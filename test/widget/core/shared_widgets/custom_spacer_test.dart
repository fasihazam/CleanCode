import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maple_harvest_app/core/core.dart';

void main() {
  group('CustomSpacer', () {
    testWidgets('should render SizedBox with correct height', (WidgetTester tester) async {
      // Arrange
      const testHeight = 50.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: SpacerWidget(
            height: testHeight,
          ),
        ),
      );

      // Assert
      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox));
      expect(sizedBox.height, testHeight);
      expect(sizedBox.width, isNull);
    });

    testWidgets('should render SizedBox with correct width', (WidgetTester tester) async {
      // Arrange
      const testWidth = 100.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: SpacerWidget(
            width: testWidth,
          ),
        ),
      );

      // Assert
      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox));
      expect(sizedBox.width, testWidth);
      expect(sizedBox.height, isNull);
    });

    testWidgets('should render SizedBox with correct height and width', (WidgetTester tester) async {
      // Arrange
      const testHeight = 50.0;
      const testWidth = 100.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: SpacerWidget(
            height: testHeight,
            width: testWidth,
          ),
        ),
      );

      // Assert
      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox));
      expect(sizedBox.height, testHeight);
      expect(sizedBox.width, testWidth);
    });
  });
}
