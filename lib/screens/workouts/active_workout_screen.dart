import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/active_workout_provider.dart';
import '../../providers/rest_timer_provider.dart';
import '../../providers/exercise_provider.dart';
import '../../models/workout_model.dart';
import '../../models/workout_log_model.dart';
import '../../models/exercise_model.dart';
import '../../widgets/rest_timer_banner.dart';
import '../../widgets/exercise_preview_modal.dart';
import '../../widgets/exercise_visual_card.dart';
import '../../widgets/bouncing_touch_target.dart';
import '../../core/constants/default_exercises.dart';
import '../../core/utils/app_animations.dart';
import '../../core/utils/unit_converter.dart';
import '../../providers/settings_provider.dart';
import '../../providers/wearable_provider.dart';

class ActiveWorkoutScreen extends ConsumerStatefulWidget {
  const ActiveWorkoutScreen({super.key});

  @override
  ConsumerState<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends ConsumerState<ActiveWorkoutScreen> {
  @override
  Widget build(BuildContext context) {
    final activeState = ref.watch(activeWorkoutProvider);
    final log = activeState.log;
    final weightUnit = ref.watch(settingsProvider).weightUnit;
    final wearableState = ref.watch(wearableProvider);

    if (log == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Active Workout')),
        body: const Center(child: Text('No active workout.')),
      );
    }

    // Calculate volume
    double volume = 0;
    int completedSets = 0;
    for (var ex in log.exercises) {
      for (var set in ex.sets) {
        if (set.completed) {
          volume += set.weight * set.reps;
          completedSets++;
        }
      }
    }

    return Hero(
      tag: 'active_workout_pill',
      child: Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down, size: 32),
          onPressed: () {
            context.pop();
          },
        ),
        title: Text(
          log.name, 
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: false,
        actions: [
          // Live Heart Rate Badge (shows real BPM streamed from Wear OS)
          if (wearableState.isConnected)
            GestureDetector(
              onTap: () => _showWearOsModal(context, ref, wearableState),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                margin: const EdgeInsets.only(right: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF5350).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFEF5350).withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.favorite, color: Color(0xFFEF5350), size: 14),
                    const SizedBox(width: 4),
                    Text(
                      wearableState.currentBpm != null ? '${wearableState.currentBpm}' : '--',
                      style: const TextStyle(color: Color(0xFFEF5350), fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      'BPM',
                      style: TextStyle(
                        color: const Color(0xFFEF5350).withValues(alpha: 0.7),
                        fontWeight: FontWeight.w600,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Real Wear OS connection status icon
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              _showWearOsModal(context, ref, wearableState);
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 4.0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.watch,
                    size: 26,
                    color: wearableState.isConnected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  Positioned(
                    right: 0,
                    bottom: 8,
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: wearableState.isConnected
                            ? Colors.greenAccent
                            : (wearableState.isPinging ? Colors.amber : Colors.grey),
                        shape: BoxShape.circle,
                        border: Border.all(color: Theme.of(context).colorScheme.surface, width: 1.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.timer_outlined),
            tooltip: 'Start 90s Rest',
            onPressed: () {
              HapticFeedback.lightImpact();
              ref.read(restTimerProvider.notifier).start(90);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Started 90s rest timer!'), duration: Duration(seconds: 1)),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12.0, top: 8.0, bottom: 8.0),
            child: BouncingTouchTarget(
              onTap: () {
                HapticFeedback.heavyImpact();
                _showFinishWorkoutModal(context, ref, log, volume, completedSets, weightUnit);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: const Text('Finish', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats Row
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                WorkoutTimerText(startTime: activeState.log!.startTime, color: Theme.of(context).colorScheme.primary),
                _buildStatColumn(context, 'Volume', '${UnitConverter.toDisplayWeight(volume, weightUnit).toInt()} $weightUnit', Theme.of(context).colorScheme.onSurface),
                _buildStatColumn(context, 'Sets', '$completedSets', Theme.of(context).colorScheme.onSurface),
                IconButton(
                  icon: const Icon(Icons.timer, size: 28),
                  color: Theme.of(context).colorScheme.primary,
                  onPressed: () {
                    ref.read(restTimerProvider.notifier).start(90);
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Exercises List or Empty State
          Expanded(
            child: log.exercises.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.fitness_center, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant),
                          const SizedBox(height: 16),
                          const Text('Get started', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text('Add an exercise to start your workout', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 16)),
                          const SizedBox(height: 32),
                          _buildBottomControls(context, ref),
                        ],
                      ),
                    ),
                  )
                : ReorderableListView(
                    padding: const EdgeInsets.only(bottom: 120),
                    onReorderItem: (oldIndex, newIndex) {
                      HapticFeedback.lightImpact();
                      ref.read(activeWorkoutProvider.notifier).reorderExercises(oldIndex, newIndex);
                    },
                    footer: Padding(
                      key: const ValueKey('bottom_controls'),
                      padding: const EdgeInsets.all(16.0),
                      child: _buildBottomControls(context, ref),
                    ),
                    children: log.exercises.map((exercise) {
                      return _buildActiveExerciseCard(context, ref, exercise, key: ValueKey(exercise.id));
                    }).toList(),
                  ),
          ),
        ],
      ),
      bottomSheet: const RestTimerBanner(), 
    ));
  }

  void _showWearOsModal(BuildContext context, WidgetRef ref, WearableState watchState) {
    AppAnimations.showAnimatedBottomSheet(
      context: context,
      builder: (ctx) {
        return Consumer(
          builder: (context, ref, _) {
            final liveWatch = ref.watch(wearableProvider);
            final cs = Theme.of(context).colorScheme;

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: cs.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.watch, color: cs.onPrimaryContainer, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Wear OS Companion',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: liveWatch.isConnected ? Colors.greenAccent : Colors.grey,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    liveWatch.isConnected
                                        ? (liveWatch.watchName.isNotEmpty ? liveWatch.watchName : 'Connected')
                                        : 'Disconnected • Open AV Fitness on watch',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: liveWatch.isConnected ? cs.onSurface : cs.onSurfaceVariant,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        if (liveWatch.batteryLevel != null && liveWatch.batteryLevel! >= 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: cs.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.battery_charging_full_rounded, size: 14),
                                const SizedBox(width: 4),
                                Text('${liveWatch.batteryLevel}%', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Heart Rate Live Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFEF5350).withValues(alpha: 0.15),
                            const Color(0xFFFF7043).withValues(alpha: 0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFEF5350).withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.favorite, color: Color(0xFFEF5350), size: 20),
                                  const SizedBox(width: 6),
                                  Text(
                                    'LIVE HEART RATE',
                                    style: TextStyle(
                                      color: cs.onSurfaceVariant,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                              if (liveWatch.isConnected && liveWatch.currentBpm != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEF5350),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Text(
                                    'ACTIVE STREAM',
                                    style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                liveWatch.currentBpm != null ? '${liveWatch.currentBpm}' : '--',
                                style: const TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFFEF5350),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'BPM',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Stats row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildMiniWatchStat('AVG', liveWatch.averageBpm > 0 ? '${liveWatch.averageBpm}' : '--', cs),
                              _buildMiniWatchStat('MAX', liveWatch.maxBpm > 0 ? '${liveWatch.maxBpm}' : '--', cs),
                              _buildMiniWatchStat('MIN', liveWatch.minBpm > 0 ? '${liveWatch.minBpm}' : '--', cs),
                              _buildMiniWatchStat('SAMPLES', '${liveWatch.samplesCount}', cs),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.vibration_rounded, size: 18),
                            label: Text(liveWatch.isPinging ? 'Pinging...' : 'Ping Watch'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: liveWatch.isPinging
                                ? null
                                : () async {
                                    HapticFeedback.lightImpact();
                                    await ref.read(wearableProvider.notifier).pingWatch();
                                    if (ctx.mounted) {
                                      ScaffoldMessenger.of(ctx).showSnackBar(
                                        const SnackBar(
                                          content: Text('Pinged watch! Watch should vibrate.'),
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
                                    }
                                  },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton.tonalIcon(
                            icon: const Icon(Icons.sync_rounded, size: 18),
                            label: const Text('Refresh'),
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () async {
                              HapticFeedback.lightImpact();
                              await ref.read(wearableProvider.notifier).refreshConnection();
                            },
                          ),
                        ),
                      ],
                    ),
                    if (liveWatch.pingLatencyMs != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Watch responded in ${liveWatch.pingLatencyMs}ms ✓',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 11, color: Colors.greenAccent, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMiniWatchStat(String label, String value, ColorScheme cs) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(fontSize: 10, color: cs.onSurfaceVariant, fontWeight: FontWeight.w600)),
      ],
    );
  }

  void _showFinishWorkoutModal(BuildContext context, WidgetRef ref, WorkoutLog log, double volume, int completedSets, String weightUnit) {
    bool updateTemplate = log.templateId.isNotEmpty;

    AppAnimations.showAnimatedBottomSheet(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('Finish Workout', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatColumn(context, 'Volume', '${UnitConverter.toDisplayWeight(volume, weightUnit).toInt()} $weightUnit', Theme.of(context).colorScheme.primary),
                        _buildStatColumn(context, 'Sets', '$completedSets', Theme.of(context).colorScheme.primary),
                      ],
                    ),
                    const SizedBox(height: 24),
                    if (log.templateId.isNotEmpty) ...[
                      const Divider(),
                      CheckboxListTile(
                        title: const Text('Update routine template', style: TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: const Text('Save your changes (new exercises, sets, or reps) back to the original template.', style: TextStyle(fontSize: 12)),
                        value: updateTemplate,
                        onChanged: (val) {
                          setState(() {
                            updateTemplate = val ?? false;
                          });
                        },
                        activeColor: Theme.of(context).colorScheme.primary,
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                      const SizedBox(height: 16),
                    ],
                    ElevatedButton(
                      onPressed: () async {
                        HapticFeedback.heavyImpact();
                        Navigator.pop(ctx); // close bottom sheet
                        final finalLog = await ref.read(activeWorkoutProvider.notifier).finishWorkout(updateTemplate: updateTemplate);
                        if (context.mounted && finalLog != null) {
                          context.pushReplacement('/workouts/summary', extra: finalLog);
                        } else if (context.mounted) {
                          context.pop();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Save Workout', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBottomControls(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: BouncingTouchTarget(
            onTap: () async {
              // Navigate to exercise picker and get selected exercises back
              final result = await context.push<List<Exercise>>('/workouts/build/select-exercises');
              if (result != null && result.isNotEmpty) {
                ref.read(activeWorkoutProvider.notifier).addExercisesToWorkout(result);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.add, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Add Exercise', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  AppAnimations.showAnimatedBottomSheet(
                    context: context,
                    builder: (ctx) => SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Quick Rest Timer', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [30, 60, 90, 120, 180].map((s) => ActionChip(
                                label: Text('${s}s'),
                                onPressed: () {
                                  ref.read(restTimerProvider.notifier).start(s);
                                  Navigator.pop(ctx);
                                },
                              )).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  foregroundColor: Theme.of(context).colorScheme.onSurface,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text('Timer Options', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () async {
                  // Show confirmation dialog before discarding
                  final confirmed = await AppAnimations.showAnimatedDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Discard Workout?'),
                      content: const Text('Are you sure you want to discard this workout? All progress will be lost.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('Discard', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true) {
                    ref.read(activeWorkoutProvider.notifier).discardWorkout();
                    if (context.mounted) {
                      context.pop();
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  foregroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text('Discard Workout', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatColumn(BuildContext context, String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12)),
        const SizedBox(height: 4),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: Text(
            value,
            key: ValueKey<String>(value),
            style: TextStyle(color: valueColor, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildActiveExerciseCard(BuildContext context, WidgetRef ref, WorkoutExercise exercise, {Key? key}) {
    final weightUnit = ref.watch(settingsProvider).weightUnit;
    // Watch previous performance for this exercise
    final prevPerfAsync = ref.watch(previousPerformanceProvider(exercise.exerciseId));
    final prevPerf = prevPerfAsync.maybeWhen(data: (d) => d, orElse: () => <int, String>{});
    final prAsync = ref.watch(personalRecordProvider(exercise.exerciseId));
    final bestWeightKg = prAsync.maybeWhen(data: (d) => d, orElse: () => 0.0);

    return Padding(
      key: key,
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    final allExercises = ref.read(exerciseListProvider).valueOrNull ?? DefaultExercises.list;
                    final matched = allExercises.firstWhere(
                      (e) => e.id == exercise.exerciseId || e.name.toLowerCase() == exercise.exerciseName.toLowerCase(),
                      orElse: () => Exercise(
                        id: exercise.exerciseId,
                        name: exercise.exerciseName,
                        muscleGroup: 'Full Body',
                        equipment: 'Standard',
                        isCustom: false,
                      ),
                    );
                    ExercisePreviewModal.show(context, exercise: matched);
                  },
                  child: Stack(
                    children: [
                      Builder(
                        builder: (context) {
                          final allExercises = ref.read(exerciseListProvider).valueOrNull ?? DefaultExercises.list;
                          final matched = allExercises.firstWhere(
                            (e) => e.id == exercise.exerciseId || e.name.toLowerCase() == exercise.exerciseName.toLowerCase(),
                            orElse: () => Exercise(
                              id: exercise.exerciseId,
                              name: exercise.exerciseName,
                              muscleGroup: 'Full Body',
                              equipment: 'Standard',
                              isCustom: false,
                            ),
                          );
                          return ExerciseVisualCard(
                            exercise: matched,
                            width: 44,
                            height: 44,
                            borderRadius: 10,
                            showLabels: false,
                            isHero: false,
                          );
                        },
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(1.5),
                          decoration: const BoxDecoration(color: Colors.black87, shape: BoxShape.circle),
                          child: const Icon(Icons.info_outline, size: 10, color: Colors.white70),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      final allExercises = ref.read(exerciseListProvider).valueOrNull ?? DefaultExercises.list;
                      final matched = allExercises.firstWhere(
                        (e) => e.id == exercise.exerciseId || e.name.toLowerCase() == exercise.exerciseName.toLowerCase(),
                        orElse: () => Exercise(
                          id: exercise.exerciseId,
                          name: exercise.exerciseName,
                          muscleGroup: 'Full Body',
                          equipment: 'Standard',
                          isCustom: false,
                        ),
                      );
                      ExercisePreviewModal.show(context, exercise: matched);
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            exercise.exerciseName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const Text(
                            'Tap to view form guide',
                            style: TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) async {
                    if (value == 'preview') {
                      final allExercises = ref.read(exerciseListProvider).valueOrNull ?? DefaultExercises.list;
                      final matched = allExercises.firstWhere(
                        (e) => e.id == exercise.exerciseId || e.name.toLowerCase() == exercise.exerciseName.toLowerCase(),
                        orElse: () => Exercise(
                          id: exercise.exerciseId,
                          name: exercise.exerciseName,
                          muscleGroup: 'Full Body',
                          equipment: 'Standard',
                          isCustom: false,
                        ),
                      );
                      ExercisePreviewModal.show(context, exercise: matched);
                    } else if (value == 'replace') {
                      final selected = await context.push<List<Exercise>>('/workouts/build/select-exercises');
                      if (selected != null && selected.isNotEmpty) {
                        ref.read(activeWorkoutProvider.notifier).replaceExerciseInWorkout(exercise.id, selected.first);
                      }
                    } else if (value == 'remove') {
                      ref.read(activeWorkoutProvider.notifier).removeExerciseFromWorkout(exercise.id);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'preview', child: Row(children: [Icon(Icons.info_outline), SizedBox(width: 12), Text('How to Perform')])),
                    const PopupMenuItem(value: 'replace', child: Row(children: [Icon(Icons.swap_horiz), SizedBox(width: 12), Text('Replace Exercise')])),
                    const PopupMenuItem(value: 'remove', child: Row(children: [Icon(Icons.delete, color: Colors.red), SizedBox(width: 12), Text('Remove Exercise', style: TextStyle(color: Colors.red))])),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Editable Notes
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Add notes here...',
                hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
                border: InputBorder.none,
              ),
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
              onChanged: (val) {
                ref.read(activeWorkoutProvider.notifier).updateNotes(exercise.id, val);
              },
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Icon(Icons.timer_outlined, size: 16, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 4),
                Text('Rest Timer: 90s', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Table Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                const SizedBox(width: 32, child: Text('SET', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1), textAlign: TextAlign.center)),
                Expanded(flex: 2, child: Text('PREVIOUS', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1), textAlign: TextAlign.center)),
                Expanded(child: Text(weightUnit.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1), textAlign: TextAlign.center)),
                const Expanded(child: Text('REPS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1), textAlign: TextAlign.center)),
                const Expanded(child: Text('RPE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1), textAlign: TextAlign.center)),
                const SizedBox(width: 48, child: Icon(Icons.check, size: 18)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Sets
          ...exercise.sets.map((set) => _buildActiveSetRow(context, ref, exercise.id, set, prevPerf, bestWeightKg, weightUnit)),
          // Add Set Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: BouncingTouchTarget(
              onTap: () {
                HapticFeedback.lightImpact();
                ref.read(activeWorkoutProvider.notifier).addSetToExercise(exercise.id);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('+ Add Set', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveSetRow(BuildContext context, WidgetRef ref, String exerciseId, WorkoutSet set, Map<int, String> prevPerf, double bestWeightKg, String weightUnit) {
    final isCompleted = set.completed;
    final isPR = isCompleted && set.weight > bestWeightKg && set.weight > 0;
    final rowColor = isPR 
        ? Colors.amber.withValues(alpha: 0.15) 
        : isCompleted 
            ? Colors.green.withValues(alpha: 0.1) 
            : Colors.transparent;
    final previousText = prevPerf[set.setNumber] ?? '-';
    final displayWeight = UnitConverter.toDisplayWeight(set.weight, weightUnit);

    return AnimatedSetRow(
      key: ValueKey('anim_set_${set.id}'),
      child: Dismissible(
        key: ValueKey('set_${set.id}'),
        direction: DismissDirection.endToStart,
        movementDuration: const Duration(milliseconds: 300),
        resizeDuration: const Duration(milliseconds: 300),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        color: Colors.redAccent,
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) {
        ref.read(activeWorkoutProvider.notifier).removeSet(exerciseId, set.id);
      },
      child: Container(
        color: rowColor,
        padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 16.0),
        child: Row(
          children: [
            SizedBox(
              width: 32,
              child: isPR
                  ? const Icon(Icons.emoji_events, color: Colors.amber, size: 20)
                  : Container(
                      padding: const EdgeInsets.all(4),
                      decoration: isCompleted ? null : BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text('${set.setNumber}', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                previousText,
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.w600),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: TextFormField(
                  initialValue: displayWeight == 0 ? '' : displayWeight.toStringAsFixed(displayWeight.truncateToDouble() == displayWeight ? 0 : 1),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  decoration: InputDecoration(
                    hintText: '-',
                    hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    filled: true,
                    fillColor: isCompleted ? Colors.green.withValues(alpha: 0.2) : Theme.of(context).colorScheme.surfaceContainerHighest,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                  ),
                  onChanged: (val) {
                    final weightInput = double.tryParse(val);
                    final weightKg = weightInput != null ? UnitConverter.toStorageWeight(weightInput, weightUnit) : null;
                    ref.read(activeWorkoutProvider.notifier).updateSet(exerciseId, set.id, weight: weightKg);
                  },
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: TextFormField(
                initialValue: set.reps == 0 ? '' : set.reps.toString(),
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                decoration: InputDecoration(
                  hintText: '-',
                  hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  filled: true,
                  fillColor: isCompleted ? Colors.green.withValues(alpha: 0.2) : Theme.of(context).colorScheme.surfaceContainerHighest,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                ),
                onChanged: (val) {
                  final reps = int.tryParse(val);
                  ref.read(activeWorkoutProvider.notifier).updateSet(exerciseId, set.id, reps: reps);
                },
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: TextFormField(
                initialValue: set.rpe == null ? '' : set.rpe.toString(),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                decoration: InputDecoration(
                  hintText: '-',
                  hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  filled: true,
                  fillColor: isCompleted ? Colors.green.withValues(alpha: 0.2) : Theme.of(context).colorScheme.surfaceContainerHighest,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                ),
                onChanged: (val) {
                  final rpe = double.tryParse(val);
                  ref.read(activeWorkoutProvider.notifier).updateSet(exerciseId, set.id, rpe: rpe);
                },
              ),
            ),
          ),
          const SizedBox(width: 8),
          BouncingTouchTarget(
            onTap: () {
              HapticFeedback.lightImpact();
              ref.read(activeWorkoutProvider.notifier).toggleSetComplete(exerciseId, set.id);
            },
            child: Container(
              width: 40,
              height: 36,
              decoration: BoxDecoration(
                color: isCompleted ? Colors.green : Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.check, color: isCompleted ? Colors.white : Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    ),
  ),
);
  }
}

class AnimatedSetRow extends StatefulWidget {
  final Widget child;

  const AnimatedSetRow({super.key, required this.child});

  @override
  State<AnimatedSetRow> createState() => _AnimatedSetRowState();
}

class _AnimatedSetRowState extends State<AnimatedSetRow> with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _sizeAnimation;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.5, 0.0), // Start slightly from right
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
    _sizeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required by AutomaticKeepAliveClientMixin
    return SizeTransition(
      sizeFactor: _sizeAnimation,
      axisAlignment: -1.0,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: widget.child,
        ),
      ),
    );
  }
}

class WorkoutTimerText extends StatefulWidget {
  final DateTime startTime;
  final Color color;

  const WorkoutTimerText({super.key, required this.startTime, required this.color});

  @override
  State<WorkoutTimerText> createState() => _WorkoutTimerTextState();
}

class _WorkoutTimerTextState extends State<WorkoutTimerText> with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  late Duration _elapsed;

  @override
  void initState() {
    super.initState();
    _elapsed = DateTime.now().difference(widget.startTime);
    _ticker = createTicker((elapsed) {
      final newElapsed = DateTime.now().difference(widget.startTime);
      if (newElapsed.inSeconds != _elapsed.inSeconds) {
        setState(() {
          _elapsed = newElapsed;
        });
      }
    });
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    int hours = duration.inHours;
    int minutes = duration.inMinutes.remainder(60);
    int seconds = duration.inSeconds.remainder(60);
    if (hours > 0) {
      return "${hours}h ${minutes}m";
    } else if (minutes > 0) {
      return "${minutes}m ${seconds}s";
    } else {
      return "${seconds}s";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Duration', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12)),
        const SizedBox(height: 4),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: Text(
            _formatDuration(_elapsed),
            key: ValueKey<int>(_elapsed.inSeconds),
            style: TextStyle(color: widget.color, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
