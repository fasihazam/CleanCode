import 'package:dartz/dartz.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maple_harvest_app/core/core.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'exception_mixin_test.mocks.dart';

class TestClass with ExceptionMixin {}

@GenerateMocks([ConnectivityUtils, LoggerUtils, CrashlyticsService])
void main() {
  late TestClass testClass;
  late MockConnectivityUtils mockConnectivity;
  late MockLoggerUtils mockLogger;
  late MockCrashlyticsService mockCrashlyticsService;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  setUp(() {
    mockConnectivity = MockConnectivityUtils();
    mockLogger = MockLoggerUtils();
    mockCrashlyticsService = MockCrashlyticsService();

    sl.registerSingleton<ConnectivityUtils>(mockConnectivity);
    sl.registerSingleton<LoggerUtils>(mockLogger);
    sl.registerSingleton<CrashlyticsService>(mockCrashlyticsService);

    testClass = TestClass();
  });

  tearDown(() {
    sl.unregister<ConnectivityUtils>();
    sl.unregister<LoggerUtils>();
    sl.unregister<CrashlyticsService>();
  });

  group('handleFuture', () {
    test('should return Right when operation succeeds', () async {
      when(mockConnectivity.hasInternet).thenAnswer((_) async => true);

      final result = await testClass.handleFuture(() async => 'success');

      expect(result, equals(const Right<CustomException, String>('success')));
      verify(mockConnectivity.hasInternet).called(1);
    });

    test('should return Left with NetworkException when no internet', () async {
      when(mockConnectivity.hasInternet).thenAnswer((_) async => false);

      final result = await testClass.handleFuture(() async => 'success');

      expect(
        result.isLeft(),
        true,
      );
      verify(mockConnectivity.hasInternet).called(1);
    });

    test('should handle GraphQLException', () async {
      when(mockConnectivity.hasInternet).thenAnswer((_) async => true);

      final graphqlException = GraphQLException(
        message: 'GraphQL error',
        type: GraphQLErrorType.generalError,
      );

      final result = await testClass.handleFuture(
        () async => throw graphqlException,
      );

      expect(
        result,
        equals(Left<CustomException, String>(graphqlException)),
      );
    });

    group('should handle different GraphQL error types', () {
      test('should handle InvalidCredentialsError', () async {
        when(mockConnectivity.hasInternet).thenAnswer((_) async => true);

        final graphqlException = GraphQLException(
          message: 'Invalid credentials',
          type: GraphQLErrorType.invalidCredentialsError,
        );

        final result = await testClass.handleFuture(
          () async => throw graphqlException,
        );

        expect(
          result,
          equals(Left<CustomException, String>(graphqlException)),
        );
      });

      test('should handle NotVerifiedError', () async {
        when(mockConnectivity.hasInternet).thenAnswer((_) async => true);

        final graphqlException = GraphQLException(
          message: 'Not verified',
          type: GraphQLErrorType.notVerifiedError,
        );

        final result = await testClass.handleFuture(
          () async => throw graphqlException,
        );

        expect(
          result,
          equals(Left<CustomException, String>(graphqlException)),
        );
      });

      test('should handle NativeAuthStrategyError', () async {
        when(mockConnectivity.hasInternet).thenAnswer((_) async => true);

        final graphqlException = GraphQLException(
          message: 'Auth strategy error',
          type: GraphQLErrorType.nativeAuthStrategyError,
        );

        final result = await testClass.handleFuture(
          () async => throw graphqlException,
        );

        expect(
          result,
          equals(Left<CustomException, String>(graphqlException)),
        );
      });

      test('should handle unknown GraphQL error type', () async {
        when(mockConnectivity.hasInternet).thenAnswer((_) async => true);

        final graphqlException = GraphQLException(
          message: 'Unknown error',
          type: GraphQLErrorType.unknown,
        );

        final result = await testClass.handleFuture(
          () async => throw graphqlException,
        );

        expect(
          result,
          equals(Left<CustomException, String>(graphqlException)),
        );
      });
    });

    test('should handle GeneralException', () async {
      when(mockConnectivity.hasInternet).thenAnswer((_) async => true);

      final generalException = GeneralException(message: 'General error');
      final result = await testClass.handleFuture(
        () async => throw generalException,
      );

      expect(
        result,
        equals(Left<CustomException, String>(generalException)),
      );
    });

    test('should handle FirebaseException', () async {
      when(mockConnectivity.hasInternet).thenAnswer((_) async => true);

      final firebaseException = FirebaseException(
        plugin: 'test',
        code: 'test-code',
        message: 'Firebase error',
      );
      final result = await testClass.handleFuture(
        () async => throw firebaseException,
      );

      expect(
        result.isLeft(),
        true,
      );
    });

    test('should handle FirebaseException with null message', () async {
      when(mockConnectivity.hasInternet).thenAnswer((_) async => true);

      final firebaseException = FirebaseException(
        plugin: 'test',
        code: 'test-code',
      );
      final result = await testClass.handleFuture(
        () async => throw firebaseException,
      );

      expect(
        result.isLeft(),
        true,
      );
    });

    test('should handle unknown exceptions', () async {
      when(mockConnectivity.hasInternet).thenAnswer((_) async => true);

      final unknownException = Exception('Unknown error');
      final result = await testClass.handleFuture(
        () async => throw unknownException,
      );

      expect(
        result.isLeft(),
        true,
      );
    });

    test('should log stack trace for exceptions', () async {
      when(mockConnectivity.hasInternet).thenAnswer((_) async => true);

      final result = await testClass.handleFuture(() async {
        throw Exception('Test error');
      });

      expect(result.isLeft(), true);
    });

    test('should handle different return types', () async {
      when(mockConnectivity.hasInternet).thenAnswer((_) async => true);

      // Test with int
      final intResult = await testClass.handleFuture(() async => 42);
      expect(intResult, equals(const Right<CustomException, int>(42)));

      // Test with Map
      final mapResult = await testClass.handleFuture(
        () async => {'key': 'value'},
      );
      expect(
        mapResult.isRight(),
        true,
      );

      // Test with List
      final listResult = await testClass.handleFuture(
        () async => [1, 2, 3],
      );
      expect(
        listResult.isRight(),
        true,
      );
    });
  });
}
