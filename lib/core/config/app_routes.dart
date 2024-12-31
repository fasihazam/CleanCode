class AppRoutes {
  static const root = '/';

  static const onboarding = '/onboarding';

  static const location = '/location';

  static const locateme = '/locateme';

  static const auth = '/auth';

  // auth sub-routes
  static const login = '$auth/login';

  static const home = '/home';

  // home sub-routes
  static const notifications = '$home/notifications';

  AppRoutes._();
}
