import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../models/user_model.dart';
import 'package:flutter/services.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Form keys and controllers
  final _detailsFormKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _ageController = TextEditingController();
  
  String _experienceLevel = 'Beginner';
  String _gender = 'Male';
  String _goal = 'Build Muscle';

  // Questionnaire answers
  String _trainingFrequency = '3-4 days';
  String _timeInGym = 'Just started';
  
  // Specific questions (Yes/No defaults)
  String _specQ1 = 'No';
  String _specQ2 = 'No';
  String _specQ3 = 'No';
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final authUser = ref.read(authStateProvider).valueOrNull;
    if (authUser?.displayName != null && authUser!.displayName!.isNotEmpty) {
      _nameController.text = authUser.displayName!;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage == 0) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else if (_currentPage == 1) {
      if (_detailsFormKey.currentState!.validate()) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOutCubic,
        );
      }
    } else if (_currentPage == 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
    );
  }

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact();

    try {
      final user = await ref.read(authStateProvider.future);
      if (user != null) {
        final repo = ref.read(userRepositoryProvider);
        
        final finalName = _nameController.text.trim().isNotEmpty 
            ? _nameController.text.trim() 
            : (user.displayName ?? 'Athlete');

        if (user.displayName != finalName) {
          await user.updateDisplayName(finalName);
        }

        // Build questionnaire map based on experience level
        final Map<String, String> questionnaire = {
          'Training frequency': _trainingFrequency,
          'Time in gym': _timeInGym,
        };

        if (_experienceLevel == 'Beginner') {
          questionnaire['Other exercises (e.g. running)'] = _specQ1;
          questionnaire['Past injuries'] = _specQ2;
          questionnaire['Familiar with barbell exercises'] = _specQ3;
        } else if (_experienceLevel == 'Intermediate') {
          questionnaire['Tracking macros'] = _specQ1;
          questionnaire['Hit a plateau recently'] = _specQ2;
          questionnaire['Follow a specific program'] = _specQ3;
        } else {
          questionnaire['Use periodization'] = _specQ1;
          questionnaire['Preparing for competition'] = _specQ2;
          questionnaire['Track 1RM regularly'] = _specQ3;
        }

        final userModel = UserModel(
          id: user.uid,
          email: user.email ?? '',
          displayName: finalName,
          height: double.tryParse(_heightController.text),
          weight: double.tryParse(_weightController.text),
          age: int.tryParse(_ageController.text),
          gender: _gender,
          goal: _goal,
          experienceLevel: _experienceLevel,
          questionnaire: questionnaire,
        );

        await repo.saveUser(userModel);
        ref.invalidate(userProfileProvider);
        
        if (mounted) {
          context.go('/');
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
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0F0F) : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: _currentPage > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _previousPage,
              )
            : null,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress Indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Row(
                children: List.generate(4, (index) {
                  final isActive = index <= _currentPage;
                  return Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: EdgeInsets.only(right: index < 3 ? 8.0 : 0),
                      height: 4,
                      decoration: BoxDecoration(
                        color: isActive ? cs.primary : cs.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),
            
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) => setState(() => _currentPage = page),
                children: [
                  _buildExperienceLevelPage(cs),
                  _buildDetailsPage(cs),
                  _buildGoalPage(cs),
                  _buildQuestionnairePage(cs),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExperienceLevelPage(ColorScheme cs) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Experience',
            style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'How familiar are you with strength training?',
            style: TextStyle(color: cs.onSurfaceVariant, fontSize: 16),
          ),
          const SizedBox(height: 48),

          _buildExperienceCard(
            'Beginner',
            'Just starting out. Need guidance on basics.',
            Icons.child_care_rounded,
            cs,
          ),
          const SizedBox(height: 16),
          _buildExperienceCard(
            'Intermediate',
            'Familiar with compound lifts and routines.',
            Icons.fitness_center_rounded,
            cs,
          ),
          const SizedBox(height: 16),
          _buildExperienceCard(
            'Veteran',
            'Highly experienced. Looking for advanced analytics.',
            Icons.military_tech_rounded,
            cs,
          ),
          
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _nextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.primary,
                foregroundColor: cs.onPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Continue', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExperienceCard(String title, String subtitle, IconData icon, ColorScheme cs) {
    final isSelected = _experienceLevel == title;
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _experienceLevel = title);
      },
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? cs.primary.withValues(alpha: 0.1) : cs.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? cs.primary : cs.surfaceContainerHighest,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? cs.primary : cs.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? cs.onPrimary : cs.onSurface,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsPage(ColorScheme cs) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _detailsFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'About You',
              style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Personal details help tailor your AI insights.',
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 16),
            ),
            const SizedBox(height: 32),
            
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.person),
              ),
              validator: (value) => (value == null || value.trim().isEmpty) ? 'Please enter your name' : null,
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _heightController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Height (cm)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.height),
                    ),
                    validator: (value) => (value == null || double.tryParse(value) == null) ? 'Invalid' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _weightController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Weight (kg)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.monitor_weight),
                    ),
                    validator: (value) => (value == null || double.tryParse(value) == null) ? 'Invalid' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Age',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.cake),
              ),
              validator: (value) => (value == null || int.tryParse(value) == null) ? 'Invalid age' : null,
            ),
            const SizedBox(height: 24),
            
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
                backgroundColor: cs.surfaceContainerHighest,
              ),
            ),
            
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _nextPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: cs.primary,
                  foregroundColor: cs.onPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Continue', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalPage(ColorScheme cs) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Primary Goal',
            style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'What do you want to achieve with AV Fitness?',
            style: TextStyle(color: cs.onSurfaceVariant, fontSize: 16),
          ),
          const SizedBox(height: 48),
          
          _buildGoalCard('Build Muscle', Icons.fitness_center, cs),
          const SizedBox(height: 16),
          _buildGoalCard('Lose Weight', Icons.monitor_weight_outlined, cs),
          const SizedBox(height: 16),
          _buildGoalCard('Increase Strength', Icons.accessibility_new_rounded, cs),
          const SizedBox(height: 16),
          _buildGoalCard('Maintain Fitness', Icons.directions_run_rounded, cs),

          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _nextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.primary,
                foregroundColor: cs.onPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Continue', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildGoalCard(String title, IconData icon, ColorScheme cs) {
    final isSelected = _goal == title;
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _goal = title);
      },
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? cs.primary.withValues(alpha: 0.1) : cs.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? cs.primary : cs.surfaceContainerHighest,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? cs.primary : cs.onSurfaceVariant),
            const SizedBox(width: 16),
            Text(title, style: TextStyle(fontSize: 16, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
            const Spacer(),
            if (isSelected) Icon(Icons.check_circle, color: cs.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionnairePage(ColorScheme cs) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Personalize AI',
            style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'A few quick questions to tailor your experience.',
            style: TextStyle(color: cs.onSurfaceVariant, fontSize: 16),
          ),
          const SizedBox(height: 32),
          
          // Common Question 1
          const Text('How many days a week do you train?', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _buildDropdown(
            value: _trainingFrequency,
            items: const ['1-2 days', '3-4 days', '5-6 days', '7 days'],
            onChanged: (v) => setState(() => _trainingFrequency = v!),
          ),
          const SizedBox(height: 24),

          // Common Question 2
          const Text('How long have you been going to the gym?', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _buildDropdown(
            value: _timeInGym,
            items: const ['Just started', '< 6 months', '1-2 years', '> 2 years'],
            onChanged: (v) => setState(() => _timeInGym = v!),
          ),
          const SizedBox(height: 24),

          // Dynamic Specific Questions based on experience level
          if (_experienceLevel == 'Beginner') ...[
            _buildYesNoQuestion('Do you do other exercises (e.g. running)?', _specQ1, (v) => setState(() => _specQ1 = v)),
            _buildYesNoQuestion('Do you have any past injuries?', _specQ2, (v) => setState(() => _specQ2 = v)),
            _buildYesNoQuestion('Are you familiar with basic barbell exercises?', _specQ3, (v) => setState(() => _specQ3 = v)),
          ] else if (_experienceLevel == 'Intermediate') ...[
            _buildYesNoQuestion('Are you currently tracking your macros/calories?', _specQ1, (v) => setState(() => _specQ1 = v)),
            _buildYesNoQuestion('Have you hit a plateau recently?', _specQ2, (v) => setState(() => _specQ2 = v)),
            _buildYesNoQuestion('Do you follow a specific program (e.g. PPL)?', _specQ3, (v) => setState(() => _specQ3 = v)),
          ] else ...[
            _buildYesNoQuestion('Do you use periodization in your training?', _specQ1, (v) => setState(() => _specQ1 = v)),
            _buildYesNoQuestion('Are you preparing for a competition?', _specQ2, (v) => setState(() => _specQ2 = v)),
            _buildYesNoQuestion('Do you track your 1 Rep Max regularly?', _specQ3, (v) => setState(() => _specQ3 = v)),
          ],

          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.primary,
                foregroundColor: cs.onPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Finish Setup', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({required String value, required List<String> items, required ValueChanged<String?> onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: value,
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildYesNoQuestion(String question, String value, ValueChanged<String> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'Yes', label: Text('Yes')),
              ButtonSegment(value: 'No', label: Text('No')),
            ],
            selected: {value},
            onSelectionChanged: (set) {
              HapticFeedback.selectionClick();
              onChanged(set.first);
            },
            style: SegmentedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
          ),
        ],
      ),
    );
  }
}
