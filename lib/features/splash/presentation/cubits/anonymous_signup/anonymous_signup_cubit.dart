import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maple_harvest_app/core/core.dart';

part 'anonymous_signup_state.dart';

class AnonymousSignupCubit extends Cubit<AnonymousSignupState> {
  final AuthRepository _authRepository;

  final PrefsUtils _prefs;

  final CrashlyticsService _crashlytics;

  final AnalyticsService _analytics;

  AnonymousSignupCubit({
    required AuthRepository authRepository,
    required PrefsUtils prefsUtils,
    required CrashlyticsService crashlyticsService,
    required AnalyticsService analyticsService,
  })  : _authRepository = authRepository,
        _prefs = prefsUtils,
        _crashlytics = crashlyticsService,
        _analytics = analyticsService,
        super(const AnonymousSignupState.initial());

  /// Initiates the anonymous signup process
  Future<void> signup() async {
    if (state.status.isLoading || isClosed) return;

    try {
      emit(state.copyWith(status: RequestStatus.loading));

      final anonymousInfo = SignupRequest.createAnonymous();
      final result = await _authRepository.signup(anonymousInfo);
      await result.fold(
        (exception) async => _handleError(exception),
        (user) async => await _handleSuccess(anonymousInfo, user),
      );
    } catch (e, stackTrace) {
      await _handleFailure(e, stackTrace);
    } finally {
      if (!isClosed) {
        emit(state.copyWith(status: RequestStatus.initial));
      }
    }
  }

  /// Handles authentication errors
  void _handleError(CustomException exception) {
    if (isClosed) return;
    emit(
      state.copyWith(
        status: RequestStatus.error,
        exception: exception,
      ),
    );
  }

  /// Handles successful signup by saving credentials and updating state
  Future<void> _handleSuccess(SignupRequest info, CustomerResponse user) async {
    if (isClosed) return;

    try {
      await _prefs.setAnonymousCreds(info);
      await _analytics.setUserInfo(UserAnalyticsModel(
        isAnonymous: true,
        userId: user.id,
      ));
      await _crashlytics.setUserIdentifier(user.id);
      emit(
        state.copyWith(
          status: RequestStatus.success,
          user: user.copyWith(
            isAnonymous: await _prefs.hasAnonymousCreds,
          ),
        ),
      );
    } catch (e, stackTrace) {
      await _handleFailure(e, stackTrace);
    }
  }

  /// Handles unexpected failures during the signup process
  Future<void> _handleFailure(Object e, [StackTrace? stackTrace]) async {
    if (isClosed) return;

    try {
      // Clear the auth token if it exists
      final token = await _prefs.authToken;
      if (token.isNotEmpty) {
        await _prefs.setAuthToken(null);
      }

      _handleError(GeneralException(message: 'operationFailedMsg'.tr()));

      await _crashlytics.recordError(
        e,
        stackTrace ?? StackTrace.current,
        fatal: true,
        reason: 'Failed to sign up anonymously',
      );
    } catch (e, errorStackTrace) {
      await _crashlytics.recordError(
        e,
        errorStackTrace,
        reason: 'Error during failure handling',
      );
    }
  }
}
