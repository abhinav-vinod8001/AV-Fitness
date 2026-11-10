import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../models/workout_log_model.dart';
import '../../models/workout_model.dart';
import '../../models/exercise_model.dart';
import '../../providers/active_workout_provider.dart';
import '../../providers/workout_provider.dart';
import '../../providers/history_provider.dart';
import '../../providers/settings_provider.dart';
import '../../core/utils/unit_converter.dart';
import '../../providers/exercise_provider.dart';
import '../../widgets/exercise_visual_card.dart';
import '../../widgets/exercise_preview_modal.dart';
import '../../core/constants/default_exercises.dart';
import '../../core/utils/app_animations.dart';
import 'package:fl_chart/fl_chart.dart';

class WorkoutDetailScreen extends ConsumerWidget {
  final WorkoutLog log;

  const WorkoutDetailScreen({super.key, required this.log});

  String _formatDuration(Duration duration) {
    int hours = duration.inHours;
    int minutes = duration.inMinutes.remainder(60);
    int seconds = duration.inSeconds.remainder(60);
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  int _calculateCalories(int durationMinutes, double volumeKg) {
    if (durationMinutes <= 0 && volumeKg <= 0) return 0;
    final cal = (durationMinutes * 6.5) + (volumeKg * 0.012);
    return cal > 0 ? cal.round() : durationMinutes * 6;
  }

  void _shareSummary(BuildContext context, String unit) {
    HapticFeedback.lightImpact();
    final dateFormatted = DateFormat('EEE, MMM d, yyyy').format(log.endTime);
    final completedSets = log.exercises.fold<int>(
      0,
      (prev, ex) => prev + ex.sets.where((s) => s.completed).length,
    );
    final totalVolume = UnitConverter.toDisplayWeight(log.totalVolume, unit);

    final sb = StringBuffer();
    sb.writeln('🏋️ ${log.name}');
    sb.writeln('📅 $dateFormatted • ${_formatDuration(log.duration)}');
    sb.writeln('💪 ${totalVolume.toInt()} $unit volume • $completedSets sets');
    sb.writeln('');
    for (final ex in log.exercises) {
      final validSets = ex.sets.where((s) => s.completed).toList();
      if (validSets.isEmpty) continue;
      sb.writeln('• ${ex.exerciseName}: ${validSets.length} sets');
      for (int i = 0; i < validSets.length; i++) {
        final s = validSets[i];
        final displayWeight = UnitConverter.toDisplayWeight(s.weight, unit);
        sb.writeln('   Set ${i + 1}: ${displayWeight.toStringAsFixed(displayWeight.truncateToDouble() == displayWeight ? 0 : 1)} $unit × ${s.reps} reps');
      }
    }
    sb.writeln('\nLogged with AV Fitness');

    Clipboard.setData(ClipboardData(text: sb.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Workout summary copied to clipboard!')),
    );
  }

  Future<void> _repeatWorkout(BuildContext context, WidgetRef ref) async {
    HapticFeedback.mediumImpact();
    // Convert the workout log exercises into a template
    final template = WorkoutTemplate(
      id: const Uuid().v4(),
      name: log.name,
      exercises: log.exercises.map((ex) {
        return WorkoutExercise(
          id: const Uuid().v4(),
          exerciseId: ex.exerciseId,
          exerciseName: ex.exerciseName,
          sets: ex.sets.map((s) => WorkoutSet(
            id: const Uuid().v4(),
            setNumber: s.setNumber,
            weight: s.weight,
            reps: s.reps,
            isWarmup: s.isWarmup,
            rpe: s.rpe,
            completed: false,
          )).toList(),
        );
      }).toList(),
    );

    ref.read(activeWorkoutProvider.notifier).startWorkout(template);
    context.push('/workouts/active');
  }

  Future<void> _saveAsRoutine(BuildContext context, WidgetRef ref) async {
    HapticFeedback.lightImpact();
    final nameController = TextEditingController(text: log.name);
    final confirmed = await AppAnimations.showAnimatedDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Save as Routine Template'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Give your new routine template a name:'),
            const SizedBox(height: 12),
            TextField(
              controller: nameController,
              autofocus: true,
              decoration: const InputDecoration(hintText: 'Routine Name'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Save Routine'),
          ),
        ],
      ),
    );

