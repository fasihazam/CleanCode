import 'package:flutter_test/flutter_test.dart';
import 'package:maple_harvest_app/core/core.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'json_extension_test.mocks.dart';


// Test models for complex object conversion
class TestModel {
  final String name;
  final int value;

  TestModel({required this.name, required this.value});

  factory TestModel.fromMap(dynamic map) {
    return TestModel(
      name: map['name'] as String,
      value: map['value'] as int,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is TestModel &&
              runtimeType == other.runtimeType &&
              name == other.name &&
              value == other.value;

  @override
  int get hashCode => name.hashCode ^ value.hashCode;
}

// Custom class to simulate toString() throwing an exception
class ThrowingObject {
  @override
  String toString() {
    throw Exception('Simulated toString error');
  }
}

@GenerateMocks([LoggerUtils])
void main() {
  late MockLoggerUtils mockLogger;

  final referenceDate = DateTime(2024, 1, 1, 12, 0);
  final referenceDateMillis = referenceDate.millisecondsSinceEpoch;

  setUp(() {
    mockLogger = MockLoggerUtils();
    sl.registerSingleton<LoggerUtils>(mockLogger);
  });

  tearDown(() {
    sl.unregister<LoggerUtils>();
  });

  group('toJsonString', () {
    test('should convert map to JSON string', () {
      final map = {'key': 'value', 'number': 42};
      expect(map.toJsonString(), '{"key":"value","number":42}');
    });

    test('should handle nested objects', () {
      final map = {
        'nested': {'key': 'value'},
        'array': [1, 2, 3]
      };
      expect(
        map.toJsonString(),
        '{"nested":{"key":"value"},"array":[1,2,3]}',
      );
    });
  });

  group('isValidKey', () {
    test('should return true for valid string values', () {
      final map = {'key': 'value'};
      expect(map.isValidKey('key'), true);
    });

    test('should return true for valid numeric values', () {
      final map = {
        'integer': 42,
        'double': 42.5,
        'zero': 0,
      };
      expect(map.isValidKey('integer'), true);
      expect(map.isValidKey('double'), true);
      expect(map.isValidKey('zero'), true);
    });

    test('should return true for valid boolean values', () {
      final map = {
        'trueValue': true,
        'falseValue': false,
      };
      expect(map.isValidKey('trueValue'), true);
      expect(map.isValidKey('falseValue'), true);
    });

    test('should return true for valid list/map values', () {
      final map = {
        'list': [1, 2, 3],
        'map': {'nested': 'value'},
      };
      expect(map.isValidKey('list'), true);
      expect(map.isValidKey('map'), true);
    });

    test('should return false for non-existent keys', () {
      final map = {'key': 'value'};
      expect(map.isValidKey('nonexistent'), false);
    });

    test('should return false for null values', () {
      final map = {'nullKey': null};
      expect(map.isValidKey('nullKey'), false);
    });

    test('should return false for empty string values', () {
      final map = {'empty': ''};
      expect(map.isValidKey('empty'), false);
    });

    test('should handle special characters in keys', () {
      final map = {
        'special@key': 'value',
        'key with spaces': 'value',
        '123': 'value',
      };
      expect(map.isValidKey('special@key'), true);
      expect(map.isValidKey('key with spaces'), true);
      expect(map.isValidKey('123'), true);
    });

    test('should handle case sensitivity correctly', () {
      final map = {'Key': 'value'};
      expect(map.isValidKey('key'), false);
      expect(map.isValidKey('Key'), true);
    });

    test('should handle whitespace-only strings', () {
      final map = {
        'space': ' ',
        'tab': '\t',
        'newline': '\n',
        'multiple': '   ',
      };
      expect(map.isValidKey('space'), true);
      expect(map.isValidKey('tab'), true);
      expect(map.isValidKey('newline'), true);
      expect(map.isValidKey('multiple'), true);
    });

    test('should return false and log error when toString() throws', () {
      final map = {'throwingKey': ThrowingObject()};

      when(mockLogger.logError(
        'Error checking key:',
        any,
      )).thenReturn(null);

      final result = map.isValidKey('throwingKey');

      expect(result, false);

      verify(mockLogger.logError(
        'Error checking key:',
        any,
      )).called(1);
    });
  });

  group('getString', () {
    test('should return string value for string type', () {
      final map = {'key': 'value'};
      expect(map.getString('key'), 'value');
    });

    test('should convert numeric values to string', () {
      final map = {
        'integer': 42,
        'double': 42.5,
        'zero': 0,
        'negative': -1,
      };
      expect(map.getString('integer'), '42');
      expect(map.getString('double'), '42.5');
      expect(map.getString('zero'), '0');
      expect(map.getString('negative'), '-1');
    });

    test('should convert boolean values to string', () {
      final map = {
        'trueValue': true,
        'falseValue': false,
      };
      expect(map.getString('trueValue'), 'true');
      expect(map.getString('falseValue'), 'false');
    });

    test('should handle null values', () {
      final map = {'nullKey': null};
      expect(map.getString('nullKey'), '');
      expect(map.getString('nullKey', defaultValue: 'default'), 'default');
    });

    test('should handle non-existent keys', () {
      final map = {'key': 'value'};
      expect(map.getString('nonexistent'), '');
      expect(map.getString('nonexistent', defaultValue: 'default'), 'default');
    });

    test('should handle empty string values', () {
      final map = {'empty': ''};
      expect(map.getString('empty'), '');
      expect(map.getString('empty', defaultValue: 'default'), 'default');
    });

    test('should handle whitespace strings', () {
      final map = {
        'space': ' ',
        'tab': '\t',
        'newline': '\n',
        'multipleSpaces': '   ',
      };
      expect(map.getString('space'), ' ');
      expect(map.getString('tab'), '\t');
      expect(map.getString('newline'), '\n');
      expect(map.getString('multipleSpaces'), '   ');
    });

    test('should handle special characters', () {
      final map = {
        'special': '!@#\$%^&*()',
        'unicode': '⭐️🌟✨',
        'escaped': 'line1\nline2',
      };
      expect(map.getString('special'), '!@#\$%^&*()');
      expect(map.getString('unicode'), '⭐️🌟✨');
      expect(map.getString('escaped'), 'line1\nline2');
    });

    test('should handle complex objects toString representation', () {
      final map = {
        'list': [1, 2, 3],
        'map': {'nested': 'value'},
        'dateTime': DateTime(2024),
      };
      expect(map.getString('list'), '[1, 2, 3]');
      expect(map.getString('map'), '{nested: value}');
      expect(map.getString('dateTime'), DateTime(2024).toString());
    });

    test('should return default value and log error when toString() throws',
        () {
      final map = {'throwingKey': ThrowingObject()};

      when(mockLogger.logError(
        'Error checking key:',
        any,
      )).thenReturn(null);

      final result = map.getString(
        'throwingKey',
        defaultValue: 'default on error',
      );

      expect(result, 'default on error');
      verify(mockLogger.logError(
        'Error checking key:',
        any,
      )).called(1);
    });

    test('should handle custom default values of different types', () {
      final map = {'key': 'value'};
      expect(map.getString('nonexistent', defaultValue: ''), '');
      expect(map.getString('nonexistent', defaultValue: 'custom'), 'custom');
      expect(map.getString('nonexistent', defaultValue: '123'), '123');
      expect(map.getString('nonexistent', defaultValue: '⭐️'), '⭐️');
    });
  });

  group('getStringOrNull', () {
    test('should return string value for non-empty strings', () {
      final map = {
        'key': 'value',
        'multiword': 'hello world',
      };
      expect(map.getStringOrNull('key'), 'value');
      expect(map.getStringOrNull('multiword'), 'hello world');
    });

    test('should return null for empty string', () {
      final map = {'empty': ''};
      expect(map.getStringOrNull('empty'), null);
    });

    test('should return null for non-existent keys', () {
      final map = {'key': 'value'};
      expect(map.getStringOrNull('nonexistent'), null);
    });

    test('should return null for null values', () {
      final map = {'nullKey': null};
      expect(map.getStringOrNull('nullKey'), null);
    });

    test('should convert and return numeric values as strings', () {
      final map = {
        'integer': 42,
        'double': 42.5,
        'zero': 0,
        'negative': -1,
      };
      expect(map.getStringOrNull('integer'), '42');
      expect(map.getStringOrNull('double'), '42.5');
      expect(map.getStringOrNull('zero'), '0');
      expect(map.getStringOrNull('negative'), '-1');
    });

    test('should convert and return boolean values as strings', () {
      final map = {
        'trueValue': true,
        'falseValue': false,
      };
      expect(map.getStringOrNull('trueValue'), 'true');
      expect(map.getStringOrNull('falseValue'), 'false');
    });

    test('should return null and log error when toString() throws', () {
      final map = {'throwingKey': ThrowingObject()};

      when(mockLogger.logError(
        'Error checking key:',
        any,
      )).thenReturn(null);

      final result = map.getStringOrNull('throwingKey');

      expect(result, null);
      verify(mockLogger.logError(
        'Error checking key:',
        any,
      )).called(1);
    });

    test('should handle various empty value cases', () {
      final map = {
        'emptyString': '',
        'nullValue': null,
        'emptyList': [],
        'emptyMap': {},
      };
      expect(map.getStringOrNull('emptyString'), null);
      expect(map.getStringOrNull('nullValue'), null);
      expect(map.getStringOrNull('emptyList'), '[]');
      expect(map.getStringOrNull('emptyMap'), '{}');
    });

    test('should maintain string case sensitivity', () {
      final map = {
        'UPPERCASE': 'VALUE',
        'lowercase': 'value',
        'MixedCase': 'Value',
      };
      expect(map.getStringOrNull('UPPERCASE'), 'VALUE');
      expect(map.getStringOrNull('lowercase'), 'value');
      expect(map.getStringOrNull('MixedCase'), 'Value');
    });
  });

  group('getInt', () {
    test('should return integer values directly', () {
      final map = {
        'zero': 0,
        'positive': 42,
        'negative': -10,
        'large': 999999,
      };
      expect(map.getInt('zero'), 0);
      expect(map.getInt('positive'), 42);
      expect(map.getInt('negative'), -10);
      expect(map.getInt('large'), 999999);
    });

    test('should handle double values by converting to int', () {
      final map = {
        'wholeNumber': 42.0,
        'decimalNumber': 42.6,
        'negativeWhole': -42.0,
        'negativeDecimal': -42.6,
        'zero': 0.0,
      };
      expect(map.getInt('wholeNumber'), 42);
      expect(map.getInt('decimalNumber'), 42);
      expect(map.getInt('negativeWhole'), -42);
      expect(map.getInt('negativeDecimal'), -42);
      expect(map.getInt('zero'), 0);
    });

    test('should parse integer strings', () {
      final map = {
        'zero': '0',
        'positive': '42',
        'negative': '-10',
        'large': '999999',
      };
      expect(map.getInt('zero'), 0);
      expect(map.getInt('positive'), 42);
      expect(map.getInt('negative'), -10);
      expect(map.getInt('large'), 999999);
    });

    test('should return default value for decimal strings', () {
      final map = {
        'decimalString': '42.5',
        'negativeDecimal': '-42.5',
      };
      expect(map.getInt('decimalString'), 0);
      expect(map.getInt('decimalString', defaultValue: -1), -1);
      expect(map.getInt('negativeDecimal'), 0);
      expect(map.getInt('negativeDecimal', defaultValue: -1), -1);
    });

    test('should handle various numeric formats', () {
      final map = {
        'withSpaces': ' 42 ',
        'withPlusSign': '+42',
        'withLeadingZeros': '0042',
      };
      expect(map.getInt('withSpaces'), 42);
      expect(map.getInt('withPlusSign'), 42);
      expect(map.getInt('withLeadingZeros'), 42);
    });

    test('should return default value for invalid strings', () {
      final map = {
        'text': 'not a number',
        'empty': '',
        'mixed': '42abc',
      };
      expect(map.getInt('text'), 0);
      expect(map.getInt('text', defaultValue: -1), -1);
      expect(map.getInt('empty'), 0);
      expect(map.getInt('mixed'), 0);
    });

    test('should return default value for null values', () {
      final map = {'nullKey': null};
      expect(map.getInt('nullKey'), 0);
      expect(map.getInt('nullKey', defaultValue: -1), -1);
    });

    test('should return default value for non-existent keys', () {
      final map = {'key': 42};
      expect(map.getInt('nonexistent'), 0);
      expect(map.getInt('nonexistent', defaultValue: -1), -1);
    });

    test('should handle boolean values', () {
      final map = {
        'trueValue': true,
        'falseValue': false,
      };
      expect(map.getInt('trueValue'), 0);
      expect(map.getInt('falseValue'), 0);
    });

    test('should return default value when toString() throws', () {
      final map = {'throwingKey': ThrowingObject()};

      when(mockLogger.logError(
        'Error checking key:',
        any,
      )).thenReturn(null);

      expect(map.getInt('throwingKey'), 0);
      expect(map.getInt('throwingKey', defaultValue: -1), -1);

      verify(mockLogger.logError(
        'Error checking key:',
        any,
      )).called(2);
    });

    test('should handle integer boundaries', () {
      final map = {
        'max': 2147483647,
        'min': -2147483648,
        'maxDouble': 2147483647.0,
        'minDouble': -2147483648.0,
      };
      expect(map.getInt('max'), 2147483647);
      expect(map.getInt('min'), -2147483648);
      expect(map.getInt('maxDouble'), 2147483647);
      expect(map.getInt('minDouble'), -2147483648);
    });
  });

  group('getDouble', () {
    test('should return double values directly', () {
      final map = {
        'zero': 0.0,
        'positive': 42.5,
        'negative': -10.5,
        'wholeNumber': 42.0,
        'smallDecimal': 0.1,
        'largeDecimal': 999999.999,
      };
      expect(map.getDouble('zero'), 0.0);
      expect(map.getDouble('positive'), 42.5);
      expect(map.getDouble('negative'), -10.5);
      expect(map.getDouble('wholeNumber'), 42.0);
      expect(map.getDouble('smallDecimal'), 0.1);
      expect(map.getDouble('largeDecimal'), 999999.999);
    });

    test('should convert integer values to double', () {
      final map = {
        'zero': 0,
        'positive': 42,
        'negative': -10,
        'large': 999999,
      };
      expect(map.getDouble('zero'), 0.0);
      expect(map.getDouble('positive'), 42.0);
      expect(map.getDouble('negative'), -10.0);
      expect(map.getDouble('large'), 999999.0);
    });

    test('should parse valid double strings', () {
      final map = {
        'zero': '0.0',
        'positive': '42.5',
        'negative': '-10.5',
        'wholeNumber': '42.0',
        'exponential': '1.5e2',
        'negativeExponential': '-1.5e2',
      };
      expect(map.getDouble('zero'), 0.0);
      expect(map.getDouble('positive'), 42.5);
      expect(map.getDouble('negative'), -10.5);
      expect(map.getDouble('wholeNumber'), 42.0);
      expect(map.getDouble('exponential'), 150.0);
      expect(map.getDouble('negativeExponential'), -150.0);
    });

    test('should parse integer strings', () {
      final map = {
        'zero': '0',
        'positive': '42',
        'negative': '-10',
      };
      expect(map.getDouble('zero'), 0.0);
      expect(map.getDouble('positive'), 42.0);
      expect(map.getDouble('negative'), -10.0);
    });

    test('should handle various numeric string formats', () {
      final map = {
        'withSpaces': ' 42.5 ',
        'withPlusSign': '+42.5',
        'withLeadingZeros': '00042.5',
        'noLeadingZero': '.5',
        'noTrailingZero': '42.',
      };
      expect(map.getDouble('withSpaces'), 42.5);
      expect(map.getDouble('withPlusSign'), 42.5);
      expect(map.getDouble('withLeadingZeros'), 42.5);
      expect(map.getDouble('noLeadingZero'), 0.5);
      expect(map.getDouble('noTrailingZero'), 42.0);
    });

    test('should return default value for invalid strings', () {
      final map = {
        'text': 'not a number',
        'empty': '',
        'mixed': '42.5abc',
        'multipleDecimals': '42.5.5',
      };
      expect(map.getDouble('text'), 0.0);
      expect(map.getDouble('text', defaultValue: -1.0), -1.0);
      expect(map.getDouble('empty'), 0.0);
      expect(map.getDouble('mixed'), 0.0);
      expect(map.getDouble('multipleDecimals'), 0.0);
    });

    test('should return default value for null values', () {
      final map = {'nullKey': null};
      expect(map.getDouble('nullKey'), 0.0);
      expect(map.getDouble('nullKey', defaultValue: -1.0), -1.0);
    });

    test('should return default value for non-existent keys', () {
      final map = {'key': 42.5};
      expect(map.getDouble('nonexistent'), 0.0);
      expect(map.getDouble('nonexistent', defaultValue: -1.0), -1.0);
    });

    test('should handle boolean values', () {
      final map = {
        'trueValue': true,
        'falseValue': false,
      };
      expect(map.getDouble('trueValue'), 0.0);
      expect(map.getDouble('falseValue'), 0.0);
    });

    test('should return default value when toString() throws', () {
      final map = {'throwingKey': ThrowingObject()};

      when(mockLogger.logError(
        'Error checking key:',
        any,
      )).thenReturn(null);

      expect(map.getDouble('throwingKey'), 0.0);
      expect(map.getDouble('throwingKey', defaultValue: -1.0), -1.0);

      verify(mockLogger.logError(
        'Error checking key:',
        any,
      )).called(2);
    });

    test('should handle extreme values', () {
      final map = {
        'maxDouble': double.maxFinite,
        'minDouble': double.minPositive,
        'infinity': double.infinity,
        'negativeInfinity': double.negativeInfinity,
        'maxInt': 9223372036854775807,
        'minInt': -9223372036854775808,
      };
      expect(map.getDouble('maxDouble'), double.maxFinite);
      expect(map.getDouble('minDouble'), double.minPositive);
      expect(map.getDouble('infinity'), double.infinity);
      expect(map.getDouble('negativeInfinity'), double.negativeInfinity);
      expect(map.getDouble('maxInt'), 9223372036854775807.0);
      expect(map.getDouble('minInt'), -9223372036854775808.0);
    });

    test('should handle precision edge cases', () {
      final map = {
        'verySmall': 1.23e-10,
        'veryLarge': 1.23e10,
        'highPrecision': 1.23456789,
      };
      expect(map.getDouble('verySmall'), 1.23e-10);
      expect(map.getDouble('veryLarge'), 1.23e10);
      expect(map.getDouble('highPrecision'), 1.23456789);
    });
  });

  group('getBool', () {
    test('should return true when key exists with true value', () {
      final map = {'isEnabled': true};
      expect(map.getBool('isEnabled'), true);
    });

    test('should return false when key exists with false value', () {
      final map = {'isEnabled': false};
      expect(map.getBool('isEnabled'), false);
    });

    test('should handle various true/false representations', () {
      final map = {
        'stringTrue': 'true',
        'stringFalse': 'false',
        'numberOne': 1,
        'numberZero': 0,
      };
      expect(map.getBool('stringTrue'), false);
      expect(map.getBool('stringFalse'), false);
      expect(map.getBool('numberOne'), false);
      expect(map.getBool('numberZero'), false);
    });

    test('should return default value for non-existent keys', () {
      final map = {'key': true};
      expect(map.getBool('nonexistent'), false);
      expect(map.getBool('nonexistent', defaultValue: true), true);
    });

    test('should return default value for null values', () {
      final map = {'nullKey': null};
      expect(map.getBool('nullKey'), false);
      expect(map.getBool('nullKey', defaultValue: true), true);
    });

    test('should return default value for non-boolean values', () {
      final map = {
        'string': 'not a boolean',
        'number': 42,
        'list': [],
        'map': {},
        'empty': '',
      };
      expect(map.getBool('string'), false);
      expect(map.getBool('number'), false);
      expect(map.getBool('list'), false);
      expect(map.getBool('map'), false);
      expect(map.getBool('empty'), false);
    });

    test('should handle case sensitivity correctly', () {
      final map = {
        'TRUE': true,
        'FALSE': false,
        'True': true,
        'False': false,
      };
      expect(map.getBool('true'), false);
      expect(map.getBool('TRUE'), true);
      expect(map.getBool('False'), false);
      expect(map.getBool('FALSE'), false);
    });

    test('should return default value and log error when toString() throws', () {
      final map = {'throwingKey': ThrowingObject()};

      when(mockLogger.logError(
        'Error checking key:',
        any,
      )).thenReturn(null);

      final result = map.getBool('throwingKey', defaultValue: true);

      expect(result, true);
      verify(mockLogger.logError(
        'Error checking key:',
        any,
      )).called(1);
    });

    test('should handle special keys', () {
      final map = {
        'special@key': true,
        'key with spaces': false,
        '123': true,
      };
      expect(map.getBool('special@key'), true);
      expect(map.getBool('key with spaces'), false);
      expect(map.getBool('123'), true);
    });
  });

  group('getList', () {
    test('should convert list of strings correctly', () {
      final map = {
        'strings': ['one', 'two', 'three']
      };

      final result = map.getList('strings', (e) => e as String);

      expect(result, ['one', 'two', 'three']);
      expect(result, isA<List<String>>());
    });

    test('should convert list of integers correctly', () {
      final map = {
        'numbers': [1, 2, 3, 4, 5]
      };

      final result = map.getList('numbers', (e) => e as int);

      expect(result, [1, 2, 3, 4, 5]);
      expect(result, isA<List<int>>());
    });

    test('should convert list of doubles correctly', () {
      final map = {
        'doubles': [1.1, 2.2, 3.3]
      };

      final result = map.getList('doubles', (e) => e as double);

      expect(result, [1.1, 2.2, 3.3]);
      expect(result, isA<List<double>>());
    });

    test('should convert list of complex objects correctly', () {
      final map = {
        'models': [
          {'name': 'first', 'value': 1},
          {'name': 'second', 'value': 2},
        ]
      };

      final result = map.getList('models', TestModel.fromMap);

      expect(result, [
        TestModel(name: 'first', value: 1),
        TestModel(name: 'second', value: 2),
      ]);
      expect(result, isA<List<TestModel>>());
    });

    test('should handle empty lists', () {
      final map = {'emptyList': []};

      final result = map.getList('emptyList', (e) => e as String);

      expect(result, isEmpty);
      expect(result, isA<List<String>>());
    });

    test('should return empty list for non-existent keys', () {
      final map = {'someKey': []};

      final result = map.getList('nonexistent', (e) => e as String);

      expect(result, isEmpty);
      expect(result, isA<List<String>>());
    });

    test('should return empty list for null values', () {
      final map = {'nullList': null};

      final result = map.getList('nullList', (e) => e as String);

      expect(result, isEmpty);
      expect(result, isA<List<String>>());
    });

    test('should return empty list for non-list values', () {
      final map = {
        'string': 'not a list',
        'number': 42,
        'boolean': true,
        'map': {'key': 'value'},
      };

      expect(map.getList('string', (e) => e as String), isEmpty);
      expect(map.getList('number', (e) => e as int), isEmpty);
      expect(map.getList('boolean', (e) => e as bool), isEmpty);
      expect(map.getList('map', (e) => e as Map), isEmpty);
    });

    test('should handle mixed type lists by conversion', () {
      final map = {
        'mixed': ['1', 2, '3', 4]
      };

      final result = map.getList('mixed', (e) => e.toString());

      expect(result, ['1', '2', '3', '4']);
      expect(result, isA<List<String>>());
    });

    test('should handle conversion errors and return empty list', () {
      final map = {
        'invalidData': [
          {'invalid': 'data'},
          {'more': 'invalid'}
        ]
      };

      when(mockLogger.logError(
        'Error parsing list:',
        any,
      )).thenReturn(null);

      final result = map.getList('invalidData', (e) => throw Exception('Conversion error'));

      expect(result, isEmpty);
      verify(mockLogger.logError(
        'Error parsing list:',
        any,
      )).called(1);
    });

    test('should handle lists with null elements', () {
      final map = {
        'withNulls': ['one', null, 'three', null]
      };

      final result = map.getList('withNulls', (e) => e?.toString() ?? 'null');

      expect(result, ['one', 'null', 'three', 'null']);
      expect(result, isA<List<String>>());
    });

    test('should return empty list when toString() throws', () {
      final map = {
        'throwingList': [ThrowingObject(), ThrowingObject()]
      };

      when(mockLogger.logError(
        'Error parsing list:',
        any,
      )).thenReturn(null);

      final result = map.getList('throwingList', (e) => e.toString());

      expect(result, isEmpty);
      verify(mockLogger.logError(
        'Error checking key:',
        any,
      )).called(1);
    });

    test('should handle nested lists through conversion', () {
      final map = {
        'nested': [
          [1, 2],
          [3, 4],
          [5, 6]
        ]
      };

      final result = map.getList('nested',
              (e) => (e as List).map((n) => n as int).toList()
      );

      expect(result, [
        [1, 2],
        [3, 4],
        [5, 6]
      ]);
      expect(result, isA<List<List<int>>>());
    });
  });

  group('getListOrNull', () {
    test('should return non-empty list when data is valid', () {
      final map = {
        'items': ['one', 'two', 'three']
      };

      final result = map.getListOrNull('items', (e) => e as String);

      expect(result, ['one', 'two', 'three']);
      expect(result, isA<List<String>?>());
    });

    test('should return null for empty list', () {
      final map = {'emptyList': []};

      final result = map.getListOrNull('emptyList', (e) => e as String);

      expect(result, isNull);
    });

    test('should return null for non-existent keys', () {
      final map = {'someKey': []};

      final result = map.getListOrNull('nonexistent', (e) => e as String);

      expect(result, isNull);
    });

    test('should return null for null values', () {
      final map = {'nullList': null};

      final result = map.getListOrNull('nullList', (e) => e as String);

      expect(result, isNull);
    });

    test('should return null for non-list values', () {
      final map = {
        'string': 'not a list',
        'number': 42,
        'boolean': true,
        'map': {'key': 'value'},
      };

      expect(map.getListOrNull('string', (e) => e as String), isNull);
      expect(map.getListOrNull('number', (e) => e as int), isNull);
      expect(map.getListOrNull('boolean', (e) => e as bool), isNull);
      expect(map.getListOrNull('map', (e) => e as Map), isNull);
    });

    test('should handle conversion errors and return null', () {
      final map = {
        'invalidData': [
          {'invalid': 'data'},
          {'more': 'invalid'}
        ]
      };

      when(mockLogger.logError(
        'Error parsing list:',
        any,
      )).thenReturn(null);

      final result = map.getListOrNull('invalidData',
              (e) => throw Exception('Conversion error')
      );

      expect(result, isNull);
      verify(mockLogger.logError(
        'Error parsing list:',
        any,
      )).called(1);
    });

    test('should verify one valid conversion case for complex objects', () {
      final map = {
        'models': [
          {'name': 'first', 'value': 1},
          {'name': 'second', 'value': 2},
        ]
      };

      final result = map.getListOrNull('models', TestModel.fromMap);

      expect(result, [
        TestModel(name: 'first', value: 1),
        TestModel(name: 'second', value: 2),
      ]);
    });
  });

  group('getDateTime', () {
    test('should parse numeric timestamps correctly', () {
      final map = {
        'milliseconds': referenceDateMillis,
        'doubleMilliseconds': referenceDateMillis.toDouble(),
      };

      expect(
        map.getDateTime('milliseconds'),
        referenceDate.toLocal(),
      );
      expect(
        map.getDateTime('doubleMilliseconds'),
        referenceDate.toLocal(),
      );
    });

    test('should parse various ISO 8601 string formats', () {
      // Date only formats
      final dateOnlyFormats = {
        'dateOnly': '2024-01-01',
      };

      // UTC/Zoned formats
      final utcFormats = {
        'fullFormat': '2024-01-01T12:00:00.000Z',
        'dateTimeWithTZ': '2024-01-01 12:00:00+00:00',
        'dateTimeWithZ': '2024-01-01 12:00:00Z',
      };

      // Local time formats
      final localTimeFormats = {
        'dateTime': '2024-01-01 12:00:00',
        'dateTimeWithT': '2024-01-01T12:00:00',
        'dateTimeWithMillis': '2024-01-01 12:00:00.000',
      };

      final expectedDateOnly = DateTime.utc(2024, 1, 1).toLocal();
      final expectedFromUtc = DateTime.utc(2024, 1, 1, 12, 0).toLocal();
      final expectedLocal = DateTime(2024, 1, 1, 12, 0);

      for (final entry in dateOnlyFormats.entries) {
        expect(
          {entry.key: entry.value}.getDateTime(entry.key),
          expectedDateOnly,
          reason: 'Error checking date-only format: ${entry.key}',
        );
      }

      for (final entry in utcFormats.entries) {
        expect(
          {entry.key: entry.value}.getDateTime(entry.key),
          expectedFromUtc,
          reason: 'Error checking UTC format: ${entry.key}',
        );
      }

      for (final entry in localTimeFormats.entries) {
        expect(
          {entry.key: entry.value}.getDateTime(entry.key),
          expectedLocal,
          reason: 'Error checking local format: ${entry.key}',
        );
      }
    });

    test('should use default value for invalid string formats', () {
      final defaultDate = DateTime(2023, 12, 31);
      final map = {
        'invalid': 'not a date',
        'partialDate': '2024-01',
        'wrongFormat': '01/01/2024',
        'garbage': 'abc123',
      };

      for (final key in map.keys) {
        final result = map.getDateTime(key, defaultValue: defaultDate);
        expect(result, defaultDate, reason: 'Failed for key: $key');

        verify(mockLogger.logError(
          'Error parsing date:',
          any,
        )).called(1);

        reset(mockLogger);
      }
    });

    test('should handle various invalid inputs with default DateTime.now()', () {
      final map = {
        'nullValue': null,
        'emptyString': '',
        'whitespace': '   ',
        'boolean': true,
        'list': [],
        'map': {},
      };

      for (final key in map.keys) {
        final before = DateTime.now();
        final result = map.getDateTime(key);
        final after = DateTime.now();

        expect(
          result.isAfter(before) && result.isBefore(after) ||
              result.isAtSameMomentAs(before) ||
              result.isAtSameMomentAs(after),
          true,
          reason: 'Failed for key: $key',
        );
      }
    });

    test('should return default value for non-existent keys', () {
      final map = {'someKey': 'someValue'};
      final defaultDate = DateTime(2023, 12, 31);

      final result = map.getDateTime('nonexistent', defaultValue: defaultDate);

      expect(result, defaultDate);
    });

    test('should handle toString() errors', () {
      final defaultDate = DateTime(2023, 12, 31);
      final map = {'throwingKey': ThrowingObject()};

      when(mockLogger.logError(
        'Error parsing date:',
        any,
      )).thenReturn(null);

      final result = map.getDateTime('throwingKey', defaultValue: defaultDate);

      expect(result, defaultDate);
      verify(mockLogger.logError(
        'Error checking key:',
        any,
      )).called(1);
    });

    test('should convert UTC timestamps to local time', () {
      final utcTimestamp = DateTime.utc(2024, 1, 1, 12);
      final map = {
        'timestamp': utcTimestamp.millisecondsSinceEpoch,
      };

      final result = map.getDateTime('timestamp');

      expect(result.isUtc, false);
      expect(result, utcTimestamp.toLocal());
    });

    test('should handle different time zones in string input', () {
      final map = {
        'utc': '2024-01-01T12:00:00Z',
        'est': '2024-01-01T12:00:00-05:00',
        'pst': '2024-01-01T12:00:00-08:00',
        'ist': '2024-01-01T12:00:00+05:30',
      };

      // Convert all to expected local times
      final utcBase = DateTime.utc(2024, 1, 1, 12);
      final estBase = DateTime.utc(2024, 1, 1, 17);
      final pstBase = DateTime.utc(2024, 1, 1, 20);
      final istBase = DateTime.utc(2024, 1, 1, 6, 30);

      expect(map.getDateTime('utc'), utcBase.toLocal());
      expect(map.getDateTime('est'), estBase.toLocal());
      expect(map.getDateTime('pst'), pstBase.toLocal());
      expect(map.getDateTime('ist'), istBase.toLocal());
    });

    test('should handle edge cases of timestamp values', () {
      final map = {
        'maxInt': 8640000000000000,
        'minInt': -8640000000000000,
        'zero': 0,
      };

      expect(
        map.getDateTime('maxInt'),
        DateTime.fromMillisecondsSinceEpoch(8640000000000000).toLocal(),
      );
      expect(
        map.getDateTime('minInt'),
        DateTime.fromMillisecondsSinceEpoch(-8640000000000000).toLocal(),
      );
      expect(
        map.getDateTime('zero'),
        DateTime.fromMillisecondsSinceEpoch(0).toLocal(),
      );
    });
  });

  group('removeEmptyOrNull', () {
    test('should remove null values', () {
      final map = {'key1': 'value1', 'key2': null};
      final result = map.removeEmptyOrNull;
      expect(result, {'key1': 'value1'});
    });

    test('should remove empty string values', () {
      final map = {'key1': 'value1', 'key2': ''};
      final result = map.removeEmptyOrNull;
      expect(result, {'key1': 'value1'});
    });

    test('should remove empty map values', () {
      final map = {'key1': 'value1', 'key2': {}};
      final result = map.removeEmptyOrNull;
      expect(result, {'key1': 'value1'});
    });

    test('should remove empty list values', () {
      final map = {'key1': 'value1', 'key2': []};
      final result = map.removeEmptyOrNull;
      expect(result, {'key1': 'value1'});
    });

    test('should retain non-empty values', () {
      final map = {
        'key1': 'value1',
        'key2': 'value2',
        'key3': {'nestedKey': 'nestedValue'},
        'key4': [1, 2, 3]
      };
      final result = map.removeEmptyOrNull;
      expect(result, {
        'key1': 'value1',
        'key2': 'value2',
        'key3': {'nestedKey': 'nestedValue'},
        'key4': [1, 2, 3]
      });
    });

    test('should handle mixed values correctly', () {
      final map = {
        'key1': 'value1',
        'key2': '',
        'key3': null,
        'key4': {},
        'key5': [],
        'key6': 'value2'
      };
      final result = map.removeEmptyOrNull;
      expect(result, {'key1': 'value1', 'key6': 'value2'});
    });
  });
}
