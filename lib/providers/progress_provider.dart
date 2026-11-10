import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/widgets.dart';
import '../providers/history_provider.dart';
import '../core/constants/default_exercises.dart';
import '../models/exercise_model.dart';

class ProgressStats {
  final int totalWorkouts;
  final double totalVolume;
  final List<FlSpot> volumeChartData;
  final Map<String, int> muscleGroupSets;
  final List<MapEntry<String, double>> topExercisesByVolume;
  
  // New Analytics Fields
  final int averageDurationMinutes;
  final int totalSetsCompleted;
  final int currentStreak;
  final int bestStreak;
  final Map<String, int> workoutDatesHeatmap;
  final List<BarChartGroupData> weeklyVolumeData;
  final Map<String, List<FlSpot>> exerciseStrengthData;
  final List<String> exerciseNames;

  ProgressStats({
    required this.totalWorkouts,
    required this.totalVolume,
    required this.volumeChartData,
    required this.muscleGroupSets,
    required this.topExercisesByVolume,
    required this.averageDurationMinutes,
    required this.totalSetsCompleted,
    required this.currentStreak,
    required this.bestStreak,
    required this.workoutDatesHeatmap,
    required this.weeklyVolumeData,
    required this.exerciseStrengthData,
    required this.exerciseNames,
  });
}

enum ProgressTimeRange {
  allTime('All Time'),
  last30Days('30 Days'),
  last90Days('90 Days');

  final String label;
  const ProgressTimeRange(this.label);
}

final progressTimeRangeProvider = StateProvider<ProgressTimeRange>((ref) => ProgressTimeRange.allTime);
final selectedStrengthExerciseProvider = StateProvider<String?>((ref) => null);

