import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/coach_message_model.dart';
import '../models/chat_session_model.dart';
import '../providers/user_provider.dart';
import '../providers/history_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/goals_provider.dart';
import '../providers/active_workout_provider.dart';
import '../providers/wearable_provider.dart';
import '../providers/weekly_schedule_provider.dart';
import '../providers/body_measurement_provider.dart';

class AiCoachState {
  final List<ChatSession> sessions;
  final String activeSessionId;
  final List<CoachMessage> messages;
  final bool isTyping;
  final String? error;
  final DateTime? lastFetched;
  final Map<String, dynamic> contextSummary;

  const AiCoachState({
    this.sessions = const [],
    this.activeSessionId = '',
    this.messages = const [],
    this.isTyping = false,
    this.error,
    this.lastFetched,
    this.contextSummary = const {},
  });

  ChatSession? get activeSession {
    if (sessions.isEmpty) return null;
    return sessions.where((s) => s.id == activeSessionId).firstOrNull ?? sessions.first;
  }

  String get activeSessionTitle => activeSession?.title ?? 'Conversation';

  bool get hasMessages => messages.isNotEmpty;

  AiCoachState copyWith({
    List<ChatSession>? sessions,
    String? activeSessionId,
    List<CoachMessage>? messages,
    bool? isTyping,
    String? error,
    DateTime? lastFetched,
    Map<String, dynamic>? contextSummary,
  }) {
    return AiCoachState(
      sessions: sessions ?? this.sessions,
      activeSessionId: activeSessionId ?? this.activeSessionId,
      messages: messages ?? this.messages,
      isTyping: isTyping ?? this.isTyping,
      error: error,
      lastFetched: lastFetched ?? this.lastFetched,
      contextSummary: contextSummary ?? this.contextSummary,
    );
  }
}

class AiCoachNotifier extends StateNotifier<AiCoachState> {
  final Ref ref;
  static const String _sessionsKey = 'ai_coach_sessions_v2';
  static const String _activeSessionKey = 'ai_coach_active_session_id';
  static const String _legacyStorageKey = 'ai_coach_chat_history_v1';
  static const _uuid = Uuid();

  AiCoachNotifier(this.ref) : super(const AiCoachState()) {
    _initHistory();
  }

  /// Initialize local session history from on-device storage
  Future<void> _initHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionsJsonList = prefs.getStringList(_sessionsKey);
      String? savedActiveId = prefs.getString(_activeSessionKey);

      List<ChatSession> loadedSessions = [];

      if (sessionsJsonList != null && sessionsJsonList.isNotEmpty) {
        loadedSessions = sessionsJsonList
            .map((str) {
              try {
                return ChatSession.fromJson(str);
              } catch (_) {
                return null;
              }
            })
            .whereType<ChatSession>()
            .toList();
      }

      // Backward compatibility: Migrate legacy single-thread history if exists
      if (loadedSessions.isEmpty) {
        final legacyList = prefs.getStringList(_legacyStorageKey);
        if (legacyList != null && legacyList.isNotEmpty) {
          final legacyMessages = legacyList
              .map((str) {
                try {
                  return CoachMessage.fromJson(str);
                } catch (_) {
                  return null;
                }
              })
              .whereType<CoachMessage>()
              .toList();

          if (legacyMessages.isNotEmpty) {
            final migratedSession = ChatSession(
              id: _uuid.v4(),
              title: 'Previous Conversation',
              createdAt: legacyMessages.first.timestamp,
              updatedAt: legacyMessages.last.timestamp,
              messages: legacyMessages,
            );
            loadedSessions = [migratedSession];
            savedActiveId = migratedSession.id;
            await _persistSessions(loadedSessions, savedActiveId);
          }
        }
      }

      // If still empty, create an initial clean session
      if (loadedSessions.isEmpty) {
        final initialSession = ChatSession(
          id: _uuid.v4(),
          title: 'Training Insight',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          messages: [],
        );
        loadedSessions = [initialSession];
        savedActiveId = initialSession.id;
        await _persistSessions(loadedSessions, savedActiveId);
      }

      // Sort sessions by most recently updated first
      loadedSessions.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

