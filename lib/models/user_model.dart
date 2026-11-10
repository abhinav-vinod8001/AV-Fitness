class UserModel {
  final String id;
  final String email;
  final String displayName;
  final double? height;
  final double? weight;
  final int? age;
  final String? gender;
  final String? goal;
  final String? experienceLevel;
  final String? latestInsight;
  final Map<String, String>? questionnaire;

  UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    this.height,
    this.weight,
    this.age,
    this.gender,
    this.goal,
    this.experienceLevel,
    this.latestInsight,
    this.questionnaire,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      height: (json['height'] as num?)?.toDouble(),
      weight: (json['weight'] as num?)?.toDouble(),
      age: json['age'] as int?,
      gender: json['gender'] as String?,
      goal: json['goal'] as String?,
      experienceLevel: json['experienceLevel'] as String?,
      latestInsight: json['latestInsight'] as String?,
      questionnaire: json['questionnaire'] != null 
          ? Map<String, String>.from(json['questionnaire'] as Map) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      if (height != null) 'height': height,
      if (weight != null) 'weight': weight,
      if (age != null) 'age': age,
      if (gender != null) 'gender': gender,
      if (goal != null) 'goal': goal,
      if (experienceLevel != null) 'experienceLevel': experienceLevel,
      if (latestInsight != null) 'latestInsight': latestInsight,
      if (questionnaire != null) 'questionnaire': questionnaire,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    double? height,
    double? weight,
    int? age,
    String? gender,
    String? goal,
    String? experienceLevel,
    String? latestInsight,
    Map<String, String>? questionnaire,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      goal: goal ?? this.goal,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      latestInsight: latestInsight ?? this.latestInsight,
      questionnaire: questionnaire ?? this.questionnaire,
    );
  }
}
