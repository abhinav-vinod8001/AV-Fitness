import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/exercise_provider.dart';
import '../../widgets/exercise_list_tile.dart';

class ExercisesScreen extends ConsumerStatefulWidget {
  const ExercisesScreen({super.key});

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
  ConsumerState<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends ConsumerState<ExercisesScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    final initialQuery = ref.read(exerciseSearchQueryProvider);
    _searchController = TextEditingController(text: initialQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _searchController.clear();
    ref.read(exerciseSearchQueryProvider.notifier).state = '';
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final filteredExercises = ref.watch(filteredExercisesProvider);
    final asyncExercises = ref.watch(exerciseListProvider);
    final selectedMuscle = ref.watch(exerciseMuscleGroupFilterProvider) ?? 'All';
    final selectedEquipment = ref.watch(exerciseEquipmentFilterProvider) ?? 'All';
    final selectedSort = ref.watch(exerciseSortOptionProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Exercise Library', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
              // Search Field
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
                    ref.read(exerciseSearchQueryProvider.notifier).state = value;
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
                        ref.read(exerciseSortOptionProvider.notifier).state = option;
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
                        ref.read(exerciseEquipmentFilterProvider.notifier).state = eq == 'All' ? null : eq;
                      },
                      itemBuilder: (context) => ExercisesScreen.equipmentFilters.map((eq) {
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
                    ...ExercisesScreen.muscleFilters.map((muscle) {
                      final isSelected = selectedMuscle == muscle || (muscle == 'All' && selectedMuscle == 'All');
                      return Padding(
                        padding: const EdgeInsets.only(right: 6.0),
                        child: ChoiceChip(
                          label: Text(muscle, style: const TextStyle(fontSize: 12)),
                          selected: isSelected,
                          onSelected: (sel) {
                            if (sel) {
                              ref.read(exerciseMuscleGroupFilterProvider.notifier).state =
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
                      ref.read(exerciseMuscleGroupFilterProvider.notifier).state = null;
                      ref.read(exerciseEquipmentFilterProvider.notifier).state = null;
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
            padding: const EdgeInsets.only(bottom: 90, top: 6),
            itemBuilder: (context, index) {
              final exercise = filteredExercises[index];
              return ExerciseListTile(
                exercise: exercise,
                onTap: () {
                  context.push('/exercises/details', extra: exercise);
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text('Error: $error'),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 90.0),
        child: FloatingActionButton(
          onPressed: () {
            context.push('/exercises/create');
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
