// use_cases/get_current_location_use_case.dart
import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/core.dart';
import '../repositories/location_repository.dart';

class GetCurrentLocationUseCase {
  final PermissionUseCases _permissionUseCases;
  final LocationRepository _locationRepository;

  GetCurrentLocationUseCase(this._permissionUseCases, this._locationRepository);

  Future<Either<CustomException, LocationData>> execute() async {
    // Request location permission
    final permissionGranted =
        await _permissionUseCases.requestPermission(Permission.location);

    if (!permissionGranted) {
      return Left(GeneralException(
        message: 'locationPermissionRequiredForFeature',
      ));
    }

    return await _locationRepository.getCurrentLocation();
  }
}
