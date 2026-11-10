import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/exercise_model.dart';
import '../repositories/exercise_repository.dart';
import 'auth_provider.dart';

// Provides the current authenticated user's ID for Firestore queries
final mockUserIdProvider = Provider<String>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.valueOrNull?.uid ?? '';
});

final exerciseRepositoryProvider = Provider<ExerciseRepository>((ref) {
  return ExerciseRepository();
});

final exerciseListProvider = FutureProvider<List<Exercise>>((ref) async {
  final repository = ref.watch(exerciseRepositoryProvider);
  final userId = ref.watch(mockUserIdProvider);
  return repository.getExercises(userId);
});

enum ExerciseSortOption {
  nameAsc('Name (A - Z)'),
  nameDesc('Name (Z - A)'),
  muscleGroup('Muscle Group'),
  equipment('Equipment');

  final String label;
  const ExerciseSortOption(this.label);
}

// Global Filter & Search Providers for ExercisesScreen
final exerciseSearchQueryProvider = StateProvider<String>((ref) => '');
final exerciseMuscleGroupFilterProvider = StateProvider<String?>((ref) => null);
final exerciseEquipmentFilterProvider = StateProvider<String?>((ref) => null);
final exerciseSortOptionProvider = StateProvider<ExerciseSortOption>((ref) => ExerciseSortOption.nameAsc);

// Independent Filter & Search Providers for SelectExercisesScreen (auto-resets when screen closes)
final selectExerciseSearchQueryProvider = StateProvider.autoDispose<String>((ref) => '');
final selectExerciseMuscleGroupFilterProvider = StateProvider.autoDispose<String?>((ref) => null);
final selectExerciseEquipmentFilterProvider = StateProvider.autoDispose<String?>((ref) => null);
final selectExerciseSortOptionProvider = StateProvider.autoDispose<ExerciseSortOption>((ref) => ExerciseSortOption.nameAsc);

/// Core search matcher supporting tokenized multi-word matching and gym abbreviations
bool exerciseMatchesSearch(Exercise exercise, String query) {
  final cleanQuery = query.trim().toLowerCase();
  if (cleanQuery.isEmpty) return true;

  final terms = cleanQuery.split(RegExp(r'\s+'));
  final exName = exercise.name.toLowerCase();
  final exMuscle = exercise.muscleGroup.toLowerCase();
  final exEq = exercise.equipment.toLowerCase();

  final List<String> searchableFields = [exName, exMuscle, exEq];

  // Muscle group synonyms and anatomy expansions
  switch (exMuscle) {
    case 'chest':
      searchableFields.addAll(['pec', 'pecs', 'bench']);
      break;
    case 'back':
      searchableFields.addAll(['lat', 'lats', 'traps', 'trap', 'rhomboid', 'erector', 'row', 'pull']);
      break;
    case 'shoulders':
      searchableFields.addAll(['shoulder', 'delt', 'delts', 'deltoid', 'deltoids', 'ohp', 'press']);
      break;
    case 'biceps':
      searchableFields.addAll(['bicep', 'arm', 'arms', 'curl', 'brachialis']);
      break;
    case 'triceps':
      searchableFields.addAll(['tricep', 'arm', 'arms', 'pushdown', 'extension', 'skull']);
      break;
    case 'forearms':
      searchableFields.addAll(['forearm', 'wrist', 'grip', 'arm', 'arms', 'hang']);
      break;
    case 'quads':
      searchableFields.addAll(['quad', 'quadriceps', 'leg', 'legs', 'thigh', 'thighs', 'squat', 'press']);
      break;
    case 'hamstrings':
      searchableFields.addAll(['hamstring', 'hams', 'leg', 'legs', 'rdl', 'deadlift', 'curl']);
      break;
    case 'glutes':
      searchableFields.addAll(['glute', 'butt', 'hip', 'thrust', 'bridge', 'kickback', 'leg', 'legs']);
      break;
    case 'calves':
      searchableFields.addAll(['calf', 'soleus', 'gastrocnemius', 'tibialis', 'raise', 'leg', 'legs']);
      break;
    case 'core':
      searchableFields.addAll(['abs', 'ab', 'abdominals', 'oblique', 'obliques', 'crunch', 'plank']);
      break;
    case 'cardio':
      searchableFields.addAll(['conditioning', 'hiit', 'endurance', 'aerobic', 'run', 'bike', 'row']);
      break;
  }

  // Equipment shortcuts
  if (exEq == 'none' || exEq == 'bodyweight') {
    searchableFields.addAll(['bodyweight', 'calisthenics', 'free', 'bw']);
  } else if (exEq == 'dumbbell') {
    searchableFields.add('db');
  } else if (exEq == 'barbell') {
    searchableFields.addAll(['bb', 'bar']);
  } else if (exEq == 'kettlebell') {
    searchableFields.add('kb');
  } else if (exEq == 'machine') {
    searchableFields.add('mach');
  }

  final fullSearchableString = searchableFields.join(' ');

  // All terms must match at least one variation or field
  for (final term in terms) {
    if (term.isEmpty) continue;

    List<String> termVariations = [term];
    if (term == 'db') termVariations.add('dumbbell');
    if (term == 'bb') termVariations.add('barbell');
    if (term == 'kb') termVariations.add('kettlebell');
    if (term == 'ohp') termVariations.addAll(['overhead', 'shoulder press', 'overhead press']);
    if (term == 'rdl') termVariations.addAll(['romanian', 'romanian deadlift']);
    if (term == 'sldl') termVariations.addAll(['stiff', 'stiff-legged']);
    if (term == 'ghr') termVariations.addAll(['glute-ham', 'glute ham']);
    if (term == 'ez') termVariations.addAll(['ez-bar', 'ez bar']);
    if (term == 'abs' || term == 'ab') termVariations.addAll(['core', 'abdominal']);
    if (term == 'quad' || term == 'quads') termVariations.addAll(['quads', 'quadriceps']);
    if (term == 'hamstring' || term == 'hamstrings') termVariations.addAll(['hamstrings', 'hams']);
    if (term == 'glute' || term == 'glutes') termVariations.addAll(['glutes', 'gluteus']);
    if (term == 'calf' || term == 'calves') termVariations.addAll(['calves', 'calf']);
    if (term == 'lat' || term == 'lats') termVariations.addAll(['lats', 'latissimus']);
    if (term == 'delt' || term == 'delts') termVariations.addAll(['delts', 'shoulders']);
    if (term == 'pec' || term == 'pecs') termVariations.addAll(['chest', 'pecs']);
    if (term == 'bodyweight' || term == 'bw') termVariations.addAll(['none', 'bodyweight']);
    if (term == 'one' || term == 'single') termVariations.addAll(['single', 'single-arm', 'one', 'one-arm', 'unilateral']);
    if (term == 'kneel' || term == 'kneeling') termVariations.addAll(['kneel', 'kneeling', 'half-kneeling']);
    if (term == 'pulldown' || term == 'pull-down') termVariations.addAll(['pulldown', 'lat pulldown', 'pull down']);

    final termMatches = termVariations.any((v) => fullSearchableString.contains(v));
    if (!termMatches) return false;
  }

  return true;
}

