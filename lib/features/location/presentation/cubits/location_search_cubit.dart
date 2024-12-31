import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maple_harvest_app/core/core.dart';
import 'package:maple_harvest_app/features/features.dart';

part 'location_search_state.dart';

class LocationSearchCubit extends Cubit<LocationSearchState> {
  final LocationRepository locationRepository;
  final GetCurrentLocationUseCase getCurrentLocationUseCase;
  final PrefsUtils _prefs;
  final Debouncer _debouncer = Debouncer(milliseconds: 300);

  LocationModel? selectedLocation;

  LocationSearchCubit(
    this.locationRepository,
    this._prefs,
    this.getCurrentLocationUseCase,
  ) : super(const LocationSearchInitial());

  /// Handles location search queries
  Future<void> searchLocation(String? query) async {
    if (query == null || query.isEmpty) {
      _emitError('queryEmptyError'.tr());
      return;
    }

    // Use the debouncer to limit API calls
    _debouncer.run(() async {
      emit(LocationSearchLoading(locations: state.locations));
      final result = await locationRepository.searchLocation(query: query);
      result.fold(
        (failure) => _emitError(failure.message),
        (suggestions) {
          if (suggestions.isEmpty) {
            _emitError('noSuggestionsError'.tr());
          } else {
            emit(LocationSearchSuggestionsLoaded(
              suggestions: suggestions,
              locations: state.locations,
            ));
          }
        },
      );
    });
  }

  /// Fetches the user's current location
  Future<void> getCurrentLocation() async {
    emit(LocationSearchLoading(locations: state.locations));

    final locationResult = await getCurrentLocationUseCase.execute();

    locationResult.fold(
      (failure) =>
          _emitError('currentLocationFailedError'.tr() + failure.toString()),
      (currentLocation) async {
        final fetchResult =
            await locationRepository.fetchAddressFromCoordinates(
          currentLocation.latitude ?? 0.0,
          currentLocation.longitude ?? 0.0,
        );

        fetchResult.fold(
          (failure) =>
              _emitError('currentLocationFailedError'.tr() + failure.message),
          (coordinates) {
            final addressParts = coordinates
                .where((c) =>
                    c.types.contains('locality') ||
                    c.types.contains('sublocality'))
                .map((c) => c.longName ?? '')
                .toList();

            final currentLocationDetails = addressParts.join(', ');

            if (currentLocationDetails.isEmpty) {
              _emitError('invalidLocation'.tr());
            } else {
              emit(CurrentLocationSuccess(
                addressComponent: coordinates,
                currentLocationDetails: currentLocationDetails,
                locations: state.locations,
              ));
            }
          },
        );
      },
    );
  }

  /// Clears recent search results
  Future<void> clearRecentSearchResults() async {
    await _prefs.setRecentLocationSearch("");
    emit(const ClearSharedPrefsSuccess());
  }

  /// Fetches recent search results
  Future<void> getRecentSearchResults() async {
    final locationsJson = await _prefs.getRecentLocationSearches();

    if (locationsJson != null && locationsJson.isNotEmpty) {
      final locationsList = (jsonDecode(locationsJson) as List)
          .map(
            (item) => LocationModel.fromLocationJson(item),
          )
          .toList();

      emit(LocationSearchSuggestionsLoaded(
        suggestions: const [],
        locations: locationsList,
      ));
    }
  }

  /// Saves a location to recent searches
  Future<void> saveRecentSearchResults(
    String mainText,
    String secondaryText,
    String? placeId,
  ) async {
    final newLocation = LocationModel(
      mainText: mainText,
      secondaryText: secondaryText,
      placeId: placeId,
    );

    final updatedLocations = List<LocationModel>.from(state.locations);

    if (!updatedLocations.any((location) =>
        location.mainText == newLocation.mainText &&
        location.secondaryText == newLocation.secondaryText)) {
      updatedLocations.add(newLocation);

      if (updatedLocations.length > 5) {
        updatedLocations.removeAt(0);
      }

      await _prefs.setRecentLocationSearch(
        jsonEncode(updatedLocations.map((e) => e.toJson()).toList()),
      );
    }
  }

  /// Navigates to the home screen with the selected location
  Future<void> navigateToHome(LocationModel location) async {
    try {
      await saveRecentSearchResults(
        location.mainText ?? '',
        location.secondaryText ?? '',
        location.placeId,
      );
      final currentLocationDetails =
          '${location.mainText ?? ''}, ${location.secondaryText ?? ''}';

      emit(NavigateToHomeSuccess(locationDetails: currentLocationDetails));
    } catch (e) {
      _emitError('navigateHomeFailedError'.tr() + e.toString());
    }
  }

  /// Helper method to emit error states
  void _emitError(String message) {
    emit(LocationSearchException(
      message: message,
      locations: state.locations,
      status: RequestStatus.error,
    ));
  }
}
