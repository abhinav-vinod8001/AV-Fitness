import 'package:flutter/material.dart';
import '../core/services/widget_data_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/history_provider.dart';
import '../widgets/workout_feed_card.dart';
import '../widgets/notifications_modal.dart';
import '../providers/notifications_provider.dart';
import 'home_widgets/consistency_rings_card.dart';
import 'home_widgets/up_next_card.dart';
import 'home_widgets/volume_sparkline_card.dart';
import 'home_widgets/recent_prs_card.dart';
import '../providers/user_provider.dart';
import '../providers/settings_provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/progress_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyLogsAsync = ref.watch(workoutHistoryProvider);
    final userProfileAsync = ref.watch(userProfileProvider);
    final progressAsync = ref.watch(progressStatsProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
        actions: [
          Consumer(
            builder: (context, ref, _) {
              final unreadCount = ref.watch(notificationsProvider.select((s) => s.unreadCount));
              return IconButton(
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.notifications_outlined),
                    if (unreadCount > 0)
                      Positioned(
                        top: -2,
                        right: -2,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: cs.primary,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                          child: Text(
                            '$unreadCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
                tooltip: 'Notifications',
                onPressed: () {
                  HapticFeedback.lightImpact();
                  NotificationsModal.show(context);
                },
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          HapticFeedback.lightImpact();
          ref.invalidate(workoutHistoryProvider);
        },
        child: ListView(
          padding: const EdgeInsets.only(top: 8, bottom: 90),
          children: [
            // Greeting Section
            userProfileAsync.when(
              data: (userProfile) {
                final name = userProfile?.model.displayName ?? 'Athlete';
                final firstName = name.isNotEmpty ? name.split(' ').first : 'Athlete';
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Time to get ready,',
                            style: TextStyle(
                              fontSize: 16,
                              color: cs.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            firstName,
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: cs.primary,
                              shadows: [
                                Shadow(
                                  color: cs.primary.withValues(alpha: 0.4),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              context.push('/recap');
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              margin: const EdgeInsets.only(bottom: 6, right: 8),
                              decoration: BoxDecoration(
                                color: cs.primaryContainer,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.auto_awesome, color: cs.onPrimaryContainer, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Recap',
                                    style: TextStyle(
                                      color: cs.onPrimaryContainer,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          progressAsync.when(
                            data: (stats) {
                              if (stats.currentStreak <= 0) return const SizedBox.shrink();
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                margin: const EdgeInsets.only(bottom: 6),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.local_fire_department_rounded, color: Colors.orange, size: 20),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${stats.currentStreak}',
                                      style: const TextStyle(
                                        color: Colors.orange,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                            loading: () => const SizedBox.shrink(),
                            error: (_, __) => const SizedBox.shrink(),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
              loading: () => const SizedBox(height: 70),
              error: (_, __) => const SizedBox(height: 70),
            ),
            
            // API Key Setup Banner
            _ApiKeyBanner(),

            // Dashboard Cards
            const ConsistencyRingsCard(),
            const UpNextCard(),
            const VolumeSparklineCard(),
            const RecentPRsCard(),
            const SizedBox(height: 16),
            
            // Feed Section
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('Recent Activity', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),
            historyLogsAsync.when(
              data: (historyLogs) {
                // Update native Android widgets with latest stats
                WidgetDataService.updateWidgetData(historyLogs);
                if (historyLogs.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.feed_outlined, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant),
                        const SizedBox(height: 16),
                        const Text('No Activity Yet', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text('Completed workouts from you and your friends will appear here.', 
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 16)),
                      ],
                    ),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: historyLogs.map((log) => WorkoutFeedCard(log: log)).toList(),
                  ),
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, st) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.error.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Unable to load activity right now.',
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        tooltip: 'Retry',
                        onPressed: () => ref.invalidate(workoutHistoryProvider),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One-time dismissible banner prompting user to set up their Groq API key
class _ApiKeyBanner extends ConsumerStatefulWidget {
  @override
  ConsumerState<_ApiKeyBanner> createState() => _ApiKeyBannerState();
}

class _ApiKeyBannerState extends ConsumerState<_ApiKeyBanner> {
  bool _dismissed = true; // hidden by default until we check

  @override
  void initState() {
    super.initState();
    _checkIfShouldShow();
  }

  Future<void> _checkIfShouldShow() async {
    final prefs = await SharedPreferences.getInstance();
    final wasDismissed = prefs.getBool('api_key_banner_dismissed') ?? false;
    final apiKey = ref.read(settingsProvider).groqApiKey.trim();
    if (!wasDismissed && apiKey.isEmpty && mounted) {
      setState(() => _dismissed = false);
    }
  }

  Future<void> _dismiss() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('api_key_banner_dismissed', true);
    if (mounted) setState(() => _dismissed = true);
  }

  @override
  Widget build(BuildContext context) {
    final apiKey = ref.watch(settingsProvider).groqApiKey.trim();
    // Auto-hide if key was added
    if (apiKey.isNotEmpty || _dismissed) return const SizedBox.shrink();

    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              cs.primary.withValues(alpha: 0.12),
              cs.primary.withValues(alpha: 0.04),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.primary.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.auto_awesome, color: cs.primary, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Unlock AI Features',
                      style: TextStyle(
                          color: cs.onSurface,
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                  const SizedBox(height: 2),
                  Text('Add your free Groq API key for AI coaching & weekly recaps.',
                      style: TextStyle(
                          color: cs.onSurfaceVariant, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              children: [
                SizedBox(
                  height: 30,
                  child: TextButton(
                    onPressed: () => context.push('/profile/settings'),
                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                    child: Text('Setup',
                        style: TextStyle(
                            color: cs.primary, fontWeight: FontWeight.bold)),
                  ),
                ),
                SizedBox(
                  height: 24,
                  child: TextButton(
                    onPressed: _dismiss,
                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                    child: Text('Later',
                        style: TextStyle(
                            color: cs.onSurfaceVariant, fontSize: 11)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