/// Category and parent-muscle filter matcher
bool exerciseMatchesMuscle(Exercise exercise, String? filter) {
  if (filter == null || filter.isEmpty || filter == 'All') return true;
  final filterLower = filter.toLowerCase();
  final exMuscle = exercise.muscleGroup.toLowerCase();

  if (filterLower == 'arms') {
    return exMuscle == 'biceps' || exMuscle == 'triceps' || exMuscle == 'forearms';
  }
  if (filterLower == 'legs') {
    return exMuscle == 'quads' || exMuscle == 'hamstrings' || exMuscle == 'glutes' || exMuscle == 'calves';
  }
  if (filterLower == 'core' || filterLower == 'abs') {
    return exMuscle == 'core';
  }
  return exMuscle == filterLower;
}

/// Equipment filter matcher
bool exerciseMatchesEquipment(Exercise exercise, String? filter) {
  if (filter == null || filter.isEmpty || filter == 'All') return true;
  final eqLower = filter.toLowerCase();
  final exEq = exercise.equipment.toLowerCase();
  if (eqLower == 'bodyweight' || eqLower == 'none') {
    return exEq == 'none' || exEq == 'bodyweight';
  }
  return exEq.contains(eqLower);
}

void _sortExercises(List<Exercise> list, ExerciseSortOption sortOption) {
  switch (sortOption) {
    case ExerciseSortOption.nameAsc:
      list.sort((a, b) => a.name.compareTo(b.name));
      break;
    case ExerciseSortOption.nameDesc:
      list.sort((a, b) => b.name.compareTo(a.name));
      break;
    case ExerciseSortOption.muscleGroup:
      list.sort((a, b) {
        final m = a.muscleGroup.compareTo(b.muscleGroup);
        return m != 0 ? m : a.name.compareTo(b.name);
      });
      break;
    case ExerciseSortOption.equipment:
      list.sort((a, b) {
        final eq = a.equipment.compareTo(b.equipment);
        return eq != 0 ? eq : a.name.compareTo(b.name);
      });
      break;
  }
}

// Provider for ExercisesScreen
final filteredExercisesProvider = Provider<List<Exercise>>((ref) {
  final exercisesAsync = ref.watch(exerciseListProvider);
  final searchQuery = ref.watch(exerciseSearchQueryProvider);
  final muscleFilter = ref.watch(exerciseMuscleGroupFilterProvider);
  final equipmentFilter = ref.watch(exerciseEquipmentFilterProvider);
  final sortOption = ref.watch(exerciseSortOptionProvider);

  return exercisesAsync.maybeWhen(
    data: (exercises) {
      var result = exercises.where((exercise) {
        return exerciseMatchesSearch(exercise, searchQuery) &&
            exerciseMatchesMuscle(exercise, muscleFilter) &&
            exerciseMatchesEquipment(exercise, equipmentFilter);
      }).toList();

      _sortExercises(result, sortOption);
      return result;
    },
    orElse: () => [],
  );
});

// Provider for SelectExercisesScreen (when building or running workouts)
final filteredSelectExercisesProvider = Provider<List<Exercise>>((ref) {
  final exercisesAsync = ref.watch(exerciseListProvider);
  final searchQuery = ref.watch(selectExerciseSearchQueryProvider);
  final muscleFilter = ref.watch(selectExerciseMuscleGroupFilterProvider);
  final equipmentFilter = ref.watch(selectExerciseEquipmentFilterProvider);
  final sortOption = ref.watch(selectExerciseSortOptionProvider);

  return exercisesAsync.maybeWhen(
    data: (exercises) {
      var result = exercises.where((exercise) {
        return exerciseMatchesSearch(exercise, searchQuery) &&
            exerciseMatchesMuscle(exercise, muscleFilter) &&
            exerciseMatchesEquipment(exercise, equipmentFilter);
      }).toList();

      _sortExercises(result, sortOption);
      return result;
    },
    orElse: () => [],
  );
});