final progressStatsProvider = FutureProvider.autoDispose<ProgressStats>((ref) async {
  final logsAsync = ref.watch(workoutHistoryProvider);
  final timeRange = ref.watch(progressTimeRangeProvider);
  
  return logsAsync.when(
    data: (logs) {
      if (logs.isEmpty) {
        return _emptyStats();
      }

      final now = DateTime.now();
      final filteredLogs = logs.where((log) {
        if (timeRange == ProgressTimeRange.last30Days) {
          return now.difference(log.endTime).inDays <= 30;
        } else if (timeRange == ProgressTimeRange.last90Days) {
          return now.difference(log.endTime).inDays <= 90;
        }
        return true;
      }).toList();

      if (filteredLogs.isEmpty) {
        return _emptyStats();
      }

      // Sort chronological for chart
      final sortedLogs = List.of(filteredLogs)..sort((a, b) => a.endTime.compareTo(b.endTime));

      double totalVolume = 0;
      List<FlSpot> chartData = [];
      Map<String, int> muscleGroupSets = {};
      Map<String, double> exerciseVolume = {};
      
      // New stats vars
      int totalDurationMinutes = 0;
      int totalSetsCompleted = 0;
      Map<String, int> workoutDatesHeatmap = {};
      
      // For Weekly Volume (last 8 weeks)
      // Group by year-week
      Map<String, double> weeklyVolumeMap = {};
      
      // For Strength Progression
      Map<String, List<FlSpot>> exerciseStrengthData = {};
      Map<String, int> exerciseOccurrences = {}; // to calculate X-axis for each exercise

      for (int i = 0; i < sortedLogs.length; i++) {
        final log = sortedLogs[i];
        totalVolume += log.totalVolume;
        chartData.add(FlSpot(i.toDouble(), log.totalVolume));
        
        final duration = log.endTime.difference(log.startTime).inMinutes;
        totalDurationMinutes += (duration > 0 ? duration : 0);
        
        // Heatmap string format YYYY-MM-DD
        final dateStr = "${log.startTime.year}-${log.startTime.month.toString().padLeft(2, '0')}-${log.startTime.day.toString().padLeft(2, '0')}";
        workoutDatesHeatmap[dateStr] = (workoutDatesHeatmap[dateStr] ?? 0) + 1;
        
        // Weekly volume (ISO week approximation)
        // A simple way is to use weeks since epoch or a fixed past date, but year-week string is easier
        // Let's use weeks since epoch for proper sorting
        final weekSinceEpoch = log.startTime.millisecondsSinceEpoch ~/ (1000 * 60 * 60 * 24 * 7);
        weeklyVolumeMap[weekSinceEpoch.toString()] = (weeklyVolumeMap[weekSinceEpoch.toString()] ?? 0) + log.totalVolume;

        for (final ex in log.exercises) {
          final completedSetsList = ex.sets.where((s) => s.completed).toList();
          final completedSetsCount = completedSetsList.length;
          totalSetsCompleted += completedSetsCount;
          if (completedSetsCount == 0) continue;

          // Resolve canonical muscle group by catalog lookup or clean heuristic
          String group = _resolveMuscleGroup(ex.exerciseName, ex.exerciseId);
          muscleGroupSets[group] = (muscleGroupSets[group] ?? 0) + completedSetsCount;

          double exVol = 0;
          double maxWeight = 0;
          for (final s in completedSetsList) {
            exVol += (s.weight * s.reps);
            if (s.weight > maxWeight) maxWeight = s.weight;
          }
          exerciseVolume[ex.exerciseName] = (exerciseVolume[ex.exerciseName] ?? 0) + exVol;
          
          // Strength progression
          if (maxWeight > 0) {
            final exIndex = exerciseOccurrences[ex.exerciseName] ?? 0;
            exerciseOccurrences[ex.exerciseName] = exIndex + 1;
            
            if (!exerciseStrengthData.containsKey(ex.exerciseName)) {
              exerciseStrengthData[ex.exerciseName] = [];
            }
            exerciseStrengthData[ex.exerciseName]!.add(FlSpot(exIndex.toDouble(), maxWeight));
          }
        }
      }

      final topExercises = exerciseVolume.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
        
      // Compute streaks
      int currentStreak = 0;
      int bestStreak = 0;
      if (workoutDatesHeatmap.isNotEmpty) {
        final sortedDates = workoutDatesHeatmap.keys.toList()..sort();
        int tempStreak = 1;
        bestStreak = 1;
        for (int i = 1; i < sortedDates.length; i++) {
          final d1 = DateTime.parse(sortedDates[i-1]);
          final d2 = DateTime.parse(sortedDates[i]);
          if (d2.difference(d1).inDays == 1) {
            tempStreak++;
            if (tempStreak > bestStreak) bestStreak = tempStreak;
          } else {
            tempStreak = 1;
          }
        }
        
        final lastDate = DateTime.parse(sortedDates.last);
        final today = DateTime(now.year, now.month, now.day);
        final diff = today.difference(lastDate).inDays;
        if (diff == 0 || diff == 1) {
          currentStreak = tempStreak;
        }
      }
      
      // Compute weekly volume data (last 8 weeks from data)
      final sortedWeeks = weeklyVolumeMap.keys.map((e) => int.parse(e)).toList()..sort();
      final last8Weeks = sortedWeeks.reversed.take(8).toList().reversed.toList();
      List<BarChartGroupData> weeklyVolumeBarData = [];
      for (int i = 0; i < last8Weeks.length; i++) {
        final val = weeklyVolumeMap[last8Weeks[i].toString()] ?? 0;
        weeklyVolumeBarData.add(
          BarChartGroupData(
            x: i,
            barRods: [BarChartRodData(toY: val, width: 16, borderRadius: BorderRadius.circular(4))],
          )
        );
      }
      
      final averageDuration = totalDurationMinutes ~/ (filteredLogs.isNotEmpty ? filteredLogs.length : 1);
      
      final exerciseNames = exerciseStrengthData.keys.toList()..sort();

      return ProgressStats(
        totalWorkouts: filteredLogs.length,
        totalVolume: totalVolume,
        volumeChartData: chartData,
        muscleGroupSets: muscleGroupSets,
        topExercisesByVolume: topExercises.take(5).toList(),
        averageDurationMinutes: averageDuration,
        totalSetsCompleted: totalSetsCompleted,
        currentStreak: currentStreak,
        bestStreak: bestStreak,
        workoutDatesHeatmap: workoutDatesHeatmap,
        weeklyVolumeData: weeklyVolumeBarData,
        exerciseStrengthData: exerciseStrengthData,
        exerciseNames: exerciseNames,
      );
    },
    loading: () => _emptyStats(),
    error: (e, st) => _emptyStats(),
  );
});

