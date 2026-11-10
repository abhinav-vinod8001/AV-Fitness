import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/exercise_model.dart';
import '../core/constants/default_exercises.dart';
import 'package:uuid/uuid.dart';

class ExerciseRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final CollectionReference<Map<String, dynamic>> _collection = _firestore.collection('exercises');

  Future<List<Exercise>> getExercises(String? userId) async {
    // Start with all default exercises keyed by ID for proper deduplication
    final exercisesById = <String, Exercise>{};
    for (var e in DefaultExercises.list) {
      exercisesById[e.id] = e;
    }

    try {
      if (userId != null && userId.isNotEmpty) {
        final snapshot = await _collection
            .where('userId', isEqualTo: userId)
            .get();

        for (var doc in snapshot.docs) {
          final ex = Exercise.fromJson(doc.data(), doc.id);
          // Custom exercises are always added by their Firestore doc ID
          // This prevents name collisions from silently dropping exercises
          exercisesById[ex.id] = ex;
        }
      }
    } catch (e) {
      // If Firestore fails (offline, permissions), still return defaults
      // Custom exercises will appear once connectivity is restored
    }

    final exercises = exercisesById.values.toList();
    exercises.sort((a, b) => a.name.compareTo(b.name));
    return exercises;
  }

  Future<Exercise> createCustomExercise(Exercise exercise) async {
    final id = exercise.id.isEmpty ? const Uuid().v4() : exercise.id;
    final newExercise = exercise.copyWith(id: id);
    
    await _collection.doc(id).set(newExercise.toJson());
    return newExercise;
  }

  Future<void> deleteCustomExercise(String exerciseId) async {
    await _collection.doc(exerciseId).delete();
  }

  Future<void> updateCustomExercise(Exercise exercise) async {
    await _collection.doc(exercise.id).set(exercise.toJson());
  }
}
