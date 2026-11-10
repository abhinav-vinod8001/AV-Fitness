import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/history_provider.dart';
import '../providers/active_workout_provider.dart';
import '../models/workout_log_model.dart';
import '../models/workout_model.dart';
import '../models/exercise_model.dart';
import '../core/constants/default_exercises.dart';
import '../widgets/exercise_preview_modal.dart';

import 'schedule_builder_tab.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  late DateTime _focusedMonth;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedMonth = DateTime(now.year, now.month, 1);
    _selectedDate = DateTime(now.year, now.month, now.day);
  }

  void _jumpToToday() {
    HapticFeedback.lightImpact();
    final now = DateTime.now();
    setState(() {
      _focusedMonth = DateTime(now.year, now.month, 1);
      _selectedDate = DateTime(now.year, now.month, now.day);
    });
  }

  void _prevMonth() {
    HapticFeedback.selectionClick();
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    HapticFeedback.selectionClick();
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 1);
    });
  }

  int _calculateCalories(int durationMinutes, double volumeKg) {
    if (durationMinutes <= 0 && volumeKg <= 0) return 0;
    // Standard estimation: ~6.5 kcal/min base + volume metabolic expenditure factor
    final cal = (durationMinutes * 6.5) + (volumeKg * 0.012);
    return cal > 0 ? cal.round() : (durationMinutes > 0 ? durationMinutes * 6 : 0);
  }

  @override
  Widget build(BuildContext context) {
    final historyAsync = ref.watch(workoutHistoryProvider);
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Calendar', style: TextStyle(fontWeight: FontWeight.bold)),
          actions: [
            IconButton(
              icon: const Icon(Icons.today_rounded),
              tooltip: 'Jump to Today',
              onPressed: _jumpToToday,
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'History'),
              Tab(text: 'Weekly Schedule'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: History
            historyAsync.when(
              data: (logs) {
          // Map logs by date string 'YYYY-M-D'
          final logsByDate = <String, List<WorkoutLog>>{};
          final workoutDates = <String>{};

          for (final log in logs) {
            final d = log.startTime;
            final key = '${d.year}-${d.month}-${d.day}';
            workoutDates.add(key);
            logsByDate.putIfAbsent(key, () => []).add(log);
          }

          final selectedKey = '${_selectedDate.year}-${_selectedDate.month}-${_selectedDate.day}';
          final selectedDayLogs = logsByDate[selectedKey] ?? [];

          // Calculate selected day metrics
          int totalDurationMinutes = 0;
          double totalVolume = 0;
          for (final log in selectedDayLogs) {
            totalDurationMinutes += log.duration.inMinutes;
            totalVolume += log.totalVolume;
          }
          final caloriesBurned = _calculateCalories(totalDurationMinutes, totalVolume);

          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 90),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Calendar Card Container ──────────────
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.black.withValues(alpha: 0.06),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Month Navigation
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chevron_left_rounded),
                            onPressed: _prevMonth,
                          ),
                          Text(
                            DateFormat('MMMM yyyy').format(_focusedMonth),
                            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: const Icon(Icons.chevron_right_rounded),
                            onPressed: _nextMonth,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Day of week headers
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                            .map((d) => SizedBox(
                                  width: 38,
                                  child: Text(
                                    d,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 11,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                      const SizedBox(height: 10),

                      // Calendar Grid
                      _buildCalendarGrid(context, workoutDates),
                    ],
                  ),
                ),

                // ── Selected Date Header & Metrics ────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DateFormat('EEEE, MMMM d').format(_selectedDate),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.2,
                            ),
                          ),
                          if (_isSameDay(_selectedDate, DateTime.now()))
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: cs.primary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'TODAY',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: cs.primary,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Daily Stats Summary Row (4 stats: Workouts, Volume, Time, Calories)
                      Row(
                        children: [
                          _buildStatCard(
                            context,
                            icon: Icons.fitness_center_rounded,
                            label: 'Workouts',
                            value: '${selectedDayLogs.length}',
                            color: cs.primary,
                          ),
                          const SizedBox(width: 8),
                          _buildStatCard(
                            context,
                            icon: Icons.monitor_weight_outlined,
                            label: 'Volume',
                            value: totalVolume > 0
                                ? '${NumberFormat.compact().format(totalVolume)} kg'
                                : '0 kg',
                            color: Colors.blueAccent,
                          ),
                          const SizedBox(width: 8),
                          _buildStatCard(
                            context,
                            icon: Icons.timer_outlined,
                            label: 'Duration',
                            value: totalDurationMinutes > 0
                                ? '$totalDurationMinutes min'
                                : '0 min',
                            color: Colors.teal,
                          ),
                          const SizedBox(width: 8),
                          _buildStatCard(
                            context,
                            icon: Icons.local_fire_department_rounded,
                            label: 'Calories',
                            value: caloriesBurned > 0 ? '$caloriesBurned' : '0',
                            unit: 'kcal',
                            color: Colors.deepOrangeAccent,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ── Detailed Workout Breakdown or Rest Day Card ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: selectedDayLogs.isNotEmpty
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: selectedDayLogs.map((log) => _buildDayWorkoutCard(context, log)).toList(),
                        )
                      : _buildRestDayCard(context),
                ),

                const SizedBox(height: 24),

                // ── Monthly Summary Footer ────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildSummaryItem(context, 'This Month', '${_countThisMonth(logs)} sessions'),
                        _buildSummaryItem(context, 'Total Logged', '${logs.length} workouts'),
                        _buildSummaryItem(context, 'Current Streak', '${_calculateStreak(workoutDates)} days'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Center(child: Text('Error: $e')),
          ),
          
          // Tab 2: Weekly Schedule
          const ScheduleBuilderTab(),
        ],
      ),
    ));
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    String? unit,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (unit != null)
              Text(
                unit,
                style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarGrid(BuildContext context, Set<String> workoutDates) {
    final firstDay = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final lastDay = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);
    final startWeekday = firstDay.weekday; // 1 = Monday
    final today = DateTime.now();
    final cs = Theme.of(context).colorScheme;

    final cells = <Widget>[];

    // Empty cells before first day
    for (int i = 1; i < startWeekday; i++) {
      cells.add(const SizedBox(width: 38, height: 42));
    }

    // Day cells
    for (int day = 1; day <= lastDay.day; day++) {
      final cellDate = DateTime(_focusedMonth.year, _focusedMonth.month, day);
      final dateKey = '${_focusedMonth.year}-${_focusedMonth.month}-$day';
      final hasWorkout = workoutDates.contains(dateKey);
      final isToday = _isSameDay(today, cellDate);
      final isSelected = _isSameDay(_selectedDate, cellDate);

      cells.add(
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() {
              _selectedDate = cellDate;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: isSelected
                  ? cs.primary
                  : hasWorkout
                      ? cs.primary.withValues(alpha: 0.12)
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: isToday && !isSelected
                  ? Border.all(color: cs.primary, width: 1.5)
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$day',
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : hasWorkout
                            ? cs.primary
                            : cs.onSurface,
                    fontWeight: isSelected || hasWorkout || isToday ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                // Indicator dot
                Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? Colors.white
                        : hasWorkout
                            ? cs.primary
                            : Colors.transparent,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: cells,
    );
  }

  Widget _buildDayWorkoutCard(BuildContext context, WorkoutLog log) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final timeStr = '${DateFormat('hh:mm a').format(log.startTime)} - ${DateFormat('hh:mm a').format(log.endTime)}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Workout header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      log.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      timeStr,
                      style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${log.duration.inMinutes} min',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: cs.primary),
                ),
              ),
            ],
          ),
          const Divider(height: 24),

          // Exercises list
          Text(
            'EXERCISES PERFORMED (${log.exercises.length})',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 10),
          ...log.exercises.map((ex) => _buildExerciseRow(context, ex)),
        ],
      ),
    );
  }

  Widget _buildExerciseRow(BuildContext context, WorkoutExercise ex) {
    final cs = Theme.of(context).colorScheme;
    final completedSets = ex.sets.where((s) => s.completed).toList();
    final bestSet = completedSets.isNotEmpty
        ? completedSets.reduce((a, b) => (a.weight * a.reps) > (b.weight * b.reps) ? a : b)
        : null;

    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        // Lookup full exercise from DefaultExercises for instructions & image preview
        final fullEx = DefaultExercises.list.firstWhere(
          (item) => item.id == ex.exerciseId || item.name.toLowerCase() == ex.exerciseName.toLowerCase(),
          orElse: () => Exercise(
            id: ex.exerciseId,
            name: ex.exerciseName,
            muscleGroup: 'Full Body',
            equipment: 'Gym',
            isCustom: true,
          ),
        );
        ExercisePreviewModal.show(context, exercise: fullEx);
      },
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4.0),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.fitness_center_rounded, size: 16, color: cs.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ex.exerciseName,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${completedSets.length} sets ${bestSet != null ? '• Best: ${bestSet.weight} kg × ${bestSet.reps}' : ''}',
                    style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            Icon(Icons.info_outline_rounded, size: 18, color: cs.onSurfaceVariant.withValues(alpha: 0.6)),
          ],
        ),
      ),
    );
  }

  Widget _buildRestDayCard(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.indigoAccent.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.bedtime_rounded, size: 36, color: Colors.indigoAccent),
          ),
          const SizedBox(height: 16),
          const Text(
            'Rest & Recovery Day',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
          ),
          const SizedBox(height: 6),
          Text(
            'No workouts recorded for this date. Rest and recovery are crucial for muscle synthesis and avoiding burnout.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant, height: 1.4),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              HapticFeedback.mediumImpact();
              final emptyTemplate = WorkoutTemplate(
                id: 'empty-${DateTime.now().millisecondsSinceEpoch}',
                name: 'Workout on ${DateFormat('MMM d').format(_selectedDate)}',
                exercises: [],
              );
              ref.read(activeWorkoutProvider.notifier).startWorkout(emptyTemplate);
              context.push('/workouts/active');
            },
            icon: const Icon(Icons.play_arrow_rounded, size: 20),
            label: const Text('Start Workout', style: TextStyle(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: cs.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  int _countThisMonth(List<WorkoutLog> logs) {
    return logs.where((l) => l.startTime.year == _focusedMonth.year && l.startTime.month == _focusedMonth.month).length;
  }

  int _calculateStreak(Set<String> workoutDates) {
    int streak = 0;
    var date = DateTime.now();
    for (int i = 0; i < 365; i++) {
      final key = '${date.year}-${date.month}-${date.day}';
      if (workoutDates.contains(key)) {
        streak++;
      } else if (i > 0) {
        break;
      }
      date = date.subtract(const Duration(days: 1));
    }
    return streak;
  }
}
