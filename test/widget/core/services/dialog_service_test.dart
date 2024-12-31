import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maple_harvest_app/core/core.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'dialog_service_test.mocks.dart';

@GenerateMocks([CrashlyticsService, LoggerUtils])
void main() {
  late MockCrashlyticsService mockCrashlytics;
  late MockLoggerUtils mockLogger;
  late GlobalKey<NavigatorState> navigatorKey;
  late DialogService dialogService;

  setUp(() {
    mockCrashlytics = MockCrashlyticsService();
    mockLogger = MockLoggerUtils();
    navigatorKey = GlobalKey<NavigatorState>();
    dialogService = DialogService(
      crashlyticsService: mockCrashlytics,
      loggerUtils: mockLogger,
      navigatorKey: navigatorKey,
    );
  });

  testWidgets('shows custom dialog with content', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigatorKey,
        home: Scaffold(body: Builder(builder: (context) {
          return ElevatedButton(
            onPressed: () {
              dialogService.showCustomDialog(
                context: context,
                builder: (_) => const Text('Custom Dialog Content'),
              );
            },
            child: const Text('Show Dialog'),
          );
        })),
      ),
    );

    // Tap the button to show dialog
    await tester.tap(find.text('Show Dialog'));
    await tester.pumpAndSettle();

    // Verify the dialog is displayed
    expect(find.text('Custom Dialog Content'), findsOneWidget);
  });

  testWidgets('shows confirmation dialog and handles actions',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigatorKey,
        home: Scaffold(body: Builder(builder: (context) {
          return ElevatedButton(
            onPressed: () {
              dialogService.showConfirmationDialog(
                context: context,
                title: 'Confirm',
                message: 'Are you sure?',
                confirmText: 'Yes',
                cancelText: 'No',
                onConfirm: () => mockLogger.logInfo('Dialog', 'Confirmed'),
                onCancel: () => mockLogger.logInfo('Dialog', 'Cancelled'),
              );
            },
            child: const Text('Show Confirmation Dialog'),
          );
        })),
      ),
    );

    // Tap the button to show dialog
    await tester.tap(find.text('Show Confirmation Dialog'));
    await tester.pumpAndSettle();

    // Verify dialog elements
    expect(find.text('Confirm'), findsOneWidget);
    expect(find.text('Are you sure?'), findsOneWidget);

    // Test Confirm Action
    await tester.tap(find.text('Yes'));
    await tester.pumpAndSettle();
    verify(mockLogger.logInfo('Dialog', 'Confirmed')).called(1);

    // Reopen Dialog and Test Cancel Action
    await tester.tap(find.text('Show Confirmation Dialog'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('No'));
    await tester.pumpAndSettle();
    verify(mockLogger.logInfo('Dialog', 'Cancelled')).called(1);
  });

  testWidgets('dismisses dialog when tapped outside',
      (WidgetTester tester) async {
    // Set a fixed screen size for testing
    await tester.binding.setSurfaceSize(const Size(800, 600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigatorKey,
        home: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Scaffold(
            body: Builder(
              builder: (context) {
                return Center(
                  child: ElevatedButton(
                    onPressed: () {
                      dialogService.showCustomDialog(
                        context: context,
                        builder: (_) => Container(
                          width: 200,
                          height: 100,
                          alignment: Alignment.center,
                          child: const Material(
                            child: Text('Dismissible Dialog'),
                          ),
                        ),
                        dismissible: true,
                      );
                    },
                    child: const Text('Show Dismissible Dialog'),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );

    // Get screen size
    final Size screenSize = tester.getSize(find.byType(MaterialApp));

    // Tap button to show dialog
    await tester.tap(find.text('Show Dismissible Dialog'));
    await tester.pumpAndSettle();

    // Verify dialog is shown
    expect(find.text('Dismissible Dialog'), findsOneWidget);

    // Get dialog position
    final dialogFinder = find.text('Dismissible Dialog');
    final dialogRect = tester.getRect(dialogFinder);

    // Find a point that's definitely outside the dialog but inside the screen
    final outsidePoint = Offset(
      // If dialog is in the left half of screen, tap on right side, and vice versa
      dialogRect.center.dx < screenSize.width / 2
          ? screenSize.width - 10 // tap on right side
          : 10, // tap on left side
      // If dialog is in the top half, tap on bottom, and vice versa
      dialogRect.center.dy < screenSize.height / 2
          ? screenSize.height - 10 // tap on bottom
          : 10, // tap on top
    );

    // Tap outside
    await tester.tapAt(outsidePoint);
    await tester.pumpAndSettle();

    // Verify dialog is dismissed
    expect(find.text('Dismissible Dialog'), findsNothing);

    // Clean up
    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('dialog does not dismiss when tapped outside if non-dismissible',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigatorKey,
        home: Scaffold(body: Builder(builder: (context) {
          return ElevatedButton(
            onPressed: () {
              dialogService.showCustomDialog(
                context: context,
                builder: (_) => const Text('Non-Dismissible Dialog'),
                dismissible: false,
              );
            },
            child: const Text('Show Non-Dismissible Dialog'),
          );
        })),
      ),
    );

    // Tap the button to show dialog
    await tester.tap(find.text('Show Non-Dismissible Dialog'));
    await tester.pumpAndSettle();

    // Tap outside the dialog
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    // Verify dialog is not dismissed
    expect(find.text('Non-Dismissible Dialog'), findsOneWidget);
  });

  testWidgets('prevents multiple dialogs from showing simultaneously',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigatorKey,
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  dialogService.showCustomDialog(
                    context: context,
                    builder: (_) => const Material(
                      child: Text('Dialog 1'),
                    ),
                  );
                  dialogService.showCustomDialog(
                    context: context,
                    builder: (_) => const Material(
                      child: Text('Dialog 2'),
                    ),
                  );
                },
                child: const Text('Show Multiple Dialogs'),
              );
            },
          ),
        ),
      ),
    );

    // Tap button to show dialogs
    await tester.tap(find.text('Show Multiple Dialogs'));
    await tester.pumpAndSettle();

    // Verify only the first dialog is shown and second dialog is not
    expect(find.text('Dialog 1'), findsOneWidget);
    expect(find.text('Dialog 2'), findsNothing);

    // Verify there's only one set of dialog elements
    final visibleTexts = find.byType(Text).evaluate().where((element) =>
        element.widget is Text &&
        (element.widget as Text).data != 'Show Multiple Dialogs');
    expect(visibleTexts.length, 1);
  });
}
