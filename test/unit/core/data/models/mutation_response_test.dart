import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maple_harvest_app/core/core.dart';

class TestMutationResponse extends MutationResponse {
  final Map<String, FieldNodeModel> _selectedFields;
  final GraphQLErrorType? _errorType;

  TestMutationResponse({
    required super.typeName,
    required Map<String, FieldNodeModel> fields,
    GraphQLErrorType? errorType,
  })  : _selectedFields = fields,
        _errorType = errorType;

  @override
  Map<String, FieldNodeModel> get selectedFields => _selectedFields;

  @override
  GraphQLErrorType? get errorType => _errorType;
}

class MockFieldNodeModel extends Mock implements FieldNodeModel {}

void main() {
  late MockFieldNodeModel mockField1;
  late MockFieldNodeModel mockField2;

  setUp(() {
    mockField1 = MockFieldNodeModel();
    mockField2 = MockFieldNodeModel();
  });

  test('should initialize with required typeName', () {
    final response = TestMutationResponse(
      typeName: 'SuccessResponse',
      fields: {},
    );

    expect(response.typeName, equals('SuccessResponse'));
  });

  test('should provide access to selectedFields', () {
    final fields = {
      'field1': mockField1,
      'field2': mockField2,
    };

    final response = TestMutationResponse(
      typeName: 'SuccessResponse',
      fields: fields,
    );

    expect(response.selectedFields, equals(fields));
    expect(response.selectedFields.length, equals(2));
    expect(response.selectedFields['field1'], equals(mockField1));
    expect(response.selectedFields['field2'], equals(mockField2));
  });

  test('should return null errorType by default', () {
    final response = TestMutationResponse(
      typeName: 'SuccessResponse',
      fields: {},
    );

    expect(response.errorType, isNull);
  });

  test('should handle custom errorType', () {
    final response = TestMutationResponse(
      typeName: 'ErrorResponse',
      fields: {},
      errorType: GraphQLErrorType.unknown,
    );

    expect(response.errorType, equals(GraphQLErrorType.unknown));
  });

  test('should handle empty selectedFields', () {
    final response = TestMutationResponse(
      typeName: 'EmptyResponse',
      fields: {},
    );

    expect(response.selectedFields, isEmpty);
  });

  test('should maintain immutability of typeName', () {
    final response = TestMutationResponse(
      typeName: 'SuccessResponse',
      fields: {},
    );

    expect(() => (response as dynamic).typeName = 'NewType',
        throwsA(isA<NoSuchMethodError>()));
  });

  test('should create with long typeName', () {
    const longTypeName = 'VeryLongCustomResponseTypeNameForTesting';
    final response = TestMutationResponse(
      typeName: longTypeName,
      fields: {},
    );

    expect(response.typeName, equals(longTypeName));
  });

  test('should handle multiple error types', () {
    const errorTypes = GraphQLErrorType.values;

    for (final errorType in errorTypes) {
      final response = TestMutationResponse(
        typeName: 'ErrorResponse',
        fields: {},
        errorType: errorType,
      );

      expect(response.errorType, equals(errorType));
    }
  });
}
