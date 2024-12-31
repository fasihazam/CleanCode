import 'package:flutter/material.dart';
import 'package:maple_harvest_app/core/core.dart';

class BaseScaffoldWidget extends StatelessWidget {
  final Widget body;

  final AppBar? appBar;

  /// The path to the image asset for the floating button.
  final String fbPath;

  /// The callback for when the floating button is pressed.
  final VoidCallback? onFBPressed;

  const BaseScaffoldWidget({
    super.key,
    required this.body,
    this.appBar,
    this.fbPath = Assets.imagesMic,
    this.onFBPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: body,
      bottomNavigationBar: const BottomNavWidget(),
      floatingActionButton: _buildFloatingButton(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildFloatingButton(BuildContext context) {
    final radius = 55.r;
    return InkWell(
      borderRadius: BorderRadius.circular(radius * 1.5),
      onTap: onFBPressed ?? context.goToAIBot,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
        elevation: 3,
        child: Padding(
          padding: EdgeInsets.all(2.r),
          child: CircleAvatar(
            radius: radius,
            backgroundColor: context.colorScheme.primary,
            child: AssetImageWidget(
              width: 35.w,
              height: 35.h,
              path: fbPath,
            ),
          ),
        ),
      ),
    );
  }
}
