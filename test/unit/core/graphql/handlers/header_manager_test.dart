import 'package:flutter_test/flutter_test.dart';
import 'package:maple_harvest_app/core/core.dart';

void main() {
  late HeaderManager headerManager;

  setUp(() {
    headerManager = HeaderManager();
  });

  group('initialization', () {
    test('should initialize with default headers', () {
      expect(headerManager.headers, equals(HeaderManager.defaultHeaders));
    });

    test('should return unmodifiable headers map', () {
      expect(
        () => headerManager.headers['New-Header'] = 'value',
        throwsUnsupportedError,
      );
    });
  });

  group('updateHeaders', () {
    test('should add new valid headers', () {
      const newHeaders = {'Authorization': 'Bearer token123'};

      headerManager.updateHeaders(newHeaders);

      expect(headerManager.headers['Authorization'], equals('Bearer token123'));
      expect(headerManager.headers.length, equals(3));
    });

    test('should preserve existing headers when adding new ones', () {
      const newHeaders = {'Authorization': 'Bearer token123'};

      headerManager.updateHeaders(newHeaders);

      expect(headerManager.headers['Content-Type'], equals('application/json'));
      expect(headerManager.headers['Accept'], equals('application/json'));
      expect(headerManager.headers['Authorization'], equals('Bearer token123'));
    });

    test('should update existing header value', () {
      const newHeaders = {'Accept': 'application/graphql'};

      headerManager.updateHeaders(newHeaders);

      expect(headerManager.headers['Accept'], equals('application/graphql'));
    });
  });

  group('resetHeaders', () {
    test('should reset to default headers', () {
      headerManager.updateHeaders({'Authorization': 'Bearer token123'});

      headerManager.resetHeaders();

      expect(headerManager.headers, equals(HeaderManager.defaultHeaders));
    });

    test('should remove all non-default headers', () {
      headerManager.updateHeaders({'Authorization': 'Bearer token123'});

      headerManager.resetHeaders();

      expect(headerManager.headers.containsKey('Authorization'), isFalse);
    });
  });

  group('validateHeaders', () {
    test('should return true for valid headers', () {
      const validHeaders = {
        'Authorization': 'Bearer token123',
        'Content-Type': 'application/json'
      };

      expect(headerManager.validateHeaders(validHeaders), isTrue);
    });

    test('should throw SecurityException for disallowed header', () {
      const invalidHeaders = {'X-Custom-Header': 'value'};

      expect(
        () => headerManager.validateHeaders(invalidHeaders),
        throwsA(isA<SecurityException>()),
      );
    });

    test('should throw SecurityException for invalid Content-Type', () {
      const invalidHeaders = {'Content-Type': 'text/plain'};

      expect(
        () => headerManager.validateHeaders(invalidHeaders),
        throwsA(isA<SecurityException>()),
      );
    });
  });

  group('sanitizeHeaderValue', () {
    group('should successfully sanitize', () {
      test('normal value', () {
        expect(
          headerManager.sanitizeHeaderValue('Bearer token123'),
          equals('Bearer token123'),
        );
      });

      test('value with extra whitespace', () {
        expect(
          headerManager.sanitizeHeaderValue('  Bearer   token123  '),
          equals('Bearer token123'),
        );
      });

      test('value with line breaks and tabs', () {
        expect(
          headerManager.sanitizeHeaderValue('Bearer\ntoken\r\t123'),
          equals('Bearertoken123'),
        );
      });

      test('value with special characters', () {
        expect(
          headerManager.sanitizeHeaderValue('Bearer~`token^123'),
          equals('Bearertoken123'),
        );
      });
    });

    group('should throw SecurityException when', () {
      test('value is null', () {
        expect(
          () => headerManager.sanitizeHeaderValue(null),
          throwsA(isA<SecurityException>()),
        );
      });

      test('value is empty', () {
        expect(
          () => headerManager.sanitizeHeaderValue(''),
          throwsA(isA<SecurityException>()),
        );
      });

      test('value is only whitespace', () {
        expect(
          () => headerManager.sanitizeHeaderValue('   '),
          throwsA(isA<SecurityException>()),
        );
      });

      test('value exceeds maximum length', () {
        final longValue = 'a' * (HeaderManager.headerValueLength + 1);
        expect(
          () => headerManager.sanitizeHeaderValue(longValue),
          throwsA(isA<SecurityException>()),
        );
      });

      test('value becomes empty after sanitization', () {
        expect(
          () => headerManager.sanitizeHeaderValue('~`^%'),
          throwsA(isA<SecurityException>()),
        );
      });
    });

    test('should remove control characters', () {
      const valueWithControlChars = 'Bearer\x00 token\x1F123';

      final result = headerManager.sanitizeHeaderValue(valueWithControlChars);

      expect(result, equals('Bearer token123'));
    });
  });

  test('should handle complete header update workflow', () {
    const newHeaders = {
      'Authorization': 'Bearer   token~123\n',
      'Accept': 'application/graphql'
    };

    headerManager.updateHeaders(newHeaders);

    expect(
      headerManager.headers['Authorization'],
      equals('Bearer token123'),
    );
    expect(
      headerManager.headers['Accept'],
      equals('application/graphql'),
    );
    expect(
      headerManager.headers['Content-Type'],
      equals('application/json'),
    );
  });

  test('should maintain state through multiple operations', () {
    headerManager.updateHeaders({'Authorization': 'Bearer token123'});

    headerManager.updateHeaders({'Accept': 'application/graphql'});

    headerManager.resetHeaders();

    headerManager.updateHeaders({'Authorization': 'Bearer newtoken'});

    expect(headerManager.headers.length, equals(3));
    expect(
      headerManager.headers['Authorization'],
      equals('Bearer newtoken'),
    );
    expect(
      headerManager.headers['Content-Type'],
      equals('application/json'),
    );
  });
}
