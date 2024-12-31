import 'package:equatable/equatable.dart';
import 'package:maple_harvest_app/core/core.dart';

class LoginRequest extends Equatable {
  static const String usernameKey = 'username';
  static const String passwordKey = 'password';
  static const String rememberMeKey = 'rememberMe';

  final String username;

  final String password;

  final bool rememberMe;

  const LoginRequest({
    required this.username,
    required this.password,
    this.rememberMe = false,
  });

  LoginRequest.fromSignupRequest(SignupRequest request)
      : username = request.emailAddress,
        password = request.password,
        rememberMe = true;

  Map<String, dynamic> toVariables() => {
        usernameKey: username,
        passwordKey: password,
        rememberMeKey: rememberMe,
      };

  factory LoginRequest.fromMap(Map<String, dynamic> map) => LoginRequest(
        username: map.getString(usernameKey),
        password: map.getString(passwordKey),
        rememberMe: map.getBool(rememberMeKey),
      );

  @override
  List<Object?> get props => [username, password, rememberMe];
}
