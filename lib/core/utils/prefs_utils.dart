import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:maple_harvest_app/core/core.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Utility class for managing app preferences and secure storage
class PrefsUtils {
  static const darkModeKey = 'darkMode';

  static const tokenKey = 'token';

  static const emailKey = 'email';

  static const passwordKey = 'password';

  static const onboardingKey = 'onboarding';

  static const recentLocationPrefKey = 'recentLocationPrefKey';

  static const String selectedLocationKey = 'selectedLocationKey';

  final SharedPreferences _prefs;

  final FlutterSecureStorage _storage;

  final LoggerUtils _loggerUtils;

  final CrashlyticsService _crashlyticsService;

  static AndroidOptions androidOptions = const AndroidOptions(
    encryptedSharedPreferences: true,
  );

  static IOSOptions iosOptions = const IOSOptions(
    accessibility: KeychainAccessibility.first_unlock,
  );

  PrefsUtils({
    required SharedPreferences prefs,
    required FlutterSecureStorage storage,
    required LoggerUtils loggerUtils,
    required CrashlyticsService crashlyticsService,
  })  : _prefs = prefs,
        _storage = storage,
        _loggerUtils = loggerUtils,
        _crashlyticsService = crashlyticsService;

  bool get darkMode => _prefs.getBool(darkModeKey) ?? false;

  Future<void> setDarkMode(bool value) async {
    try {
      if (darkMode != value) {
        await _prefs.setBool(darkModeKey, value);
      }
    } catch (e, stack) {
      _loggerUtils.logError('Failed to set dark mode', '$e');
      await _crashlyticsService.recordError(
        e,
        stack,
        fatal: false,
        reason: 'Failed to set dark mode',
      );
      throw GeneralException(message: 'operationFailedMsg'.tr());
    }
  }

  Future<String?> _getKey(String key) async => (await _storage.read(
        key: key,
        iOptions: iosOptions,
        aOptions: androidOptions,
      ));

  Future<bool> _setKey(String key, String value) async {
    try {
      if (key.trim().isEmpty || value.trim().isEmpty) {
        throw GeneralException(message: 'operationFailedMsg'.tr());
      }
      await _storage.write(
        key: key,
        value: value,
        iOptions: Platform.isIOS ? iosOptions : null,
        aOptions: Platform.isAndroid ? androidOptions : null,
      );
      _loggerUtils.logInfo('Key set', 'Key: $key, Value: ${value.protect()}');
      return true;
    } on GeneralException {
      rethrow;
    } catch (e, stack) {
      _loggerUtils.logError('Failed to set key', '$e\n$stack');
      await _crashlyticsService.recordError(
        e,
        stack,
        fatal: false,
        reason: 'Failed to set key $key',
      );
      throw GeneralException(message: 'operationFailedMsg'.tr());
    }
  }

  Future<bool> _deleteKey(String key) async {
    try {
      await _storage.delete(
        key: key,
        iOptions: iosOptions,
        aOptions: androidOptions,
      );

      return true;
    } catch (e, stack) {
      _loggerUtils.logError('Failed to delete key', '$e');
      await _crashlyticsService.recordError(
        e,
        stack,
        fatal: false,
        reason: 'Failed to delete key $key',
      );
      throw GeneralException(message: 'operationFailedMsg'.tr());
    }
  }

  Future<String> get authToken async => await _getKey(tokenKey) ?? '';

  Future<bool> setAuthToken(String? token) async => token == null
      ? await _deleteKey(tokenKey)
      : await _setKey(tokenKey, token);

  Future<String?> get email async => await _getKey(emailKey);

  Future<bool> setEmail(String? email) async {
    return email == null
        ? await _deleteKey(emailKey)
        : await _setKey(emailKey, email);
  }

  Future<String?> get password async => await _getKey(passwordKey);

  Future<bool> setPassword(String? password) async => password == null
      ? await _deleteKey(passwordKey)
      : await _setKey(passwordKey, password);

  Future<bool> setAnonymousCreds(SignupRequest request) async {
    final emailSet = await setEmail(request.emailAddress);
    final passwordSet = await setPassword(request.password);
    return emailSet && passwordSet;
  }

  Future<bool> get hasAnonymousCreds async =>
      await email != null && await password != null;

  Future<bool> clearAnonymousCreds() async {
    final emailSet = await setEmail(null);
    final passwordSet = await setPassword(null);
    return emailSet && passwordSet;
  }

  bool get hasVisitedOnboarding => _prefs.getBool(onboardingKey) ?? false;

  Future<void> setVisitedOnboarding() async {
    await _prefs.setBool(onboardingKey, true);
  }

  Future<void> setRecentLocationSearch(String value) async {
    await _prefs.setString(
      recentLocationPrefKey,
      value,
    );
  }

  Future<dynamic> getRecentLocationSearches() async {
    return _prefs.getString(recentLocationPrefKey);
  }

  Future<void> setSelectedLocation(String location) async {
    await _prefs.setString(selectedLocationKey, location);
  }

  Future<String?> getSelectedLocation() async {
    return _prefs.getString(selectedLocationKey);
  }
}
