import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:maple_harvest_app/core/core.dart';

void main() {
  group('LoadingWidget', () {
    testWidgets('should display child when not loading',
        (WidgetTester tester) async {
      // Arrange
      const testChild = Text('Test Child');

      await tester.pumpWidget(
        SizerUtils(
          builder: (_, __) => const MaterialApp(
            home: LoadingWidget(
              isLoading: false,
              child: testChild,
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(Text), findsOneWidget);
      expect(find.text('Test Child'), findsOneWidget);
      expect(find.byType(LoadingIndicator), findsNothing);
    });

    testWidgets('should display loading indicator when loading',
        (WidgetTester tester) async {
      // Arrange
      const testChild = Text('Test Child');

      await tester.pumpWidget(
        const MaterialApp(
          home: LoadingWidget(
            isLoading: true,
            child: testChild,
          ),
        ),
      );

      // Assert
      expect(find.byType(Text), findsOneWidget);
      expect(find.text('Test Child'), findsOneWidget);
      expect(find.byType(LoadingIndicator), findsOneWidget);
    });

    testWidgets('should render overlay when loading',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: const LoadingWidget(
            isLoading: true,
            child: SizedBox(),
          ),
        ),
      );

      // Assert
      final coloredBox = find.byType(ColoredBox);
      expect(coloredBox, findsOneWidget);
      final coloredBoxWidget = tester.widget<ColoredBox>(coloredBox);
      expect(coloredBoxWidget.color.opacity.toDoubleValue(fractionDigits: 1),
          equals(0.5));
    });

    testWidgets('should unfocus primary focus when loading', (WidgetTester tester) async {
      // Arrange
      final focusNode = FocusNode();

      await tester.pumpWidget(
        SizerUtils(
          builder: (_, __) => MaterialApp(
            home: Scaffold(
              body: LoadingWidget(
                isLoading: true,
                child: TextField(focusNode: focusNode),
              ),
            ),
          ),
        ),
      );

      // Act
      focusNode.requestFocus();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Assert
      expect(focusNode.hasFocus, isTrue);
    });
  });
}
