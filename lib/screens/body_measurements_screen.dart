import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/body_measurement_provider.dart';
import '../providers/settings_provider.dart';
import '../core/utils/unit_converter.dart';

class BodyMeasurementsScreen extends ConsumerStatefulWidget {
  const BodyMeasurementsScreen({super.key});

  @override
  ConsumerState<BodyMeasurementsScreen> createState() => _BodyMeasurementsScreenState();
}

class _BodyMeasurementsScreenState extends ConsumerState<BodyMeasurementsScreen> {
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _chestController = TextEditingController();
  final TextEditingController _waistController = TextEditingController();
  final TextEditingController _hipsController = TextEditingController();
  final TextEditingController _bicepController = TextEditingController();
  final TextEditingController _thighController = TextEditingController();

  @override
  void dispose() {
    _weightController.dispose();
    _chestController.dispose();
    _waistController.dispose();
    _hipsController.dispose();
    _bicepController.dispose();
    _thighController.dispose();
    super.dispose();
  }

  void _saveMeasurements(String weightUnit) {
    HapticFeedback.lightImpact();
    final parsedWeight = double.tryParse(_weightController.text);
    ref.read(bodyMeasurementProvider.notifier).addFromInput(
          bodyWeight: parsedWeight != null ? UnitConverter.toStorageWeight(parsedWeight, weightUnit) : null,
          chest: double.tryParse(_chestController.text),
          waist: double.tryParse(_waistController.text),
          hips: double.tryParse(_hipsController.text),
          bicepLeft: double.tryParse(_bicepController.text),
          bicepRight: double.tryParse(_bicepController.text),
          thighLeft: double.tryParse(_thighController.text),
          thighRight: double.tryParse(_thighController.text),
        );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Measurements saved!')),
    );
    _weightController.clear();
    _chestController.clear();
    _waistController.clear();
    _hipsController.clear();
    _bicepController.clear();
    _thighController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final measurementsAsync = ref.watch(bodyMeasurementProvider);
    final weightUnit = ref.watch(settingsProvider).weightUnit;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Body Measurements', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: measurementsAsync.when(
        data: (measurements) => SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (measurements.isNotEmpty && measurements.any((m) => m.bodyWeight != null))
                _buildWeightChart(context, measurements, weightUnit),
              const SizedBox(height: 24),
              Text('Log New Measurements', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildMeasurementInput('Body Weight', weightUnit, _weightController),
              _buildMeasurementInput('Chest', 'cm', _chestController),
              _buildMeasurementInput('Waist', 'cm', _waistController),
              _buildMeasurementInput('Hips', 'cm', _hipsController),
              _buildMeasurementInput('Bicep', 'cm', _bicepController),
              _buildMeasurementInput('Thigh', 'cm', _thighController),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _saveMeasurements(weightUnit),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Save Measurements', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              if (measurements.isNotEmpty) ...[
                const SizedBox(height: 32),
                Text('History', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ...measurements.map((m) => _buildHistoryItem(context, m, weightUnit)),
              ]
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildHistoryItem(BuildContext context, dynamic m, String weightUnit) {
    final dateStr = '${m.date.day}/${m.date.month}/${m.date.year}';
    final parts = <String>[];
    if (m.bodyWeight != null) {
      final displayWeight = UnitConverter.toDisplayWeight(m.bodyWeight!, weightUnit);
      parts.add('Weight: ${displayWeight.toStringAsFixed(1)} $weightUnit');
    }
    if (m.chest != null) parts.add('Chest: ${m.chest} cm');
    if (m.waist != null) parts.add('Waist: ${m.waist} cm');
    if (m.hips != null) parts.add('Hips: ${m.hips} cm');
    if (m.bicepLeft != null) parts.add('Bicep: ${m.bicepLeft} cm');
    if (m.thighLeft != null) parts.add('Thigh: ${m.thighLeft} cm');

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(dateStr, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(parts.join(' • ')),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
          onPressed: () {
            ref.read(bodyMeasurementProvider.notifier).removeMeasurement(m.id);
          },
        ),
      ),
    );
  }

  Widget _buildMeasurementInput(String label, String unit, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          Expanded(
            flex: 3,
            child: TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                hintText: '0.0',
                suffixText: unit,
                isDense: true,
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightChart(BuildContext context, List measurements, String weightUnit) {
    final weightLogs = measurements.where((m) => m.bodyWeight != null).toList();
    if (weightLogs.length < 2) return const SizedBox();

    weightLogs.sort((a, b) => a.date.compareTo(b.date));

    final spots = weightLogs.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), UnitConverter.toDisplayWeight(e.value.bodyWeight!, weightUnit));
    }).toList();

    final minWeight = weightLogs.map((m) => UnitConverter.toDisplayWeight(m.bodyWeight!, weightUnit)).reduce((a, b) => a < b ? a : b) - 2;
    final maxWeight = weightLogs.map((m) => UnitConverter.toDisplayWeight(m.bodyWeight!, weightUnit)).reduce((a, b) => a > b ? a : b) + 2;

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Weight Trend', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (weightLogs.length - 1).toDouble(),
                minY: minWeight,
                maxY: maxWeight,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: Theme.of(context).colorScheme.primary,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
