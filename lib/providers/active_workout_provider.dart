import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/workout_model.dart';
import '../models/workout_log_model.dart';
import '../models/exercise_model.dart';
import '../repositories/workout_log_repository.dart';
import '../core/services/live_activity_service.dart';
import '../core/services/workout_persistence_service.dart';
import '../core/services/wearable_service.dart';
import '../core/services/widget_data_service.dart';
import 'exercise_provider.dart';
import 'rest_timer_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'workout_provider.dart';

final workoutLogRepositoryProvider = Provider<WorkoutLogRepository>((ref) {
  return WorkoutLogRepository();
});

class ActiveWorkoutState {
  final WorkoutLog? log;
  final Duration elapsedTime;

  ActiveWorkoutState({this.log, this.elapsedTime = Duration.zero});
}

class ActiveWorkoutNotifier extends StateNotifier<ActiveWorkoutState> {
  final Ref ref;
  Timer? _saveDebounceTimer;

  ActiveWorkoutNotifier(this.ref) : super(ActiveWorkoutState()) {
    LiveActivityService.initialize(
      onAddRest: (seconds) {
        ref.read(restTimerProvider.notifier).addTime(seconds);
      },
      onSkipRest: () {
        ref.read(restTimerProvider.notifier).stop();
      },
      onCompleteSet: (exerciseId, setId) {
        toggleSetComplete(exerciseId, setId);
      },
    );

    // Initialize Wear OS watch integration
    WearableService().init();
    WearableService().onWorkoutCommand = (command) {
      switch (command) {
        case 'complete_set':
          completeNextActiveSet();
          break;
        case 'skip_rest':
          ref.read(restTimerProvider.notifier).stop();
          break;
        case 'add_rest_30':
          ref.read(restTimerProvider.notifier).addTime(30);
          break;
      }
    };

    ref.listen<RestTimerState>(restTimerProvider, (prev, next) {
      if (state.log != null) {
        _syncLiveActivity(
          isResting: next.isActive,
          restTimeRemaining: next.remainingSeconds,
        );
      }
    });
  }

  /// Automatically completes the first incomplete set in the active workout
  void completeNextActiveSet() {
    final log = state.log;
    if (log == null) return;
    for (final ex in log.exercises) {
      for (final set in ex.sets) {
        if (!set.completed) {
          toggleSetComplete(ex.id, set.id);
          return;
        }
      }
    }
  }

  void _syncLiveActivity({bool isResting = false, int restTimeRemaining = 0}) {
    final log = state.log;
    if (log == null) {
      LiveActivityService.stop();
      WearableService().sendWorkoutStop();
      WidgetDataService.updateActiveWorkout(isActive: false);
      return;
    }

    final totalSets = log.exercises.fold<int>(0, (sum, ex) => sum + ex.sets.length);
    final completedSets = log.exercises.fold<int>(
      0,
      (sum, ex) => sum + ex.sets.where((s) => s.completed).length,
    );
    
    // Find next uncompleted set for the live activity & watch
    String currentExerciseName = log.exercises.isNotEmpty ? log.exercises.first.exerciseName : '';
    int? currentSetNumber;
    int? totalExerciseSets;
    double? currentSetWeight;
    int? currentSetReps;
    String? nextSetExerciseId;
    String? nextSetId;
    
    for (final ex in log.exercises) {
      final nextSet = ex.sets.firstWhere((s) => !s.completed, orElse: () => ex.sets.last);
      if (!nextSet.completed) {
        currentExerciseName = ex.exerciseName;
        currentSetNumber = nextSet.setNumber;
        totalExerciseSets = ex.sets.length;
        currentSetWeight = nextSet.weight;
        currentSetReps = nextSet.reps;
        nextSetExerciseId = ex.id;
        nextSetId = nextSet.id;
        break; // found the next active set
      }
    }

    // 1. Sync Live Activity notification
    LiveActivityService.startOrUpdate(
      workoutName: log.name,
      currentExercise: currentExerciseName,
      completedSets: completedSets,
      totalSets: totalSets,
      startTime: log.startTime,
      isResting: isResting,
      restTimeRemaining: restTimeRemaining,
      currentSetNumber: currentSetNumber,
      totalExerciseSets: totalExerciseSets,
      currentSetWeight: currentSetWeight,
      currentSetReps: currentSetReps,
      nextSetExerciseId: nextSetExerciseId,
      nextSetId: nextSetId,
    );

    // 2. Sync Wear OS watch app in real time
    WearableService().sendWorkoutState(
      workoutName: log.name,
      currentExercise: currentExerciseName,
      completedSets: completedSets,
      totalSets: totalSets,
      isResting: isResting,
      restTimeRemaining: restTimeRemaining,
      elapsedSeconds: state.elapsedTime.inSeconds,
      currentSetNumber: currentSetNumber,
      totalExerciseSets: totalExerciseSets,
      currentSetWeight: currentSetWeight,
      currentSetReps: currentSetReps,
    );

    // 3. Sync home screen widgets
    WidgetDataService.updateActiveWorkout(
      isActive: true,
      workoutName: log.name,
      currentExercise: currentExerciseName,
    );
  }

