import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:maple_harvest_app/core/core.dart';

class AnalyticsService {
  final FirebaseAnalytics _analytics;

  final CrashlyticsService _crashlytics;

  final LoggerUtils _logger;

  String? _currentScreen;

  String? _previousScreen;

  UserAnalyticsModel? _userInfo;

  static const _tag = 'AnalyticsService';

  AnalyticsService._({
    required FirebaseAnalytics analytics,
    required LoggerUtils loggerUtils,
    required CrashlyticsService crashlyticsService,
  })  : _analytics = analytics,
        _logger = loggerUtils,
        _crashlytics = crashlyticsService;

  static Future<AnalyticsService> create({
    required FirebaseAnalytics analytics,
    required LoggerUtils loggerUtils,
    required CrashlyticsService crashlyticsService,
  }) async {
    final service = AnalyticsService._(
      analytics: analytics,
      loggerUtils: loggerUtils,
      crashlyticsService: crashlyticsService,
    );
    await service._init();
    return service;
  }

  Future<void> _init() async {
    try {
      if (kDebugMode) {
        _logger.log(_tag, 'Analytics initialized in debug mode');
        return;
      }
      _analytics.setAnalyticsCollectionEnabled(true);
      _logger.log(_tag, 'Analytics initialized');
    } catch (error, stackTrace) {
      await _crashlytics.recordError(
        error,
        stackTrace,
        reason: 'Failed to initialize Analytics',
      );
    }
  }

  late final navigatorObserver = FirebaseAnalyticsObserver(
    analytics: _analytics,
    nameExtractor: (route) {
      final routeName = route.name;
      if (routeName != null) {
        _updateScreenTracking(routeName);
      }
      return routeName;
    },
  );

  void _updateScreenTracking(String screenName) {
    _previousScreen = _currentScreen;
    _currentScreen = screenName;
  }

  Future<void> logEvent(
    AnalyticsEventType event, {
    Map<String, dynamic>? customParams,
    AnalyticsParamsModel? params,
  }) async {
    try {
      if (kDebugMode) {
        _logger.log(_tag, 'Event logged: $event');
        return;
      }

      final newParams = (params ?? AnalyticsParamsModel())
        ..addTimestamp()
        ..addCustomParams(customParams ?? {});

      if (_userInfo != null) {
        newParams.addUserInfo(_userInfo!);
      }

      await _analytics.logEvent(
        name: event.name,
        parameters: newParams.build(),
      );
      _logger.log(_tag, 'Event logged: $event');
    } catch (error, stackTrace) {
      await _crashlytics.recordError(
        error,
        stackTrace,
        reason: 'Analytics Event Logging Failed',
        additionalData: {
          'event': event.name,
        },
      );
    }
  }

  Future<void> logScreenEvent(BuildContext context) async {
    if (!context.mounted) return;
    try {
      final currentWidget = context.widget.runtimeType.toString();
      if (kDebugMode) {
        _logger.log(_tag, 'Screen view logged: $currentWidget');
        return;
      }

      final routeName = ModalRoute.of(context)?.settings.name;

      _updateScreenTracking(currentWidget);

      final screenInfo = ScreenInfoModel(
        screenName: currentWidget,
        routeName: routeName,
        previousScreen: _previousScreen,
      );

      final params = AnalyticsParamsModel()
        ..addScreenInfo(screenInfo)
        ..addTimestamp();

      if (_userInfo != null) {
        params.addUserInfo(_userInfo!);
      }

      await _analytics.logScreenView(
        screenName: screenInfo.screenName,
        parameters: params.build(),
      );
      _logger.log(_tag, 'Screen view logged: $currentWidget');
    } catch (e) {
      await _crashlytics.recordError(
        e,
        StackTrace.current,
        reason: 'Analytics Screen Logging Failed',
        additionalData: context.mounted
            ? {
                'screen': context.widget.runtimeType.toString(),
                'route': ModalRoute.of(context)?.settings.name,
              }
            : null,
      );
    }
  }

  Future<void> setUserInfo(UserAnalyticsModel newInfo) async {
    try {
      await Future.wait([
        _analytics.setUserId(id: newInfo.userId),
        _analytics.setUserProperty(
          name: UserAnalyticsModel.isAnonymousKey,
          value: newInfo.isAnonymous.toString(),
        )
      ]);
      _userInfo = newInfo;
    } catch (error, stackTrace) {
      await _crashlytics.recordError(
        error,
        stackTrace,
        reason: 'Failed to set user property',
      );
    }
  }

  Future<void> removeUserInfo() async {
    try {
      await logEvent(AnalyticsEventType.logout);
      await _analytics.setUserId();
    } catch (error, stackTrace) {
      await _crashlytics.recordError(
        error,
        stackTrace,
        reason: 'Failed to remove user property',
      );
    } finally {
      _userInfo = null;
    }
  }
}
