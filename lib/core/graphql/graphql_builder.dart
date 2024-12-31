import 'package:easy_localization/easy_localization.dart';
import 'package:maple_harvest_app/core/core.dart';

class GraphQLQueryBuilder {
  final String operationName;
  final OperationType operationType;
  final Map<String, dynamic> variables;
  final Map<String, FieldNodeModel> fields;

  const GraphQLQueryBuilder({
    required this.operationName,
    this.operationType = OperationType.query,
    this.variables = const {},
    this.fields = const {},
  });

  String build() {
    if (!operationName.isValidOPName) {
      throw GraphQLException(
        message: 'invalidOperationName'.tr(),
        type: GraphQLErrorType.invalidOperation,
      );
    }

    final buffer = StringBuffer();

    // Add operation type and name
    buffer.write('${operationType.name} $operationName');

    // Add variables if any
    if (variables.isNotEmpty) {
      final vars =
          variables.entries.map((e) => '\$${e.key}: ${e.value}').join(', ');
      buffer.write('($vars)');
    }

    // Add fields
    buffer.write(' {\n');
    for (final field in fields.values) {
      buffer.write('${field.build(depth: 1)}\n');
    }
    buffer.write('}');

    return buffer.toString();
  }
}
