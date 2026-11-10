import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/workout_log_model.dart';

/// Service that persists active workout state to SharedPreferences so that
/// workout progress survives OS-initiated background termination.
class WorkoutPersistenceService {
  static const String _activeWorkoutKey = 'active_workout_backup';
  static const String _restTimerEndKey = 'rest_timer_end_millis';
  static const String _restTimerDurationKey = 'rest_timer_total_seconds';

  // ──────────────────────────────────────────────
  // Active Workout persistence
  // ──────────────────────────────────────────────

  /// Save the current in-progress workout to SharedPreferences.
  static Future<void> saveActiveWorkout(WorkoutLog log) async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(log.toJson());
    await prefs.setString(_activeWorkoutKey, json);
  }

  /// Load a previously saved in-progress workout.
  /// Returns `null` if no backup exists or if deserialization fails.
  static Future<WorkoutLog?> loadActiveWorkout() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_activeWorkoutKey);
    if (json == null || json.isEmpty) return null;

    try {
      final map = jsonDecode(json) as Map<String, dynamic>;
      return WorkoutLog.fromJson(map);
    } catch (e) {
      // Corrupted data — clear it so we don't keep failing
      await clearActiveWorkout();
      return null;
    }
  }

  /// Clear saved workout backup (called on Finish or Discard).
  static Future<void> clearActiveWorkout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_activeWorkoutKey);
  }

  /// Returns `true` if there is a saved workout backup.
  static Future<bool> hasSavedWorkout() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_activeWorkoutKey);
  }

  // ──────────────────────────────────────────────
  // Rest Timer persistence
  // ──────────────────────────────────────────────

  /// Save rest timer state by storing the absolute end-time.
  /// This lets us recalculate remaining seconds on restore.
  static Future<void> saveRestTimerState({
    required int remainingSeconds,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final endTime = DateTime.now().add(Duration(seconds: remainingSeconds));
    await prefs.setInt(_restTimerEndKey, endTime.millisecondsSinceEpoch);
    await prefs.setInt(_restTimerDurationKey, remainingSeconds);
  }

  /// Load rest timer state.
  /// Returns remaining seconds (>0 if still active), or `null` if no timer.
  static Future<int?> loadRestTimerRemainingSeconds() async {
    final prefs = await SharedPreferences.getInstance();
    final endMillis = prefs.getInt(_restTimerEndKey);
    if (endMillis == null) return null;

    final endTime = DateTime.fromMillisecondsSinceEpoch(endMillis);
    final remaining = endTime.difference(DateTime.now()).inSeconds;

    if (remaining <= 0) {
      // Timer has already expired while app was dead
      await clearRestTimerState();
      return null;
    }
    return remaining;
  }

  /// Clear rest timer backup.
  static Future<void> clearRestTimerState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_restTimerEndKey);
    await prefs.remove(_restTimerDurationKey);
  }
}
