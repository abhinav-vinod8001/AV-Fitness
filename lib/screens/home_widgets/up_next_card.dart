import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/weekly_schedule_provider.dart';
import '../../providers/workout_provider.dart';
import '../../providers/active_workout_provider.dart';
import '../../models/workout_model.dart';
import 'dart:math';

class UpNextCard extends ConsumerWidget {
  const UpNextCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schedule = ref.watch(weeklyScheduleProvider);
    final templatesAsync = ref.watch(workoutTemplatesProvider);
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final weekday = DateTime.now().weekday; // 1 = Monday
    final todaysRoutinesIds = schedule[weekday] ?? [];

    return templatesAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (templates) {
        // Find all workouts for today
        final nextWorkouts = todaysRoutinesIds
            .map((id) => templates.firstWhere(
                  (t) => t.id == id,
                  orElse: () => WorkoutTemplate(id: '', name: 'Workout', exercises: [], userId: ''),
                ))
            .where((t) => t.id.isNotEmpty)
            .toList();

        if (nextWorkouts.isNotEmpty) {
          return Column(
            children: nextWorkouts.map((t) => _buildCard(context, ref, t, isDark, cs, 'Today')).toList(),
          );
        }

        // 2. Find next upcoming workout
        for (int i = 1; i <= 6; i++) {
          final nextDay = (weekday + i) > 7 ? (weekday + i) % 7 : (weekday + i);
          final routines = schedule[nextDay] ?? [];
          if (routines.isNotEmpty) {
            final t = templates.firstWhere(
              (t) => t.id == routines.first, 
              orElse: () => WorkoutTemplate(id: '', name: 'Workout', exercises: [], userId: '')
            );
            if (t.id.isNotEmpty) {
              return _buildCard(context, ref, t, isDark, cs, _getDayName(nextDay));
            }
          }
        }
        return _buildEmptyCard(isDark, cs, context);
      },
    );
  }

  Widget _buildEmptyCard(bool isDark, ColorScheme cs, BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161616) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? const Color(0xFF262626) : const Color(0xFFE5E5E5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: cs.onSurfaceVariant.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(Icons.weekend_rounded, color: cs.onSurfaceVariant),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Rest Day', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text('Enjoy your recovery!', style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13)),
              ],
            ),
          ),
          TextButton(
            onPressed: () => context.push('/profile/calendar'),
            child: Text('Schedule', style: TextStyle(fontWeight: FontWeight.bold, color: cs.primary)),
          )
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, WidgetRef ref, WorkoutTemplate t, bool isDark, ColorScheme cs, String dayLabel) {
    final estMinutes = max(15, t.exercises.length * 8);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark 
            ? [cs.primary.withOpacity(0.2), const Color(0xFF161616)] 
            : [cs.primary.withOpacity(0.1), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cs.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bolt_rounded, color: cs.primary, size: 20),
              const SizedBox(width: 6),
              Text('Up Next • $dayLabel', style: TextStyle(color: cs.primary, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                    const SizedBox(height: 4),
                    Text('${t.exercises.length} Exercises • ~$estMinutes min', style: TextStyle(color: cs.onSurfaceVariant, fontSize: 14)),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  // Start workout directly
                  ref.read(activeWorkoutProvider.notifier).startWorkout(t);
                  context.push('/workouts/active');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: cs.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text('Start', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              )
            ],
          ),
        ],
      ),
    );
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1: return 'Monday';
      case 2: return 'Tuesday';
      case 3: return 'Wednesday';
      case 4: return 'Thursday';
      case 5: return 'Friday';
      case 6: return 'Saturday';
      case 7: return 'Sunday';
      default: return 'Someday';
    }
  }
}
