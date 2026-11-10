import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../providers/workout_provider.dart';
import '../../providers/exercise_provider.dart';
import '../../core/utils/app_animations.dart';
import '../../models/exercise_model.dart';
import '../../models/workout_model.dart';
import '../../models/folder_model.dart';

class WorkoutBuilderScreen extends ConsumerStatefulWidget {
  final WorkoutTemplate? existingTemplate;
  final String? initialFolderId;

  const WorkoutBuilderScreen({
    super.key,
    this.existingTemplate,
    this.initialFolderId,
  });

  @override
  ConsumerState<WorkoutBuilderScreen> createState() => _WorkoutBuilderScreenState();
}

class _WorkoutBuilderScreenState extends ConsumerState<WorkoutBuilderScreen> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.existingTemplate?.name ?? 'New Routine');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.existingTemplate != null) {
        ref.read(workoutBuilderProvider.notifier).loadTemplate(widget.existingTemplate!);
      } else if (widget.initialFolderId != null) {
        ref.read(workoutBuilderProvider.notifier).updateFolderId(widget.initialFolderId);
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _selectFolder(List<WorkoutFolder> folders, String? currentFolderId) async {
    HapticFeedback.lightImpact();
    final cs = Theme.of(context).colorScheme;

    final selected = await AppAnimations.showAnimatedDialog<String?>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Assign to Folder'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.folder_off_outlined),
                title: const Text('None (Unassigned)'),
                selected: currentFolderId == null || currentFolderId.isEmpty,
                onTap: () => Navigator.pop(ctx, ''),
              ),
              const Divider(),
              ...folders.map((f) => ListTile(
                    leading: Icon(Icons.folder_rounded, color: cs.primary),
                    title: Text(f.name),
                    selected: currentFolderId == f.id,
                    onTap: () => Navigator.pop(ctx, f.id),
                  )),
              const Divider(),
              ListTile(
                leading: Icon(Icons.create_new_folder_outlined, color: cs.primary),
                title: Text('Create New Folder', style: TextStyle(color: cs.primary, fontWeight: FontWeight.bold)),
                onTap: () async {
                  Navigator.pop(ctx, '__create__');
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, null), child: const Text('Cancel')),
        ],
      ),
    );

    if (selected == '__create__') {
      if (!mounted) return;
      String folderName = '';
      final confirmed = await AppAnimations.showAnimatedDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('New Folder'),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Folder Name'),
            onChanged: (val) => folderName = val,
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Create')),
          ],
        ),
      );

      if (confirmed == true && folderName.trim().isNotEmpty) {
        final folderRepo = ref.read(folderRepositoryProvider);
        final userId = ref.read(mockUserIdProvider);
        final newFolder = WorkoutFolder(
          id: const Uuid().v4(),
          name: folderName.trim(),
          userId: userId,
          createdAt: DateTime.now(),
        );
        await folderRepo.saveFolder(newFolder);
        ref.invalidate(workoutFoldersProvider);
        ref.read(workoutBuilderProvider.notifier).updateFolderId(newFolder.id);
      }
    } else if (selected != null) {
      ref.read(workoutBuilderProvider.notifier).updateFolderId(selected.isEmpty ? null : selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final workout = ref.watch(workoutBuilderProvider);
    final foldersAsync = ref.watch(workoutFoldersProvider);
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final folders = foldersAsync.valueOrNull ?? [];
    final currentFolderName = folders.firstWhere(
      (f) => f.id == workout.folderId,
      orElse: () => WorkoutFolder(id: '', name: 'None (Unassigned)', userId: '', createdAt: DateTime.now()),
    ).name;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingTemplate != null ? 'Edit Routine' : 'Routine Builder'),
        actions: [
          TextButton(
            onPressed: () async {
              HapticFeedback.mediumImpact();
              ref.read(workoutBuilderProvider.notifier).updateName(_nameController.text.trim());
              await ref.read(workoutBuilderProvider.notifier).saveRoutine();
              if (context.mounted) {
                context.pop();
              }
            },
            child: const Text('SAVE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _nameController,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Routine Name',
                  ),
                  onChanged: (val) {
                    ref.read(workoutBuilderProvider.notifier).updateName(val);
                  },
                ),
                const SizedBox(height: 6),
                InkWell(
                  onTap: () => _selectFolder(folders, workout.folderId),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF141414) : Colors.black.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDark ? const Color(0xFF262626) : const Color(0xFFE5E5E5),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          workout.folderId != null && workout.folderId!.isNotEmpty
                              ? Icons.folder_rounded
                              : Icons.folder_off_outlined,
                          size: 18,
                          color: workout.folderId != null && workout.folderId!.isNotEmpty ? cs.primary : cs.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Folder: $currentFolderName',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: workout.folderId != null && workout.folderId!.isNotEmpty ? cs.onSurface : cs.onSurfaceVariant,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.arrow_drop_down, size: 18, color: cs.onSurfaceVariant),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: workout.exercises.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.fitness_center_outlined, size: 64, color: cs.onSurfaceVariant.withValues(alpha: 0.4)),
                        const SizedBox(height: 16),
                        const Text('No exercises added yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Text('Tap "Add Exercise" below to start building', style: TextStyle(color: cs.onSurfaceVariant, fontSize: 14)),
                      ],
                    ),
                  )
                : ReorderableListView.builder(
                    itemCount: workout.exercises.length,
                    // ignore: deprecated_member_use
                    onReorder: (oldIndex, newIndex) {
                      ref.read(workoutBuilderProvider.notifier).reorderExercises(oldIndex, newIndex);
                    },
                    proxyDecorator: (child, index, animation) {
                      return Material(
                        elevation: 4,
                        borderRadius: BorderRadius.circular(16),
                        color: isDark ? const Color(0xFF161616) : Colors.white,
                        child: child,
                      );
                    },
                    itemBuilder: (context, index) {
                      final exercise = workout.exercises[index];
                      return _buildExerciseCard(context, exercise, ValueKey(exercise.id));
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              onPressed: () async {
                final selected = await context.push<List<Exercise>>('/workouts/build/select-exercises');
                if (selected != null && selected.isNotEmpty) {
                  ref.read(workoutBuilderProvider.notifier).addExercises(selected);
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Exercise'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(BuildContext context, WorkoutExercise exercise, Key key) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      key: key,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      color: isDark ? const Color(0xFF121212) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? const Color(0xFF262626) : const Color(0xFFE5E5E5),
          width: 1.0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    exercise.exerciseName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () {
                    AppAnimations.showAnimatedBottomSheet(
                      context: context,
                      builder: (ctx) => SafeArea(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: const Icon(Icons.delete, color: Colors.red),
                              title: const Text('Remove Exercise', style: TextStyle(color: Colors.red)),
                              onTap: () {
                                ref.read(workoutBuilderProvider.notifier).removeExercise(exercise.id);
                                Navigator.pop(ctx);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: const [
                SizedBox(width: 32, child: Text('Set', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                Expanded(child: Text('Weight', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                Expanded(child: Text('Reps', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                Expanded(child: Text('RPE', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                SizedBox(width: 48),
              ],
            ),
            const Divider(),
            ...exercise.sets.map((set) => _buildSetRow(context, exercise.id, set)),
            TextButton(
              onPressed: () {
                ref.read(workoutBuilderProvider.notifier).addSet(exercise.id);
              },
              child: const Text('+ Add Set'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSetRow(BuildContext context, String workoutExerciseId, WorkoutSet set) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text('${set.setNumber}', textAlign: TextAlign.center),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: TextFormField(
                initialValue: set.weight == 0 ? '' : set.weight.toString(),
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(hintText: '-', isDense: true, border: OutlineInputBorder()),
                onChanged: (val) {
                  final weight = double.tryParse(val);
                  ref.read(workoutBuilderProvider.notifier).updateSet(workoutExerciseId, set.id, weight: weight);
                },
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: TextFormField(
                initialValue: set.reps == 0 ? '' : set.reps.toString(),
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(hintText: '-', isDense: true, border: OutlineInputBorder()),
                onChanged: (val) {
                  final reps = int.tryParse(val);
                  ref.read(workoutBuilderProvider.notifier).updateSet(workoutExerciseId, set.id, reps: reps);
                },
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: TextFormField(
                initialValue: set.rpe == null ? '' : set.rpe.toString(),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                textAlign: TextAlign.center,
                decoration: const InputDecoration(hintText: '-', isDense: true, border: OutlineInputBorder()),
                onChanged: (val) {
                  final rpe = double.tryParse(val);
                  ref.read(workoutBuilderProvider.notifier).updateSet(workoutExerciseId, set.id, rpe: rpe);
                },
              ),
            ),
          ),
          SizedBox(
            width: 48,
            child: IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              onPressed: () {
                ref.read(workoutBuilderProvider.notifier).removeSet(workoutExerciseId, set.id);
              },
            ),
          ),
        ],
      ),
    );
  }
}
