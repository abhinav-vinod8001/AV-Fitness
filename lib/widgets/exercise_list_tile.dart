import 'package:flutter/material.dart';
import '../../models/exercise_model.dart';
import 'exercise_preview_modal.dart';
import 'exercise_visual_card.dart';

class ExerciseListTile extends StatelessWidget {
  final Exercise exercise;
  final VoidCallback onTap;

  const ExerciseListTile({
    super.key,
    required this.exercise,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: GestureDetector(
        onTap: () {
          ExercisePreviewModal.show(context, exercise: exercise);
        },
        child: ExerciseVisualCard(
          exercise: exercise,
          width: 48,
          height: 48,
          borderRadius: 10,
          showLabels: false,
          isHero: false,
        ),
      ),
      title: Text(
        exercise.name,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        '${exercise.muscleGroup} • ${exercise.equipment}',
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontSize: 12,
        ),
      ),
      trailing: exercise.isCustom
          ? const Icon(Icons.person, size: 16, color: Colors.grey)
          : null,
      onTap: onTap,
    );
  }
}
