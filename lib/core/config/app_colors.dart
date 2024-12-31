import 'package:flutter/material.dart';

class AppColors {

  static const MaterialColor primarySwatch = MaterialColor(
    0xFFFF0101,
    <int, Color>{
      50: Color(0xFFFFE5E5),
      100: Color(0xFFFFB8B8),
      200: Color(0xFFFF8A8A),
      300: Color(0xFFFF5C5C),
      400: Color(0xFFFF3636),
      500: primary,
      600: Color(0xFFFF0000),
      700: Color(0xFFEA0000),
      800: Color(0xFFD50000),
      900: Color(0xFFBF0000),
    },
  );

  static const primary = Color(0xFFFF0101);

  static const secondary = Color(0xFF263238);

  static const onPrimary = Color(0xFFFFFFFF);

  static const onPrimaryContainer = Color(0xFFF5F5F5);

  static const onPrimaryDarkContainer = Color(0xFF263238);

  static const primaryText = Color(0xFF000000);

  static const inputBorder = Color(0x30000000);

  static const inputBorderDark = Color(0x30000000);

  static const error = Colors.red;

  static const onError = onPrimary;

  static const disabled = Color(0xFFBDBDBD);

  static const onboardingSubHeading = Color(0xA3000000);

  static const alertMsg = Color(0xFF7C7E93);

  static const backBorder = Color(0x31000000);

  AppColors._();
}
