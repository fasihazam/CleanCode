import 'package:flutter/material.dart';
import 'package:maple_harvest_app/core/core.dart';

/// A custom [AppBar] that supports both [String] and [Widget] titles.
///
/// [title] - The title displayed in the app bar. Must be either [String] or [Widget].
class AppBarWidget extends AppBar {
  AppBarWidget({
    super.key,
    required BuildContext context,
    required dynamic title,
    super.actions,
    super.automaticallyImplyLeading,
    VoidCallback? onBackPressed,
  })  : assert(title is String || title is Widget,
            'Title must be either String or Widget'),
        super(
          title: _buildTitle(title),
          leading: automaticallyImplyLeading && Navigator.of(context).canPop()
              ? IconButton(
                  icon: Container(
                    height: kToolbarHeight * 0.65,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.transparent,
                      border: Border.all(
                        color: AppColors.backBorder,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.arrow_back_ios_new,
                      color: context.colorScheme.secondary,
                      size: kToolbarHeight * 0.25,
                    ),
                  ),
                  onPressed: onBackPressed ?? () => Navigator.pop(context),
                )
              : null,
        );

  static _buildTitle(title) {
    if (title == null) {
      return const SizedBox.shrink();
    }

    if (title is String) {
      return TextWidget(title);
    } else if (title is Widget) {
      return title;
    } else {
      return const SizedBox.shrink();
    }
  }
}