  /// Starts a quick empty workout directly (e.g. from Home Screen widget)
  Future<void> startQuickWorkout() async {
    final emptyTemplate = WorkoutTemplate(
      id: 'empty-${DateTime.now().millisecondsSinceEpoch}',
      name: 'Quick Workout',
      exercises: [],
    );
    await startWorkout(emptyTemplate);
  }

  Future<void> startWorkout(WorkoutTemplate template) async {
    // Request notification permission for Live Activity
    await Permission.notification.request();

    // Deep copy sets to ensure they aren't marked complete in the template itself
    final activeExercises = template.exercises.map((ex) {
      final activeSets = ex.sets.map((set) => set.copyWith(completed: false)).toList();
      return ex.copyWith(sets: activeSets);
    }).toList();

    final log = WorkoutLog(
      id: const Uuid().v4(),
      templateId: template.id,
      name: template.name,
      startTime: DateTime.now(),
      endTime: DateTime.now(), // Updated on finish
      exercises: activeExercises,
      userId: ref.read(mockUserIdProvider),
    );

    state = ActiveWorkoutState(log: log, elapsedTime: Duration.zero);
    WearableService().startSession();
    WearableService().sendWorkoutStart(log.name);
    _syncLiveActivity();
    _persistState(); // Save immediately on start
  }

  void toggleSetComplete(String exerciseId, String setId) {
    if (state.log == null) return;

    bool wasJustCompleted = false;

    final updatedExercises = state.log!.exercises.map((ex) {
      if (ex.id == exerciseId) {
        final updatedSets = ex.sets.map((set) {
          if (set.id == setId) {
            wasJustCompleted = !set.completed;
            return set.copyWith(completed: !set.completed);
          }
          return set;
        }).toList();
        return ex.copyWith(sets: updatedSets);
      }
      return ex;
    }).toList();

    state = ActiveWorkoutState(
      log: WorkoutLog(
        id: state.log!.id,
        templateId: state.log!.templateId,
        name: state.log!.name,
        startTime: state.log!.startTime,
        endTime: state.log!.endTime,
        exercises: updatedExercises,
        userId: state.log!.userId,
      ),
      elapsedTime: state.elapsedTime,
    );
    _debouncedPersist();

    // Trigger rest timer if a set was checked as complete
    if (wasJustCompleted) {
      ref.read(restTimerProvider.notifier).start(90); // default 90s rest
    } else {
      _syncLiveActivity();
    }
  }

  void updateSet(String exerciseId, String setId, {double? weight, int? reps, double? rpe}) {
    if (state.log == null) return;

    final updatedExercises = state.log!.exercises.map((ex) {
      if (ex.id == exerciseId) {
        final updatedSets = ex.sets.map((set) {
          if (set.id == setId) {
            return set.copyWith(
              weight: weight ?? set.weight,
              reps: reps ?? set.reps,
              rpe: rpe ?? set.rpe,
            );
          }
          return set;
        }).toList();
        return ex.copyWith(sets: updatedSets);
      }
      return ex;
    }).toList();

    state = ActiveWorkoutState(
      log: WorkoutLog(
        id: state.log!.id,
        templateId: state.log!.templateId,
        name: state.log!.name,
        startTime: state.log!.startTime,
        endTime: state.log!.endTime,
        exercises: updatedExercises,
        userId: state.log!.userId,
      ),
      elapsedTime: state.elapsedTime,
    );
    _debouncedPersist();
  }

