import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/exercise_model.dart';
import '../../providers/exercise_provider.dart';

class CreateExerciseScreen extends ConsumerStatefulWidget {
  const CreateExerciseScreen({super.key});

  @override
  ConsumerState<CreateExerciseScreen> createState() => _CreateExerciseScreenState();
}

class _CreateExerciseScreenState extends ConsumerState<CreateExerciseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _instructionsController = TextEditingController();
  
  String _selectedMuscleGroup = 'Chest';
  String _selectedEquipment = 'None';
  bool _isLoading = false;

  final List<String> _muscleGroups = [
    'Chest', 'Back', 'Legs', 'Shoulders', 'Arms', 'Core', 'Cardio', 'Other'
  ];

  final List<String> _equipmentOptions = [
    'None', 'Dumbbell', 'Barbell', 'Machine', 'Cable', 'Kettlebell', 'Band'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userId = ref.read(mockUserIdProvider);
      
      final newExercise = Exercise(
        id: '', // Will be assigned by Firestore
        name: _nameController.text.trim(),
        muscleGroup: _selectedMuscleGroup,
        equipment: _selectedEquipment,
        instructions: _instructionsController.text.trim(),
        isCustom: true,
        userId: userId,
      );

      await ref.read(exerciseRepositoryProvider).createCustomExercise(newExercise);
      
      // Invalidate the provider to fetch the new exercise
      ref.invalidate(exerciseListProvider);
      
      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Exercise created successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Custom Exercise')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Exercise Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedMuscleGroup,
              decoration: const InputDecoration(
                labelText: 'Muscle Group',
                border: OutlineInputBorder(),
              ),
              items: _muscleGroups.map((group) {
                return DropdownMenuItem(
                  value: group,
                  child: Text(group),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedMuscleGroup = val);
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedEquipment,
              decoration: const InputDecoration(
                labelText: 'Equipment',
                border: OutlineInputBorder(),
              ),
              items: _equipmentOptions.map((eq) {
                return DropdownMenuItem(
                  value: eq,
                  child: Text(eq),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedEquipment = val);
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _instructionsController,
              decoration: const InputDecoration(
                labelText: 'Instructions (Optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              child: _isLoading 
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Save Exercise'),
            ),
          ],
        ),
      ),
    );
  }
}
