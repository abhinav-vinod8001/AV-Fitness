import 'dart:async';
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
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFFFF5722),
          secondary: const Color(0xFF2979FF),
          surface: Colors.black,
        ),
        fontFamily: 'sans-serif',
      ),
      home: const WatchHomeScreen(),
    );
  }
}

// ─── Health Service Bridge ───────────────────────────────────────────────────

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
    await _healthChannel.invokeMethod('requestPermissions');
  }

  static Future<void> startHeartRate() async {
    await _healthChannel.invokeMethod('startHeartRate');
  }

  static Future<void> stopHeartRate() async {
    await _healthChannel.invokeMethod('stopHeartRate');
  }

  static Future<void> startSkinTemp() async {
    await _healthChannel.invokeMethod('startSkinTemp');
  }

  static Future<void> stopSkinTemp() async {
    await _healthChannel.invokeMethod('stopSkinTemp');
  }

  static Future<void> vibrate({List<int> pattern = const [0, 200, 100, 200]}) async {
    await _hapticChannel.invokeMethod('vibrate', {'pattern': pattern});
  }

  static Future<void> vibrateOnce() async {
    await _hapticChannel.invokeMethod('vibrateOnce');
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
  double? _skinTemp;
  bool _monitoring = false;
  StreamSubscription? _healthSub;

  // Pulse animation
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _startMonitoring();
  }

  Future<void> _startMonitoring() async {
    await HealthService.requestPermissions();
    await HealthService.startHeartRate();
    await HealthService.startSkinTemp();

    _healthSub = HealthService.healthStream.listen((data) {
      if (!mounted) return;
      final type = data['type'] as String?;
      final value = data['value'];
      setState(() {
        _monitoring = true;
        if (type == 'heart_rate' && value is num) {
          _heartRate = value.toDouble();
        } else if (type == 'skin_temp' && value is num) {
          _skinTemp = value.toDouble();
        }
      });
    });
  }

  @override
  void dispose() {
    _healthSub?.cancel();
    HealthService.stopHeartRate();
    HealthService.stopSkinTemp();
    _pulseController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isRound = size.width == size.height;

    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView(
        controller: _pageController,
        onPageChanged: (i) => setState(() => _currentPage = i),
        children: [
          _buildHeartRatePage(size),
          _buildStatsPage(size),
        ],
      ),
    );
  }

  // ─── Page 1: Heart Rate + Temp ──────────────────────────────────

  Widget _buildHeartRatePage(Size size) {
    return Container(
      width: size.width,
      height: size.height,
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 0.85,
          colors: [Color(0xFF1A0A00), Colors.black],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 8),
          // App Title
          Text(
            'AV FITNESS',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 12),

          // Heart Rate
          ScaleTransition(
            scale: _pulseAnim,
            child: Icon(
              Icons.favorite_rounded,
              color: _heartRate != null
                  ? const Color(0xFFFF5722)
                  : Colors.white.withValues(alpha: 0.3),
              size: 36,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _heartRate != null ? '${_heartRate!.toInt()}' : '--',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 52,
              fontWeight: FontWeight.bold,
              height: 1.0,
            ),
          ),
          Text(
            'BPM',
            style: TextStyle(
              color: const Color(0xFFFF5722).withValues(alpha: 0.8),
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 16),

          // Divider
          Container(
            width: 40,
            height: 1,
            color: Colors.white.withValues(alpha: 0.1),
          ),
          const SizedBox(height: 12),

          // Skin Temperature
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.thermostat_rounded,
                color: _skinTemp != null
                    ? const Color(0xFF2979FF)
                    : Colors.white.withValues(alpha: 0.3),
                size: 20,
              ),
              const SizedBox(width: 6),
              Text(
                _skinTemp != null
                    ? '${_skinTemp!.toStringAsFixed(1)}°C'
                    : '-- °C',
                style: TextStyle(
                  color: _skinTemp != null
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.4),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Skin Temp',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.3),
              fontSize: 10,
            ),
          ),

          const Spacer(),
          // Page indicator
          _buildPageIndicator(),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // ─── Page 2: Quick Stats ────────────────────────────────────────

  Widget _buildStatsPage(Size size) {
    return Container(
      width: size.width,
      height: size.height,
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'WORKOUT',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),

          // Status indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF333333)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF4CAF50),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Ready',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Heart Rate Mini
          if (_heartRate != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.favorite_rounded, color: Color(0xFFFF5722), size: 16),
                const SizedBox(width: 4),
                Text(
                  '${_heartRate!.toInt()} BPM',
                  style: const TextStyle(
                    color: Color(0xFFFF5722),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],

          // Skin Temp Mini
          if (_skinTemp != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.thermostat_rounded, color: Color(0xFF2979FF), size: 16),
                const SizedBox(width: 4),
                Text(
                  '${_skinTemp!.toStringAsFixed(1)}°C',
                  style: const TextStyle(
                    color: Color(0xFF2979FF),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],

          // Tap to vibrate test
          GestureDetector(
            onTap: () => HealthService.vibrateOnce(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFF5722),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Test Haptic',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const Spacer(),
          _buildPageIndicator(),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(2, (i) {
        final isActive = i == _currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: isActive ? 12 : 6,
          height: 6,
          margin: const EdgeInsets.symmetric(horizontal: 3),
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
