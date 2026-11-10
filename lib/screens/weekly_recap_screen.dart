import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'dart:ui';

import '../providers/weekly_recap_provider.dart';
import '../core/constants/app_colors.dart';

class WeeklyRecapScreen extends ConsumerStatefulWidget {
  const WeeklyRecapScreen({super.key});

  @override
  ConsumerState<WeeklyRecapScreen> createState() => _WeeklyRecapScreenState();
}

class _WeeklyRecapScreenState extends ConsumerState<WeeklyRecapScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  int _currentPage = 0;
  int _totalPages = 0;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;
  final _screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fadeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recapState = ref.watch(weeklyRecapProvider);
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        title: const Text('Weekly Recap'),
        centerTitle: true,
        actions: [
          if (recapState.recapData != null)
            IconButton(
              icon: const Icon(Icons.ios_share),
              onPressed: _shareRecap,
            ),
        ],
      ),
      body: Column(
        children: [
          // Progress bar
          if (!recapState.isLoading && recapState.recapData != null)
            _buildProgressBar(cs),

          Expanded(child: _buildBody(recapState, cs, isDark)),
        ],
      ),
    );
  }

  Widget _buildProgressBar(ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: List.generate(_totalPages, (i) {
          return Expanded(
            child: Container(
              height: 3,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: i <= _currentPage
                    ? cs.primary
                    : cs.onSurface.withValues(alpha: 0.12),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildBody(WeeklyRecapState recapState, ColorScheme cs, bool isDark) {
    if (recapState.isLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: cs.primary),
            const SizedBox(height: 16),
            Text('Crunching your numbers...',
                style: TextStyle(color: cs.onSurfaceVariant)),
          ],
        ),
      );
    }

    if (recapState.needsApiKey) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: cs.primary.withValues(alpha: 0.1),
                ),
                child: Icon(Icons.vpn_key_rounded,
                    color: cs.primary, size: 48),
              ),
              const SizedBox(height: 24),
              Text('AI Recap Needs a Key',
                  style: TextStyle(
                      color: cs.onSurface,
                      fontSize: 22,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text(
                'Add your free Groq API key in Settings to unlock AI-powered weekly insights.',
                style: TextStyle(
                    color: cs.onSurfaceVariant, fontSize: 15, height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: () => context.push('/profile/settings'),
                icon: const Icon(Icons.settings),
                label: const Text('Open Settings'),
                style: FilledButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (recapState.error != null && recapState.recapData == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, color: cs.error, size: 48),
              const SizedBox(height: 16),
              Text(recapState.error!,
                  style: TextStyle(color: cs.onSurfaceVariant, fontSize: 15),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }

    if (recapState.recapData == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.auto_awesome, color: cs.primary, size: 48),
              const SizedBox(height: 20),
              Text(
                'Your first AI report will generate on Sunday at 10 AM.\nKeep training until then! 💪',
                style: TextStyle(
                    color: cs.onSurfaceVariant, fontSize: 16, height: 1.6),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final pages = _buildPages(recapState, cs, isDark);
    _totalPages = pages.length;

    return FadeTransition(
      opacity: _fadeAnim,
      child: Screenshot(
        controller: _screenshotController,
        child: Container(
          color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
          child: ClipRect(
            child: Stack(
              children: [
                // Subtle background glow
                Positioned(
                  top: -150,
                  right: -100,
                  child: Container(
                    width: 400,
                    height: 400,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          cs.primary.withValues(alpha: isDark ? 0.15 : 0.08),
                          cs.primary.withValues(alpha: 0.0),
                        ],
                        stops: const [0.1, 1.0],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -200,
                  left: -150,
                  child: Container(
                    width: 600,
                    height: 600,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          cs.primary.withValues(alpha: isDark ? 0.10 : 0.05),
                          cs.primary.withValues(alpha: 0.0),
                        ],
                        stops: const [0.1, 1.0],
                      ),
                    ),
                  ),
                ),
                PageView(
                  controller: _pageController,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  children: pages,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────
  //  Story Pages
  // ──────────────────────────────────────────

  List<Widget> _buildPages(WeeklyRecapState s, ColorScheme cs, bool isDark) {
    final data = s.recapData!;
    return [
      // ── Page 1: Coach Summary + Stats ──
      _StoryPage(
        children: [
          _sectionHeader(Icons.auto_awesome, 'Your weekly report is here', cs.primary),
          const SizedBox(height: 20),
          Text(data.intro,
              style: TextStyle(
                  color: cs.onSurface, fontSize: 18, height: 1.6),
              textAlign: TextAlign.center),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                  child: _buildStatTile(
                      'WORKOUTS', '${s.workoutCount}',
                      delta: s.workoutDelta != null
                          ? '${s.workoutDelta! >= 0 ? '+' : ''}${s.workoutDelta}'
                          : null,
                      cs: cs, isDark: isDark)),
              const SizedBox(width: 10),
              Expanded(
                  child: _buildStatTile(
                      'VOLUME', _fmtVol(s.totalVolume),
                      delta: s.volumeDelta != null
                          ? '${s.volumeDelta! >= 0 ? '+' : ''}${s.volumeDelta!.toStringAsFixed(0)}%'
                          : null,
                      cs: cs, isDark: isDark)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                  child: _buildStatTile(
                      'ACTIVE MIN', '${s.totalMinutes}',
                      delta: s.minutesDelta != null
                          ? '${s.minutesDelta! >= 0 ? '+' : ''}${s.minutesDelta!.toStringAsFixed(0)}%'
                          : null,
                      cs: cs, isDark: isDark)),
              const SizedBox(width: 10),
              Expanded(
                  child: _buildStatTile(
                      'CONSISTENCY', '${s.daysWithWorkout}/7',
                      delta:
                          '${(s.daysWithWorkout / 7 * 100).toStringAsFixed(0)}%',
                      cs: cs, isDark: isDark)),
            ],
          ),
          const Spacer(),
          _swipeHint(cs),
        ],
      ),

      // ── Page 2: Volume Graph ──
      _StoryPage(
        children: [
          _sectionHeader(Icons.bar_chart_rounded, 'Daily Volume', cs.primary),
          const SizedBox(height: 8),
          Text('${_fmtVol(s.totalVolume)} total this week',
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13)),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildCard(
                    isDark: isDark,
                    cs: cs,
                    child: SizedBox(
                      height: 200,
                      child: _buildBarChart(s.dailyVolume, s.dailyPrimaryMuscle, s.targetSunday!, cs, isDark),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildCard(
                    isDark: isDark,
                    cs: cs,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total Sets Completed',
                            style: TextStyle(
                                color: cs.onSurfaceVariant,
                                fontWeight: FontWeight.w500)),
                        Text('${s.totalSets}',
                            style: TextStyle(
                                color: cs.onSurface,
                                fontWeight: FontWeight.bold,
                                fontSize: 18)),
                      ],
                    ),
                  ),
                  if (s.dailyPrimaryMuscle.any((m) => m != null)) ...[
                    const SizedBox(height: 16),
                    _buildCard(
                      isDark: isDark,
                      cs: cs,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Daily Focus',
                              style: TextStyle(
                                  color: cs.onSurfaceVariant,
                                  fontWeight: FontWeight.w500)),
                          const SizedBox(height: 12),
                          ...List.generate(7, (index) {
                            final muscle = s.dailyPrimaryMuscle[index];
                            if (muscle == null) return const SizedBox.shrink();
                            final date = s.targetSunday!
                                .subtract(const Duration(days: 7))
                                .add(Duration(days: index));
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(DateFormat('EEEE').format(date),
                                      style: TextStyle(
                                          color: cs.onSurface, fontSize: 14)),
                                  Text('$muscle Day',
                                      style: TextStyle(
                                          color: cs.primary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14)),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _swipeHint(cs),
        ],
      ),

      // ── Page 3: Top Exercises + PRs ──
      _StoryPage(
        children: [
          _sectionHeader(
              Icons.emoji_events_rounded, 'Top Exercises & PRs', AppColors.warning),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  if (s.topExercises.isNotEmpty)
                    ...s.topExercises.asMap().entries.map((entry) {
                      final i = entry.key;
                      final ex = entry.value;
                      final medals = ['🥇', '🥈', '🥉'];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _buildCard(
                          isDark: isDark,
                          cs: cs,
                          highlight: i == 0,
                          child: Row(
                            children: [
                              Text(medals[i], style: const TextStyle(fontSize: 20)),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(ex.name,
                                    style: TextStyle(
                                        color: cs.onSurface,
                                        fontWeight: FontWeight.w600)),
                              ),
                              Text(_fmtVol(ex.volume),
                                  style: TextStyle(
                                      color: cs.onSurfaceVariant, fontSize: 13)),
                            ],
                          ),
                        ),
                      );
                    }),
                  if (s.weekPRs.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('NEW PERSONAL RECORDS',
                          style: TextStyle(
                              color: AppColors.success,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1)),
                    ),
                    const SizedBox(height: 10),
                    ...s.weekPRs.map((pr) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: AppColors.success.withValues(alpha: 0.2)),
                            ),
                            child: Row(
                              children: [
                                const Text('🏆', style: TextStyle(fontSize: 18)),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(pr.exerciseName,
                                      style: TextStyle(
                                          color: cs.onSurface,
                                          fontWeight: FontWeight.w600)),
                                ),
                                Text('${pr.weight.toStringAsFixed(1)} kg',
                                    style: const TextStyle(
                                        color: AppColors.success,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        )),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _swipeHint(cs),
        ],
      ),

      // ── Page 4: Muscle Groups ──
      if (s.muscleGroupVolume.isNotEmpty)
        _StoryPage(
          children: [
            _sectionHeader(Icons.accessibility_new_rounded, 'Muscle Groups',
                AppColors.accent),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                child: _buildCard(
                  isDark: isDark,
                  cs: cs,
                  child: Column(
                    children: _buildMuscleGroupBars(s.muscleGroupVolume, cs),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _swipeHint(cs),
          ],
        ),

      // ── Page 5: Tips + Finish ──
      _StoryPage(
        children: [
          _sectionHeader(
              Icons.lightbulb_outline, 'Focus for Next Week', cs.primary),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ...data.tips.asMap().entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildCard(
                        isDark: isDark,
                        cs: cs,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: cs.primary.withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text('${entry.key + 1}',
                                    style: TextStyle(
                                        color: cs.primary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13)),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(entry.value,
                                  style: TextStyle(
                                      color: cs.onSurface,
                                      fontSize: 14,
                                      height: 1.5)),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('See you next week with new insights! 👋',
              style: TextStyle(
                  color: cs.onSurfaceVariant,
                  fontSize: 14,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: () => context.pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.primary,
                foregroundColor: cs.onPrimary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Back to Training',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    ];
  }

  // ──────────────────────────────────────────
  //  Shared UI Components (matching app theme)
  // ──────────────────────────────────────────

  Widget _sectionHeader(IconData icon, String title, Color accent) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: accent.withValues(alpha: 0.1),
          ),
          child: Icon(icon, color: accent, size: 28),
        ),
        const SizedBox(height: 12),
        Text(title.toUpperCase(),
            style: TextStyle(
                color: accent,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 1)),
      ],
    );
  }

  /// Card matching app's dark card style: surfaceDark bg, cardBorderDark border, rounded 16
  Widget _buildCard(
      {required bool isDark,
      required ColorScheme cs,
      required Widget child,
      bool highlight = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: highlight
              ? cs.primary.withValues(alpha: 0.3)
              : (isDark ? AppColors.cardBorderDark : const Color(0xFFE5E5E5)),
        ),
      ),
      child: child,
    );
  }

  Widget _buildStatTile(String label, String value,
      {String? delta, required ColorScheme cs, required bool isDark}) {
    final isPositive =
        delta != null && (delta.startsWith('+') || !delta.startsWith('-'));
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color:
                isDark ? AppColors.cardBorderDark : const Color(0xFFE5E5E5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  color: cs.onSurfaceVariant,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8)),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(
                  color: cs.onSurface,
                  fontSize: 22,
                  fontWeight: FontWeight.w900)),
          if (delta != null) ...[
            const SizedBox(height: 4),
            Text(delta,
                style: TextStyle(
                  color: isPositive ? AppColors.success : AppColors.error,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                )),
          ],
        ],
      ),
    );
  }

  Widget _swipeHint(ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text('Swipe to continue →',
          style: TextStyle(
              color: cs.onSurfaceVariant.withValues(alpha: 0.4),
              fontSize: 12)),
    );
  }

  Widget _buildBarChart(
      List<double> dailyVol, List<String?> dailyMuscle, DateTime targetSunday, ColorScheme cs, bool isDark) {
    final startOfWeek = targetSunday.subtract(const Duration(days: 7));
    double maxY = 100;
    for (final v in dailyVol) {
      if (v > maxY) maxY = v;
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY * 1.3,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                _fmtVol(rod.toY),
                TextStyle(
                    color: cs.onSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 12),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) {
                final date =
                    startOfWeek.add(Duration(days: value.toInt()));
                
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    DateFormat('E').format(date).substring(0, 2),
                    style: TextStyle(
                        color: cs.onSurfaceVariant,
                        fontSize: 11,
                        fontWeight: FontWeight.w600),
                  ),
                );
              },
            ),
          ),
          leftTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(7, (i) {
          final hasData = dailyVol[i] > 0;
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: hasData ? dailyVol[i] : maxY * 0.02,
                color: hasData
                    ? cs.primary
                    : (isDark
                        ? AppColors.surfaceVariantDark
                        : AppColors.surfaceVariantLight),
                width: 22,
                borderRadius: BorderRadius.circular(6),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: maxY * 1.3,
                  color: isDark
                      ? AppColors.surfaceDark
                      : AppColors.surfaceVariantLight.withValues(alpha: 0.3),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  List<Widget> _buildMuscleGroupBars(
      Map<String, double> muscleVol, ColorScheme cs) {
    final sorted = muscleVol.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final maxVol = sorted.first.value;

    return sorted.asMap().entries.map((entry) {
      final e = entry.value;
      final pct = maxVol > 0 ? e.value / maxVol : 0.0;

      return Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(e.key,
                    style: TextStyle(
                        color: cs.onSurface, fontWeight: FontWeight.w600)),
                Text(_fmtVol(e.value),
                    style: TextStyle(
                        color: cs.onSurfaceVariant, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Stack(
                children: [
                  Container(
                    height: 8,
                    width: double.infinity,
                    color: cs.primary.withValues(alpha: 0.08),
                  ),
                  FractionallySizedBox(
                    widthFactor: pct,
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: cs.primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Future<void> _shareRecap() async {
    HapticFeedback.lightImpact();
    try {
      final image = await _screenshotController.capture(
          delay: const Duration(milliseconds: 50), pixelRatio: 3.0);
      if (image == null) return;
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/weekly_recap.png');
      await file.writeAsBytes(image);
      final box = context.findRenderObject() as RenderBox?;
      await Share.shareXFiles([XFile(file.path)],
          text: 'My weekly training recap on AV Fitness! 💪',
          sharePositionOrigin:
              box!.localToGlobal(Offset.zero) & box.size);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Share failed: $e')));
      }
    }
  }

  String _fmtVol(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M kg';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K kg';
    return '${v.toInt()} kg';
  }
}

// ────────────────────────────────────────────
//  Story page wrapper
// ────────────────────────────────────────────

class _StoryPage extends StatelessWidget {
  final List<Widget> children;
  const _StoryPage({required this.children});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: children,
      ),
    );
  }
}
