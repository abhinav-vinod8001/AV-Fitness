import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/body_measurement_model.dart';
import 'package:uuid/uuid.dart';

class BodyMeasurementRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final CollectionReference<Map<String, dynamic>> _collection =
      _firestore.collection('body_measurements');

  Future<List<BodyMeasurement>> getMeasurements(String? userId) async {
    if (userId == null || userId.isEmpty) return [];

    final snapshot = await _collection
        .where('userId', isEqualTo: userId)
        .get();

    final list = snapshot.docs
        .map((doc) => BodyMeasurement.fromJson(doc.data()))
        .toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  Future<BodyMeasurement> saveMeasurement(BodyMeasurement measurement) async {
    final id = measurement.id.isEmpty ? const Uuid().v4() : measurement.id;
    final newMeasurement = measurement.copyWith(id: id);

    await _collection.doc(id).set(newMeasurement.toJson());
    return newMeasurement;
  }

  Future<void> deleteMeasurement(String id) async {
    await _collection.doc(id).delete();
  }
}