  void removeSet(String exerciseId, String setId) {
    if (state.log == null) return;

    final updatedExercises = state.log!.exercises.map((ex) {
      if (ex.id == exerciseId) {
        final remainingSets = ex.sets.where((set) => set.id != setId).toList();
        final renumberedSets = List.generate(remainingSets.length, (index) {
          return remainingSets[index].copyWith(setNumber: index + 1);
        });
        return ex.copyWith(sets: renumberedSets);
      }
      return ex;
    }).toList();

    state = ActiveWorkoutState(
      log: state.log!.copyWith(exercises: updatedExercises),
      elapsedTime: state.elapsedTime,
    );
    _debouncedPersist();
  }

  void updateNotes(String exerciseId, String notes) {
    if (state.log == null) return;

    final updatedExercises = state.log!.exercises.map((ex) {
      if (ex.id == exerciseId) {
        return ex.copyWith(notes: notes);
      }
      return ex;
    }).toList();

    state = ActiveWorkoutState(
      log: WorkoutLog(
        id: state.log!.id,
        templateId: state.log!.templateId,
        name: state.log!.name,
        startTime: state.log!.startTime,
        endTime: state.log!.endTime,
        exercises: updatedExercises,
        userId: state.log!.userId,
      ),
      elapsedTime: state.elapsedTime,
    );
    _debouncedPersist();
  }

  void addExercisesToWorkout(List<Exercise> exercises) {
    if (state.log == null) return;
    const uuid = Uuid();

    final newExercises = exercises.map((exercise) {
      return WorkoutExercise(
        id: uuid.v4(),
        exerciseId: exercise.id,
        exerciseName: exercise.name,
        sets: [
          WorkoutSet(id: uuid.v4(), setNumber: 1),
          WorkoutSet(id: uuid.v4(), setNumber: 2),
          WorkoutSet(id: uuid.v4(), setNumber: 3),
        ],
      );
    }).toList();

    state = ActiveWorkoutState(
      log: WorkoutLog(
        id: state.log!.id,
        templateId: state.log!.templateId,
        name: state.log!.name,
        startTime: state.log!.startTime,
        endTime: state.log!.endTime,
        exercises: [...state.log!.exercises, ...newExercises],
        userId: state.log!.userId,
      ),
      elapsedTime: state.elapsedTime,
    );
    _syncLiveActivity();
    _debouncedPersist();
  }

  void removeExerciseFromWorkout(String exerciseId) {
    if (state.log == null) return;
    state = ActiveWorkoutState(
      log: state.log!.copyWith(
        exercises: state.log!.exercises.where((e) => e.id != exerciseId).toList(),
      ),
      elapsedTime: state.elapsedTime,
    );
    _syncLiveActivity();
    _debouncedPersist();
  }

  void reorderExercises(int oldIndex, int newIndex) {
    if (state.log == null) return;

    final List<WorkoutExercise> updatedExercises = List.from(state.log!.exercises);
    final WorkoutExercise exercise = updatedExercises.removeAt(oldIndex);
    updatedExercises.insert(newIndex, exercise);

    state = ActiveWorkoutState(
      log: state.log!.copyWith(exercises: updatedExercises),
      elapsedTime: state.elapsedTime,
    );
    _syncLiveActivity();
    _debouncedPersist();
  }

  void replaceExerciseInWorkout(String exerciseId, Exercise newExercise) {
    if (state.log == null) return;
    final updated = state.log!.exercises.map((e) {
      if (e.id == exerciseId) {
        return e.copyWith(
          exerciseId: newExercise.id,
          exerciseName: newExercise.name,
        );
      }
      return e;
    }).toList();

    state = ActiveWorkoutState(
      log: state.log!.copyWith(exercises: updated),
      elapsedTime: state.elapsedTime,
    );
    _syncLiveActivity();
    _debouncedPersist();
  }

