import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'history_provider.dart';
import '../models/workout_log_model.dart';

enum NotificationType {
  streak,
  pr,
  reminder,
  recovery,
  insight,
}

class FitnessNotification {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final NotificationType type;
  final bool isRead;
  final String? actionRoute;
  final String? actionLabel;

  const FitnessNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.type,
    this.isRead = false,
    this.actionRoute,
    this.actionLabel,
  });

  FitnessNotification copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? timestamp,
    NotificationType? type,
    bool? isRead,
    String? actionRoute,
    String? actionLabel,
  }) {
    return FitnessNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      actionRoute: actionRoute ?? this.actionRoute,
      actionLabel: actionLabel ?? this.actionLabel,
    );
  }
}

class NotificationPreferences {
  final bool dailyReminders;
  final bool prCelebrations;
  final bool recoveryTips;
  final bool weeklySummary;

  const NotificationPreferences({
    this.dailyReminders = true,
    this.prCelebrations = true,
    this.recoveryTips = true,
    this.weeklySummary = true,
  });

  NotificationPreferences copyWith({
    bool? dailyReminders,
    bool? prCelebrations,
    bool? recoveryTips,
    bool? weeklySummary,
  }) {
    return NotificationPreferences(
      dailyReminders: dailyReminders ?? this.dailyReminders,
      prCelebrations: prCelebrations ?? this.prCelebrations,
      recoveryTips: recoveryTips ?? this.recoveryTips,
      weeklySummary: weeklySummary ?? this.weeklySummary,
    );
  }
}

class NotificationsState {
  final List<FitnessNotification> notifications;
  final NotificationPreferences preferences;
  final bool isLoading;