ProgressStats _emptyStats() {
  return ProgressStats(
    totalWorkouts: 0, 
    totalVolume: 0, 
    volumeChartData: [], 
    muscleGroupSets: {}, 
    topExercisesByVolume: [],
    averageDurationMinutes: 0,
    totalSetsCompleted: 0,
    currentStreak: 0,
    bestStreak: 0,
    workoutDatesHeatmap: {},
    weeklyVolumeData: [],
    exerciseStrengthData: {},
    exerciseNames: [],
  );
}

String _resolveMuscleGroup(String exerciseName, String exerciseId) {
  // 1. Check exact match by exerciseId or name in DefaultExercises.list
  final matched = DefaultExercises.list.firstWhere(
    (e) => (exerciseId.isNotEmpty && e.id == exerciseId) || e.name.toLowerCase() == exerciseName.toLowerCase(),
    orElse: () => Exercise(id: '', name: '', muscleGroup: '', equipment: ''),
  );
  if (matched.muscleGroup.isNotEmpty) {
    return _toHighLevelGroup(matched.muscleGroup);
  }

  // 2. Intelligent heuristics for custom exercises
  final lower = exerciseName.toLowerCase();
  if (lower.contains('shoulder') || lower.contains('delt') || lower.contains('military') || lower.contains('overhead') || lower.contains('lateral raise') || lower.contains('arnold')) {
    return 'Shoulders';
  }
  if (lower.contains('bench') || lower.contains('chest') || lower.contains('fly') || lower.contains('push up') || lower.contains('pec')) {
    return 'Chest';
  }
  if (lower.contains('squat') || lower.contains('leg press') || lower.contains('leg ext') || lower.contains('lunge') || lower.contains('hack') || lower.contains('sissy')) {
    return 'Legs';
  }
  if (lower.contains('deadlift') || lower.contains('rdl') || lower.contains('hamstring') || lower.contains('leg curl') || lower.contains('hip thrust') || lower.contains('glute') || lower.contains('calf') || lower.contains('calves')) {
    return 'Legs';
  }
  if (lower.contains('row') || lower.contains('pull up') || lower.contains('chin up') || lower.contains('lat') || lower.contains('pulldown') || lower.contains('shrug') || lower.contains('back')) {
    return 'Back';
  }
  if (lower.contains('curl') || lower.contains('bicep')) {
    return 'Arms';
  }
  if (lower.contains('tricep') || lower.contains('pushdown') || lower.contains('skull') || lower.contains('dip') || lower.contains('kickback')) {
    return 'Arms';
  }
  if (lower.contains('core') || lower.contains('crunch') || lower.contains('plank') || lower.contains('abs') || lower.contains('leg raise')) {
    return 'Core';
  }
  if (lower.contains('run') || lower.contains('treadmill') || lower.contains('bike') || lower.contains('cycle') || lower.contains('rower') || lower.contains('jump rope') || lower.contains('burpee')) {
    return 'Cardio';
  }
  return 'Other';
}

String _toHighLevelGroup(String specificGroup) {
  switch (specificGroup.toLowerCase()) {
    case 'biceps':
    case 'triceps':
    case 'forearms':
    case 'arms':
      return 'Arms';
    case 'quads':
    case 'hamstrings':
    case 'glutes':
    case 'calves':
    case 'legs':
      return 'Legs';
    case 'chest':
      return 'Chest';
    case 'back':
      return 'Back';
    case 'shoulders':
      return 'Shoulders';
    case 'core':
      return 'Core';
    case 'cardio':
      return 'Cardio';
    default:
      return 'Other';
  }
}
