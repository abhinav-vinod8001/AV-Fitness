import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';

class OneRepMaxScreen extends ConsumerStatefulWidget {
  const OneRepMaxScreen({super.key});

  @override
  ConsumerState<OneRepMaxScreen> createState() => _OneRepMaxScreenState();
}

class _OneRepMaxScreenState extends ConsumerState<OneRepMaxScreen> {
  final _weightController = TextEditingController();
  final _repsController = TextEditingController();

  double _oneRepMax = 0;
  List<Map<String, dynamic>> _percentages = [];

  void _calculate1RM() {
    final weight = double.tryParse(_weightController.text) ?? 0;
    final reps = int.tryParse(_repsController.text) ?? 0;

    if (weight > 0 && reps > 0) {
      // Epley Formula: 1RM = Weight * (1 + (Reps / 30))
      setState(() {
        _oneRepMax = weight * (1 + (reps / 30));
        _generatePercentages();
      });
    } else {
      setState(() {
        _oneRepMax = 0;
        _percentages = [];
      });
    }
  }

  void _generatePercentages() {
    _percentages = [
      {'percent': 100, 'reps': 1, 'weight': _oneRepMax},
      {'percent': 95, 'reps': 2, 'weight': _oneRepMax * 0.95},
      {'percent': 90, 'reps': 3, 'weight': _oneRepMax * 0.90},
      {'percent': 85, 'reps': 5, 'weight': _oneRepMax * 0.85},
      {'percent': 80, 'reps': 7, 'weight': _oneRepMax * 0.80},
      {'percent': 75, 'reps': 10, 'weight': _oneRepMax * 0.75},
      {'percent': 70, 'reps': 12, 'weight': _oneRepMax * 0.70},
      {'percent': 65, 'reps': 15, 'weight': _oneRepMax * 0.65},
    ];
  }

  @override
  void dispose() {
    _weightController.dispose();
    _repsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final weightUnit = ref.watch(settingsProvider).weightUnit;

    return Scaffold(
      appBar: AppBar(
        title: const Text('1RM Calculator', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text('Your Estimated 1RM', style: TextStyle(color: Colors.white70, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(
                    _oneRepMax > 0 ? '${_oneRepMax.toStringAsFixed(1)} $weightUnit' : '---',
                    style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _weightController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (_) => _calculate1RM(),
                    decoration: InputDecoration(
                      labelText: 'Weight',
                      suffixText: weightUnit,
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _repsController,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => _calculate1RM(),
                    decoration: InputDecoration(
                      labelText: 'Reps',
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            if (_percentages.isNotEmpty) ...[
              const Text('Percentages', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ..._percentages.map((p) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${p['percent']}%', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
                        Text('${p['reps']} Rep${p['reps'] > 1 ? 's' : ''}', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                        Text('${(p['weight'] as double).toStringAsFixed(1)} $weightUnit', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                  )),
            ]
          ],
        ),
      ),
    );
  }
}
