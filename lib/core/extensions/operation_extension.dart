import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:gql/ast.dart' as gql;

extension OperationExtension on Operation {
  String get realOPName {
    return operationName ??
        (document.definitions
                .whereType<gql.OperationDefinitionNode>()
                .firstOrNull
                ?.name
                ?.value ??
            'Unnamed');
  }

  String get opType {
    final type = getOperationType();
    if (type == null) return 'Unknown';

    switch (type) {
      case gql.OperationType.query:
        return 'query';
      case gql.OperationType.mutation:
        return 'mutation';
      default:
        return 'Unknown';
    }
  }
}
