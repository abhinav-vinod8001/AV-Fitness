class WorkoutSet {
  final String id;
  final int setNumber;
  final double weight;
  final int reps;
  final double? rpe;
  final bool isWarmup;
  final bool completed;

  WorkoutSet({
    required this.id,
    required this.setNumber,
    this.weight = 0.0,
    this.reps = 0,
    this.rpe,
    this.isWarmup = false,
    this.completed = false,
  });

  factory WorkoutSet.fromJson(Map<String, dynamic> json) {
    return WorkoutSet(
      id: json['id'] as String? ?? '',
      setNumber: json['setNumber'] as int? ?? 1,
      weight: (json['weight'] as num?)?.toDouble() ?? 0.0,
      reps: json['reps'] as int? ?? 0,
      rpe: (json['rpe'] as num?)?.toDouble(),
      isWarmup: json['isWarmup'] as bool? ?? false,
      completed: json['completed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'setNumber': setNumber,
      'weight': weight,
      'reps': reps,
      if (rpe != null) 'rpe': rpe,
      'isWarmup': isWarmup,
      'completed': completed,
    };
  }

  WorkoutSet copyWith({
    String? id,
    int? setNumber,
    double? weight,
    int? reps,
    double? rpe,
    bool? isWarmup,
    bool? completed,
  }) {
    return WorkoutSet(
      id: id ?? this.id,
      setNumber: setNumber ?? this.setNumber,
      weight: weight ?? this.weight,
      reps: reps ?? this.reps,
      rpe: rpe ?? this.rpe,
      isWarmup: isWarmup ?? this.isWarmup,
      completed: completed ?? this.completed,
    );
  }
}

class WorkoutExercise {
  final String id;
  final String exerciseId;
  final String exerciseName;
  final String notes;
  final List<WorkoutSet> sets;

  WorkoutExercise({
    required this.id,
    required this.exerciseId,
    required this.exerciseName,
    this.notes = '',
    required this.sets,
  });

  factory WorkoutExercise.fromJson(Map<String, dynamic> json) {
    return WorkoutExercise(
      id: json['id'] as String? ?? '',
      exerciseId: json['exerciseId'] as String? ?? '',
      exerciseName: json['exerciseName'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
      sets: (json['sets'] as List<dynamic>?)
              ?.map((e) => WorkoutSet.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'exerciseId': exerciseId,
      'exerciseName': exerciseName,
      'notes': notes,
      'sets': sets.map((e) => e.toJson()).toList(),
    };
  }

  WorkoutExercise copyWith({
    String? id,
    String? exerciseId,
    String? exerciseName,
    String? notes,
    List<WorkoutSet>? sets,
  }) {
    return WorkoutExercise(
      id: id ?? this.id,
      exerciseId: exerciseId ?? this.exerciseId,
      exerciseName: exerciseName ?? this.exerciseName,
      notes: notes ?? this.notes,
      sets: sets ?? this.sets,
    );
  }
}

class WorkoutTemplate {
  final String id;
  final String name;
  final String? notes;
  final List<WorkoutExercise> exercises;
  final String? userId;
  final String? folderId;
  final int sortOrder;

  WorkoutTemplate({
    required this.id,
    required this.name,
    this.notes,
    required this.exercises,
    this.userId,
    this.folderId,
    this.sortOrder = 0,
  });

  factory WorkoutTemplate.fromJson(Map<String, dynamic> json) {
    return WorkoutTemplate(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      notes: json['notes'] as String?,
      exercises: (json['exercises'] as List<dynamic>?)
              ?.map((e) => WorkoutExercise.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      userId: json['userId'] as String?,
      folderId: json['folderId'] as String?,
      sortOrder: json['sortOrder'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (notes != null) 'notes': notes,
      'exercises': exercises.map((e) => e.toJson()).toList(),
      if (userId != null) 'userId': userId,
      if (folderId != null) 'folderId': folderId,
      'sortOrder': sortOrder,
    };
  }

  WorkoutTemplate copyWith({
    String? id,
    String? name,
    String? notes,
    List<WorkoutExercise>? exercises,
    String? userId,
    String? folderId,
    int? sortOrder,
  }) {
    return WorkoutTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      notes: notes ?? this.notes,
      exercises: exercises ?? this.exercises,
      userId: userId ?? this.userId,
      folderId: folderId ?? this.folderId,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}
