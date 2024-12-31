import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:maple_harvest_app/core/core.dart';
import 'package:permission_handler/permission_handler.dart';

/// A service class responsible for handling push notifications and local notifications
/// following clean architecture principles.
class MessagingService {
  final FirebaseMessaging _messaging;

  final FlutterLocalNotificationsPlugin _localNotifications;

  final CrashlyticsService _crashlytics;

  final LoggerUtils _logger;

  final UserRepository _userRepository;

  static const _tag = 'MessagingService';

  bool _notificationInitialized = false;

  bool get notificationInitialized => _notificationInitialized;

  MessagingService._({
    required FirebaseMessaging messaging,
    required FlutterLocalNotificationsPlugin localNotifications,
    required CrashlyticsService crashlyticService,
    required LoggerUtils loggerUtils,
    required UserRepository userRepository,
  })  : _messaging = messaging,
        _localNotifications = localNotifications,
        _crashlytics = crashlyticService,
        _logger = loggerUtils,
        _userRepository = userRepository;

  static Future<MessagingService> create({
    required FirebaseMessaging messaging,
    required FlutterLocalNotificationsPlugin localNotifications,
    required CrashlyticsService crashlyticService,
    required LoggerUtils loggerUtils,
    required UserRepository userRepository,
  }) async {
    final service = MessagingService._(
      messaging: messaging,
      localNotifications: localNotifications,
      crashlyticService: crashlyticService,
      loggerUtils: loggerUtils,
      userRepository: userRepository,
    );

    await service.init();
    return service;
  }

  Future<void> init() async {
    try {
      await _initMessaging();
      await _setupTokenRefresh();
      await initNotifications();
    } catch (error, stackTrace) {
      await _crashlytics.recordError(error, stackTrace);
      _logger.logError(
          _tag, 'Error initializing messaging service $error\n$stackTrace');
    }
  }

  Future<void> _handleNotificationInteraction(RemoteMessage message) async {
    try {
      _logger.logInfo(
          _tag, 'Handling notification interaction: ${message.messageId}');
    } catch (error, stackTrace) {
      await _crashlytics.recordError(
        error,
        stackTrace,
        reason: 'Error handling notification interaction',
        additionalData: {'message': message.toMap()},
      );
      _logger.logError(
          _tag, 'Error handling notification interaction $error\n$stackTrace');
    }
  }

  Future<void> initNotifications() async {
    try {
      if (notificationInitialized) {
        _logger.logInfo(_tag, 'Messaging service already initialized');
        return;
      }

      // Check if notification permission is already granted
      final hasPermission = await hasNotificationPermission();
      if (!hasPermission) return;

      await _initLocalNotifications();

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle notification taps when app is in background
      FirebaseMessaging.onMessageOpenedApp
          .listen(_handleNotificationInteraction);

      _notificationInitialized = true;

      _logger.logInfo(_tag, 'Notifications initialized');
    } catch (error, stackTrace) {
      await _crashlytics.recordError(error, stackTrace,
          reason: 'Failed to initialize notifications');
      _logger.logError(
          _tag, 'Error initializing notifications $error\n$stackTrace');
    }
  }

  Future<void> _initLocalNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      defaultPresentAlert: true,
      defaultPresentBadge: true,
      defaultPresentSound: true,
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        _logger.logInfo(_tag, 'Local notification tapped: ${details.payload}');
      },
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  void _handleForegroundMessage(RemoteMessage message) {
    _logger.logInfo(_tag, 'Received foreground message: ${message.messageId}');
    showLocalNotification(message);
  }

  Future<void> showLocalNotification(RemoteMessage message) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        NetworkConstants.appNotificationChannel,
        AppStrings.appName,
        channelDescription: NetworkConstants.appChannelDesc,
        importance: Importance.max,
        priority: Priority.high,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.show(
        message.hashCode,
        message.notification?.title,
        message.notification?.body,
        details,
        payload: message.data.toString(),
      );
    } catch (error, stackTrace) {
      await _crashlytics.recordError(error, stackTrace);
      _logger.logError(
          _tag, 'Error showing local notification $error\n$stackTrace');
    }
  }

  Future<String?> getToken() async {
    try {
      final token = await _messaging.getToken();
      _logger.logInfo(_tag, 'FCM Token: ${token?.protect(showLastChars: 5)}');
      return token;
    } catch (error, stackTrace) {
      _crashlytics.recordError(error, stackTrace);
      _logger.logInfo(_tag, 'Error getting FCM token $error\n$stackTrace');
      return null;
    }
  }

  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      _logger.logInfo(_tag, 'Subscribed to topic: $topic');
    } catch (error, stackTrace) {
      await _crashlytics.recordError(error, stackTrace);
      _logger.logInfo(_tag, 'Error subscribing to topic $error\n$stackTrace');
      rethrow;
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      _logger.logInfo(_tag, 'Unsubscribed from topic: $topic');
    } catch (error, stackTrace) {
      await _crashlytics.recordError(error, stackTrace);
      _logger.logError(
          _tag, 'Error unsubscribing from topic $error\n$stackTrace');
      rethrow;
    }
  }

  Future<PermissionStatus> checkStatus() async {
    try {
      final settings = await _messaging.getNotificationSettings();
      switch (settings.authorizationStatus) {
        case AuthorizationStatus.authorized:
        case AuthorizationStatus.provisional:
          return PermissionStatus.granted;
        case AuthorizationStatus.denied:
          return PermissionStatus.permanentlyDenied;
        case AuthorizationStatus.notDetermined:
          return PermissionStatus.denied;
      }
    } catch (e) {
      _logger.logError(
          _tag, 'Failed to check notification permission status: $e');
      return PermissionStatus.denied;
    }
  }

  Future<bool> hasNotificationPermission() async {
    final settings = await _messaging.getNotificationSettings();
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  Future<void> _updateToken() async {
    try {
      final token = await getToken();
      if (token == null || token.isEmpty) return;

      final result =
          await _userRepository.updateUser(CustomerRequest.withToken(token));
      result.fold(
        (error) =>
            _logger.logError(_tag, 'Failed to update user token: $error'),
        (_) => _logger.logInfo(
            _tag, 'User token updated to ${token.protect(showLastChars: 5)}'),
      );
    } catch (e) {
      _logger.logError(_tag, 'Failed to update user token: $e');
    }
  }

  Future<void> _initMessaging() async {
    // Check if app was launched from notification when terminated
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      await _handleNotificationInteraction(initialMessage);
    }
  }

  Future<void> _setupTokenRefresh() async {
    _messaging.onTokenRefresh.listen(
      (token) => _updateToken(),
      onError: (error, stackTrace) => _crashlytics
          .recordError(error, stackTrace, reason: 'Token refresh error'),
    );
  }

  /// Request permission to show notifications using [FirebaseMessaging].
  Future<bool> requestPermission() async {
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      final authorized =
          settings.authorizationStatus == AuthorizationStatus.authorized ||
              settings.authorizationStatus == AuthorizationStatus.provisional;

      _logger.logInfo(_tag,
          'Notification permission status: ${settings.authorizationStatus}');

      if (authorized) {
        // Fire and forget token update only if permission was granted
        // to avoid blocking the UI
        unawaited(_updateToken());
      }

      return authorized;
    } catch (e, stack) {
      await _crashlytics.recordError(e, stack,
          reason: 'Failed to request notification permission');
      _logger.logError(_tag, 'Error requesting notification permission: $e');
      return false;
    }
  }
}
