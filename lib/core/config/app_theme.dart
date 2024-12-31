import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maple_harvest_app/core/core.dart';

class AppTheme {
  static TextTheme get _textTheme {
    TextStyle baseTextStyle(
      double fontSize,
      FontWeight weight, {
      double? letterSpacing,
    }) =>
        GoogleFonts.poppins(
          fontSize: fontSize.fSize,
          fontWeight: weight,
          letterSpacing: letterSpacing,
        );

    return TextTheme(
      displayLarge: baseTextStyle(57, FontWeight.w300, letterSpacing: -0.5),
      displayMedium: baseTextStyle(45, FontWeight.w300, letterSpacing: -0.5),
      displaySmall: baseTextStyle(36, FontWeight.w400),
      headlineLarge: baseTextStyle(32, FontWeight.w400, letterSpacing: 0.25),
      headlineMedium: baseTextStyle(28, FontWeight.w400),
      headlineSmall: baseTextStyle(24, FontWeight.w500, letterSpacing: 0.15),
      titleLarge: baseTextStyle(20, FontWeight.w700, letterSpacing: 0.1),
      titleMedium: baseTextStyle(18, FontWeight.w500, letterSpacing: 0.1),
      titleSmall: baseTextStyle(14, FontWeight.w500, letterSpacing: 0.1),
      bodyLarge: baseTextStyle(18, FontWeight.w600, letterSpacing: 0.5),
      bodySmall: baseTextStyle(14, FontWeight.w400, letterSpacing: 0.25),
      bodyMedium: baseTextStyle(16, FontWeight.w500, letterSpacing: 0.1),
      labelLarge: baseTextStyle(15, FontWeight.w400, letterSpacing: 1),
      labelMedium: baseTextStyle(12, FontWeight.w400, letterSpacing: 0.4),
      labelSmall: baseTextStyle(11, FontWeight.w400, letterSpacing: 1.5),
    );
  }

  static ElevatedButtonThemeData get _elevatedButtonTheme =>
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: AppColors.onPrimary,
          backgroundColor: AppColors.primary,
          textStyle: _textTheme.titleMedium?.copyWith(
            color: AppColors.onPrimary,
          ),
          elevation: 1.4,
          minimumSize: Size(double.infinity, Dimens.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Dimens.buttonBorderRadius),
          ),
        ),
      );

  // text field theme config
  static InputDecorationTheme _inputDecorationTheme({required bool isDark}) =>
      InputDecorationTheme(
        hintStyle: _textTheme.labelMedium?.copyWith(
          color: isDark ? AppColors.onPrimary : AppColors.secondary,
        ),
        labelStyle: _textTheme.bodyMedium?.copyWith(
          color: isDark ? AppColors.onPrimary : AppColors.primaryText,
        ),
        floatingLabelStyle: _textTheme.bodyMedium?.copyWith(
          color: isDark ? AppColors.onPrimary : AppColors.primaryText,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Dimens.inputBorderRadius),
          borderSide: BorderSide(
            width: Dimens.inputBorderWidth,
            color: isDark ? AppColors.inputBorderDark : AppColors.inputBorder,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Dimens.inputBorderRadius),
          borderSide: BorderSide(
            width: Dimens.inputBorderWidth,
            color: isDark ? AppColors.inputBorderDark : AppColors.inputBorder,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Dimens.inputBorderRadius),
          borderSide: BorderSide(
            color: AppColors.primary,
            width: Dimens.inputBorderWidth,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: Dimens.inputHorizontalPadding,
          vertical: Dimens.inputVerticalPadding,
        ),
      );

  // card theme config
  static CardTheme _cardTheme(ThemeMode mode) => CardTheme(
        color: mode == ThemeMode.dark
            ? AppColors.onPrimaryDarkContainer
            : AppColors.onPrimaryContainer,
        surfaceTintColor: mode == ThemeMode.dark
            ? AppColors.onPrimaryDarkContainer
            : AppColors.onPrimaryContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimens.cardRadius),
        ),
      );

  static IconThemeData get _iconTheme => const IconThemeData(
        color: AppColors.primary,
      );

  static AppBarTheme _appBarTheme({required bool isDark}) => AppBarTheme(
        backgroundColor: isDark ? AppColors.secondary : AppColors.onPrimary,
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: AppColors.primary,
        ),
        titleTextStyle: _textTheme.titleMedium?.copyWith(
          color: isDark ? AppColors.onPrimary : AppColors.secondary,
        ),
      );

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: false,
        scaffoldBackgroundColor: AppColors.onPrimary,
        primaryColor: AppColors.primary,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: AppColors.primarySwatch,
          accentColor: AppColors.secondary,
          brightness: Brightness.light,
          errorColor: AppColors.error,
          cardColor: AppColors.onPrimaryContainer,
        ),
        elevatedButtonTheme: _elevatedButtonTheme,
        inputDecorationTheme: _inputDecorationTheme(isDark: false),
        textTheme: _textTheme,
        cardColor: AppColors.onPrimaryContainer,
        cardTheme: _cardTheme(ThemeMode.light),
        iconTheme: _iconTheme,
        appBarTheme: _appBarTheme(isDark: false),
      );

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: false,
        scaffoldBackgroundColor: AppColors.secondary,
        primaryColor: AppColors.primary,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: AppColors.primarySwatch,
          accentColor: AppColors.secondary,
          brightness: Brightness.light,
          errorColor: AppColors.error,
          cardColor: AppColors.onPrimaryDarkContainer,
        ),
        elevatedButtonTheme: _elevatedButtonTheme,
        inputDecorationTheme: _inputDecorationTheme(isDark: true),
        textTheme: _textTheme,
        cardColor: AppColors.onPrimaryDarkContainer,
        cardTheme: _cardTheme(ThemeMode.dark),
        iconTheme: _iconTheme,
        appBarTheme: _appBarTheme(isDark: true),
      );

  AppTheme._();
}
