import 'package:dartz/dartz.dart';
import 'package:maple_harvest_app/core/core.dart';

class UserRepoImpl with ExceptionMixin implements UserRepository {
  final UserDatasource _userDatasource;

  UserRepoImpl(this._userDatasource);

  @override
  Future<Either<CustomException, CustomerResponse>> getUser() async =>
      await handleFuture(() async {
        final user = await _userDatasource.getUser();
        return user;
      });

  @override
  Future<Either<CustomException, bool>> logout() async => await handleFuture(() async {
    return await _userDatasource.logout();
  });

  @override
  Future<Either<CustomException, void>> updateUser(CustomerRequest request) async =>
      await handleFuture(() async {
        await _userDatasource.updateUser(request);
      });
}
