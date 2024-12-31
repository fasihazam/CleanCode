import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maple_harvest_app/core/core.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'permission_usecase_test.mocks.dart';

@GenerateMocks([
  PermissionRepository,
  DialogService,
  CrashlyticsService,
  AnalyticsService,
  LoggerUtils,
  MessagingService,
])
void main() {
  late PermissionUseCases permissionUseCase;
  late MockPermissionRepository mockRepository;
  late MockDialogService mockDialogService;
  late MockCrashlyticsService mockCrashlytics;
  late MockAnalyticsService mockAnalyticsService;
  late MockLoggerUtils mockLoggerUtils;
  late MockMessagingService mockMessagingService;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  setUp(() {
    mockRepository = MockPermissionRepository();
    mockDialogService = MockDialogService();
    mockCrashlytics = MockCrashlyticsService();
    mockAnalyticsService = MockAnalyticsService();
    mockLoggerUtils = MockLoggerUtils();
    mockMessagingService = MockMessagingService();

    permissionUseCase = PermissionUseCases(
      permissionRepository: mockRepository,
      dialogService: mockDialogService,
      crashlyticsService: mockCrashlytics,
      analyticsService: mockAnalyticsService,
      loggerUtils: mockLoggerUtils,
      messagingService: mockMessagingService,
    );
  });

  group('requestPermission', () {
    test('should return true when permission is already granted', () async {
      when(mockRepository.checkStatus(Permission.camera))
          .thenAnswer((_) async => PermissionStatus.granted);

      final result =
          await permissionUseCase.requestPermission(Permission.camera);

      expect(result, true);
      verify(mockRepository.checkStatus(Permission.camera)).called(1);
      verifyNever(mockRepository.request(any));
    });

    test('should handle limited photo permission correctly', () async {
      when(mockRepository.checkStatus(Permission.photos))
          .thenAnswer((_) async => PermissionStatus.limited);

      final result =
          await permissionUseCase.requestPermission(Permission.photos);

      expect(result, true);
      verify(mockRepository.checkStatus(Permission.photos)).called(1);
    });

    test('should show dialog and return false for restricted permission',
        () async {
      when(mockRepository.checkStatus(Permission.camera))
          .thenAnswer((_) async => PermissionStatus.restricted);
      when(mockDialogService.showConfirmationDialog(
        title: anyNamed('title'),
        message: anyNamed('message'),
        showCancelOnly: true,
      )).thenAnswer((_) async => false);

      final result =
          await permissionUseCase.requestPermission(Permission.camera);

      expect(result, false);
      verify(mockDialogService.showConfirmationDialog(
        title: anyNamed('title'),
        message: anyNamed('message'),
        showCancelOnly: true,
      )).called(1);
    });

    test('handles settings dialog for permanently denied', () async {
      const permission = Permission.camera;
      when(mockRepository.checkStatus(permission))
          .thenAnswer((_) async => PermissionStatus.permanentlyDenied);
      when(mockDialogService.showPermissionRationaleDialog(
        permission: permission,
        isPermanentlyDenied: true,
      )).thenAnswer((_) async => true);
      when(mockRepository.openSettings()).thenAnswer((_) async => true);
      // After settings
      when(mockRepository.checkStatus(permission))
          .thenAnswer((_) async => PermissionStatus.granted);

      final result = await permissionUseCase.requestPermission(permission);

      expect(result, isTrue);
    });

    test('should handle denied permission with user accepting dialog',
        () async {
      const permission = Permission.camera;

      // First check returns denied
      when(mockRepository.checkStatus(permission))
          .thenAnswer((_) async => PermissionStatus.denied);

      when(mockDialogService.showPermissionRationaleDialog(
        permission: permission,
      )).thenAnswer((_) async => true);

      when(mockRepository.request(permission)).thenAnswer((_) async => true);

      // Setup for the second status check after successful request
      // Need to change behavior after first check
      int checkCount = 0;
      when(mockRepository.checkStatus(permission)).thenAnswer((_) {
        if (checkCount++ == 0) {
          return Future.value(PermissionStatus.denied);
        }
        return Future.value(PermissionStatus.granted);
      });

      final result = await permissionUseCase.requestPermission(permission);

      expect(result, true);
      verify(mockDialogService.showPermissionRationaleDialog(
        permission: permission,
      )).called(1);
      verify(mockRepository.request(permission)).called(1);
      // Verify checkStatus was called twice
      verify(mockRepository.checkStatus(permission)).called(2);
    });

    test('should handle denied permission with user rejecting dialog',
        () async {
      const permission = Permission.camera;
      when(mockRepository.checkStatus(permission))
          .thenAnswer((_) async => PermissionStatus.denied);
      when(mockDialogService.showPermissionRationaleDialog(
        permission: permission,
      )).thenAnswer((_) async => false);

      final result = await permissionUseCase.requestPermission(permission);

      expect(result, false);
      verify(mockDialogService.showPermissionRationaleDialog(
        permission: permission,
      )).called(1);
      verifyNever(mockRepository.request(permission));
    });

    test('should handle error in openSettings for permanently denied',
        () async {
      const permission = Permission.camera;
      when(mockRepository.checkStatus(permission))
          .thenAnswer((_) async => PermissionStatus.permanentlyDenied);
      when(mockDialogService.showPermissionRationaleDialog(
        permission: permission,
        isPermanentlyDenied: true,
      )).thenAnswer((_) async => true);
      when(mockRepository.openSettings()).thenAnswer((_) async => false);
      when(mockDialogService.showConfirmationDialog(
        title: anyNamed('title'),
        message: anyNamed('message'),
        showCancelOnly: true,
      )).thenAnswer((_) async => null);

      final result = await permissionUseCase.requestPermission(permission);

      expect(result, false);
      verify(mockDialogService.showConfirmationDialog(
        title: anyNamed('title'),
        message: anyNamed('message'),
        showCancelOnly: true,
      )).called(1);
    });

    test('should handle exception during permission request', () async {
      const permission = Permission.camera;

      when(mockRepository.checkStatus(permission))
          .thenAnswer((_) async => PermissionStatus.denied);

      when(mockDialogService.showPermissionRationaleDialog(
        permission: permission,
      )).thenThrow(Exception('Dialog error'));

      final result = await permissionUseCase.requestPermission(permission);

      expect(result, false);
      verify(mockCrashlytics.recordError(
        argThat(isA<Exception>()),
        any,
        reason: 'Failed to request permission',
      )).called(1);
    });

    test('checkPermission should handle exceptions gracefully', () async {
      const permission = Permission.camera;

      when(mockRepository.checkStatus(permission))
          .thenThrow(Exception('Permission error'));

      final result = await permissionUseCase.checkPermission(permission);

      expect(result, PermissionStatus.denied);
      verify(mockCrashlytics.recordError(
        any,
        any,
        reason: 'Failed to check permission status',
      )).called(1);
    });

    test('should handle null dialog response for permanently denied', () async {
      const permission = Permission.camera;
      when(mockRepository.checkStatus(permission))
          .thenAnswer((_) async => PermissionStatus.permanentlyDenied);
      when(mockDialogService.showPermissionRationaleDialog(
        permission: permission,
        isPermanentlyDenied: true,
      )).thenAnswer((_) async => null);

      final result = await permissionUseCase.requestPermission(permission);

      expect(result, false);
    });
  });

  group('checkPermission', () {
    test('should return current permission status', () async {
      when(mockRepository.checkStatus(Permission.camera))
          .thenAnswer((_) async => PermissionStatus.granted);

      final result = await permissionUseCase.checkPermission(Permission.camera);

      expect(result, PermissionStatus.granted);
      verify(mockRepository.checkStatus(Permission.camera)).called(1);
    });
  });

  group('openSettings', () {
    test('should delegate to repository', () async {
      when(mockRepository.openSettings()).thenAnswer((_) async => true);

      final result = await permissionUseCase.openSettings();

      expect(result, true);
      verify(mockRepository.openSettings()).called(1);
    });
  });

  group('requestNotificationPermission', () {
    test('should initialize notifications when permission granted', () async {
      when(mockMessagingService.checkStatus())
          .thenAnswer((_) async => PermissionStatus.denied);

      when(mockDialogService.showPermissionRationaleDialog(
        permission: Permission.notification,
      )).thenAnswer((_) async => true);

      when(mockMessagingService.requestPermission())
          .thenAnswer((_) async => true);

      // Second call returns granted status
      var callCount = 0;
      when(mockMessagingService.checkStatus()).thenAnswer((_) {
        callCount++;
        return Future.value(
            callCount > 1 ? PermissionStatus.granted : PermissionStatus.denied);
      });

      await permissionUseCase.requestNotificationPermission();

      verify(mockMessagingService.initNotifications()).called(1);
      verify(mockMessagingService.checkStatus()).called(2);
    });

    test('should not initialize notifications when permission denied', () async {
      when(mockMessagingService.checkStatus())
          .thenAnswer((_) async => PermissionStatus.denied);

      when(mockDialogService.showPermissionRationaleDialog(
        permission: Permission.notification,
      )).thenAnswer((_) async => false);

      await permissionUseCase.requestNotificationPermission();

      verifyNever(mockMessagingService.initNotifications());
      verify(mockMessagingService.checkStatus()).called(1);
    });
  });

  group('notification specific permission handling', () {
    test('should use messaging service for notification permission check', () async {
      when(mockMessagingService.checkStatus())
          .thenAnswer((_) async => PermissionStatus.granted);

      final status = await permissionUseCase.checkPermission(Permission.notification);

      expect(status, PermissionStatus.granted);
      verify(mockMessagingService.checkStatus()).called(1);
      verifyNever(mockRepository.checkStatus(any));
    });

    test('should handle notification permission request error', () async {
      when(mockMessagingService.checkStatus())
          .thenThrow(Exception('Permission check failed'));

      final status = await permissionUseCase.checkPermission(Permission.notification);

      expect(status, PermissionStatus.denied);
      verify(mockCrashlytics.recordError(any, any,
          reason: 'Failed to check permission status')).called(1);
    });
  });

  group('analytics and logging', () {
    test('should log analytics event on permission success', () async {
      when(mockRepository.checkStatus(Permission.camera))
          .thenAnswer((_) async => PermissionStatus.granted);

      await permissionUseCase.requestPermission(Permission.camera);

      verify(mockLoggerUtils.logInfo('PermissionUseCase', any)).called(1);
      verify(mockAnalyticsService.logEvent(
        AnalyticsEventType.permissionSuccess,
        customParams: anyNamed('customParams'),
      )).called(1);
    });

    test('should log analytics event on permission failure', () async {
      when(mockRepository.checkStatus(Permission.camera))
          .thenAnswer((_) async => PermissionStatus.denied);

      when(mockDialogService.showPermissionRationaleDialog(
        permission: Permission.camera,
      )).thenAnswer((_) async => false);

      await permissionUseCase.requestPermission(Permission.camera);

      verify(mockLoggerUtils.logInfo('PermissionUseCase', any)).called(1);
      verify(mockAnalyticsService.logEvent(
        AnalyticsEventType.permissionFailure,
        customParams: anyNamed('customParams'),
      )).called(1);
    });
  });
}
