import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:maple_harvest_app/core/core.dart';

void main() {
  group('BottomNavCubit', () {
    late BottomNavCubit bottomNavCubit;

    setUp(() {
      bottomNavCubit = BottomNavCubit();
    });

    tearDown(() {
      bottomNavCubit.close();
    });

    test('initial state should be BottomNavItem.home', () {
      expect(bottomNavCubit.state.currentItem, equals(BottomNavItem.home));
    });

    blocTest<BottomNavCubit, BottomNavState>(
      'emits new state with updated BottomNavItem when updateItem is called',
      build: () => bottomNavCubit,
      act: (cubit) => cubit.updateItem(BottomNavItem.profile),
      expect: () => [
        const BottomNavState(currentItem: BottomNavItem.profile),
      ],
    );

    blocTest<BottomNavCubit, BottomNavState>(
      'emits new state when changing from one item to another',
      build: () => bottomNavCubit,
      act: (cubit) => {
        cubit.updateItem(BottomNavItem.home),
        cubit.updateItem(BottomNavItem.profile),
      },
      expect: () => [
        const BottomNavState(currentItem: BottomNavItem.profile),
      ],
    );

    blocTest<BottomNavCubit, BottomNavState>(
      'emits no state when updating to the same item',
      build: () => bottomNavCubit,
      act: (cubit) => cubit.updateItem(BottomNavItem.home),
      expect: () => [],
    );

    group('BottomNavState', () {
      test('supports value equality', () {
        expect(
          const BottomNavState(currentItem: BottomNavItem.home),
          equals(const BottomNavState(currentItem: BottomNavItem.home)),
        );
      });

      test('props contains currentItem', () {
        const state = BottomNavState(currentItem: BottomNavItem.home);
        expect(state.props, equals([BottomNavItem.home]));
      });

      test('copyWith returns new instance with updated values', () {
        const initialState = BottomNavState(currentItem: BottomNavItem.home);
        final newState = initialState.copyWith(currentItem: BottomNavItem.profile);

        expect(newState.currentItem, equals(BottomNavItem.profile));
        expect(newState, isNot(equals(initialState)));
      });

      test('copyWith returns same instance when no parameters are provided', () {
        const initialState = BottomNavState(currentItem: BottomNavItem.home);
        final newState = initialState.copyWith();

        expect(newState.currentItem, equals(initialState.currentItem));
      });
    });
  });
}