    if (confirmed == true && nameController.text.trim().isNotEmpty) {
      final userId = ref.read(mockUserIdProvider);
      final template = WorkoutTemplate(
        id: const Uuid().v4(),
        name: nameController.text.trim(),
        userId: userId,
        exercises: log.exercises.map((ex) {
          return WorkoutExercise(
            id: const Uuid().v4(),
            exerciseId: ex.exerciseId,
            exerciseName: ex.exerciseName,
            sets: ex.sets.map((s) => WorkoutSet(
              id: const Uuid().v4(),
              setNumber: s.setNumber,
              weight: s.weight,
              reps: s.reps,
              isWarmup: s.isWarmup,
              rpe: s.rpe,
              completed: false,
            )).toList(),
          );
        }).toList(),
      );

      await ref.read(workoutRepositoryProvider).saveTemplate(template);
      ref.invalidate(workoutTemplatesProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Routine "${template.name}" saved!')),
        );
      }
    }
  }

  Future<void> _deleteWorkout(BuildContext context, WidgetRef ref) async {
    HapticFeedback.mediumImpact();
    final confirmed = await AppAnimations.showAnimatedDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Workout?'),
        content: Text('Are you sure you want to delete "${log.name}"? This action cannot be undone and stats will be updated.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final repo = ref.read(workoutLogRepositoryProvider);
      await repo.deleteLog(log.id);
      ref.invalidate(workoutHistoryProvider);
      if (context.mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Workout deleted')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final weightUnit = ref.watch(settingsProvider).weightUnit;

    final completedSets = log.exercises.fold<int>(
      0,
      (prev, ex) => prev + ex.sets.where((s) => s.completed).length,
    );
    final totalVolume = UnitConverter.toDisplayWeight(log.totalVolume, weightUnit);
    final calories = _calculateCalories(log.duration.inMinutes, log.totalVolume);

    return Scaffold(
      appBar: AppBar(
        title: Text(log.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Share Summary',
            onPressed: () => _shareSummary(context, weightUnit),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
            onSelected: (val) {
              if (val == 'repeat') {
                _repeatWorkout(context, ref);
              } else if (val == 'save_routine') {
                _saveAsRoutine(context, ref);
              } else if (val == 'delete') {
                _deleteWorkout(context, ref);
              }
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                value: 'repeat',
                child: Row(
                  children: [
                    Icon(Icons.replay_rounded, size: 18),
                    SizedBox(width: 8),
                    Text('Perform Again'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'save_routine',
                child: Row(
                  children: [
                    Icon(Icons.bookmark_add_outlined, size: 18),
                    SizedBox(width: 8),
                    Text('Save as Routine'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                    SizedBox(width: 8),
                    Text('Delete Workout', style: TextStyle(color: Colors.redAccent)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
        children: [
          // ── Date & Time Info Banner ───────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF121212) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? const Color(0xFF262626) : const Color(0xFFE5E5E5),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today_rounded, size: 16, color: cs.primary),
                const SizedBox(width: 10),
                Text(
                  DateFormat('EEEE, MMM d, yyyy • h:mm a').format(log.endTime),
                  style: TextStyle(fontWeight: FontWeight.w600, color: cs.onSurfaceVariant, fontSize: 13),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Key Metrics Cards Row ─────────────────────
          Row(
            children: [
              _buildMetricCard(context, Icons.timer_outlined, 'Time', _formatDuration(log.duration), cs.primary),
              const SizedBox(width: 8),
              _buildMetricCard(context, Icons.fitness_center_outlined, 'Volume', '${totalVolume.toInt()} $weightUnit', Colors.blueAccent),
              const SizedBox(width: 8),
              _buildMetricCard(context, Icons.check_circle_outline, 'Sets', '$completedSets', Colors.teal),
              const SizedBox(width: 8),
              _buildMetricCard(context, Icons.local_fire_department_outlined, 'Calories', '$calories kcal', Colors.deepOrangeAccent),
            ],
          ),

          const SizedBox(height: 20),

          // ── Heart Rate Graph ──────────────────────────
          if (log.heartRateData != null && log.heartRateData!.isNotEmpty) ...[
            Text(
              'HEART RATE (BPM)',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 180,
              child: _buildHeartRateChart(context),
            ),
            const SizedBox(height: 24),
          ],

          // ── Primary Action Buttons ────────────────────
          Row(
            children: [
              Expanded(
                flex: 3,
                child: ElevatedButton.icon(
                  onPressed: () => _repeatWorkout(context, ref),
                  icon: const Icon(Icons.play_arrow_rounded, size: 22),
                  label: const Text('Perform Again', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cs.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: OutlinedButton.icon(
                  onPressed: () => _saveAsRoutine(context, ref),
                  icon: const Icon(Icons.bookmark_add_outlined, size: 18),
                  label: const Text('Save Routine', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.6)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ── Exercises Header ──────────────────────────
          Text(
            'EXERCISES PERFORMED (${log.exercises.length})',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),

          // ── Exercise Breakdown Cards ──────────────────
          if (log.exercises.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              alignment: Alignment.center,
              child: Text('No exercises recorded for this session.', style: TextStyle(color: cs.onSurfaceVariant)),
            )
          else
            ...log.exercises.map((ex) => _buildExerciseCard(context, ex, weightUnit, isDark, cs)),

          const SizedBox(height: 20),

          // ── Delete Workout Button ─────────────────────
          Center(
            child: TextButton.icon(
              onPressed: () => _deleteWorkout(context, ref),
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
              label: const Text('Delete this workout log', style: TextStyle(color: Colors.redAccent, fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(BuildContext context, IconData icon, String label, String value, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF121212) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? const Color(0xFF262626) : const Color(0xFFE5E5E5),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseCard(
    BuildContext context,
    WorkoutExercise ex,
    String weightUnit,
    bool isDark,
    ColorScheme cs,
  ) {
    // Find exercise details for thumbnail / preview modal
    final fullExercise = DefaultExercises.list.firstWhere(
      (item) => item.id == ex.exerciseId || item.name.toLowerCase() == ex.exerciseName.toLowerCase(),
      orElse: () => Exercise(
        id: ex.exerciseId,
        name: ex.exerciseName,
        muscleGroup: 'Full Body',
        equipment: 'Gym',
        isCustom: true,
      ),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF121212) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF262626) : const Color(0xFFE5E5E5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with clickable thumbnail
          InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              ExercisePreviewModal.show(context, exercise: fullExercise);
            },
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Row(
                children: [
                  ExerciseVisualCard(
                    exercise: fullExercise,
                    width: 44,
                    height: 44,
                    borderRadius: 10,
                    showLabels: false,
                    isHero: false,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ex.exerciseName,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${fullExercise.muscleGroup} • ${fullExercise.equipment}',
                          style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.info_outline_rounded, size: 20, color: cs.onSurfaceVariant.withValues(alpha: 0.7)),
                ],
              ),
            ),
          ),

          const Divider(height: 1),

          // Sets Table Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 36,
                  child: Text('SET', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: cs.onSurfaceVariant)),
                ),
                Expanded(
                  flex: 2,
                  child: Text('TYPE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: cs.onSurfaceVariant)),
                ),
                Expanded(
                  flex: 3,
                  child: Text('LOAD', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: cs.onSurfaceVariant)),
                ),
                Expanded(
                  flex: 2,
                  child: Text('EST 1RM', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: cs.onSurfaceVariant)),
                ),
                const SizedBox(width: 28),
              ],
            ),
          ),

          // Sets Rows
          ...ex.sets.asMap().entries.map((entry) {
            final idx = entry.key;
            final s = entry.value;
            final est1RM = s.weight * (1 + (s.reps / 30));
            final displayWeight = UnitConverter.toDisplayWeight(s.weight, weightUnit);
            final display1RM = UnitConverter.toDisplayWeight(est1RM, weightUnit);

            return Container(
              color: idx.isEven
                  ? Colors.transparent
                  : (isDark ? Colors.white.withValues(alpha: 0.02) : Colors.black.withValues(alpha: 0.015)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  SizedBox(
                    width: 36,
                    child: Text(
                      '${idx + 1}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: _buildSetTypeBadge(s.isWarmup, cs),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      '${displayWeight.toStringAsFixed(displayWeight.truncateToDouble() == displayWeight ? 0 : 1)} $weightUnit × ${s.reps}',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      display1RM > 0 ? '${display1RM.toStringAsFixed(1)} $weightUnit' : '-',
                      style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                    ),
                  ),
                  Icon(
                    s.completed ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                    size: 18,
                    color: s.completed ? Colors.green : cs.onSurfaceVariant.withValues(alpha: 0.4),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 6),
        ],
      ),
    );
  }

  Widget _buildSetTypeBadge(bool isWarmup, ColorScheme cs) {
    final bg = isWarmup ? Colors.amber.withValues(alpha: 0.2) : cs.surfaceContainerHighest;
    final fg = isWarmup ? Colors.amber.shade700 : cs.onSurfaceVariant;
    final label = isWarmup ? 'Warmup' : 'Normal';

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(color: fg, fontSize: 10, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildHeartRateChart(BuildContext context) {
    final hrData = log.heartRateData!;
    final spots = List.generate(
      hrData.length,
      (index) => FlSpot(index.toDouble(), hrData[index].toDouble()),
    );

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.only(right: 16, top: 16, bottom: 12, left: 0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF121212) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF262626) : const Color(0xFFE5E5E5),
        ),
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 20,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1),
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 22,
                interval: 10,
                getTitlesWidget: (value, meta) {
                  if (value % 10 != 0 || value == hrData.length.toDouble()) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      '${value.toInt()}m',
                      style: TextStyle(
                        color: isDark ? Colors.white.withValues(alpha: 0.5) : Colors.black.withValues(alpha: 0.5), 
                        fontSize: 10,
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 20,
                reservedSize: 32,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: TextStyle(
                      color: isDark ? Colors.white.withValues(alpha: 0.5) : Colors.black.withValues(alpha: 0.5), 
                      fontSize: 10,
                    ),
                    textAlign: TextAlign.right,
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: hrData.length.toDouble() - 1,
          minY: 60,
          maxY: 180,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: const Color(0xFFFF5722), // HR Accent
              barWidth: 2,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: const Color(0xFFFF5722).withValues(alpha: 0.2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
