import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maple_harvest_app/core/core.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:permission_handler/permission_handler.dart';

import 'messaging_service_test.mocks.dart';

@GenerateMocks([
  FirebaseMessaging,
  FlutterLocalNotificationsPlugin,
  IOSFlutterLocalNotificationsPlugin,
  CrashlyticsService,
  LoggerUtils,
  UserRepository,
], customMocks: [
  MockSpec<RemoteMessage>(
    as: #MockRemoteMessageCustom,
    onMissingStub: OnMissingStub.returnDefault,
  ),
])
void main() {
  late MessagingService messagingService;
  late MockFirebaseMessaging mockMessaging;
  late MockFlutterLocalNotificationsPlugin mockLocalNotifications;
  late MockCrashlyticsService mockCrashlytics;
  late MockLoggerUtils mockLogger;
  late MockUserRepository mockUserRepository;
  late MockRemoteMessageCustom mockMessage;
  late StreamController<String> tokenStreamController;

  setUp(() async {
    mockMessaging = MockFirebaseMessaging();
    mockLocalNotifications = MockFlutterLocalNotificationsPlugin();
    mockCrashlytics = MockCrashlyticsService();
    mockLogger = MockLoggerUtils();
    mockUserRepository = MockUserRepository();
    mockMessage = MockRemoteMessageCustom();
    tokenStreamController = StreamController<String>.broadcast();

    // Firebase Messaging setup
    when(mockMessaging.getInitialMessage()).thenAnswer((_) async => null);
    when(mockMessaging.onTokenRefresh)
        .thenAnswer((_) => tokenStreamController.stream);
    when(mockMessaging.getToken()).thenAnswer((_) async => 'test-token');

    // Local Notifications setup
    when(mockLocalNotifications.initialize(
      any,
      onDidReceiveNotificationResponse:
          anyNamed('onDidReceiveNotificationResponse'),
    )).thenAnswer((_) async => true);

    when(mockLocalNotifications.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>())
        .thenReturn(null);

    // Mock message setup
    when(mockMessage.messageId).thenReturn('test-message-id');
    when(mockMessage.notification).thenReturn(
      const RemoteNotification(title: 'Test Title', body: 'Test Body'),
    );

    // Repository setup
    when(mockUserRepository.updateUser(any))
        .thenAnswer((_) async => const Right(null));

    messagingService = await MessagingService.create(
      messaging: mockMessaging,
      localNotifications: mockLocalNotifications,
      crashlyticService: mockCrashlytics,
      loggerUtils: mockLogger,
      userRepository: mockUserRepository,
    );
  });

  tearDown(() {
    tokenStreamController.close();
  });

  group('initialization', () {
    setUp(() {
      when(mockMessaging.getNotificationSettings()).thenAnswer(
        (_) async => getMockNotificationSettings(
          authorizationStatus: AuthorizationStatus.authorized,
          enabled: true,
        ),
      );
    });

    test('should initialize notifications when permission granted', () async {
      await messagingService.initNotifications();

      verify(mockLogger.logInfo(
              'MessagingService', 'Notifications initialized'))
          .called(1);
      expect(messagingService.notificationInitialized, true);
    });

    test('should not initialize when already initialized', () async {
      await messagingService.initNotifications();
      await messagingService.initNotifications();

      verify(mockLogger.logInfo(
              'MessagingService', 'Messaging service already initialized'))
          .called(1);
    });
  });

  group('notification handling', () {
    setUp(() {
      // Setup mock message
      when(mockMessage.notification).thenReturn(
        const RemoteNotification(
          title: 'Test Title',
          body: 'Test Body',
        ),
      );
      when(mockMessage.data).thenReturn({});
    });

    test('should show local notification', () async {
      await messagingService.showLocalNotification(mockMessage);

      verify(mockLocalNotifications.show(
        mockMessage.hashCode,
        'Test Title',
        'Test Body',
        any,
        payload: '{}',
      )).called(1);
    });

    test('should handle notification error', () async {
      when(mockLocalNotifications.show(
        mockMessage.hashCode,
        'Test Title',
        'Test Body',
        any,
        payload: '{}',
      )).thenThrow(Exception('Test error'));

      await messagingService.showLocalNotification(mockMessage);

      verify(mockCrashlytics.recordError(any, any)).called(1);
      verify(mockLogger.logError(
        'MessagingService',
        contains('Error showing local notification'),
      )).called(1);
    });
  });

  group('permission handling', () {
    test('should check notification permission status', () async {
      when(mockMessaging.getNotificationSettings()).thenAnswer(
        (_) async => getMockNotificationSettings(),
      );

      final result = await messagingService.checkStatus();
      expect(result, PermissionStatus.granted);
    });

    test('should handle denied permission status', () async {
      when(mockMessaging.getNotificationSettings()).thenAnswer(
        (_) async => getMockNotificationSettings(
            authorizationStatus: AuthorizationStatus.denied, enabled: false),
      );

      final result = await messagingService.checkStatus();
      expect(result, PermissionStatus.permanentlyDenied);
    });

    test('should request notification permission', () async {
      when(mockMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      )).thenAnswer(
        (_) async => getMockNotificationSettings(),
      );

      final result = await messagingService.requestPermission();
      expect(result, true);
    });
  });

  group('token management', () {
    test('should get FCM token', () async {
      when(mockMessaging.getToken()).thenAnswer((_) async => 'test-token');

      final token = await messagingService.getToken();
      expect(token, 'test-token');
    });

    test('should handle token refresh', () async {
      final controller = StreamController<String>();
      when(mockMessaging.onTokenRefresh).thenAnswer((_) => controller.stream);

      when(mockUserRepository.updateUser(any))
          .thenAnswer((_) async => const Right(null));

      // Initialize to setup token refresh listener
      await messagingService.init();

      // Simulate token refresh
      controller.add('new-token');
      await Future.delayed(Duration.zero);

      verify(mockUserRepository.updateUser(any)).called(1);
      await controller.close();
    });
  });

  group('topic subscription', () {
    test('should subscribe to topic', () async {
      const topic = 'test-topic';
      when(mockMessaging.subscribeToTopic(topic)).thenAnswer((_) async => {});

      await messagingService.subscribeToTopic(topic);

      verify(mockMessaging.subscribeToTopic(topic)).called(1);
      verify(mockLogger.logInfo(
        'MessagingService',
        'Subscribed to topic: test-topic',
      )).called(1);
    });

    test('should unsubscribe from topic', () async {
      const topic = 'test-topic';
      when(mockMessaging.unsubscribeFromTopic(topic))
          .thenAnswer((_) async => {});

      await messagingService.unsubscribeFromTopic(topic);

      verify(mockMessaging.unsubscribeFromTopic(topic)).called(1);
      verify(mockLogger.logInfo(
        'MessagingService',
        'Unsubscribed from topic: test-topic',
      )).called(1);
    });
  });

  group('error handling', () {
    test('should handle initialization errors', () async {
      when(mockMessaging.getInitialMessage())
          .thenThrow(Exception('Init error'));

      await messagingService.init();

      verify(mockCrashlytics.recordError(any, any)).called(1);
      verify(mockLogger.logError(any, any)).called(2);
    });

    test('should handle token refresh errors', () async {
      final controller = StreamController<String>.broadcast(sync: true);
      when(mockMessaging.onTokenRefresh).thenAnswer((_) => controller.stream);

      await messagingService.init();

      controller.addError(Exception('Refresh error'));
      await Future.delayed(Duration.zero);

      verify(mockCrashlytics.recordError(
        any,
        any,
        reason: 'Token refresh error',
      )).called(1);

      await controller.close();
    });
  });
}

NotificationSettings getMockNotificationSettings({
  AuthorizationStatus authorizationStatus = AuthorizationStatus.authorized,
  bool enabled = true,
}) {
  final setting = enabled
      ? AppleNotificationSetting.enabled
      : AppleNotificationSetting.disabled;

  return NotificationSettings(
    authorizationStatus: authorizationStatus,
    alert: setting,
    badge: setting,
    sound: setting,
    announcement: AppleNotificationSetting.disabled,
    carPlay: AppleNotificationSetting.disabled,
    lockScreen: setting,
    notificationCenter: setting,
    showPreviews: enabled
        ? AppleShowPreviewSetting.always
        : AppleShowPreviewSetting.never,
    timeSensitive: AppleNotificationSetting.disabled,
    criticalAlert: AppleNotificationSetting.disabled,
  );
}
