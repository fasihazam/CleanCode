import 'package:maple_harvest_app/core/config/config.dart';

extension RequestStatusExtension on RequestStatus {
  bool get isLoading => this == RequestStatus.loading;

  bool get isSuccess => this == RequestStatus.success;

  bool get hasError => this == RequestStatus.error;
}