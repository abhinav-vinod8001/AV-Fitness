import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/body_measurement_model.dart';
import '../repositories/body_measurement_repository.dart';
import 'exercise_provider.dart';

final bodyMeasurementRepositoryProvider = Provider<BodyMeasurementRepository>((ref) {
  return BodyMeasurementRepository();
});

class BodyMeasurementNotifier extends StateNotifier<AsyncValue<List<BodyMeasurement>>> {
  final Ref ref;

  BodyMeasurementNotifier(this.ref) : super(const AsyncValue.loading()) {
    loadMeasurements();
  }

  Future<void> loadMeasurements() async {
    final userId = ref.read(mockUserIdProvider);
    if (userId.isEmpty) {
      state = const AsyncValue.data([]);
      return;
    }

    try {
      final repo = ref.read(bodyMeasurementRepositoryProvider);
      final list = await repo.getMeasurements(userId);
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addFromInput({
    double? bodyWeight,
    double? chest,
    double? waist,
    double? hips,
    double? bicepLeft,
    double? bicepRight,
    double? thighLeft,
    double? thighRight,
  }) async {
    final userId = ref.read(mockUserIdProvider);
    final m = BodyMeasurement(
      id: const Uuid().v4(),
      userId: userId,
      date: DateTime.now(),
      bodyWeight: bodyWeight,
      chest: chest,
      waist: waist,
      hips: hips,
      bicepLeft: bicepLeft,
      bicepRight: bicepRight,
      thighLeft: thighLeft,
      thighRight: thighRight,
    );

    final currentList = state.valueOrNull ?? [];
    state = AsyncValue.data([m, ...currentList]);

    try {
      final repo = ref.read(bodyMeasurementRepositoryProvider);
      await repo.saveMeasurement(m);
    } catch (e) {
      // Revert or reload if save failed
      loadMeasurements();
    }
  }

  Future<void> removeMeasurement(String id) async {
    final currentList = state.valueOrNull ?? [];
    state = AsyncValue.data(currentList.where((m) => m.id != id).toList());

    try {
      final repo = ref.read(bodyMeasurementRepositoryProvider);
      await repo.deleteMeasurement(id);
    } catch (_) {
      loadMeasurements();
    }
  }
}

final bodyMeasurementProvider =
    StateNotifierProvider<BodyMeasurementNotifier, AsyncValue<List<BodyMeasurement>>>((ref) {
  return BodyMeasurementNotifier(ref);
});
