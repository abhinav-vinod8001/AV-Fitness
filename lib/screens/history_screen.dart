import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/history_provider.dart';
import '../providers/settings_provider.dart';
import '../core/utils/unit_converter.dart';
import '../models/workout_log_model.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
    }
    return '${duration.inMinutes}m';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(workoutHistoryProvider);
    final weightUnit = ref.watch(settingsProvider).weightUnit;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(workoutHistoryProvider),
          )
        ],
      ),
      body: historyAsync.when(
        data: (logs) {
          if (logs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history_toggle_off,
                    size: 120,
                    color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.2),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'No workouts logged yet.\nHead to the Workouts tab to get started!',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 90, top: 8),
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[index];
              return _buildHistoryCard(context, log, weightUnit);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, WorkoutLog log, String weightUnit) {
    final dateFormat = DateFormat('MMM d, yyyy • h:mm a');
    final completedExercisesCount = log.exercises.where((ex) => ex.sets.any((s) => s.completed)).length;
    
    // Create a preview string of the exercises done
    final exerciseNames = log.exercises
      .where((ex) => ex.sets.any((s) => s.completed))
      .map((e) => e.exerciseName)
      .take(3)
      .toList();
    
    String exercisePreview = exerciseNames.join(', ');
    if (completedExercisesCount > 3) {
      exercisePreview += ', and ${completedExercisesCount - 3} more';
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      color: isDark ? const Color(0xFF121212) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? const Color(0xFF262626) : const Color(0xFFE5E5E5),
          width: 1.0,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          HapticFeedback.lightImpact();
          context.push('/history/detail', extra: log);
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      log.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        dateFormat.format(log.endTime),
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12),
                      ),
                      const SizedBox(width: 6),
                      Icon(Icons.chevron_right_rounded, size: 18, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.timer_outlined, size: 16),
                  const SizedBox(width: 4),
                  Text(_formatDuration(log.duration)),
                  const SizedBox(width: 16),
                  const Icon(Icons.fitness_center_outlined, size: 16),
                  const SizedBox(width: 4),
                  Text('${UnitConverter.toDisplayWeight(log.totalVolume, weightUnit).toStringAsFixed(0)} $weightUnit'),
                  const SizedBox(width: 16),
                  const Icon(Icons.list_alt_outlined, size: 16),
                  const SizedBox(width: 4),
                  Text('$completedExercisesCount exercises'),
                ],
              ),
              const Divider(height: 24),
              Text(
                exercisePreview.isNotEmpty ? exercisePreview : 'No exercises completed.',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
