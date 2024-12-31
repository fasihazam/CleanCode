import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:location/location.dart';
import 'package:maple_harvest_app/core/core.dart';
import 'package:maple_harvest_app/features/features.dart';

class LocationRepositoryImpl with ExceptionMixin implements LocationRepository {
  final FallbackLocationService _fallbackLocationService;
  final GoogleLocationDataSource _googleLocationDataSource;
  final Location _location;

  LocationRepositoryImpl({
    required FallbackLocationService fallbackLocationService,
    required GoogleLocationDataSource googleLocationDataSource,
    required Location location,
  })  : _fallbackLocationService = fallbackLocationService,
        _googleLocationDataSource = googleLocationDataSource,
        _location = location;

  @override
  Future<Either<CustomException, List<LocationModel>>> searchLocation({
    required String query,
  }) async =>
      handleFuture(() async {
        final locations = await _fallbackLocationService.searchLocation(query);
        if (locations.isEmpty) {
          throw GeneralException(message: "noLocationsFound".tr());
        }
        return locations;
      });

  @override
  Future<Either<CustomException, List<LocationModel>>>
      fetchAddressFromCoordinates(
    double lat,
    double lng,
  ) async =>
          handleFuture(() async {
            final data = await _googleLocationDataSource
                .fetchAddressFromCoordinates(lat, lng);

            if (data == null) {
              throw GeneralException(message: "noDataFromCoordinates".tr());
            }

            // Parse data directly into UnifiedLocationModel
            final results = data['results'] as List<dynamic>? ?? [];
            if (results.isEmpty) {
              throw GeneralException(message: "noResultsFound".tr());
            }

            final addressComponents =
                results.first['address_components'] as List<dynamic>? ?? [];

            return addressComponents.map((component) {
              return LocationModel(
                longName: component['long_name'] as String?,
                shortName: component['short_name'] as String?,
                types: (component['types'] as List<dynamic>?)?.cast<String>() ??
                    [],
              );
            }).toList();
          });

  @override
  Future<Either<CustomException, LocationData>> getCurrentLocation() async =>
      handleFuture(() async {
        // Check if location services are enabled
        bool serviceEnabled = await _location.serviceEnabled();
        if (!serviceEnabled) {
          serviceEnabled = await _location.requestService();
          if (!serviceEnabled) {
            throw GeneralException(message: "locationServiceError".tr());
          }
        }

        try {
          // Get current location data with timeout
          final locationData = await _location.getLocation().timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw GeneralException(message: "locationTimeOutError".tr());
            },
          );
          return locationData;
        } catch (e) {
          if (e is TimeoutException) {
            throw GeneralException(message: "locationTimeOutError".tr());
          }
          rethrow; // Re-throw other exceptions to be handled by handleFuture
        }
      });
}
