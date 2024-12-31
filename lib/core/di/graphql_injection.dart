import 'package:maple_harvest_app/core/core.dart';

class GraphQLInjection {
  static Future<void> init() async {
    sl.registerSingleton<HeaderManager>(HeaderManager());

    sl.registerSingleton<VendureGraphQLClient>(
      VendureGraphQLClient(
        prefsUtils: sl(),
        logger: sl(),
        headerManager: sl(),
      ),
    );

    sl.registerSingleton<GraphQLService>(GraphQLService(sl()));

    await sl<VendureGraphQLClient>().init();
  }

  GraphQLInjection._();
}
