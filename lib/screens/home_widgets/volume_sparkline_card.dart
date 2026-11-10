import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/history_provider.dart';
import '../../providers/settings_provider.dart';
import '../../core/utils/unit_converter.dart';
import 'package:intl/intl.dart';

class VolumeSparklineCard extends ConsumerWidget {
  const VolumeSparklineCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(workoutHistoryProvider);
    final weightUnit = ref.watch(settingsProvider).weightUnit;
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return historyAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (logs) {
        if (logs.isEmpty) return const SizedBox.shrink();

        // Calculate last 7 days of volume
        final now = DateTime.now();
        final todayMidnight = DateTime(now.year, now.month, now.day);
        
        final List<double> last7DaysVolume = List.filled(7, 0.0);
        final List<double> prev7DaysVolume = List.filled(7, 0.0);

        for (final log in logs) {
          final diff = todayMidnight.difference(DateTime(log.startTime.year, log.startTime.month, log.startTime.day)).inDays;
          if (diff >= 0 && diff < 7) {
            last7DaysVolume[6 - diff] += log.totalVolume;
          } else if (diff >= 7 && diff < 14) {
            prev7DaysVolume[6 - (diff - 7)] += log.totalVolume;
          }
        }

        final double totalCurrent = last7DaysVolume.fold(0, (a, b) => a + b);
        final double totalPrev = prev7DaysVolume.fold(0, (a, b) => a + b);
        final double percentChange = totalPrev > 0 ? ((totalCurrent - totalPrev) / totalPrev) * 100 : 100.0;
        
        final isPositive = percentChange >= 0;

        List<FlSpot> spots = [];
        double maxVol = 100;
        for (int i = 0; i < 7; i++) {
          final v = last7DaysVolume[i];
          if (v > maxVol) maxVol = v;
          spots.add(FlSpot(i.toDouble(), v));
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF161616) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: isDark ? const Color(0xFF262626) : const Color(0xFFE5E5E5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('7-Day Volume', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: (isPositive ? Colors.green : Colors.red).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(isPositive ? Icons.trending_up : Icons.trending_down, 
                          size: 14, color: isPositive ? Colors.green : Colors.red),
                        const SizedBox(width: 4),
                        Text('${percentChange.abs().toStringAsFixed(1)}%', 
                          style: TextStyle(color: isPositive ? Colors.green : Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(height: 4),
              Text('${(UnitConverter.toDisplayWeight(totalCurrent, weightUnit) / 1000).toStringAsFixed(1)}k $weightUnit total', style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13)),
              const SizedBox(height: 24),
              SizedBox(
                height: 80,
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: false),
                    titlesData: const FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    minX: 0,
                    maxX: 6,
                    minY: 0,
                    maxY: maxVol * 1.2,
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        color: cs.primary,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: cs.primary.withOpacity(0.1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(DateFormat('MMM d').format(now.subtract(const Duration(days: 6))), style: TextStyle(color: cs.onSurfaceVariant, fontSize: 11)),
                  Text('Today', style: TextStyle(color: cs.onSurfaceVariant, fontSize: 11)),
                ],
              )
            ],
          ),
        );
      }
    );
  }
}
