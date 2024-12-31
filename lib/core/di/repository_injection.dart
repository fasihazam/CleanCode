import 'package:flutter/services.dart';
import 'package:location/location.dart';
import 'package:maple_harvest_app/core/core.dart';
import 'package:maple_harvest_app/features/location/location.dart';

class RepositoryInjection {
  static Future<void> init() async {
    // DataSources
    _initDataSources();

    // Repositories
    _initRepositories();
  }

  static void _initDataSources() {
    if (!sl.isRegistered<UserDatasource>()) {
      sl.registerSingleton<UserDatasource>(UserDatasourceImpl(
        graphQLService: sl(),
        loggerUtils: sl(),
      ));
    }

    sl.registerSingleton<AuthDatasource>(AuthDatasourceImpl(
      graphQLService: sl(),
    ));

    sl.registerSingleton<GoogleLocationDataSource>(
      LocationDataSourceImpl(
        dio: sl(),
        logger: sl(),
        envUtils: sl(),
      ),
    );

    sl.registerSingleton<MapKitLocationDataSource>(
      MapKitDataSourceImpl(
        const MethodChannel('info.lieferking.mapleharvest/mkmapkit'),
      ),
    );
  }

  static void _initRepositories() {
    sl.registerSingleton<AuthRepository>(AuthRepoImpl(
      userDatasource: sl(),
      authDatasource: sl(),
      loggerUtils: sl(),
    ));

    //LocationRepository
    sl.registerSingleton<LocationRepository>(
      LocationRepositoryImpl(
        fallbackLocationService: FallbackLocationService(
          googleDataSource: sl(),
          mapKitDataSource: sl(),
        ),
        googleLocationDataSource: sl(),
        location: Location(),
      ),
    );

    if (!sl.isRegistered<UserRepository>()) {
      sl.registerSingleton<UserRepository>(UserRepoImpl(sl()));
    }

    sl.registerSingleton<PermissionRepository>(PermissionRepoImpl());
  }

  RepositoryInjection._();
}
