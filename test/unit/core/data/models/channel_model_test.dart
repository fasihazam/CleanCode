import 'package:flutter_test/flutter_test.dart';
import 'package:maple_harvest_app/core/core.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'channel_model_test.mocks.dart';

@GenerateMocks([LoggerUtils])
void main() {
  late MockLoggerUtils mockLogger;

  setUp(() {
    mockLogger = MockLoggerUtils();
    sl.registerSingleton<LoggerUtils>(mockLogger);
  });

  tearDown(() {
    sl.reset();
  });

  test('fromMap creates model with all fields', () {
    final map = {
      'id': 'channel_123',
      'token': 'abc123',
      'code': 'MAIN_CHANNEL',
      'permissions': ['READ', 'WRITE', 'ADMIN'],
    };

    final model = ChannelModel.fromMap(map);

    expect(model.id, equals('channel_123'));
    expect(model.token, equals('abc123'));
    expect(model.code, equals('MAIN_CHANNEL'));
    expect(model.permissions, equals(['READ', 'WRITE', 'ADMIN']));
  });

  test('fromMap handles null values', () {
    final map = {
      'id': null,
      'token': null,
      'code': null,
      'permissions': null,
    };

    final model = ChannelModel.fromMap(map);

    expect(model.id, isEmpty);
    expect(model.token, isEmpty);
    expect(model.code, isEmpty);
    expect(model.permissions, isEmpty);
  });

  test('fromMap handles missing fields', () {
    final map = <String, dynamic>{};

    final model = ChannelModel.fromMap(map);

    expect(model.id, isEmpty);
    expect(model.token, isEmpty);
    expect(model.code, isEmpty);
    expect(model.permissions, isEmpty);
  });

  test('fromMap handles empty permissions list', () {
    final map = {
      'id': 'channel_123',
      'token': 'abc123',
      'code': 'MAIN_CHANNEL',
      'permissions': [],
    };

    final model = ChannelModel.fromMap(map);

    expect(model.permissions, isEmpty);
  });

  test('selectedFields returns correct structure', () {
    final model = ChannelModel();
    final fields = model.selectedFields;

    expect(fields.length, equals(4));
    expect(fields.containsKey('id'), isTrue);
    expect(fields.containsKey('token'), isTrue);
    expect(fields.containsKey('code'), isTrue);
    expect(fields.containsKey('permissions'), isTrue);
  });

  test('defaultFields generates correct structure', () {
    final fields = ChannelModel.defaultFields;

    expect(fields.length, equals(4));
    expect(fields.containsKey('id'), isTrue);
    expect(fields.containsKey('token'), isTrue);
    expect(fields.containsKey('code'), isTrue);
    expect(fields.containsKey('permissions'), isTrue);
  });

  test('fromMap logs error for invalid permissions list items', () {
    final map = {
      'id': 'channel_123',
      'permissions': [123, 'READ', true],
    };

    ChannelModel.fromMap(map);
    verify(mockLogger.logError(
      'Error parsing list:',
      any,
    )).called(1);
  });

  test('constant keys are correctly defined', () {
    expect(ChannelModel.idKey, equals('id'));
    expect(ChannelModel.tokenKey, equals('token'));
    expect(ChannelModel.codeKey, equals('code'));
    expect(ChannelModel.permissionsKey, equals('permissions'));
  });
}