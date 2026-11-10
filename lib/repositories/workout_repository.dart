import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/workout_model.dart';
import 'package:uuid/uuid.dart';

class WorkoutRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final CollectionReference<Map<String, dynamic>> _collection = _firestore.collection('workout_templates');

  Future<List<WorkoutTemplate>> getTemplates(String? userId) async {
    if (userId == null || userId.isEmpty) return [];
    
    final snapshot = await _collection.where('userId', isEqualTo: userId).get();
    return snapshot.docs.map((doc) => WorkoutTemplate.fromJson(doc.data())).toList();
  }

  Future<WorkoutTemplate> saveTemplate(WorkoutTemplate template) async {
    final id = template.id.isEmpty ? const Uuid().v4() : template.id;
    final newTemplate = template.copyWith(id: id);
    
    await _collection.doc(id).set(newTemplate.toJson());
    return newTemplate;
  }

  Future<void> deleteTemplate(String id) async {
    await _collection.doc(id).delete();
  }
}
