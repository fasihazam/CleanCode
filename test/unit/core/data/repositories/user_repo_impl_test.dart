import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maple_harvest_app/core/core.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'user_repo_impl_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<UserDatasource>(),
  MockSpec<CustomerResponse>(),
  MockSpec<LoggerUtils>(),
  MockSpec<ConnectivityUtils>(),
  MockSpec<CrashlyticsService>(),
])
void main() {
  late UserRepoImpl userRepo;
  late MockUserDatasource mockUserDatasource;
  late MockLoggerUtils mockLoggerUtils;
  late MockConnectivityUtils mockConnectivityUtils;
  late MockCrashlyticsService mockCrashlyticsService;

  CustomerResponse customerResponse = const CustomerResponse(
      id: '1',
      firstName: 'John',
      lastName: 'Doe',
      emailAddress: 'johndoe@testing.com');

  setUp(() {
    mockConnectivityUtils = MockConnectivityUtils();
    mockLoggerUtils = MockLoggerUtils();
    mockUserDatasource = MockUserDatasource();
    mockCrashlyticsService = MockCrashlyticsService();

    sl.registerLazySingleton<LoggerUtils>(() => mockLoggerUtils);
    sl.registerLazySingleton<ConnectivityUtils>(() => mockConnectivityUtils);
    sl.registerLazySingleton<CrashlyticsService>(() => mockCrashlyticsService);

    userRepo = UserRepoImpl(mockUserDatasource);

    when(mockConnectivityUtils.hasInternet)
        .thenAnswer((_) => Future.value(true));
  });

  tearDown(() {
    sl.reset();
  });

  group('getUser', () {
    test('should return Right(CustomerResponse) when datasource call succeeds',
        () async {
      when(mockUserDatasource.getUser())
          .thenAnswer((_) async => customerResponse);

      final result = await userRepo.getUser();

      expect(result.isRight(), true);
      verify(mockUserDatasource.getUser()).called(1);
    });

    test('should return Left(NetworkException) when network error occurs',
        () async {
      final exception = NetworkException(message: 'No internet connection');
      when(mockUserDatasource.getUser()).thenThrow(exception);

      final result = await userRepo.getUser();

      expect(result, Left(exception));
      verify(mockUserDatasource.getUser()).called(1);
    });

    test('should return Left(GeneralException) for unknown errors', () async {
      final exception = Exception('Unknown error');
      when(mockUserDatasource.getUser()).thenThrow(exception);

      final result = await userRepo.getUser();

      expect(result.isLeft(), true);
      verify(mockUserDatasource.getUser()).called(1);
    });
  });
}
