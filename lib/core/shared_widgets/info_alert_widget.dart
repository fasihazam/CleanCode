import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:maple_harvest_app/core/core.dart';

class InfoAlertWidget extends StatelessWidget {
  final String title;
  final String? message;
  final AlertType alertType;
  final VoidCallback? onDismiss;
  final String? buttonTitle;

  const InfoAlertWidget({
    super.key,
    required this.title,
    this.message,
    this.alertType = AlertType.success,
    this.onDismiss,
    this.buttonTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Spacer(),
        _AlertContent(
          title: title,
          message: message,
          alertType: alertType,
          onDismiss: onDismiss,
          buttonTitle: buttonTitle,
        ),
        const Spacer(),
        if (onDismiss != null) _buildDismissButton(context),
      ],
    );
  }

  Widget _buildDismissButton(BuildContext context) {
    return ElevatedButtonWidget(
      margin: EdgeInsets.only(bottom: 30.h),
      title: buttonTitle ?? 'continue'.tr(),
      onPressed: () async => onDismiss?.call(),
    );
  }
}

class _AlertContent extends HookWidget {
  final String title;
  final String? message;
  final AlertType alertType;
  final VoidCallback? onDismiss;
  final String? buttonTitle;

  const _AlertContent({
    required this.title,
    this.message,
    this.alertType = AlertType.success,
    this.onDismiss,
    this.buttonTitle,
  });

  @override
  Widget build(BuildContext context) {
    final controller = useAnimationController(
      duration: const Duration(milliseconds: 900),
    );

    final scaleAnimation = useAnimation(
      TweenSequence<double>([
        TweenSequenceItem(
          tween: Tween<double>(begin: 0.0, end: 1.2)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 30.0,
        ),
        TweenSequenceItem(
          tween: Tween<double>(begin: 1.2, end: 1.0)
              .chain(CurveTween(curve: Curves.bounceOut)),
          weight: 70.0,
        ),
      ]).animate(controller),
    );

    final bounceAnimation = useAnimation(
      TweenSequence<double>([
        TweenSequenceItem(
          tween: Tween<double>(begin: 1.0, end: 1.05)
              .chain(CurveTween(curve: Curves.easeInOut)),
          weight: 50.0,
        ),
        TweenSequenceItem(
          tween: Tween<double>(begin: 1.05, end: 1.0)
              .chain(CurveTween(curve: Curves.easeInOut)),
          weight: 50.0,
        ),
      ]).animate(
        CurvedAnimation(
          parent: controller,
          curve: const Interval(0.5, 1.0, curve: Curves.linear),
        ),
      ),
    );

    // Start animation
    useEffect(() {
      controller.forward();
      return null;
    }, []);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildHeader(
          context,
          scaleAnimation * bounceAnimation,
        ),
        SpacerWidget(height: 40.h),
        TextWidget(
          title,
          textAlign: TextAlign.center,
          style: context.textTheme.titleLarge,
        ),
        if (message != null)
          Padding(
            padding: EdgeInsets.only(top: 20.h),
            child: TextWidget(
              message!,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                color: AppColors.alertMsg,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, double scale) => Stack(
        children: [
          AssetImageWidget(
            height: context.height * 0.3,
            path: Assets.imagesInfoAlert,
          ),
          Positioned.fill(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Transform.scale(
                  scale: scale,
                  child: CircleAvatar(
                    radius: 140.r,
                    backgroundColor: context.colorScheme.primary,
                    child: Icon(
                      alertType.icon,
                      size: 80.adaptSize,
                      color: context.colorScheme.onPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
}