  void addSetToExercise(String exerciseId) {
    if (state.log == null) return;
    const uuid = Uuid();

    final updatedExercises = state.log!.exercises.map((ex) {
      if (ex.id == exerciseId) {
        final newSetNumber = ex.sets.length + 1;
        final newSet = WorkoutSet(id: uuid.v4(), setNumber: newSetNumber);
        return ex.copyWith(sets: [...ex.sets, newSet]);
      }
      return ex;
    }).toList();

    state = ActiveWorkoutState(
      log: WorkoutLog(
        id: state.log!.id,
        templateId: state.log!.templateId,
        name: state.log!.name,
        startTime: state.log!.startTime,
        endTime: state.log!.endTime,
        exercises: updatedExercises,
        userId: state.log!.userId,
      ),
      elapsedTime: state.elapsedTime,
    );
    _syncLiveActivity();
    _debouncedPersist();
  }

  void discardWorkout() {
    _saveDebounceTimer?.cancel();
    ref.read(restTimerProvider.notifier).stop();
    LiveActivityService.stop();
    WearableService().sendWorkoutStop();
    WidgetDataService.updateActiveWorkout(isActive: false);
    WorkoutPersistenceService.clearActiveWorkout();
    WorkoutPersistenceService.clearRestTimerState();
    state = ActiveWorkoutState(); // Clear without saving
  }

  Future<WorkoutLog?> finishWorkout({bool updateTemplate = false}) async {
    if (state.log == null) return null;

    _saveDebounceTimer?.cancel();
    ref.read(restTimerProvider.notifier).stop();
    LiveActivityService.stop();
    WearableService().sendWorkoutStop();
    WidgetDataService.updateActiveWorkout(isActive: false);

    // Use REAL heart rate data points measured by Wear OS watch during the workout!
    final realSamples = WearableService().sessionHeartRateSamples;
    final finalHeartRateData = realSamples.length >= 3 ? realSamples : _generateMockHeartRateData();

    final finalLog = WorkoutLog(
      id: state.log!.id,
      templateId: state.log!.templateId,
      name: state.log!.name,
      startTime: state.log!.startTime,
      endTime: DateTime.now(), // Actual end time
      exercises: state.log!.exercises,
      userId: state.log!.userId,
      heartRateData: finalHeartRateData,
    );

    final repo = ref.read(workoutLogRepositoryProvider);
    await repo.saveLog(finalLog);

    // Immediately update home screen widgets with the newly finished workout!
    try {
      final allLogs = await repo.getLogs(finalLog.userId);
      await WidgetDataService.updateWidgetData(allLogs);
    } catch (_) {}

    // Clear backup after successful save to Firestore
    await WorkoutPersistenceService.clearActiveWorkout();
    await WorkoutPersistenceService.clearRestTimerState();

    if (updateTemplate && finalLog.templateId.isNotEmpty) {
      final templateRepo = ref.read(workoutRepositoryProvider);
      final userId = ref.read(mockUserIdProvider);
      final templates = await templateRepo.getTemplates(userId);
      try {
        final originalTemplate = templates.firstWhere((t) => t.id == finalLog.templateId);
        
        // Convert the completed exercises back into template format (no completed state needed, just sets & reps)
        final updatedExercises = finalLog.exercises.map((ex) {
          final cleanSets = ex.sets.map((s) => s.copyWith(completed: false)).toList();
          return ex.copyWith(sets: cleanSets);
        }).toList();

        final updatedTemplate = originalTemplate.copyWith(exercises: updatedExercises);
        await templateRepo.saveTemplate(updatedTemplate);
        ref.invalidate(workoutTemplatesProvider);
      } catch (e) {
        // Template might have been deleted, ignore
      }
    }


    state = ActiveWorkoutState(); // Clear active workout
    return finalLog;
  }

