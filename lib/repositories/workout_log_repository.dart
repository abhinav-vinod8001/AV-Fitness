import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/workout_log_model.dart';

class WorkoutLogRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final CollectionReference<Map<String, dynamic>> _collection = _firestore.collection('workout_logs');

  Future<void> saveLog(WorkoutLog log) async {
    // Workout logs should typically just have the ID set when created
    final docRef = _collection.doc(log.id.isEmpty ? null : log.id);
    // If we're creating a new one without an ID, let's update the model with the generated ID
    final newLog = log.id.isEmpty ? log.copyWith(id: docRef.id) : log;
    await docRef.set(newLog.toJson());
  }

  Future<List<WorkoutLog>> getLogs(String? userId) async {
    if (userId == null || userId.isEmpty) return [];

    final snapshot = await _collection
        .where('userId', isEqualTo: userId)
        .get();

    final logs = snapshot.docs.map((doc) => WorkoutLog.fromJson(doc.data())).toList();
    logs.sort((a, b) => b.startTime.compareTo(a.startTime));
    return logs;
  }

  Future<void> deleteLog(String logId) async {
    if (logId.isEmpty) return;
    await _collection.doc(logId).delete();
  }
}

