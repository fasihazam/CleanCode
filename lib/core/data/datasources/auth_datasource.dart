import 'package:maple_harvest_app/core/core.dart';
import 'package:maple_harvest_app/features/features.dart';

abstract class AuthDatasource {
  Future<LoginResponse> login(LoginRequest request);

  Future<SignupResponse> signup(SignupRequest request);
}

class AuthDatasourceImpl implements AuthDatasource {
  final GraphQLService _graphQLService;

  AuthDatasourceImpl({
    required GraphQLService graphQLService,
  }) : _graphQLService = graphQLService;

  @override
  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final query = AuthOperations.login(request);

      final result = await _graphQLService.mutate(
        query,
        variables: request.toVariables(),
      );

      final loginResponse = LoginResponse.fromData(result.data);
      return loginResponse;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<SignupResponse> signup(SignupRequest request) async {
    try {
      final query = AuthOperations.signup(request);

      final result = await _graphQLService.mutate(
        query,
        variables: request.toVariables(),
      );

      final signupResponse = SignupResponse.fromData(result.data);
      return signupResponse;
    } catch (e) {
      rethrow;
    }
  }
}
