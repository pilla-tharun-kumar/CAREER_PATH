import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/theme.dart';
import 'data/models/user_profile.dart';
import 'screens/splash_screen.dart';
import 'data/services/firebase_service.dart';
import 'data/services/mongo_sync_service.dart';
import 'data/services/telemetry_service.dart';
import 'providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Register Hive Adapters
  Hive.registerAdapter(UserProfileAdapter());

  // Open Boxes
  await Hive.openBox<UserProfile>('profile');

  // Initialize Remote Services (Firebase & MongoDB Atlas Sync)
  await FirebaseService.initialize();
  await MongoSyncService.initialize();
  await TelemetryService.initialize();

  runApp(
    const ProviderScope(
      child: LifeQuestApp(),
    ),
  );
}

class LifeQuestApp extends ConsumerWidget {
  const LifeQuestApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(isDarkModeProvider);
    RpgColors.isDarkMode = isDark;

    return MaterialApp(
      title: 'CareerPath',
      debugShowCheckedModeBanner: false,
      theme: isDark ? RpgTheme.darkTheme : RpgTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
