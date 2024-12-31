import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:graphql_flutter/graphql_flutter.dart' hide HttpLink;
import 'package:gql_http_link/gql_http_link.dart' show HttpLink;
import 'package:maple_harvest_app/core/core.dart';

import 'header_link_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<HeaderManager>(as: #MockHeaderManager),
  MockSpec<LoggerUtils>(as: #MockLoggerUtils),
  MockSpec<PrefsUtils>(as: #MockPrefsUtils),
  MockSpec<HttpLink>(as: #MockHttpLink),
  MockSpec<GraphQLLogger>(as: #MockGraphQLLogger),
])
void main() {
  late HeaderLink headerLink;
  late MockHeaderManager mockHeaderManager;
  late MockLoggerUtils mockLogger;
  late MockPrefsUtils mockPrefsUtils;
  late GraphQLLogger mockGraphQLLogger;
  late MockHttpLink mockHttpLink;

  setUp(() {
    mockHeaderManager = MockHeaderManager();
    mockLogger = MockLoggerUtils();
    mockPrefsUtils = MockPrefsUtils();
    mockGraphQLLogger = MockGraphQLLogger();
    mockHttpLink = MockHttpLink();

    headerLink = HeaderLink(
      mockHeaderManager,
      mockLogger,
      mockPrefsUtils,
      mockGraphQLLogger,
    );
  });

  test('merges headers and logs them', () async {
    when(mockHeaderManager.headers).thenReturn({'manager': 'value'});

    final request = Request(
      operation: Operation(document: gql('')),
      context: const Context().withEntry(const HttpLinkHeaders(headers: {'existing': 'header'})),
    );

    when(mockHttpLink.request(any)).thenAnswer((_) => Stream.value(const Response(data: {}, response: {})));

    await headerLink.request(request, mockHttpLink.request).first;

    verify(mockLogger.logInfo('HeaderLink', 'Merged headers: {existing: header, manager: value}')).called(1);
  });

  test('updates auth token from response headers', () async {
    when(mockHeaderManager.headers).thenReturn({});

    final request = Request(operation: Operation(document: gql('')));
    final response = Response(
      data: const {},
      context: const Context().withEntry(const HttpLinkResponseContext(headers: {'vendure-auth-token': 'new-token'}, statusCode: 200)),
      response: const {},
    );

    when(mockHttpLink.request(any)).thenAnswer((_) => Stream.value(response));

    await headerLink.request(request, mockHttpLink.request).first;

    verify(mockPrefsUtils.setAuthToken('new-token')).called(1);
  });

  test('does not update auth token if missing from response', () async {
    when(mockHeaderManager.headers).thenReturn({});

    final request = Request(operation: Operation(document: gql('')));
    const response = Response(data: {}, context: Context(), response: {});

    when(mockHttpLink.request(any)).thenAnswer((_) => Stream.value(response));

    await headerLink.request(request, mockHttpLink.request).first;

    verifyNever(mockPrefsUtils.setAuthToken(any));
  });

  test('rethrows errors', () async {
    final exception = GeneralException(message: 'Test error');
    when(mockHeaderManager.headers).thenThrow(exception);

    final request = Request(operation: Operation(document: gql('')));

    expect(
      headerLink.request(request, mockHttpLink.request),
      emitsError(exception),
    );
  });
}