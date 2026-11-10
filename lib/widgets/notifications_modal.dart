import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/notifications_provider.dart';

class NotificationsModal extends ConsumerStatefulWidget {
  const NotificationsModal({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const NotificationsModal(),
    );
  }

  @override
  ConsumerState<NotificationsModal> createState() => _NotificationsModalState();
}

class _NotificationsModalState extends ConsumerState<NotificationsModal> {
  bool _showSettings = false;
  bool _filterOnlyUnread = false;

  String _formatRelativeTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d').format(time);
    }
  }

  IconData _getIconForType(NotificationType type) {
    switch (type) {
      case NotificationType.streak:
        return Icons.local_fire_department_rounded;
      case NotificationType.pr:
        return Icons.emoji_events_rounded;
      case NotificationType.reminder:
        return Icons.alarm_rounded;
      case NotificationType.recovery:
        return Icons.spa_rounded;
      case NotificationType.insight:
        return Icons.auto_awesome_rounded;
    }
  }

  Color _getColorForType(NotificationType type) {
    switch (type) {
      case NotificationType.streak:
        return Colors.deepOrangeAccent;
      case NotificationType.pr:
        return Colors.amber.shade700;
      case NotificationType.reminder:
        return Colors.blueAccent;
      case NotificationType.recovery:
        return Colors.tealAccent.shade400;
      case NotificationType.insight:
        return Colors.purpleAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifState = ref.watch(notificationsProvider);
    final notifier = ref.read(notificationsProvider.notifier);
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final displayedNotifications = _filterOnlyUnread
        ? notifState.notifications.where((n) => !n.isRead).toList()
        : notifState.notifications;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF121212) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(
          color: isDark ? const Color(0xFF262626) : const Color(0xFFE5E5E5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 44,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.25)
                      : Colors.black.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.notifications_active_rounded, color: cs.primary, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Notifications',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      if (notifState.unreadCount > 0)
                        Text(
                          '${notifState.unreadCount} unread update${notifState.unreadCount > 1 ? 's' : ''}',
                          style: TextStyle(color: cs.primary, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      _showSettings ? Icons.close_rounded : Icons.tune_rounded,
                      color: _showSettings ? cs.primary : cs.onSurfaceVariant,
                      size: 22,
                    ),
                    tooltip: _showSettings ? 'Back to list' : 'Notification Settings',
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      setState(() => _showSettings = !_showSettings);
                    },
                  ),
                  if (!_showSettings && notifState.notifications.isNotEmpty)
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_horiz_rounded, color: cs.onSurfaceVariant),
                      onSelected: (val) {
                        if (val == 'read_all') {
                          HapticFeedback.lightImpact();
                          notifier.markAllAsRead();
                        } else if (val == 'clear_all') {
                          HapticFeedback.mediumImpact();
                          notifier.clearAll();
                        }
                      },
                      itemBuilder: (ctx) => [
                        const PopupMenuItem(
                          value: 'read_all',
                          child: Row(
                            children: [
                              Icon(Icons.done_all_rounded, size: 18),
                              SizedBox(width: 8),
                              Text('Mark all as read'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'clear_all',
                          child: Row(
                            children: [
                              Icon(Icons.delete_sweep_outlined, color: Colors.redAccent, size: 18),
                              SizedBox(width: 8),
                              Text('Clear all', style: TextStyle(color: Colors.redAccent)),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Main Content: Settings or Notifications List
            Expanded(
              child: _showSettings
                  ? _buildSettingsView(context, notifState.preferences, notifier, cs)
                  : _buildListView(context, displayedNotifications, notifier, cs, isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListView(
    BuildContext context,
    List<FitnessNotification> list,
    NotificationsNotifier notifier,
    ColorScheme cs,
    bool isDark,
  ) {
    if (list.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.notifications_none_rounded, size: 36, color: cs.primary),
              ),
              const SizedBox(height: 16),
              const Text('All caught up!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(
                'No unread notifications at the moment. Keep training consistently!',
                textAlign: TextAlign.center,
                style: TextStyle(color: cs.onSurfaceVariant, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        // Filter bar
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 6),
          child: Row(
            children: [
              ChoiceChip(
                label: const Text('All'),
                selected: !_filterOnlyUnread,
                onSelected: (val) {
                  if (val) setState(() => _filterOnlyUnread = false);
                },
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Unread Only'),
                selected: _filterOnlyUnread,
                onSelected: (val) {
                  if (val) setState(() => _filterOnlyUnread = true);
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: list.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (ctx, index) {
              final notif = list[index];
              final color = _getColorForType(notif.type);
              final icon = _getIconForType(notif.type);

              return InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  notifier.markAsRead(notif.id);
                  if (notif.actionRoute != null) {
                    Navigator.pop(context);
                    context.push(notif.actionRoute!);
                  }
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: notif.isRead
                        ? (isDark ? const Color(0xFF181818) : Colors.black.withValues(alpha: 0.02))
                        : (isDark ? cs.primary.withValues(alpha: 0.14) : cs.primary.withValues(alpha: 0.08)),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: notif.isRead
                          ? (isDark ? const Color(0xFF262626) : const Color(0xFFE5E5E5))
                          : cs.primary.withValues(alpha: 0.4),
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icon Badge
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(icon, color: color, size: 22),
                      ),
                      const SizedBox(width: 14),
                      // Text Content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    notif.title,
                                    style: TextStyle(
                                      fontWeight: notif.isRead ? FontWeight.w600 : FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _formatRelativeTime(notif.timestamp),
                                  style: TextStyle(
                                    color: cs.onSurfaceVariant,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              notif.message,
                              style: TextStyle(
                                color: cs.onSurfaceVariant,
                                fontSize: 13,
                                height: 1.35,
                              ),
                            ),
                            if (notif.actionRoute != null && notif.actionLabel != null) ...[
                              const SizedBox(height: 10),
                              GestureDetector(
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  notifier.markAsRead(notif.id);
                                  Navigator.pop(context);
                                  context.push(notif.actionRoute!);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: cs.primary,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        notif.actionLabel!,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 14),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (!notif.isRead) ...[
                        const SizedBox(width: 8),
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(top: 6),
                          decoration: BoxDecoration(
                            color: cs.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsView(
    BuildContext context,
    NotificationPreferences prefs,
    NotificationsNotifier notifier,
    ColorScheme cs,
  ) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Notification Preferences',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Text(
          'Choose what notifications you want to receive to stay motivated and on track.',
          style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
        ),
        const SizedBox(height: 20),

        _buildSwitchTile(
          title: 'Daily Workout Reminders',
          subtitle: 'Prompts to keep your training streak active and avoid missed days',
          icon: Icons.alarm_rounded,
          value: prefs.dailyReminders,
          onChanged: (val) {
            notifier.updatePreferences(prefs.copyWith(dailyReminders: val));
          },
        ),
        _buildSwitchTile(
          title: 'PR & Milestone Celebrations',
          subtitle: 'Get notified when you hit personal records in volume, weight, or reps',
          icon: Icons.emoji_events_rounded,
          value: prefs.prCelebrations,
          onChanged: (val) {
            notifier.updatePreferences(prefs.copyWith(prCelebrations: val));
          },
        ),
        _buildSwitchTile(
          title: 'Recovery & Hydration Tips',
          subtitle: 'Helpful cues on rest days for post-workout adaptation and health',
          icon: Icons.spa_rounded,
          value: prefs.recoveryTips,
          onChanged: (val) {
            notifier.updatePreferences(prefs.copyWith(recoveryTips: val));
          },
        ),
        _buildSwitchTile(
          title: 'Weekly Summary',
          subtitle: 'Recap of your weekly volume and sessions completed',
          icon: Icons.calendar_view_week_rounded,
          value: prefs.weeklySummary,
          onChanged: (val) {
            notifier.updatePreferences(prefs.copyWith(weeklySummary: val));
          },
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      value: value,
      onChanged: (val) {
        HapticFeedback.selectionClick();
        onChanged(val);
      },
      secondary: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
      subtitle: Text(subtitle, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12)),
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      activeThumbColor: Theme.of(context).colorScheme.primary,
    );
  }
}
