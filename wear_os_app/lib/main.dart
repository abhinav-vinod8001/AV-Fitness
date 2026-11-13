import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const IronTrackWatchApp());
}

class IronTrackWatchApp extends StatelessWidget {
  const IronTrackWatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AV Fitness',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFF5722),
          secondary: Color(0xFF2979FF),
          surface: Colors.black,
        ),
        fontFamily: 'sans-serif',
      ),
      home: const WatchHomeScreen(),
    );
  }
}

// ─── Health & Wearable Bridge ────────────────────────────────────────────────

class HealthService {
  static const _healthChannel = MethodChannel('com.irontrack.watch/health');
  static const _healthEvents = EventChannel('com.irontrack.watch/health_events');
  static const _hapticChannel = MethodChannel('com.irontrack.watch/haptics');

  static Stream<Map<String, dynamic>> get healthStream {
    return _healthEvents.receiveBroadcastStream().map((event) {
      return Map<String, dynamic>.from(event as Map);
    });
  }

  static Future<void> requestPermissions() async {
    try {
      await _healthChannel.invokeMethod('requestPermissions');
    } catch (_) {}
  }

  static Future<void> startHeartRate() async {
    try {
      await _healthChannel.invokeMethod('startHeartRate');
    } catch (_) {}
  }

  static Future<void> stopHeartRate() async {
    try {
      await _healthChannel.invokeMethod('stopHeartRate');
    } catch (_) {}
  }

  static Future<void> sendWorkoutCommand(String command, [Map<String, dynamic>? extra]) async {
    try {
      await _healthChannel.invokeMethod('sendWorkoutCommand', {
        'command': command,
        'extra': extra ?? {},
      });
    } catch (_) {}
  }

  static Future<Map<String, dynamic>> getPhoneConnectionStatus() async {
    try {
      final res = await _healthChannel.invokeMethod<Map>('getPhoneConnectionStatus');
      if (res != null) {
        return Map<String, dynamic>.from(res);
      }
    } catch (_) {}
    return {'connected': false, 'phoneName': ''};
  }

  static Future<void> setKeepScreenOn(bool enable) async {
    try {
      await _healthChannel.invokeMethod('setKeepScreenOn', {'enable': enable});
    } catch (_) {}
  }

  static Future<void> vibrate({List<int> pattern = const [0, 200, 100, 200]}) async {
    try {
      await _hapticChannel.invokeMethod('vibrate', {'pattern': pattern});
    } catch (_) {}
  }

  static Future<void> vibrateOnce() async {
    try {
      await _hapticChannel.invokeMethod('vibrateOnce');
    } catch (_) {}
  }

  static Future<void> vibrateDouble() async {
    try {
      await _hapticChannel.invokeMethod('vibrateDouble');
    } catch (_) {}
  }
}

// ─── Watch Active Workout State Model ────────────────────────────────────────

class WatchWorkoutState {
  final bool hasActiveWorkout;
  final String workoutName;
  final String currentExercise;
  final int completedSets;
  final int totalSets;
  final int currentSetNumber;
  final int totalExerciseSets;
  final double weight;
  final int reps;
  final String weightUnit;
  final bool isResting;
  final int restRemaining;
  final int elapsedSeconds;

  const WatchWorkoutState({
    this.hasActiveWorkout = false,
    this.workoutName = '',
    this.currentExercise = '',
    this.completedSets = 0,
    this.totalSets = 0,
    this.currentSetNumber = 1,
    this.totalExerciseSets = 3,
    this.weight = 0.0,
    this.reps = 0,
    this.weightUnit = 'kg',
    this.isResting = false,
    this.restRemaining = 0,
    this.elapsedSeconds = 0,
  });

