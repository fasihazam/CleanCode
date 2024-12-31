import 'package:flutter_test/flutter_test.dart';
import 'package:maple_harvest_app/core/core.dart';
import 'package:maple_harvest_app/features/features.dart';

void main() {
  group('AuthOperations', () {
    test('login should generate correct GraphQL mutation string', () {
      const loginRequest = LoginRequest(
        username: 'test@example.com',
        password: 'password123',
        rememberMe: true,
      );

      final query = AuthOperations.login(loginRequest);

      expect(
        query,
        '''mutation Login {
  login(username: "${loginRequest.username}", password: "${loginRequest.password}", rememberMe: ${loginRequest.rememberMe}) {
    ... on CurrentUser {
      id
      identifier
      channels {
        id
        token
        code
        permissions
      }
    }
    ... on InvalidCredentialsError {
      errorCode
      message
      authenticationError
    }
    ... on NotVerifiedError {
      errorCode
      message
    }
    ... on NativeAuthStrategyError {
      errorCode
      message
    }
  }
}''',
      );
    });

    test('login should handle minimal login request', () {
      const loginRequest = LoginRequest(
        username: 'test@example.com',
        password: 'password123',
        rememberMe: false,
      );

      final query = AuthOperations.login(loginRequest);

      expect(query, contains('username: "${loginRequest.username}"'));
      expect(query, contains('password: "${loginRequest.password}"'));
      expect(query, contains('rememberMe: ${loginRequest.rememberMe}'));
    });

    test('login should include all possible response types', () {
      const loginRequest = LoginRequest(
        username: 'test@example.com',
        password: 'password123',
        rememberMe: true,
      );

      final query = AuthOperations.login(loginRequest);

      expect(query, contains('... on CurrentUser {'));
      expect(query, contains('... on InvalidCredentialsError {'));
      expect(query, contains('... on NotVerifiedError {'));
      expect(query, contains('... on NativeAuthStrategyError {'));
    });

    test('login should include required CurrentUser fields', () {
      const loginRequest = LoginRequest(
        username: 'test@example.com',
        password: 'password123',
        rememberMe: true,
      );

      final query = AuthOperations.login(loginRequest);

      expect(query, contains('id'));
      expect(query, contains('identifier'));
      expect(query, contains('channels {'));
      expect(query, contains('token'));
      expect(query, contains('code'));
      expect(query, contains('permissions'));
    });

    test('login should include error fields in error types', () {
      const loginRequest = LoginRequest(
        username: 'test@example.com',
        password: 'password123',
        rememberMe: true,
      );

      final query = AuthOperations.login(loginRequest);

      expect(
        query,
        contains('''... on InvalidCredentialsError {
      errorCode
      message
      authenticationError
    }'''),
      );

      for (final errorType in ['NotVerifiedError', 'NativeAuthStrategyError']) {
        expect(
          query,
          contains('''... on $errorType {
      errorCode
      message
    }'''),
        );
      }
    });
  });
}