  const NotificationsState({
    this.notifications = const [],
    this.preferences = const NotificationPreferences(),
    this.isLoading = false,
  });

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  NotificationsState copyWith({
    List<FitnessNotification>? notifications,
    NotificationPreferences? preferences,
    bool? isLoading,
  }) {
    return NotificationsState(
      notifications: notifications ?? this.notifications,
      preferences: preferences ?? this.preferences,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class NotificationsNotifier extends StateNotifier<NotificationsState> {
  final Ref _ref;
  static const _readKey = 'read_notification_ids';
  static const _clearedKey = 'cleared_notification_ids';
  static const _prefsKey = 'notification_user_prefs';

  NotificationsNotifier(this._ref) : super(const NotificationsState(isLoading: true)) {
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load preferences
    final prefsJson = prefs.getString(_prefsKey);
    NotificationPreferences userPrefs = const NotificationPreferences();
    if (prefsJson != null) {
      try {
        final map = jsonDecode(prefsJson) as Map<String, dynamic>;
        userPrefs = NotificationPreferences(
          dailyReminders: map['dailyReminders'] ?? true,
          prCelebrations: map['prCelebrations'] ?? true,
          recoveryTips: map['recoveryTips'] ?? true,
          weeklySummary: map['weeklySummary'] ?? true,
        );
      } catch (_) {}
    }

    final readIds = prefs.getStringList(_readKey)?.toSet() ?? <String>{};
    final clearedIds = prefs.getStringList(_clearedKey)?.toSet() ?? <String>{};

    // Watch history logs to generate smart contextual notifications
    final historyLogs = _ref.read(workoutHistoryProvider).valueOrNull ?? [];
    final generated = _generateSmartNotifications(historyLogs, readIds, clearedIds);

    state = NotificationsState(
      notifications: generated,
      preferences: userPrefs,
      isLoading: false,
    );
  }

  List<FitnessNotification> _generateSmartNotifications(
    List<WorkoutLog> logs,
    Set<String> readIds,
    Set<String> clearedIds,
  ) {
    final now = DateTime.now();
    final list = <FitnessNotification>[];

    // Notification 1: Consistency streak
    if (logs.isNotEmpty) {
      final lastLog = logs.first;
      final daysSince = now.difference(lastLog.endTime).inDays;
      if (daysSince == 0) {
        list.add(FitnessNotification(
          id: 'notif_streak_today',
          title: 'Crushed Today\'s Session! 🔥',
          message: 'Great job completing "${lastLog.name}". Recovery and sleep tonight are where muscle adapts.',
          timestamp: lastLog.endTime,
          type: NotificationType.streak,
          actionRoute: '/history',
          actionLabel: 'View Workout',
        ));
      } else if (daysSince >= 1 && daysSince <= 2) {
        list.add(FitnessNotification(
          id: 'notif_reminder_next',
          title: 'Time for Training! 💪',
          message: 'It has been $daysSince day${daysSince > 1 ? 's' : ''} since your last session. Keep your streak alive!',
          timestamp: now.subtract(const Duration(hours: 3)),
          type: NotificationType.reminder,
          actionRoute: '/workouts',
          actionLabel: 'Start Workout',
        ));
      } else {
        list.add(FitnessNotification(
          id: 'notif_reminder_comeback',
          title: 'Ready for a comeback? 🏋️',
          message: 'Your routine templates are ready. Pick one and log a workout today!',
          timestamp: now.subtract(const Duration(hours: 5)),
          type: NotificationType.reminder,
          actionRoute: '/workouts',
          actionLabel: 'View Routines',
        ));
      }
    } else {
      list.add(FitnessNotification(
        id: 'notif_welcome',
        title: 'Welcome to AV Fitness! 🎉',
        message: 'Create your first workout routine or tap "Start Empty Workout" to log your first lift.',
        timestamp: now.subtract(const Duration(minutes: 30)),
        type: NotificationType.insight,
        actionRoute: '/workouts',
        actionLabel: 'Create Routine',
      ));
    }

    // Notification: Weekly Recap
    if (now.weekday == DateTime.sunday && now.hour >= 10 && logs.isNotEmpty) {
      list.add(FitnessNotification(
        id: 'notif_weekly_recap_sun_10am',
        title: 'Weekly Recap is Ready! 📊',
        message: 'Your new AI-powered weekly insights are ready. Tap to view!',
        timestamp: DateTime(now.year, now.month, now.day, 10, 0),
        type: NotificationType.insight,
        actionRoute: '/recap',
        actionLabel: 'View Recap',
      ));
    }

    // Notification 2: PR & Milestone achievement
    if (logs.isNotEmpty) {
      double maxVol = 0;
      for (final l in logs) {
        if (l.totalVolume > maxVol) maxVol = l.totalVolume;
      }
      if (maxVol > 0) {
        list.add(FitnessNotification(
          id: 'notif_pr_volume',
          title: 'Volume Record Tracked! 🏆',
          message: 'Your highest recorded workout volume is ${(maxVol).toInt()} kg. Consistency drives progress!',
          timestamp: now.subtract(const Duration(days: 1, hours: 2)),
          type: NotificationType.pr,
          actionRoute: '/progress',
          actionLabel: 'Check Progress',
        ));
      }
    }

    // Notification 3: Recovery / Hydration tip
    list.add(FitnessNotification(
      id: 'notif_recovery_tip',
      title: 'Hydration & Mobility Tip 💧',
      message: 'Aim for 3-4 liters of water and 10 minutes of active mobility after strenuous resistance workouts.',
      timestamp: now.subtract(const Duration(days: 2, hours: 6)),
      type: NotificationType.recovery,
    ));

    // Notification 4: 1RM Calculator tip
    list.add(FitnessNotification(
      id: 'notif_1rm_tool',
      title: 'Calculate Your Percentages 🎯',
      message: 'Use the built-in 1RM tool under Profile to calculate your working sets from 65% to 95%.',
      timestamp: now.subtract(const Duration(days: 3, hours: 4)),
      type: NotificationType.insight,
      actionRoute: '/profile/1rm',
      actionLabel: 'Open 1RM Calc',
    ));

    // Filter out cleared notifications and apply read status
    return list
        .where((n) => !clearedIds.contains(n.id))
        .map((n) => n.copyWith(isRead: readIds.contains(n.id)))
        .toList();
  }

  Future<void> markAsRead(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final readIds = prefs.getStringList(_readKey)?.toSet() ?? <String>{};
    readIds.add(id);
    await prefs.setStringList(_readKey, readIds.toList());

    state = state.copyWith(
      notifications: state.notifications.map((n) {
        if (n.id == id) return n.copyWith(isRead: true);
        return n;
      }).toList(),
    );
  }

  Future<void> markAllAsRead() async {
    final prefs = await SharedPreferences.getInstance();
    final allIds = state.notifications.map((n) => n.id).toList();
    await prefs.setStringList(_readKey, allIds);

    state = state.copyWith(
      notifications: state.notifications.map((n) => n.copyWith(isRead: true)).toList(),
    );
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    final allIds = state.notifications.map((n) => n.id).toList();
    await prefs.setStringList(_clearedKey, allIds);

    state = state.copyWith(notifications: []);
  }

  Future<void> updatePreferences(NotificationPreferences newPrefs) async {
    final prefs = await SharedPreferences.getInstance();
    final map = {
      'dailyReminders': newPrefs.dailyReminders,
      'prCelebrations': newPrefs.prCelebrations,
      'recoveryTips': newPrefs.recoveryTips,
      'weeklySummary': newPrefs.weeklySummary,
    };
    await prefs.setString(_prefsKey, jsonEncode(map));
    state = state.copyWith(preferences: newPrefs);
  }
}

final notificationsProvider = StateNotifierProvider<NotificationsNotifier, NotificationsState>((ref) {
  return NotificationsNotifier(ref);
});
