import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:maple_harvest_app/core/core.dart';


class LoadingWidget extends StatelessWidget {
  final Widget child;

  final bool isLoading;

  const LoadingWidget({
    super.key,
    required this.isLoading,
    required this.child,
  });

  static Widget loaderChild(BuildContext context,
          {required double size, Color? color}) =>
      SizedBox(
        width: size,
        height: size,
        child: LoadingIndicator(
          indicatorType: Indicator.ballRotateChase,
          colors: [color ?? context.colorScheme.onPrimary],
        ),
      );

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      FocusManager.instance.primaryFocus?.unfocus();
    }

    return Stack(
      children: [
        Positioned.fill(child: child),
        if (isLoading) ...[
          ModalBarrier(
            color: context.colorScheme.secondary.withOpacity(0.5),
            dismissible: false,
          ),
          Center(
            child: loaderChild(context, size: 40.adaptSize),
          ),
        ],
      ],
    );
  }
}
