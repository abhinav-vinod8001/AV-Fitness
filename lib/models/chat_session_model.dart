import 'dart:convert';
import 'coach_message_model.dart';

class ChatSession {
  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<CoachMessage> messages;

  ChatSession({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    required this.messages,
  });

  String get preview {
    if (messages.isEmpty) return 'No messages yet';
    final last = messages.last;
    final snippet = last.content.replaceAll('\n', ' ').trim();
    if (snippet.length > 70) {
      return '${snippet.substring(0, 67)}...';
    }
    return snippet;
  }

  int get userMessageCount => messages.where((m) => m.isUser).length;
  int get coachMessageCount => messages.where((m) => m.isCoach).length;

  ChatSession copyWith({
    String? id,
    String? title,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<CoachMessage>? messages,
  }) {
    return ChatSession(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      messages: messages ?? this.messages,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'messages': messages.map((m) => m.toMap()).toList(),
    };
  }

  factory ChatSession.fromMap(Map<String, dynamic> map) {
    return ChatSession(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? 'Conversation',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      messages: (map['messages'] as List? ?? [])
          .map((m) {
            if (m is Map<String, dynamic>) {
              return CoachMessage.fromMap(m);
            } else if (m is Map) {
              return CoachMessage.fromMap(Map<String, dynamic>.from(m));
            }
            return null;
          })
          .whereType<CoachMessage>()
          .toList(),
    );
  }

  String toJson() => jsonEncode(toMap());

  factory ChatSession.fromJson(String source) =>
      ChatSession.fromMap(jsonDecode(source) as Map<String, dynamic>);
}
