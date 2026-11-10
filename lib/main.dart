import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app.dart';
import 'core/utils/mock_data_seeder.dart';
import 'core/services/local_notifications_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  await LocalNotificationsService().init();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization failed (ensure you ran flutterfire configure): $e');
  }

  // Note: MockDataSeeder has been moved to SplashScreen 
  // to prevent blocking the UI frame and causing unoptimized app startup.

  runApp(
    const ProviderScope(
      child: FitnessApp(),
    ),
  );
}
