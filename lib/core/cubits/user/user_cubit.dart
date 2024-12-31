import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maple_harvest_app/core/core.dart';

part 'user_state.dart';

/// The [UserCubit] is responsible for managing the user state
/// It fetches the user details and logs out the user
class UserCubit extends Cubit<UserState> {
  final UserRepository _userRepository;

  final CrashlyticsService _crashlytics;

  final AnalyticsService _analytics;

  final PrefsUtils _prefs;

  UserCubit({
    required UserRepository userRepository,
    required CrashlyticsService crashlyticsService,
    required AnalyticsService analyticsService,
    required PrefsUtils prefsUtils,
  })  : _userRepository = userRepository,
        _crashlytics = crashlyticsService,
        _analytics = analyticsService,
        _prefs = prefsUtils,
        super(const UserState.initial());

  /// Fetches the user details
  Future<void> fetchUser() async {
    if (state.status.isLoading || isClosed) return;

    try {
      emit(state.copyWith(status: RequestStatus.loading));

      await _analytics.logEvent(AnalyticsEventType.fetchUser);
      final result = await _userRepository.getUser();
      await result.fold(
        (exception) async => await _handleError(exception),
        (user) async => await _handleSuccess(user),
      );
    } catch (e, stackTrace) {
      await _handleFailure(e, stackTrace);
    } finally {
      if (!isClosed) {
        emit(state.copyWith(status: RequestStatus.initial));
      }
    }
  }

  Future<void> _handleError(CustomException exception) async {
    if (isClosed) return;

    try {
      await _analytics.logEvent(
        AnalyticsEventType.fetchUserFailure,
        customParams: {
          AnalyticsParamsModel.errorInfoKey: exception.toString(),
        }
      );

      if (exception is UserNotFoundException) {
        await _prefs.clearAnonymousCreds();
        await _prefs.setAuthToken(null);
      }

      emit(
        state.copyWith(
          status: RequestStatus.error,
          exception: exception,
        ),
      );
    } catch (e, stack) {
      await _handleFailure(e, stack);
    }
  }

  Future<void> _handleSuccess(CustomerResponse user) async {
    if (isClosed) return;

    try {
      final isAnonymous = await _prefs.hasAnonymousCreds;

      await Future.wait([
        _analytics.setUserInfo(UserAnalyticsModel(
          userId: user.id,
          isAnonymous: isAnonymous,
        )),
        _crashlytics.setUserIdentifier(user.id),
        _analytics.logEvent(AnalyticsEventType.fetchUserSuccess),
      ]);

      emit(
        state.copyWith(
          status: RequestStatus.success,
          user: user.copyWith(
            isAnonymous: isAnonymous,
          ),
        ),
      );
    } catch (e, stackTrace) {
      await _handleFailure(e, stackTrace);
    }
  }

  Future<void> _handleFailure(Object e, StackTrace stackTrace) async =>
      await _crashlytics.recordError(e, stackTrace);

  Future<void> logout() async {
    if (state.status.isLoading || isClosed) return;

    try {
      emit(state.copyWith(status: RequestStatus.loading));
      final result = await _userRepository.logout();
      await result.fold(
        (exception) {
          emit(
            state.copyWith(
              status: RequestStatus.error,
              exception: GeneralException(
                message: 'unableToLogout'.tr(),
              ),
            ),
          );
        },
        (_) async {
          await Future.wait([
            _analytics.logEvent(AnalyticsEventType.logout),
            _analytics.removeUserInfo(),
            _crashlytics.setUserIdentifier(null),
          ]);
          emit(const UserState.initial());
        },
      );
    } catch (e, stackTrace) {
      await _handleFailure(e, stackTrace);
    } finally {
      if (!isClosed) {
        emit(state.copyWith(status: RequestStatus.initial));
      }
    }
  }

  void updateCustomer(CustomerResponse user) {
    emit(state.copyWith(user: user));
  }
}
