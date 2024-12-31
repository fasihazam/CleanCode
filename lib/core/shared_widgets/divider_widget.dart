import 'package:flutter/material.dart';
import 'package:maple_harvest_app/core/core.dart';

class DividerWidget extends StatelessWidget {
  final double? height;

  final double? width;

  final Color? color;

  final EdgeInsets? margin;

  const DividerWidget({
    super.key,
    this.height,
    this.width,
    this.color,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: Dimens.defaultAnimDurationMillis),
      height: height ?? Dimens.dividerHeight,
      width: width,
      margin: margin,
      decoration: BoxDecoration(
        color: color ?? context.colorScheme.primary,
        borderRadius: BorderRadius.circular(Dimens.dividerRadius),
      ),
    );
  }
}
