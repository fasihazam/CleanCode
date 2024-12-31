import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:maple_harvest_app/core/core.dart';
import 'package:maple_harvest_app/features/features.dart';


class LoginPage extends BaseStatelessWidget {
  const LoginPage({super.key});

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.onPrimary,
      body: BlocProvider<LoginCubit>(
        create: (_) => LoginCubit(
          authRepository: sl(),
          prefsUtils: sl(),
          crashlyticsService: sl(),
          analyticsService: sl(),
          loggerUtils: sl(),
        ),
        child: const _LoginContent(),
      ),
    );
  }
}

class _LoginContent extends HookWidget {
  const _LoginContent();

  @override
  Widget build(BuildContext context) {
    final emailController =
        useTextEditingController(text: 'testing@testing.com');
    final passwordController = useTextEditingController(text: '123456');

    final formKey = useMemoized(() => GlobalKey<FormState>());

    return BlocConsumer<LoginCubit, LoginState>(
        listener: _loginCubitListener,
        builder: (context, state) {
          return LoadingWidget(
            isLoading: state.status.isLoading,
            child: Form(
              key: formKey,
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Login',
                        style: context.textTheme.titleMedium,
                      ),
                      SizedBox(height: 20.h),
                      TextFormField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: 'email'.tr(),
                        ),
                        validator: (value) {
                          if (value?.isEmpty ?? false) {
                            return 'Email required';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 10.h),
                      TextFormField(
                        controller: passwordController,
                        decoration: InputDecoration(
                          labelText: 'password'.tr(),
                        ),
                        validator: (value) {
                          if (value?.isEmpty ?? false) {
                            return 'Password required';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20.h),
                      ElevatedButton(
                        onPressed: () async {
                          if (formKey.currentState?.validate() == false) return;
                          // implementing for testing
                          if (!context.mounted) return;
                          await context.read<LoginCubit>().login(LoginRequest(
                                username: emailController.text,
                                password: passwordController.text,
                              ));
                        },
                        child: const Text('Login'),
                      ),
                      if (state.exception != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            state.exception!.message,
                            style: context.textTheme.bodySmall?.copyWith(
                              color: context.colorScheme.error,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

  void _loginCubitListener(BuildContext context, LoginState state) async {
    if (state.status.hasError) {
      sl<ToastUtils>().showErrorToast(
          state.exception?.message ?? 'operationFailedMsg'.tr());
      return;
    }

    final user = state.user;
    if (state.status.isSuccess && user != null) {
      context
          .read<UserCubit>()
          .updateCustomer(user.copyWith(isAnonymous: false));
      context.goToHome();
      return;
    }
  }
}
