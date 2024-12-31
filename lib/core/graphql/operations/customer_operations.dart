import 'package:maple_harvest_app/core/core.dart';

class CustomerOperations {
  static String getActiveCustomer({CustomerRequest? selection}) {
    final queryBuilder = GraphQLQueryBuilder(
      operationName: OperationName.user.name,
      fields: {
        NetworkConstants.activeCustomerKey: FieldNodeModel(
          name: NetworkConstants.activeCustomerKey,
          children: selection?.selectedFields ?? CustomerRequest.defaultFields,
        ),
      },
    );

    return queryBuilder.build();
  }

  static String updateCustomer(CustomerRequest request) {
    final mutation = GraphQLQueryBuilder(
      operationName: OperationName.updateCustomer.name,
      operationType: OperationType.mutation,
      fields: {
        NetworkConstants.updateCustomerKey: MutationFieldModel(
          name: NetworkConstants.updateCustomerKey,
          variables: request.toVariables(),
          possibleResponses: [
            const CustomerResponse(),
          ],
        ),
      },
    );

    return mutation.build();
  }

  CustomerOperations._();
}
