import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:maple_harvest_app/core/core.dart';

class LoggedLink extends Link {
  final GraphQLLogger _logger;

  final Link _link;

  LoggedLink(this._logger, this._link);

  @override
  Stream<Response> request(Request request, [NextLink? forward]) async* {
    final operation = request.operation;
    final operationType = operation.opType;
    final operationName = operation.realOPName;

    final startTime = DateTime.now();

    try {
      await for (final response in _link.request(request)) {
        final duration = DateTime.now().difference(startTime);

        // Extract headers from the response context
        final linkResponseContext =
            response.context.entry<HttpLinkResponseContext>();
        final responseHeaders = linkResponseContext?.headers ?? {};

        if (response.errors?.isNotEmpty ?? false) {
          _logger.logError(
            operationType: operationType,
            operationName: operationName,
            error: response.errors!,
            duration: duration,
            headers: responseHeaders,
          );
        } else {
          _logger.logResponse(
            operationType: operationType,
            operationName: operationName,
            result: QueryResult(
              data: response.data,
              source: QueryResultSource.network,
              options: QueryOptions(document: operation.document),
            ),
            duration: duration,
            headers: responseHeaders,
          );
        }

        yield response;
      }
    } catch (e, stack) {
      final duration = DateTime.now().difference(startTime);
      _logger.logError(
        operationType: operationType,
        operationName: operationName,
        error: e,
        stackTrace: stack,
        duration: duration,
      );
      rethrow;
    }
  }
}
