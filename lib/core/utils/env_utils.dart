import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvUtils {
  String getEnvVariable(String key) {
    final value = dotenv.env[key];
    if (value == null || value.isEmpty) {
      throw StateError('$key environment variable is not set');
    }
    return value;
  }
}
