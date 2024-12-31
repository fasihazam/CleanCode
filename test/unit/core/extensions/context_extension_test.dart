import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:maple_harvest_app/core/core.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'context_extension_test.mocks.dart';

@GenerateNiceMocks([MockSpec<GoRouter>()])
void main() {
  Widget buildTestableWidget(Widget child, {ThemeData? theme}) {
    return MaterialApp(
      theme: theme,
      home: Builder(
        builder: (context) => child,
      ),
    );
  }

  group('ContextExtension', () {
    testWidgets('should return correct ThemeData', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const Placeholder()));

      // Assert: ThemeData is accessed correctly.
      expect(tester.element(find.byType(Placeholder)).theme, isA<ThemeData>());
    });

    testWidgets('should return correct TextTheme', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const Placeholder()));

      // Assert: TextTheme is accessed correctly.
      expect(tester.element(find.byType(Placeholder)).textTheme, isA<TextTheme>());
    });

    testWidgets('should return correct ColorScheme', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const Placeholder(), theme: ThemeData.light()));

      // Assert: ColorScheme is accessed correctly.
      expect(tester.element(find.byType(Placeholder)).colorScheme, isA<ColorScheme>());
    });

    testWidgets('should return correct MediaQueryData', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const Placeholder()));

      // Assert: MediaQueryData is accessed correctly.
      expect(tester.element(find.byType(Placeholder)).mediaQuery, isA<MediaQueryData>());
    });

    testWidgets('should return correct Size', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const Placeholder()));

      // Assert: Size is accessed correctly.
      expect(tester.element(find.byType(Placeholder)).mediaQuery.size, isA<Size>());
    });

    testWidgets('should return correct width and height', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const Placeholder()));

      // Assert: Width and height are accessed correctly.
      expect(tester.element(find.byType(Placeholder)).width, greaterThan(0));
      expect(tester.element(find.byType(Placeholder)).height, greaterThan(0));
    });

    group('Navigation methods', () {
      late MockGoRouter mockRouter;

      setUp(() {
        mockRouter = MockGoRouter();
      });

      testWidgets('goToHome should navigate to home route', (WidgetTester tester) async {
        await tester.pumpWidget(
          InheritedGoRouter(
            goRouter: mockRouter,
            child: Builder(
              builder: (context) {
                return MaterialApp(
                  home: Scaffold(
                    body: TextButton(
                      onPressed: () => context.goToHome(),
                      child: const Text('Navigate'),
                    ),
                  ),
                );
              },
            ),
          ),
        );

        // Trigger navigation
        await tester.tap(find.byType(TextButton));
        await tester.pumpAndSettle();

        // Verify that goNamed was called with correct route
        verify(mockRouter.goNamed(AppRoutes.home)).called(1);
      });

      testWidgets('goToOnboarding should navigate to onboarding route', (WidgetTester tester) async {
        await tester.pumpWidget(
          InheritedGoRouter(
            goRouter: mockRouter,
            child: Builder(
              builder: (context) {
                return MaterialApp(
                  home: Scaffold(
                    body: TextButton(
                      onPressed: () => context.goToOnboarding(),
                      child: const Text('Navigate'),
                    ),
                  ),
                );
              },
            ),
          ),
        );

        await tester.tap(find.byType(TextButton));
        await tester.pumpAndSettle();

        verify(mockRouter.goNamed(AppRoutes.onboarding)).called(1);
      });

      testWidgets('goToLogin should navigate to login route', (WidgetTester tester) async {
        await tester.pumpWidget(
          InheritedGoRouter(
            goRouter: mockRouter,
            child: Builder(
              builder: (context) {
                return MaterialApp(
                  home: Scaffold(
                    body: TextButton(
                      onPressed: () => context.goToLogin(),
                      child: const Text('Navigate'),
                    ),
                  ),
                );
              },
            ),
          ),
        );

        await tester.tap(find.byType(TextButton));
        await tester.pumpAndSettle();

        verify(mockRouter.goNamed(AppRoutes.login)).called(1);
      });

      testWidgets('goToAIBot should do nothing (TODO implementation)', (WidgetTester tester) async {
        await tester.pumpWidget(
          InheritedGoRouter(
            goRouter: mockRouter,
            child: Builder(
              builder: (context) {
                return MaterialApp(
                  home: Scaffold(
                    body: TextButton(
                      onPressed: () => context.goToAIBot(),
                      child: const Text('Navigate'),
                    ),
                  ),
                );
              },
            ),
          ),
        );

        await tester.tap(find.byType(TextButton));
        await tester.pumpAndSettle();

        // Verify that no navigation occurred
        verifyNever(mockRouter.goNamed(any));
      });
    });

  });
}