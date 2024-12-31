import 'package:flutter_test/flutter_test.dart';
import 'package:maple_harvest_app/core/core.dart';

void main() {
  group('GraphQLModel', () {
    group('generateFields', () {
      test('should generate map with single field', () {
        final result = GraphQLModel.generateFields(['id']);

        expect(result, isA<Map<String, FieldNodeModel>>());
        expect(result.length, equals(1));
        expect(result['id'], isA<FieldNodeModel>());
        expect(result['id']?.name, equals('id'));
      });

      test('should generate map with multiple fields', () {
        final result = GraphQLModel.generateFields(['id', 'name', 'email']);

        expect(result.length, equals(3));
        expect(result.keys, containsAll(['id', 'name', 'email']));
        for (final value in result.values) {
          expect(value, isA<FieldNodeModel>());
        }
        expect(result['id']?.name, equals('id'));
        expect(result['name']?.name, equals('name'));
        expect(result['email']?.name, equals('email'));
      });

      test('should return empty map for empty input list', () {
        final result = GraphQLModel.generateFields([]);

        expect(result, isEmpty);
      });

      test('should return unmodifiable map', () {
        final result = GraphQLModel.generateFields(['id']);

        expect(() => result['newField'] = FieldNodeModel(name: 'newField'),
            throwsUnsupportedError);
      });

      test('should handle fields with special characters', () {
        final result = GraphQLModel.generateFields(['user_id', 'created_at']);

        expect(result.length, equals(2));
        expect(result['user_id']?.name, equals('user_id'));
        expect(result['created_at']?.name, equals('created_at'));
      });

      test('should preserve field order', () {
        final fields = ['third', 'first', 'second'];
        final result = GraphQLModel.generateFields(fields);

        expect(result.keys.toList(), equals(fields));
      });
    });
  });
}