import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/workout_model.dart';
import 'workout_provider.dart';

// Key: Weekday (1 = Monday, 7 = Sunday)
// Value: List of WorkoutTemplate IDs
class WeeklyScheduleNotifier extends StateNotifier<Map<int, List<String>>> {
  WeeklyScheduleNotifier() : super({}) {
    _loadSchedule();
  }

  Future<void> _loadSchedule() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('weekly_schedule');
    if (jsonStr != null) {
      try {
        final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
        final Map<int, List<String>> loaded = {};
        for (final entry in decoded.entries) {
          final day = int.tryParse(entry.key);
          if (day != null) {
            loaded[day] = List<String>.from(entry.value);
          }
        }
        state = loaded;
      } catch (e) {
        state = {};
      }
    }
  }

  Future<void> _saveSchedule(Map<int, List<String>> newSchedule) async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, dynamic> toSave = {};
    for (final entry in newSchedule.entries) {
      toSave[entry.key.toString()] = entry.value;
    }
    await prefs.setString('weekly_schedule', jsonEncode(toSave));
    state = newSchedule;
  }

  Future<void> addRoutineToDay(int weekday, String templateId) async {
    final current = Map<int, List<String>>.from(state);
    final list = current[weekday] ?? [];
    if (!list.contains(templateId)) {
      list.add(templateId);
      current[weekday] = list;
      await _saveSchedule(current);
    }
  }

  Future<void> removeRoutineFromDay(int weekday, String templateId) async {
    final current = Map<int, List<String>>.from(state);
    final list = current[weekday] ?? [];
    if (list.contains(templateId)) {
      list.remove(templateId);
      if (list.isEmpty) {
        current.remove(weekday);
      } else {
        current[weekday] = list;
      }
      await _saveSchedule(current);
    }
  }

  Future<void> clearDay(int weekday) async {
    final current = Map<int, List<String>>.from(state);
    if (current.containsKey(weekday)) {
      current.remove(weekday);
      await _saveSchedule(current);
    }
  }
}

final weeklyScheduleProvider = StateNotifierProvider<WeeklyScheduleNotifier, Map<int, List<String>>>((ref) {
  return WeeklyScheduleNotifier();
});

final dailyWorkoutNamesProvider = Provider<Map<int, String>>((ref) {
  final schedule = ref.watch(weeklyScheduleProvider);
  final templatesAsync = ref.watch(workoutTemplatesProvider);
  
  if (templatesAsync.value == null) return {};
  
  final templates = templatesAsync.value!;
  final Map<int, String> result = {};
  
  for (final entry in schedule.entries) {
    if (entry.value.isNotEmpty) {
      final templateId = entry.value.first;
      final template = templates.firstWhere(
        (t) => t.id == templateId, 
        orElse: () => WorkoutTemplate(id: '', name: 'Workout', exercises: [], userId: '')
      );
      result[entry.key] = template.name;
    }
  }
  return result;
});
