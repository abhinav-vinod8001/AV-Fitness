import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/workout_persistence_service.dart';

class RestTimerState {
  final int remainingSeconds;
  final bool isActive;

  RestTimerState({required this.remainingSeconds, required this.isActive});

  String get formattedTime {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

class RestTimerNotifier extends StateNotifier<RestTimerState> {
  Timer? _timer;

  RestTimerNotifier() : super(RestTimerState(remainingSeconds: 0, isActive: false));

  void start(int seconds) {
    _timer?.cancel();
    state = RestTimerState(remainingSeconds: seconds, isActive: true);
    WorkoutPersistenceService.saveRestTimerState(remainingSeconds: seconds);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.remainingSeconds > 0) {
        state = RestTimerState(remainingSeconds: state.remainingSeconds - 1, isActive: true);
      } else {
        stop();
      }
    });
  }

  void stop() {
    _timer?.cancel();
    WorkoutPersistenceService.clearRestTimerState();
    state = RestTimerState(remainingSeconds: 0, isActive: false);
  }

  void addTime(int seconds) {
    if (state.isActive) {
      state = RestTimerState(remainingSeconds: state.remainingSeconds + seconds, isActive: true);
    }
  }

  void subtractTime(int seconds) {
    if (state.isActive) {
      final newTime = state.remainingSeconds - seconds;
      if (newTime <= 0) {
        stop();
      } else {
        state = RestTimerState(remainingSeconds: newTime, isActive: true);
      }
    }
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final restTimerProvider = StateNotifierProvider<RestTimerNotifier, RestTimerState>((ref) {
  return RestTimerNotifier();
});
