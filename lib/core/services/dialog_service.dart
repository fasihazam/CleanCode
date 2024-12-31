import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:maple_harvest_app/core/core.dart';
import 'package:permission_handler/permission_handler.dart';

class DialogService {
  final CrashlyticsService _crashlytics;

  final LoggerUtils _logger;

  final GlobalKey<NavigatorState> _navigatorKey;

  static const _tag = 'DialogService';

  DialogService({
    required CrashlyticsService crashlyticsService,
    required LoggerUtils loggerUtils,
    required GlobalKey<NavigatorState> navigatorKey,
  })  : _crashlytics = crashlyticsService,
        _logger = loggerUtils,
        _navigatorKey = navigatorKey;

  Completer<void>? _dialogCompleter;

  static const _defaultTransitionDuration = Duration(milliseconds: 350);

  /// Shows a custom dialog with the given [builder] function.
  Future<T?> showCustomDialog<T>({
    required BuildContext context,
    required Widget Function(BuildContext context) builder,
    bool dismissible = true,
    bool wrapWithAlertDialog = false,
    bool showExitButton = true,
    Widget Function(BuildContext context)? actionWidget,
    Duration? transitionDuration,
    Color? barrierColor,
  }) async {
    if (_dialogCompleter != null && !_dialogCompleter!.isCompleted) return null;
    _dialogCompleter = Completer<void>();

    if (!context.mounted) {
      _logger.logInfo(_tag, 'Context is not mounted');
      return null;
    }

    try {
      return await showGeneralDialog<T>(
        context: context,
        transitionDuration: transitionDuration ?? _defaultTransitionDuration,
        barrierColor: barrierColor ?? AppColors.secondary.withOpacity(0.4),
        barrierDismissible: dismissible,
        barrierLabel:
            MaterialLocalizations.of(context).modalBarrierDismissLabel,
        pageBuilder: (dialogContext, animation, secondaryAnimation) {
          return PopScope(
            canPop: dismissible,
            child: ScaleTransition(
              scale: CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              ),
              child: _buildDialogContent(
                dialogContext: dialogContext,
                builder: builder,
                wrapWithAlertDialog: wrapWithAlertDialog,
                showExitButton: showExitButton,
                actionWidget: actionWidget,
              ),
            ),
          );
        },
      );
    } catch (e, stackTrace) {
      _logger.logError(_tag, 'Failed to show dialog\n$e');
      await _crashlytics.recordError(
        e,
        stackTrace,
        reason: 'Failed to show dialog',
      );
      return null;
    } finally {
      _dialogCompleter?.complete();
      _dialogCompleter = null;
    }
  }

  Widget _buildDialogContent({
    required BuildContext dialogContext,
    required Widget Function(BuildContext) builder,
    required bool wrapWithAlertDialog,
    required bool showExitButton,
    Widget Function(BuildContext)? actionWidget,
  }) {
    if (!wrapWithAlertDialog) return builder(dialogContext);

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimens.cardRadius),
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: Dimens.dialogHorizontalPadding,
        vertical: Dimens.dialogVerticalPadding,
      ),
      content: SizedBox(
        width: dialogContext.width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showExitButton) _buildExitButton(dialogContext),
            builder(dialogContext),
            actionWidget?.call(dialogContext) ?? const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  Widget _buildExitButton(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: InkWell(
        onTap: () => Navigator.of(context).pop(),
        borderRadius: BorderRadius.circular(30.adaptSize),
        child: CircleAvatar(
          radius: 15.adaptSize,
          backgroundColor: context.colorScheme.primary,
          child: Icon(
            Icons.close,
            color: context.theme.colorScheme.onPrimary,
            size: 18.adaptSize,
          ),
        ),
      ),
    );
  }

  /// Shows a confirmation dialog with the given [title] and [message].
  ///
  /// Returns `true` if the user confirms, `false` if the user cancels, and `null` if the dialog is dismissed.
  ///
  /// If [showCancelOnly] is `true`, the dialog will only show a cancel button.
  Future<bool?> showConfirmationDialog({
    BuildContext? context,
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
    bool dismissible = false,
    bool isDestructive = false,
    bool showCancelOnly = false,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    List<Widget> actions = const [],
  }) async {
    try {
      context ??= _navigatorKey.currentContext;
      if (context == null || !context.mounted) {
        _logger.logError(_tag, 'No valid context found');
        return null;
      }

      return await showCustomDialog<bool>(
        context: context,
        dismissible: dismissible,
        builder: (context) => CupertinoAlertDialog(
          title: TextWidget(
            title,
            style: context.textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          content: TextWidget(
            message,
            style: context.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          actions: actions.isNotEmpty
              ? actions
              : [
                  _buildDialogAction(
                    context: context,
                    onPressed: () {
                      if (!context.mounted) return;
                      Navigator.of(context).pop(false);
                      onCancel?.call();
                    },
                    isDefault: true,
                    title: cancelText ?? 'cancel'.tr(),
                  ),
                  _buildDialogAction(
                    context: context,
                    onPressed: () {
                      if (!context.mounted) return;
                      Navigator.of(context).pop(true);
                      onConfirm?.call();
                    },
                    title: confirmText ?? 'confirm'.tr(),
                  )
                ],
        ),
      );
    } catch (e, stackTrace) {
      _logger.logError(_tag, 'Failed to show confirmation dialog\n$e');
      await _crashlytics.recordError(
        e,
        stackTrace,
        reason: 'Failed to show confirmation dialog',
      );
      return null;
    }
  }

  /// Shows a delete confirmation dialog with the given [title].
  Future<bool?> showDeleteConfirmation({
    required BuildContext context,
    required String title,
    String? message,
    String? confirmText,
    String? cancelText,
  }) async =>
      await showConfirmationDialog(
        context: context,
        title: title,
        message: message ?? 'deleteConfirmMsg'.tr(),
        confirmText: confirmText ?? 'delete'.tr(),
        cancelText: cancelText ?? 'cancel'.tr(),
        isDestructive: true,
      );

  /// Shows a success dialog with the given [title] and [message].
  Future<void> showSuccessDialog({
    required BuildContext context,
    required String title,
    required String message,
    VoidCallback? onDismiss,
  }) async {
    return await showCustomDialog(
      context: context,
      builder: (_) => InfoAlertWidget(
        title: title,
        message: message,
        alertType: AlertType.success,
        onDismiss: onDismiss,
        buttonTitle: 'continue'.tr(),
      ),
    );
  }

  /// Shows an error dialog with the given [title] and [message].
  Future<bool?> showPermissionRationaleDialog({
    required Permission permission,
    String? message,
    bool isPermanentlyDenied = false,
  }) async {
    _logger.logInfo(_tag, 'Showing permission rationale dialog: $permission');

    final context = _navigatorKey.currentContext;
    if (context == null || !context.mounted) {
      _logger.logError(_tag, 'No valid context found');
      return null;
    }

    final permissionMessage = message ?? _getPermissionMessage(permission);

    return await showConfirmationDialog(
      context: context,
      title: isPermanentlyDenied
          ? 'permissionRequired'.tr()
          : 'permissionNeeded'.tr(),
      message: permissionMessage,
      dismissible: false,
      actions: _buildPermissionActions(context, isPermanentlyDenied),
    );
  }

  List<Widget> _buildPermissionActions(
    BuildContext context,
    bool isPermanentlyDenied,
  ) {
    return [
      _buildDialogAction(
        context: context,
        title: 'notNow'.tr(),
        isDefault: true,
        onPressed: () {
          if (!context.mounted) return;
          Navigator.of(context).pop(false);
        },
      ),
      isPermanentlyDenied
          ? _buildDialogAction(
              context: context,
              title: 'openSettings'.tr(),
              onPressed: () async {
                if (!context.mounted) return;
                Navigator.of(context).pop(true);
              },
            )
          : _buildDialogAction(
              context: context,
              title: 'continue'.tr(),
              onPressed: () {
                if (!context.mounted) return;
                Navigator.of(context).pop(true);
              },
            ),
    ];
  }

  CupertinoDialogAction _buildDialogAction({
    required BuildContext context,
    required String title,
    required VoidCallback onPressed,
    bool isDefault = false,
  }) =>
      CupertinoDialogAction(
        onPressed: onPressed,
        isDefaultAction: isDefault,
        child: TextWidget(
          title,
          style: context.textTheme.bodyMedium,
        ),
      );

  String _getPermissionMessage(Permission permission) {
    switch (permission) {
      case Permission.camera:
      case Permission.photos:
        return 'photosPermissionMsg'.tr();
      case Permission.location:
        return 'locationPermissionMsg'.tr();
      case Permission.notification:
        return 'notificationPermissionMsg'.tr();
      default:
        return 'permissionMessage'.tr();
    }
  }
}
