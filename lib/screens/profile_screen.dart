import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/history_provider.dart';
import '../providers/user_provider.dart';
import '../models/workout_log_model.dart';
import '../widgets/workout_feed_card.dart';
import '../widgets/profile_share_sheet.dart';
import '../core/utils/app_animations.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyLogsAsync = ref.watch(workoutHistoryProvider);
    final userProfileAsync = ref.watch(userProfileProvider);

    return userProfileAsync.when(
      data: (userProfile) {
        if (userProfile == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

        int completedFields = 0;
        if (userProfile.model.displayName.isNotEmpty) completedFields++;
        if (userProfile.model.height != null) completedFields++;
        if (userProfile.model.weight != null) completedFields++;
        if (userProfile.model.gender != null) completedFields++;
        if (userProfile.model.goal != null) completedFields++;
        final completionPercent = (completedFields / 5 * 100).toInt();
        final cs = Theme.of(context).colorScheme;

        return Scaffold(
          appBar: AppBar(
            title: Text(userProfile.model.displayName, style: const TextStyle(fontWeight: FontWeight.bold)),
            centerTitle: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  context.push('/profile/edit');
                },
              ),
              IconButton(
                icon: const Icon(Icons.ios_share),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  AppAnimations.showAnimatedBottomSheet(
                    context: context,
                    builder: (ctx) => ProfileShareSheet(
                      displayName: userProfile.model.displayName,
                      initials: userProfile.initials,
                      goal: userProfile.model.goal ?? 'Fitness',
                      workouts: historyLogsAsync.maybeWhen(data: (logs) => logs.length, orElse: () => 0),
                      weight: userProfile.model.weight != null ? '${userProfile.model.weight} kg' : '-',
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  context.push('/profile/settings');
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 90.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Header
                Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.blue,
                      child: Text(userProfile.initials, style: const TextStyle(fontSize: 36, color: Colors.white)),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(userProfile.model.displayName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildStatItem(context, 'Workouts', historyLogsAsync.maybeWhen(data: (logs) => logs.length.toString(), orElse: () => '0')),
                              _buildStatItem(context, 'Goal', userProfile.model.goal ?? 'Fitness'),
                              _buildStatItem(context, 'Weight', userProfile.model.weight != null ? '${userProfile.model.weight} kg' : '-'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Banner
                if (completionPercent < 100)
                  InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      context.push('/profile/edit');
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Your profile is $completionPercent% finished', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w500)),
                          const Icon(Icons.arrow_forward, size: 20),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
                // Interactive Chart
                historyLogsAsync.when(
                  data: (logs) => ProfileChartWidget(logs: logs),
                  loading: () => const SizedBox(height: 200, child: Center(child: CircularProgressIndicator())),
                  error: (e, st) => SizedBox(height: 200, child: Center(child: Text('Error loading chart: $e'))),
                ),
                const SizedBox(height: 20),
                // Dashboard
                Text('Dashboard', style: TextStyle(color: cs.onSurfaceVariant, fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
                const SizedBox(height: 10),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 3.0,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  children: [
                    _buildDashboardCard(context, Icons.show_chart, 'Statistics', onTap: () => context.push('/profile/statistics')),
                    _buildDashboardCard(context, Icons.fitness_center, 'Exercises', onTap: () => context.push('/exercises')),
                    _buildDashboardCard(context, Icons.accessibility, 'Measures', onTap: () => context.push('/profile/body-measurements')),
                    _buildDashboardCard(context, Icons.calendar_month, 'Calendar', onTap: () => context.push('/profile/calendar')),
                    _buildDashboardCard(context, Icons.emoji_events, 'Achievements', onTap: () => context.push('/profile/achievements')),
                    _buildDashboardCard(context, Icons.auto_awesome, 'AI Coach', onTap: () => context.push('/profile/ai-history')),
                  ],
                ),
                const SizedBox(height: 20),
                // Workouts
                Text('Workouts', style: TextStyle(color: cs.onSurfaceVariant, fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
                const SizedBox(height: 10),
                // Feed
                historyLogsAsync.when(
                  data: (historyLogs) {
                    if (historyLogs.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Center(child: Text('No workouts completed yet!')),
                      );
                    }
                    return Column(
                      children: historyLogs.map((log) => WorkoutFeedCard(log: log)).toList(),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, st) => Center(child: Text('Error: $e')),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, st) => Scaffold(body: Center(child: Text('Error: $e'))),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }

  Widget _buildDashboardCard(BuildContext context, IconData icon, String label, {VoidCallback? onTap}) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.onSurface),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class ProfileChartWidget extends StatefulWidget {
  final List<WorkoutLog> logs;
  const ProfileChartWidget({super.key, required this.logs});

  @override
  State<ProfileChartWidget> createState() => _ProfileChartWidgetState();
}

class _ProfileChartWidgetState extends State<ProfileChartWidget> {
  String _selectedFilter = 'Duration';

  @override
  Widget build(BuildContext context) {
    // Chronological order for chart
    final sortedLogs = List<WorkoutLog>.from(widget.logs)
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    final spots = <FlSpot>[];
    for (int i = 0; i < sortedLogs.length; i++) {
      final log = sortedLogs[i];
      double val = 0;
      if (_selectedFilter == 'Duration') {
        val = log.duration.inMinutes.toDouble();
      } else if (_selectedFilter == 'Volume') {
        val = log.totalVolume;
      } else {
        // Total reps
        val = log.exercises.fold<double>(
          0,
          (sum, ex) => sum + ex.sets.where((s) => s.completed).fold<double>(0, (sSum, s) => sSum + s.reps),
        );
      }
      spots.add(FlSpot(i.toDouble(), val));
    }

    final maxY = spots.isEmpty ? 10.0 : spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Chart Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            RichText(
              text: TextSpan(
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 16),
                children: [
                  TextSpan(text: '${widget.logs.length} workouts ', style: const TextStyle(fontWeight: FontWeight.bold)),
                  const TextSpan(text: 'total', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          height: 180,
          padding: const EdgeInsets.only(right: 16, top: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(16),
          ),
          child: spots.length < 2
              ? Center(
                  child: Text(
                    spots.isEmpty ? 'Log a workout to view performance' : 'Complete 1 more workout for trend line',
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                )
              : LineChart(
                  LineChartData(
                    minX: 0,
                    maxX: (spots.length - 1).toDouble(),
                    minY: 0,
                    maxY: maxY == 0 ? 10 : maxY * 1.2,
                    gridData: const FlGridData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 45,
                          getTitlesWidget: (val, meta) {
                            if (_selectedFilter == 'Volume') {
                              return Text('${(val / 1000).toStringAsFixed(1)}k', style: const TextStyle(fontSize: 10));
                            }
                            return Text(val.toInt().toString(), style: const TextStyle(fontSize: 10));
                          },
                        ),
                      ),
                      bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        color: Theme.of(context).colorScheme.primary,
                        barWidth: 3,
                        dotData: const FlDotData(show: true),
                        belowBarData: BarAreaData(
                          show: true,
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
        const SizedBox(height: 16),
        // Filter Pills
        Row(
          children: [
            _buildInteractivePill('Duration'),
            const SizedBox(width: 8),
            _buildInteractivePill('Volume'),
            const SizedBox(width: 8),
            _buildInteractivePill('Reps'),
          ],
        ),
      ],
    );
  }

  Widget _buildInteractivePill(String label) {
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
