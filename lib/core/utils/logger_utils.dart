import 'package:logger/logger.dart';

class LoggerUtils {

  final Logger _logger;

  LoggerUtils(this._logger);

  void log(String tag, dynamic message) => _logger.d('$tag: $message');

  void logError(String tag, dynamic message) => _logger.e('$tag: $message');

  void logInfo(String tag, dynamic message) => _logger.i('$tag: $message');
}
