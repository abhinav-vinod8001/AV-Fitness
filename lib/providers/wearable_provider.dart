import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/wearable_service.dart';

class WearableState {
  final bool isConnected;
  final String watchName;
  final int? currentBpm;
  final int averageBpm;
  final int maxBpm;
  final int minBpm;
  final int samplesCount;
  final int? batteryLevel;
  final DateTime? lastHeartRateTime;
  final int? pingLatencyMs;
  final bool isPinging;

  const WearableState({
    this.isConnected = false,
    this.watchName = '',
    this.currentBpm,
    this.averageBpm = 0,
    this.maxBpm = 0,
    this.minBpm = 0,
    this.samplesCount = 0,
    this.batteryLevel,
    this.lastHeartRateTime,
    this.pingLatencyMs,
    this.isPinging = false,
  });

  WearableState copyWith({
    bool? isConnected,
    String? watchName,
    int? currentBpm,
    int? averageBpm,
    int? maxBpm,
    int? minBpm,
    int? samplesCount,
    int? batteryLevel,
    DateTime? lastHeartRateTime,
    int? pingLatencyMs,
    bool? isPinging,
  }) {
    return WearableState(
      isConnected: isConnected ?? this.isConnected,
      watchName: watchName ?? this.watchName,
      currentBpm: currentBpm ?? this.currentBpm,
      averageBpm: averageBpm ?? this.averageBpm,
      maxBpm: maxBpm ?? this.maxBpm,
      minBpm: minBpm ?? this.minBpm,
      samplesCount: samplesCount ?? this.samplesCount,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      lastHeartRateTime: lastHeartRateTime ?? this.lastHeartRateTime,
      pingLatencyMs: pingLatencyMs ?? this.pingLatencyMs,
      isPinging: isPinging ?? this.isPinging,
    );
  }
}

class WearableNotifier extends StateNotifier<WearableState> {
  final WearableService _service;

  WearableNotifier(this._service) : super(const WearableState()) {
    _init();
  }

  void _init() {
    _service.init();

    _service.onConnectionChanged = (connected, name) {
      state = state.copyWith(
        isConnected: connected,
        watchName: name,
      );
    };

    _service.onHeartRateUpdated = (bpm) {
      state = state.copyWith(
        currentBpm: bpm,
        averageBpm: _service.averageBpm,
        maxBpm: _service.maxBpm,
        minBpm: _service.minBpm,
        samplesCount: _service.sessionHeartRateSamples.length,
        lastHeartRateTime: _service.lastHeartRateTime,
      );
    };

    _service.onPongReceived = (battery, device, latency) {
      state = state.copyWith(
        isConnected: true,
        watchName: device.isNotEmpty ? device : state.watchName,
        batteryLevel: battery >= 0 ? battery : state.batteryLevel,
        pingLatencyMs: latency,
        isPinging: false,
      );
    };

    // Initial sync
    state = state.copyWith(
      isConnected: _service.isConnected,
      watchName: _service.watchName,
    );
  }

  Future<void> refreshConnection() async {
    await _service.checkConnection();
    state = state.copyWith(
      isConnected: _service.isConnected,
      watchName: _service.watchName,
    );
  }

  Future<void> pingWatch() async {
    state = state.copyWith(isPinging: true);
    await _service.pingWatch();
    // Reset pinging state after timeout if no pong received
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && state.isPinging) {
        state = state.copyWith(isPinging: false);
      }
    });
  }

  void resetSession() {
    _service.startSession();
    state = state.copyWith(
      currentBpm: null,
      averageBpm: 0,
      maxBpm: 0,
      minBpm: 0,
      samplesCount: 0,
    );
  }
}

final wearableServiceProvider = Provider<WearableService>((ref) {
  return WearableService();
});

final wearableProvider = StateNotifierProvider<WearableNotifier, WearableState>((ref) {
  final service = ref.watch(wearableServiceProvider);
  return WearableNotifier(service);
});

