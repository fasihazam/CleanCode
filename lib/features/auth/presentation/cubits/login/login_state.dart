part of 'login_cubit.dart';

class LoginState extends Equatable {
  final RequestStatus status;

  final CustomException? exception;

  final CustomerResponse? user;

  const LoginState({
    this.status = RequestStatus.initial,
    this.exception,
    this.user,
  });

  const LoginState.initial() : this();

  LoginState copyWith({
    RequestStatus? status,
    CustomException? exception,
    CustomerResponse? user,
  }) {
    return LoginState(
      status: status ?? this.status,
      exception: exception ?? this.exception,
      user: user ?? this.user,
    );
  }

  @override
  List<Object?> get props => [status, exception, user];
}
