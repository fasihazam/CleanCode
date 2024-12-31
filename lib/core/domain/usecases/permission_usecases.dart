import 'package:easy_localization/easy_localization.dart';
import 'package:maple_harvest_app/core/core.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionUseCases {
  final PermissionRepository _permissionRepository;
  final DialogService _dialogService;
  final CrashlyticsService _crashlytics;
  final AnalyticsService _analytics;
  final LoggerUtils _logger;
  final MessagingService _messaging;

  PermissionUseCases({
    required PermissionRepository permissionRepository,
    required DialogService dialogService,
    required CrashlyticsService crashlyticsService,
    required AnalyticsService analyticsService,
    required LoggerUtils loggerUtils,
    required MessagingService messagingService,
  })  : _permissionRepository = permissionRepository,
        _dialogService = dialogService,
        _crashlytics = crashlyticsService,
        _analytics = analyticsService,
        _logger = loggerUtils,
        _messaging = messagingService;

  Future<bool> requestPermission(Permission permission) async {
    final status = await checkPermission(permission);

    try {
      bool hasGranted = await _handlePermissionStatus(status, permission);

      final msg =
          '$permission is ${hasGranted ? 'granted' : 'denied'} by the user';
      _logger.logInfo('PermissionUseCase', msg);
      await _analytics.logEvent(
        hasGranted
            ? AnalyticsEventType.permissionSuccess
            : AnalyticsEventType.permissionFailure,
        customParams: {AnalyticsParamsModel.errorInfoKey: msg},
      );
      return hasGranted;
    } catch (e, stack) {
      await _crashlytics.recordError(e, stack,
          reason: 'Failed to request permission');
      await _analytics.logEvent(
        AnalyticsEventType.permissionFailure,
        customParams: {
          AnalyticsParamsModel.errorInfoKey: e.toString(),
        },
      );
      return false;
    }
  }

  Future<bool> _handlePermanentlyDenied(Permission permission) async {
    final shouldOpenSettings =
        await _dialogService.showPermissionRationaleDialog(
              permission: permission,
              isPermanentlyDenied: true,
            ) ??
            false;

    if (shouldOpenSettings) {
      final hasOpenedSettings = await _permissionRepository.openSettings();
      if (!hasOpenedSettings) {
        await _showSettingsError();
        return false;
      }
    }
    return false;
  }

  Future<bool> _handleDenied(Permission permission) async {
    final shouldRequest = await _dialogService.showPermissionRationaleDialog(
          permission: permission,
        ) ??
        false;

    if (!shouldRequest) return false;
    bool granted = false;
    if (permission == Permission.notification) {
      granted = await _messaging.requestPermission();
    } else {
      granted = await _permissionRepository.request(permission);
    }
    if (!granted) return false;

    return await _validatePermissionStatus(permission);
  }

  Future<bool> _validatePermissionStatus(Permission permission) async {
    final status = await checkPermission(permission);
    return _isValidPermissionStatus(status, permission);
  }

  Future<PermissionStatus> checkPermission(Permission permission) async {
    try {
      if (permission == Permission.notification) {
        return await _messaging.checkStatus();
      }
      return await _permissionRepository.checkStatus(permission);
    } catch (e, stackTrace) {
      await _crashlytics.recordError(e, stackTrace,
          reason: 'Failed to check permission status');
      return PermissionStatus.denied;
    }
  }

  Future<bool> openSettings() async =>
      await _permissionRepository.openSettings();

  Future<void> _showSettingsError() async =>
      await _dialogService.showConfirmationDialog(
        title: 'oops'.tr(),
        message: 'settingsErrorMsg'.tr(),
        showCancelOnly: true,
      );

  bool _isValidPermissionStatus(
          PermissionStatus status, Permission permission) =>
      status == PermissionStatus.granted ||
      (status == PermissionStatus.limited && permission == Permission.photos) ||
      (status == PermissionStatus.provisional &&
          permission == Permission.notification);

  /// Handles the permission request flow based on the current [PermissionStatus]
  /// Returns true if the permission is granted or valid for the requested type
  Future<bool> _handlePermissionStatus(
      PermissionStatus status, Permission permission) async {
    bool hasGranted = false;
    switch (status) {
      case PermissionStatus.granted:
      case PermissionStatus.provisional:
        hasGranted = true;
        break;
      case PermissionStatus.limited:
        final isValid = _isValidPermissionStatus(status, permission);
        if (!isValid) {
          // Show dialog explaining why we need full access
          final shouldRequest =
              await _dialogService.showPermissionRationaleDialog(
                    permission: permission,
                    message: 'permissionMessage'.tr(),
                  ) ??
                  false;
          if (shouldRequest) {
            hasGranted = await _handleDenied(permission);
          }
        } else {
          hasGranted = true;
        }
        break;
      case PermissionStatus.restricted:
        hasGranted = (await _dialogService.showConfirmationDialog(
              title: 'accessRestricted'.tr(),
              message: 'accessRestrictedMsg'.tr(),
              showCancelOnly: true,
            )) ??
            false;
        break;
      case PermissionStatus.permanentlyDenied:
        hasGranted = await _handlePermanentlyDenied(permission);
        break;
      case PermissionStatus.denied:
        hasGranted = await _handleDenied(permission);
        break;
    }
    return hasGranted;
  }

  Future<void> requestNotificationPermission() async {
    final granted = await requestPermission(Permission.notification);
    if (!granted) return;

    await _messaging.initNotifications();
  }
}
