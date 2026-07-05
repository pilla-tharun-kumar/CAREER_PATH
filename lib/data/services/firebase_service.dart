import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../core/config.dart';

class FirebaseService {
  static bool _isInitialized = false;

  static bool get isInitialized => _isInitialized;

  static Future<void> initialize() async {
    if (!RpgConfig.isFirebaseEnabled) {
      debugPrint("🎯 [LifeQuest RPG] Firebase Authentication is currently disabled in RpgConfig.");
      return;
    }

    try {
      // Initialize Firebase SDK
      await Firebase.initializeApp();
      _isInitialized = true;
      debugPrint("🔥 [LifeQuest RPG] Firebase successfully initialized!");
    } catch (e) {
      _isInitialized = false;
      RpgConfig.isFirebaseEnabled = false; // Turn off feature flag to trigger fallback mock authentication
      debugPrint("To fix: Please ensure 'google-services.json' (Android) and 'GoogleService-Info.plist' (iOS) are configured, or run 'flutterfire configure'.");
    }
  }
}
