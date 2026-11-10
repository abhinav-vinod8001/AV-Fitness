import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

import '../providers/history_provider.dart';
import '../models/workout_log_model.dart';

class ProfileShareSheet extends ConsumerStatefulWidget {
  final String displayName;
  final String initials;
  final String goal;
  final int workouts;
  final String weight;

  const ProfileShareSheet({
    super.key,
    required this.displayName,
    required this.initials,
    required this.goal,
    required this.workouts,
    required this.weight,
  });

  @override
  ConsumerState<ProfileShareSheet> createState() => _ProfileShareSheetState();
}

class _ProfileShareSheetState extends ConsumerState<ProfileShareSheet> {
  final ScreenshotController _screenshotController = ScreenshotController();
  bool _isSharing = false;

  // Computed stats
  double _totalVolume = 0;
  int _totalMinutes = 0;
  int _totalSets = 0;
  int _currentStreak = 0;
  String _topExercise = '';
  double _topWeight = 0;

  @override
  void initState() {
    super.initState();
    _computeStats();
  }

  void _computeStats() {
    final logs = ref.read(workoutHistoryProvider).valueOrNull ?? [];

    // Total volume and minutes
    for (final log in logs) {
      _totalVolume += log.totalVolume;
      _totalMinutes += log.duration.inMinutes;
      for (final ex in log.exercises) {
        _totalSets += ex.sets.where((s) => s.completed).length;
      }
    }

    // Top exercise by weight
    for (final log in logs) {
      for (final ex in log.exercises) {
        for (final set in ex.sets) {
          if (set.completed && set.weight > _topWeight) {
            _topWeight = set.weight;
            _topExercise = ex.exerciseName;
          }
        }
      }
    }

    // Current streak (consecutive days with a workout, looking backwards)
    if (logs.isNotEmpty) {
      final workoutDays = <String>{};
      for (final log in logs) {
        workoutDays.add(DateFormat('yyyy-MM-dd').format(log.startTime));
      }
      var day = DateTime.now();
      // Check if today or yesterday had a workout to start the streak
      final todayStr = DateFormat('yyyy-MM-dd').format(day);
      final yesterdayStr =
          DateFormat('yyyy-MM-dd').format(day.subtract(const Duration(days: 1)));
      if (!workoutDays.contains(todayStr) &&
          !workoutDays.contains(yesterdayStr)) {
        _currentStreak = 0;
      } else {
        if (!workoutDays.contains(todayStr)) {
          day = day.subtract(const Duration(days: 1));
        }
        while (workoutDays
            .contains(DateFormat('yyyy-MM-dd').format(day))) {
          _currentStreak++;
          day = day.subtract(const Duration(days: 1));
        }
      }
    }
  }

