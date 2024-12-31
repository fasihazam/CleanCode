import 'package:maple_harvest_app/core/core.dart';

class UseCaseInjection {
  static Future<void> init() async {
    sl.registerLazySingleton<PermissionUseCases>(
      () => PermissionUseCases(
        permissionRepository: sl(),
        dialogService: sl(),
        crashlyticsService: sl(),
        analyticsService: sl(),
        loggerUtils: sl(),
        messagingService: sl(),
      ),
    );
  }

  UseCaseInjection._();
}
