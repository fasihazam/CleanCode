import 'package:flutter_test/flutter_test.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:maple_harvest_app/core/core.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateNiceMocks([
  MockSpec<GraphQLService>(),
  MockSpec<LoggerUtils>(),
])
import 'user_datasource_test.mocks.dart';

void main() {
  late UserDatasourceImpl userDatasource;
  late MockGraphQLService mockGraphQLService;
  late MockLoggerUtils mockLogger;

  setUp(() {
    mockGraphQLService = MockGraphQLService();
    mockLogger = MockLoggerUtils();
    userDatasource = UserDatasourceImpl(
      graphQLService: mockGraphQLService,
      loggerUtils: mockLogger,
    );
  });

  group('UserDatasourceImpl', () {
    const mockQueryResult = {
      'activeCustomer': {
        'id': '123',
        'firstName': 'John',
        'lastName': 'Doe',
        'emailAddress': 'john@example.com',
      }
    };

    test('getUser returns CustomerResponse when successful', () async {
      final query = CustomerOperations.getActiveCustomer();
      when(mockGraphQLService.query(query))
          .thenAnswer((_) async => QueryResult(
        data: mockQueryResult,
        options: QueryOptions(document: gql(query)),
        source: QueryResultSource.network,
      ));

      final result = await userDatasource.getUser();

      expect(result, isA<CustomerResponse>());
      expect(result.id, '123');
      expect(result.firstName, 'John');
      expect(result.lastName, 'Doe');
      expect(result.emailAddress, 'john@example.com');
      verify(mockGraphQLService.query(query)).called(1);
      verifyNever(mockLogger.logError(any, any));
    });

    test('getUser throws and logs error when GraphQL service fails', () async {
      final query = CustomerOperations.getActiveCustomer();
      final exception = Exception('GraphQL error');
      when(mockGraphQLService.query(query)).thenThrow(exception);

      expect(
            () => userDatasource.getUser(),
        throwsA(equals(exception)),
      );
    });

    test('getUser throws when GraphQL service fails', () async {
      final query = CustomerOperations.getActiveCustomer();
      final exception = Exception('GraphQL error');
      when(mockGraphQLService.query(query)).thenThrow(exception);

      expect(
            () => userDatasource.getUser(),
        throwsA(equals(exception)),
      );
    });
  });
}