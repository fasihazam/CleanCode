part of 'user_cubit.dart';

class UserState extends Equatable {
  final RequestStatus status;

  final CustomerResponse? user;

  final CustomException? exception;

  bool get isLoggedIn => user?.id.isNotEmpty ?? false;

  bool get isAnonymous => isLoggedIn && user!.isAnonymous;

  const UserState({
    this.status = RequestStatus.initial,
    this.user,
    this.exception,
  });

  const UserState.initial() : this();

  UserState copyWith({
    RequestStatus? status,
    CustomerResponse? user,
    CustomException? exception,
  }) {
    return UserState(
      status: status ?? this.status,
      user: user ?? this.user,
      exception: exception,
    );
  }

  @override
  List<Object?> get props => [status, user, exception];

  @override
  String toString() {
    return 'UserState { status: $status, user: $user, exception: $exception }';
  }
}
