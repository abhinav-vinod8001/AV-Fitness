import 'workout_model.dart';

class WorkoutLog {
  final String id;
  final String templateId; // If it was started from a routine
  final String name;
  final DateTime startTime;
  final DateTime endTime;
  final List<WorkoutExercise> exercises;
  final String? userId;
  final List<int>? heartRateData; // Mock data for heart rate graph (BPM at 1-min intervals)

  WorkoutLog({
    required this.id,
    required this.templateId,
    required this.name,
    required this.startTime,
    required this.endTime,
    required this.exercises,
    this.userId,
    this.heartRateData,
  });

  factory WorkoutLog.fromJson(Map<String, dynamic> json) {
    return WorkoutLog(
      id: json['id'] as String? ?? '',
      templateId: json['templateId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      startTime: json['startTime'] != null
          ? DateTime.parse(json['startTime'] as String)
          : DateTime.now(),
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'] as String)
          : DateTime.now(),
      exercises: (json['exercises'] as List<dynamic>?)
              ?.map((e) => WorkoutExercise.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      userId: json['userId'] as String?,
      heartRateData: (json['heartRateData'] as List<dynamic>?)?.map((e) => e as int).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'templateId': templateId,
      'name': name,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'exercises': exercises.map((e) => e.toJson()).toList(),
      if (userId != null) 'userId': userId,
      if (heartRateData != null) 'heartRateData': heartRateData,
    };
  }

  WorkoutLog copyWith({
    String? id,
    String? templateId,
    String? name,
    DateTime? startTime,
    DateTime? endTime,
    List<WorkoutExercise>? exercises,
    String? userId,
    List<int>? heartRateData,
  }) {
    return WorkoutLog(
      id: id ?? this.id,
      templateId: templateId ?? this.templateId,
      name: name ?? this.name,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      exercises: exercises ?? this.exercises,
      userId: userId ?? this.userId,
      heartRateData: heartRateData ?? this.heartRateData,
    );
  }

  Duration get duration => endTime.difference(startTime);

  double get totalVolume {
    double volume = 0;
    for (var ex in exercises) {
      for (var set in ex.sets) {
        if (set.completed) {
          volume += set.weight * set.reps;
        }
      }
    }
    return volume;
  }
}
