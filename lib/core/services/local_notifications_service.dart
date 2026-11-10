import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/material.dart';

class LocalNotificationsService {
  static final LocalNotificationsService _instance = LocalNotificationsService._internal();
  factory LocalNotificationsService() => _instance;
  LocalNotificationsService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // Initialize timezone data
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap
      },
    );

    // Schedule the Sunday 10 AM notification
    await scheduleWeeklyRecapNotification();
  }

  Future<void> scheduleWeeklyRecapNotification() async {
    await flutterLocalNotificationsPlugin.cancel(id: 1001); // Cancel existing if any

    final scheduledDate = _nextInstanceOfSunday10AM();

    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'weekly_recap_channel',
      'Weekly Recap',
      channelDescription: 'Notifications for your AI Weekly Performance Recap',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id: 1001,
      title: 'Your Weekly Recap is Ready! 📊',
      body: 'Tap to see your AI-generated weekly performance summary and personalized suggestions.',
      scheduledDate: scheduledDate,
      notificationDetails: platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  tz.TZDateTime _nextInstanceOfSunday10AM() {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, 10, 0);

    // If today is Sunday and it's already past 10 AM, schedule for next week
    if (scheduledDate.weekday == DateTime.sunday && now.isAfter(scheduledDate)) {
      scheduledDate = scheduledDate.add(const Duration(days: 7));
    } else {
      // Find the next Sunday
      while (scheduledDate.weekday != DateTime.sunday) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }
    }
    return scheduledDate;
  }

  Future<void> scheduleDailyWorkoutReminders(Map<int, String> dailyWorkouts) async {
    // Cancel previous daily reminders (IDs 2001 to 2007)
    for (int i = 1; i <= 7; i++) {
      await flutterLocalNotificationsPlugin.cancel(id: 2000 + i);
    }

    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'daily_workout_channel',
      'Daily Workout Reminders',
      channelDescription: 'Reminders for your scheduled daily workouts',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

    for (final entry in dailyWorkouts.entries) {
      final weekday = entry.key;
      final workoutName = entry.value;

      final scheduledDate = _nextInstanceOfTimeAndDay(weekday, 16, 0); // 4 PM

      await flutterLocalNotificationsPlugin.zonedSchedule(
        id: 2000 + weekday,
        title: "It's $workoutName Day! 💪",
        body: "Are you ready for your workout?",
        scheduledDate: scheduledDate,
        notificationDetails: platformChannelSpecifics,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    }
  }

  tz.TZDateTime _nextInstanceOfTimeAndDay(int weekday, int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    if (scheduledDate.weekday == weekday && now.isAfter(scheduledDate)) {
      scheduledDate = scheduledDate.add(const Duration(days: 7));
    } else {
      while (scheduledDate.weekday != weekday) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }
    }
    return scheduledDate;
  }
}