  Future<void> _sharePoster() async {
    setState(() => _isSharing = true);
    try {
      final image = await _screenshotController.capture(
          delay: const Duration(milliseconds: 20), pixelRatio: 3.0);
      if (image == null) return;

      final directory = await getTemporaryDirectory();
      final imagePath =
          await File('${directory.path}/av_fitness_progress.png').create();
      await imagePath.writeAsBytes(image);

      final box = context.findRenderObject() as RenderBox?;
      await Share.shareXFiles(
        [XFile(imagePath.path)],
        text: 'Check out my fitness progress on AV Fitness! 💪',
        sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to share: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSharing = false);
      }
    }
  }

  Future<void> _shareToChatGPT() async {
    final summary = '''
Fitness Profile Summary for ${widget.displayName}:
- Goal: ${widget.goal}
- Total Workouts Completed: ${widget.workouts}
- Current Weight: ${widget.weight}
- Total Volume Lifted: ${_formatVolume(_totalVolume)}
- Total Active Minutes: $_totalMinutes min
- Total Sets Completed: $_totalSets
- Current Streak: $_currentStreak days
- Personal Best: ${_topExercise.isNotEmpty ? '$_topExercise at ${_topWeight.toStringAsFixed(1)} kg' : 'N/A'}

Based on these stats, can you analyze my progress and give me a personalized workout plan to achieve my goal of "${widget.goal}"?
''';
    await Clipboard.setData(ClipboardData(text: summary));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Progress copied! Opening ChatGPT...')),
      );
    }

    final url = Uri.parse('https://chatgpt.com/');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  String _formatVolume(double vol) {
    if (vol >= 1000000) {
      return '${(vol / 1000000).toStringAsFixed(1)}M kg';
    } else if (vol >= 1000) {
      return '${(vol / 1000).toStringAsFixed(1)}K kg';
    }
    return '${vol.toInt()} kg';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.only(
        top: 16,
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text('Share Progress',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            // The Card to be screenshotted
            Screenshot(
              controller: _screenshotController,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF0A0E21),
                      Color(0xFF141A33),
                      Color(0xFF1D2550),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08), width: 1),
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Ambient glow top-right
                    Positioned(
                      top: -60,
                      right: -60,
                      child: Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Colors.blueAccent.withValues(alpha: 0.25),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Ambient glow bottom-left
                    Positioned(
                      bottom: -40,
                      left: -40,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Colors.purpleAccent.withValues(alpha: 0.2),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Brand header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF6C63FF),
                                        Color(0xFF3F51B5)
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.bolt,
                                      color: Colors.white, size: 18),
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  'AV FITNESS',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 3,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                DateFormat('MMM yyyy').format(DateTime.now()),
                                style: TextStyle(
                                    color:
                                        Colors.white.withValues(alpha: 0.5),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Avatar + Name
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF6C63FF), Color(0xFF00BCD4)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 40,
                            backgroundColor: const Color(0xFF141A33),
                            child: Text(
                              widget.initials,
                              style: const TextStyle(
                                  fontSize: 30,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          widget.displayName.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF6C63FF).withValues(alpha: 0.3),
                                const Color(0xFF00BCD4).withValues(alpha: 0.3),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: const Color(0xFF6C63FF)
                                    .withValues(alpha: 0.5)),
                          ),
                          child: Text(
                            widget.goal,
                            style: const TextStyle(
                                color: Color(0xFF82B1FF),
                                fontWeight: FontWeight.w700,
                                fontSize: 13),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Stats grid — 2x2
                        Row(
                          children: [
                            Expanded(
                                child: _buildMiniStat(
                                    'WORKOUTS', '${widget.workouts}',
                                    icon: Icons.fitness_center)),
                            const SizedBox(width: 10),
                            Expanded(
                                child: _buildMiniStat(
                                    'VOLUME', _formatVolume(_totalVolume),
                                    icon: Icons.monitor_weight_outlined)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                                child: _buildMiniStat(
                                    'STREAK', '$_currentStreak days',
                                    icon: Icons.local_fire_department)),
                            const SizedBox(width: 10),
                            Expanded(
                                child: _buildMiniStat(
                                    'WEIGHT', widget.weight,
                                    icon: Icons.scale_outlined)),
                          ],
                        ),

                        // Personal Best section
                        if (_topExercise.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.amber.withValues(alpha: 0.12),
                                  Colors.orange.withValues(alpha: 0.06),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color:
                                      Colors.amber.withValues(alpha: 0.2)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.emoji_events_rounded,
                                    color: Colors.amber, size: 22),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text('PERSONAL BEST',
                                          style: TextStyle(
                                              color: Colors.amber,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: 1.5)),
                                      const SizedBox(height: 2),
                                      Text(
                                        '$_topExercise — ${_topWeight.toStringAsFixed(1)} kg',
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Actions
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isSharing ? null : _sharePoster,
                    icon: _isSharing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child:
                                CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.share_rounded),
                    label: const Text('Share Poster'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cs.primary,
                      foregroundColor: cs.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _shareToChatGPT,
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('AI Analysis'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cs.surfaceContainerHighest,
                      foregroundColor: cs.onSurfaceVariant,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon,
                color: Colors.white.withValues(alpha: 0.4), size: 18),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(label,
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
