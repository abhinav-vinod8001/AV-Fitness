import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../screens/main_wrapper.dart';
import '../screens/home_screen.dart';
import '../screens/workouts_screen.dart';
import '../screens/history_screen.dart';
import '../screens/progress_screen.dart';
import '../screens/settings_screen.dart';
import '../widgets/fade_indexed_stack.dart';
import '../screens/profile_screen.dart';
import '../screens/edit_profile_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/onboarding_screen.dart';
import '../screens/splash_screen.dart';
import '../providers/user_provider.dart';
import 'utils/app_animations.dart';
import '../screens/exercises/exercises_screen.dart';
import '../screens/exercises/exercise_details_screen.dart';
import '../screens/exercises/create_exercise_screen.dart';
import '../screens/workouts/workout_builder_screen.dart';
import '../screens/workouts/select_exercises_screen.dart';
import '../screens/workouts/active_workout_screen.dart';
import '../screens/workouts/workout_summary_screen.dart';
import '../models/exercise_model.dart';
import '../models/workout_model.dart';
import '../models/workout_log_model.dart';
import '../screens/workouts/workout_detail_screen.dart';
import '../screens/calendar_screen.dart';
import '../screens/body_measurements_screen.dart';
import '../screens/achievements_screen.dart';
import '../screens/profile/ai_chat_history_screen.dart';
import '../screens/weekly_recap_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _homeNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'home');
final GlobalKey<NavigatorState> _workoutsNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'workouts');
final GlobalKey<NavigatorState> _historyNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'history');
final GlobalKey<NavigatorState> _progressNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'progress');
final GlobalKey<NavigatorState> _profileNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'profile');

final _routerRefreshNotifier = Provider<_RouterRefreshNotifier>((ref) {
  final notifier = _RouterRefreshNotifier();

  // Listen to auth state changes and notify the router to re-evaluate redirects
  ref.listen(authStateProvider, (prev, next) {
    notifier.notify();
  });
  ref.listen(userProfileProvider, (prev, next) {
    notifier.notify();
  });

  ref.onDispose(() => notifier.dispose());
  return notifier;
});

class _RouterRefreshNotifier extends ChangeNotifier {
  void notify() => notifyListeners();
}

final routerProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = ref.watch(_routerRefreshNotifier);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      final userProfileAsync = ref.read(userProfileProvider);

      final isLoggedIn = authState.valueOrNull != null;
      final isLoggingIn = state.matchedLocation == '/login';
      final isOnboarding = state.matchedLocation == '/onboarding';
      final isSplash = state.matchedLocation == '/splash';

      if (isSplash) return null; // Don't redirect out of splash screen early

      if (authState.isLoading) {
        return null; // Don't redirect while checking auth state
      }

      if (!isLoggedIn && !isLoggingIn) {
        return '/login';
      }

      if (isLoggedIn && isLoggingIn) {
        return '/home';
      }

      if (isLoggedIn) {
        if (userProfileAsync.isLoading) return null;
        
        final userProfile = userProfileAsync.valueOrNull;
        // If profile is loaded but missing height/weight, force onboarding
        if (userProfile != null && (userProfile.model.height == null || userProfile.model.weight == null)) {
          if (!isOnboarding) return '/onboarding';
        } else if (isOnboarding) {
          // If they have full profile, don't let them stay on onboarding
          return '/home';
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/recap',
        pageBuilder: (context, state) => AppAnimations.heroPage(
          key: state.pageKey,
          child: const WeeklyRecapScreen(),
        ),
      ),
      GoRoute(
        path: '/exercises',
        pageBuilder: (context, state) => AppAnimations.slidePage(
          key: state.pageKey,
          child: const ExercisesScreen(),
        ),
      ),
      GoRoute(
        path: '/exercises/details',
        pageBuilder: (context, state) {
          final exercise = state.extra as Exercise;
          return AppAnimations.slidePage(
            key: state.pageKey,
            child: ExerciseDetailsScreen(exercise: exercise),
          );
        },
      ),
      GoRoute(
        path: '/exercises/create',
        pageBuilder: (context, state) => AppAnimations.slidePage(
          key: state.pageKey,
          child: const CreateExerciseScreen(),
        ),
      ),
      GoRoute(
        path: '/workouts/build',
        pageBuilder: (context, state) {
          WorkoutTemplate? template;
          String? folderId;
          if (state.extra is WorkoutTemplate) {
            template = state.extra as WorkoutTemplate;
          } else if (state.extra is String) {
            folderId = state.extra as String;
          } else if (state.extra is Map<String, dynamic>) {
            final map = state.extra as Map<String, dynamic>;
            template = map['template'] as WorkoutTemplate?;
            folderId = map['folderId'] as String?;
          }
          return AppAnimations.slidePage(
            key: state.pageKey,
            child: WorkoutBuilderScreen(existingTemplate: template, initialFolderId: folderId),
          );
        },
      ),
      GoRoute(
        path: '/workouts/build/select-exercises',
        pageBuilder: (context, state) => AppAnimations.slidePage(
          key: state.pageKey,
          child: const SelectExercisesScreen(),
        ),
      ),
      GoRoute(
        path: '/workouts/active',
        pageBuilder: (context, state) => AppAnimations.heroPage(
          key: state.pageKey,
          child: const ActiveWorkoutScreen(),
        ),
      ),
      GoRoute(
        path: '/workouts/summary',
        pageBuilder: (context, state) {
          final log = state.extra as WorkoutLog;
          return AppAnimations.slidePage(
            key: state.pageKey,
            child: WorkoutSummaryScreen(log: log),
          );
        },
      ),
      GoRoute(
        path: '/history/detail',
        pageBuilder: (context, state) {
          final log = state.extra as WorkoutLog;
          return AppAnimations.slidePage(
            key: state.pageKey,
            child: WorkoutDetailScreen(log: log),
          );
        },
      ),
      StatefulShellRoute(
        builder: (context, state, navigationShell) {
          return MainWrapper(navigationShell: navigationShell);
        },
        navigatorContainerBuilder: (context, navigationShell, children) {
          return FadeIndexedStack(
            index: navigationShell.currentIndex,
            children: children,
          );
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: _homeNavigatorKey,
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _workoutsNavigatorKey,
            routes: [
              GoRoute(
                path: '/workouts',
                builder: (context, state) => const WorkoutsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _historyNavigatorKey,
            routes: [
              GoRoute(
                path: '/history',
                builder: (context, state) => const HistoryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _progressNavigatorKey,
            routes: [
              GoRoute(
                path: '/progress',
                builder: (context, state) => const ProgressScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _profileNavigatorKey,
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
                routes: [
                  GoRoute(
                    path: 'calendar',
                    parentNavigatorKey: _rootNavigatorKey,
                    pageBuilder: (context, state) => AppAnimations.slidePage(
                      key: state.pageKey,
                      child: const CalendarScreen(),
                    ),
                  ),
                  GoRoute(
                    path: 'statistics',
                    parentNavigatorKey: _rootNavigatorKey,
                    pageBuilder: (context, state) => AppAnimations.slidePage(
                      key: state.pageKey,
                      child: const ProgressScreen(),
                    ),
                  ),
                  GoRoute(
                    path: 'body-measurements',
                    parentNavigatorKey: _rootNavigatorKey,
                    pageBuilder: (context, state) => AppAnimations.slidePage(
                      key: state.pageKey,
                      child: const BodyMeasurementsScreen(),
                    ),
                  ),
                  GoRoute(
                    path: 'achievements',
                    parentNavigatorKey: _rootNavigatorKey,
                    pageBuilder: (context, state) => AppAnimations.slidePage(
                      key: state.pageKey,
                      child: const AchievementsScreen(),
                    ),
                  ),
                  GoRoute(
                    path: 'ai-history',
                    parentNavigatorKey: _rootNavigatorKey,
                    pageBuilder: (context, state) => AppAnimations.slidePage(
                      key: state.pageKey,
                      child: const AiChatHistoryScreen(),
                    ),
                  ),
                  GoRoute(
                    path: 'settings',
                    parentNavigatorKey: _rootNavigatorKey,
                    pageBuilder: (context, state) => AppAnimations.slidePage(
                      key: state.pageKey,
                      child: const SettingsScreen(),
                    ),
                  ),
                  GoRoute(
                    path: 'edit',
                    parentNavigatorKey: _rootNavigatorKey,
                    pageBuilder: (context, state) => AppAnimations.slidePage(
                      key: state.pageKey,
                      child: const EditProfileScreen(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
