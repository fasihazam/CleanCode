import 'package:easy_localization/easy_localization.dart';
import 'package:maple_harvest_app/core/config/config.dart';

extension StringExtension on String {
  /// Sanitizes a name by allowing only alphanumeric characters and underscores
  String get sanitizeName {
    String sanitized = trim();

    // Basic validation checks
    if (!_isValidLength(sanitized) || !_hasValidStartCharacter(sanitized)) {
      throw GeneralException(message: 'invalidNameMsg'.tr());
    }

    // Sanitization
    sanitized = _sanitizeCharacters(sanitized);

    // Post-sanitization validation
    if (!_isValidSanitizedName(sanitized)) {
      throw GeneralException(message: 'invalidNameMsg'.tr());
    }

    return sanitized;
  }

  bool _isValidLength(String value) => value.length <= 80 && value.length >= 3;

  bool _hasValidStartCharacter(String value) =>
      RegExp(r'^[a-zA-Z]').hasMatch(value);

  String _sanitizeCharacters(String value) =>
      value.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '');

  bool _isValidSanitizedName(String value) =>
      value.isNotEmpty && value.length >= 3;

  /// Operation names must start with a letter and can only contain letters, numbers, and underscores
  bool get isValidOPName {
    final regex = RegExp(r'^[a-zA-Z][a-zA-Z0-9_]*$');
    return regex.hasMatch(this);
  }

  /// Masks the string with stars with the last two characters of a string
  String protect({int showLastChars = 2}) {
    final masked = length > showLastChars
        ? '****${substring(length - showLastChars)}'
        : '****';
    return masked;
  }

}
