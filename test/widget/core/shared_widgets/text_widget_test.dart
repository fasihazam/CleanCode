import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maple_harvest_app/core/core.dart';

void main() {
  testWidgets('TextWidget displays text correctly',
      (WidgetTester tester) async {
    const testText = 'Hello, Flutter!';
    const testStyle = TextStyle(fontSize: 20, fontWeight: FontWeight.bold);
    const testAlign = TextAlign.center;
    const testMaxLines = 2;
    const testOverflow = TextOverflow.ellipsis;

    // Build the TextWidget and trigger a frame.
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: TextWidget(
            testText,
            style: testStyle,
            textAlign: testAlign,
            maxLines: testMaxLines,
            overflow: testOverflow,
          ),
        ),
      ),
    );

    // Find the Text widget in the widget tree.
    final textFinder = find.text(testText);
    expect(textFinder, findsOneWidget);

    // Verify the text, style, alignment, maxLines, and overflow.
    final textWidget = tester.widget<Text>(textFinder);
    expect(textWidget.style, testStyle);
    expect(textWidget.textAlign, testAlign);
    expect(textWidget.maxLines, testMaxLines);
    expect(textWidget.overflow, testOverflow);
  });
}
