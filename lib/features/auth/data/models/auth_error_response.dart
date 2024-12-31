import 'package:maple_harvest_app/core/core.dart';

abstract class AuthErrorResponse extends MutationResponse {
  static const errorCodeKey = 'errorCode';
  static const messageKey = 'message';

  final String errorCode;
  final String message;

  const AuthErrorResponse({
    required super.typeName,
    this.errorCode = '',
    this.message = '',
  });

  @override
  Map<String, FieldNodeModel> get selectedFields =>
      GraphQLModel.generateFields([
        errorCodeKey,
        messageKey,
      ]);
}

class InvalidCredentialsError extends AuthErrorResponse {
  static const _typeName = 'InvalidCredentialsError';
  static const authenticationErrorKey = 'authenticationError';

  final String? authenticationError;

  const InvalidCredentialsError({
    super.errorCode,
    super.message,
    this.authenticationError,
  }) : super(typeName: _typeName);

  @override
  Map<String, FieldNodeModel> get selectedFields => {
        ...super.selectedFields,
        ...GraphQLModel.generateFields([authenticationErrorKey]),
      };

  factory InvalidCredentialsError.fromMap(Map<String, dynamic> map) {
    return InvalidCredentialsError(
      errorCode: map.getString(AuthErrorResponse.errorCodeKey),
      message: map.getString(AuthErrorResponse.messageKey),
      authenticationError: map.getString(authenticationErrorKey),
    );
  }
}

class NotVerifiedError extends AuthErrorResponse {
  static const _typeName = 'NotVerifiedError';

  const NotVerifiedError({
    super.errorCode,
    super.message,
  }) : super(typeName: _typeName);

  factory NotVerifiedError.fromMap(Map<String, dynamic> map) {
    return NotVerifiedError(
      errorCode: map.getString(AuthErrorResponse.errorCodeKey),
      message: map.getString(AuthErrorResponse.messageKey),
    );
  }
}

class NativeAuthStrategyError extends AuthErrorResponse {
  static const _typeName = 'NativeAuthStrategyError';

  const NativeAuthStrategyError({
    super.errorCode,
    super.message,
  }) : super(typeName: _typeName);

  factory NativeAuthStrategyError.fromMap(Map<String, dynamic> map) {
    return NativeAuthStrategyError(
      errorCode: map.getString(AuthErrorResponse.errorCodeKey),
      message: map.getString(AuthErrorResponse.messageKey),
    );
  }
}

class MissingPasswordError extends AuthErrorResponse {
  static const _typeName = 'MissingPasswordError';

  const MissingPasswordError({
    super.errorCode,
    super.message,
  }) : super(typeName: _typeName);

  factory MissingPasswordError.fromMap(Map<String, dynamic> map) {
    return MissingPasswordError(
      errorCode: map.getString(AuthErrorResponse.errorCodeKey),
      message: map.getString(AuthErrorResponse.messageKey),
    );
  }
}

class PasswordValidationError extends AuthErrorResponse {
  static const _typeName = 'PasswordValidationError';
  static const validationErrorMessageKey = 'validationErrorMessage';

  final String? validationErrorMessage;

  const PasswordValidationError({
    super.errorCode,
    super.message,
    this.validationErrorMessage,
  }) : super(typeName: _typeName);

  factory PasswordValidationError.fromMap(Map<String, dynamic> map) {
    return PasswordValidationError(
      errorCode: map.getString(AuthErrorResponse.errorCodeKey),
      message: map.getString(AuthErrorResponse.messageKey),
      validationErrorMessage: map.getString(validationErrorMessageKey),
    );
  }

  @override
  Map<String, FieldNodeModel> get selectedFields => {
        ...super.selectedFields,
        ...GraphQLModel.generateFields([validationErrorMessageKey]),
      };
}
