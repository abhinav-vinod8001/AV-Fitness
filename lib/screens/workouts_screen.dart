import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../models/workout_model.dart';
import '../models/folder_model.dart';
import '../providers/workout_provider.dart';
import '../core/utils/app_animations.dart';
import '../providers/active_workout_provider.dart';
import '../providers/exercise_provider.dart';

class WorkoutsScreen extends ConsumerStatefulWidget {
  const WorkoutsScreen({super.key});

  @override
  ConsumerState<WorkoutsScreen> createState() => _WorkoutsScreenState();
}

class _WorkoutsScreenState extends ConsumerState<WorkoutsScreen> {
  final Set<String> _expandedFolders = {};
  final TextEditingController _routineSearchController =
      TextEditingController();
  String _routineSearchQuery = '';

  @override
  void dispose() {
    _routineSearchController.dispose();
    super.dispose();
  }

  Future<void> _createFolder() async {
    HapticFeedback.lightImpact();
    String folderName = '';
    final confirmed = await AppAnimations.showAnimatedDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Folder'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Folder Name (e.g. Upper/Lower, Hypertrophy)',
          ),
          onChanged: (val) => folderName = val,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (confirmed == true && folderName.trim().isNotEmpty) {
      final repo = ref.read(folderRepositoryProvider);
      final userId = ref.read(mockUserIdProvider);
      final newFolderId = const Uuid().v4();
      await repo.saveFolder(
        WorkoutFolder(
          id: newFolderId,
          name: folderName.trim(),
          userId: userId,
          createdAt: DateTime.now(),
        ),
      );
      setState(() {
        // Auto-expand new folder so user sees it ready
        _expandedFolders.add(newFolderId);
      });
      ref.invalidate(workoutFoldersProvider);
    }
  }

  Future<void> _editFolder(WorkoutFolder folder) async {
    HapticFeedback.lightImpact();
    String newName = folder.name;
    final confirmed = await AppAnimations.showAnimatedDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename Folder'),
        content: TextFormField(
          initialValue: folder.name,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Folder Name'),
          onChanged: (val) => newName = val,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (confirmed == true &&
        newName.trim().isNotEmpty &&
        newName.trim() != folder.name) {
      final repo = ref.read(folderRepositoryProvider);
      await repo.saveFolder(folder.copyWith(name: newName.trim()));
      ref.invalidate(workoutFoldersProvider);
    }
  }

  Future<void> _deleteFolder(WorkoutFolder folder) async {
    HapticFeedback.mediumImpact();
    final confirmed = await AppAnimations.showAnimatedDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Folder?'),
        content: Text(
          'Are you sure you want to delete "${folder.name}"? Routines inside will be preserved and moved to unassigned.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              'Delete Folder',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final folderRepo = ref.read(folderRepositoryProvider);
      final workoutRepo = ref.read(workoutRepositoryProvider);

      // Unassign any templates in this folder
      final templates = ref.read(workoutTemplatesProvider).valueOrNull ?? [];
      for (final t in templates) {
        if (t.folderId == folder.id) {
          await workoutRepo.saveTemplate(t.copyWith(folderId: ''));
        }
      }

      await folderRepo.deleteFolder(folder.id);
      ref.invalidate(workoutFoldersProvider);
      ref.invalidate(workoutTemplatesProvider);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Deleted "${folder.name}"')));
      }
    }
  }

  Future<void> _addExistingRoutinesToFolder(
    WorkoutFolder folder,
    List<WorkoutTemplate> allTemplates,
    List<WorkoutFolder> allFolders,
  ) async {
    HapticFeedback.lightImpact();
    final initialSelectedIds = allTemplates
        .where((t) => t.folderId == folder.id)
        .map((t) => t.id)
        .toSet();
    final selectedIds = Set<String>.from(initialSelectedIds);
    final cs = Theme.of(context).colorScheme;

    final confirmed = await AppAnimations.showAnimatedDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.folder_rounded, color: cs.primary, size: 24),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Manage "${folder.name}"',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: allTemplates.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Text(
                          'No routines exist yet. Tap "Create New Routine" to make one!',
                          textAlign: TextAlign.center,
                        ),
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Select routines to include in this folder:',
                            style: TextStyle(
                              fontSize: 13,
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Flexible(
                            child: ListView.separated(
                              shrinkWrap: true,
                              itemCount: allTemplates.length,
                              separatorBuilder: (_, _) =>
                                  const Divider(height: 1),
                              itemBuilder: (ctx, index) {
                                final t = allTemplates[index];
                                final isSelected = selectedIds.contains(t.id);
                                final currentFolderName =
                                    t.folderId == null || t.folderId!.isEmpty
                                    ? 'Unassigned'
                                    : (allFolders
                                          .firstWhere(
                                            (f) => f.id == t.folderId,
                                            orElse: () => WorkoutFolder(
                                              id: '',
                                              name: 'Other',
                                              userId: '',
                                              createdAt: DateTime.now(),
                                            ),
                                          )
                                          .name);

                                return CheckboxListTile(
                                  value: isSelected,
                                  activeColor: cs.primary,
                                  title: Text(
                                    t.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                                  subtitle: Text(
                                    t.folderId == folder.id
                                        ? 'Currently in this folder'
                                        : 'Currently in $currentFolderName',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: cs.onSurfaceVariant,
                                    ),
                                  ),
                                  onChanged: (val) {
                                    setDialogState(() {
                                      if (val == true) {
                                        selectedIds.add(t.id);
                                      } else {
                                        selectedIds.remove(t.id);
                                      }
                                    });
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cs.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: Text('Save (${selectedIds.length})'),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmed == true) {
      final repo = ref.read(workoutRepositoryProvider);
      for (final t in allTemplates) {
        final wasInFolder = t.folderId == folder.id;
        final shouldBeInFolder = selectedIds.contains(t.id);
        if (shouldBeInFolder && !wasInFolder) {
          await repo.saveTemplate(t.copyWith(folderId: folder.id));
        } else if (!shouldBeInFolder && wasInFolder) {
          await repo.saveTemplate(t.copyWith(folderId: ''));
        }
      }
      setState(() {
        _expandedFolders.add(folder.id);
      });
      ref.invalidate(workoutTemplatesProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Updated routines in "${folder.name}"')),
        );
      }
    }
  }

  void _createNewRoutineInFolder(WorkoutFolder folder) {
    HapticFeedback.lightImpact();
    context.push('/workouts/build', extra: {'folderId': folder.id});
  }

  Future<void> _removeTemplateFromFolder(WorkoutTemplate template) async {
    HapticFeedback.lightImpact();
    final repo = ref.read(workoutRepositoryProvider);
    await repo.saveTemplate(template.copyWith(folderId: ''));
    ref.invalidate(workoutTemplatesProvider);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Removed "${template.name}" from folder')),
      );
    }
  }

  Future<void> _moveTemplate(
    WorkoutTemplate template,
    List<WorkoutFolder> folders,
  ) async {
    HapticFeedback.lightImpact();
    final cs = Theme.of(context).colorScheme;

    final selectedFolderId = await AppAnimations.showAnimatedDialog<String?>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Move to Folder'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              ListTile(
                leading: const Icon(Icons.folder_off_outlined),
                title: const Text('No Folder (Unassigned)'),
                selected:
                    template.folderId == null || template.folderId!.isEmpty,
                onTap: () => Navigator.of(ctx).pop(''),
              ),
              const Divider(),
              ...folders.map(
                (f) => ListTile(
                  leading: Icon(Icons.folder_rounded, color: cs.primary),
                  title: Text(f.name),
                  selected: template.folderId == f.id,
                  onTap: () => Navigator.of(ctx).pop(f.id),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(null),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (selectedFolderId != null &&
        selectedFolderId != (template.folderId ?? '')) {
      final repo = ref.read(workoutRepositoryProvider);
      await repo.saveTemplate(template.copyWith(folderId: selectedFolderId));
      ref.invalidate(workoutTemplatesProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final templatesAsync = ref.watch(workoutTemplatesProvider);
    final foldersAsync = ref.watch(workoutFoldersProvider);
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(workoutTemplatesProvider);
              ref.invalidate(workoutFoldersProvider);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 90.0, left: 16.0, right: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // ── Start Empty Workout Button ───────────────
            InkWell(
              onTap: () {
                HapticFeedback.mediumImpact();
                final emptyTemplate = WorkoutTemplate(
                  id: 'empty-${DateTime.now().millisecondsSinceEpoch}',
                  name: 'Quick Workout',
                  exercises: [],
                );
                ref
                    .read(activeWorkoutProvider.notifier)
                    .startWorkout(emptyTemplate);
                context.push('/workouts/active');
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF121212) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: cs.primary.withValues(alpha: 0.4),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: cs.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.add_rounded,
                        color: cs.primary,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Start Empty Workout',
                            style: TextStyle(
                              color: cs.onSurface,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Log a custom workout on the fly',
                            style: TextStyle(
                              color: cs.onSurfaceVariant,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: cs.onSurfaceVariant.withValues(alpha: 0.6),
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),

            // ── Routines Header ──────────────────────────
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Routines',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  icon: Icon(
                    Icons.create_new_folder_outlined,
                    size: 16,
                    color: cs.primary,
                  ),
                  label: Text(
                    'Folder',
                    style: TextStyle(
                      color: cs.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    side: BorderSide(color: cs.primary.withValues(alpha: 0.5)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _createFolder,
                ),
                const SizedBox(width: 6),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text(
                    'Routine',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cs.primary,
                    foregroundColor: Colors.white,
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    context.push('/workouts/build');
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Routines & Folders Content ───────────────
            templatesAsync.when(
              data: (templates) {
                final isSearching = _routineSearchQuery.isNotEmpty;
                final matchingTemplates = !isSearching
                    ? templates
                    : templates.where((t) {
                        final nameMatch = t.name.toLowerCase().contains(
                          _routineSearchQuery,
                        );
                        final exMatch = t.exercises.any(
                          (e) => e.exerciseName.toLowerCase().contains(
                            _routineSearchQuery,
                          ),
                        );
                        return nameMatch || exMatch;
                      }).toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (templates.isNotEmpty) ...[
                      TextField(
                        controller: _routineSearchController,
                        decoration: InputDecoration(
                          hintText: 'Search routines or exercises...',
                          hintStyle: const TextStyle(fontSize: 13),
                          prefixIcon: const Icon(Icons.search, size: 20),
                          suffixIcon: _routineSearchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(
                                    Icons.clear_rounded,
                                    size: 18,
                                  ),
                                  onPressed: () {
                                    _routineSearchController.clear();
                                    setState(() {
                                      _routineSearchQuery = '';
                                    });
                                  },
                                )
                              : null,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 10,
                          ),
                          filled: true,
                          fillColor: isDark
                              ? const Color(0xFF161616)
                              : Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest
                                    .withValues(alpha: 0.5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (val) {
                          setState(() {
                            _routineSearchQuery = val.trim().toLowerCase();
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (isSearching && matchingTemplates.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.search_off_rounded,
                                size: 40,
                                color: cs.onSurfaceVariant,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'No routines found matching "$_routineSearchQuery"',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              TextButton(
                                onPressed: () {
                                  _routineSearchController.clear();
                                  setState(() => _routineSearchQuery = '');
                                },
                                child: const Text('Clear search'),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      foldersAsync.when(
                        data: (folders) {
                          final unassignedTemplates = matchingTemplates
                              .where(
                                (t) =>
                                    t.folderId == null || t.folderId!.isEmpty,
                              )
                              .toList();

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Display Folders
                              ...folders.map((folder) {
                                final folderTemplates = matchingTemplates
                                    .where((t) => t.folderId == folder.id)
                                    .toList();
                                if (isSearching && folderTemplates.isEmpty) {
                                  return const SizedBox.shrink();
                                }
                                final isExpanded =
                                    isSearching ||
                                    _expandedFolders.contains(folder.id);

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: Material(
                                    color: isDark
                                        ? const Color(0xFF121212)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      side: BorderSide(
                                        color: isDark
                                            ? const Color(0xFF262626)
                                            : const Color(0xFFE5E5E5),
                                        width: 1.0,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Folder Header Tile
                                        InkWell(
                                          onTap: () {
                                            setState(() {
                                              if (isExpanded) {
                                                _expandedFolders.remove(
                                                  folder.id,
                                                );
                                              } else {
                                                _expandedFolders.add(folder.id);
                                              }
                                            });
                                            HapticFeedback.selectionClick();
                                          },
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 14.0,
                                              vertical: 12.0,
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  isExpanded
                                                      ? Icons
                                                            .keyboard_arrow_down_rounded
                                                      : Icons
                                                            .keyboard_arrow_right_rounded,
                                                  color: cs.onSurfaceVariant,
                                                  size: 24,
                                                ),
                                                const SizedBox(width: 4),
                                                Icon(
                                                  isExpanded
                                                      ? Icons
                                                            .folder_open_rounded
                                                      : Icons.folder_rounded,
                                                  color: cs.primary,
                                                  size: 24,
                                                ),
                                                const SizedBox(width: 10),
                                                Expanded(
                                                  child: Text(
                                                    folder.name,
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 7,
                                                        vertical: 2,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: cs.primary
                                                        .withValues(
                                                          alpha: 0.12,
                                                        ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          6,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    '${folderTemplates.length}',
                                                    style: TextStyle(
                                                      color: cs.primary,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 2),
                                                IconButton(
                                                  icon: Icon(
                                                    Icons
                                                        .add_circle_outline_rounded,
                                                    color: cs.primary,
                                                    size: 20,
                                                  ),
                                                  tooltip:
                                                      'Add Routine to Folder',
                                                  visualDensity:
                                                      VisualDensity.compact,
                                                  padding: const EdgeInsets.all(
                                                    6,
                                                  ),
                                                  constraints:
                                                      const BoxConstraints(),
                                                  onPressed: () {
                                                    _addExistingRoutinesToFolder(
                                                      folder,
                                                      templates,
                                                      folders,
                                                    );
                                                  },
                                                ),
                                                PopupMenuButton<String>(
                                                  icon: Icon(
                                                    Icons.more_vert_rounded,
                                                    size: 20,
                                                    color: cs.onSurfaceVariant,
                                                  ),
                                                  padding: const EdgeInsets.all(
                                                    6,
                                                  ),
                                                  constraints:
                                                      const BoxConstraints(),
                                                  onSelected: (value) {
                                                    if (value ==
                                                        'add_existing') {
                                                      _addExistingRoutinesToFolder(
                                                        folder,
                                                        templates,
                                                        folders,
                                                      );
                                                    } else if (value ==
                                                        'create_new') {
                                                      _createNewRoutineInFolder(
                                                        folder,
                                                      );
                                                    } else if (value ==
                                                        'rename') {
                                                      _editFolder(folder);
                                                    } else if (value ==
                                                        'delete') {
                                                      _deleteFolder(folder);
                                                    }
                                                  },
                                                  itemBuilder: (context) => [
                                                    const PopupMenuItem(
                                                      value: 'add_existing',
                                                      child: Row(
                                                        children: [
                                                          Icon(
                                                            Icons
                                                                .playlist_add_rounded,
                                                            size: 18,
                                                          ),
                                                          SizedBox(width: 8),
                                                          Text(
                                                            'Add Existing Routines',
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    const PopupMenuItem(
                                                      value: 'create_new',
                                                      child: Row(
                                                        children: [
                                                          Icon(
                                                            Icons.add_rounded,
                                                            size: 18,
                                                          ),
                                                          SizedBox(width: 8),
                                                          Text(
                                                            'Create New Routine Here',
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    const PopupMenuItem(
                                                      value: 'rename',
                                                      child: Row(
                                                        children: [
                                                          Icon(
                                                            Icons.edit_outlined,
                                                            size: 18,
                                                          ),
                                                          SizedBox(width: 8),
                                                          Text('Rename Folder'),
                                                        ],
                                                      ),
                                                    ),
                                                    const PopupMenuItem(
                                                      value: 'delete',
                                                      child: Row(
                                                        children: [
                                                          Icon(
                                                            Icons
                                                                .delete_outline,
                                                            color: Colors.red,
                                                            size: 18,
                                                          ),
                                                          SizedBox(width: 8),
                                                          Text(
                                                            'Delete Folder',
                                                            style: TextStyle(
                                                              color: Colors.red,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),

                                        // Folder Content (Expanded)
                                        if (isExpanded) ...[
                                          const Divider(height: 1),
                                          if (folderTemplates.isEmpty)
                                            Padding(
                                              padding: const EdgeInsets.all(
                                                20.0,
                                              ),
                                              child: Column(
                                                children: [
                                                  Text(
                                                    'No routines in this folder yet.',
                                                    style: TextStyle(
                                                      color:
                                                          cs.onSurfaceVariant,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 12),
                                                  Wrap(
                                                    alignment:
                                                        WrapAlignment.center,
                                                    spacing: 10,
                                                    runSpacing: 8,
                                                    children: [
                                                      ElevatedButton.icon(
                                                        onPressed: () =>
                                                            _addExistingRoutinesToFolder(
                                                              folder,
                                                              templates,
                                                              folders,
                                                            ),
                                                        icon: const Icon(
                                                          Icons
                                                              .playlist_add_rounded,
                                                          size: 16,
                                                        ),
                                                        label: const Text(
                                                          'Add Existing',
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor:
                                                              cs.primary,
                                                          foregroundColor:
                                                              Colors.white,
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                                horizontal: 14,
                                                                vertical: 8,
                                                              ),
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  8,
                                                                ),
                                                          ),
                                                        ),
                                                      ),
                                                      OutlinedButton.icon(
                                                        onPressed: () =>
                                                            _createNewRoutineInFolder(
                                                              folder,
                                                            ),
                                                        icon: const Icon(
                                                          Icons.add_rounded,
                                                          size: 16,
                                                        ),
                                                        label: const Text(
                                                          'Create New',
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                        style: OutlinedButton.styleFrom(
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                                horizontal: 14,
                                                                vertical: 8,
                                                              ),
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  8,
                                                                ),
                                                          ),
                                                          side: BorderSide(
                                                            color: cs
                                                                .outlineVariant,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            )
                                          else ...[
                                            Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                    12,
                                                    12,
                                                    12,
                                                    4,
                                                  ),
                                              child: Column(
                                                children: [
                                                  _buildReorderableTemplateList(
                                                    folderTemplates,
                                                    folders,
                                                    inFolder: true,
                                                  ),
                                                  const SizedBox(height: 6),
                                                  Center(
                                                    child: TextButton.icon(
                                                      onPressed: () =>
                                                          _addExistingRoutinesToFolder(
                                                            folder,
                                                            templates,
                                                            folders,
                                                          ),
                                                      icon: Icon(
                                                        Icons.add_rounded,
                                                        size: 16,
                                                        color: cs.primary,
                                                      ),
                                                      label: Text(
                                                        'Add / Manage Routines in this folder',
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: cs.primary,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ],
                                      ],
                                    ),
                                  ),
                                );
                              }),

                              const SizedBox(height: 12),

                              // ── My Routines (Unassigned) ─────────────────
                              Row(
                                children: [
                                  Icon(
                                    Icons.fitness_center_rounded,
                                    size: 18,
                                    color: cs.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'My Routines (${unassignedTemplates.length})',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              if (unassignedTemplates.isEmpty &&
                                  folders.isEmpty)
                                Container(
                                  padding: const EdgeInsets.all(32.0),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? const Color(0xFF121212)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isDark
                                          ? const Color(0xFF262626)
                                          : const Color(0xFFE5E5E5),
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.fitness_center_outlined,
                                        size: 48,
                                        color: cs.onSurfaceVariant.withValues(
                                          alpha: 0.4,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      const Text(
                                        'No routines created yet.',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Tap "+ Routine" to build your first training plan.',
                                        style: TextStyle(
                                          color: cs.onSurfaceVariant,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              else if (unassignedTemplates.isEmpty)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8.0,
                                  ),
                                  child: Text(
                                    'All your routines are organized into folders!',
                                    style: TextStyle(
                                      color: cs.onSurfaceVariant,
                                      fontSize: 13,
                                    ),
                                  ),
                                )
                              else
                                _buildReorderableTemplateList(
                                  unassignedTemplates,
                                  folders,
                                  inFolder: false,
                                ),
                            ],
                          );
                        },
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (e, st) =>
                            Center(child: Text('Error loading folders: $e')),
                      ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) =>
                  Center(child: Text('Error loading routines: $e')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReorderableTemplateList(
    List<WorkoutTemplate> templates,
    List<WorkoutFolder> folders, {
    required bool inFolder,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: templates.length,
      // ignore: deprecated_member_use
      onReorder: (oldIndex, newIndex) {
        HapticFeedback.mediumImpact();
        if (oldIndex < newIndex) {
          newIndex -= 1;
        }
        final reordered = List<WorkoutTemplate>.from(templates);
        final item = reordered.removeAt(oldIndex);
        reordered.insert(newIndex, item);
        reorderTemplates(ref, reordered);
      },
      proxyDecorator: (child, index, animation) {
        return Material(
          elevation: 6,
          borderRadius: BorderRadius.circular(16),
          color: isDark ? const Color(0xFF161616) : Colors.white,
          child: child,
        );
      },
      itemBuilder: (context, index) {
        final template = templates[index];
        return _buildTemplateCard(
          template,
          folders,
          inFolder: inFolder,
          key: ValueKey(template.id),
        );
      },
    );
  }

  Widget _buildTemplateCard(
    WorkoutTemplate template,
    List<WorkoutFolder> folders, {
    required bool inFolder,
    Key? key,
  }) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final exerciseNames = template.exercises
        .map((e) => e.exerciseName)
        .join(', ');

    return Card(
      key: key,
      margin: const EdgeInsets.only(bottom: 12),
      color: isDark ? const Color(0xFF121212) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? const Color(0xFF262626) : const Color(0xFFE5E5E5),
          width: 1.0,
        ),
      ),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ReorderableDragStartListener(
                  index: 0,
                  child: Icon(
                    Icons.drag_handle_rounded,
                    color: cs.onSurfaceVariant.withValues(alpha: 0.4),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    template.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_horiz),
                  onSelected: (value) async {
                    if (value == 'start') {
                      HapticFeedback.mediumImpact();
                      ref
                          .read(activeWorkoutProvider.notifier)
                          .startWorkout(template);
                      context.push('/workouts/active');
                    } else if (value == 'edit') {
                      context.push('/workouts/build', extra: template);
                    } else if (value == 'remove_folder') {
                      _removeTemplateFromFolder(template);
                    } else if (value == 'move') {
                      _moveTemplate(template, folders);
                    } else if (value == 'delete') {
                      final confirmed =
                          await AppAnimations.showAnimatedDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Delete Routine?'),
                              content: Text(
                                'Are you sure you want to delete "${template.name}"?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(true),
                                  child: const Text(
                                    'Delete',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          );
                      if (confirmed == true) {
                        final repo = ref.read(workoutRepositoryProvider);
                        await repo.deleteTemplate(template.id);
                        ref.invalidate(workoutTemplatesProvider);
                      }
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'start',
                      child: Row(
                        children: [
                          Icon(Icons.play_arrow_rounded, size: 18),
                          SizedBox(width: 8),
                          Text('Start Routine'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 18),
                          SizedBox(width: 8),
                          Text('Edit Routine'),
                        ],
                      ),
                    ),
                    if (inFolder)
                      const PopupMenuItem(
                        value: 'remove_folder',
                        child: Row(
                          children: [
                            Icon(Icons.folder_off_outlined, size: 18),
                            SizedBox(width: 8),
                            Text('Remove from Folder'),
                          ],
                        ),
                      ),
                    const PopupMenuItem(
                      value: 'move',
                      child: Row(
                        children: [
                          Icon(Icons.drive_file_move_outlined, size: 18),
                          SizedBox(width: 8),
                          Text('Move to Folder...'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                            size: 18,
                          ),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              exerciseNames.isNotEmpty ? exerciseNames : 'No exercises added',
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  ref
                      .read(activeWorkoutProvider.notifier)
                      .startWorkout(template);
                  context.push('/workouts/active');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: cs.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'Start Routine',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
