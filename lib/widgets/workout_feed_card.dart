import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/workout_log_model.dart';
import '../models/workout_model.dart';
import '../core/utils/app_animations.dart';
import '../providers/user_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/active_workout_provider.dart';
import '../providers/history_provider.dart';
import '../core/utils/unit_converter.dart';

class WorkoutFeedCard extends ConsumerStatefulWidget {
  final WorkoutLog log;

  const WorkoutFeedCard({
    super.key,
    required this.log,
  });

  @override
  ConsumerState<WorkoutFeedCard> createState() => _WorkoutFeedCardState();
}

class _WorkoutFeedCardState extends ConsumerState<WorkoutFeedCard> {
  bool _isLiked = false;
  int _likesCount = 0;
  final List<String> _comments = [];

  String _formatRelativeTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inSeconds < 60) {
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

  void _showCommentsBottomSheet() {
    final textController = TextEditingController();
    AppAnimations.showAnimatedBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: SizedBox(
            height: 350,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text('Comments', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Expanded(
                  child: _comments.isEmpty
                      ? const Center(child: Text('No comments yet. Say something encouraging!'))
                      : ListView.builder(
                          itemCount: _comments.length,
                          itemBuilder: (c, i) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              children: [
                                const CircleAvatar(radius: 14, child: Icon(Icons.person, size: 16)),
                                const SizedBox(width: 8),
                                Expanded(child: Text(_comments[i])),
                              ],
                            ),
                          ),
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: textController,
                          decoration: InputDecoration(
                            hintText: 'Add a comment...',
                            isDense: true,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: () {
                          if (textController.text.trim().isNotEmpty) {
                            setState(() {
                              _comments.add(textController.text.trim());
                            });
                            setModalState(() {});
                            textController.clear();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProfileAsync = ref.watch(userProfileProvider);
    final weightUnit = ref.watch(settingsProvider).weightUnit;
    final log = widget.log;
    final completedSets = log.exercises.fold<int>(
      0,
      (prev, ex) => prev + ex.sets.where((s) => s.completed).length,
    );

    return userProfileAsync.when(
      data: (userProfile) {
        if (userProfile == null) return const SizedBox.shrink();
        final displayVolume = UnitConverter.toDisplayWeight(log.totalVolume, weightUnit);
        final totalVolumeStr = NumberFormat('#,##0').format(displayVolume);
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          color: isDark ? const Color(0xFF121212) : Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isDark ? const Color(0xFF262626) : const Color(0xFFE5E5E5),
              width: 1.0,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.blue,
                      child: Text(userProfile.initials, style: const TextStyle(color: Colors.white)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(userProfile.model.displayName, style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                            _formatRelativeTime(log.endTime),
                            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_horiz),
                      onSelected: (val) async {
                        if (val == 'details') {
                          HapticFeedback.lightImpact();
                          context.push('/history/detail', extra: log);
                        } else if (val == 'repeat') {
                          HapticFeedback.mediumImpact();
                          final template = WorkoutTemplate(
                            id: const Uuid().v4(),
                            name: log.name,
                            exercises: log.exercises.map((ex) => WorkoutExercise(
                              id: const Uuid().v4(),
                              exerciseId: ex.exerciseId,
                              exerciseName: ex.exerciseName,
                              sets: ex.sets.map((s) => WorkoutSet(
                                id: const Uuid().v4(),
                                setNumber: s.setNumber,
                                weight: s.weight,
                                reps: s.reps,
                                isWarmup: s.isWarmup,
                                rpe: s.rpe,
                                completed: false,
                              )).toList(),
                            )).toList(),
                          );
                          ref.read(activeWorkoutProvider.notifier).startWorkout(template);
                          context.push('/workouts/active');
                        } else if (val == 'copy') {
                          final summary = '${log.name}\n${log.duration.inMinutes} mins • $totalVolumeStr $weightUnit volume';
                          Clipboard.setData(ClipboardData(text: summary));
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Workout summary copied!')));
                        } else if (val == 'delete') {
                          final confirmed = await AppAnimations.showAnimatedDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Delete Workout?'),
                              content: Text('Are you sure you want to delete "${log.name}"?'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );
                          if (confirmed == true) {
                            await ref.read(workoutLogRepositoryProvider).deleteLog(log.id);
                            ref.invalidate(workoutHistoryProvider);
                          }
                        }
                      },
                      itemBuilder: (ctx) => [
                        const PopupMenuItem(
                          value: 'details',
                          child: Row(
                            children: [
                              Icon(Icons.visibility_outlined, size: 18),
                              SizedBox(width: 8),
                              Text('View Details'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'repeat',
                          child: Row(
                            children: [
                              Icon(Icons.replay_rounded, size: 18),
                              SizedBox(width: 8),
                              Text('Perform Again'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'copy',
                          child: Row(
                            children: [
                              Icon(Icons.copy_rounded, size: 18),
                              SizedBox(width: 8),
                              Text('Copy Summary'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                              SizedBox(width: 8),
                              Text('Delete', style: TextStyle(color: Colors.redAccent)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    context.push('/history/detail', extra: log);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(log.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          ),
                          Icon(Icons.chevron_right_rounded, size: 18, color: Theme.of(context).colorScheme.onSurfaceVariant),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Time', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12)),
                                Text(
                                  log.duration.inHours > 0
                                      ? '${log.duration.inHours}h ${log.duration.inMinutes.remainder(60)}m'
                                      : '${log.duration.inMinutes}m',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Volume', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12)),
                                Text('$totalVolumeStr $weightUnit', style: const TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Completed Sets', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12)),
                                Row(
                                  children: [
                                    const Icon(Icons.check_circle_outline, color: Colors.green, size: 16),
                                    const SizedBox(width: 4),
                                    Text('$completedSets', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                // Exercise list summary
                ...log.exercises.take(3).map((e) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                            child: Icon(Icons.fitness_center, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '${e.sets.where((s) => s.completed).length} sets ${e.exerciseName}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    )),
                if (log.exercises.length > 3)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      '+ ${log.exercises.length - 3} more exercises',
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.bold),
                    ),
                  ),
                const SizedBox(height: 16),
                // Interaction Bar
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        setState(() {
                          _isLiked = !_isLiked;
                          _likesCount += _isLiked ? 1 : -1;
                        });
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                        child: Row(
                          children: [
                            Icon(
                              _isLiked ? Icons.favorite : Icons.favorite_border,
                              color: _isLiked ? Colors.red : Theme.of(context).colorScheme.onSurfaceVariant,
                              size: 20,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '$_likesCount',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _isLiked ? Colors.red : Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    InkWell(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        _showCommentsBottomSheet();
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                        child: Row(
                          children: [
                            Icon(Icons.chat_bubble_outline, color: Theme.of(context).colorScheme.onSurfaceVariant, size: 20),
                            const SizedBox(width: 6),
                            Text(
                              '${_comments.length}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => const SizedBox.shrink(),
    );
  }
}
