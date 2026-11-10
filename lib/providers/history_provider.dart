import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/workout_log_model.dart';
import 'active_workout_provider.dart';
import 'auth_provider.dart';

final workoutHistoryProvider = FutureProvider.autoDispose<List<WorkoutLog>>((ref) async {
  final repo = ref.watch(workoutLogRepositoryProvider);
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return [];
  
  final logs = await repo.getLogs(user.uid);
  
  // Sort newest first
  logs.sort((a, b) => b.endTime.compareTo(a.endTime));
  
  return logs;
});
