import 'package:dartz/dartz.dart';
import 'package:location/location.dart';
import 'package:maple_harvest_app/core/core.dart';
import 'package:maple_harvest_app/features/features.dart';

abstract class LocationRepository {
  Future<Either<CustomException, List<LocationModel>>> searchLocation({
    required String query,
  });

  Future<Either<CustomException, List<LocationModel>>>
      fetchAddressFromCoordinates(
    double lat,
    double lng,
  );

  Future<Either<CustomException, LocationData>> getCurrentLocation();
}
