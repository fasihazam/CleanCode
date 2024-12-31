import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:maple_harvest_app/core/core.dart';

part 'bottom_nav_state.dart';

class BottomNavCubit extends Cubit<BottomNavState> {
  BottomNavCubit() : super(const BottomNavState.initial());

  void updateItem(BottomNavItem item) {
    if (state.currentItem == item) return;
    emit(state.copyWith(currentItem: item));
  }
}
