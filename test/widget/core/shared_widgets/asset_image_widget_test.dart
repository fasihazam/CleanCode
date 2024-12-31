import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:maple_harvest_app/core/core.dart';

void main() {
  group('AssetImageWidget', () {
    testWidgets('should display SVG image when path ends with .svg', (WidgetTester tester) async {
      // Arrange
      const testPath = 'assets/images/test.svg';

      await tester.pumpWidget(
        const MaterialApp(
          home: AssetImageWidget(
            path: testPath,
            width: 100,
            height: 100,
          ),
        ),
      );

      // Assert
      expect(find.byType(SvgPicture), findsOneWidget);
    });

    testWidgets('should display regular image when path does not end with .svg', (WidgetTester tester) async {
      // Arrange
      const testPath = 'assets/images/app_icon.png';

      await tester.pumpWidget(
        const MaterialApp(
          home: AssetImageWidget(
            path: testPath,
            width: 100,
            height: 100,
          ),
        ),
      );

      // Assert
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('should apply the correct width, height, and color filter', (WidgetTester tester) async {
      // Arrange
      const testPath = 'assets/images/test.svg';
      const testColor = Colors.red;

      await tester.pumpWidget(
        const MaterialApp(
          home: AssetImageWidget(
            path: testPath,
            width: 100,
            height: 100,
            color: testColor,
          ),
        ),
      );

      // Assert
      final svgPicture = tester.widget<SvgPicture>(find.byType(SvgPicture));
      expect(svgPicture.width, 100);
      expect(svgPicture.height, 100);
      expect(svgPicture.colorFilter, isNotNull);
    });

    testWidgets('should handle tap gesture', (WidgetTester tester) async {
      // Arrange
      bool wasTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: AssetImageWidget(
            path: 'assets/images/app_icon.png',
            onTap: () {
              wasTapped = true;
            },
          ),
        ),
      );

      // Act
      await tester.tap(find.byType(AssetImageWidget));
      await tester.pumpAndSettle();

      // Assert
      expect(wasTapped, isTrue);
    });
  });
}
