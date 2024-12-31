import 'dart:math';

import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maple_harvest_app/core/core.dart';

class BottomNavWidget extends StatelessWidget {
  const BottomNavWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final BottomNavItem currentItem =
        context.select((BottomNavCubit cubit) => cubit.state.currentItem);

    return AnimatedBottomNavigationBar.builder(
      shadow: Shadow(
        color: context.colorScheme.secondary.withOpacity(0.25),
        blurRadius: 20.r,
      ),
      height: max(kBottomNavigationBarHeight, Dimens.navBarHeight),
      itemCount: BottomNavItem.values.length,
      tabBuilder: (int index, bool isActive) =>
          _buildNavItem(context, BottomNavItem.values[index], isActive),
      scaleFactor: 0.5,
      activeIndex: currentItem.index,
      splashSpeedInMilliseconds: 0,
      onTap: (index) => context
          .read<BottomNavCubit>()
          .updateItem(BottomNavItem.values[index]),
      gapLocation: GapLocation.center,
      notchSmoothness: NotchSmoothness.softEdge,
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    BottomNavItem item,
    bool isActive,
  ) {
    return Padding(
      padding: EdgeInsets.only(top: 3.h),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AssetImageWidget(
              path: item.iconPath,
              color: isActive
                  ? context.colorScheme.primary
                  : context.colorScheme.secondary,
              height: 24.h,
              width: 24.w,
            ),
            TextWidget(
              item.label,
              style: context.textTheme.labelSmall?.copyWith(
                color: isActive
                    ? context.colorScheme.primary
                    : context.colorScheme.secondary,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