      final activeSession = loadedSessions.firstWhere(
        (s) => s.id == savedActiveId,
        orElse: () => loadedSessions.first,
      );

      final summary = _buildQuickContextSummary();

      state = state.copyWith(
        sessions: loadedSessions,
        activeSessionId: activeSession.id,
        messages: activeSession.messages,
        contextSummary: summary,
      );

      // If active session has no messages, populate initial contextual insight
      if (activeSession.messages.isEmpty) {
        await generateInitialInsight();
      }
    } catch (e) {
      debugPrint('Error initializing local AI chat history: $e');
    }
  }

  /// Persist sessions 100% locally on device using SharedPreferences
  Future<void> _persistSessions(List<ChatSession> sessions, String activeId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = sessions.map((s) => s.toJson()).toList();
      await prefs.setStringList(_sessionsKey, encoded);
      await prefs.setString(_activeSessionKey, activeId);
    } catch (e) {
      debugPrint('Error saving local AI chat sessions: $e');
    }
  }

  /// Start a new chat conversation thread
  Future<void> startNewChat({String? initialTitle}) async {
    final newId = _uuid.v4();
    final newSession = ChatSession(
      id: newId,
      title: initialTitle ?? 'New Chat',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      messages: [],
    );

    final updatedSessions = [newSession, ...state.sessions];
    state = state.copyWith(
      sessions: updatedSessions,
      activeSessionId: newId,
      messages: [],
      error: null,
      contextSummary: _buildQuickContextSummary(),
    );

    await _persistSessions(updatedSessions, newId);
    await generateInitialInsight();
  }

  /// Switch into a previous chat session from local history
  Future<void> selectSession(String sessionId) async {
    final session = state.sessions.where((s) => s.id == sessionId).firstOrNull;
    if (session == null) return;

    state = state.copyWith(
      activeSessionId: session.id,
      messages: session.messages,
      error: null,
      contextSummary: _buildQuickContextSummary(),
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_activeSessionKey, session.id);
  }

  /// Delete a chat session from local storage
  Future<void> deleteSession(String sessionId) async {
    final remaining = state.sessions.where((s) => s.id != sessionId).toList();

    if (remaining.isEmpty) {
      final fresh = ChatSession(
        id: _uuid.v4(),
        title: 'New Chat',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        messages: [],
      );
      state = state.copyWith(
        sessions: [fresh],
        activeSessionId: fresh.id,
        messages: [],
      );
      await _persistSessions([fresh], fresh.id);
      await generateInitialInsight();
      return;
    }

    final newActiveId = (state.activeSessionId == sessionId)
        ? remaining.first.id
        : state.activeSessionId;

    final activeSession = remaining.firstWhere((s) => s.id == newActiveId);

    state = state.copyWith(
      sessions: remaining,
      activeSessionId: newActiveId,
      messages: activeSession.messages,
    );

    await _persistSessions(remaining, newActiveId);
  }

  /// Rename a chat session title
  Future<void> renameSession(String sessionId, String newTitle) async {
    if (newTitle.trim().isEmpty) return;

    final updatedSessions = state.sessions.map((s) {
      if (s.id == sessionId) {
        return s.copyWith(title: newTitle.trim(), updatedAt: DateTime.now());
      }
      return s;
    }).toList();

    state = state.copyWith(sessions: updatedSessions);
    await _persistSessions(updatedSessions, state.activeSessionId);
  }

  /// Clear all saved chat history locally
  Future<void> clearChatHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_sessionsKey);
      await prefs.remove(_activeSessionKey);
      await prefs.remove(_legacyStorageKey);

      final fresh = ChatSession(
        id: _uuid.v4(),
        title: 'Training Insight',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        messages: [],
      );

      state = AiCoachState(
        sessions: [fresh],
        activeSessionId: fresh.id,
        messages: [],
        contextSummary: _buildQuickContextSummary(),
      );

      await _persistSessions([fresh], fresh.id);
      await generateInitialInsight();
    } catch (e) {
      debugPrint('Error clearing chat history: $e');
    }
  }

  /// Quick summary of athlete context metrics for UI badge
  Map<String, dynamic> _buildQuickContextSummary() {
    final historyLogs = ref.read(workoutHistoryProvider).valueOrNull ?? [];
    final active = ref.read(activeWorkoutProvider);
    final wearable = ref.read(wearableProvider);
    final user = ref.read(userProfileProvider).valueOrNull;
    final hasActive = active.log != null;

    return {
      'totalWorkouts': historyLogs.length,
      'hasActiveWorkout': hasActive,
      'activeWorkoutName': hasActive ? active.log!.name : null,
      'wearableConnected': wearable.isConnected,
      'watchName': wearable.watchName,
      'heartRate': wearable.currentBpm,
      'goal': user?.model.goal ?? 'Strength & Fitness',
      'athleteName': user?.model.displayName ?? 'Athlete',
    };
  }

  /// Generate initial coaching insight
  Future<void> generateInitialInsight() async {
    if (state.isTyping) return;

    final apiKey = ref.read(settingsProvider).groqApiKey.trim().replaceAll('"', '').replaceAll("'", '');
    if (apiKey.isEmpty) {
      if (state.messages.isEmpty) {
        _generateOfflineTips();
      }
      return;
    }

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
        _updateActiveSessionMessages(newMessages);
      } else {
        _generateOfflineTips();
      }
    } catch (e) {
      _generateOfflineTips();
    }
  }

  /// Send a message from the user and stream/await Coach reply
  Future<void> sendMessage(String userMessage) async {
    final cleanInput = userMessage.trim();
    if (state.isTyping || cleanInput.isEmpty) return;

    final apiKey = ref.read(settingsProvider).groqApiKey.trim().replaceAll('"', '').replaceAll("'", '');
    if (apiKey.isEmpty) {
      final updated = [
        ...state.messages,
        CoachMessage(role: 'user', content: cleanInput),
        CoachMessage(
          role: 'coach',
          content: 'Add your free Groq API key in **Settings > AI Coach** to unlock live, personalized coaching tailored to your workouts!',
        ),
      ];
      _updateActiveSessionMessages(updated, autoTitleFrom: cleanInput);
      return;
    }

    // Add user message immediately
    final updatedMessages = [
      ...state.messages,
      CoachMessage(role: 'user', content: cleanInput),
    ];
    _updateActiveSessionMessages(updatedMessages, isTyping: true, autoTitleFrom: cleanInput);

    try {
      final systemPrompt = await _buildSystemPrompt();

      // Keep last 10 messages for multi-turn conversation depth
      final recentMessages = updatedMessages.length > 10
          ? updatedMessages.sublist(updatedMessages.length - 10)
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
        _updateActiveSessionMessages(withReply, isTyping: false);
      } else {
        final errorMsg = response != null && response.startsWith('Error:')
            ? response.replaceFirst('Error:', '').trim()
            : 'Having trouble reaching Coach right now. Please check your connection and try again.';

        final withError = [
          ...state.messages,
          CoachMessage(role: 'coach', content: errorMsg),
        ];
        _updateActiveSessionMessages(withError, isTyping: false);
      }
    } catch (e) {
      final withError = [
        ...state.messages,
        CoachMessage(
          role: 'coach',
          content: 'Network connection issue. Please verify your internet and API key.',
        ),
      ];
      _updateActiveSessionMessages(withError, isTyping: false);
    }
  }

  /// Internal helper to update active session messages, update title, and persist
  void _updateActiveSessionMessages(
    List<CoachMessage> newMessages, {
    bool isTyping = false,
    String? autoTitleFrom,
  }) {
    final activeId = state.activeSessionId;
    final updatedSessions = state.sessions.map((session) {
      if (session.id == activeId) {
        String title = session.title;
        // Auto-generate a readable title if currently "New Chat" or "Training Insight"
        if ((title == 'New Chat' || title == 'Training Insight') && autoTitleFrom != null) {
          title = _generateSmartTitle(autoTitleFrom);
        }
        return session.copyWith(
          title: title,
          messages: newMessages,
          updatedAt: DateTime.now(),
        );
      }
      return session;
    }).toList();

    // Keep active session at the top
    updatedSessions.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    state = state.copyWith(
      sessions: updatedSessions,
      messages: newMessages,
      isTyping: isTyping,
      lastFetched: DateTime.now(),
      contextSummary: _buildQuickContextSummary(),
    );

    _persistSessions(updatedSessions, activeId);
  }

  /// Auto-generate a short, relevant title from the user prompt
  String _generateSmartTitle(String prompt) {
    final cleaned = prompt.replaceAll(RegExp(r'[^a-zA-Z0-9\s]'), '').trim();
    final words = cleaned.split(RegExp(r'\s+'));
    if (words.length <= 4) {
      return words.map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '').join(' ');
    }
    return words.take(4).map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '').join(' ');
  }

  /// Force refresh the insight
  Future<void> refreshInsight() async {
    await generateInitialInsight();
  }

  /// Quick action chips
  Future<void> handleQuickAction(String action) async {
    switch (action) {
      case 'next_workout':
        await sendMessage('Based on my recent training split and recovered muscle groups, what should my next workout look like?');
        break;
      case 'progress':
        await sendMessage('Analyze my recent workout volume and PRs. Am I making progressive overload gains?');
        break;
      case 'recovery':
        await sendMessage('How is my recovery looking based on my recent training frequency and Galaxy Watch heart rate?');
        break;
      case 'form_sub':
        await sendMessage('What are the best accessory exercises or substitutions for my primary lifts?');
        break;
      case 'motivation':
        await sendMessage('Give me a high-energy pre-workout pump-up. Let\'s crush today\'s session!');
        break;
    }
  }

  /// Call Groq API with modern model suite
  Future<String?> _callApi(String apiKey, String systemPrompt, List<Map<String, String>> messages) async {
    final cleanedKey = apiKey.trim().replaceAll('"', '').replaceAll("'", '');
    if (cleanedKey.isEmpty) return 'Error: Please set your Groq API key in Settings.';

    // Fast, highly capable LLMs supported on Groq
    final models = [
      'llama-3.3-70b-versatile',
      'llama-3.1-8b-instant',
      'llama3-8b-8192',
      'openai/gpt-oss-20b',
    ];

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
            'max_tokens': 500,
          }),
        ).timeout(const Duration(seconds: 18));

        if (response.statusCode == 200) {
          final data = jsonDecode(utf8.decode(response.bodyBytes));
          final content = data['choices']?[0]?['message']?['content']?.toString().trim();
          if (content != null && content.isNotEmpty) {
            return content;
          }
        } else if (response.statusCode == 401) {
          return 'Error: Invalid Groq API key. Please check your key in Settings.';
        } else if (response.statusCode == 429) {
          return 'Error: Groq rate limit reached. Please wait a few seconds and try again.';
        } else if (response.statusCode == 404) {
          continue; // Try next fallback model
        }
      } on TimeoutException {
        continue;
      } on SocketException {
        return 'Error: Unable to connect to internet. Please check your network connection.';
      } catch (e) {
        debugPrint('Groq call exception on $model: $e');
      }
    }
    return 'Error: Unable to connect to AI Coach. Please verify your internet and API key in Settings.';
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
          'model': 'llama-3.1-8b-instant',
          'messages': [
            {'role': 'user', 'content': 'ping'},
          ],
          'max_tokens': 5,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return {'success': true, 'model': 'llama-3.1-8b-instant'};
      } else if (response.statusCode == 401) {
        return {'success': false, 'error': 'Invalid API Key (401 Unauthorized)'};
      } else if (response.statusCode == 429) {
        return {'success': false, 'error': 'Rate Limit Exceeded — try again in a few seconds'};
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

  /// Comprehensive contextual data injection for Coach
  Future<String> _buildSystemPrompt() async {
    final userProfile = ref.read(userProfileProvider).valueOrNull;
    final historyLogs = ref.read(workoutHistoryProvider).valueOrNull ?? [];
    final activeWorkout = ref.read(activeWorkoutProvider);
    final goals = ref.read(weeklyGoalsProvider);
    final wearable = ref.read(wearableProvider);
    final weeklySchedule = ref.read(weeklyScheduleProvider);
    final bodyMeasurements = ref.read(bodyMeasurementProvider).valueOrNull ?? [];

    final now = DateTime.now();
    final dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final currentDayName = dayNames[now.weekday - 1];
    final formattedTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    // 1. Athlete Demographics & Goals
    String userContext = 'ATHLETE PROFILE:\n';
    if (userProfile != null) {
      userContext += '''- Name: ${userProfile.model.displayName}
- Primary Goal: ${userProfile.model.goal ?? 'Strength & Muscle Gain'}
- Experience Level: ${userProfile.model.experienceLevel ?? 'Intermediate'}
- Gender: ${userProfile.model.gender ?? 'Not specified'}
- Age: ${userProfile.model.age ?? 'Not set'}
- Height: ${userProfile.model.height != null ? '${userProfile.model.height} cm' : 'Not set'}
- Body Weight: ${userProfile.model.weight != null ? '${userProfile.model.weight} kg' : 'Not set'}
''';
      if (userProfile.model.questionnaire != null && userProfile.model.questionnaire!.isNotEmpty) {
        userContext += 'Questionnaire Assessments:\n';
        userProfile.model.questionnaire!.forEach((k, v) {
          userContext += '  • $k: $v\n';
        });
      }
    } else {
      userContext += '- Name: Athlete\n- Experience: Intermediate\n';
    }

    // 2. Real-time Live Workout Awareness
    String liveWorkoutContext = 'LIVE WORKOUT STATE:\n';
    if (activeWorkout.log != null) {
      final log = activeWorkout.log!;
      final elapsedMin = activeWorkout.elapsedTime.inMinutes;
      final activeEx = log.exercises.where((e) => e.sets.any((s) => !s.completed)).firstOrNull ?? log.exercises.lastOrNull;
      final currentExName = activeEx?.exerciseName ?? 'Active Routine';
      final currentSet = activeEx?.sets.where((s) => !s.completed).firstOrNull ?? activeEx?.sets.lastOrNull;
      final setIndex = (activeEx != null && currentSet != null) ? (activeEx.sets.indexOf(currentSet) + 1) : 1;
      final totalSets = activeEx?.sets.length ?? 1;
      final targetWeight = currentSet?.weight ?? 0.0;
      final targetReps = currentSet?.reps ?? 0;

      liveWorkoutContext += '''- STATUS: ATHLETE IS CURRENTLY IN THE GYM WORKING OUT RIGHT NOW!
- Active Routine: "${log.name}"
- Elapsed Duration: $elapsedMin minutes
- Current Exercise: $currentExName
- Current Set: Set $setIndex of $totalSets
- Target: ${targetWeight}kg × $targetReps reps
*Note: Give immediate, concise, and actionable guidance if asked about form, rest, fatigue, or exercise swaps during this active session.*
''';
    } else {
      liveWorkoutContext += '- STATUS: Rest / Outside gym (No active workout currently running).\n';
    }

    // 3. Wearable & Heart Rate Health
    String wearableContext = 'WEARABLE SENSORS & HEART RATE:\n';
    if (wearable.isConnected) {
      wearableContext += '''- Wearable Device: Connected (${wearable.watchName.isNotEmpty ? wearable.watchName : 'Samsung Galaxy Watch'})
- Live Heart Rate: ${wearable.currentBpm != null ? '${wearable.currentBpm} BPM' : 'Active monitoring'}
- Average Workout BPM: ${wearable.averageBpm > 0 ? '${wearable.averageBpm} BPM' : 'N/A'}
- Peak Workout BPM: ${wearable.maxBpm > 0 ? '${wearable.maxBpm} BPM' : 'N/A'}
''';
    } else {
      wearableContext += '- Wearable Device: Disconnected / Standalone phone mode.\n';
    }

    // 4. Workout History & Recent Performance (Last 7 Sessions)
    String historyContext = 'RECENT WORKOUT PERFORMANCE (LAST 7 SESSIONS):\n';
    final recentLogs = historyLogs.take(7).toList();
    if (recentLogs.isNotEmpty) {
      for (final log in recentLogs) {
        final duration = log.endTime.difference(log.startTime).inMinutes;
        final exSummary = log.exercises.map((e) {
          final compSets = e.sets.where((s) => s.completed).length;
          final topW = e.sets.where((s) => s.completed).fold<double>(0.0, (m, s) => s.weight > m ? s.weight : m);
          return '${e.exerciseName} ($compSets sets, max ${topW}kg)';
        }).join(', ');
        historyContext += '• [${log.startTime.toString().split(' ')[0]}] ${log.name} (${duration}m, ${log.totalVolume.toInt()}kg volume): $exSummary\n';
      }
    } else {
      historyContext += '- No logged workouts yet. Athlete is just starting their journey.\n';
    }

    // 5. Volume, Streaks & Adherence
    final thisWeekLogs = historyLogs.where((l) =>
      l.startTime.isAfter(now.subtract(const Duration(days: 7)))
    ).toList();
    final thisWeekVolume = thisWeekLogs.fold<double>(0.0, (sum, l) => sum + l.totalVolume);
    final targetWorkouts = goals.targetWorkoutsPerWeek;

    String adherenceContext = '''WEEKLY ADHERENCE & VOLUME:
- Current Time: $currentDayName at $formattedTime
- Lifetime Workouts Logged: ${historyLogs.length}
- Workouts This Week: ${thisWeekLogs.length} of $targetWorkouts goal
- Total Volume Lifted This Week: ${thisWeekVolume.toInt()} kg
''';

    // 6. Muscle Group Distribution & Recovery Status (Last 14 Days)
    final Map<String, int> muscleSets = {};
    final fourteenDaysAgo = now.subtract(const Duration(days: 14));
    final twoDaysAgo = now.subtract(const Duration(days: 2));
    final List<String> recentMuscles = [];

    for (final log in historyLogs.where((l) => l.startTime.isAfter(fourteenDaysAgo))) {
      final isVeryRecent = log.startTime.isAfter(twoDaysAgo);
      for (final ex in log.exercises) {
        final compSets = ex.sets.where((s) => s.completed).length;
        final group = _inferMuscleGroup(ex.exerciseName);
        muscleSets[group] = (muscleSets[group] ?? 0) + compSets;
        if (isVeryRecent && !recentMuscles.contains(group)) {
          recentMuscles.add(group);
        }
      }
    }

    String muscleContext = 'MUSCLE GROUP BALANCE & FATIGUE (PAST 14 DAYS):\n';
    if (muscleSets.isNotEmpty) {
      muscleSets.forEach((muscle, sets) {
        muscleContext += '- $muscle: $sets total sets\n';
      });
      if (recentMuscles.isNotEmpty) {
        muscleContext += '⚠️ Recently trained (<48 hours, likely fatigued): ${recentMuscles.join(', ')}\n';
      }
    } else {
      muscleContext += '- No muscle volume data in the past 14 days.\n';
    }

    // 7. All-Time Personal Records (PRs)
    final Map<String, double> prMap = {};
    for (final log in historyLogs) {
      for (final ex in log.exercises) {
        for (final s in ex.sets) {
          if (s.completed && s.weight > 0) {
            final curMax = prMap[ex.exerciseName] ?? 0.0;
            if (s.weight > curMax) {
              prMap[ex.exerciseName] = s.weight;
            }
          }
        }
      }
    }

    String prContext = 'TOP ALL-TIME PERSONAL RECORDS (PRs):\n';
    if (prMap.isNotEmpty) {
      final sortedPrs = prMap.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
      for (final entry in sortedPrs.take(6)) {
        prContext += '🏆 ${entry.key}: ${entry.value} kg\n';
      }
    } else {
      prContext += '- No PRs logged yet.\n';
    }

    // 8. Body Weight Trend
    String bodyWeightContext = '';
    if (bodyMeasurements.isNotEmpty) {
      final latestM = bodyMeasurements.first;
      bodyWeightContext = 'BODY MEASUREMENTS:\n- Latest Weight: ${latestM.bodyWeight ?? "N/A"} kg on ${latestM.date.toString().split(" ")[0]}\n';
    }

    // 9. Today's Scheduled Routine
    final todayRoutines = weeklySchedule[now.weekday] ?? [];
    String scheduleContext = 'WEEKLY SCHEDULE:\n- Today ($currentDayName): ${todayRoutines.isNotEmpty ? "Scheduled routine planned" : "Rest or flexible training day"}\n';

    return '''You are "Coach AV", an elite, supportive, science-grounded Strength & Conditioning Fitness Coach embedded in the AV Fitness mobile app.

COACHING PRINCIPLES:
1. DEEP CONTEXT AWARENESS: You have full access to the athlete's real gym data below. ALWAYS tailor your answers specifically to their actual workouts, PRs, muscle fatigue, and schedule.
2. PERSONALIZED GUIDANCE: Mention their exercises, weights, and consistency numbers naturally.
3. CONVERSATIONAL YET STRUCTURED:
   - For quick questions: Give concise, direct answers (2-4 sentences).
   - For routine suggestions, form checks, or program design: Provide clear, structured bullet points with bold exercises (`**Bench Press**`), sets, reps, and rest intervals.
4. IN-WORKOUT ASSISTANCE: If the athlete is currently in an active workout, prioritize quick tips, form cues, or smart exercise substitutions for the specific movement they are doing right now.
5. CELEBRATE & MOTIVATE: Acknowledge PRs, praise consistency streaks, and motivate them with genuine energy.

══════════════════════════════════════════════════
REAL-TIME ATHLETE DATA:
$userContext
$liveWorkoutContext
$wearableContext
$adherenceContext
$historyContext
$muscleContext
$prContext
$bodyWeightContext
$scheduleContext
══════════════════════════════════════════════════''';
  }

  String _inferMuscleGroup(String exerciseName) {
    final lower = exerciseName.toLowerCase();
    if (lower.contains('bench') || lower.contains('chest') || lower.contains('push-up') || lower.contains('fly')) return 'Chest';
    if (lower.contains('pull') || lower.contains('row') || lower.contains('lat') || lower.contains('deadlift') || lower.contains('chin')) return 'Back';
    if (lower.contains('squat') || lower.contains('leg press') || lower.contains('quad') || lower.contains('lunge')) return 'Quads / Legs';
    if (lower.contains('curl') || lower.contains('bicep')) return 'Biceps';
    if (lower.contains('tricep') || lower.contains('dip') || lower.contains('skull')) return 'Triceps';
    if (lower.contains('press') || lower.contains('shoulder') || lower.contains('lateral') || lower.contains('delt')) return 'Shoulders';
    if (lower.contains('calf') || lower.contains('calves')) return 'Calves';
    if (lower.contains('hamstring') || lower.contains('rdl')) return 'Hamstrings';
    if (lower.contains('ab') || lower.contains('plank') || lower.contains('crunch')) return 'Core';
    return 'Full Body';
  }

  String _buildInitialPrompt() {
    return 'Give me a brief, personalized coaching greeting and training insight based on my recent training data. Highlight a specific pattern, PR, or consistency milestone. Keep it friendly, encouraging, and under 3 sentences.';
  }

  void _generateOfflineTips() {
    final historyLogs = ref.read(workoutHistoryProvider).valueOrNull ?? [];
    final goals = ref.read(weeklyGoalsProvider);

    String tip;
    if (historyLogs.isEmpty) {
      tip = 'Welcome to **AV Fitness**! Create your first routine and start logging your sets. Consistency is the foundation of all progress — let\'s get after it! 💪';
    } else {
      final thisWeek = historyLogs.where((l) =>
        l.startTime.isAfter(DateTime.now().subtract(const Duration(days: 7)))
      ).length;
      final totalVolume = historyLogs.take(3).fold<double>(0, (sum, log) => sum + log.totalVolume);

      if (thisWeek >= goals.targetWorkoutsPerWeek) {
        tip = 'You\'ve hit **$thisWeek workouts this week**, crushing your goal! Make sure you prioritize sleep and protein intake to lock in those gains.';
      } else if (thisWeek >= 2) {
        tip = 'Solid consistency with **$thisWeek sessions** this week and **${totalVolume.toInt()}kg** of volume moved in your recent workouts. Keep that momentum going!';
      } else {
        tip = 'Ready for your next session? Today is a great day to train. Let\'s build on your last workout!';
      }
    }

    final newMessages = [CoachMessage(role: 'coach', content: tip)];
    _updateActiveSessionMessages(newMessages);
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
