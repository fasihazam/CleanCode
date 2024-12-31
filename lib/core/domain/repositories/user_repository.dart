import 'package:dartz/dartz.dart';
import 'package:maple_harvest_app/core/core.dart';

abstract class UserRepository {
  Future<Either<CustomException, CustomerResponse>> getUser();

  Future<Either<CustomException, bool>> logout();

  Future<Either<CustomException, void>> updateUser(CustomerRequest request);
}