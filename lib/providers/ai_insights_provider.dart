import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/coach_message_model.dart';
import '../providers/user_provider.dart';
import '../providers/history_provider.dart';
import '../providers/settings_provider.dart';

class AiCoachState {
  final List<CoachMessage> messages;
  final bool isTyping;
  final String? error;
  final DateTime? lastFetched;

  const AiCoachState({
    this.messages = const [],
    this.isTyping = false,
    this.error,
    this.lastFetched,
  });

  AiCoachState copyWith({
    List<CoachMessage>? messages,
    bool? isTyping,
    String? error,
    DateTime? lastFetched,
  }) {
    return AiCoachState(
      messages: messages ?? this.messages,
      isTyping: isTyping ?? this.isTyping,
      error: error,
      lastFetched: lastFetched ?? this.lastFetched,
    );
  }

  bool get hasMessages => messages.isNotEmpty;
}

class AiCoachNotifier extends StateNotifier<AiCoachState> {
  final Ref ref;
  static const String _storageKey = 'ai_coach_chat_history_v1';

  AiCoachNotifier(this.ref) : super(const AiCoachState()) {
    _initHistory();
  }

  Future<void> _initHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_storageKey);
      if (list != null && list.isNotEmpty) {
        final loadedMessages = list
            .map((str) {
              try {
                return CoachMessage.fromJson(str);
              } catch (_) {
                return null;
              }
            })
            .whereType<CoachMessage>()
            .toList();

        if (loadedMessages.isNotEmpty) {
          state = state.copyWith(messages: loadedMessages);
          return;
        }
      }
    } catch (e) {
      debugPrint('Error loading AI chat history: $e');
    }
  }

  Future<void> _persistMessages(List<CoachMessage> messages) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Keep up to 100 messages for storage efficiency
      final toSave = messages.length > 100 ? messages.sublist(messages.length - 100) : messages;
      final encoded = toSave.map((m) => m.toJson()).toList();
      await prefs.setStringList(_storageKey, encoded);
    } catch (e) {
      debugPrint('Error saving AI chat history: $e');
    }
  }

  Future<void> clearChatHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
      state = const AiCoachState();
      await generateInitialInsight();
    } catch (e) {
      debugPrint('Error clearing chat history: $e');
    }
  }

  /// Generate the initial coaching insight — called on first load
  Future<void> generateInitialInsight() async {
    if (state.isTyping) return;

    final apiKey = ref.read(settingsProvider).groqApiKey.trim().replaceAll('"', '').replaceAll("'", '');
    if (apiKey.isEmpty) {
      if (state.messages.isEmpty) {
        _generateOfflineTips();
      }
      return;
    }

    // Don't refetch if we already have messages loaded
    if (state.hasMessages) {
      return;
    }

    state = state.copyWith(isTyping: true, error: null);

    try {
      final systemPrompt = await _buildSystemPrompt();
      final userPrompt = _buildInitialPrompt();

      final response = await _callApi(apiKey, systemPrompt, [
        {'role': 'user', 'content': userPrompt},
      ]);

      if (response != null && !response.startsWith('Error:')) {
        final newMessages = [CoachMessage(role: 'coach', content: response)];
        state = AiCoachState(
          messages: newMessages,
          isTyping: false,
          lastFetched: DateTime.now(),
        );
        await _persistMessages(newMessages);
      } else {
        _generateOfflineTips();
      }
    } catch (e) {
      _generateOfflineTips();
    }
  }

  /// Send a follow-up message from the user and get a coach response
  Future<void> sendMessage(String userMessage) async {
    if (state.isTyping || userMessage.trim().isEmpty) return;

    final apiKey = ref.read(settingsProvider).groqApiKey.trim().replaceAll('"', '').replaceAll("'", '');
    if (apiKey.isEmpty) {
      final updated = [
        ...state.messages,
        CoachMessage(role: 'user', content: userMessage),
        CoachMessage(
          role: 'coach',
          content: 'I need an API key to give you personalized advice. Add your free Groq API key in Settings to unlock AI coaching!',
        ),
      ];
      state = state.copyWith(messages: updated);
      await _persistMessages(updated);
      return;
    }

    // Add user message immediately
    final updatedMessages = [
      ...state.messages,
      CoachMessage(role: 'user', content: userMessage.trim()),
    ];
    state = state.copyWith(messages: updatedMessages, isTyping: true, error: null);
    await _persistMessages(updatedMessages);

    try {
      final systemPrompt = await _buildSystemPrompt();

      // Build conversation history for the API (keep last 8 messages for context)
      final recentMessages = updatedMessages.length > 8
          ? updatedMessages.sublist(updatedMessages.length - 8)
          : updatedMessages;

      final apiMessages = recentMessages.map((m) => {
        'role': m.isCoach ? 'assistant' : 'user',
        'content': m.content,
      }).toList();

      final response = await _callApi(apiKey, systemPrompt, apiMessages);

      if (response != null && !response.startsWith('Error:')) {
        final withReply = [
          ...state.messages,
          CoachMessage(role: 'coach', content: response),
        ];
        state = state.copyWith(
          messages: withReply,
          isTyping: false,
          lastFetched: DateTime.now(),
        );
        await _persistMessages(withReply);
      } else {
        final errorMsg = response != null && response.startsWith('Error:')
            ? response.replaceFirst('Error:', '').trim()
            : 'Having trouble connecting right now. Let\'s try again in a moment.';

        final withError = [
          ...state.messages,
          CoachMessage(role: 'coach', content: errorMsg),
        ];
        state = state.copyWith(
          messages: withError,
          isTyping: false,
        );
        await _persistMessages(withError);
      }
    } catch (e) {
      final withError = [
        ...state.messages,
        CoachMessage(
          role: 'coach',
          content: 'Connection issue. Please verify your internet and API key.',
        ),
      ];
      state = state.copyWith(
        messages: withError,
        isTyping: false,
      );
      await _persistMessages(withError);
    }
  }

  /// Force refresh the insight
  Future<void> refreshInsight() async {
    state = const AiCoachState();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
    await generateInitialInsight();
  }

  /// Handle quick action chips
  Future<void> handleQuickAction(String action) async {
    switch (action) {
      case 'next_workout':
        await sendMessage('Based on my recent training, what should my next workout look like? Give me a specific suggestion.');
        break;
      case 'progress':
        await sendMessage('Am I making good progress? What patterns do you see in my recent workouts?');
        break;
      case 'recovery':
        await sendMessage('Any recovery tips based on my training frequency and intensity?');
        break;
      case 'motivation':
        await sendMessage('Give me a quick pre-workout pump-up. Let\'s get after it!');
        break;
    }
  }

  /// Call the Groq API with model fallbacks and error handling
  Future<String?> _callApi(String apiKey, String systemPrompt, List<Map<String, String>> messages) async {
    final cleanedKey = apiKey.trim().replaceAll('"', '').replaceAll("'", '');
    if (cleanedKey.isEmpty) return 'Error: Please set your Groq API key in Settings.';

    // Try primary model, fallback to larger model
    final models = ['openai/gpt-oss-20b', 'openai/gpt-oss-120b'];

    for (final model in models) {
      try {
        final response = await http.post(
          Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
          headers: {
            'Authorization': 'Bearer $cleanedKey',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'model': model,
            'messages': [
              {'role': 'system', 'content': systemPrompt},
              ...messages,
            ],
            'temperature': 0.7,
            'max_tokens': 350,
          }),
        ).timeout(const Duration(seconds: 15));

        if (response.statusCode == 200) {
          final data = jsonDecode(utf8.decode(response.bodyBytes));
          final content = data['choices']?[0]?['message']?['content']?.toString().trim();
          if (content != null && content.isNotEmpty) {
            return content;
          }
        } else if (response.statusCode == 401) {
          debugPrint('Groq 401 Unauthorized: ${response.body}');
          return 'Error: Invalid Groq API key. Please check or re-enter your key in Settings.';
        } else if (response.statusCode == 429) {
          debugPrint('Groq 429 Rate Limit: ${response.body}');
          return 'Error: Groq rate limit reached. Please wait a few seconds and try again.';
        } else if (response.statusCode == 404) {
          // Model not found — try fallback
          debugPrint('Groq 404 model not found for $model, trying fallback...');
          continue;
        } else {
          debugPrint('Groq error [${response.statusCode}]: ${response.body}');
        }
      } on TimeoutException {
        debugPrint('Groq request timed out on model $model');
        return 'Error: Connection timed out. Please check your internet connection.';
      } on SocketException {
        debugPrint('Groq SocketException on model $model');
        return 'Error: Unable to connect to internet. Please check your network connection.';
      } catch (e) {
        debugPrint('Groq call exception on $model: $e');
      }
    }
    return 'Error: Having trouble connecting right now. Please try again in a moment.';
  }

  /// Static tool to test a Groq API Key
  static Future<Map<String, dynamic>> testConnection(String rawApiKey) async {
    final cleaned = rawApiKey.trim().replaceAll('"', '').replaceAll("'", '');
    if (cleaned.isEmpty) {
      return {'success': false, 'error': 'API key cannot be empty'};
    }

    try {
      final response = await http.post(
        Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
        headers: {
          'Authorization': 'Bearer $cleaned',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'openai/gpt-oss-20b',
          'messages': [
            {'role': 'user', 'content': 'ping'},
          ],
          'max_tokens': 5,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return {'success': true, 'model': 'openai/gpt-oss-20b'};
      } else if (response.statusCode == 401) {
        return {'success': false, 'error': 'Invalid API Key (401 Unauthorized)'};
      } else if (response.statusCode == 429) {
        return {'success': false, 'error': 'Rate Limit Exceeded — try again in a few seconds'};
      } else if (response.statusCode == 404) {
        return {'success': false, 'error': 'Model unavailable (404). Groq may have updated their models.'};
      } else {
        return {'success': false, 'error': 'HTTP ${response.statusCode}: ${response.body}'};
      }
    } on TimeoutException {
      return {'success': false, 'error': 'Request timed out (10s)'};
    } on SocketException {
      return {'success': false, 'error': 'No internet connection'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Build system prompt with athlete profile and workout data
  Future<String> _buildSystemPrompt() async {
    final userProfile = ref.read(userProfileProvider).valueOrNull;
    final historyLogs = ref.read(workoutHistoryProvider).valueOrNull ?? [];

    String userContext = '';
    if (userProfile != null) {
      userContext = '''
User Profile:
- Name: ${userProfile.model.displayName}
- Goal: ${userProfile.model.goal ?? 'General Fitness'}
- Experience Level: ${userProfile.model.experienceLevel ?? 'Intermediate'}
- Gender: ${userProfile.model.gender ?? 'Not specified'}
- Age: ${userProfile.model.age != null ? '${userProfile.model.age}' : 'Not set'}
- Height: ${userProfile.model.height != null ? '${userProfile.model.height} cm' : 'Not set'}
- Weight: ${userProfile.model.weight != null ? '${userProfile.model.weight} kg' : 'Not set'}
''';

      if (userProfile.model.questionnaire != null && userProfile.model.questionnaire!.isNotEmpty) {
        userContext += '\nPersonalized Assessment Answers:\n';
        userProfile.model.questionnaire!.forEach((key, value) {
          userContext += '- $key: $value\n';
        });
      }
    }

    String workoutContext = '';
    if (historyLogs.isNotEmpty) {
      final recentWorkouts = historyLogs.take(5).map((log) {
        final duration = log.endTime.difference(log.startTime);
        final exercises = log.exercises.map((e) {
          final completedSets = e.sets.where((s) => s.completed).length;
          final topWeight = e.sets.where((s) => s.completed).fold<double>(0.0, (max, s) => s.weight > max ? s.weight : max);
          return '${e.exerciseName} ($completedSets sets, max ${topWeight}kg)';
        }).join(', ');
        return '• ${log.name} on ${log.startTime.toString().split(' ')[0]} (${duration.inMinutes}min): $exercises';
      }).join('\n');

      final totalWorkouts = historyLogs.length;
      final thisWeek = historyLogs.where((l) =>
        l.startTime.isAfter(DateTime.now().subtract(const Duration(days: 7)))
      ).length;

      workoutContext = '''
Workout History ($totalWorkouts total, $thisWeek this week):
$recentWorkouts
''';
    }

    return '''You are a friendly, knowledgeable fitness coach named "Coach". You're like a gym buddy who happens to be an expert — warm, encouraging, and straight-talking.

PERSONALITY RULES:
- Be concise. Max 2-3 sentences per response unless the user explicitly asks for detailed routines.
- Use the user's name naturally.
- Reference their actual workout data when giving advice.
- Celebrate PRs and consistency.
- Sound like a real gym coach, conversational and encouraging.
- Never use markdown bullet points in brief chat. Keep it natural.

ADAPT TO EXPERIENCE LEVEL:
- If Beginner: Use simple terms. Focus on habit building, form basics, and steady progression. 
- If Intermediate: Talk about progressive overload, varied rep ranges, and plateau breaking.
- If Veteran: Use advanced terminology (periodization, RPE, supersets). Focus on optimization, analytics, and peak performance.

$userContext
$workoutContext''';
  }

  String _buildInitialPrompt() {
    return 'Give me a brief, personalized training insight based on my recent workouts. If I have workout history, comment on something specific (a PR, consistency, a pattern you notice). If no history, give a warm welcome and motivate me to get started. Keep it to 2-3 sentences max.';
  }

  void _generateOfflineTips() {
    final historyLogs = ref.read(workoutHistoryProvider).valueOrNull ?? [];

    String tip;
    if (historyLogs.isEmpty) {
      tip = 'Welcome! Create your first routine and start tracking your progress. Consistency is the #1 predictor of results — let\'s build that habit. 💪';
    } else {
      final thisWeek = historyLogs.where((l) =>
        l.startTime.isAfter(DateTime.now().subtract(const Duration(days: 7)))
      ).length;

      final totalVolume = historyLogs.take(3).fold<double>(0, (sum, log) => sum + log.totalVolume);

      if (thisWeek >= 4) {
        tip = 'You\'ve trained $thisWeek times this week — impressive dedication! Make sure you\'re getting enough rest between sessions to maximize gains.';
      } else if (thisWeek >= 2) {
        tip = '$thisWeek sessions this week — solid consistency! You moved ${totalVolume.toInt()}kg of total volume in your recent workouts. Keep pushing!';
      } else if (thisWeek == 1) {
        tip = 'Good start with $thisWeek session this week. Try to hit 3-4 sessions for optimal progress. Every rep counts!';
      } else {
        tip = 'Haven\'t trained this week yet? No worries — today is a perfect day to get back in. Your last workout was great, let\'s build on it!';
      }
    }

    final newMessages = [CoachMessage(role: 'coach', content: tip)];
    state = AiCoachState(
      messages: newMessages,
      isTyping: false,
      lastFetched: DateTime.now(),
    );
    _persistMessages(newMessages);
  }
}

final aiCoachProvider = StateNotifierProvider<AiCoachNotifier, AiCoachState>((ref) {
  return AiCoachNotifier(ref);
});

final aiInsightsProvider = Provider<AsyncValue<String?>>((ref) {
  final coachState = ref.watch(aiCoachProvider);
  if (coachState.isTyping) return const AsyncValue.loading();
  if (coachState.error != null) return AsyncValue.error(coachState.error!, StackTrace.current);
  final lastCoachMessage = coachState.messages.where((m) => m.isCoach).lastOrNull;
  return AsyncValue.data(lastCoachMessage?.content);
});
