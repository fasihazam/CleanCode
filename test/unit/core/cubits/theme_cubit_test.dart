import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:maple_harvest_app/core/core.dart';

import 'theme_cubit_test.mocks.dart';

@GenerateNiceMocks([MockSpec<PrefsUtils>()])
void main() {
  group('ThemeCubit', () {
    late ThemeCubit themeCubit;
    late MockPrefsUtils mockPrefsUtils;

    setUp(() {
      mockPrefsUtils = MockPrefsUtils();
      themeCubit = ThemeCubit(prefs: mockPrefsUtils);
    });

    tearDown(() {
      themeCubit.close();
    });

    test('initial state is light theme with no exception', () {
      expect(themeCubit.state.themeMode, equals(ThemeMode.light));
      expect(themeCubit.state.exception, isNull);
    });

    blocTest<ThemeCubit, ThemeState>(
      'toggleTheme changes from light to dark successfully',
      build: () {
        when(mockPrefsUtils.setDarkMode(true)).thenAnswer((_) async {});
        return themeCubit;
      },
      act: (cubit) => cubit.toggleTheme(),
      expect: () => [
        isA<ThemeState>()
            .having((state) => state.themeMode, 'themeMode', ThemeMode.dark)
            .having((state) => state.exception, 'exception', isNull),
      ],
      verify: (_) {
        verify(mockPrefsUtils.setDarkMode(true)).called(1);
      },
    );

    blocTest<ThemeCubit, ThemeState>(
      'toggleTheme changes from dark to light successfully',
      build: () {
        when(mockPrefsUtils.setDarkMode(false)).thenAnswer((_) async {});
        return ThemeCubit(prefs: mockPrefsUtils)
          ..emit(const ThemeState(themeMode: ThemeMode.dark));
      },
      act: (cubit) => cubit.toggleTheme(),
      expect: () => [
        isA<ThemeState>()
            .having((state) => state.themeMode, 'themeMode', ThemeMode.light)
            .having((state) => state.exception, 'exception', isNull),
      ],
      verify: (_) {
        verify(mockPrefsUtils.setDarkMode(false)).called(1);
      },
    );

    blocTest<ThemeCubit, ThemeState>(
      'toggleTheme preserves state when handling CustomException',
      build: () {
        final exception = GeneralException(message: 'Custom error');
        when(mockPrefsUtils.setDarkMode(any)).thenThrow(exception);
        return themeCubit;
      },
      act: (cubit) => cubit.toggleTheme(),
      expect: () => [
        isA<ThemeState>()
            .having((state) => state.themeMode, 'themeMode', ThemeMode.light)
            .having(
              (state) => state.exception?.message,
          'exception message',
          'Custom error',
        ),
      ],
    );

    blocTest<ThemeCubit, ThemeState>(
      'toggleTheme converts general exceptions to GeneralException',
      build: () {
        when(mockPrefsUtils.setDarkMode(any))
            .thenThrow(Exception('Unknown error'));
        return themeCubit;
      },
      act: (cubit) => cubit.toggleTheme(),
      expect: () => [
        isA<ThemeState>()
            .having((state) => state.themeMode, 'themeMode', ThemeMode.light)
            .having(
              (state) => state.exception?.message,
          'exception message',
          'operationFailedMsg',
        ),
      ],
    );

    blocTest<ThemeCubit, ThemeState>(
      'toggleTheme maintains dark theme on error',
      build: () {
        when(mockPrefsUtils.setDarkMode(any))
            .thenThrow(Exception('Storage error'));
        return ThemeCubit(prefs: mockPrefsUtils)
          ..emit(const ThemeState(themeMode: ThemeMode.dark));
      },
      act: (cubit) => cubit.toggleTheme(),
      expect: () => [
        isA<ThemeState>()
            .having((state) => state.themeMode, 'themeMode', ThemeMode.dark)
            .having(
              (state) => state.exception?.message,
          'exception message',
          'operationFailedMsg',
        ),
      ],
    );

    group('ThemeState', () {
      test('copyWith only themeMode', () {
        const initialState = ThemeState(themeMode: ThemeMode.light);
        final newState = initialState.copyWith(themeMode: ThemeMode.dark);

        expect(newState.themeMode, ThemeMode.dark);
        expect(newState.exception, isNull);
      });

      test('copyWith only exception', () {
        const initialState = ThemeState(themeMode: ThemeMode.light);
        final exception = GeneralException(message: 'test');
        final newState = initialState.copyWith(exception: exception);

        expect(newState.themeMode, ThemeMode.light);
        expect(newState.exception?.message, 'test');
      });

      test('copyWith both properties', () {
        const initialState = ThemeState(themeMode: ThemeMode.light);
        final exception = GeneralException(message: 'test');
        final newState = initialState.copyWith(
          themeMode: ThemeMode.dark,
          exception: exception,
        );

        expect(newState.themeMode, ThemeMode.dark);
        expect(newState.exception?.message, 'test');
      });

      test('initial constructor sets correct values', () {
        const state = ThemeState.initial();
        expect(state.themeMode, ThemeMode.light);
        expect(state.exception, isNull);
      });

      test('props contains all properties', () {
        final exception = GeneralException(message: 'test');
        final state = ThemeState(
          themeMode: ThemeMode.dark,
          exception: exception,
        );

        expect(state.props, containsAll([ThemeMode.dark, exception]));
      });
    });
  });
}