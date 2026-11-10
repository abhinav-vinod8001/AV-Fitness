import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final CollectionReference<Map<String, dynamic>> _collection = _firestore.collection('users');

  Future<UserModel?> getUser(String userId) async {
    final doc = await _collection.doc(userId).get();
    if (doc.exists && doc.data() != null) {
      return UserModel.fromJson(doc.data()!);
    }
    return null;
  }

  Future<void> saveUser(UserModel user) async {
    await _collection.doc(user.id).set(user.toJson(), SetOptions(merge: true));
  }
}
