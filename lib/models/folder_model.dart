class WorkoutFolder {
  final String id;
  final String name;
  final String userId;
  final DateTime createdAt;

  WorkoutFolder({
    required this.id,
    required this.name,
    required this.userId,
    required this.createdAt,
  });

  factory WorkoutFolder.fromJson(Map<String, dynamic> json) {
    return WorkoutFolder(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  WorkoutFolder copyWith({
    String? id,
    String? name,
    String? userId,
    DateTime? createdAt,
  }) {
    return WorkoutFolder(
      id: id ?? this.id,
      name: name ?? this.name,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
