import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:maple_harvest_app/core/core.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final sl = GetIt.instance;

  Future<void> setupMocks() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    setupFirebaseCoreMocks();
    try {
      await Firebase.initializeApp();
    } catch (e) {
      throw Exception('Failed to initialize Firebase: $e');
    }
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  }

  setUpAll(() async {
    await setupMocks();
  });

  group('Injection', () {
    test('init should initialize all dependencies in correct order', () async {
      await Injection.init();

      expect(sl.isRegistered<Logger>(), isTrue);
      expect(sl.isRegistered<FirebaseAnalytics>(), isTrue);
      expect(sl.isRegistered<FirebaseCrashlytics>(), isTrue);
      expect(sl.isRegistered<VendureGraphQLClient>(), isTrue);
      expect(sl.isRegistered<UserDatasource>(), isTrue);
      expect(sl.isRegistered<AuthDatasource>(), isTrue);
      expect(sl.isRegistered<AuthRepository>(), isTrue);
      expect(sl.isRegistered<UserRepository>(), isTrue);
      expect(sl.isRegistered<AppRouter>(), isTrue);
      expect(sl.isRegistered<CrashlyticsService>(), isTrue);
      expect(sl.isRegistered<AnalyticsService>(), isTrue);
      expect(sl.isRegistered<FlutterSecureStorage>(), isTrue);
      expect(sl.isRegistered<SharedPreferences>(), isTrue);
      expect(sl.isRegistered<Connectivity>(), isTrue);
      expect(sl.isRegistered<ToastUtils>(), isTrue);
      expect(sl.isRegistered<DialogService>(), isTrue);
      expect(sl.isRegistered<MessagingService>(), isTrue);
      expect(sl.isRegistered<PermissionUseCases>(), isTrue);
    });
  });
}
