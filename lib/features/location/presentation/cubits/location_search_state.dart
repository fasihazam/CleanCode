part of 'location_search_cubit.dart';

/// Base State Class
sealed class LocationSearchState extends Equatable {
  final RequestStatus status;
  final CustomException? exception;
  final List<LocationModel> locations;

  const LocationSearchState({
    this.status = RequestStatus.initial,
    this.exception,
    this.locations = const [],
  });

  @override
  List<Object?> get props => [status, exception, locations];
}

/// Initial State
final class LocationSearchInitial extends LocationSearchState {
  const LocationSearchInitial() : super();
}

/// Loading State
final class LocationSearchLoading extends LocationSearchState {
  const LocationSearchLoading({
    super.locations,
    super.status = RequestStatus.loading,
    super.exception,
  });
}

/// Suggestions Loaded State
final class LocationSearchSuggestionsLoaded extends LocationSearchState {
  final List<LocationModel> suggestions;
  const LocationSearchSuggestionsLoaded({
    super.locations,
    super.status = RequestStatus.success,
    super.exception,
    required this.suggestions,
  });

  @override
  List<Object?> get props => [super.props, suggestions];
}

/// Details Loaded State
final class LocationSearchDetailsLoaded extends LocationSearchState {
  final LocationModel details;

  const LocationSearchDetailsLoaded({
    required this.details,
    super.status = RequestStatus.success,
    super.exception,
  });

  @override
  List<Object?> get props => [super.props, details];
}

/// Exception State
final class LocationSearchException extends LocationSearchState {
  final String message;

  const LocationSearchException({
    required this.message,
    super.locations,
    super.status = RequestStatus.error,
    super.exception,
  });

  @override
  List<Object?> get props => [super.props, message];
}

/// Current Location Loading State
final class CurrentLocationLoading extends LocationSearchState {
  const CurrentLocationLoading({
    super.locations,
    super.status = RequestStatus.loading,
    super.exception,
  });
}

/// Current Location Success State
final class CurrentLocationSuccess extends LocationSearchState {
  final List<dynamic> addressComponent;
  final String? currentLocationDetails;

  const CurrentLocationSuccess({
    required this.addressComponent,
    this.currentLocationDetails,
    super.locations,
    super.status = RequestStatus.success,
    super.exception,
  });

  @override
  List<Object?> get props =>
      [super.props, addressComponent, currentLocationDetails];
}

/// Current Location Exception State
final class CurrentLocationException extends LocationSearchState {
  final String message;

  const CurrentLocationException({
    required this.message,
    super.locations,
    super.status = RequestStatus.error,
    super.exception,
  });

  @override
  List<Object?> get props => [super.props, message];
}

/// Clear Shared Preferences Success State
final class ClearSharedPrefsSuccess extends LocationSearchState {
  const ClearSharedPrefsSuccess() : super(status: RequestStatus.success);
}

/// Navigation to Home Success State
final class NavigateToHomeSuccess extends LocationSearchState {
  final String locationDetails;

  const NavigateToHomeSuccess({
    required this.locationDetails,
    super.status = RequestStatus.success,
  });

  @override
  List<Object?> get props => [super.props, locationDetails];
}
