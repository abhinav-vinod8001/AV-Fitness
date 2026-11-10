import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/folder_model.dart';
import 'package:uuid/uuid.dart';

class FolderRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final CollectionReference<Map<String, dynamic>> _collection = _firestore.collection('workout_folders');

  Future<List<WorkoutFolder>> getFolders(String? userId) async {
    if (userId == null || userId.isEmpty) return [];
    
    final snapshot = await _collection.where('userId', isEqualTo: userId).get();
    return snapshot.docs.map((doc) => WorkoutFolder.fromJson(doc.data())).toList();
  }

  Future<WorkoutFolder> saveFolder(WorkoutFolder folder) async {
    final id = folder.id.isEmpty ? const Uuid().v4() : folder.id;
    final newFolder = folder.copyWith(id: id);
    
    await _collection.doc(id).set(newFolder.toJson());
    return newFolder;
  }

  Future<void> deleteFolder(String id) async {
    await _collection.doc(id).delete();
  }
}
