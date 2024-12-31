import 'dart:convert';

import 'package:maple_harvest_app/core/core.dart';

extension JsonExtension on Map<String, dynamic> {
  String toJsonString() => jsonEncode(this);

  /// Checks whether the key exists and the value is not null and empty
  bool isValidKey(String key) {
    try {
      return containsKey(key) &&
          this[key] != null &&
          this[key].toString().isNotEmpty;
    } catch (e) {
      sl<LoggerUtils>().logError('Error checking key:', e);
      return false;
    }
  }

  /// Extracts a string value from json
  String getString(String key, {String defaultValue = ''}) {
    try {
      return isValidKey(key) ? this[key].toString() : defaultValue;
    } catch (e) {
      sl<LoggerUtils>().logError('Error parsing string:', e);
      return defaultValue;
    }
  }

  /// Extracts a nullable string value from json
  String? getStringOrNull(String key) {
    try {
      final value = getString(key);
      return value.isNotEmpty ? value : null;
    } catch (e) {
      sl<LoggerUtils>().logError('Error parsing string:', e);
      return null;
    }
  }

  /// Extracts an int value from json
  int getInt(String key, {int defaultValue = 0}) {
    if (!isValidKey(key)) return defaultValue;

    final value = this[key];
    if (value is int) return value;
    if (value is double) return value.toInt();

    return int.tryParse(value.toString()) ?? defaultValue;
  }

  /// Extracts a double value from json
  double getDouble(String key, {double defaultValue = 0.0}) {
    if (!isValidKey(key)) return defaultValue;

    final value = this[key];
    if (value is double) return value;
    if (value is int) return value.toDouble();

    return double.tryParse(value.toString()) ?? defaultValue;
  }

  /// Extracts a bool value from json
  bool getBool(String key, {bool defaultValue = false}) {
    try {
      return isValidKey(key) && this[key] is bool
          ? this[key] as bool
          : defaultValue;
    } catch (e) {
      sl<LoggerUtils>().logError('Error parsing bool:', e);
      return defaultValue;
    }
  }

  /// Extracts a list value from json
  List<T> getList<T>(String key, T Function(dynamic) fromMap) {
    try {
      if (!isValidKey(key) || this[key] is! List) return [];

      return (this[key] as List).map((e) => fromMap(e)).toList();
    } catch (e) {
      sl<LoggerUtils>().logError('Error parsing list:', e);
      return [];
    }
  }

  /// Extracts a nullable list value from json
  List<T>? getListOrNull<T>(String key, T Function(dynamic) fromMap) {
    try {
      final list = getList(key, fromMap);
      return list.isNotEmpty ? list : null;
    } catch (e) {
      sl<LoggerUtils>().logError('Error parsing list:', e);
      return null;
    }
  }

  /// Extracts a date value from json
  DateTime getDateTime(String key, {DateTime? defaultValue}) {
    if (!isValidKey(key)) return defaultValue ?? DateTime.now();

    try {
      final value = this[key];

      if (value is num) {
        return DateTime.fromMillisecondsSinceEpoch(value.toInt()).toLocal();
      }

      final dateStr = value.toString().trim();

      // Handle date only format e.g. '2021-01-01'
      if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(dateStr)) {
        return DateTime.parse('${dateStr}T00:00:00Z').toLocal();
      }

      return DateTime.parse(dateStr).toLocal();
    } catch (e) {
      sl<LoggerUtils>().logError('Error parsing date:', e);
      return defaultValue ?? DateTime.now();
    }
  }

  /// Masks the value of sensitive keys
  Map<String, String> maskSensitive() {
    if (isEmpty) return {};

    final sensitiveHeaders = {'authorization', 'cookie', 'x-api-key'};
    return Map<String, String>.fromEntries(
      entries.map(
        (entry) => MapEntry(
            entry.key,
            sensitiveHeaders.contains(entry.key.toLowerCase()) &&
                    entry.value != null
                ? entry.value.toString().protect()
                : entry.value?.toString() ?? ''),
      ),
    );
  }

  /// Clean up the json by removing null and empty values
  Map<String, dynamic> get removeEmptyOrNull {
    return Map<String, dynamic>.fromEntries(
      entries.where((entry) {
        if (entry.value == null) return false;
        if (entry.value is String) return entry.value.toString().isNotEmpty;
        if (entry.value is Map) return (entry.value as Map).isNotEmpty;
        if (entry.value is List) return (entry.value as List).isNotEmpty;
        return true;
      }),
    );
  }

  /// Extracts a map value from json or returns null if the key does not exist or is invalid
  Map<String, dynamic>? getMapOrNull(String key) {
    try {
      return isValidKey(key) && this[key] is Map<String, dynamic>
          ? this[key]
          : null;
    } catch (e) {
      sl<LoggerUtils>().logError('Error parsing map:', e);
      return null;
    }
  }
}
