import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:maple_harvest_app/core/config/config.dart';

extension ContextExtension on BuildContext {
  ThemeData get theme => Theme.of(this);

  TextTheme get textTheme => theme.textTheme;

  ColorScheme get colorScheme => theme.colorScheme;

  MediaQueryData get mediaQuery => MediaQuery.of(this);

  Size get size => mediaQuery.size;

  double get width => size.width;

  double get height => size.height;

  void goToHome([Map<String, dynamic>? map]) =>
      GoRouter.of(this).goNamed(AppRoutes.home, extra: map);

  void goToOnboarding() => GoRouter.of(this).goNamed(AppRoutes.onboarding);

  void goToLogin() => GoRouter.of(this).goNamed(AppRoutes.login);

  void goToLocationScreen(bool extra) =>
      GoRouter.of(this).goNamed(AppRoutes.location, extra: extra);

  void goToLocateMeScreen() => GoRouter.of(this).goNamed(AppRoutes.locateme);

  void goToAIBot() {
    //TODO: implement it when the AI Bot is ready
    return;
  }

  void goToNotifications() =>
      GoRouter.of(this).goNamed(AppRoutes.notifications);
}
