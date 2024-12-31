import 'package:flutter_test/flutter_test.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:maple_harvest_app/core/core.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'graphql_service_test.mocks.dart';

@GenerateMocks([
  VendureGraphQLClient,
  GraphQLClient,
])
void main() {
  late GraphQLService service;
  late MockVendureGraphQLClient mockVendureClient;
  late MockGraphQLClient mockGraphQLClient;

  setUp(() {
    mockVendureClient = MockVendureGraphQLClient();
    mockGraphQLClient = MockGraphQLClient();

    when(mockVendureClient.client).thenReturn(mockGraphQLClient);

    service = GraphQLService(mockVendureClient);
  });

  group('clearAuthToken', () {
    test('should clear token when clearToken is called', () async {
      when(mockVendureClient.clearToken()).thenAnswer((_) async => Future.value(true));

      await service.clearAuthToken();

      verify(mockVendureClient.clearToken()).called(1);
    });

    test('should rethrow original exception from clearToken', () async {
      final exception = Exception('Some error');
      when(mockVendureClient.clearToken()).thenThrow(exception);

      expect(
            () => service.clearAuthToken(),
        throwsA(equals(exception)),
      );
    });
  });

  group('query', () {
    const testDocument = '''
      query TestQuery {
        test {
          field
        }
      }
    ''';

    test('should execute successful query', () async {
      final expectedData = {
        'test': {'field': 'value'}
      };

      when(mockGraphQLClient.query(any)).thenAnswer(
        (_) async => QueryResult(
          data: expectedData,
          options: QueryOptions(document: gql(testDocument)),
          source: QueryResultSource.network,
        ),
      );

      final result = await service.query(testDocument);

      expect(result.data, equals(expectedData));
      verify(mockGraphQLClient.query(any)).called(1);
    });

    test('should throw GraphQLException on graphql error', () async {
      when(mockGraphQLClient.query(any)).thenAnswer(
        (_) async => QueryResult(
          options: QueryOptions(document: gql(testDocument)),
          source: QueryResultSource.network,
          exception: OperationException(
            graphqlErrors: [
              const GraphQLError(
                message: 'Test error',
                extensions: {'code': 'UNAUTHORIZED'},
              ),
            ],
          ),
        ),
      );

      expect(
        () => service.query(testDocument),
        throwsA(isA<GraphQLException>()
            .having((e) => e.message, 'message', 'Test error')),
      );
    });

    test('should throw GraphQLException on null data', () async {
      when(mockGraphQLClient.query(any)).thenAnswer(
        (_) async => QueryResult(
          options: QueryOptions(document: gql(testDocument)),
          source: QueryResultSource.network,
        ),
      );

      expect(
        () => service.query(testDocument),
        throwsA(
          isA<GraphQLException>()
              .having((e) => e.message, 'message', 'operationFailedMsg')
              .having((e) => e.type, 'type', GraphQLErrorType.generalError),
        ),
      );
    });

    test('should handle variables correctly', () async {
      final variables = {'id': '123'};
      final expectedData = {
        'test': {'field': 'value'}
      };

      when(mockGraphQLClient.query(any)).thenAnswer(
        (_) async => QueryResult(
          data: expectedData,
          options: QueryOptions(document: gql(testDocument)),
          source: QueryResultSource.network,
        ),
      );

      await service.query(testDocument, variables: variables);

      verify(
        mockGraphQLClient.query(
          argThat(
            predicate<QueryOptions>((options) =>
                options.variables['id'] == '123' &&
                options.errorPolicy == ErrorPolicy.all),
          ),
        ),
      ).called(1);
    });

    test('should throw on error response type', () async {
      final errorResponse = {
        '__typename': 'Mutation',
        'login': {
          '__typename': 'InvalidCredentialsError',
          'errorCode': 'INVALID_CREDENTIALS_ERROR',
          'message': 'The provided credentials are invalid authenticationError',
        },
      };

      when(mockGraphQLClient.query(any)).thenAnswer(
        (_) async => Future.value(QueryResult(
          data: errorResponse,
          options: QueryOptions(document: gql(testDocument)),
          source: QueryResultSource.network,
        )),
      );

      expect(
        () => service.query(testDocument),
        throwsA(
          isA<GraphQLException>()
              .having((e) => e.message, 'message',
                  'The provided credentials are invalid authenticationError')
              .having((e) => e.type, 'type',
                  GraphQLErrorType.invalidCredentialsError),
        ),
      );
    });

    test('should handle operation timeout', () async {
      when(mockGraphQLClient.query(any)).thenAnswer(
            (_) async => Future.delayed(
          const Duration(seconds: 5),
              () => QueryResult(
            options: QueryOptions(document: gql(testDocument)),
            source: QueryResultSource.network,
          ),
        ),
      );

      expect(
            () => service.query(
          testDocument,
          variables: {'timeout': const Duration(seconds: 1)},
        ),
        throwsA(isA<GraphQLException>()),
      );
    });
  });

  group('mutate', () {
    const testDocument = '''
      mutation TestMutation {
        test {
          field
        }
      }
    ''';

    test('should execute successful mutation', () async {
      final expectedData = {
        'test': {'field': 'value'}
      };

      when(mockGraphQLClient.mutate(any)).thenAnswer(
        (_) async => QueryResult(
          data: expectedData,
          options: MutationOptions(document: gql(testDocument)),
          source: QueryResultSource.network,
        ),
      );

      final result = await service.mutate(testDocument);

      expect(result.data, equals(expectedData));
      verify(mockGraphQLClient.mutate(any)).called(1);
    });

    test('should throw GraphQLException on graphql error', () async {
      when(mockGraphQLClient.mutate(any)).thenAnswer(
        (_) async => QueryResult(
          options: QueryOptions(document: gql(testDocument)),
          source: QueryResultSource.network,
          exception: OperationException(
            graphqlErrors: [
              const GraphQLError(
                message: 'Test error',
                extensions: {'code': 'BAD_INPUT'},
              ),
            ],
          ),
        ),
      );

      expect(
        () => service.mutate(testDocument),
        throwsA(
          isA<GraphQLException>()
              .having((e) => e.message, 'message', 'Test error')
              .having((e) => e.type, 'type', GraphQLErrorType.unknown),
        ),
      );
    });

    test('should use correct error policy', () async {
      final expectedData = {
        'test': {'field': 'value'}
      };

      when(mockGraphQLClient.mutate(any)).thenAnswer(
        (_) async => QueryResult(
          data: expectedData,
          options: QueryOptions(document: gql(testDocument)),
          source: QueryResultSource.network,
        ),
      );

      await service.mutate(testDocument);

      verify(
        mockGraphQLClient.mutate(
          argThat(
            predicate<MutationOptions>(
                (options) => options.errorPolicy == ErrorPolicy.none),
          ),
        ),
      ).called(1);
    });

    test('should handle variables correctly', () async {
      final variables = {'id': '123'};
      final expectedData = {
        'test': {'field': 'value'}
      };

      when(mockGraphQLClient.mutate(any)).thenAnswer(
        (_) async => QueryResult(
          data: expectedData,
          options: MutationOptions(document: gql(testDocument)),
          source: QueryResultSource.network,
        ),
      );

      await service.mutate(testDocument, variables: variables);

      verify(
        mockGraphQLClient.mutate(
          argThat(
            predicate<MutationOptions>((options) =>
                options.variables['id'] == '123' &&
                options.errorPolicy == ErrorPolicy.none),
          ),
        ),
      ).called(1);
    });

    test('should throw on error response type', () async {
      final errorResponse = {
        '__typename': 'Mutation',
        'login': {
          '__typename': 'InvalidCredentialsError',
          'errorCode': 'INVALID_CREDENTIALS_ERROR',
          'message': 'The provided credentials are invalid authenticationError',
        },
      };

      when(mockGraphQLClient.mutate(any)).thenAnswer(
        (_) async => Future.value(QueryResult(
          data: errorResponse,
          options: MutationOptions(document: gql(testDocument)),
          source: QueryResultSource.network,
        )),
      );

      expect(
        () => service.mutate(testDocument),
        throwsA(
          isA<GraphQLException>()
              .having((e) => e.message, 'message',
                  'The provided credentials are invalid authenticationError')
              .having((e) => e.type, 'type',
                  GraphQLErrorType.invalidCredentialsError),
        ),
      );
    });

    test('should handle operation timeout', () async {
      when(mockGraphQLClient.query(any)).thenAnswer(
        (_) async => Future.delayed(
          const Duration(seconds: 5),
          () => QueryResult(
            options: QueryOptions(document: gql(testDocument)),
            source: QueryResultSource.network,
          ),
        ),
      );

      expect(
        () => service.query(
          testDocument,
          variables: {'timeout': const Duration(seconds: 1)},
        ),
        throwsA(isA<GraphQLException>()),
      );
    });
  });
}
