part of 'theme_cubit.dart';

class ThemeState extends Equatable {
  final ThemeMode themeMode;

  final CustomException? exception;

  const ThemeState({
    required this.themeMode,
    this.exception,
  });

  const ThemeState.initial() : this(themeMode: ThemeMode.light);

  @override
  List<Object?> get props => [themeMode, exception];

  ThemeState copyWith({
    ThemeMode? themeMode,
    CustomException? exception,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      exception: exception ?? this.exception,
    );
  }
}
