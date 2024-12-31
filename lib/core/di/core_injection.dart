import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:logger/logger.dart';
import 'package:maple_harvest_app/core/core.dart';

/// It will contain all the core dependencies that must be initialized first
/// before any other dependencies.
class CoreInjection {
  static Future<void> init() async {
    // Logger first as crash reporting needs it
    sl.registerSingleton<Logger>(Logger());
    sl.registerSingleton<LoggerUtils>(LoggerUtils(sl()));

    // 2. CrashlyticsService needs this
    sl.registerSingleton<FirebaseCrashlytics>(FirebaseCrashlytics.instance);

    // 3. Crash reporting service
    sl.registerSingleton<CrashlyticsService>(
      CrashlyticsService(
        crashlytics: sl(),
        loggerUtils: sl(),
      ),
    );

    // initializing here as it is required by MessagingService
    // MessagingService needs this to store user token
    await StorageInjection.init();
    await GraphQLInjection.init();
    sl.registerSingleton<UserDatasource>(
      UserDatasourceImpl(
        graphQLService: sl<GraphQLService>(),
        loggerUtils: sl(),
      ),
    );
    sl.registerSingleton<UserRepository>(UserRepoImpl(sl<UserDatasource>()));

    // Messaging
    sl.registerSingletonAsync<MessagingService>(
      () async => await MessagingService.create(
        messaging: sl(),
        localNotifications: sl(),
        crashlyticService: sl(),
        loggerUtils: sl(),
        userRepository: sl(),
      ),
    );
  }

  CoreInjection._();
}
