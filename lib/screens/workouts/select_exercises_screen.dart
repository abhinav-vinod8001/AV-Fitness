import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/exercise_model.dart';
import '../../providers/exercise_provider.dart';
import '../../widgets/exercise_preview_modal.dart';
import '../../widgets/exercise_visual_card.dart';

// Local provider for tracking selected exercises on this screen only
final selectedExercisesProvider = StateProvider.autoDispose<List<Exercise>>((ref) => []);

class SelectExercisesScreen extends ConsumerStatefulWidget {
  const SelectExercisesScreen({super.key});

  static const List<String> muscleFilters = [
    'All',
    'Chest',
    'Back',
    'Shoulders',
    'Biceps',
    'Triceps',
    'Forearms',
    'Quads',
    'Hamstrings',
    'Glutes',
    'Calves',
    'Core',
    'Cardio',
  ];

  static const List<String> equipmentFilters = [
    'All',
    'Barbell',
    'Dumbbell',
    'Cable',
    'Machine',
    'Bodyweight',
    'Kettlebell',
  ];

  @override
  ConsumerState<SelectExercisesScreen> createState() => _SelectExercisesScreenState();
}

class _SelectExercisesScreenState extends ConsumerState<SelectExercisesScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _searchController.clear();
    ref.read(selectExerciseSearchQueryProvider.notifier).state = '';
    setState(() {});
  }

  void _toggleExercise(Exercise exercise) {
    final currentSelected = ref.read(selectedExercisesProvider);
    final exists = currentSelected.any((e) => e.id == exercise.id);
    if (!exists) {
      ref.read(selectedExercisesProvider.notifier).state = [...currentSelected, exercise];
    } else {
      ref.read(selectedExercisesProvider.notifier).state =
          currentSelected.where((e) => e.id != exercise.id).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredExercises = ref.watch(filteredSelectExercisesProvider);
    final asyncExercises = ref.watch(exerciseListProvider);
    final selectedExercises = ref.watch(selectedExercisesProvider);
    final selectedMuscle = ref.watch(selectExerciseMuscleGroupFilterProvider) ?? 'All';
    final selectedEquipment = ref.watch(selectExerciseEquipmentFilterProvider) ?? 'All';
    final selectedSort = ref.watch(selectExerciseSortOptionProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Add Exercises', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text(
              '${filteredExercises.length} movements available',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(115),
          child: Column(
            children: [
              // Search Input
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search exercises, muscles (e.g. OHP, DB, Quads)...',
                    hintStyle: const TextStyle(fontSize: 13),
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: _clearSearch,
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) {
                    ref.read(selectExerciseSearchQueryProvider.notifier).state = value;
                    setState(() {});
                  },
                ),
              ),

              // Filter & Sort Row
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Row(
                  children: [
                    // Sort Menu Button
                    PopupMenuButton<ExerciseSortOption>(
                      initialValue: selectedSort,
                      onSelected: (option) {
                        ref.read(selectExerciseSortOptionProvider.notifier).state = option;
                      },
                      itemBuilder: (context) => ExerciseSortOption.values.map((option) {
                        return PopupMenuItem(
                          value: option,
                          child: Row(
                            children: [
                              Icon(
                                option == selectedSort ? Icons.check : Icons.sort,
                                size: 18,
                                color: option == selectedSort ? Theme.of(context).colorScheme.primary : null,
                              ),
                              const SizedBox(width: 8),
                              Text(option.label),
                            ],
                          ),
                        );
                      }).toList(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.sort, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              selectedSort.label,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Equipment Filter Menu
                    PopupMenuButton<String>(
                      initialValue: selectedEquipment,
                      onSelected: (eq) {
                        ref.read(selectExerciseEquipmentFilterProvider.notifier).state = eq == 'All' ? null : eq;
                      },
                      itemBuilder: (context) => SelectExercisesScreen.equipmentFilters.map((eq) {
                        final isChosen = (eq == 'All' && selectedEquipment == 'All') || selectedEquipment == eq;
                        return PopupMenuItem(
                          value: eq,
                          child: Row(
                            children: [
                              Icon(
                                isChosen ? Icons.check : Icons.fitness_center,
                                size: 18,
                                color: isChosen ? Theme.of(context).colorScheme.primary : null,
                              ),
                              const SizedBox(width: 8),
                              Text(eq),
                            ],
                          ),
                        );
                      }).toList(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: selectedEquipment != 'All'
                              ? Theme.of(context).colorScheme.primaryContainer
                              : Theme.of(context).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.fitness_center,
                              size: 14,
                              color: selectedEquipment != 'All'
                                  ? Theme.of(context).colorScheme.onPrimaryContainer
                                  : null,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              selectedEquipment == 'All' ? 'Equipment' : selectedEquipment,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: selectedEquipment != 'All'
                                    ? Theme.of(context).colorScheme.onPrimaryContainer
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Muscle Group Filter Chips
                    ...SelectExercisesScreen.muscleFilters.map((muscle) {
                      final isSelected = selectedMuscle == muscle || (muscle == 'All' && selectedMuscle == 'All');
                      return Padding(
                        padding: const EdgeInsets.only(right: 6.0),
                        child: ChoiceChip(
                          label: Text(muscle, style: const TextStyle(fontSize: 12)),
                          selected: isSelected,
                          onSelected: (sel) {
                            if (sel) {
                              ref.read(selectExerciseMuscleGroupFilterProvider.notifier).state =
                                  muscle == 'All' ? null : muscle;
                            }
                          },
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: asyncExercises.when(
        data: (_) {
          if (filteredExercises.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off_rounded, size: 48, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  const SizedBox(height: 12),
                  const Text('No exercises found', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text('Try clearing your search query or muscle filter', style: TextStyle(fontSize: 13, color: Colors.grey)),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () {
                      _clearSearch();
                      ref.read(selectExerciseMuscleGroupFilterProvider.notifier).state = null;
                      ref.read(selectExerciseEquipmentFilterProvider.notifier).state = null;
                    },
                    icon: const Icon(Icons.refresh_rounded, size: 16),
                    label: const Text('Reset All Filters'),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            itemCount: filteredExercises.length,
            padding: const EdgeInsets.symmetric(vertical: 6),
            itemBuilder: (context, index) {
              final exercise = filteredExercises[index];
              final isSelected = selectedExercises.any((e) => e.id == exercise.id);

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                // Clickable Thumbnail with visual tap feedback
                leading: GestureDetector(
                  onTap: () {
                    ExercisePreviewModal.show(
                      context,
                      exercise: exercise,
                      isSelected: isSelected,
                      onSelect: () => _toggleExercise(exercise),
                    );
                  },
                  child: Stack(
                    children: [
                      ExerciseVisualCard(
                        exercise: exercise,
                        width: 48,
                        height: 48,
                        borderRadius: 10,
                        showLabels: false,
                        isHero: false,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(1.5),
                          decoration: const BoxDecoration(
                            color: Colors.black87,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.info_outline, size: 10, color: Colors.white70),
                        ),
                      ),
                    ],
                  ),
                ),
                title: Text(exercise.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(
                  '${exercise.muscleGroup} • ${exercise.equipment}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
                trailing: Checkbox(
                  value: isSelected,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  onChanged: (_) => _toggleExercise(exercise),
                ),
                onTap: () => _toggleExercise(exercise),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: selectedExercises.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () {
                context.pop(selectedExercises);
              },
              icon: const Icon(Icons.check),
              label: Text('Add ${selectedExercises.length} Exercise${selectedExercises.length > 1 ? 's' : ''}'),
            )
          : null,
    );
  }
}
