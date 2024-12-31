import 'package:dartz/dartz.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:maple_harvest_app/core/core.dart';

mixin ExceptionMixin {
  Future<CustomException> _mapException(Object e, [StackTrace? stack]) async {
    await sl<CrashlyticsService>().recordError(
      e,
      stack,
      fatal: true,
      reason: e is CustomException ? e.message : e.runtimeType.toString(),
      information: e is CustomException ? e.toIterable() : [],
    );

    return switch (e) {
      NetworkException() => e,
      GraphQLException() => e,
      GeneralException() => e,
      SecurityException() => e,
      UserNotFoundException() => e,
      FirebaseException() => FirebaseCustomException(
          message: e.message ?? 'defaultErrorMsg'.tr(),
          code: e.code,
        ),
      _ => GeneralException(message: e.toString()),
    };
  }

  /// Checks internet connectivity
  Future<void> _checkConnectivity() async {
    if (!await sl<ConnectivityUtils>().hasInternet) {
      throw NetworkException(message: 'noInternetMsg'.tr());
    }
  }

  /// Perform the provided action and handles exceptions
  Future<Either<CustomException, T>> handleFuture<T>(
      Future<T> Function() action) async {
    try {
      await _checkConnectivity();
      return right(await action());
    } catch (e, stack) {
      final exception = await _mapException(e, stack);
      return left(exception);
    }
  }
}
