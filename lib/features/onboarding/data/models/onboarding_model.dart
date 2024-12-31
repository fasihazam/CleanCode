import 'package:equatable/equatable.dart';

class OnboardingModel extends Equatable {
  final String heading;

  final String subHeading;

  final String imagePath;

  const OnboardingModel({
    required this.heading,
    required this.subHeading,
    required this.imagePath,
  });

  @override
  List<Object?> get props => [heading, subHeading, imagePath];
}