import 'package:flutter/material.dart';
import '../models/exercise_model.dart';

class ExerciseVisualCard extends StatelessWidget {
  final Exercise exercise;
  final double width;
  final double height;
  final double borderRadius;
  final bool showLabels;
  final bool isHero;

  const ExerciseVisualCard({
    super.key,
    required this.exercise,
    this.width = double.infinity,
    this.height = 200,
    this.borderRadius = 16,
    this.showLabels = true,
    this.isHero = true,
  });

  static String getAnatomicalAssetPath(Exercise exercise) {
    final muscleLower = exercise.muscleGroup.toLowerCase();

    switch (muscleLower) {
      case 'chest':
        return 'assets/images/anatomical/chest.jpg';
      case 'back':
        return 'assets/images/anatomical/back.jpg';
      case 'shoulders':
        return 'assets/images/anatomical/shoulders.jpg';
      case 'biceps':
        return 'assets/images/anatomical/biceps.jpg';
      case 'triceps':
        return 'assets/images/anatomical/triceps.jpg';
      case 'forearms':
        return 'assets/images/anatomical/biceps.jpg';
      case 'quads':
        return 'assets/images/anatomical/quads.jpg';
      case 'hamstrings':
        return 'assets/images/anatomical/hamstrings.jpg';
      case 'glutes':
        return 'assets/images/anatomical/hamstrings.jpg';
      case 'calves':
        return 'assets/images/anatomical/calves.jpg';
      case 'core':
        return 'assets/images/anatomical/core.jpg';
      case 'cardio':
        return 'assets/images/anatomical/cardio.jpg';
    }

    // Fallback heuristic for custom or legacy exercises
    final nameLower = exercise.name.toLowerCase();
    if (nameLower.contains('bicep') || (nameLower.contains('curl') && !nameLower.contains('leg curl') && !nameLower.contains('wrist'))) {
      return 'assets/images/anatomical/biceps.jpg';
    }
    if (nameLower.contains('tricep') || nameLower.contains('pushdown') || nameLower.contains('skull') || (nameLower.contains('dip') && muscleLower.contains('arm'))) {
      return 'assets/images/anatomical/triceps.jpg';
    }
    if (nameLower.contains('calf') || nameLower.contains('calves') || nameLower.contains('tibialis')) {
      return 'assets/images/anatomical/calves.jpg';
    }
    if (nameLower.contains('hamstring') || nameLower.contains('leg curl') || nameLower.contains('rdl') || nameLower.contains('deadlift') || nameLower.contains('hip thrust') || nameLower.contains('glute') || nameLower.contains('sumo')) {
      return 'assets/images/anatomical/hamstrings.jpg';
    }
    if (nameLower.contains('squat') || nameLower.contains('quad') || nameLower.contains('leg press') || nameLower.contains('leg extension') || nameLower.contains('lunge') || nameLower.contains('step-up')) {
      return 'assets/images/anatomical/quads.jpg';
    }
    if (nameLower.contains('shoulder') || (nameLower.contains('press') && muscleLower.contains('shoulder')) || nameLower.contains('lateral') || nameLower.contains('delt') || nameLower.contains('arnold') || nameLower.contains('upright row')) {
      return 'assets/images/anatomical/shoulders.jpg';
    }
    if (muscleLower.contains('arm')) {
      return 'assets/images/anatomical/biceps.jpg';
    }
    if (muscleLower.contains('leg')) {
      return 'assets/images/anatomical/quads.jpg';
    }

    return 'assets/images/anatomical/chest.jpg';
  }

  static Color getMuscleColor(String muscleGroup) {
    switch (muscleGroup.toLowerCase()) {
      case 'chest':
        return const Color(0xFFE53935);
      case 'back':
        return const Color(0xFF1E88E5);
      case 'shoulders':
        return const Color(0xFF8E24AA);
      case 'biceps':
      case 'arms':
        return const Color(0xFF00ACC1);
      case 'triceps':
        return const Color(0xFF0097A7);
      case 'forearms':
        return const Color(0xFF00838F);
      case 'quads':
      case 'legs':
        return const Color(0xFF43A047);
      case 'hamstrings':
        return const Color(0xFF2E7D32);
      case 'glutes':
        return const Color(0xFF689F38);
      case 'calves':
        return const Color(0xFF8BC34A);
      case 'core':
        return const Color(0xFFFB8C00);
      case 'cardio':
        return const Color(0xFFE91E63);
      default:
        return const Color(0xFF5C6BC0);
    }
  }

  static IconData getEquipmentIcon(String equipment) {
    switch (equipment.toLowerCase()) {
      case 'barbell':
        return Icons.fitness_center;
      case 'dumbbell':
        return Icons.fitness_center_outlined;
      case 'cable':
        return Icons.cable;
      case 'machine':
        return Icons.precision_manufacturing;
      case 'kettlebell':
        return Icons.sports_gymnastics;
      case 'none':
      case 'bodyweight':
        return Icons.accessibility_new;
      default:
        return Icons.fitness_center;
    }
  }

  @override
  Widget build(BuildContext context) {
    final assetPath = getAnatomicalAssetPath(exercise);
    final muscleColor = getMuscleColor(exercise.muscleGroup);
    final eqIcon = getEquipmentIcon(exercise.equipment);

    Widget content = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Anatomical Vector Line Art Image
            Image.asset(
              assetPath,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.grey.shade100,
                child: Center(
                  child: Icon(Icons.fitness_center, size: 36, color: muscleColor),
                ),
              ),
            ),

            // Top-Left Muscle & Equipment Badges (Large Preview Only)
            if (showLabels && height > 100)
              Positioned(
                top: 10,
                left: 10,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: muscleColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            exercise.muscleGroup.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(eqIcon, size: 11, color: Colors.white70),
                          const SizedBox(width: 4),
                          Text(
                            exercise.equipment.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            // Bottom Floating Name Banner (Large Preview Only)
            if (showLabels && height > 100)
              Positioned(
                bottom: 8,
                left: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    exercise.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
          ],
        ),
      ),
    );

    if (isHero) {
      return Hero(
        tag: 'exercise_visual_${exercise.id}',
        child: content,
      );
    }
    return content;
  }
}
