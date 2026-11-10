import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'history_provider.dart';

class Achievement {
  final String id;
  final String title;
  final String subtitle;
  final DateTime date;
  final IconData icon;

  const Achievement({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.date,
    required this.icon,
  });
}

final achievementsProvider = FutureProvider.autoDispose<List<Achievement>>((ref) async {
  final historyLogs = await ref.watch(workoutHistoryProvider.future);
  
  if (historyLogs.isEmpty) return [];

  final List<Achievement> achievements = [];
  
  // 1. First Workout Achievement
  achievements.add(Achievement(
    id: 'first_workout',
    title: 'Journey Begun',
    subtitle: 'Completed your first ever workout!',
    date: historyLogs.last.endTime, // last in list because it's sorted newest first
    icon: Icons.flag_rounded,
  ));

  // 2. Workout Count Milestones (10, 50, 100)
  final count = historyLogs.length;
  if (count >= 10) {
    achievements.add(Achievement(
      id: 'workouts_10',
      title: 'Consistency is Key',
      subtitle: 'Completed 10 workouts',
      date: historyLogs[historyLogs.length - 10].endTime,
      icon: Icons.military_tech_rounded,
    ));
  }
  if (count >= 50) {
    achievements.add(Achievement(
      id: 'workouts_50',
      title: 'Half Century',
      subtitle: 'Completed 50 workouts',
      date: historyLogs[historyLogs.length - 50].endTime,
      icon: Icons.workspace_premium_rounded,
    ));
  }

  // 3. Max Weight PRs per Exercise
  // Track all-time max weight for each exercise name
  final Map<String, double> maxWeights = {};
  final Map<String, DateTime> maxWeightDates = {};

  // Iterate chronologically (reverse the list since it's newest first)
  for (final log in historyLogs.reversed) {
    for (final ex in log.exercises) {
      for (final set in ex.sets) {
        if (set.completed && set.weight > 0 && set.reps > 0) {
          final currentMax = maxWeights[ex.exerciseName] ?? 0.0;
          if (set.weight > currentMax) {
            maxWeights[ex.exerciseName] = set.weight;
            maxWeightDates[ex.exerciseName] = log.endTime;
          }
        }
      }
    }
  }

  // Convert Max Weights to Achievements
  for (final entry in maxWeights.entries) {
    if (entry.value > 0) {
      achievements.add(Achievement(
        id: 'pr_${entry.key}',
        title: '${entry.key} PR',
        subtitle: '${entry.value.toStringAsFixed(1)} kg',
        date: maxWeightDates[entry.key]!,
        icon: Icons.emoji_events_rounded,
      ));
    }
  }

  // Sort by date descending (newest first)
  achievements.sort((a, b) => b.date.compareTo(a.date));

  return achievements;
});
