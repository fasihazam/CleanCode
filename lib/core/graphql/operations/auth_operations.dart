import 'package:maple_harvest_app/core/core.dart';
import 'package:maple_harvest_app/features/features.dart';

class AuthOperations {
  static String login(LoginRequest request) {
    final mutation = GraphQLQueryBuilder(
      operationName: OperationName.login.name,
      operationType: OperationType.mutation,
      fields: {
        NetworkConstants.loginKey: MutationFieldModel(
          name: NetworkConstants.loginKey,
          variables: request.toVariables(),
          possibleResponses: [
            LoginResponse(),
            const InvalidCredentialsError(),
            const NotVerifiedError(),
            const NativeAuthStrategyError(),
          ],
        ),
      },
    );

    return mutation.build();
  }

  static String signup(SignupRequest request) {
    final mutation = GraphQLQueryBuilder(
      operationName: OperationName.signup.name,
      operationType: OperationType.mutation,
      fields: {
        NetworkConstants.registerCustomerAccountKey: MutationFieldModel(
          name: NetworkConstants.registerCustomerAccountKey,
          variables: request.toVariables(),
          possibleResponses: [
            SignupResponse(),
            const MissingPasswordError(),
            const PasswordValidationError(),
            const NativeAuthStrategyError(),
          ],
        ),
        NetworkConstants.loginKey: MutationFieldModel(
          name: NetworkConstants.loginKey,
          variables: LoginRequest.fromSignupRequest(request).toVariables(),
          possibleResponses: [
            LoginResponse(),
            const InvalidCredentialsError(),
            const NotVerifiedError(),
            const NativeAuthStrategyError(),
          ],
        ),
      },
    );

    return mutation.build();
  }

  AuthOperations._();
}
