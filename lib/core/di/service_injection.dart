import 'package:maple_harvest_app/core/core.dart';

class ServiceInjection {
  static Future<void> init() async {
    // App Router
    sl.registerSingleton<AppRouter>(AppRouter());

    // Analytics
    sl.registerSingletonAsync<AnalyticsService>(
      () async => AnalyticsService.create(
        analytics: sl(),
        loggerUtils: sl(),
        crashlyticsService: sl(),
      ),
    );

    // Dialog
    sl.registerSingleton<DialogService>(
      DialogService(
        crashlyticsService: sl(),
        loggerUtils: sl(),
        navigatorKey: sl<AppRouter>().navigatorKey,
      ),
    );
  }

  ServiceInjection._();
}
