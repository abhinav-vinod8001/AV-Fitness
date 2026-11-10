import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/exercise_model.dart';

class MockDataSeeder {
  static Future<void> seedExercises() async {
    final firestore = FirebaseFirestore.instance;
    final collection = firestore.collection('exercises');

    final snap = await collection.limit(1).get();
    if (snap.docs.isNotEmpty) {
      // Already seeded
      return;
    }

    final mockExercises = [
      Exercise(id: '', name: 'Bench Press', muscleGroup: 'Chest', equipment: 'Barbell', isCustom: false),
      Exercise(id: '', name: 'Incline Dumbbell Press', muscleGroup: 'Chest', equipment: 'Dumbbell', isCustom: false),
      Exercise(id: '', name: 'Squat', muscleGroup: 'Legs', equipment: 'Barbell', isCustom: false),
      Exercise(id: '', name: 'Deadlift', muscleGroup: 'Back', equipment: 'Barbell', isCustom: false),
      Exercise(id: '', name: 'Pull Up', muscleGroup: 'Back', equipment: 'None', isCustom: false),
      Exercise(id: '', name: 'Shoulder Press', muscleGroup: 'Shoulders', equipment: 'Dumbbell', isCustom: false),
      Exercise(id: '', name: 'Bicep Curl', muscleGroup: 'Arms', equipment: 'Dumbbell', isCustom: false),
      Exercise(id: '', name: 'Tricep Extension', muscleGroup: 'Arms', equipment: 'Cable', isCustom: false),
      Exercise(id: '', name: 'Crunch', muscleGroup: 'Core', equipment: 'None', isCustom: false),
    ];

    for (var ex in mockExercises) {
      final docRef = collection.doc();
      final newEx = ex.copyWith(id: docRef.id);
      await docRef.set(newEx.toJson());
    }
  }
}
