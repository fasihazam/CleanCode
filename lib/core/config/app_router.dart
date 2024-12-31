import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:maple_harvest_app/core/core.dart';
import 'package:maple_harvest_app/features/features.dart';

import '../../features/location/data/models/location_arguments_model.dart';

class AppRouter {
  final GlobalKey<NavigatorState> _navigatorKey;
  late final GoRouter _router;

  AppRouter({
    GlobalKey<NavigatorState>? navigatorKey,
  }) : _navigatorKey = navigatorKey ?? GlobalKey<NavigatorState>() {
    _router = GoRouter(
      debugLogDiagnostics: kDebugMode,
      navigatorKey: _navigatorKey,
      initialLocation: AppRoutes.root,
      errorBuilder: (context, state) => const NotFoundPage(),
      routes: _routes,
    );
  }

  GoRouter get router => _router;

  GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;

  List<RouteBase> get _routes => [
        GoRoute(
          path: AppRoutes.root,
          name: AppRoutes.root,
          builder: (context, state) => const SplashPage(),
        ),
        GoRoute(
          path: AppRoutes.onboarding,
          name: AppRoutes.onboarding,
          builder: (context, state) => const OnboardingPage(),
        ),
        ShellRoute(
          restorationScopeId: AppRoutes.auth,
          builder: (_, __, ___) => const LoginPage(),
          routes: [
            GoRoute(
              name: AppRoutes.login,
              path: AppRoutes.login,
              builder: (context, state) => const LoginPage(),
            ),
          ],
        ),
        ShellRoute(
          restorationScopeId: AppRoutes.home,
          builder: (_, __, child) => child,
          routes: [
            GoRoute(
              path: AppRoutes.home,
              name: AppRoutes.home,
              builder: (context, state) {
                String location = '';

                if (state.extra != null &&
                    state.extra is Map<String, dynamic>) {
                  try {
                    final locationArgs = LocationArguments.fromJson(
                        state.extra as Map<String, dynamic>);
                    location = locationArgs.location;
                  } catch (e) {
                    debugPrint("Error parsing location arguments: $e");
                  }
                }

                return BlocProvider(
                  create: (_) =>
                      HomeCubit(sl<PrefsUtils>())..initializeLocation(location),
                  child: HomePage(location: location),
                );
              },
              routes: [
                GoRoute(
                  path: _getSubRoutePath(AppRoutes.notifications),
                  name: AppRoutes.notifications,
                  builder: (context, state) => const NotificationPage(),
                ),
              ],
            ),
            GoRoute(
              path: AppRoutes.location,
              name: AppRoutes.location,
              builder: (context, state) {
                bool isFromHome = false;
                if (state.extra != null && state.extra is bool) {
                  isFromHome =
                      state.extra is bool ? state.extra as bool : false;
                }

                return AddressScreen(
                  isFromHome: isFromHome,
                );
              },
            ),
            GoRoute(
              path: AppRoutes.locateme,
              name: AppRoutes.locateme,
              builder: (context, state) => const LocateMeScreen(),
            ),
          ],
        ),
      ];

  static String _getSubRoutePath(String route) {
    if (!route.contains('/')) return route;

    return route.split('/').last;
  }

  void goToHome(BuildContext context) => context.goNamed(AppRoutes.home);

  void goToOnboarding(BuildContext context) =>
      context.goNamed(AppRoutes.onboarding);

  void goToLogin(BuildContext context) => context.goNamed(AppRoutes.login);
}
