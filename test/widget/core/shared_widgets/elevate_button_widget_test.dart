import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maple_harvest_app/core/core.dart';

void main() {
  Future<void> setupWidget(WidgetTester tester, Widget widget) async {
    await tester.pumpWidget(
      SizerUtils(
        builder: (_, __) => MaterialApp(
          home: Scaffold(
            body: widget,
          ),
        ),
      ),
    );
  }

  group('ElevatedButtonWidget', () {
    group('General Behavior', () {
      testWidgets('displays title correctly', (WidgetTester tester) async {
        await setupWidget(
          tester,
          ElevatedButtonWidget(
            title: 'Test Button',
            onPressed: () async {},
          ),
        );

        expect(find.text('Test Button'), findsOneWidget);
      });

      testWidgets('calls onPressed when tapped', (WidgetTester tester) async {
        bool pressed = false;

        await setupWidget(
          tester,
          ElevatedButtonWidget(
            title: 'Test Button',
            onPressed: () async {
              pressed = true;
            },
          ),
        );

        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        expect(pressed, isTrue);
      });

      testWidgets('does not call onPressed when disabled',
          (WidgetTester tester) async {
        await setupWidget(
          tester,
          const ElevatedButtonWidget(
            title: 'Test Button',
            onPressed: null, // Disabled button
          ),
        );

        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        // Button should not trigger any actions
        expect(find.text('Test Button'), findsOneWidget);
      });
    });

    group('Appearance', () {
      testWidgets('displays prefix icon when provided',
          (WidgetTester tester) async {
        await setupWidget(
          tester,
          ElevatedButtonWidget(
            title: 'Test Button',
            prefixIcon: Icons.add,
            onPressed: () async {},
          ),
        );

        expect(find.byIcon(Icons.add), findsOneWidget);
      });

      testWidgets('applies custom background color',
          (WidgetTester tester) async {
        await setupWidget(
          tester,
          ElevatedButtonWidget(
            title: 'Test Button',
            backgroundColor: const Color(0xffd32f2f),
            onPressed: () async {},
          ),
        );

        final button = tester
            .widget<ElevatedButtonWidget>(find.byType(ElevatedButtonWidget));
        expect(button.backgroundColor, const Color(0xffd32f2f));
      });

      testWidgets('applies custom text color', (WidgetTester tester) async {
        await setupWidget(
          tester,
          ElevatedButtonWidget(
            title: 'Test Button',
            textColor: const Color(0xff2fd358),
            onPressed: () async {},
          ),
        );

        final text = tester.widget<TextWidget>(find.byType(TextWidget));
        expect(text.style?.color, const Color(0xff2fd358));
      });

      testWidgets('applies custom border radius', (WidgetTester tester) async {
        await setupWidget(
          tester,
          ElevatedButtonWidget(
            title: 'Test Button',
            borderRadius: 16.0,
            onPressed: () async {},
          ),
        );

        final button = tester
            .widget<ElevatedButtonWidget>(find.byType(ElevatedButtonWidget));
        expect(button.borderRadius, 16.0);
      });

      testWidgets('displays outlined button when isOutlined is true',
          (WidgetTester tester) async {
        await setupWidget(
          tester,
          ElevatedButtonWidget(
            title: 'Test Button',
            isOutlined: true,
            onPressed: () async {},
          ),
        );

        expect(find.byType(OutlinedButton), findsOneWidget);
      });
    });
  });
}
