import 'package:maple_harvest_app/core/core.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';

import 'mutation_field_model_request.mocks.dart';

@GenerateMocks([MutationResponse, FieldNodeModel])
void main() {
  group('MutationFieldModel', () {
    late MockMutationResponse mockResponse1;
    late MockMutationResponse mockResponse2;
    late MockFieldNodeModel mockField1;
    late MockFieldNodeModel mockField2;

    setUp(() {
      mockResponse1 = MockMutationResponse();
      mockResponse2 = MockMutationResponse();
      mockField1 = MockFieldNodeModel();
      mockField2 = MockFieldNodeModel();
    });

    test('should build simple mutation without variables', () {
      when(mockResponse1.typeName).thenReturn('SuccessResponse');
      when(mockResponse1.selectedFields).thenReturn({
        'field1': mockField1,
      });
      when(mockField1.build(depth: 2)).thenReturn('    field1');

      final mutation = MutationFieldModel(
        name: 'createUser',
        possibleResponses: [mockResponse1],
      );

      final result = mutation.build();
      expect(result, '''createUser {
  ... on SuccessResponse {
    field1
  }
}''');
    });

    test('should build mutation with variables', () {
      when(mockResponse1.typeName).thenReturn('SuccessResponse');
      when(mockResponse1.selectedFields).thenReturn({
        'field1': mockField1,
      });
      when(mockField1.build(depth: 2)).thenReturn('    field1');

      final mutation = MutationFieldModel(
        name: 'createUser',
        possibleResponses: [mockResponse1],
        variables: {
          'name': 'John',
          'age': 25,
          'active': true,
        },
      );

      final result = mutation.build();
      expect(result, '''createUser(name: "John", age: 25, active: true) {
  ... on SuccessResponse {
    field1
  }
}''');
    });

    test('should build mutation with multiple possible responses', () {
      when(mockResponse1.typeName).thenReturn('SuccessResponse');
      when(mockResponse2.typeName).thenReturn('ErrorResponse');

      when(mockResponse1.selectedFields).thenReturn({
        'field1': mockField1,
      });
      when(mockResponse2.selectedFields).thenReturn({
        'field2': mockField2,
      });

      when(mockField1.build(depth: 2)).thenReturn('    field1');
      when(mockField2.build(depth: 2)).thenReturn('    field2');

      final mutation = MutationFieldModel(
        name: 'createUser',
        possibleResponses: [mockResponse1, mockResponse2],
      );

      final result = mutation.build();
      expect(result, '''createUser {
  ... on SuccessResponse {
    field1
  }
  ... on ErrorResponse {
    field2
  }
}''');
    });

    test('should handle nested depth properly', () {
      when(mockResponse1.typeName).thenReturn('SuccessResponse');
      when(mockResponse1.selectedFields).thenReturn({
        'field1': mockField1,
      });
      when(mockField1.build(depth: 3)).thenReturn('      field1');

      final mutation = MutationFieldModel(
        name: 'createUser',
        possibleResponses: [mockResponse1],
      );

      final result = mutation.build(depth: 1);
      expect(result, '''  createUser {
    ... on SuccessResponse {
      field1
    }
  }''');
    });

    test('should format different variable types correctly', () {
      when(mockResponse1.typeName).thenReturn('SuccessResponse');
      when(mockResponse1.selectedFields).thenReturn({
        'field1': mockField1,
      });
      when(mockField1.build(depth: 2)).thenReturn('    field1');

      final mutation = MutationFieldModel(
        name: 'createUser',
        possibleResponses: [mockResponse1],
        variables: {
          'name': 'John',
          'age': 25,
          'active': true,
          'score': 3.14,
          'tags': ['tag1', 'tag2'],
          'data': null,
        },
      );

      final result = mutation.build();
      expect(result, '''createUser(name: "John", age: 25, active: true, score: 3.14, tags: ["tag1", "tag2"], data: null) {
  ... on SuccessResponse {
    field1
  }
}''');
    });

    test('should throw error when possibleResponses is empty', () {
      expect(
            () => MutationFieldModel(
          name: 'createUser',
          possibleResponses: [],
        ).build(),
        throwsA(isA<AssertionError>()),
      );
    });
  });
}