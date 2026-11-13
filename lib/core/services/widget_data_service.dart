import 'package:home_widget/home_widget.dart';
import 'package:flutter/foundation.dart';
import '../../models/workout_log_model.dart';

/// Writes workout summary stats to SharedPreferences so native Android
/// home screen widgets of all sizes (1x1, 2x1, 4x1, 2x2, 4x2, 3x3) can display them.
class WidgetDataService {
  static const String _appGroupId = 'com.irontrack.irontrack';

  /// Call this whenever workout history is loaded or updated.
  static Future<void> updateWidgetData(List<WorkoutLog> logs) async {
    try {
      HomeWidget.setAppGroupId(_appGroupId);
      if (logs.isEmpty) {
        await _writeDefaults();
        await _requestWidgetUpdate();
        return;
      }

      // Sort newest first
      final sorted = List.of(logs)..sort((a, b) => b.endTime.compareTo(a.endTime));
      final now = DateTime.now();

      // --- Streak ---
      final streak = _calculateStreak(sorted, now);

      // --- Weekly Stats ---
      final startOfWeek = now.subtract(Duration(days: now.weekday % 7));
      final weekStart = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
      final weekLogs = sorted.where((log) => log.startTime.isAfter(weekStart)).toList();

      double weeklyVolume = 0;
      int weeklyWorkouts = weekLogs.length;
      int weeklySets = 0;

      for (final log in weekLogs) {
        weeklyVolume += log.totalVolume;
        for (final ex in log.exercises) {
          weeklySets += ex.sets.where((s) => s.completed).length;
        }
      }

      // --- Last Workout ---
      final lastLog = sorted.first;
      final daysSince = now.difference(lastLog.endTime).inDays;
      final isToday = daysSince == 0;

      final volumeFormatted = lastLog.totalVolume >= 1000
          ? '${(lastLog.totalVolume / 1000).toStringAsFixed(1)}k kg'
          : '${lastLog.totalVolume.toStringAsFixed(0)} kg';

      // --- Write to SharedPreferences ---
      await HomeWidget.saveWidgetData<String>('streak', streak.toString());
      await HomeWidget.saveWidgetData<String>('streak_text', '$streak day streak');
      await HomeWidget.saveWidgetData<String>('weekly_volume', weeklyVolume.toStringAsFixed(0));
      await HomeWidget.saveWidgetData<String>('weekly_workouts', weeklyWorkouts.toString());
      await HomeWidget.saveWidgetData<String>('weekly_sets', weeklySets.toString());
      await HomeWidget.saveWidgetData<String>('last_workout_name', lastLog.name);
      await HomeWidget.saveWidgetData<String>('last_workout_date', _formatDate(lastLog.endTime));
      await HomeWidget.saveWidgetData<String>('last_workout_volume', volumeFormatted);
      await HomeWidget.saveWidgetData<String>('days_since_last', daysSince.toString());
      await HomeWidget.saveWidgetData<String>('trained_today', isToday ? 'true' : 'false');

      await _requestWidgetUpdate();
    } catch (e) {
      debugPrint('WidgetDataService error: $e');
    }
  }

  /// Updates active workout banner in widgets
  static Future<void> updateActiveWorkout({
    required bool isActive,
    String? workoutName,
    String? currentExercise,
  }) async {
    try {
      await HomeWidget.saveWidgetData<String>('active_workout', isActive ? 'true' : 'false');
      await HomeWidget.saveWidgetData<String>('active_workout_name', workoutName ?? '');
      await HomeWidget.saveWidgetData<String>('active_workout_exercise', currentExercise ?? '');
      await _requestWidgetUpdate();
    } catch (e) {
      debugPrint('WidgetDataService updateActiveWorkout error: $e');
    }
  }

  static int _calculateStreak(List<WorkoutLog> sortedLogs, DateTime now) {
    final workoutDays = <String>{};
    for (final log in sortedLogs) {
      final d = log.startTime;
      workoutDays.add('${d.year}-${d.month}-${d.day}');
    }

    int streak = 0;
    var check = DateTime(now.year, now.month, now.day);

    // Check if today counts
    final todayStr = '${check.year}-${check.month}-${check.day}';
    if (!workoutDays.contains(todayStr)) {
      // Check yesterday — if no workout yesterday either, streak is 0
      check = check.subtract(const Duration(days: 1));
      final yStr = '${check.year}-${check.month}-${check.day}';
      if (!workoutDays.contains(yStr)) return 0;
    }

    while (true) {
      final key = '${check.year}-${check.month}-${check.day}';
      if (workoutDays.contains(key)) {
        streak++;
        check = check.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }

  static String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return '$diff days ago';
  }

  static Future<void> _writeDefaults() async {
    await HomeWidget.saveWidgetData<String>('streak', '0');
    await HomeWidget.saveWidgetData<String>('streak_text', '0 day streak');
    await HomeWidget.saveWidgetData<String>('weekly_volume', '0');
    await HomeWidget.saveWidgetData<String>('weekly_workouts', '0');
    await HomeWidget.saveWidgetData<String>('weekly_sets', '0');
    await HomeWidget.saveWidgetData<String>('last_workout_name', 'No workouts yet');
    await HomeWidget.saveWidgetData<String>('last_workout_date', 'Tap to start');
    await HomeWidget.saveWidgetData<String>('last_workout_volume', '');
    await HomeWidget.saveWidgetData<String>('days_since_last', '');
    await HomeWidget.saveWidgetData<String>('trained_today', 'false');
    await HomeWidget.saveWidgetData<String>('active_workout', 'false');
    await HomeWidget.saveWidgetData<String>('active_workout_name', '');
    await HomeWidget.saveWidgetData<String>('active_workout_exercise', '');
  }

  static Future<void> _requestWidgetUpdate() async {
    final widgets = [
      'Widget1x1',
      'Widget2x1',
      'Widget4x1',
      'Widget2x2',
      'Widget4x2',
      'Widget3x3',
    ];

    for (final widget in widgets) {
      try {
        await HomeWidget.updateWidget(
          androidName: widget,
          qualifiedAndroidName: 'com.irontrack.irontrack.$widget',
        );
      } catch (e) {
        debugPrint('Failed to update $widget: $e');
      }
    }
  }
}
