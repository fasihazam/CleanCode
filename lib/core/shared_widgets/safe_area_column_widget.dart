import 'package:flutter/material.dart';
import 'package:maple_harvest_app/core/core.dart';

class SafeAreaColumnWidget extends StatelessWidget {
  final List<Widget> children;

  final CrossAxisAlignment crossAxisAlignment;

  final MainAxisAlignment mainAxisAlignment;

  final MainAxisSize mainAxisSize;

  final EdgeInsets? padding;

  SafeAreaColumnWidget({
    super.key,
    required this.children,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisAlignment = MainAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.max,
    this.padding,
  }): assert(children.isNotEmpty, 'Empty children list is not allowed');

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: padding ??
            EdgeInsets.symmetric(
              horizontal: Dimens.pageHorizontalPadding,
            ),
        child: Column(
          crossAxisAlignment: crossAxisAlignment,
          mainAxisAlignment: mainAxisAlignment,
          mainAxisSize: mainAxisSize,
          children: children,
        ),
      ),
    );
  }
}
