import 'package:easy_localization/easy_localization.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:maple_harvest_app/core/core.dart';

class HeaderLink extends Link {
  final HeaderManager _headerManager;
  final LoggerUtils _logger;
  final PrefsUtils _prefsUtils;
  final GraphQLLogger _graphQLLogger;

  static const _tokenHeader = 'vendure-auth-token';
  static const _tag = 'HeaderLink';

  HeaderLink(
    this._headerManager,
    this._logger,
    this._prefsUtils,
    this._graphQLLogger,
  );

  @override
  Stream<Response> request(Request request, [NextLink? forward]) async* {
    try {
      if (forward == null) {
        _logger.logError(_tag, 'Forward link is null');
        throw GeneralException(message: 'operationFailedMsg'.tr());
      }

      final currentHeaders = _headerManager.headers;
      _logger.logInfo(
          _tag, 'Current headers: ${currentHeaders.maskSensitive()}');

      final updatedRequest = request.updateContextEntry<HttpLinkHeaders>(
        (headers) {
          final existingHeaders = headers?.headers ?? {};
          final mergedHeaders = <String, String>{
            ...existingHeaders,
            ...currentHeaders
          };
          _logger.logInfo(
              _tag, 'Merged headers: ${mergedHeaders.maskSensitive()}');
          return HttpLinkHeaders(headers: mergedHeaders);
        },
      );

      // wrapping the request in a try-catch block to avoid breaking the entire request
      try {
        _graphQLLogger.logRequest(
          operationType: updatedRequest.operation.opType,
          operationName: updatedRequest.operation.realOPName,
          queryDocument: updatedRequest.operation.document,
          variables: updatedRequest.variables,
          headers: updatedRequest.context.entry<HttpLinkHeaders>()?.headers,
        );
      } catch (e) {
        _logger.logError(_tag, 'Error logging request: $e');
      }

      await for (final response in forward(updatedRequest)) {
        await _handleAuthToken(response);
        yield response;
      }
    } catch (e, stackTrace) {
      _logger.logError(_tag, 'Error: $e $stackTrace');
      rethrow;
    }
  }

  Future<void> _handleAuthToken(Response response) async {
    final linkResponse = response.context.entry<HttpLinkResponseContext>();
    final headers = linkResponse?.headers;

    if (headers == null || headers.isEmpty) {
      return;
    }

    final authToken = headers.getString(_tokenHeader);
    if (authToken.isEmpty) {
      return;
    }

    // Update token in storage and headers
    await _prefsUtils.setAuthToken(authToken);
    _logger.logInfo(_tag, 'Auth token updated: ${authToken.protect()}');
  }
}
