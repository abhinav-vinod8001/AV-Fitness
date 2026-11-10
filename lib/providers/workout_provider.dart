import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/workout_model.dart';
import '../models/exercise_model.dart';
import '../models/folder_model.dart';
import '../repositories/workout_repository.dart';
import '../repositories/folder_repository.dart';
import 'exercise_provider.dart'; // for mockUserIdProvider

final workoutRepositoryProvider = Provider<WorkoutRepository>((ref) {
  return WorkoutRepository();
});

final workoutTemplatesProvider = FutureProvider<List<WorkoutTemplate>>((ref) async {
  final repo = ref.watch(workoutRepositoryProvider);
  final userId = ref.watch(mockUserIdProvider);
  final templates = await repo.getTemplates(userId);
  // Sort by sortOrder to preserve user's custom ordering
  templates.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  return templates;
});

/// Batch-save reordered templates with updated sortOrder values
Future<void> reorderTemplates(WidgetRef ref, List<WorkoutTemplate> reordered) async {
  final repo = ref.read(workoutRepositoryProvider);
  for (int i = 0; i < reordered.length; i++) {
    final updated = reordered[i].copyWith(sortOrder: i);
    await repo.saveTemplate(updated);
  }
  ref.invalidate(workoutTemplatesProvider);
}

final folderRepositoryProvider = Provider<FolderRepository>((ref) {
  return FolderRepository();
});

final workoutFoldersProvider = FutureProvider<List<WorkoutFolder>>((ref) async {
  final repo = ref.watch(folderRepositoryProvider);
  final userId = ref.watch(mockUserIdProvider);
  return repo.getFolders(userId);
});

class WorkoutBuilderNotifier extends StateNotifier<WorkoutTemplate> {
  final Ref ref;

  WorkoutBuilderNotifier(this.ref, [WorkoutTemplate? initial])
      : super(
          initial ??
              WorkoutTemplate(
                id: '',
                name: 'New Routine',
                exercises: [],
                userId: ref.read(mockUserIdProvider),
              ),
        );

  void loadTemplate(WorkoutTemplate template) {
    state = template;
  }

  void updateName(String name) {
    state = state.copyWith(name: name);
  }

  void updateNotes(String notes) {
    state = state.copyWith(notes: notes);
  }

  void updateFolderId(String? folderId) {
    state = state.copyWith(folderId: folderId);
  }

  void addExercises(List<Exercise> exercises) {
    final newWorkoutExercises = exercises.map((ex) {
      return WorkoutExercise(
        id: const Uuid().v4(),
        exerciseId: ex.id,
        exerciseName: ex.name,
        sets: [
          WorkoutSet(id: const Uuid().v4(), setNumber: 1, weight: 0, reps: 0),
        ],
      );
    }).toList();

    state = state.copyWith(
      exercises: [...state.exercises, ...newWorkoutExercises],
    );
  }

  void removeExercise(String workoutExerciseId) {
    state = state.copyWith(
      exercises: state.exercises.where((e) => e.id != workoutExerciseId).toList(),
    );
  }

  void reorderExercises(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final exercises = List<WorkoutExercise>.from(state.exercises);
    final item = exercises.removeAt(oldIndex);
    exercises.insert(newIndex, item);
    state = state.copyWith(exercises: exercises);
  }

  void addSet(String workoutExerciseId) {
    final exercises = state.exercises.map((ex) {
      if (ex.id == workoutExerciseId) {
        final newSetNum = ex.sets.isEmpty ? 1 : ex.sets.last.setNumber + 1;
        // Copy the previous set's weight and reps if available to save time typing
        final previousSet = ex.sets.isNotEmpty ? ex.sets.last : null;
        
        final newSet = WorkoutSet(
          id: const Uuid().v4(),
          setNumber: newSetNum,
          weight: previousSet?.weight ?? 0.0,
          reps: previousSet?.reps ?? 0,
          isWarmup: false,
        );
        return ex.copyWith(sets: [...ex.sets, newSet]);
      }
      return ex;
    }).toList();
    
    state = state.copyWith(exercises: exercises);
  }

  void removeSet(String workoutExerciseId, String setId) {
    final exercises = state.exercises.map((ex) {
      if (ex.id == workoutExerciseId) {
        final newSets = ex.sets.where((s) => s.id != setId).toList();
        // Re-number sets
        for (int i = 0; i < newSets.length; i++) {
          newSets[i] = newSets[i].copyWith(setNumber: i + 1);
        }
        return ex.copyWith(sets: newSets);
      }
      return ex;
    }).toList();

    state = state.copyWith(exercises: exercises);
  }

  void updateSet(String workoutExerciseId, String setId, {double? weight, int? reps, double? rpe, bool? isWarmup}) {
    final exercises = state.exercises.map((ex) {
      if (ex.id == workoutExerciseId) {
        final newSets = ex.sets.map((s) {
          if (s.id == setId) {
            return s.copyWith(
              weight: weight ?? s.weight,
              reps: reps ?? s.reps,
              rpe: rpe ?? s.rpe,
              isWarmup: isWarmup ?? s.isWarmup,
            );
          }
          return s;
        }).toList();
        return ex.copyWith(sets: newSets);
      }
      return ex;
    }).toList();

    state = state.copyWith(exercises: exercises);
  }

  Future<void> saveRoutine() async {
    final repo = ref.read(workoutRepositoryProvider);
    final userId = ref.read(mockUserIdProvider);
    final templateToSave = state.userId == null || state.userId!.isEmpty
        ? state.copyWith(userId: userId)
        : state;
    await repo.saveTemplate(templateToSave);
    ref.invalidate(workoutTemplatesProvider);
  }
}

// We use an autoDispose provider so that the builder state resets when leaving the screen.
final workoutBuilderProvider = StateNotifierProvider.autoDispose<WorkoutBuilderNotifier, WorkoutTemplate>((ref) {
  return WorkoutBuilderNotifier(ref);
});
