import 'package:maple_harvest_app/core/core.dart';

abstract class UserDatasource {
  Future<CustomerResponse> getUser();

  Future<bool> logout();

  Future<void> updateUser(CustomerRequest request);
}

class UserDatasourceImpl implements UserDatasource {
  final GraphQLService _graphQLService;

  final LoggerUtils _logger;

  static const _tag = 'UserDatasourceImpl';

  UserDatasourceImpl({
    required GraphQLService graphQLService,
    required LoggerUtils loggerUtils,
  })  : _graphQLService = graphQLService,
        _logger = loggerUtils;

  @override
  Future<CustomerResponse> getUser() async {
    try {
      final query = CustomerOperations.getActiveCustomer();
      final result = await _graphQLService.query(query);

      return CustomerResponse.fromActiveCustomerData(result.data);
    } catch (e) {
      _logger.logInfo(_tag, 'Failed to get user: $e');
      rethrow;
    }
  }

  @override
  Future<bool> logout() async {
    try {
      return await _graphQLService.clearAuthToken();
    } catch (e) {
      _logger.logInfo(_tag, 'Failed to logout: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateUser(CustomerRequest request) async {
    try {
      final mutation = CustomerOperations.updateCustomer(request);
      _logger.logInfo(_tag, 'Updating user: $mutation');
      await _graphQLService.mutate(mutation);
    } catch (e, stack) {
      _logger.logInfo(_tag, 'Failed to update user: $e\n$stack');
      rethrow;
    }
  }
}
