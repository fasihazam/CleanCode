import 'package:flutter/material.dart';
import 'package:maple_harvest_app/core/core.dart';
import 'package:tap_debouncer/tap_debouncer.dart';

class ElevatedButtonWidget extends StatelessWidget {
  final String title;

  final Future<void> Function()? onPressed;

  final Color? backgroundColor;

  final Color? iconColor;

  final Color? textColor;

  final double? width;

  final double? height;

  final EdgeInsets? margin;

  final double? borderRadius;

  final IconData? prefixIcon;

  final bool isOutlined;

  const ElevatedButtonWidget({
    super.key,
    required this.title,
    this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.textColor,
    this.width,
    this.height,
    this.margin,
    this.borderRadius,
    this.prefixIcon,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final buttonStyle = context.theme.elevatedButtonTheme.style?.copyWith(
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return AppColors.disabled;
        }
        return backgroundColor;
      }),
      textStyle: WidgetStatePropertyAll(
        context.textTheme.titleMedium?.copyWith(
          color: textColor ?? context.colorScheme.onPrimary,
        ),
      ),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(borderRadius ?? Dimens.buttonBorderRadius),
        ),
      ),
    );

    return Container(
      width: width,
      height: height ?? Dimens.buttonHeight,
      margin: margin,
      child: FractionallySizedBox(
        widthFactor: width != null ? null : 0.90,
        child: _buildDebouncedButton(buttonStyle),
      ),
    );
  }

  Widget _buildDebouncedButton(ButtonStyle? buttonStyle) {
    return TapDebouncer(
      onTap: () async => await onPressed?.call(),
      builder: (BuildContext context, TapDebouncerFunc? onTap) => isOutlined
          ? OutlinedButton(
              onPressed: onTap,
              style: buttonStyle,
              child: _buildButtonChild(context),
            )
          : ElevatedButton(
              onPressed: onTap,
              style: buttonStyle,
              child: _buildButtonChild(context),
            ),
    );
  }

  Widget _buildButtonChild(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (prefixIcon != null) ...[
          Icon(
            prefixIcon,
            size: 20.r,
            color: iconColor ?? context.colorScheme.onPrimary,
          ),
          SpacerWidget(width: 7.w),
        ],
        TextWidget(
          title,
          style: context.textTheme.titleMedium?.copyWith(
            color: textColor ?? context.colorScheme.onPrimary,
          ),
        ),
      ],
    );
  }
}
