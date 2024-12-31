import 'package:flutter_test/flutter_test.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:maple_harvest_app/core/core.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'vendure_graphql_client_test.mocks.dart';

@GenerateMocks([HeaderManager, PrefsUtils, LoggerUtils])
void main() {
  late MockPrefsUtils mockPrefsUtils;
  late MockLoggerUtils mockLogger;
  late MockHeaderManager mockHeaderManager;
  late VendureGraphQLClient vendureClient;

  setUp(() {
    mockPrefsUtils = MockPrefsUtils();
    mockLogger = MockLoggerUtils();
    mockHeaderManager = MockHeaderManager();
    vendureClient = VendureGraphQLClient(
      prefsUtils: mockPrefsUtils,
      logger: mockLogger,
      headerManager: mockHeaderManager,
    );
  });

  group('VendureGraphQLClient Initialization', () {
    test('init() should initialize client successfully', () async {
      when(mockPrefsUtils.authToken).thenAnswer((_) => Future.value(''));

      await vendureClient.init();

      verify(mockLogger.log('VendureGraphQLClient', 'Successfully initialized'))
          .called(1);
      expect(vendureClient.client, isNotNull);
    });

    test(
        'init() should handle loadCachedToken errors and continue initialization',
        () async {
      final testException = Exception('Test error');
      when(mockPrefsUtils.authToken).thenThrow(testException);

      await vendureClient.init();

      verify(mockLogger.log('VendureGraphQLClient', 'Successfully initialized'))
          .called(1);
      expect(vendureClient.client, isNotNull);
    });
  });

  group('Token Management', () {
    group('loadCachedToken', () {
      test('should load and update existing token', () async {
        const testToken = 'cached-test-token';
        when(mockPrefsUtils.authToken).thenAnswer((_) => Future.value(testToken));

        await vendureClient.loadCachedToken();

        verify(mockPrefsUtils.authToken).called(1);
      });

      test('should not update token when cached token is empty', () async {
        when(mockPrefsUtils.authToken).thenAnswer((_) => Future.value(''));

        await vendureClient.loadCachedToken();

        verify(mockPrefsUtils.authToken).called(1);
        verifyNever(mockPrefsUtils.setAuthToken(any));
      });

      test('should handle and log errors', () async {
        final testException = Exception('Test error');
        when(mockPrefsUtils.authToken).thenThrow(testException);

        await vendureClient.loadCachedToken();

        verify(mockLogger.logError(
          'VendureGraphQLClient',
          contains('Error loading cached token'),
        )).called(1);
      });
    });

    group('clearToken', () {
      test('should clear token and preferences', () async {
        when(mockPrefsUtils.setAuthToken(null))
            .thenAnswer((_) => Future.value(true));

        await vendureClient.clearToken();

        verify(mockPrefsUtils.setAuthToken(null)).called(1);
        verify(mockLogger.log(
          'VendureGraphQLClient',
          'Clearing token',
        )).called(1);
      });

      test('should handle errors during token clearing', () async {
        when(mockPrefsUtils.setAuthToken(null))
            .thenThrow(Exception('Test error'));

        await expectLater(
          vendureClient.clearToken,
          throwsA(isA<Exception>()),
        );
      });
    });
  });

  group('Header Management', () {
    test('updateHeaders() should successfully update headers', () {
      final testHeaders = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Custom-Header': 'test-value'
      };

      vendureClient.updateHeaders(testHeaders);

      verify(mockHeaderManager.updateHeaders(testHeaders)).called(1);
    });

    test('updateHeaders() should handle empty headers map', () {
      final emptyHeaders = <String, String>{};

      vendureClient.updateHeaders(emptyHeaders);

      verify(mockHeaderManager.updateHeaders(emptyHeaders)).called(1);
    });

    test('updateHeaders() should handle HeaderManager throwing exception', () {
      final testHeaders = {'test': 'value'};
      final testException = Exception('Header update failed');
      when(mockHeaderManager.updateHeaders(any)).thenThrow(testException);

      expect(() => vendureClient.updateHeaders(testHeaders),
          throwsA(equals(testException)));
    });

    test('client should be initialized with default headers', () async {
      when(mockPrefsUtils.authToken).thenAnswer((_) => Future.value(''));

      await vendureClient.init();

      expect(vendureClient.client, isNotNull);
      expect(vendureClient.client.link, isA<Link>());

      final httpLink = vendureClient.client.link;
      expect(httpLink.toString(), contains('LoggedLink'));

      verifyNever(mockHeaderManager.updateHeaders(any));
    });

    test('client should handle header updates after initialization', () async {
      when(mockPrefsUtils.authToken).thenAnswer((_) => Future.value(''));
      await vendureClient.init();

      final testHeaders = {'Custom-Header': 'test-value'};
      vendureClient.updateHeaders(testHeaders);

      verify(mockHeaderManager.updateHeaders(testHeaders)).called(1);
      verify(mockLogger.log(
        'VendureGraphQLClient',
        'Successfully initialized',
      )).called(1);
    });

    test('client should use LoggedLink in the link chain', () async {
      when(mockPrefsUtils.authToken).thenAnswer((_) => Future.value(''));

      await vendureClient.init();

      expect(vendureClient.client, isNotNull);
      final linkChain = vendureClient.client.link.toString();
      expect(linkChain, contains('LoggedLink'));
    });
  });
}
