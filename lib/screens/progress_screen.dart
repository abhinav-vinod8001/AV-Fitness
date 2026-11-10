import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/progress_provider.dart';
import '../providers/settings_provider.dart';
import '../core/utils/unit_converter.dart';
import '../core/constants/default_exercises.dart';
import '../models/exercise_model.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(progressStatsProvider);
    final currentTimeRange = ref.watch(progressTimeRangeProvider);
    final weightUnit = ref.watch(settingsProvider).weightUnit;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
      ),
      body: statsAsync.when(
        data: (stats) {
          return SingleChildScrollView(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 100.0, top: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Time Range Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ProgressTimeRange.values.map((tr) {
                      final isSelected = currentTimeRange == tr;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0, bottom: 16.0),
                        child: ChoiceChip(
                          label: Text(tr.label),
                          selected: isSelected,
                          onSelected: (val) {
                            if (val) {
                              HapticFeedback.selectionClick();
                              ref.read(progressTimeRangeProvider.notifier).state = tr;
                            }
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),

                if (stats.totalWorkouts == 0)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 48.0),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.query_stats_rounded, size: 80, color: cs.onSurfaceVariant.withValues(alpha: 0.5)),
                          const SizedBox(height: 16),
                          const Text('No data for this period', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text('Try selecting "All Time" or complete workouts to see your stats.', 
                            textAlign: TextAlign.center,
                            style: TextStyle(color: cs.onSurfaceVariant)),
                        ],
                      ),
                    ),
                  )
                else ...[
                  // Highlight Cards Row 1
                  Row(
                    children: [
                      Expanded(child: _buildHighlightCard(context, 'Workouts', '${stats.totalWorkouts}', Icons.fitness_center_rounded, Colors.teal)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildHighlightCard(context, 'Volume ($weightUnit)', '${(UnitConverter.toDisplayWeight(stats.totalVolume, weightUnit) / 1000).toStringAsFixed(1)}k', Icons.monitor_weight_outlined, Colors.indigoAccent)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Highlight Cards Row 2
                  Row(
                    children: [
                      Expanded(child: _buildHighlightCard(context, 'Avg Duration', '${stats.averageDurationMinutes} min', Icons.timer_outlined, Colors.orange)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildHighlightCard(context, 'Total Sets', '${stats.totalSetsCompleted}', Icons.repeat, Colors.blue)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Highlight Cards Row 3
                  Row(
                    children: [
                      Expanded(child: _buildHighlightCard(context, 'Current Streak', '${stats.currentStreak} days', Icons.local_fire_department, Colors.redAccent)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildHighlightCard(context, 'Best Streak', '${stats.bestStreak} days', Icons.emoji_events_outlined, Colors.amber)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Heatmap
                  Text('Workout Frequency', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: cs.onSurface)),
                  const SizedBox(height: 12),
                  _buildGlassCard(
                    context,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: _buildHeatmap(context, stats.workoutDatesHeatmap),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Weekly Volume Chart
                  Text('Weekly Volume ($weightUnit)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: cs.onSurface)),
                  const SizedBox(height: 12),
                  _buildGlassCard(
                    context,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: _buildBarChart(context, stats.weeklyVolumeData.map((group) {
                        return group.copyWith(
                          barRods: group.barRods.map((rod) => rod.copyWith(toY: UnitConverter.toDisplayWeight(rod.toY, weightUnit))).toList(),
                        );
                      }).toList()),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Strength Progression
                  Text('Strength Progression', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: cs.onSurface)),
                  const SizedBox(height: 12),
                  _buildGlassCard(
                    context,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: _buildStrengthProgression(context, stats, ref),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Volume Chart
                  Text('Volume Progression ($weightUnit)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: cs.onSurface)),
                  const SizedBox(height: 12),
                  _buildGlassCard(
                    context,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: _buildLineChart(context, stats.volumeChartData.map((spot) => FlSpot(spot.x, UnitConverter.toDisplayWeight(spot.y, weightUnit))).toList()),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Muscle Group Distribution
                  Text('Muscle Group Distribution', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: cs.onSurface)),
                  const SizedBox(height: 12),
                  _buildGlassCard(
                    context,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: _buildPieChart(context, stats.muscleGroupSets),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Top Exercises
                  Text('Top Exercises (by volume)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: cs.onSurface)),
                  const SizedBox(height: 12),
                  _buildGlassCard(
                    context,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: stats.topExercisesByVolume.isEmpty
                            ? [const Padding(padding: EdgeInsets.all(16.0), child: Text('No data'))]
                            : stats.topExercisesByVolume.map((e) {
                                final ex = DefaultExercises.list.firstWhere(
                                  (item) => item.name.toLowerCase() == e.key.toLowerCase(),
                                  orElse: () => Exercise(
                                    id: e.key,
                                    name: e.key,
                                    muscleGroup: 'Full Body',
                                    equipment: 'Gym',
                                    isCustom: true,
                                  ),
                                );

                                return ListTile(
                                  onTap: () {
                                    HapticFeedback.lightImpact();
                                    context.push('/exercises/details', extra: ex);
                                  },
                                  leading: CircleAvatar(
                                    backgroundColor: cs.primaryContainer,
                                    child: Icon(Icons.fitness_center, color: cs.onPrimaryContainer, size: 18),
                                  ),
                                  title: Text(e.key, style: const TextStyle(fontWeight: FontWeight.w600)),
                                  subtitle: Text(ex.muscleGroup, style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text('${UnitConverter.toDisplayWeight(e.value, weightUnit).toInt()} $weightUnit', style: TextStyle(color: cs.onSurfaceVariant, fontWeight: FontWeight.bold)),
                                      const SizedBox(width: 4),
                                      Icon(Icons.chevron_right_rounded, size: 18, color: cs.onSurfaceVariant),
                                    ],
                                  ),
                                );
                              }).toList(),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildHighlightCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return _buildGlassCard(
      context,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
            Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(title, style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassCard(BuildContext context, {required Widget child}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF121212) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF262626) : const Color(0xFFE5E5E5),
          width: 1.0,
        ),
      ),
      child: child,
    );
  }

  Widget _buildLineChart(BuildContext context, List<FlSpot> data) {
    if (data.length < 2) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('Not enough data (needs 2+ workouts).', style: TextStyle(fontWeight: FontWeight.w600))),
      );
    }
    
    final maxY = data.map((e) => e.y).reduce((a, b) => a > b ? a : b);
    
    return SizedBox(
      height: 220,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: (data.length - 1).toDouble(),
          minY: 0,
          maxY: maxY * 1.2,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: (maxY / 4) == 0 ? 1 : maxY / 4,
            getDrawingHorizontalLine: (value) => FlLine(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1), strokeWidth: 1),
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 22,
                interval: 1,
                getTitlesWidget: (val, meta) => Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text('#${val.toInt() + 1}', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 10)),
                ),
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 44,
                getTitlesWidget: (val, meta) => Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Text('${(val / 1000).toStringAsFixed(0)}k', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 10)),
                ),
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: data,
              isCurved: true,
              curveSmoothness: 0.35,
              color: Theme.of(context).colorScheme.primary,
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: FlDotData(show: true, getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(radius: 4, color: Theme.of(context).colorScheme.primary, strokeWidth: 2, strokeColor: Theme.of(context).scaffoldBackgroundColor)),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                    Theme.of(context).colorScheme.primary.withValues(alpha: 0.01),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart(BuildContext context, List<BarChartGroupData> data) {
    if (data.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('Not enough data.', style: TextStyle(fontWeight: FontWeight.w600))),
      );
    }
    
    double maxY = 0;
    for (var group in data) {
      for (var rod in group.barRods) {
        if (rod.toY > maxY) maxY = rod.toY;
      }
    }
    
    return SizedBox(
      height: 220,
      child: BarChart(
        BarChartData(
          minY: 0,
          maxY: maxY * 1.2,
          barGroups: data,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: (maxY / 4) == 0 ? 1 : maxY / 4,
            getDrawingHorizontalLine: (value) => FlLine(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1), strokeWidth: 1),
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 22,
                interval: 1,
                getTitlesWidget: (val, meta) => Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text('Wk ${val.toInt() + 1}', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 10)),
                ),
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 44,
                getTitlesWidget: (val, meta) => Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Text('${(val / 1000).toStringAsFixed(0)}k', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 10)),
                ),
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }
  
  Widget _buildHeatmap(BuildContext context, Map<String, int> heatmapData) {
    final today = DateTime.now();
    // Show approx last 90 days (13 weeks)
    final startDate = today.subtract(const Duration(days: 90));
    final days = today.difference(startDate).inDays + 1;
    
    final cs = Theme.of(context).colorScheme;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate((days / 7).ceil(), (colIndex) {
              return Column(
                children: List.generate(7, (rowIndex) {
                  final dayOffset = (colIndex * 7) + rowIndex;
                  if (dayOffset >= days) return const SizedBox(width: 16, height: 16);
                  
                  final date = startDate.add(Duration(days: dayOffset));
                  final dateStr = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
                  final count = heatmapData[dateStr] ?? 0;
                  
                  Color color = cs.surfaceContainerHighest;
                  if (count == 1) color = cs.primary.withValues(alpha: 0.4);
                  if (count == 2) color = cs.primary.withValues(alpha: 0.7);
                  if (count > 2) color = cs.primary;
                  
                  return Container(
                    width: 14,
                    height: 14,
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              );
            }),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text('Less', style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
            const SizedBox(width: 4),
            Container(width: 10, height: 10, decoration: BoxDecoration(color: cs.surfaceContainerHighest, borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 2),
            Container(width: 10, height: 10, decoration: BoxDecoration(color: cs.primary.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 2),
            Container(width: 10, height: 10, decoration: BoxDecoration(color: cs.primary.withValues(alpha: 0.7), borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 2),
            Container(width: 10, height: 10, decoration: BoxDecoration(color: cs.primary, borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 4),
            Text('More', style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
          ],
        )
      ],
    );
  }
  
  Widget _buildStrengthProgression(BuildContext context, ProgressStats stats, WidgetRef ref) {
    if (stats.exerciseNames.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('No strength data available.', style: TextStyle(fontWeight: FontWeight.w600))),
      );
    }
    
    final selectedExercise = ref.watch(selectedStrengthExerciseProvider) ?? stats.exerciseNames.first;
    final chartData = stats.exerciseStrengthData[selectedExercise] ?? [];
    
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButton<String>(
            value: selectedExercise,
            isExpanded: true,
            underline: const SizedBox(),
            items: stats.exerciseNames.map((name) {
              return DropdownMenuItem(value: name, child: Text(name));
            }).toList(),
            onChanged: (val) {
              if (val != null) {
                ref.read(selectedStrengthExerciseProvider.notifier).state = val;
              }
            },
          ),
        ),
        const SizedBox(height: 16),
        _buildLineChart(context, chartData),
      ],
    );
  }

  Widget _buildPieChart(BuildContext context, Map<String, int> muscleData) {
    if (muscleData.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('No muscle group data.', style: TextStyle(fontWeight: FontWeight.w600))),
      );
    }

    final colors = [
      Colors.blueAccent, Colors.redAccent, Colors.greenAccent,
      Colors.orangeAccent, Colors.purpleAccent, Colors.cyan, Colors.teal
    ];

    int totalSets = muscleData.values.fold(0, (a, b) => a + b);
    int colorIdx = 0;

    final sections = muscleData.entries.map((entry) {
      final val = (entry.value / totalSets) * 100;
      final color = colors[colorIdx % colors.length];
      colorIdx++;
      return PieChartSectionData(
        color: color,
        value: val,
        title: '${val.toInt()}%',
        radius: 50,
        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();

    return Row(
      children: [
        SizedBox(
          width: 140,
          height: 140,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 30,
              sections: sections,
            ),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: (() {
              int idx = 0;
              return muscleData.entries.map((entry) {
                final color = colors[idx % colors.length];
                idx++;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6.0),
                  child: Row(
                    children: [
                      Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                      const SizedBox(width: 8),
                      Expanded(child: Text(entry.key, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                      Text('${entry.value} sets', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                    ],
                  ),
                );
              }).toList();
            })(),
          ),
        ),
      ],
    );
  }
}
