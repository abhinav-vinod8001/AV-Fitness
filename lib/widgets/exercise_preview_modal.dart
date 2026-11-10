import 'package:flutter/material.dart';
import '../models/exercise_model.dart';
import 'exercise_visual_card.dart';
import 'bouncing_touch_target.dart';
import '../core/utils/app_animations.dart';

class ExercisePreviewModal extends StatelessWidget {
  final Exercise exercise;
  final VoidCallback? onSelect;
  final bool isSelected;

  const ExercisePreviewModal({
    super.key,
    required this.exercise,
    this.onSelect,
    this.isSelected = false,
  });

  static Future<void> show(
    BuildContext context, {
    required Exercise exercise,
    VoidCallback? onSelect,
    bool isSelected = false,
  }) {
    return AppAnimations.showAnimatedBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => ExercisePreviewModal(
        exercise: exercise,
        onSelect: onSelect,
        isSelected: isSelected,
      ),
    );
  }

  List<String> _parseInstructionSteps(String? instructions) {
    if (instructions == null || instructions.trim().isEmpty) return [];
    final lines = instructions.split('\n');
    final steps = <String>[];
    for (var line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;
      final cleaned = trimmed.replaceFirst(RegExp(r'^\d+[\.\)]\s*'), '');
      if (cleaned.isNotEmpty) {
        steps.add(cleaned);
      }
    }
    return steps;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final steps = _parseInstructionSteps(exercise.instructions);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Modal Header with Close Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    exercise.name,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Scrollable Content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Accurate Anatomical Exercise Visual Banner
                  ExerciseVisualCard(
                    exercise: exercise,
                    height: 200,
                    borderRadius: 16,
                  ),
                  const SizedBox(height: 16),

                  // Metadata Badges
                  Row(
                    children: [
                      _buildTag(
                        context,
                        Icons.accessibility_new,
                        exercise.muscleGroup,
                        Colors.blue,
                      ),
                      const SizedBox(width: 8),
                      _buildTag(
                        context,
                        Icons.fitness_center,
                        exercise.equipment,
                        Colors.purple,
                      ),
                      if (exercise.isCustom) ...[
                        const SizedBox(width: 8),
                        _buildTag(
                          context,
                          Icons.person,
                          'Custom',
                          Colors.orange,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Step-by-Step Execution Guide
                  Text(
                    'Step-by-Step Execution',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),

                  if (steps.isNotEmpty)
                    ...steps.asMap().entries.map((entry) {
                      final stepNum = entry.key + 1;
                      final stepText = entry.value;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.colorScheme.outlineVariant
                                .withValues(alpha: 0.25),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: theme.colorScheme.primary,
                              child: Text(
                                '$stepNum',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                stepText,
                                style: TextStyle(
                                  fontSize: 14,
                                  height: 1.4,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    })
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        exercise.instructions ??
                            'Form guidance is being curated for this exercise.',
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                    ),

                  const SizedBox(height: 12),

                  // Form & Technique Cues Card
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.amber.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.lightbulb_outline,
                          color: Colors.amber,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Key Form Tip: Keep the movement smooth and controlled. Avoid using momentum and maintain core tightness throughout.',
                            style: TextStyle(
                              color: theme.colorScheme.onSurface,
                              fontSize: 13,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Bottom Action Bar (if onSelect is provided)
          if (onSelect != null)
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: BouncingTouchTarget(
                    onTap: () {
                      Navigator.of(context).pop();
                      onSelect?.call();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.green.shade700 : theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(isSelected ? Icons.check_circle : Icons.add_circle_outline, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            isSelected ? 'Selected (Tap to Toggle)' : 'Select Exercise',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTag(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
