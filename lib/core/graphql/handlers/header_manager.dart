import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:maple_harvest_app/core/core.dart';

class HeaderManager {
  static const defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static const _allowedContentTypes = {
    'application/json',
    'application/graphql',
  };

  static const _allowedHeaders = {
    'Content-Type',
    'Accept',
    'Authorization',
  };

  static const authHeaderKey = 'Authorization';

  /// Maximum allowed length for header values
  static const headerValueLength = 8192; // 8KB

  final Map<String, String> _headers = Map.from(defaultHeaders);

  Map<String, String> get headers => Map.unmodifiable(_headers);

  void updateHeaders(Map<String, String> newHeaders) {
    try {
      final sanitizedHeaders = Map<String, String>.fromEntries(
        newHeaders.entries.map((entry) => MapEntry(
              entry.key,
              sanitizeHeaderValue(entry.value),
            )),
      );

      validateHeaders(sanitizedHeaders);
      _headers.addAll(sanitizedHeaders);
      if (kDebugMode) {
        debugPrint(
            'Headers updated: ${headers.maskSensitive().entries.join(', ')}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('HeaderManager: Security violation attempted: $e');
      }
      rethrow;
    }
  }

  void resetHeaders() {
    _headers
      ..clear()
      ..addAll(defaultHeaders);
    debugPrint('HeaderManager: Headers after reset: $_headers');
  }

  /// Validates headers by checking if they are allowed and sanitizing values
  /// Throws [SecurityException] if invalid
  bool validateHeaders(Map<String, String> headers) {
    for (final entry in headers.entries) {
      if (!_allowedHeaders.contains(entry.key)) {
        throw SecurityException.injectionAttempt(
          message: 'invalidHeaderMsg'.tr(args: [entry.key]),
          payload: entry.toString(),
        );
      }

      if (entry.key == 'Content-Type' &&
          !_allowedContentTypes.contains(entry.value)) {
        throw SecurityException.injectionAttempt(
          message: 'invalidContentTypeMsg'.tr(args: [entry.value]),
          payload: entry.toString(),
        );
      }
    }

    return true;
  }

  /// Sanitizes header values by:
  /// - Normalizing whitespace (replacing multiple spaces with single space)
  /// - Removing control characters
  /// - Removing potentially dangerous characters
  /// - Removing single quotes
  /// - Removing line breaks, tabs, and carriage returns
  /// - Ensure the value length is within the [headerValueLength] limit
  /// Returns sanitized header value or throws [SecurityException] if invalid
  String sanitizeHeaderValue(String? value) {
    value = value?.trim();
    if (value == null) {
      throw SecurityException(
        message: 'nullHeaderValueMsg'.tr(),
        attackType: AttackType.injectionAttempt,
      );
    }

    if (value.isEmpty) {
      throw SecurityException(
        message: 'emptyHeaderValueMsg'.tr(),
        attackType: AttackType.injectionAttempt,
      );
    }

    if (value.length > HeaderManager.headerValueLength) {
      throw SecurityException(
        message: 'headerLengthExceededMsg'.tr(),
        attackType: AttackType.injectionAttempt,
      );
    }

    // Return unmodified if it's a valid content type
    if (_isContentTypeHeader(value) && _allowedContentTypes.contains(value)) {
      return value;
    }

    // Remove control characters
    String cleaned = value.replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '');

    // normalize whitespace - replace all whitespace sequences with single space
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();

    // Remove line breaks, tabs, and carriage returns
    cleaned = cleaned.replaceAll(RegExp(r'[\r\n\t]'), '');

    // Remove potentially dangerous characters
    cleaned = cleaned.replaceAll(RegExp(r'[~`\\/<>^%{}()\[\]";_]'), '');

    // Remove single quotes
    cleaned = cleaned.replaceAll(RegExp(r"'"), '');

    // Ensure we still have a value after cleaning
    if (cleaned.isEmpty) {
      throw SecurityException(
        message: 'invalidHeaderValueMsg'.tr(),
        attackType: AttackType.injectionAttempt,
      );
    }

    return cleaned;
  }

  bool _isContentTypeHeader(String value) {
    return value.toLowerCase().startsWith('application/');
  }
}
