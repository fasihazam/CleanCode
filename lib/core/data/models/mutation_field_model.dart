import 'package:maple_harvest_app/core/core.dart';

class MutationFieldModel extends FieldNodeModel {
  final List<MutationResponse> possibleResponses;
  final Map<String, dynamic> variables;

  MutationFieldModel({
    required super.name,
    required this.possibleResponses,
    this.variables = const {},
  });

  @override
  String build({int depth = 0}) {
    final buffer = StringBuffer();
    final indent = '  ' * depth;

    // Add field name with variables
    buffer.write('$indent$name');

    // Add variables if any
    if (variables.isNotEmpty) {
      final args = variables.entries
          .map((e) => '${e.key}: ${formatValue(e.value)}')
          .join(', ');
      buffer.write('($args)');
    }

    // Add response types
    buffer.write(' {\n');

    if (possibleResponses.isEmpty) {
      throw AssertionError('Mutation field $name must have at least one possible response type');
    }

    // Add union type selections
    for (final response in possibleResponses) {
      buffer.write('$indent  ... on ${response.typeName} {\n');

      for (final field in response.selectedFields.values) {
        buffer.write('${field.build(depth: depth + 2)}\n');
      }

      buffer.write('$indent  }\n');
    }

    buffer.write('$indent}');

    return buffer.toString();
  }
}