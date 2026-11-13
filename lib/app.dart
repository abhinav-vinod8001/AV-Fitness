import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/routes.dart';
import 'providers/settings_provider.dart';
import 'providers/active_workout_provider.dart';
import 'providers/weekly_schedule_provider.dart';
import 'core/services/local_notifications_service.dart';
import 'core/services/live_activity_service.dart';

class FitnessApp extends ConsumerStatefulWidget {
  const FitnessApp({super.key});

  @override
  ConsumerState<FitnessApp> createState() => _FitnessAppState();
}

class _FitnessAppState extends ConsumerState<FitnessApp> with WidgetsBindingObserver {
  bool _restorationAttempted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    LiveActivityService.initialize(
      onQuickAction: (action) {
        if (mounted) {
          _handleQuickAction(action);
        }
      },
    );
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _restoreWorkoutIfNeeded();
      final initialAction = await LiveActivityService.getInitialQuickAction();
      if (initialAction != null && mounted) {
        _handleQuickAction(initialAction);
      }
    });
  }

  Future<void> _handleQuickAction(String action) async {
    final router = ref.read(routerProvider);
    if (action == 'quick_workout') {
      final active = ref.read(activeWorkoutProvider);
      if (active.log == null) {
        await ref.read(activeWorkoutProvider.notifier).startQuickWorkout();
      }
      router.push('/workouts/active');
    } else if (action == 'history') {
      router.go('/history');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _restoreWorkoutIfNeeded() async {
    if (_restorationAttempted) return;
    _restorationAttempted = true;
    await ref.read(activeWorkoutProvider.notifier).restoreWorkoutIfAvailable();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        ref.read(activeWorkoutProvider.notifier).forceSave();
        break;
      case AppLifecycleState.resumed:
        break;
      case AppLifecycleState.detached:
        ref.read(activeWorkoutProvider.notifier).forceSave();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final router = ref.watch(routerProvider);

    // Listen to changes in the daily workout schedule and update OS-level push notifications
    ref.listen(dailyWorkoutNamesProvider, (previous, next) {
      LocalNotificationsService().scheduleDailyWorkoutReminders(next);
    });

    return MaterialApp.router(
      title: 'AV Fitness',
      theme: AppTheme.lightTheme(settings.seedColor),
      darkTheme: AppTheme.darkTheme(settings.seedColor),
      themeMode: settings.themeMode,
      themeAnimationDuration: const Duration(milliseconds: 350),
      themeAnimationCurve: Curves.easeOutCubic,
      routerConfig: router,
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      ),
    );
  }
}
