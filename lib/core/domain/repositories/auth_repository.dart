import 'package:dartz/dartz.dart';
import 'package:maple_harvest_app/core/core.dart';
import 'package:maple_harvest_app/features/auth/data/data.dart';

abstract class AuthRepository {
  Future<Either<CustomException, CustomerResponse>> login(LoginRequest loginRequestModel);

  Future<Either<CustomException, CustomerResponse>> signup(SignupRequest signupRequestModel);
}