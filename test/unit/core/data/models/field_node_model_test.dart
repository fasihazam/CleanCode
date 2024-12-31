import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maple_harvest_app/core/core.dart';

void main() {
  group('constructor validation', () {
    test('accepts valid field names', () {
      expect(() => FieldNodeModel(name: 'validName'), returnsNormally);
      expect(() => FieldNodeModel(name: 'valid_name'), returnsNormally);
      expect(() => FieldNodeModel(name: '_validName'), returnsNormally);
      expect(() => FieldNodeModel(name: 'validName123'), returnsNormally);
    });

    test('throws FormatException for invalid field names', () {
      expect(() => FieldNodeModel(name: ''), throwsFormatException);
      expect(() => FieldNodeModel(name: '123name'), throwsFormatException);
      expect(() => FieldNodeModel(name: 'invalid-name'), throwsFormatException);
      expect(() => FieldNodeModel(name: 'invalid name'), throwsFormatException);
      expect(() => FieldNodeModel(name: 'invalid@name'), throwsFormatException);
    });
  });

  group('build', () {
    test('builds simple field without arguments or children', () {
      final node = FieldNodeModel(name: 'simpleField');
      expect(node.build(), equals('simpleField'));
    });

    test('builds field with arguments', () {
      final node = FieldNodeModel(
        name: 'fieldWithArgs',
        arguments: {
          'stringArg': 'value',
          'numArg': 42,
          'boolArg': true,
          'nullArg': null,
        },
      );

      expect(
        node.build(),
        equals(
            'fieldWithArgs(stringArg: "value", numArg: 42, boolArg: true, nullArg: null)'),
      );
    });

    test('builds field with children', () {
      final node = FieldNodeModel(
        name: 'parent',
        children: {
          'child1': FieldNodeModel(name: 'child1'),
          'child2': FieldNodeModel(name: 'child2'),
        },
      );

      expect(
          node.build(),
          equals('''
parent {
  child1
  child2
}'''
              .trim()));
    });

    test('builds complex nested structure', () {
      final node = FieldNodeModel(
        name: 'root',
        arguments: {'key': 'value'},
        children: {
          'child1': FieldNodeModel(
            name: 'child1',
            arguments: {'id': 123},
            children: {
              'grandchild': FieldNodeModel(name: 'grandchild'),
            },
          ),
          'child2': FieldNodeModel(name: 'child2'),
        },
      );

      expect(
          node.build(),
          equals('''
root(key: "value") {
  child1(id: 123) {
    grandchild
  }
  child2
}'''
              .trim()));
    });

    test('detects circular references', () {
      final childrenMap = <String, FieldNodeModel>{};
      final parentChildrenMap = <String, FieldNodeModel>{};

      final child = FieldNodeModel(
        name: 'child',
        children: childrenMap,
      );

      final parent = FieldNodeModel(
        name: 'parent',
        children: parentChildrenMap,
      );

      // Set up circular reference
      childrenMap['parent'] = parent;
      parentChildrenMap['child'] = child;

      expect(parent.build(), contains('[Circular Reference Detected]'));
    });

    test('throws error when exceeding maximum depth', () {
      FieldNodeModel createNestedNode(int depth) {
        if (depth <= 0) return FieldNodeModel(name: 'leaf');
        return FieldNodeModel(
          name: 'node$depth',
          children: {'child': createNestedNode(depth - 1)},
        );
      }

      final deepNode = createNestedNode(FieldNodeModel.maxDepth + 1);
      expect(() => deepNode.build(), throwsStateError);
    });
  });

  group('formatValue', () {
    late FieldNodeModel node;

    setUp(() {
      node = FieldNodeModel(name: 'test');
    });

    test('formats primitive values', () {
      expect(node.formatValue('string'), equals('"string"'));
      expect(node.formatValue(42), equals('42'));
      expect(node.formatValue(3.14), equals('3.14'));
      expect(node.formatValue(true), equals('true'));
      expect(node.formatValue(null), equals('null'));
    });

    test('formats DateTime', () {
      final date = DateTime(2024, 1, 1, 12, 0);
      expect(node.formatValue(date), equals('"2024-01-01T12:00:00.000"'));
    });

    test('formats List', () {
      final list = ['a', 1, true];
      expect(node.formatValue(list), equals('["a", 1, true]'));
    });

    test('formats Map', () {
      final map = {'key1': 'value1', 'key2': 42};
      expect(node.formatValue(map), equals('{key1: "value1", key2: 42}'));
    });

    test('throws for unsupported types', () {
      expect(() => node.formatValue(const Symbol('test')), throwsArgumentError);
    });

    test('escapes special characters in strings', () {
      const specialChars = 'Line 1\nLine 2\tTabbed\r\n"Quoted"\'Single\'<>&{}';
      final formatted = node.formatValue(specialChars);

      expect(formatted, contains('\\n'));         // newline
      expect(formatted, contains('\\t'));         // tab
      expect(formatted, contains('\\"'));         // double quote
      expect(formatted, contains('\\\''));        // single quote
      expect(formatted, contains('\\u003C'));     // <
      expect(formatted, contains('\\u003E'));     // >
      expect(formatted, contains('\\u0026'));     // &
      expect(formatted, contains('\\u007B'));     // {
      expect(formatted, contains('\\u007D'));     // }

      // Print for debugging
      debugPrint('Formatted string: $formatted');

      // Verify the complete escaped string
      expect(
        formatted,
        '"Line 1\\nLine 2\\tTabbed\r\n\\"Quoted\\"\\\'Single\\\'\\u003C\\u003E\\u0026\\u007B\\u007D"',
      );
    });

    test('handles empty maps for children and arguments', () {
      final node = FieldNodeModel(name: 'test');
      expect(node.children, isEmpty);
      expect(node.arguments, isEmpty);
    });

    test('preserves immutability of default maps', () {
      final node = FieldNodeModel(name: 'test');
      expect(() => node.children['key'] = FieldNodeModel(name: 'new'),
          throwsUnsupportedError);
      expect(() => node.arguments['key'] = 'value', throwsUnsupportedError);
    });
  });
}