  factory WatchWorkoutState.fromJson(Map<String, dynamic> json) {
    return WatchWorkoutState(
      hasActiveWorkout: true,
      workoutName: json['workoutName'] as String? ?? 'Active Workout',
      currentExercise: json['currentExercise'] as String? ?? 'Exercise',
      completedSets: json['completedSets'] as int? ?? 0,
      totalSets: json['totalSets'] as int? ?? 0,
      currentSetNumber: json['currentSetNumber'] as int? ?? 1,
      totalExerciseSets: json['totalExerciseSets'] as int? ?? 3,
      weight: (json['weight'] as num?)?.toDouble() ?? 0.0,
      reps: json['reps'] as int? ?? 0,
      weightUnit: json['weightUnit'] as String? ?? 'kg',
      isResting: json['isResting'] as bool? ?? false,
      restRemaining: json['restRemaining'] as int? ?? 0,
      elapsedSeconds: json['elapsedSeconds'] as int? ?? 0,
    );
  }
}

// ─── Watch Home Screen ──────────────────────────────────────────────────────

class WatchHomeScreen extends StatefulWidget {
  const WatchHomeScreen({super.key});

  @override
  State<WatchHomeScreen> createState() => _WatchHomeScreenState();
}

class _WatchHomeScreenState extends State<WatchHomeScreen>
    with TickerProviderStateMixin {
  int _currentPage = 0;
  final _pageController = PageController();

  // Health Data
  double? _heartRate;
  double? _minHeartRate;
  double? _maxHeartRate;
  double _heartRateSum = 0;
  int _heartRateCount = 0;
  StreamSubscription? _healthSub;

  // Phone Connection & Workout Sync
  bool _isPhoneConnected = false;
  String _phoneName = '';
  WatchWorkoutState _workoutState = const WatchWorkoutState();

  // Pulse animation for heart rate
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  // Feedback banner
  String? _bannerMessage;
  Timer? _bannerTimer;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.88, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _initWatchSync();
  }

  Future<void> _initWatchSync() async {
    await HealthService.requestPermissions();
    await HealthService.setKeepScreenOn(true);
    await HealthService.startHeartRate();

    final status = await HealthService.getPhoneConnectionStatus();
    if (mounted) {
      setState(() {
        _isPhoneConnected = status['connected'] as bool? ?? false;
        _phoneName = status['phoneName'] as String? ?? '';
      });
    }

    _healthSub = HealthService.healthStream.listen((data) {
      if (!mounted) return;
      final type = data['type'] as String?;

      switch (type) {
        case 'heart_rate':
          final value = data['value'];
          if (value is num && value > 30) {
            final bpm = value.toDouble();
            setState(() {
              _heartRate = bpm;
              _heartRateCount++;
              _heartRateSum += bpm;
              if (_minHeartRate == null || bpm < _minHeartRate!) {
                _minHeartRate = bpm;
              }
              if (_maxHeartRate == null || bpm > _maxHeartRate!) {
                _maxHeartRate = bpm;
              }

              // Adjust pulse speed to real heart rate!
              final msPerBeat = (60000 / bpm).clamp(400, 1500).toInt();
              _pulseController.duration = Duration(milliseconds: msPerBeat ~/ 2);
            });
          }
          break;

        case 'workout_state':
          final rawJson = data['data'] as String?;
          if (rawJson != null) {
            try {
              final map = jsonDecode(rawJson) as Map<String, dynamic>;
              final newState = WatchWorkoutState.fromJson(map);
              
              // Haptic alert if rest timer just reached 0
              if (_workoutState.isResting && !newState.isResting && newState.restRemaining <= 0) {
                HealthService.vibrateDouble();
                _showBanner('Rest Complete! Next set ready.');
              }

              // AUTO-START: When phone starts a workout, activate HR, keep screen on, & switch to workout screen
              final wasIdle = !_workoutState.hasActiveWorkout;
              if (wasIdle && newState.hasActiveWorkout) {
                HealthService.vibrateOnce();
                _showBanner('Workout Started: ${newState.workoutName}');
                HealthService.startHeartRate();
                HealthService.setKeepScreenOn(true);
                Future.microtask(() {
                  if (_pageController.hasClients && _currentPage != 1) {
                    _pageController.animateToPage(
                      1,
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeOutCubic,
                    );
                  }
                });
              }

              setState(() {
                _workoutState = newState;
                _isPhoneConnected = true;
              });
            } catch (_) {}
          }
          break;

        case 'workout_stop':
          HealthService.stopHeartRate();
          HealthService.setKeepScreenOn(false);
          setState(() {
            _workoutState = const WatchWorkoutState();
          });
          _showBanner('Workout Finished!');
          HealthService.vibrateOnce();
          Future.microtask(() {
            if (_pageController.hasClients && _currentPage != 0) {
              _pageController.animateToPage(
                0,
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutCubic,
              );
            }
          });
          break;

        case 'connection_changed':
          setState(() {
            _isPhoneConnected = data['connected'] as bool? ?? false;
            _phoneName = data['phoneName'] as String? ?? '';
          });
          break;

        case 'ping':
          _showBanner('Phone Connected!');
          break;
      }
    });
  }

  void _showBanner(String message) {
    _bannerTimer?.cancel();
    setState(() {
      _bannerMessage = message;
    });
    _bannerTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _bannerMessage = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _healthSub?.cancel();
    HealthService.setKeepScreenOn(false);
    HealthService.stopHeartRate();
    _pulseController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  // ─── Heart Rate Zone Helpers ──────────────────────────────────────────────

  String _getHeartRateZone(double? bpm) {
    if (bpm == null) return 'RESTING';
    if (bpm < 115) return 'WARM UP';
    if (bpm < 135) return 'FAT BURN';
    if (bpm < 155) return 'CARDIO';
    if (bpm < 172) return 'HARD';
    return 'PEAK';
  }

  Color _getHeartRateColor(double? bpm) {
    if (bpm == null) return Colors.grey;
    if (bpm < 115) return const Color(0xFF29B6F6);
    if (bpm < 135) return const Color(0xFF66BB6A);
    if (bpm < 155) return const Color(0xFFFFA726);
    if (bpm < 172) return const Color(0xFFFF7043);
    return const Color(0xFFEF5350);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (i) => setState(() => _currentPage = i),
            children: [
              _buildHeartRatePage(size),
              _buildWorkoutPage(size),
              _buildToolsPage(size),
            ],
          ),
          if (_bannerMessage != null)
            Positioned(
              top: 16,
              left: 20,
              right: 20,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: 1.0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF5722),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    _bannerMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ─── Page 1: Live Heart Rate & Zones ─────────────────────────────────────

  Widget _buildHeartRatePage(Size size) {
    final zoneColor = _getHeartRateColor(_heartRate);
    final zoneName = _getHeartRateZone(_heartRate);
    final avgBpm = _heartRateCount > 0 ? (_heartRateSum / _heartRateCount).round() : 0;

    return Container(
      width: size.width,
      height: size.height,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 12),
          // Connection pill
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: _isPhoneConnected ? Colors.greenAccent : Colors.amber,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 5),
              Text(
                _isPhoneConnected ? 'AV FITNESS' : 'OFFLINE',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const Spacer(),

          // Pulsing Heart Icon
          ScaleTransition(
            scale: _pulseAnim,
            child: Icon(
              Icons.favorite_rounded,
              color: zoneColor,
              size: 32,
            ),
          ),
          const SizedBox(height: 2),

          // Main BPM Display
          Text(
            _heartRate != null ? '${_heartRate!.toInt()}' : '--',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.w900,
              height: 1.0,
            ),
          ),
          Text(
            'BPM',
            style: TextStyle(
              color: zoneColor,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 6),

          // Heart Rate Zone Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: zoneColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: zoneColor.withValues(alpha: 0.6), width: 1),
            ),
            child: Text(
              zoneName,
              style: TextStyle(
                color: zoneColor,
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
          ),
          const Spacer(),

          // Mini Stats Row (Avg & Max)
          if (_heartRateCount > 0)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'AVG $avgBpm',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'MAX ${_maxHeartRate?.toInt() ?? "--"}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

          const SizedBox(height: 4),
          _buildPageIndicator(),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  // ─── Page 2: Live Workout & Interactive Controls ─────────────────────────

  Widget _buildWorkoutPage(Size size) {
    if (!_workoutState.hasActiveWorkout) {
      return Container(
        width: size.width,
        height: size.height,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.fitness_center_rounded, color: Color(0xFFFF5722), size: 28),
            const SizedBox(height: 8),
            const Text(
              'No Active Workout',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 6),
            Text(
              _isPhoneConnected
                  ? 'Start a workout on your phone to track sets & rest here.'
                  : 'Connect to phone to sync live workout routines.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.5)),
            ),
            const Spacer(),
            _buildPageIndicator(),
            const SizedBox(height: 4),
          ],
        ),
      );
    }

    final isRest = _workoutState.isResting;

    return Container(
      width: size.width,
      height: size.height,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 12),
          // Current Exercise Name
          Text(
            _workoutState.currentExercise,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),

          // Set & Target info
          Text(
            'Set ${_workoutState.currentSetNumber} of ${_workoutState.totalExerciseSets} • ${_workoutState.weight.toStringAsFixed(1)} ${_workoutState.weightUnit} × ${_workoutState.reps}',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),

          // Rest Timer or Workout Progress Banner
          if (isRest)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.orange, width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.timer, color: Colors.orange, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    'REST: ${_workoutState.restRemaining}s',
                    style: const TextStyle(
                      color: Colors.orange,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF1E88E5).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'COMPLETED: ${_workoutState.completedSets}/${_workoutState.totalSets} SETS',
                style: const TextStyle(
                  color: Color(0xFF90CAF9),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

          const Spacer(),

          // Primary Watch Action Buttons
          if (isRest)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Skip Rest button
                GestureDetector(
                  onTap: () {
                    HealthService.vibrateOnce();
                    HealthService.sendWorkoutCommand('skip_rest');
                    _showBanner('Skipped Rest');
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: const Color(0xFF333333),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      'Skip',
                      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // +30s Rest button
                GestureDetector(
                  onTap: () {
                    HealthService.vibrateOnce();
                    HealthService.sendWorkoutCommand('add_rest_30');
                    _showBanner('+30s Added');
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF5722),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      '+30s',
                      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            )
          else
            GestureDetector(
              onTap: () {
                HealthService.vibrateDouble();
                HealthService.sendWorkoutCommand('complete_set');
                _showBanner('Set Completed! ✓');
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF5722), Color(0xFFFF8A65)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_rounded, color: Colors.white, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'LOG SET',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 6),
          _buildPageIndicator(),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  // ─── Page 3: Tools & Diagnostic Info ──────────────────────────────────────

  Widget _buildToolsPage(Size size) {
    return Container(
      width: size.width,
      height: size.height,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 8),
          const Text(
            'WATCH TOOLS',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 10),

          // Test Haptic Button
          GestureDetector(
            onTap: () {
              HealthService.vibrateDouble();
              _showBanner('Haptic OK');
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF222222),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF444444)),
              ),
              child: const Text(
                'Test Haptic Buzz',
                style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Ping Phone Button
          GestureDetector(
            onTap: () {
              HealthService.vibrateOnce();
              HealthService.sendWorkoutCommand('ping_phone');
              _showBanner('Pinged Phone');
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF2979FF).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF2979FF)),
              ),
              child: const Text(
                'Ping Phone',
                style: TextStyle(color: Color(0xFF82B1FF), fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 10),

          Text(
            _isPhoneConnected
                ? 'Connected: $_phoneName'
                : 'No phone connected via Wearable API',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _isPhoneConnected ? Colors.greenAccent : Colors.grey,
              fontSize: 9,
            ),
          ),

          const Spacer(),
          _buildPageIndicator(),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        final isActive = i == _currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: isActive ? 12 : 5,
          height: 5,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: isActive
                ? const Color(0xFFFF5722)
                : Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }
}
