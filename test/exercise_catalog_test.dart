import 'package:flutter_test/flutter_test.dart';
import 'package:irontrack/core/constants/default_exercises.dart';
import 'package:irontrack/providers/exercise_provider.dart';

void main() {
  group('Exercise Catalog & Search Verification', () {
    test('Exercise catalog has over 300 unique exercises', () {
      final list = DefaultExercises.list;
      expect(list.length, greaterThanOrEqualTo(300));

      final ids = <String>{};
      for (final ex in list) {
        expect(ids.contains(ex.id), isFalse, reason: 'Duplicate ID: ${ex.id}');
        ids.add(ex.id);
        expect(ex.name.isNotEmpty, isTrue);
        expect(ex.muscleGroup.isNotEmpty, isTrue);
        expect(ex.equipment.isNotEmpty, isTrue);
      }
    });

    test('Muscle categorizations are discrete and clean', () {
      final list = DefaultExercises.list;
      final muscleGroups = list.map((e) => e.muscleGroup).toSet();

      expect(muscleGroups, containsAll([
        'Chest',
        'Back',
        'Shoulders',
        'Biceps',
        'Triceps',
        'Forearms',
        'Quads',
        'Hamstrings',
        'Glutes',
        'Calves',
        'Core',
        'Cardio',
      ]));

      // Verify no mixing: Wrist curls must NOT be in Biceps
      final bicepWristCurls = list.where((e) => e.muscleGroup == 'Biceps' && e.name.toLowerCase().contains('wrist curl'));
      expect(bicepWristCurls, isEmpty);

      // Verify Forearms has wrist curls
      final forearmWristCurls = list.where((e) => e.muscleGroup == 'Forearms' && e.name.toLowerCase().contains('wrist curl'));
      expect(forearmWristCurls, isNotEmpty);

      // Verify Close-Grip Barbell Bench Press is in Triceps
      final closeGrip = list.firstWhere((e) => e.name.contains('Close-Grip Barbell Bench Press'));
      expect(closeGrip.muscleGroup, equals('Triceps'));
    });

    test('Tokenized search and gym abbreviations work accurately', () {
      final list = DefaultExercises.list;

      // 1. "db press" matches dumbbell presses
      final dbPresses = list.where((e) => exerciseMatchesSearch(e, 'db press')).toList();
      expect(dbPresses.any((e) => e.name == 'Flat Dumbbell Press'), isTrue);
      expect(dbPresses.any((e) => e.name == 'Incline Dumbbell Press'), isTrue);

      // 2. "ohp" matches Overhead Barbell Press
      final ohpMatches = list.where((e) => exerciseMatchesSearch(e, 'ohp')).toList();
      expect(ohpMatches.any((e) => e.name.contains('Overhead Barbell Press')), isTrue);

      // 3. "rdl" matches Romanian Deadlifts
      final rdlMatches = list.where((e) => exerciseMatchesSearch(e, 'rdl')).toList();
      expect(rdlMatches.any((e) => e.name.contains('Romanian Deadlift')), isTrue);

      // 4. "cable chest" matches cable chest flyes & presses
      final cableChestMatches = list.where((e) => exerciseMatchesSearch(e, 'cable chest')).toList();
      expect(cableChestMatches.isNotEmpty, isTrue);
      expect(cableChestMatches.every((e) => e.muscleGroup == 'Chest' || e.equipment == 'Cable'), isTrue);

      // 5. "quad" matches squats and leg presses
      final quadMatches = list.where((e) => exerciseMatchesSearch(e, 'quad')).toList();
      expect(quadMatches.any((e) => e.name.contains('Barbell Back Squat')), isTrue);
      expect(quadMatches.any((e) => e.name.contains('Leg Press')), isTrue);

      // 6. Multi-word query out of order: "bench barbell"
      final benchBb = list.where((e) => exerciseMatchesSearch(e, 'bench barbell')).toList();
      expect(benchBb.any((e) => e.name == 'Barbell Bench Press'), isTrue);

      // 7. Kneeling and one-arm search queries
      final kneelingMatches = list.where((e) => exerciseMatchesSearch(e, 'kneeling')).toList();
      expect(kneelingMatches.any((e) => e.name == 'Half-Kneeling Single-Arm Lat Pulldown'), isTrue);

      final oneArmLat = list.where((e) => exerciseMatchesSearch(e, 'one arm lat pulldown')).toList();
      expect(oneArmLat.any((e) => e.name == 'Single-Arm Cable Lat Pulldown'), isTrue);
      expect(oneArmLat.any((e) => e.name == 'Half-Kneeling Single-Arm Lat Pulldown'), isTrue);
    });

    test('Muscle filter matcher respects discrete groups and parent categories', () {
      final list = DefaultExercises.list;

      // Biceps filter only matches biceps
      final biceps = list.where((e) => exerciseMatchesMuscle(e, 'Biceps')).toList();
      expect(biceps.every((e) => e.muscleGroup == 'Biceps'), isTrue);

      // Triceps filter matches triceps including Close-Grip Bench
      final triceps = list.where((e) => exerciseMatchesMuscle(e, 'Triceps')).toList();
      expect(triceps.every((e) => e.muscleGroup == 'Triceps'), isTrue);
      expect(triceps.any((e) => e.name.contains('Close-Grip Barbell Bench Press')), isTrue);

      // Forearms filter matches forearms
      final forearms = list.where((e) => exerciseMatchesMuscle(e, 'Forearms')).toList();
      expect(forearms.every((e) => e.muscleGroup == 'Forearms'), isTrue);
      expect(forearms.any((e) => e.name.contains('Barbell Wrist Curl')), isTrue);

      // "Arms" parent filter matches Biceps, Triceps, and Forearms
      final allArms = list.where((e) => exerciseMatchesMuscle(e, 'Arms')).toList();
      expect(allArms.every((e) => ['Biceps', 'Triceps', 'Forearms'].contains(e.muscleGroup)), isTrue);
      expect(allArms.length, equals(biceps.length + triceps.length + forearms.length));

      // "Legs" parent filter matches Quads, Hamstrings, Glutes, and Calves
      final allLegs = list.where((e) => exerciseMatchesMuscle(e, 'Legs')).toList();
      expect(allLegs.every((e) => ['Quads', 'Hamstrings', 'Glutes', 'Calves'].contains(e.muscleGroup)), isTrue);
    });
  });
}
