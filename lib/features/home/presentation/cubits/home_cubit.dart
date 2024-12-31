import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maple_harvest_app/core/core.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final PrefsUtils _prefsUtils;

  HomeCubit(this._prefsUtils) : super(const HomeInitial());

  Future<void> initializeLocation(String location) async {
    emit(const HomeLoading());

    if (location.isNotEmpty) {
      await saveLocation(location);
    } else {
      await loadSavedLocation();
    }
  }

  Future<void> saveLocation(String location) async {
    try {
      await _prefsUtils.setSelectedLocation(location);
      emit(HomeLocationLoaded(location: location));
      debugPrint("Location saved to prefs via Cubit: $location");
    } catch (e) {
      debugPrint("Error saving location via Cubit: $e");
      emit(const HomeError(message: "Failed to save location"));
    }
  }

  Future<void> loadSavedLocation() async {
    try {
      final location = await _prefsUtils.getSelectedLocation() ?? '';
      emit(HomeLocationLoaded(location: location));
      debugPrint("Loaded location via Cubit: $location");
    } catch (e) {
      debugPrint("Error loading location via Cubit: $e");
      emit(const HomeError(message: "Failed to load location"));
    }
  }
}
