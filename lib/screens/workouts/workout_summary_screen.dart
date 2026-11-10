import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/workout_log_model.dart';
import '../../models/workout_model.dart';
import '../../core/utils/unit_converter.dart';
import '../../providers/settings_provider.dart';
import '../../providers/active_workout_provider.dart'; // for repo providers
import '../../providers/exercise_provider.dart'; // for mockUserIdProvider

// A local provider to fetch previous performance excluding the current workout
final previousPerformanceExcludingCurrentProvider = FutureProvider.family<Map<int, String>, ({String exerciseId, String currentWorkoutId})>((ref, arg) async {
  final repo = ref.watch(workoutLogRepositoryProvider);
  final userId = ref.watch(mockUserIdProvider);
  final logs = await repo.getLogs(userId);

  // Sort newest first
  logs.sort((a, b) => b.endTime.compareTo(a.endTime));

  // Find the most recent log that contains this exercise, EXCLUDING the current workout
  for (final log in logs) {
    if (log.id == arg.currentWorkoutId) continue;
    
    for (final ex in log.exercises) {
      if (ex.exerciseId == arg.exerciseId) {
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

class WorkoutSummaryScreen extends ConsumerWidget {
  final WorkoutLog log;

  const WorkoutSummaryScreen({super.key, required this.log});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final weightUnit = settings.weightUnit;

    final duration = log.endTime.difference(log.startTime);
    final totalVolume = log.exercises.fold<double>(
      0,
      (sum, ex) =>
          sum +
          ex.sets.where((s) => s.completed).fold(
                0.0,
                (setSum, s) => setSum + (s.weight * s.reps),
              ),
    );
    final totalSets = log.exercises.fold<int>(
      0,
      (sum, ex) => sum + ex.sets.where((s) => s.completed).length,
    );

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Workout Complete',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // High-level Stats
                    _buildStatsRow(context, totalVolume, totalSets, duration, weightUnit),
                    const SizedBox(height: 24),

                    // Heart Rate Graph (if available)
                    if (log.heartRateData != null && log.heartRateData!.isNotEmpty) ...[
                      const Text(
                        'Heart Rate (BPM)',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 200,
                        child: _buildHeartRateChart(context),
                      ),
                      const SizedBox(height: 32),
                    ],

                    // Exercise Comparison
                    const Text(
                      'Performance',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    ...log.exercises.map((ex) {
                      // Only show exercises that had completed sets
                      final completedSets = ex.sets.where((s) => s.completed).toList();
                      if (completedSets.isEmpty) return const SizedBox.shrink();
                      
                      return _buildExerciseComparisonCard(context, ref, ex, weightUnit);
                    }),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            // Finish Button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    context.go('/home');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Finish', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context, double volume, int sets, Duration duration, String weightUnit) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatItem(context, 'Volume', '${UnitConverter.toDisplayWeight(volume, weightUnit).toInt()} $weightUnit'),
        _buildStatItem(context, 'Sets', '$sets'),
        _buildStatItem(context, 'Time', _formatDuration(duration)),
      ],
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.5),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeartRateChart(BuildContext context) {
    final hrData = log.heartRateData!;
    final spots = List.generate(
      hrData.length,
      (index) => FlSpot(index.toDouble(), hrData[index].toDouble()),
    );

    return Container(
      padding: const EdgeInsets.only(right: 16, top: 16, bottom: 12, left: 0),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 20,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.white.withValues(alpha: 0.1),
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
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 10),
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
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 10),
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

  Widget _buildExerciseComparisonCard(BuildContext context, WidgetRef ref, WorkoutExercise ex, String weightUnit) {
    final previousPerfAsync = ref.watch(previousPerformanceExcludingCurrentProvider(
      (exerciseId: ex.exerciseId, currentWorkoutId: log.id),
    ));

    final completedSets = ex.sets.where((s) => s.completed).toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              ex.exerciseName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          
          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.black26,
            child: Row(
              children: [
                const SizedBox(width: 40, child: Text('Set', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w600))),
                const Expanded(child: Text('Previous', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w600))),
                Expanded(child: Text('Current ($weightUnit)', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w600))),
              ],
            ),
          ),

          // Sets
          previousPerfAsync.when(
            data: (previousData) {
              return Column(
                children: completedSets.map((set) {
                  final prevText = previousData[set.setNumber] ?? '-';
                  
                  // Compare to highlight progress (very basic check)
                  bool progressed = false;
                  if (prevText != '-') {
                    final parts = prevText.split(' x ');
                    if (parts.length == 2) {
                      final prevW = double.tryParse(parts[0]) ?? 0;
                      final prevR = int.tryParse(parts[1]) ?? 0;
                      if (set.weight > prevW || (set.weight == prevW && set.reps > prevR)) {
                        progressed = true;
                      }
                    }
                  }

                  final currentDisplayW = UnitConverter.toDisplayWeight(set.weight, weightUnit);

                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: const BoxDecoration(
                      border: Border(top: BorderSide(color: Color(0xFF262626))),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 40, 
                          child: Text('${set.setNumber}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                        Expanded(
                          child: Text(
                            prevText, 
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 14),
                          ),
                        ),
                        Expanded(
                          child: Row(
                            children: [
                              Text(
                                '${currentDisplayW.toInt()} x ${set.reps}', 
                                style: TextStyle(
                                  color: progressed ? const Color(0xFF4CAF50) : Colors.white, 
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              if (progressed) ...[
                                const SizedBox(width: 4),
                                const Icon(Icons.arrow_upward, color: Color(0xFF4CAF50), size: 14),
                              ]
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, __) => const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Error loading previous stats', style: TextStyle(color: Colors.red)),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    if (duration.inHours > 0) {
      return "${duration.inHours}h ${twoDigitMinutes}m";
    }
    return "${twoDigitMinutes}m ${twoDigitSeconds}s";
  }
}
