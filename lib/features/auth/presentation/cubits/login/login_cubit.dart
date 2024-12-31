import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maple_harvest_app/core/core.dart';
import 'package:maple_harvest_app/features/features.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final AuthRepository _authRepository;

  final PrefsUtils _prefs;

  final CrashlyticsService _crashlytics;

  final AnalyticsService _analytics;

  final LoggerUtils _logger;

  LoginCubit({
    required AuthRepository authRepository,
    required PrefsUtils prefsUtils,
    required CrashlyticsService crashlyticsService,
    required AnalyticsService analyticsService,
    required LoggerUtils loggerUtils,
  })  : _authRepository = authRepository,
        _prefs = prefsUtils,
        _crashlytics = crashlyticsService,
        _analytics = analyticsService,
        _logger = loggerUtils,
        super(const LoginState.initial());

  Future<void> login(LoginRequest request) async {
    if (state.status.isLoading || isClosed) return;

    emit(state.copyWith(status: RequestStatus.loading));
    try {
      await _analytics.logEvent(AnalyticsEventType.login);
      final response = await _authRepository.login(request);
      await response.fold(_handleFailure, _handleSuccess);
    } catch (e, stackTrace) {
      await _recordError(e, stackTrace);
      emit(state.copyWith(
          status: RequestStatus.error,
          exception: GeneralException(message: 'operationFailedMsg'.tr())));
    } finally {
      emit(state.copyWith(status: RequestStatus.initial));
    }
  }

  Future<void> _recordError(dynamic e, StackTrace stack) async {
    await _crashlytics.recordError(
      e,
      stack,
      fatal: false,
      reason: 'Failed to login',
    );
  }

  Future<void> _handleSuccess(CustomerResponse user) async {
    if (isClosed) return;
    try {
      await Future.wait([
        _prefs.clearAnonymousCreds(),
        _crashlytics.setUserIdentifier(user.id),
        _analytics.setUserInfo(UserAnalyticsModel(userId: user.id)),
        _analytics.logEvent(AnalyticsEventType.loginSuccess),
      ]);

      emit(state.copyWith(status: RequestStatus.success, user: user));
    } catch (e, stack) {
      _logger.logError(
          'Failed to save user data to analytics and crashlytics', '$e');
      await _recordError(e, stack);
      // log out the user and show the error
      emit(const LoginState.initial().copyWith(
        status: RequestStatus.error,
        exception: GeneralException(message: 'operationFailedMsg'.tr()),
      ));
    }
  }

  Future<void> _handleFailure(CustomException exception) async {
    if (isClosed) return;
    await _analytics.logEvent(AnalyticsEventType.loginFailure);
    emit(const LoginState.initial()
        .copyWith(status: RequestStatus.error, exception: exception));
  }
}
