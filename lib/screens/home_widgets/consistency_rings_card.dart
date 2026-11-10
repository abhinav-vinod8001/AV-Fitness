import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/goals_provider.dart';
import '../../providers/history_provider.dart';
import '../../providers/settings_provider.dart';
import '../../core/utils/unit_converter.dart';

class ConsistencyRingsCard extends ConsumerWidget {
  const ConsistencyRingsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals = ref.watch(weeklyGoalsProvider);
    final historyAsync = ref.watch(workoutHistoryProvider);
    final weightUnit = ref.watch(settingsProvider).weightUnit;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return historyAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => const SizedBox.shrink(),
      data: (logs) {
        // Calculate this week's progress
        final now = DateTime.now();
        // Assuming week starts on Monday
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final startOfWeekMidnight = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);

        final thisWeekLogs = logs.where((l) => l.startTime.isAfter(startOfWeekMidnight)).toList();

        final workoutsCompleted = thisWeekLogs.length;
        final double volumeCompleted = thisWeekLogs.fold(0.0, (sum, log) => sum + log.totalVolume);
        final int minutesCompleted = thisWeekLogs.fold(0, (sum, log) => sum + log.duration.inMinutes);

        final p1 = (workoutsCompleted / goals.targetWorkoutsPerWeek).clamp(0.0, 1.0);
        final p2 = (volumeCompleted / goals.targetVolumeKg).clamp(0.0, 1.0);
        final p3 = (minutesCompleted / goals.targetActiveMinutes).clamp(0.0, 1.0);

        final color1 = const Color(0xFFFFB300); // Amber (Workouts)
        final color2 = const Color(0xFF8E24AA); // Purple (Volume)
        final color3 = const Color(0xFF00ACC1); // Teal (Active)

        return GestureDetector(
          onTap: () {
            // Expand to show goals editor
            _showGoalsSheet(context, ref, goals);
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF161616) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: isDark ? const Color(0xFF262626) : const Color(0xFFE5E5E5)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 90,
                  height: 70,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildVerticalBar(p1, color1),
                      _buildVerticalBar(p2, color2),
                      _buildVerticalBar(p3, color3),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLegendItem(color1, 'Workouts', '$workoutsCompleted / ${goals.targetWorkoutsPerWeek}'),
                      const SizedBox(height: 8),
                      _buildLegendItem(color2, 'Volume', '${(UnitConverter.toDisplayWeight(volumeCompleted, weightUnit) / 1000).toStringAsFixed(1)}k / ${(UnitConverter.toDisplayWeight(goals.targetVolumeKg, weightUnit) / 1000).toStringAsFixed(0)}k $weightUnit'),
                      const SizedBox(height: 8),
                      _buildLegendItem(color3, 'Active', '$minutesCompleted / ${goals.targetActiveMinutes} m'),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildVerticalBar(double progress, Color color) {
    return Container(
      width: 22,
      height: double.infinity,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.bottomCenter,
      child: FractionallySizedBox(
        heightFactor: progress,
        widthFactor: 1.0,
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label, String value) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
        Text(value, style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }

  void _showGoalsSheet(BuildContext context, WidgetRef ref, WeeklyGoalsState goals) {
    int w = goals.targetWorkoutsPerWeek;
    double v = goals.targetVolumeKg;
    int m = goals.targetActiveMinutes;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          final cs = Theme.of(context).colorScheme;
          return Container(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 24, top: 24, left: 24, right: 24),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Set Weekly Goals', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                _buildGoalSlider(
                  label: 'Workouts per Week',
                  value: w.toDouble(),
                  min: 1, max: 7, divisions: 6,
                  color: const Color(0xFFFFB300),
                  onChanged: (val) => setSheetState(() => w = val.toInt()),
                  displayValue: '$w',
                ),
                _buildGoalSlider(
                  label: 'Target Volume (kg)',
                  value: v,
                  min: 1000, max: 50000, divisions: 49,
                  color: const Color(0xFF8E24AA),
                  onChanged: (val) => setSheetState(() => v = val),
                  displayValue: '${(v / 1000).toStringAsFixed(1)}k kg',
                ),
                _buildGoalSlider(
                  label: 'Active Minutes',
                  value: m.toDouble(),
                  min: 30, max: 600, divisions: 19,
                  color: const Color(0xFF00ACC1),
                  onChanged: (val) => setSheetState(() => m = val.toInt()),
                  displayValue: '$m min',
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () {
                      ref.read(weeklyGoalsProvider.notifier).updateGoals(workouts: w, volume: v, minutes: m);
                      Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cs.primary,
                      foregroundColor: cs.onPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Save Goals', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                )
              ],
            ),
          );
        }
      )
    );
  }

  Widget _buildGoalSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required Color color,
    required ValueChanged<double> onChanged,
    required String displayValue,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            Text(displayValue, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: color,
            inactiveTrackColor: color.withOpacity(0.2),
            thumbColor: color,
            overlayColor: color.withOpacity(0.1),
            trackHeight: 6,
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
