import 'dart:io';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:maple_harvest_app/core/core.dart';

class CrashlyticsService {
  final FirebaseCrashlytics _crashlytics;
  final LoggerUtils _logger;

  static const _tag = 'CrashlyticsService';

  CrashlyticsService({
    required FirebaseCrashlytics crashlytics,
    required LoggerUtils loggerUtils,
  })  : _crashlytics = crashlytics,
        _logger = loggerUtils {
    _init();
  }

  Future<void> _init() async {
    try {
      await _crashlytics.setCrashlyticsCollectionEnabled(!kDebugMode);

      // setup error handlers
      FlutterError.onError = (details) async {
        await _crashlytics.recordFlutterError(details);
      };

      PlatformDispatcher.instance.onError = (error, stack) {
        _crashlytics.recordError(
          error,
          stack,
          fatal: true,
          reason: 'Platform Error',
          information: ['Error caught by PlatformDispatcher'],
        );

        return true;
      };

      await Future.wait([
        setCustomKey('platform', Platform.operatingSystem),
        setCustomKey('platformVersion', Platform.operatingSystemVersion),
        setCustomKey('platformLocale', Platform.localeName),
        setCustomKey('app_version', const String.fromEnvironment('APP_VERSION', defaultValue: 'unknown')),
      ]);

      _logger.log(_tag, 'Crashlytics initialized');
    } catch (e, stack) {
      _logger.logError(
        'Failed to initialize Crashlytics',
        '$e\n$stack',
      );
    }
  }

  Future<void> recordError(
    dynamic exception,
    StackTrace? stack, {
    bool fatal = false,
    String? reason,
    Iterable<Object> information = const [],
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final List<Object> allInformation = [
        ...information,
        if (additionalData != null)
          ...additionalData.entries.map((e) => '${e.key}: ${e.value}'),
      ];

      await _crashlytics.recordError(
        exception,
        stack,
        fatal: fatal,
        reason: reason,
        information: allInformation,
      );

      _logger.logError(_tag, '$exception\n${stack ?? StackTrace.current}');
    } catch (error) {
      _logger.logError('Failed to record error to Crashlytics', '$error');
    }
  }

  Future<void> setUserIdentifier(String? userId) async {
    try {
      await _crashlytics.setUserIdentifier(
          (userId?.isNotEmpty ?? false) ? userId! : 'anonymous');
    } catch (error) {
      _logger.logError('Failed to set user identifier', '$error');
    }
  }

  Future<void> setCustomKey(String key, dynamic value) async {
    try {
      await _crashlytics.setCustomKey(key, value);
    } catch (error) {
      _logger.logError('Failed to set custom key', '$error');
    }
  }

  Future<void> log(String message) async {
    try {
      await _crashlytics.log(message);
    } catch (error) {
      _logger.logError('Failed to log message', '$error');
    }
  }
}
