import 'package:flutter_test/flutter_test.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:maple_harvest_app/core/core.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'header_cleanup_link_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<HeaderManager>(),
  MockSpec<Request>(),
  MockSpec<Context>(),
  MockSpec<HttpLinkResponseContext>(),
])

/// Returns a default test response stream
class MockNextLink extends Mock {
  Stream<Response> call(Request request) => super.noSuchMethod(
    Invocation.method(#call, [request]),
    returnValue: Stream.fromIterable([
      const Response(data: {'test': 'data'}, response: {}),
    ]),
  ) as Stream<Response>;
}

void main() {
  late MockHeaderManager mockHeaderManager;
  late HeaderCleanupLink headerCleanupLink;
  late MockRequest mockRequest;
  late MockContext mockContext;
  late MockHttpLinkResponseContext mockHttpContext;

  setUp(() {
    mockHeaderManager = MockHeaderManager();
    headerCleanupLink = HeaderCleanupLink(mockHeaderManager);
    mockRequest = MockRequest();
    mockContext = MockContext();
    mockHttpContext = MockHttpLinkResponseContext();

    // Setup the context chain
    when(mockRequest.context).thenReturn(mockContext);
    when(mockContext.entry<HttpLinkResponseContext>())
        .thenReturn(mockHttpContext);
  });

  Stream<Response> setupSuccessfulForwardLink(Request request) {
    return Stream.fromIterable([
      const Response(data: {'test': 'data'}, response: {}),
    ]);
  }

  group('HeaderCleanupLink', () {
    test('should process request and cleanup headers on success', () async {
      final mockForward = MockNextLink();
      when(mockForward.call(mockRequest))
          .thenAnswer((_) => setupSuccessfulForwardLink(mockRequest));

      final responses = await headerCleanupLink
          .request(mockRequest, mockForward.call)
          .toList();

      expect(responses, hasLength(1));
      expect(responses.first.data, equals({'test': 'data'}));

      verify(mockForward.call(mockRequest)).called(1);
      verify(mockHeaderManager.resetHeaders()).called(1);
    });

    test('should cleanup headers when request throws synchronous error', () async {
      final mockForward = MockNextLink();
      when(mockForward.call(mockRequest))
          .thenThrow(Exception('Sync error'));

      await expectLater(
        headerCleanupLink.request(mockRequest, mockForward.call).toList(),
        throwsA(isA<Exception>()),
      );

      verify(mockHeaderManager.resetHeaders()).called(1);
    });

    test('should maintain request integrity while cleaning headers', () async {
      final mockForward = MockNextLink();
      final testHeaders = {'Authorization': 'Bearer token123'};

      when(mockHttpContext.headers).thenReturn(testHeaders);
      when(mockForward.call(mockRequest))
          .thenAnswer((_) => setupSuccessfulForwardLink(mockRequest));

      final responses = await headerCleanupLink
          .request(mockRequest, mockForward.call)
          .toList();

      expect(responses, hasLength(1));
      verify(mockForward.call(mockRequest)).called(1);
      verify(mockHeaderManager.resetHeaders()).called(1);
    });
  });
}