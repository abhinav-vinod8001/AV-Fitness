import 'dart:convert';

class CoachMessage {
  final String role; // 'coach' or 'user'
  final String content;
  final DateTime timestamp;

  CoachMessage({
    required this.role,
    required this.content,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  bool get isCoach => role == 'coach';
  bool get isUser => role == 'user';

  Map<String, dynamic> toMap() {
    return {
      'role': role,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory CoachMessage.fromMap(Map<String, dynamic> map) {
    return CoachMessage(
      role: map['role'] ?? 'coach',
      content: map['content'] ?? '',
      timestamp: map['timestamp'] != null
          ? DateTime.tryParse(map['timestamp']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  String toJson() => jsonEncode(toMap());

  factory CoachMessage.fromJson(String source) =>
      CoachMessage.fromMap(jsonDecode(source) as Map<String, dynamic>);
}
