part of 'home_cubit.dart';

sealed class HomeState {
  final RequestStatus status;
  final String? location;
  final String? errorMessage;

  const HomeState({
    this.status = RequestStatus.initial,
    this.location,
    this.errorMessage,
  });

  List<Object?> get props => [status, location, errorMessage];
}

final class HomeInitial extends HomeState {
  const HomeInitial() : super();
}

final class HomeLoading extends HomeState {
  const HomeLoading() : super(status: RequestStatus.loading);
}

final class HomeLocationLoaded extends HomeState {
  const HomeLocationLoaded({
    required String location,
  }) : super(status: RequestStatus.success, location: location);
}

final class HomeError extends HomeState {
  const HomeError({
    required String message,
  }) : super(status: RequestStatus.error, errorMessage: message);
}
