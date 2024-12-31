import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:maple_harvest_app/features/features.dart';

class FallbackLocationService {
  final GoogleLocationDataSource googleDataSource;
  final MapKitLocationDataSource mapKitDataSource;

  FallbackLocationService({
    required this.googleDataSource,
    required this.mapKitDataSource,
  });

  Future<List<LocationModel>> searchLocation(String query) async {
    if (query.length < 3) {
      debugPrint("Query must be at least 3 characters.");
      return [];
    }

    try {
      if (Platform.isIOS) {
        return await _searchWithMapKit(query) ?? await _searchWithGoogle(query);
      } else {
        return await _searchWithGoogle(query);
      }
    } catch (e) {
      debugPrint("Error during location search: $e");
      return [];
    }
  }

  Future<List<LocationModel>?> _searchWithMapKit(String query) async {
    try {
      final result = await mapKitDataSource.iosSearchLocation(query: query);
      if (result != null && result.isNotEmpty) {
        return _parseIOSResult(result);
      } else {
        debugPrint("MapKit returned no results. Falling back to Google.");
        return await _searchWithGoogle(query);
      }
    } on PlatformException catch (e) {
      if (e.code == 'RATE_LIMIT') {
        debugPrint("MapKit rate limit reached. Falling back to Google.");
        return await _searchWithGoogle(query);
      }
      throw Exception("MapKit error: $e");
    } catch (e) {
      debugPrint("Unexpected error during MapKit search: $e");
      return await _searchWithGoogle(query);
    }
  }

  Future<List<LocationModel>> _searchWithGoogle(String query) async {
    try {
      final result = await googleDataSource.searchLocation(query: query);
      if (result != null) {
        return _parseGoogleResult(result['predictions'] ?? []);
      } else {
        debugPrint("Google API returned null or empty results.");
      }
    } catch (e) {
      debugPrint("Unexpected error with Google API: $e");
    }
    return [];
  }

  List<LocationModel> _parseIOSResult(List<Map<String, dynamic>> data) {
    try {
      return data.map((item) => LocationModel.fromLocationJson(item)).toList();
    } catch (e) {
      throw Exception("Failed to parse iOS MapKit results.");
    }
  }

  List<LocationModel> _parseGoogleResult(List<dynamic> data) {
    try {
      return data.map((item) {
        if (item is Map<String, dynamic>) {
          return LocationModel.fromPredictionJson(item);
        } else {
          throw Exception(
              "Unexpected item type in Google results: ${item.runtimeType}");
        }
      }).toList();
    } catch (e) {
      throw Exception("Failed to parse Google API results.");
    }
  }
}
