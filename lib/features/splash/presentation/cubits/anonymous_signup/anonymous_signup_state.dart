part of 'anonymous_signup_cubit.dart';

class AnonymousSignupState extends Equatable {
  final RequestStatus status;

  final CustomException? exception;

  final CustomerResponse? user;

  const AnonymousSignupState({
    this.status = RequestStatus.initial,
    this.exception,
    this.user,
  });

  const AnonymousSignupState.initial() : this();

  AnonymousSignupState copyWith({
    RequestStatus? status,
    CustomException? exception,
    CustomerResponse? user,
  }) {
    return AnonymousSignupState(
      status: status ?? this.status,
      exception: exception ?? this.exception,
      user: user ?? this.user,
    );
  }

  @override
  List<Object?> get props => [status, exception, user];

  @override
  String toString() {
    return 'AnonymousSignupState(status: $status, exception: $exception, user: $user)';
  }
}
