import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:maple_harvest_app/core/core.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'user_cubit_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<UserRepository>(),
  MockSpec<CrashlyticsService>(),
  MockSpec<AnalyticsService>(),
  MockSpec<PrefsUtils>()
])
void main() {
  late UserCubit userCubit;
  late MockUserRepository mockUserRepository;
  late MockCrashlyticsService mockCrashlyticsService;
  late MockAnalyticsService mockAnalyticsService;
  late MockPrefsUtils mockPrefsUtils;

  setUp(() async {
    mockUserRepository = MockUserRepository();
    mockCrashlyticsService = MockCrashlyticsService();
    mockAnalyticsService = MockAnalyticsService();
    mockPrefsUtils = MockPrefsUtils();

    await initializeEasyLocalization();

    userCubit = UserCubit(
      userRepository: mockUserRepository,
      crashlyticsService: mockCrashlyticsService,
      analyticsService: mockAnalyticsService,
      prefsUtils: mockPrefsUtils,
    );
  });

  tearDown(() async {
    await userCubit.close();
  });

  group('UserCubit', () {
    const mockUser = CustomerResponse(
      id: 'test-id',
      emailAddress: 'test@example.com',
    );

    test('initial state is correct', () {
      expect(userCubit.state, const UserState.initial());
    });

    group('fetchUser', () {
      setUp(() {
        when(mockAnalyticsService.setUserInfo(any)).thenAnswer((_) async {});
        when(mockAnalyticsService.logEvent(
          any,
          customParams: anyNamed('customParams'),
        )).thenAnswer((_) async {});
        when(mockCrashlyticsService.setUserIdentifier(any))
            .thenAnswer((_) async {});
        when(mockPrefsUtils.hasAnonymousCreds).thenAnswer((_) async => false);
      });

      blocTest<UserCubit, UserState>(
        'emits nothing when already loading',
        build: () => userCubit,
        seed: () => const UserState(status: RequestStatus.loading),
        act: (cubit) => cubit.fetchUser(),
        expect: () => [],
      );

      blocTest<UserCubit, UserState>(
        'emits correct states when user fetch is successful',
        build: () {
          when(mockUserRepository.getUser())
              .thenAnswer((_) async => const Right(mockUser));
          return userCubit;
        },
        act: (cubit) => cubit.fetchUser(),
        expect: () => [
          isA<UserState>()
              .having((s) => s.status, 'status', RequestStatus.loading)
              .having((s) => s.user, 'user', null)
              .having((s) => s.exception, 'exception', null),
          isA<UserState>()
              .having((s) => s.status, 'status', RequestStatus.success)
              .having((s) => s.user?.id, 'user.id', mockUser.id)
              .having((s) => s.user?.isAnonymous, 'user.isAnonymous', false)
              .having((s) => s.exception, 'exception', null),
          isA<UserState>()
              .having((s) => s.status, 'status', RequestStatus.initial)
              .having((s) => s.user?.id, 'user.id', mockUser.id)
              .having((s) => s.exception, 'exception', null),
        ],
        verify: (_) {
          verifyInOrder([
            mockAnalyticsService.logEvent(AnalyticsEventType.fetchUser),
            mockPrefsUtils.hasAnonymousCreds,
            mockAnalyticsService.setUserInfo(any),
            mockCrashlyticsService.setUserIdentifier(mockUser.id),
            mockAnalyticsService.logEvent(AnalyticsEventType.fetchUserSuccess),
          ]);
        },
      );

      blocTest<UserCubit, UserState>(
        'handles UserNotFoundException correctly',
        build: () {
          final exception = UserNotFoundException(message: 'User not found');
          when(mockUserRepository.getUser())
              .thenAnswer((_) async => Left(exception));
          when(mockPrefsUtils.clearAnonymousCreds()).thenAnswer((_) async => true);
          when(mockPrefsUtils.setAuthToken(any)).thenAnswer((_) async => true);
          return userCubit;
        },
        act: (cubit) => cubit.fetchUser(),
        expect: () => [
          isA<UserState>()
              .having((s) => s.status, 'status', RequestStatus.loading),
          isA<UserState>()
              .having((s) => s.status, 'status', RequestStatus.error)
              .having((s) => s.exception, 'exception', isA<UserNotFoundException>()),
          isA<UserState>()
              .having((s) => s.status, 'status', RequestStatus.initial),
        ],
        verify: (_) {
          verify(mockPrefsUtils.clearAnonymousCreds()).called(1);
          verify(mockPrefsUtils.setAuthToken(null)).called(1);
        },
      );

      blocTest<UserCubit, UserState>(
        'handles unexpected errors during fetch',
        build: () {
          when(mockUserRepository.getUser())
              .thenThrow(Exception('Unexpected error'));
          when(mockCrashlyticsService.recordError(any, any))
              .thenAnswer((_) async {});
          return userCubit;
        },
        act: (cubit) => cubit.fetchUser(),
        expect: () => [
          isA<UserState>()
              .having((s) => s.status, 'status', RequestStatus.loading),
          isA<UserState>()
              .having((s) => s.status, 'status', RequestStatus.initial),
        ],
        verify: (_) {
          verify(mockCrashlyticsService.recordError(any, any)).called(1);
        },
      );
    });

    group('logout', () {
      setUp(() {
        when(mockAnalyticsService.logEvent(any)).thenAnswer((_) async {});
        when(mockAnalyticsService.removeUserInfo()).thenAnswer((_) async {});
        when(mockCrashlyticsService.setUserIdentifier(any))
            .thenAnswer((_) async {});
      });

      blocTest<UserCubit, UserState>(
        'emits nothing when already loading',
        build: () => userCubit,
        seed: () => const UserState(status: RequestStatus.loading),
        act: (cubit) => cubit.logout(),
        expect: () => [],
      );

      blocTest<UserCubit, UserState>(
        'emits correct states when logout is successful',
        build: () {
          when(mockUserRepository.logout())
              .thenAnswer((_) async => const Right(true));
          return userCubit;
        },
        seed: () => const UserState(user: mockUser),
        act: (cubit) => cubit.logout(),
        expect: () => [
          isA<UserState>()
              .having((s) => s.status, 'status', RequestStatus.loading)
              .having((s) => s.user, 'user', mockUser),
          const UserState.initial(),
        ],
        verify: (_) {
          verifyInOrder([
            mockAnalyticsService.logEvent(AnalyticsEventType.logout),
            mockAnalyticsService.removeUserInfo(),
            mockCrashlyticsService.setUserIdentifier(null),
          ]);
        },
      );

      blocTest<UserCubit, UserState>(
        'emits correct states when logout fails',
        build: () {
          when(mockUserRepository.logout()).thenAnswer(
                (_) async => Left(GeneralException(message: 'Logout failed')),
          );
          return userCubit;
        },
        seed: () => const UserState(user: mockUser),
        act: (cubit) => cubit.logout(),
        expect: () => [
          isA<UserState>()
              .having((s) => s.status, 'status', RequestStatus.loading),
          isA<UserState>()
              .having((s) => s.status, 'status', RequestStatus.error)
              .having((s) => s.exception?.message, 'exception message', 'unableToLogout'),
          isA<UserState>()
              .having((s) => s.status, 'status', RequestStatus.initial),
        ],
      );
    });

    group('updateCustomer', () {
      test('updates customer information correctly', () {
        const updatedUser = CustomerResponse(
          id: 'test-id',
          emailAddress: 'updated@example.com',
          isAnonymous: true,
        );

        userCubit.updateCustomer(updatedUser);

        expect(
          userCubit.state,
          isA<UserState>()
              .having((s) => s.user, 'user', updatedUser)
              .having((s) => s.status, 'status', RequestStatus.initial)
              .having((s) => s.exception, 'exception', null),
        );
      });

      test('throws StateError when closed', () async {
        await userCubit.close();

        expect(
              () => userCubit.updateCustomer(mockUser),
          throwsA(isA<StateError>()),
        );
      });
    });
  });
}

Future<void> initializeEasyLocalization() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  await EasyLocalization.ensureInitialized();
}