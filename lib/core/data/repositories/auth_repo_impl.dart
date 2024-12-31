import 'package:dartz/dartz.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:maple_harvest_app/core/core.dart';
import 'package:maple_harvest_app/features/features.dart';

class AuthRepoImpl with ExceptionMixin implements AuthRepository {
  final UserDatasource _userDatasource;

  final AuthDatasource _authDatasource;

  final LoggerUtils _loggerUtils;

  AuthRepoImpl({
    required UserDatasource userDatasource,
    required AuthDatasource authDatasource,
    required LoggerUtils loggerUtils,
  })  : _userDatasource = userDatasource,
        _authDatasource = authDatasource,
        _loggerUtils = loggerUtils;

  @override
  Future<Either<CustomException, CustomerResponse>> login(
          LoginRequest request) async =>
      handleFuture(() async {
        await _authDatasource.login(request);
        final user = await _userDatasource.getUser();
        return user;
      });

  @override
  Future<Either<CustomException, CustomerResponse>> signup(
      SignupRequest signupRequestModel) async {
    return handleFuture(() async {
      final response = await _authDatasource.signup(signupRequestModel);
      if (!response.success) {
        _loggerUtils.logError('authRepo', 'Signup failed');
        throw GeneralException(message: 'operationFailedMsg'.tr());
      }
      final user = await _userDatasource.getUser();
      return user;
    });
  }
}
