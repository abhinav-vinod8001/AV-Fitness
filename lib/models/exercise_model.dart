class Exercise {
  final String id;
  final String name;
  final String muscleGroup;
  final String equipment;
  final String? instructions;
  final String? imageUrl;
  final bool isCustom;
  final String? userId;

  Exercise({
    required this.id,
    required this.name,
    required this.muscleGroup,
    required this.equipment,
    this.instructions,
    this.imageUrl,
    this.isCustom = false,
    this.userId,
  });

  factory Exercise.fromJson(Map<String, dynamic> json, String documentId) {
    return Exercise(
      id: documentId,
      name: json['name'] as String? ?? '',
      muscleGroup: json['muscleGroup'] as String? ?? 'Other',
      equipment: json['equipment'] as String? ?? 'None',
      instructions: json['instructions'] as String?,
      imageUrl: json['imageUrl'] as String?,
      isCustom: json['isCustom'] as bool? ?? false,
      userId: json['userId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'muscleGroup': muscleGroup,
      'equipment': equipment,
      if (instructions != null) 'instructions': instructions,
      if (imageUrl != null) 'imageUrl': imageUrl,
      'isCustom': isCustom,
      if (userId != null) 'userId': userId,
    };
  }

  Exercise copyWith({
    String? id,
    String? name,
    String? muscleGroup,
    String? equipment,
    String? instructions,
    String? imageUrl,
    bool? isCustom,
    String? userId,
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      muscleGroup: muscleGroup ?? this.muscleGroup,
      equipment: equipment ?? this.equipment,
      instructions: instructions ?? this.instructions,
      imageUrl: imageUrl ?? this.imageUrl,
      isCustom: isCustom ?? this.isCustom,
      userId: userId ?? this.userId,
    );
  }
}
