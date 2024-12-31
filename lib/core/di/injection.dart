import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:maple_harvest_app/core/core.dart';

final sl = GetIt.instance;

class Injection {
  static Future<void> init() async {
    // Load environment variables.
    await dotenv.load(fileName: ".env");

    // Register the EnvUtils class as a singleton
    sl.registerSingleton<EnvUtils>(EnvUtils());

    // 1. Initialize core logging and crash reporting first
    await CoreInjection.init();

    // 2. Initialize infrastructure dependencies
    await FirebaseInjection.init();
    await NetworkInjection.init();

    // 3. Initialize remaining services and features
    await ServiceInjection.init();
    await RepositoryInjection.init();
    await UseCaseInjection.init();

    await sl.allReady();
  }
}
