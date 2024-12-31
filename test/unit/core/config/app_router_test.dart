import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:maple_harvest_app/core/core.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('AppRouter', () {
    late AppRouter appRouter;
    late GlobalKey<NavigatorState> navigatorKey;

    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
      await EasyLocalization.ensureInitialized();
      setupFirebaseCoreMocks();
      await Firebase.initializeApp();

      await Injection.init();
    });

    tearDownAll(() {
      sl.reset();
    });

    setUp(() {
      navigatorKey = GlobalKey<NavigatorState>();
      appRouter = AppRouter(navigatorKey: navigatorKey);
    });

    test('initializes with provided navigator key', () {
      expect(appRouter.navigatorKey, equals(navigatorKey));
    });

    test('initializes with default navigator key when none provided', () {
      final defaultRouter = AppRouter();
      expect(defaultRouter.navigatorKey, isA<GlobalKey<NavigatorState>>());
    });

    test('router is properly configured', () {
      final router = appRouter.router;
      expect(router, isA<GoRouter>());
      expect(router.routerDelegate.navigatorKey, equals(navigatorKey));
    });
  });
}