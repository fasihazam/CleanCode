import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:maple_harvest_app/core/core.dart';

import 'prefs_utils_test.mocks.dart';

@GenerateMocks([
  SharedPreferences,
  LoggerUtils,
  FlutterSecureStorage,
  CrashlyticsService,
])
void main() {
  group('PrefsUtils', () {
    late MockSharedPreferences mockSharedPreferences;
    late MockLoggerUtils mockLoggerUtils;
    late MockFlutterSecureStorage mockFlutterSecureStorage;
    late MockCrashlyticsService mockCrashlyticsService;
    late PrefsUtils prefsUtils;

    setUp(() {
      mockSharedPreferences = MockSharedPreferences();
      mockLoggerUtils = MockLoggerUtils();
      mockFlutterSecureStorage = MockFlutterSecureStorage();
      mockCrashlyticsService = MockCrashlyticsService();
      prefsUtils = PrefsUtils(
        prefs: mockSharedPreferences,
        loggerUtils: mockLoggerUtils,
        storage: mockFlutterSecureStorage,
        crashlyticsService: mockCrashlyticsService,
      );
    });

    group('Dark Mode Tests', () {
      test('should return false when dark mode is not set', () {
        when(mockSharedPreferences.getBool(PrefsUtils.darkModeKey))
            .thenReturn(null);

        final result = prefsUtils.darkMode;

        expect(result, isFalse);
      });

      test('should return true when dark mode is set to true', () {
        when(mockSharedPreferences.getBool(PrefsUtils.darkModeKey))
            .thenReturn(true);

        final result = prefsUtils.darkMode;

        expect(result, isTrue);
      });

      test('should set dark mode to true when value changes', () async {
        when(mockSharedPreferences.getBool(PrefsUtils.darkModeKey))
            .thenReturn(false);
        when(mockSharedPreferences.setBool(PrefsUtils.darkModeKey, true))
            .thenAnswer((_) async => true);

        await prefsUtils.setDarkMode(true);

        verify(mockSharedPreferences.setBool(PrefsUtils.darkModeKey, true))
            .called(1);
      });

      test('should throw GeneralException when setting dark mode fails',
          () async {
        when(mockSharedPreferences.getBool(PrefsUtils.darkModeKey))
            .thenReturn(false);
        when(mockSharedPreferences.setBool(PrefsUtils.darkModeKey, true))
            .thenThrow(Exception('Failed'));
        when(mockCrashlyticsService.recordError(any, any,
                fatal: anyNamed('fatal'), reason: anyNamed('reason')))
            .thenAnswer((_) async {});

        await expectLater(
          prefsUtils.setDarkMode(true),
          throwsA(isA<GeneralException>()),
        );
      });
    });

    group('Secure Storage Tests', () {
      group('Auth Token Tests', () {
        test('should return empty string when auth token is not set', () async {
          when(mockFlutterSecureStorage.read(
            key: PrefsUtils.tokenKey,
            iOptions: PrefsUtils.iosOptions,
            aOptions: PrefsUtils.androidOptions,
          )).thenAnswer((_) async => null);

          final result = await prefsUtils.authToken;

          expect(result, isEmpty);
        });

        test('should set auth token successfully', () async {
          const token = 'test-token';
          when(mockFlutterSecureStorage.write(
            key: PrefsUtils.tokenKey,
            value: token,
            iOptions: PrefsUtils.iosOptions,
            aOptions: PrefsUtils.androidOptions,
          )).thenAnswer((_) async {});

          final result = await prefsUtils.setAuthToken(token);

          expect(result, isTrue);
        });

        test('should throw GeneralException when setting auth token fails',
            () async {
          const token = '';

          // Setup mock
          when(mockFlutterSecureStorage.write(
            key: PrefsUtils.tokenKey,
            value: token,
            iOptions: PrefsUtils.iosOptions,
            aOptions: PrefsUtils.androidOptions,
          )).thenThrow(GeneralException(message: 'Failed'));

          when(mockCrashlyticsService.recordError(any, any,
                  fatal: anyNamed('fatal'), reason: anyNamed('reason')))
              .thenAnswer((_) async {});

          // Use expectLater with throwsA for async functions
          await expectLater(
              prefsUtils.setAuthToken(token), throwsA(isA<GeneralException>()));
        });

        test('should delete token when null is provided', () async {
          when(mockFlutterSecureStorage.delete(
            key: PrefsUtils.tokenKey,
            iOptions: PrefsUtils.iosOptions,
            aOptions: PrefsUtils.androidOptions,
          )).thenAnswer((_) async {});

          final result = await prefsUtils.setAuthToken(null);

          expect(result, isTrue);
          verify(mockFlutterSecureStorage.delete(
            key: PrefsUtils.tokenKey,
            iOptions: PrefsUtils.iosOptions,
            aOptions: PrefsUtils.androidOptions,
          )).called(1);
        });
      });

      group('Email Tests', () {
        test('should get email successfully', () async {
          const email = 'test@example.com';
          when(mockFlutterSecureStorage.read(
            key: PrefsUtils.emailKey,
            iOptions: PrefsUtils.iosOptions,
            aOptions: PrefsUtils.androidOptions,
          )).thenAnswer((_) async => email);

          final result = await prefsUtils.email;

          expect(result, equals(email));
        });

        test('should set email successfully', () async {
          const email = 'test@example.com';
          when(mockFlutterSecureStorage.write(
            key: PrefsUtils.emailKey,
            value: email,
            iOptions: PrefsUtils.iosOptions,
            aOptions: PrefsUtils.androidOptions,
          )).thenAnswer((_) async {});

          final result = await prefsUtils.setEmail(email);

          expect(result, isTrue);
        });

        test('should delete email when null is provided', () async {
          when(mockFlutterSecureStorage.delete(
            key: PrefsUtils.emailKey,
            iOptions: PrefsUtils.iosOptions,
            aOptions: PrefsUtils.androidOptions,
          )).thenAnswer((_) async {});

          final result = await prefsUtils.setEmail(null);

          expect(result, isTrue);
          verify(mockFlutterSecureStorage.delete(
            key: PrefsUtils.emailKey,
            iOptions: PrefsUtils.iosOptions,
            aOptions: PrefsUtils.androidOptions,
          )).called(1);
        });
      });

      group('Password Tests', () {
        test('should get password successfully', () async {
          const password = 'test-password';
          when(mockFlutterSecureStorage.read(
            key: PrefsUtils.passwordKey,
            iOptions: PrefsUtils.iosOptions,
            aOptions: PrefsUtils.androidOptions,
          )).thenAnswer((_) async => password);

          final result = await prefsUtils.password;

          expect(result, equals(password));
        });

        test('should set password successfully', () async {
          const password = 'test-password';
          when(mockFlutterSecureStorage.write(
            key: PrefsUtils.passwordKey,
            value: password,
            iOptions: PrefsUtils.iosOptions,
            aOptions: PrefsUtils.androidOptions,
          )).thenAnswer((_) async {});

          final result = await prefsUtils.setPassword(password);

          expect(result, isTrue);
        });

        test('should delete password when null is provided', () async {
          when(mockFlutterSecureStorage.delete(
            key: PrefsUtils.passwordKey,
            iOptions: PrefsUtils.iosOptions,
            aOptions: PrefsUtils.androidOptions,
          )).thenAnswer((_) async {});

          final result = await prefsUtils.setPassword(null);

          expect(result, isTrue);
          verify(mockFlutterSecureStorage.delete(
            key: PrefsUtils.passwordKey,
            iOptions: PrefsUtils.iosOptions,
            aOptions: PrefsUtils.androidOptions,
          )).called(1);
        });

        test('should throw GeneralException when deleting password fails',
            () async {
          when(mockFlutterSecureStorage.delete(
            key: PrefsUtils.passwordKey,
            iOptions: PrefsUtils.iosOptions,
            aOptions: PrefsUtils.androidOptions,
          )).thenThrow(Exception('Failed'));
          when(mockCrashlyticsService.recordError(any, any,
                  fatal: anyNamed('fatal'), reason: anyNamed('reason')))
              .thenAnswer((_) async {});

          await expectLater(() => prefsUtils.setPassword(null),
              throwsA(isA<GeneralException>()));
        });
      });

      group('Anonymous Credentials Tests', () {
        test('should set anonymous credentials successfully', () async {
          const email = 'test@example.com';
          const password = 'test-password';
          final request =
              SignupRequest(emailAddress: email, password: password);

          when(mockFlutterSecureStorage.write(
            key: PrefsUtils.emailKey,
            value: email,
            iOptions: Platform.isIOS ? PrefsUtils.iosOptions : null,
            aOptions: Platform.isAndroid ? PrefsUtils.androidOptions : null,
          )).thenAnswer((_) async {});

          when(mockFlutterSecureStorage.write(
            key: PrefsUtils.passwordKey,
            value: password,
            iOptions: Platform.isIOS ? PrefsUtils.iosOptions : null,
            aOptions: Platform.isAndroid ? PrefsUtils.androidOptions : null,
          )).thenAnswer((_) async {});

          final result = await prefsUtils.setAnonymousCreds(request);

          expect(result, isTrue);
          verify(mockFlutterSecureStorage.write(
            key: PrefsUtils.emailKey,
            value: email,
            iOptions: Platform.isIOS ? PrefsUtils.iosOptions : null,
            aOptions: Platform.isAndroid ? PrefsUtils.androidOptions : null,
          )).called(1);
          verify(mockFlutterSecureStorage.write(
            key: PrefsUtils.passwordKey,
            value: password,
            iOptions: Platform.isIOS ? PrefsUtils.iosOptions : null,
            aOptions: Platform.isAndroid ? PrefsUtils.androidOptions : null,
          )).called(1);
        });

        test(
            'should return false when hasAnonymousCreds and no credentials exist',
            () async {
          when(mockFlutterSecureStorage.read(
            key: PrefsUtils.emailKey,
            iOptions: PrefsUtils.iosOptions,
            aOptions: PrefsUtils.androidOptions,
          )).thenAnswer((_) async => null);

          when(mockFlutterSecureStorage.read(
            key: PrefsUtils.passwordKey,
            iOptions: PrefsUtils.iosOptions,
            aOptions: PrefsUtils.androidOptions,
          )).thenAnswer((_) async => null);

          final result = await prefsUtils.hasAnonymousCreds;

          expect(result, isFalse);
        });

        test(
            'should return true when hasAnonymousCreds and both credentials exist',
            () async {
          when(mockFlutterSecureStorage.read(
            key: PrefsUtils.emailKey,
            iOptions: PrefsUtils.iosOptions,
            aOptions: PrefsUtils.androidOptions,
          )).thenAnswer((_) async => 'test@example.com');

          when(mockFlutterSecureStorage.read(
            key: PrefsUtils.passwordKey,
            iOptions: PrefsUtils.iosOptions,
            aOptions: PrefsUtils.androidOptions,
          )).thenAnswer((_) async => 'password');

          final result = await prefsUtils.hasAnonymousCreds;

          expect(result, isTrue);
        });

        test('should clear anonymous credentials successfully', () async {
          when(mockFlutterSecureStorage.delete(
            key: PrefsUtils.emailKey,
            iOptions: PrefsUtils.iosOptions,
            aOptions: PrefsUtils.androidOptions,
          )).thenAnswer((_) async {});

          when(mockFlutterSecureStorage.delete(
            key: PrefsUtils.passwordKey,
            iOptions: PrefsUtils.iosOptions,
            aOptions: PrefsUtils.androidOptions,
          )).thenAnswer((_) async {});

          final result = await prefsUtils.clearAnonymousCreds();

          expect(result, isTrue);
          verify(mockFlutterSecureStorage.delete(
            key: PrefsUtils.emailKey,
            iOptions: PrefsUtils.iosOptions,
            aOptions: PrefsUtils.androidOptions,
          )).called(1);
          verify(mockFlutterSecureStorage.delete(
            key: PrefsUtils.passwordKey,
            iOptions: PrefsUtils.iosOptions,
            aOptions: PrefsUtils.androidOptions,
          )).called(1);
        });

        test('should throw GeneralException when setting anonymous creds fails',
            () async {
          const email = 'test@example.com';
          const password = 'test-password';
          final request =
              SignupRequest(emailAddress: email, password: password);

          when(mockFlutterSecureStorage.write(
            key: PrefsUtils.emailKey,
            value: email,
            iOptions: Platform.isIOS ? PrefsUtils.iosOptions : null,
            aOptions: Platform.isAndroid ? PrefsUtils.androidOptions : null,
          )).thenThrow(Exception('Failed'));

          when(mockCrashlyticsService.recordError(any, any,
                  fatal: anyNamed('fatal'), reason: anyNamed('reason')))
              .thenAnswer((_) async {});

          await expectLater(
            () => prefsUtils.setAnonymousCreds(request),
            throwsA(isA<GeneralException>()),
          );
        });
      });
    });

    group('Onboarding Tests', () {
      test('should return false when onboarding has not been visited', () {
        when(mockSharedPreferences.getBool(PrefsUtils.onboardingKey))
            .thenReturn(null);

        final result = prefsUtils.hasVisitedOnboarding;

        expect(result, isFalse);
      });

      test('should return true when onboarding has been visited', () {
        when(mockSharedPreferences.getBool(PrefsUtils.onboardingKey))
            .thenReturn(true);

        final result = prefsUtils.hasVisitedOnboarding;

        expect(result, isTrue);
      });

      test('should set onboarding as visited successfully', () async {
        when(mockSharedPreferences.setBool(PrefsUtils.onboardingKey, true))
            .thenAnswer((_) async => true);

        await prefsUtils.setVisitedOnboarding();

        verify(mockSharedPreferences.setBool(PrefsUtils.onboardingKey, true))
            .called(1);
      });
    });


    tearDown(() {
      reset(mockSharedPreferences);
      reset(mockLoggerUtils);
      reset(mockFlutterSecureStorage);
      reset(mockCrashlyticsService);
    });
  });
}
