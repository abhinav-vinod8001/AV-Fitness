import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/user_provider.dart';
import 'package:flutter/services.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late String _gender;
  late String _goal;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final userProfile = ref.read(userProfileProvider).valueOrNull;
    final user = userProfile?.model;
    
    _nameController = TextEditingController(text: user?.displayName ?? '');
    _heightController = TextEditingController(text: user?.height?.toString() ?? '');
    _weightController = TextEditingController(text: user?.weight?.toString() ?? '');
    _gender = user?.gender ?? 'Male';
    _goal = user?.goal ?? 'Build Muscle';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact();

    try {
      final userProfile = ref.read(userProfileProvider).valueOrNull;
      if (userProfile != null) {
        final repo = ref.read(userRepositoryProvider);
        
        final updatedModel = userProfile.model.copyWith(
          displayName: _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : userProfile.model.displayName,
          height: double.tryParse(_heightController.text),
          weight: double.tryParse(_weightController.text),
          gender: _gender,
          goal: _goal,
        );

        await repo.saveUser(updatedModel);
        
        // Invalidate to fetch fresh profile
        ref.invalidate(userProfileProvider);
        
        if (mounted) {
          context.pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving profile: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _submit,
            child: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Save'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display Name
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Display Name',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Height
              TextFormField(
                controller: _heightController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Height (cm)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.height),
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty && double.tryParse(value) == null) {
                    return 'Enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Weight
              TextFormField(
                controller: _weightController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Weight (kg)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.monitor_weight),
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty && double.tryParse(value) == null) {
                    return 'Enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              
              // Gender
              const Text('Gender', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'Male', label: Text('Male')),
                  ButtonSegment(value: 'Female', label: Text('Female')),
                  ButtonSegment(value: 'Other', label: Text('Other')),
                ],
                selected: {_gender},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() => _gender = newSelection.first);
                  HapticFeedback.selectionClick();
                },
                style: SegmentedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
              ),
              const SizedBox(height: 24),

              // Goal
              const Text('Primary Goal', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _goal,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: const [
                  DropdownMenuItem(value: 'Build Muscle', child: Text('Build Muscle')),
                  DropdownMenuItem(value: 'Lose Weight', child: Text('Lose Weight')),
                  DropdownMenuItem(value: 'Maintain', child: Text('Maintain Fitness')),
                  DropdownMenuItem(value: 'Increase Strength', child: Text('Increase Strength')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _goal = val);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
