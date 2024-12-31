import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

abstract class MapKitLocationDataSource {
  Future<List<Map<String, dynamic>>?> iosSearchLocation(
      {required String query});
}

class MapKitDataSourceImpl implements MapKitLocationDataSource {
  final MethodChannel platform;

  MapKitDataSourceImpl(this.platform);

  @override
  Future<List<Map<String, dynamic>>?> iosSearchLocation({
    required String query,
  }) async {
    try {
      final String jsonString =
          await platform.invokeMethod('searchLocation', {'query': query});
      // Decode the JSON string into a List<Map<String, dynamic>>
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.map((item) => Map<String, dynamic>.from(item)).toList();
    } on PlatformException catch (e) {
      // Handle PlatformException gracefully
      debugPrint('PlatformException: $e');
      throw PlatformException(
        message:
            'MapKit searchLocation failed due to platform error: ${e.message}',
        code: e.code,
      );
    } catch (e) {
      throw Exception('MapKit searchLocation failed: $e');
    }
  }
}
