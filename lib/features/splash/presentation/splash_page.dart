import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:maple_harvest_app/core/core.dart';

import 'cubits/anonymous_signup/anonymous_signup_cubit.dart';

class SplashPage extends BaseHookWidget {
  const SplashPage({super.key});

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.primary,
      body: BlocProvider<AnonymousSignupCubit>(
        create: (_) => AnonymousSignupCubit(
          authRepository: sl(),
          prefsUtils: sl(),
          crashlyticsService: sl(),
          analyticsService: sl(),
        ),
        child: _ContentWidget(),
      ),
    );
  }
}

class _ContentWidget extends HookWidget {
  static const _maxRetryAttempts = 2;

  @override
  Widget build(BuildContext context) {
    final opacity = useState(0.0);
    final retryCount = useRef(0);

    const animDuration = Duration(milliseconds: 500);

    useEffect(() {
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      );

      Future.delayed(animDuration, () {
        opacity.value = 1.0;

        // add a delay to show the splash screen for a while
        // because the api response is too fast
        Future.delayed(const Duration(seconds: 1), () async {
          if (!context.mounted) return;
          await _startNavigation(context, retryCount);
        });
      });

      return () {
        SystemChrome.restoreSystemUIOverlays();
      };
    }, []);

    return MultiBlocListener(
      listeners: [
        BlocListener<AnonymousSignupCubit, AnonymousSignupState>(
          listener: _signupCubitListener,
        ),
        BlocListener<UserCubit, UserState>(
          listener: (context, state) =>
              _userCubitListener(context, state, retryCount),
        ),
      ],
      child: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(Assets.imagesSplashBg),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned.fill(
            child: Center(
              child: AnimatedOpacity(
                duration: animDuration,
                opacity: opacity.value,
                child: AssetImageWidget(
                  path: Assets.imagesSplashLogo,
                  height: 200.h,
                  width: 200.w,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          // No need to handle visibility based on state
          // as the loader will be shown only for a short time
          Positioned(
            left: 0,
            right: 0,
            bottom: Platform.isAndroid ? 20.h : 40.h,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedOpacity(
                  opacity: opacity.value,
                  duration: animDuration,
                  child: LoadingWidget.loaderChild(
                    context,
                    size: 30.adaptSize,
                    color: context.colorScheme.onPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Navigate to the home page or onboarding page based on user's onboarding status
  void _navigate(BuildContext context) {
    if (sl<PrefsUtils>().hasVisitedOnboarding) {
      context.goToHome();
      return;
    }

    context.goToOnboarding();
  }

  /// Start the navigation process
  /// If the user is already logged in, navigate to the home page
  /// If the user is not logged in, navigate to the onboarding page
  Future<void> _startNavigation(
      BuildContext context, ObjectRef<int> retryCount) async {
    String token = await sl<PrefsUtils>().authToken;

    if (!context.mounted) return;
    if (token.isNotEmpty) {
      // User is already logged in
      await context.read<UserCubit>().fetchUser();
      return;
    }
    // User is not logged in
    retryCount.value++;
    context.read<AnonymousSignupCubit>().signup();
  }

  Future<void> _signupCubitListener(
      BuildContext context, AnonymousSignupState state) async {
    if (state.status.hasError) {
      sl<ToastUtils>().showErrorToast(
          state.exception?.message ?? 'operationFailedMsg'.tr());
      return;
    }

    if (state.status.isSuccess && state.user != null) {
      if (!context.mounted) return;
      context.read<UserCubit>().updateCustomer(state.user!);
      _navigate(context);
      return;
    }
  }

  Future<void> _userCubitListener(
      BuildContext context, UserState state, ObjectRef<int> retryCount) async {
    if (state.status.hasError) {
      // If the user is not logged in, start the anonymous signup process
      if (retryCount.value < _maxRetryAttempts) {
        await _startNavigation(context, retryCount);
        return;
      } else {
        sl<ToastUtils>().showErrorToast('operationFailedMsg'.tr());
        return;
      }
    }

    if (state.status.isSuccess) {
      _navigate(context);
      return;
    }
  }
}
