import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/weekly_schedule_provider.dart';
import '../providers/workout_provider.dart';
import '../models/workout_model.dart';
import '../core/utils/app_animations.dart';

class ScheduleBuilderTab extends ConsumerStatefulWidget {
  const ScheduleBuilderTab({super.key});

  @override
  ConsumerState<ScheduleBuilderTab> createState() => _ScheduleBuilderTabState();
}

class _ScheduleBuilderTabState extends ConsumerState<ScheduleBuilderTab> {
  final List<String> _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  void _addRoutineToDay(BuildContext context, int weekday, List<WorkoutTemplate> allTemplates) async {
    final selectedId = await AppAnimations.showAnimatedDialog<String?>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Assign Routine to ${_weekdays[weekday - 1]}'),
        content: SizedBox(
          width: double.maxFinite,
          child: allTemplates.isEmpty 
            ? const Text('No routines available. Create one first.')
            : ListView.builder(
              shrinkWrap: true,
              itemCount: allTemplates.length,
              itemBuilder: (ctx, idx) {
                final t = allTemplates[idx];
                return ListTile(
                  title: Text(t.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${t.exercises.length} exercises'),
                  onTap: () => Navigator.pop(ctx, t.id),
                );
              },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, null), child: const Text('Cancel')),
        ],
      ),
    );

    if (selectedId != null) {
      ref.read(weeklyScheduleProvider.notifier).addRoutineToDay(weekday, selectedId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final schedule = ref.watch(weeklyScheduleProvider);
    final templatesAsync = ref.watch(workoutTemplatesProvider);
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return templatesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Error: $e')),
      data: (templates) {
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: 7,
          itemBuilder: (context, index) {
            final weekday = index + 1; // 1 to 7
            final assignedIds = schedule[weekday] ?? [];
            final assignedTemplates = assignedIds
                .map((id) => templates.firstWhere((t) => t.id == id, orElse: () => WorkoutTemplate(id: '', name: 'Deleted Routine', exercises: [], userId: '')))
                .toList();

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF161616) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? const Color(0xFF262626) : const Color(0xFFE5E5E5),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _weekdays[index],
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: assignedTemplates.isNotEmpty ? cs.primary : cs.onSurface,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.add_circle_outline, color: cs.primary),
                          onPressed: () => _addRoutineToDay(context, weekday, templates),
                        ),
                      ],
                    ),
                  ),
                  if (assignedTemplates.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                      child: Text('Rest Day', style: TextStyle(color: cs.onSurfaceVariant, fontStyle: FontStyle.italic)),
                    )
                  else
                    ...assignedTemplates.map((t) => ListTile(
                          title: Text(t.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                          trailing: IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                            onPressed: () {
                              ref.read(weeklyScheduleProvider.notifier).removeRoutineFromDay(weekday, t.id);
                            },
                          ),
                        )),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
