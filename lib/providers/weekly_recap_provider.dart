import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:io';

import '../providers/history_provider.dart';
import '../providers/settings_provider.dart';
import '../models/workout_log_model.dart';
import '../core/constants/default_exercises.dart';

// ──────────────────────────────────────────────
//  Data Models
// ──────────────────────────────────────────────

class WeeklyRecapData {
  final String intro;
  final List<String> tips;

  WeeklyRecapData({required this.intro, required this.tips});

  Map<String, dynamic> toJson() => {'intro': intro, 'tips': tips};

  factory WeeklyRecapData.fromJson(Map<String, dynamic> json) {
    return WeeklyRecapData(
      intro: json['intro']?.toString() ?? 'Great job this week!',
      tips: (json['tips'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}

class ExerciseVolumeStat {
  final String name;
  final double volume;
  ExerciseVolumeStat({required this.name, required this.volume});
}

class WeekPR {
  final String exerciseName;
  final double weight;
  WeekPR({required this.exerciseName, required this.weight});
}

class WeeklyRecapState {
  final bool isLoading;
  final WeeklyRecapData? recapData;
  final String? error;
  final DateTime? targetSunday;
  final bool needsApiKey;

  // Computed stats
  final int workoutCount;
  final double totalVolume;
  final int totalMinutes;
  final int totalSets;

  // Week-over-week deltas (percentage change, null if no prior week)
  final double? volumeDelta;
  final int? workoutDelta;
  final double? minutesDelta;

  // Consistency
  final int daysWithWorkout;

  // Top exercises
  final List<ExerciseVolumeStat> topExercises;

  // PRs this week
  final List<WeekPR> weekPRs;

  // Muscle group breakdown {muscleGroup: totalVolume}
  final Map<String, double> muscleGroupVolume;

  // Daily volume for graph
  final List<double> dailyVolume;
  final List<String?> dailyPrimaryMuscle;

  WeeklyRecapState({
    this.isLoading = true,
    this.recapData,
    this.error,
    this.targetSunday,
    this.needsApiKey = false,
    this.workoutCount = 0,
    this.totalVolume = 0,
    this.totalMinutes = 0,
    this.totalSets = 0,
    this.volumeDelta,
    this.workoutDelta,
    this.minutesDelta,
    this.daysWithWorkout = 0,
    this.topExercises = const [],
    this.weekPRs = const [],
    this.muscleGroupVolume = const {},
    this.dailyVolume = const [],
    this.dailyPrimaryMuscle = const [],
  });
}

// ──────────────────────────────────────────────
//  Notifier
// ──────────────────────────────────────────────

class WeeklyRecapNotifier extends StateNotifier<WeeklyRecapState> {
  final Ref ref;

  WeeklyRecapNotifier(this.ref) : super(WeeklyRecapState()) {
    generateRecap();
  }

  Future<void> generateRecap() async {
    state = WeeklyRecapState(isLoading: true);

    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();

    // ── Find target Sunday 10 AM ──
    var d = now;
    while (d.weekday != DateTime.sunday) {
      d = d.subtract(const Duration(days: 1));
    }
    final mostRecentSunday10AM = DateTime(d.year, d.month, d.day, 10, 0);
    final targetSunday10AM = now.isBefore(mostRecentSunday10AM)
        ? mostRecentSunday10AM.subtract(const Duration(days: 7))
        : mostRecentSunday10AM;

    // ── Get all logs ──
    final allLogs = ref.read(workoutHistoryProvider).valueOrNull ?? [];

    final startOfWeek = targetSunday10AM.subtract(const Duration(days: 7));
    final weekLogs = allLogs
        .where((log) =>
            log.startTime.isBefore(targetSunday10AM) &&
            log.startTime.isAfter(startOfWeek))
        .toList();

    // Previous week logs (for week-over-week)
    final prevStart = startOfWeek.subtract(const Duration(days: 7));
    final prevLogs = allLogs
        .where((log) =>
            log.startTime.isBefore(startOfWeek) &&
            log.startTime.isAfter(prevStart))
        .toList();

    if (weekLogs.isEmpty) {
      state = WeeklyRecapState(
          isLoading: false, recapData: null, targetSunday: targetSunday10AM);
      return;
    }

    // ── Compute all stats ──
    final stats = _computeStats(weekLogs, prevLogs, startOfWeek, allLogs);

    // ── Check cache ──
    final savedRecap = prefs.getString('weekly_recap_text');
    final savedRecapTimeStr = prefs.getString('weekly_recap_time');
    DateTime? savedRecapTime;
    if (savedRecapTimeStr != null) {
      savedRecapTime = DateTime.tryParse(savedRecapTimeStr);
    }

    if (savedRecap != null &&
        savedRecapTime != null &&
        savedRecapTime.isAfter(targetSunday10AM)) {
      try {
        final data = WeeklyRecapData.fromJson(jsonDecode(savedRecap));
        state = _buildStateWithStats(
            data: data, stats: stats, targetSunday: targetSunday10AM);
        return;
      } catch (e) {
        debugPrint('Failed to parse cached recap: $e');
      }
    }

    // ── Check API key ──
    final apiKey = ref
        .read(settingsProvider)
        .groqApiKey
        .trim()
        .replaceAll('"', '')
        .replaceAll("'", '');
    if (apiKey.isEmpty) {
      state = _buildStateWithStats(
          stats: stats, targetSunday: targetSunday10AM, needsApiKey: true);
      return;
    }

    // ── Call AI ──
    final prompt = '''
You are a highly motivating AI fitness coach. The user just finished their week of training.
Stats for past 7 days:
- Workouts: ${stats['workoutCount']}
- Volume: ${(stats['totalVolume'] as double).toInt()} kg
- Active Minutes: ${stats['totalMinutes']}
- Days trained: ${stats['daysWithWorkout']} / 7
${(stats['volumeDelta'] as double?) != null ? '- Volume change vs last week: ${((stats['volumeDelta'] as double) >= 0 ? '+' : '')}${(stats['volumeDelta'] as double).toStringAsFixed(0)}%' : ''}

Write a personalized, highly encouraging weekly recap.
You MUST respond ONLY with a valid JSON object. No markdown, no backticks.
Schema: {"intro": "2-3 sentence energetic congratulation", "tips": ["tip1", "tip2", "tip3"]}
''';

    final models = ['openai/gpt-oss-20b', 'llama3-8b-8192'];
    for (final model in models) {
      try {
        final response = await http
            .post(
          Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'model': model,
            'messages': [
              {'role': 'user', 'content': prompt}
            ],
            'temperature': 0.7,
            'max_tokens': 350,
          }),
        )
            .timeout(const Duration(seconds: 20));

        if (response.statusCode == 200) {
          final data = jsonDecode(utf8.decode(response.bodyBytes));
          final content =
              data['choices']?[0]?['message']?['content']?.toString().trim();
          if (content != null && content.isNotEmpty) {
            final parsed = _extractJson(content);
            if (parsed != null) {
              await prefs.setString(
                  'weekly_recap_text', jsonEncode(parsed.toJson()));
              await prefs.setString(
                  'weekly_recap_time', now.toIso8601String());
              state = _buildStateWithStats(
                  data: parsed, stats: stats, targetSunday: targetSunday10AM);
              return;
            }
          }
        } else if (response.statusCode == 401) {
          state = _buildStateWithStats(
              stats: stats,
              targetSunday: targetSunday10AM,
              error: 'Invalid API key. Check Settings.');
          return;
        } else if (response.statusCode == 429) {
          state = _buildStateWithStats(
              stats: stats,
              targetSunday: targetSunday10AM,
              error: 'Rate limit hit. Try again shortly.');
          return;
        } else if (response.statusCode == 404) {
          continue;
        } else {
          continue;
        }
      } on TimeoutException {
        continue;
      } on SocketException {
        state = _buildStateWithStats(
            stats: stats,
            targetSunday: targetSunday10AM,
            error: 'No internet connection.');
        return;
      } catch (e) {
        continue;
      }
    }

    // All models failed — offline fallback
    final fallback = WeeklyRecapData(
      intro:
          "What a week! You crushed ${stats['workoutCount']} workouts and moved ${(stats['totalVolume'] as double).toInt()}kg of total volume. Keep pushing!",
      tips: [
        'Focus on progressive overload — add small weight or extra reps each session.',
        'Stay hydrated and aim for 7-8 hours of sleep.',
        'Consider a deload week every 4-6 weeks to prevent burnout.',
      ],
    );
    await prefs.setString('weekly_recap_text', jsonEncode(fallback.toJson()));
    await prefs.setString('weekly_recap_time', now.toIso8601String());
    state = _buildStateWithStats(
        data: fallback, stats: stats, targetSunday: targetSunday10AM);
  }

  // ── Compute all advanced stats ──
  Map<String, dynamic> _computeStats(List<WorkoutLog> weekLogs,
      List<WorkoutLog> prevLogs, DateTime startOfWeek, List<WorkoutLog> allLogs) {
    double totalVolume = 0;
    int totalMinutes = 0;
    int totalSets = 0;
    final Set<String> daysWorkedOut = {};
    final Map<String, double> exerciseVolumes = {};
    final Map<String, double> muscleGroupVol = {};
    final dailyVolume = List.filled(7, 0.0);
    final List<Map<String, double>> dailyMuscleVols = List.generate(7, (_) => {});

    // Build a lookup map for exercise -> muscle group
    final exerciseToMuscle = <String, String>{};
    for (final ex in DefaultExercises.list) {
      exerciseToMuscle[ex.name.toLowerCase()] = ex.muscleGroup;
      exerciseToMuscle[ex.id] = ex.muscleGroup;
    }

    for (final log in weekLogs) {
      totalVolume += log.totalVolume;
      totalMinutes += log.duration.inMinutes;
      daysWorkedOut
          .add('${log.startTime.year}-${log.startTime.month}-${log.startTime.day}');

      final dayIndex = log.startTime.difference(startOfWeek).inDays;
      if (dayIndex >= 0 && dayIndex < 7) {
        dailyVolume[dayIndex] += log.totalVolume;
      }

      for (final ex in log.exercises) {
        double exVol = 0;
        for (final set in ex.sets) {
          if (set.completed) {
            totalSets++;
            exVol += set.weight * set.reps;
          }
        }
        exerciseVolumes[ex.exerciseName] =
            (exerciseVolumes[ex.exerciseName] ?? 0) + exVol;

        // Muscle group lookup
        final muscle = exerciseToMuscle[ex.exerciseId] ??
            exerciseToMuscle[ex.exerciseName.toLowerCase()] ??
            'Other';
        muscleGroupVol[muscle] = (muscleGroupVol[muscle] ?? 0) + exVol;
        
        if (dayIndex >= 0 && dayIndex < 7) {
          dailyMuscleVols[dayIndex][muscle] = (dailyMuscleVols[dayIndex][muscle] ?? 0) + exVol;
        }
      }
    }

    final List<String?> dailyPrimaryMuscle = List.filled(7, null);
    for (int i = 0; i < 7; i++) {
      if (dailyMuscleVols[i].isNotEmpty) {
        final sorted = dailyMuscleVols[i].entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        dailyPrimaryMuscle[i] = sorted.first.key;
      }
    }

    // Top exercises by volume
    final sortedExercises = exerciseVolumes.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topExercises = sortedExercises
        .take(3)
        .map((e) => ExerciseVolumeStat(name: e.key, volume: e.value))
        .toList();

    // Week PRs — find weights that are higher than all prior history
    final List<WeekPR> weekPRs = [];
    final Map<String, double> priorMaxWeights = {};
    final priorLogs = allLogs.where((log) => log.startTime.isBefore(startOfWeek));
    for (final log in priorLogs) {
      for (final ex in log.exercises) {
        for (final set in ex.sets) {
          if (set.completed && set.weight > 0) {
            final cur = priorMaxWeights[ex.exerciseName] ?? 0;
            if (set.weight > cur) {
              priorMaxWeights[ex.exerciseName] = set.weight;
            }
          }
        }
      }
    }
    for (final log in weekLogs) {
      for (final ex in log.exercises) {
        for (final set in ex.sets) {
          if (set.completed && set.weight > 0) {
            final prior = priorMaxWeights[ex.exerciseName] ?? 0;
            if (set.weight > prior) {
              // Check we haven't already added a higher PR for this exercise
              final existing =
                  weekPRs.where((p) => p.exerciseName == ex.exerciseName);
              if (existing.isEmpty || existing.first.weight < set.weight) {
                weekPRs.removeWhere((p) => p.exerciseName == ex.exerciseName);
                weekPRs.add(
                    WeekPR(exerciseName: ex.exerciseName, weight: set.weight));
              }
            }
          }
        }
      }
    }

    // Week-over-week deltas
    double? volumeDelta;
    int? workoutDelta;
    double? minutesDelta;
    if (prevLogs.isNotEmpty) {
      double prevVolume = 0;
      int prevMinutes = 0;
      for (final log in prevLogs) {
        prevVolume += log.totalVolume;
        prevMinutes += log.duration.inMinutes;
      }
      if (prevVolume > 0) {
        volumeDelta = ((totalVolume - prevVolume) / prevVolume) * 100;
      }
      workoutDelta = weekLogs.length - prevLogs.length;
      if (prevMinutes > 0) {
        minutesDelta = ((totalMinutes - prevMinutes) / prevMinutes) * 100;
      }
    }

    return {
      'workoutCount': weekLogs.length,
      'totalVolume': totalVolume,
      'totalMinutes': totalMinutes,
      'totalSets': totalSets,
      'daysWithWorkout': daysWorkedOut.length,
      'topExercises': topExercises,
      'weekPRs': weekPRs,
      'muscleGroupVolume': muscleGroupVol,
      'dailyVolume': dailyVolume,
      'dailyPrimaryMuscle': dailyPrimaryMuscle,
      'volumeDelta': volumeDelta,
      'workoutDelta': workoutDelta,
      'minutesDelta': minutesDelta,
    };
  }

  WeeklyRecapState _buildStateWithStats({
    WeeklyRecapData? data,
    required Map<String, dynamic> stats,
    required DateTime targetSunday,
    bool needsApiKey = false,
    String? error,
  }) {
    return WeeklyRecapState(
      isLoading: false,
      recapData: data,
      targetSunday: targetSunday,
      needsApiKey: needsApiKey,
      error: error,
      workoutCount: stats['workoutCount'] as int,
      totalVolume: stats['totalVolume'] as double,
      totalMinutes: stats['totalMinutes'] as int,
      totalSets: stats['totalSets'] as int,
      daysWithWorkout: stats['daysWithWorkout'] as int,
      topExercises: stats['topExercises'] as List<ExerciseVolumeStat>,
      weekPRs: stats['weekPRs'] as List<WeekPR>,
      muscleGroupVolume: stats['muscleGroupVolume'] as Map<String, double>,
      dailyVolume: stats['dailyVolume'] as List<double>,
      dailyPrimaryMuscle: stats['dailyPrimaryMuscle'] as List<String?>,
      volumeDelta: stats['volumeDelta'] as double?,
      workoutDelta: stats['workoutDelta'] as int?,
      minutesDelta: stats['minutesDelta'] as double?,
    );
  }

  WeeklyRecapData? _extractJson(String raw) {
    try {
      return WeeklyRecapData.fromJson(jsonDecode(raw));
    } catch (_) {}
    try {
      final s = raw.indexOf('{');
      final e = raw.lastIndexOf('}');
      if (s != -1 && e != -1 && e > s) {
        return WeeklyRecapData.fromJson(jsonDecode(raw.substring(s, e + 1)));
      }
    } catch (_) {}
    return null;
  }
}

final weeklyRecapProvider =
    StateNotifierProvider.autoDispose<WeeklyRecapNotifier, WeeklyRecapState>(
        (ref) => WeeklyRecapNotifier(ref));
