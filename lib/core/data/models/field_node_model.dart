import 'package:flutter/widgets.dart';

class FieldNodeModel {
  final String name;

  final Map<String, FieldNodeModel> children;

  final Map<String, dynamic> arguments;

  static const int maxDepth = 1000;

  // Regular expression for valid field names
  static final RegExp _validFieldNamePattern = RegExp(r'^[a-zA-Z_][a-zA-Z0-9_]*$');

  static const Map<String, String> _escapeChars = {
    '"': '\\"',
    '\\': '\\\\',
    '\b': '\\b',
    '\f': '\\f',
    '\n': '\\n',
    '\r': '\\r',
    '\t': '\\t',
    '\v': '\\v',
    "'": "\\'",
    '<': '\\u003C',
    '>': '\\u003E',
    '&': '\\u0026',
    '{': '\\u007B',
    '}': '\\u007D',
  };

  FieldNodeModel({
    required String name,
    this.children = const {},
    this.arguments = const {},
  }) : name = _validateFieldName(name);


  String build({int depth = 0}) => _buildWithCycleDetection(
        depth: depth,
        visited: {},
      );

  String _buildWithCycleDetection({
    int depth = 0,
    required Set<FieldNodeModel> visited,
  }) {
    if (depth >= maxDepth) {
      throw StateError('Maximum recursion depth of $maxDepth exceeded. The structure is too deeply nested.');
    }

    final indent = '  ' * depth;
    final buffer = StringBuffer();

    // Add field name
    buffer.write('$indent$name');

    // Add arguments if any
    if (arguments.isNotEmpty) {
      final args = arguments.entries
          .map((e) => '${e.key}: ${formatValue(e.value)}')
          .join(', ');
      buffer.write('($args)');
    }

    // Add nested fields if any, with cycle detection
    if (children.isNotEmpty) {
      buffer.write(' {\n');

      if (visited.contains(this)) {
        buffer.write('$indent  [Circular Reference Detected]\n');
      } else {
        visited.add(this);
        for (var child in children.values) {
          buffer.write('${child._buildWithCycleDetection(depth: depth + 1, visited: visited)}\n');
        }
        visited.remove(this);
      }

      buffer.write('$indent}');
    }

    return buffer.toString();
  }

  String formatValue(dynamic value) {
    if (value == null) return 'null';
    if (value is String) return '"${_escapeString(value)}"';
    if (value is num || value is bool) return value.toString();
    if (value is DateTime) return '"${value.toIso8601String()}"';
    if (value is List) {
      return '[${value.map(formatValue).join(', ')}]';
    }
    if (value is Map) {
      return '{${value.entries.map((e) {
        final key = _validateFieldName(e.key.toString());
        return '$key: ${formatValue(e.value)}';
      }).join(', ')}}';
    }
    throw ArgumentError('Unsupported value type: ${value.runtimeType}');
  }

  static String _validateFieldName(String name) {
    if (!_validFieldNamePattern.hasMatch(name)) {
      throw FormatException(
        'Invalid field name "$name". Field names must start with a letter or underscore '
            'and contain only letters, numbers, and underscores.',
      );
    }
    return name;
  }

  // Sanitize string values
  static String _escapeString(String value) {
    final buffer = StringBuffer();
    for (final char in value.characters) {
      buffer.write(_escapeChars[char] ?? char);
    }
    return buffer.toString();
  }
}
