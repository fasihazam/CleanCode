import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:maple_harvest_app/core/core.dart';

abstract class GoogleLocationDataSource {
  Future<Map<String, dynamic>?> searchLocation({required String query});

  Future<Map<String, dynamic>?> fetchAddressFromCoordinates(
      double lat, double lng);
}

class LocationDataSourceImpl extends GoogleLocationDataSource {
  final Dio dio;
  final Logger logger;
  final EnvUtils envUtils;

  LocationDataSourceImpl({
    required this.dio,
    required this.logger,
    required this.envUtils,
  });

  @override
  Future<Map<String, dynamic>?> searchLocation({required String query}) async {
    try {
      final response = await dio.get(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json',
        queryParameters: {
          'input': query,
          'key': envUtils.getEnvVariable('GOOGLE_MAPS_API_KEY'),
        },
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
    } catch (e) {
      logger.e(e);
    }
    return null;
  }

  @override
  Future<Map<String, dynamic>?> fetchAddressFromCoordinates(
      double lat, double lng) async {
    String apiKey = envUtils.getEnvVariable('GOOGLE_MAPS_API_KEY');
    final String url =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$apiKey";
    try {
      final response = await dio.get(url);
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception("Failed to fetch address: ${response.statusMessage}");
      }
    } catch (e) {
      throw Exception("Error fetching address: $e");
    }
  }
}
