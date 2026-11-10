import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/active_workout_provider.dart';

class MinimizedWorkoutBanner extends ConsumerWidget {
  const MinimizedWorkoutBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeState = ref.watch(activeWorkoutProvider);
    final log = activeState.log;
    final isActive = log != null;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        return SizeTransition(
          sizeFactor: CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOutCubic,
          ),
          alignment: const Alignment(0, -1.0),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      child: !isActive
          ? const SizedBox(key: ValueKey('empty'), width: double.infinity, height: 0)
          : _BannerContent(
              key: const ValueKey('banner'),
              workoutName: log.name,
              startTime: log.startTime,
              onTap: () {
                HapticFeedback.lightImpact();
                context.push('/workouts/active');
              },
              onDiscard: () {
                HapticFeedback.heavyImpact();
                ref.read(activeWorkoutProvider.notifier).discardWorkout();
              },
            ),
    );
  }
}

class _BannerContent extends StatefulWidget {
  final String workoutName;
  final DateTime startTime;
  final VoidCallback onTap;
  final VoidCallback onDiscard;

  const _BannerContent({
    super.key,
    required this.workoutName,
    required this.startTime,
    required this.onTap,
    required this.onDiscard,
  });

  @override
  State<_BannerContent> createState() => _BannerContentState();
}

class _BannerContentState extends State<_BannerContent> with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  late Duration _elapsed;

  @override
  void initState() {
    super.initState();
    _elapsed = DateTime.now().difference(widget.startTime);
    _ticker = createTicker((_) {
      final newElapsed = DateTime.now().difference(widget.startTime);
      if (newElapsed.inSeconds != _elapsed.inSeconds) {
        setState(() => _elapsed = newElapsed);
      }
    });
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    int hours = duration.inHours;
    int minutes = duration.inMinutes.remainder(60);
    int seconds = duration.inSeconds.remainder(60);
    if (hours > 0) {
      return "${hours}h ${minutes}m";
    } else if (minutes > 0) {
      return "${minutes}m ${seconds}s";
    } else {
      return "${seconds}s";
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Hero(
      tag: 'active_workout_pill',
      child: Material(
        type: MaterialType.transparency,
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: cs.primary.withValues(alpha: 0.25),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: cs.primary.withValues(alpha: isDark ? 0.12 : 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  padding: const EdgeInsets.all(14.0),
                  color: isDark
                      ? cs.surface.withValues(alpha: 0.45)
                      : cs.surfaceContainerHighest.withValues(alpha: 0.55),
                  child: Row(
                    children: [
                      // Pulsing dot + up chevron
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: cs.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.keyboard_arrow_up, size: 24, color: cs.primary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 7,
                                  height: 7,
                                  decoration: const BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  widget.workoutName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: cs.onSurface,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _formatDuration(_elapsed),
                              style: TextStyle(
                                color: cs.primary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: Icon(Icons.close_rounded, color: cs.error, size: 22),
                        onPressed: widget.onDiscard,
                        style: IconButton.styleFrom(
                          backgroundColor: cs.error.withValues(alpha: 0.08),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
