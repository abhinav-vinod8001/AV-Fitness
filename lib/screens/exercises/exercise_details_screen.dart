import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/exercise_model.dart';
import '../../widgets/exercise_visual_card.dart';

class ExerciseDetailsScreen extends StatelessWidget {
  final Exercise exercise;

  const ExerciseDetailsScreen({super.key, required this.exercise});

  List<String> _parseInstructionSteps(String? instructions) {
    if (instructions == null || instructions.trim().isEmpty) return [];
    final lines = instructions.split('\n');
    final steps = <String>[];
    for (var line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;
      // Strip leading number if present (e.g. "1. Step" -> "Step")
      final cleaned = trimmed.replaceFirst(RegExp(r'^\d+[\.\)]\s*'), '');
      if (cleaned.isNotEmpty) {
        steps.add(cleaned);
      }
    }
    return steps;
  }

  @override
  Widget build(BuildContext context) {
    final steps = _parseInstructionSteps(exercise.instructions);

    return Scaffold(
      appBar: AppBar(
        title: Text(exercise.name, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Anatomical Exercise Visual Card
            ExerciseVisualCard(
              exercise: exercise,
              height: 220,
              borderRadius: 16,
            ),
            const SizedBox(height: 20),

            // Metadata Badges
            Row(
              children: [
                _buildBadge(context, Icons.accessibility_new, exercise.muscleGroup, Colors.blue),
                const SizedBox(width: 8),
                _buildBadge(context, Icons.fitness_center, exercise.equipment, Colors.purple),
                if (exercise.isCustom) ...[
                  const SizedBox(width: 8),
                  _buildBadge(context, Icons.person, 'Custom', Colors.orange),
                ],
              ],
            ),
            const SizedBox(height: 24),

            // How to Perform / Steps
            Text(
              'How to Perform',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            if (steps.isNotEmpty)
              ...steps.asMap().entries.map((entry) {
                final index = entry.key + 1;
                final text = entry.value;
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: Text(
                          '$index',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          text,
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.45,
                            color: Theme.of(context).colorScheme.onSurface,
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
                  exercise.instructions ?? 'No specific instructions available for this exercise.',
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 15, height: 1.5),
                ),
              ),

            const SizedBox(height: 20),

            // Pro Tips & Form Cues Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.lightbulb_outline, color: Colors.amber, size: 22),
                      SizedBox(width: 8),
                      Text('Pro Form Tips', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Maintain full controlled range of motion on every rep.\n'
                    '• Exhale during the lifting/concentric phase; inhale on the descent.\n'
                    '• Never sacrifice technique for heavier load to prevent injuries.',
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface, height: 1.4, fontSize: 14),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Action: 1RM Calculator for this exercise
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  context.push('/profile/1rm');
                },
                icon: const Icon(Icons.calculate_outlined),
                label: const Text('Calculate 1RM for this Exercise', style: TextStyle(fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(BuildContext context, IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
