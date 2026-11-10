import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class LiveActivityService {
  static const MethodChannel _channel = MethodChannel('com.irontrack/live_activity');
  static bool _initialized = false;
  static VoidCallback? _onSkipRestCallback;
  static ValueChanged<int>? _onAddRestCallback;
  static void Function(String exerciseId, String setId)? _onCompleteSetCallback;

  static void initialize({
    VoidCallback? onSkipRest,
    ValueChanged<int>? onAddRest,
    void Function(String exerciseId, String setId)? onCompleteSet,
  }) {
    _onSkipRestCallback = onSkipRest;
    _onAddRestCallback = onAddRest;
    _onCompleteSetCallback = onCompleteSet;

    if (!_initialized) {
      _channel.setMethodCallHandler((call) async {
        switch (call.method) {
          case 'onAddRestTime':
            final seconds = call.arguments as int? ?? 30;
            _onAddRestCallback?.call(seconds);
            break;
          case 'onSkipRest':
            _onSkipRestCallback?.call();
            break;
          case 'onCompleteSet':
            final args = call.arguments as Map<dynamic, dynamic>?;
            if (args != null) {
              final exerciseId = args['exerciseId'] as String?;
              final setId = args['setId'] as String?;
              if (exerciseId != null && setId != null) {
                _onCompleteSetCallback?.call(exerciseId, setId);
              }
            }
            break;
        }
      });
      _initialized = true;
    }
  }

  static Future<void> startOrUpdate({
    required String workoutName,
    required String currentExercise,
    required int completedSets,
    required int totalSets,
    required DateTime startTime,
    required bool isResting,
    required int restTimeRemaining,
    int? currentSetNumber,
    int? totalExerciseSets,
    double? currentSetWeight,
    int? currentSetReps,
    String? nextSetExerciseId,
    String? nextSetId,
  }) async {
    try {
      await _channel.invokeMethod('startLiveActivity', {
        'workoutName': workoutName,
        'currentExercise': currentExercise,
        'completedSets': completedSets,
        'totalSets': totalSets,
        'startTimeMillis': startTime.millisecondsSinceEpoch,
        'isResting': isResting,
        'restTimeRemaining': restTimeRemaining,
        'currentSetNumber': currentSetNumber,
        'totalExerciseSets': totalExerciseSets,
        'currentSetWeight': currentSetWeight,
        'currentSetReps': currentSetReps,
        'nextSetExerciseId': nextSetExerciseId,
        'nextSetId': nextSetId,
      });
    } catch (e) {
      debugPrint('LiveActivityService update error: $e');
    }
  }

  static Future<void> stop() async {
    try {
      await _channel.invokeMethod('stopLiveActivity');
    } catch (e) {
      debugPrint('LiveActivityService stop error: $e');
    }
  }
}
