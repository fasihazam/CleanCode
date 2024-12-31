import 'package:gql/ast.dart' as gql;
import 'package:gql/language.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:logger/logger.dart';

class GraphQLLogger {
  final Logger _logger;
  static const _separator = '''
=============================================================================''';
  static const _subSeparator = '''
-----------------------------------------------------------------------------''';

  GraphQLLogger()
      : _logger = Logger(
          printer: PrettyPrinter(
            methodCount: 0,
            errorMethodCount: 5,
            lineLength: 80,
            colors: true,
            printEmojis: true,
            dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
          ),
        );

  void logRequest({
    required String operationType,
    required String operationName,
    required gql.DocumentNode queryDocument,
    Map<String, dynamic>? variables,
    Map<String, String>? headers,
  }) {
    final buffer = StringBuffer();
    buffer.writeln(_separator);
    buffer.writeln('📡 GraphQL $operationType: $operationName');
    buffer.writeln(_subSeparator);
    buffer.writeln('Query:');
    buffer.writeln(printNode(queryDocument));

    if (headers != null && headers.isNotEmpty) {
      buffer.writeln(_subSeparator);
      buffer.writeln('Request Headers:');
      buffer.writeln(headers);
    }

    if (variables != null && variables.isNotEmpty) {
      buffer.writeln(_subSeparator);
      buffer.writeln('Variables:');
      buffer.writeln(variables);
    }
    buffer.writeln(_separator);

    _logger.i(buffer.toString());
  }

  void logResponse({
    required String operationType,
    required String operationName,
    required QueryResult result,
    Duration? duration,
    Map<String, String>? headers,
  }) {
    final buffer = StringBuffer();
    buffer.writeln(_separator);
    buffer.writeln('✅ GraphQL $operationType Response: $operationName');
    if (duration != null) {
      buffer.writeln('⏱️ Duration: ${duration.inMilliseconds}ms');
    }

    if (headers != null && headers.isNotEmpty) {
      buffer.writeln(_subSeparator);
      buffer.writeln('Response Headers:');
      buffer.writeln(headers);
    }

    buffer.writeln(_subSeparator);
    buffer.writeln('Data:');
    buffer.writeln(result.data);
    buffer.writeln(_separator);

    _logger.i(buffer.toString());
  }

  void logError({
    required String operationType,
    required String operationName,
    required Object error,
    StackTrace? stackTrace,
    Duration? duration,
    Map<String, String>? headers,
  }) {
    final buffer = StringBuffer();
    buffer.writeln(_separator);
    buffer.writeln('❌ GraphQL $operationType Error: $operationName');
    if (duration != null) {
      buffer.writeln('⏱️ Duration: ${duration.inMilliseconds}ms');
    }

    buffer.writeln(_subSeparator);
    buffer.writeln('Error:');
    buffer.writeln(error);

    if (headers != null && headers.isNotEmpty) {
      buffer.writeln(_subSeparator);
      buffer.writeln('Response Headers:');
      buffer.writeln(headers);
    }

    if (stackTrace != null) {
      buffer.writeln(_subSeparator);
      buffer.writeln('Stack Trace:');
      buffer.writeln(stackTrace);
    }
    buffer.writeln(_separator);

    _logger.e(buffer.toString());
  }
}
