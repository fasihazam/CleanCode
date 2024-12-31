import 'dart:core';

import 'package:maple_harvest_app/core/core.dart';

abstract class CustomException implements Exception {
  static const messageKey = 'message';

  final String message;

  CustomException({required this.message});

  @override
  String toString() => 'CustomException: $message';

  Iterable<Object> toIterable() => ['$messageKey: $message'];
}

class NetworkException extends CustomException {
  NetworkException({required super.message});

  @override
  String toString() => 'NetworkException: $message';
}

class FirebaseCustomException extends CustomException {
  static const codeKey = 'code';

  final String code;

  FirebaseCustomException({
    required super.message,
    required this.code,
  });

  @override
  String toString() => 'FirebaseBaseException: [Code: $code] $message';

  @override
  Iterable<Object> toIterable() => [super.toIterable(), '$codeKey: $code'];
}

class GraphQLException extends CustomException {
  static const typeKey = 'type';

  final GraphQLErrorType type;

  GraphQLException({
    required super.message,
    required this.type,
  });

  @override
  String toString() => 'GraphQLException: [Type: $type] $message';

  @override
  Iterable<Object> toIterable() => [
        super.toIterable(),
        '$typeKey: ${type.name}',
      ];
}

class GeneralException extends CustomException {
  GeneralException({required super.message});

  @override
  String toString() => 'GeneralException: $message';
}

class SecurityException extends CustomException {
  static const payloadKey = 'payload';
  static const timestampKey = 'timestamp';
  static const contextKey = 'context';
  static const attackTypeKey = 'attackType';

  final AttackType attackType;
  final Map<String, dynamic>? context;
  final DateTime timestamp;

  SecurityException({
    required super.message,
    required this.attackType,
    this.context,
  }) : timestamp = DateTime.now();

  @override
  String toString() =>
      'SecurityException: [${attackType.name}] $message (${timestamp.toIso8601String()})';

  factory SecurityException.injectionAttempt({
    required String message,
    required String payload,
  }) {
    return SecurityException(
      message: message,
      attackType: AttackType.injectionAttempt,
      context: {
        payloadKey: payload,
      },
    );
  }

  @override
  Iterable<Object> toIterable() => [
        super.toIterable(),
        '$attackTypeKey: ${attackType.name}',
        '$timestampKey: ${timestamp.toIso8601String()}',
        if (context != null)
          '$contextKey: ${context!.entries.map((e) => '${e.key}: ${e.value}')}',
      ];
}

class UserNotFoundException extends CustomException {
  UserNotFoundException({required super.message});

  @override
  String toString() => 'UserNotFoundException: $message';
}
