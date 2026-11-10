import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WeeklyGoalsState {
  final int targetWorkoutsPerWeek;
  final double targetVolumeKg;
  final int targetActiveMinutes;

  const WeeklyGoalsState({
    required this.targetWorkoutsPerWeek,
    required this.targetVolumeKg,
    required this.targetActiveMinutes,
  });

  WeeklyGoalsState copyWith({
    int? targetWorkoutsPerWeek,
    double? targetVolumeKg,
    int? targetActiveMinutes,
  }) {
    return WeeklyGoalsState(
      targetWorkoutsPerWeek: targetWorkoutsPerWeek ?? this.targetWorkoutsPerWeek,
      targetVolumeKg: targetVolumeKg ?? this.targetVolumeKg,
      targetActiveMinutes: targetActiveMinutes ?? this.targetActiveMinutes,
    );
  }
}

class WeeklyGoalsNotifier extends StateNotifier<WeeklyGoalsState> {
  WeeklyGoalsNotifier() : super(const WeeklyGoalsState(
    targetWorkoutsPerWeek: 4,
    targetVolumeKg: 10000.0,
    targetActiveMinutes: 180,
  )) {
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    final prefs = await SharedPreferences.getInstance();
    final targetW = prefs.getInt('targetWorkoutsPerWeek') ?? 4;
    final targetV = prefs.getDouble('targetVolumeKg') ?? 10000.0;
    final targetM = prefs.getInt('targetActiveMinutes') ?? 180;
    state = state.copyWith(
      targetWorkoutsPerWeek: targetW,
      targetVolumeKg: targetV,
      targetActiveMinutes: targetM,
    );
  }

  Future<void> updateGoals({int? workouts, double? volume, int? minutes}) async {
    final prefs = await SharedPreferences.getInstance();
    if (workouts != null) await prefs.setInt('targetWorkoutsPerWeek', workouts);
    if (volume != null) await prefs.setDouble('targetVolumeKg', volume);
    if (minutes != null) await prefs.setInt('targetActiveMinutes', minutes);
    state = state.copyWith(
      targetWorkoutsPerWeek: workouts,
      targetVolumeKg: volume,
      targetActiveMinutes: minutes,
    );
  }
}

final weeklyGoalsProvider = StateNotifierProvider<WeeklyGoalsNotifier, WeeklyGoalsState>((ref) {
  return WeeklyGoalsNotifier();
});
