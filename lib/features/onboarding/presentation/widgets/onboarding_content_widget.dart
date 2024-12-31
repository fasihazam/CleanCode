import 'package:flutter/material.dart';
import 'package:maple_harvest_app/core/core.dart';
import 'package:maple_harvest_app/features/features.dart';

class OnboardingContentWidget extends StatelessWidget {
  final OnboardingModel onboarding;
  final Widget header;

  const OnboardingContentWidget({
    required this.onboarding,
    required this.header,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AssetImageWidget(
          path: onboarding.imagePath,
          width: context.width,
          height: context.height * 0.50,
          fit: BoxFit.contain,
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: 30.h,
                horizontal: Dimens.pageHorizontalPadding,
              ),
              child: Column(
                children: [
                  header,
                  SpacerWidget(height: 40.h),
                  TextWidget(
                    onboarding.subHeading,
                    textAlign: TextAlign.center,
                    style: context.textTheme.labelLarge?.copyWith(
                      color: AppColors.onboardingSubHeading,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
