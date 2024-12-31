import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:maple_harvest_app/core/config/config.dart';
import 'package:maple_harvest_app/features/home/home.dart';

enum RequestStatus {
  initial,
  loading,
  success,
  error,
}

enum RequestMethod {
  get,
  post,
  put,
  delete,
}

enum GraphQLErrorType {
  unknown,
  generalError,
  invalidCredentialsError,
  notVerifiedError,
  nativeAuthStrategyError,
  invalidOperation,
  malformedToken,
  ;

  factory GraphQLErrorType.fromString(String? type) {
    return switch (type) {
      'InvalidCredentialsError' => GraphQLErrorType.invalidCredentialsError,
      'NotVerifiedError' => GraphQLErrorType.notVerifiedError,
      'NativeAuthStrategyError' => GraphQLErrorType.nativeAuthStrategyError,
      'InvalidOperationError' => GraphQLErrorType.invalidOperation,
      'GeneralError' => GraphQLErrorType.generalError,
      'MalformedToken' => GraphQLErrorType.malformedToken,
      _ => GraphQLErrorType.unknown,
    };
  }
}

enum AlertType {
  success(Icons.check),
  error(Icons.error_outline),
  info(Icons.info_outline);

  final IconData icon;

  const AlertType(this.icon);
}

enum OperationType {
  mutation,
  query,
}

enum OperationName {
  login('Login'),
  signup('RegisterCustomerAccount'),
  user('ActiveCustomer'),
  updateCustomer('UpdateCustomer'),
  ;

  final String name;

  const OperationName(this.name);
}

enum AnalyticsEventType {
  // Auth Events
  login('login'),
  loginSuccess('login_success'),
  loginFailure('login_failure'),
  logout('logout'),
  signup('signup'),

  // User Events
  fetchUser('fetch_user'),
  fetchUserSuccess('fetch_user_success'),
  fetchUserFailure('fetch_user_failure'),

  // Onboarding Events
  onboardingStart('onboarding_start'),
  onboardingComplete('onboarding_complete'),

  // Cart Events
  addToCart('add_to_cart'),
  removeFromCart('remove_from_cart'),
  checkout('checkout'),
  checkoutStart('checkout_start'),
  checkoutComplete('checkout_complete'),

  // Product Events
  viewProduct('view_product'),
  viewProductList('view_product_list'),
  productSearch('product_search'),

  // Restaurant Events
  viewRestaurant('view_restaurant'),
  viewRestaurantList('view_restaurant_list'),
  restaurantSearch('restaurant_search'),

  // Permission Events
  permissionFailure('permission_failure'),
  permissionSuccess('permission_success'),

  // Adding semi-colon for easy adding of new events above
  ;

  const AnalyticsEventType(this.name);

  final String name;
}

enum AttackType { injectionAttempt }

enum BottomNavItem {
  home(
    iconPath: Assets.imagesHome,
    child: HomeWidget(),
  ),
  favorite(
    iconPath: Assets.imagesFavorite,
    child: FavoriteWidget(),
  ),
  orders(
    iconPath: Assets.imagesList,
    child: OrdersWidget(),
  ),
  profile(
    iconPath: Assets.imagesUser,
    child: ProfileWidget(),
  );

  String get label {
    switch (this) {
      case BottomNavItem.home:
        return 'home'.tr();
      case BottomNavItem.favorite:
        return 'favorite'.tr();
      case BottomNavItem.orders:
        return 'orders'.tr();
      case BottomNavItem.profile:
        return 'profile'.tr();
    }
  }

  final String iconPath;

  final Widget child;

  const BottomNavItem({
    required this.iconPath,
    required this.child,
  });
}
