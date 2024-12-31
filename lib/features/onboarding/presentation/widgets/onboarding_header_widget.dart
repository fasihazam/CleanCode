import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:maple_harvest_app/core/core.dart';

class OnboardingHeaderWidget extends HookWidget {
  final String text;
  final AnimationController animationController;

  const OnboardingHeaderWidget({
    super.key,
    required this.text,
    required this.animationController,
  });

  @override
  Widget build(BuildContext context) {
    final highlightPattern = RegExp(r'<highlight>(.*?)</highlight>');
    final match = highlightPattern.firstMatch(text);

    if (match == null) {
      return Center(
        child: TextWidget(
          text,
          style: context.textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
      );
    }

    final beforeHighlight = text.substring(0, match.start);
    final highlightText = match.group(1) ?? '';
    final afterHighlight = text.substring(match.end);

    // Calculate circle radius based on text length
    double calculateRadius() {
      // Base radius for single character
      final baseRadius = 30.r;

      // Additional radius per character (decreasing for longer text)
      final additionalRadiusPerChar = 8.r;

      // Maximum radius to prevent circle from getting too large
      final maxRadius = 45.r;

      // Calculate radius based on text length with diminishing returns
      final calculatedRadius = baseRadius +
          (highlightText.length > 1
              ? additionalRadiusPerChar * log(highlightText.length)
              : 0);

      return min(calculatedRadius, maxRadius);
    }

    return Center(
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: context.textTheme.titleLarge,
          children: [
            if (beforeHighlight.isNotEmpty) TextSpan(text: beforeHighlight),
            if (highlightText.isNotEmpty)
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Background circle
                    Positioned(
                      child: CircleAvatar(
                        radius: calculateRadius(),
                        backgroundColor:
                            context.colorScheme.primary,
                      ),
                    ),
                    // Highlighted text
                    TextWidget(
                      highlightText,
                      style: context.textTheme.titleLarge?.copyWith(
                        color: context.colorScheme.onPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            if (afterHighlight.isNotEmpty) TextSpan(text: afterHighlight),
          ],
        ),
      ),
    );
  }
}
