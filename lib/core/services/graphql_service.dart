import 'package:easy_localization/easy_localization.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:maple_harvest_app/core/core.dart';

class GraphQLService {
  final VendureGraphQLClient _client;
  final _defaultErrMsg = 'operationFailedMsg'.tr();

  GraphQLService(this._client);

  /// Adds headers to the GraphQL client manually other than the default ones
  void setHeaders(Map<String, String> headers) {
    try {
      final filteredHeaders = Map<String, String>.from(headers)
        ..remove(HeaderManager.authHeaderKey)
        ..removeWhere((_, value) => value.isEmpty);

      _client.updateHeaders(filteredHeaders);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> clearAuthToken() async {
    try {
      return await _client.clearToken();
    } catch (e) {
      rethrow;
    }
  }

  Future<QueryResult> _execute(
    String document,
    Future<QueryResult> Function(
      String document,
      Map<String, dynamic> variables,
    ) operation, {
    Map<String, dynamic>? variables,
  }) async {
    try {
      final result = await operation(document, variables ?? {});

      if (result.hasException) {
        final error = result.exception?.graphqlErrors.firstOrNull;
        throw GraphQLException(
          message: error?.message ?? _defaultErrMsg,
          type: _determineErrorType(error),
        );
      }

      if (result.data == null) {
        throw GraphQLException(
          message: _defaultErrMsg,
          type: GraphQLErrorType.generalError,
        );
      }

      _validateResponse(result.data!);
      return result;
    } on GraphQLException {
      rethrow;
    } catch (e) {
      throw GeneralException(message: _defaultErrMsg);
    }
  }

  GraphQLErrorType _determineErrorType(GraphQLError? error) {
    final errorCode = error?.extensions?.getStringOrNull('code');
    return GraphQLErrorType.fromString(errorCode);
  }

  void _validateResponse(Map<String, dynamic> data) {
    for (final value in data.values) {
      if (value is! Map<String, dynamic>) continue;

      final typename = value.getStringOrNull('__typename');
      if (typename == null) continue;

      final type = GraphQLErrorType.fromString(typename);
      if (type != GraphQLErrorType.unknown) {
        final errorMessage = value.getStringOrNull('message');
        throw GraphQLException(
          message: errorMessage ?? _defaultErrMsg,
          type: type,
        );
      }
    }
  }

  Future<QueryResult> query(
    String document, {
    Map<String, dynamic>? variables,
  }) =>
      _execute(
        document,
        (doc, vars) => _client.client.query(
          QueryOptions(
            document: gql(doc),
            variables: vars,
            errorPolicy: ErrorPolicy.all,
          ),
        ),
        variables: variables,
      );

  Future<QueryResult> mutate(
    String document, {
    Map<String, dynamic>? variables,
  }) =>
      _execute(
        document,
        (doc, vars) => _client.client.mutate(
          MutationOptions(
            document: gql(doc),
            variables: vars,
            errorPolicy: ErrorPolicy.none,
          ),
        ),
        variables: variables,
      );
}
