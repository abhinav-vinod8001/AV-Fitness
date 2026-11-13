import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Wearable service for real-time synchronization between the phone app and Wear OS watch.
/// Handles heart rate streaming, workout state synchronization, and watch command callbacks.
class WearableService {
  static final WearableService _instance = WearableService._internal();
  factory WearableService() => _instance;
  WearableService._internal();

  static const MethodChannel _channel = MethodChannel('com.irontrack/wearable');
  static const EventChannel _eventChannel = EventChannel('com.irontrack/wearable_events');

  bool _initialized = false;
  StreamSubscription? _eventSubscription;

  // Connection State
  bool _isConnected = false;
  String _watchName = '';
  int? _watchBattery;

  // Real-time Heart Rate State
  int? _currentBpm;
  DateTime? _lastHeartRateTime;
  final List<int> _sessionHeartRateSamples = [];

  // Callbacks
  void Function(String command)? onWorkoutCommand;
  void Function(int bpm)? onHeartRateUpdated;
  void Function(bool connected, String name)? onConnectionChanged;
  void Function(int battery, String device, int roundTripMs)? onPongReceived;

  // Ping tracking
  int? _lastPingTimestamp;

  bool get isConnected => _isConnected;
  String get watchName => _watchName;
  int? get watchBattery => _watchBattery;
  int? get currentBpm => _currentBpm;
  DateTime? get lastHeartRateTime => _lastHeartRateTime;
  List<int> get sessionHeartRateSamples => List.unmodifiable(_sessionHeartRateSamples);

  int get averageBpm {
    if (_sessionHeartRateSamples.isEmpty) return 0;
    final sum = _sessionHeartRateSamples.fold<int>(0, (a, b) => a + b);
    return (sum / _sessionHeartRateSamples.length).round();
  }

  int get maxBpm {
    if (_sessionHeartRateSamples.isEmpty) return 0;
    return _sessionHeartRateSamples.reduce((curr, next) => curr > next ? curr : next);
  }

  int get minBpm {
    if (_sessionHeartRateSamples.isEmpty) return 0;
    return _sessionHeartRateSamples.reduce((curr, next) => curr < next ? curr : next);
  }

  void init() {
    if (_initialized) return;
    _initialized = true;

    _eventSubscription = _eventChannel.receiveBroadcastStream().listen(
      _handleEvent,
      onError: (err) {
        debugPrint('WearableService event error: $err');
      },
    );

    checkConnection();
  }

  void _handleEvent(dynamic event) {
    if (event is! Map) return;
    final map = Map<String, dynamic>.from(event);
    final type = map['type'] as String?;

    switch (type) {
      case 'connection':
        _isConnected = map['connected'] as bool? ?? false;
        _watchName = map['name'] as String? ?? '';
        onConnectionChanged?.call(_isConnected, _watchName);
        break;

      case 'heart_rate':
        final bpm = map['bpm'] as int? ?? 0;
        if (bpm > 30 && bpm < 250) {
          _currentBpm = bpm;
          _lastHeartRateTime = DateTime.now();
          _sessionHeartRateSamples.add(bpm);
          onHeartRateUpdated?.call(bpm);
        }
        break;

      case 'command':
        final cmd = map['command'] as String?;
        if (cmd != null && cmd.isNotEmpty) {
          onWorkoutCommand?.call(cmd);
        }
        break;

      case 'pong':
        _watchBattery = map['battery'] as int?;
        final device = map['device'] as String? ?? '';
        int latency = 0;
        if (_lastPingTimestamp != null) {
          latency = DateTime.now().millisecondsSinceEpoch - _lastPingTimestamp!;
        }
        _isConnected = true;
        onPongReceived?.call(_watchBattery ?? -1, device, latency);
        break;
    }
  }

  Future<void> checkConnection() async {
    try {
      final res = await _channel.invokeMethod<Map>('getConnectedWatch');
      if (res != null) {
        _isConnected = res['connected'] as bool? ?? false;
        _watchName = res['name'] as String? ?? '';
        onConnectionChanged?.call(_isConnected, _watchName);
      }
    } catch (e) {
      debugPrint('WearableService checkConnection error: $e');
    }
  }

  void startSession() {
    _sessionHeartRateSamples.clear();
    _currentBpm = null;
  }

  Future<void> sendWorkoutState({
    required String workoutName,
    required String currentExercise,
    required int completedSets,
    required int totalSets,
    required bool isResting,
    required int restTimeRemaining,
    required int elapsedSeconds,
    int? currentSetNumber,
    int? totalExerciseSets,
    double? currentSetWeight,
    int? currentSetReps,
    String? weightUnit = 'kg',
  }) async {
    try {
      final stateMap = {
        'action': 'update',
        'workoutName': workoutName,
        'currentExercise': currentExercise,
        'completedSets': completedSets,
        'totalSets': totalSets,
        'isResting': isResting,
        'restRemaining': restTimeRemaining,
        'elapsedSeconds': elapsedSeconds,
        'currentSetNumber': currentSetNumber ?? 1,
        'totalExerciseSets': totalExerciseSets ?? 3,
        'weight': currentSetWeight ?? 0.0,
        'reps': currentSetReps ?? 0,
        'weightUnit': weightUnit,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      await _channel.invokeMethod('sendWorkoutState', {
        'state': jsonEncode(stateMap),
      });
    } catch (e) {
      debugPrint('WearableService sendWorkoutState error: $e');
    }
  }

  Future<void> sendWorkoutStop() async {
    try {
      await _channel.invokeMethod('sendWorkoutStop');
    } catch (e) {
      debugPrint('WearableService sendWorkoutStop error: $e');
    }
  }

  Future<void> pingWatch() async {
    try {
      _lastPingTimestamp = DateTime.now().millisecondsSinceEpoch;
      await _channel.invokeMethod('pingWatch');
    } catch (e) {
      debugPrint('WearableService pingWatch error: $e');
    }
  }

  void dispose() {
    _eventSubscription?.cancel();
    _initialized = false;
  }
}

