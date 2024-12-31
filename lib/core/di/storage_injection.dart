import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:maple_harvest_app/core/core.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageInjection {
  /// Initializes storage-related dependencies in the following order:
  /// 1. FlutterSecureStorage for secure key-value storage
  /// 2. SharedPreferences for persistent key-value storage
  /// 3. PrefsUtils which depends on both storage implementations
  static Future<void> init() async {
    // Secure Storage
    sl.registerSingleton<FlutterSecureStorage>(
      const FlutterSecureStorage(),
    );

    // Shared Preferences
    final prefs = await SharedPreferences.getInstance();
    sl.registerSingleton<SharedPreferences>(prefs);

    // Utils
    sl.registerSingleton<PrefsUtils>(
      PrefsUtils(
        prefs: sl(),
        storage: sl(),
        loggerUtils: sl(),
        crashlyticsService: sl(),
      ),
    );
  }

  StorageInjection._();
}
