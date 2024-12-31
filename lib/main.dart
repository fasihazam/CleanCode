import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maple_harvest_app/core/core.dart';
import 'package:maple_harvest_app/firebase_options.dart';

Future<void> main() async {
  // runZonedGuarded ensures that errors are caught even in async operations
  await runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Ensure localization is initialized
    await EasyLocalization.ensureInitialized();

    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Lock the orientation to portrait only
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    // Initialize DI (Dependency Injection)
    await Injection.init();

    // Run the app
    runApp(
      MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => ThemeCubit(prefs: sl()),
          ),
          BlocProvider(
              create: (_) => UserCubit(
                    userRepository: sl(),
                    crashlyticsService: sl(),
                    analyticsService: sl(),
                    prefsUtils: sl(),
                  )),
          BlocProvider(
            create: (_) => BottomNavCubit(),
          ),
        ],
        child: EasyLocalization(
          supportedLocales: const [Locale('en')],
          path: 'assets/translations',
          fallbackLocale: const Locale('en'),
          child: MyApp(
            appRouter: sl<AppRouter>(),
          ),
        ),
      ),
    );
  }, (error, stackTrace) async {
    // If an error occurs during initialization, report it to Firebase Crashlytics
    if (sl.isRegistered<FirebaseCrashlytics>()) {
      sl<FirebaseCrashlytics>().recordError(error, stackTrace);
    } else {
      await FirebaseCrashlytics.instance.recordError(error, stackTrace);
    }

    // Log the error
    sl<LoggerUtils>()
        .logError('Failed to initialize app', '$error\n$stackTrace');
  });
}

class MyApp extends StatelessWidget {
  final AppRouter appRouter;

  const MyApp({
    super.key,
    required this.appRouter,
  });

  @override
  Widget build(BuildContext context) {
    return SizerUtils(
      builder: (context, orientation) {
        // Hide keyboard when user taps outside of text fields
        return GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: BlocBuilder<ThemeCubit, ThemeState>(
            builder: (context, state) {
              return MaterialApp.router(
                debugShowCheckedModeBanner: false,
                title: AppStrings.appName,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                routerConfig: appRouter.router,
                localizationsDelegates: context.localizationDelegates,
                locale: context.locale,
                supportedLocales: context.supportedLocales,
                themeMode: state.themeMode,
              );
            },
          ),
        );
      },
    );
  }
}
