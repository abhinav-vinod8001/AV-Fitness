class BodyMeasurement {
  final String id;
  final String? userId;
  final DateTime date;
  final double? bodyWeight; // kg
  final double? chest; // cm
  final double? waist; // cm
  final double? hips; // cm
  final double? bicepLeft; // cm
  final double? bicepRight; // cm
  final double? thighLeft; // cm
  final double? thighRight; // cm

  BodyMeasurement({
    required this.id,
    this.userId,
    required this.date,
    this.bodyWeight,
    this.chest,
    this.waist,
    this.hips,
    this.bicepLeft,
    this.bicepRight,
    this.thighLeft,
    this.thighRight,
  });

  factory BodyMeasurement.fromJson(Map<String, dynamic> json) {
    return BodyMeasurement(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String?,
      date: json['date'] != null ? DateTime.parse(json['date'] as String) : DateTime.now(),
      bodyWeight: (json['bodyWeight'] as num?)?.toDouble(),
      chest: (json['chest'] as num?)?.toDouble(),
      waist: (json['waist'] as num?)?.toDouble(),
      hips: (json['hips'] as num?)?.toDouble(),
      bicepLeft: (json['bicepLeft'] as num?)?.toDouble(),
      bicepRight: (json['bicepRight'] as num?)?.toDouble(),
      thighLeft: (json['thighLeft'] as num?)?.toDouble(),
      thighRight: (json['thighRight'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (userId != null) 'userId': userId,
      'date': date.toIso8601String(),
      if (bodyWeight != null) 'bodyWeight': bodyWeight,
      if (chest != null) 'chest': chest,
      if (waist != null) 'waist': waist,
      if (hips != null) 'hips': hips,
      if (bicepLeft != null) 'bicepLeft': bicepLeft,
      if (bicepRight != null) 'bicepRight': bicepRight,
      if (thighLeft != null) 'thighLeft': thighLeft,
      if (thighRight != null) 'thighRight': thighRight,
    };
  }

  BodyMeasurement copyWith({
    String? id,
    String? userId,
    DateTime? date,
    double? bodyWeight,
    double? chest,
    double? waist,
    double? hips,
    double? bicepLeft,
    double? bicepRight,
    double? thighLeft,
    double? thighRight,
  }) {
    return BodyMeasurement(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      bodyWeight: bodyWeight ?? this.bodyWeight,
      chest: chest ?? this.chest,
      waist: waist ?? this.waist,
      hips: hips ?? this.hips,
      bicepLeft: bicepLeft ?? this.bicepLeft,
      bicepRight: bicepRight ?? this.bicepRight,
      thighLeft: thighLeft ?? this.thighLeft,
      thighRight: thighRight ?? this.thighRight,
    );
  }
}
