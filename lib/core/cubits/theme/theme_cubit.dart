import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:maple_harvest_app/core/core.dart';

part 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  final PrefsUtils prefs;

  ThemeCubit({
    required this.prefs,
  }) : super(const ThemeState.initial());

  Future<void> toggleTheme() async {
    try {
      await prefs.setDarkMode(state.themeMode == ThemeMode.light);
      emit(ThemeState(
        themeMode: state.themeMode == ThemeMode.light
            ? ThemeMode.dark
            : ThemeMode.light,
      ));
    } on CustomException catch (e) {
      emit(ThemeState(
        themeMode: state.themeMode,
        exception: e,
      ));
    } catch (e) {
      emit(ThemeState(
        themeMode: state.themeMode,
        exception: GeneralException(
          message: 'operationFailedMsg'.tr(),
        ),
      ));
    }
  }
}