  // Generate a realistic looking mock heart rate curve based on elapsed time
  List<int> _generateMockHeartRateData() {
    final minutes = (state.elapsedTime.inSeconds / 60).ceil().clamp(5, 120); // At least 5 mins of mock data
    final data = <int>[];
    int currentBpm = 80; // start at resting
    for (int i = 0; i < minutes; i++) {
      data.add(currentBpm);
      if (i < minutes * 0.2) {
        currentBpm += 10; // warm up
      } else if (i > minutes * 0.8) {
        currentBpm -= 15; // cool down
      } else {
        // active phase (fluctuate between 120-170)
        final randomVariation = (DateTime.now().millisecond % 30) - 10;
        currentBpm = (currentBpm + randomVariation).clamp(110, 175);
      }
    }
    return data;
  }

  // ──────────────────────────────────────────────
  // Persistence helpers
  // ──────────────────────────────────────────────

  /// Debounced save — avoids excessive writes during rapid input.
  void _debouncedPersist() {
    _saveDebounceTimer?.cancel();
    _saveDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      _persistState();
    });
  }

  /// Immediately persist current state (used on lifecycle events).
  void _persistState() {
    final log = state.log;
    if (log != null) {
      WorkoutPersistenceService.saveActiveWorkout(log);
    }
  }

  /// Force-save — called by the lifecycle observer when app goes to background.
  void forceSave() {
    _saveDebounceTimer?.cancel();
    _persistState();
  }

  /// Restore a previously persisted workout (called on app startup).
  Future<void> restoreWorkoutIfAvailable() async {
    final savedLog = await WorkoutPersistenceService.loadActiveWorkout();
    if (savedLog == null) return;

    // Recalculate elapsed time from the original start time
    final elapsed = DateTime.now().difference(savedLog.startTime);

    state = ActiveWorkoutState(log: savedLog, elapsedTime: elapsed);
    WearableService().startSession();
    WearableService().sendWorkoutStart(savedLog.name);
    _syncLiveActivity();

    // Restore rest timer if applicable
    final restRemaining = await WorkoutPersistenceService.loadRestTimerRemainingSeconds();
    if (restRemaining != null && restRemaining > 0) {
      ref.read(restTimerProvider.notifier).start(restRemaining);
    }

    debugPrint('WorkoutRestore: Restored workout "${savedLog.name}" (elapsed: $elapsed)');
  }

  @override
  void dispose() {
    _saveDebounceTimer?.cancel();
    super.dispose();
  }
}

// Global provider for active workout since it can persist across screens
final activeWorkoutProvider = StateNotifierProvider<ActiveWorkoutNotifier, ActiveWorkoutState>((ref) {
  return ActiveWorkoutNotifier(ref);
});

// Provider to get previous performance for a given exercise
// Returns a map of setNumber -> "weight x reps" string
final previousPerformanceProvider = FutureProvider.family<Map<int, String>, String>((ref, exerciseId) async {
  final repo = ref.watch(workoutLogRepositoryProvider);
  final userId = ref.watch(mockUserIdProvider);
  final logs = await repo.getLogs(userId);

  // Sort newest first
  logs.sort((a, b) => b.endTime.compareTo(a.endTime));

  // Find the most recent log that contains this exercise
  for (final log in logs) {
    for (final ex in log.exercises) {
      if (ex.exerciseId == exerciseId) {
        final Map<int, String> result = {};
        for (final set in ex.sets) {
          if (set.completed) {
            result[set.setNumber] = '${set.weight} x ${set.reps}';
          }
        }
        if (result.isNotEmpty) return result;
      }
    }
  }
  return {};
});

// Provider to get personal record (best weight) for an exercise
// Returns the best weight ever lifted for this exercise
final personalRecordProvider = FutureProvider.family<double, String>((ref, exerciseId) async {
  final repo = ref.watch(workoutLogRepositoryProvider);
  final userId = ref.watch(mockUserIdProvider);
  final logs = await repo.getLogs(userId);

  double bestWeight = 0;
  for (final log in logs) {
    for (final ex in log.exercises) {
      if (ex.exerciseId == exerciseId) {
        for (final set in ex.sets) {
          if (set.completed && set.weight > bestWeight) {
            bestWeight = set.weight;
          }
        }
      }
    }
  }
  return bestWeight;
});
