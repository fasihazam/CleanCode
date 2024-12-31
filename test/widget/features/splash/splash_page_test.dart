import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maple_harvest_app/core/core.dart';
import 'package:maple_harvest_app/features/features.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'splash_page_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<AnonymousSignupCubit>(onMissingStub: OnMissingStub.returnDefault),
  MockSpec<UserCubit>(onMissingStub: OnMissingStub.returnDefault),
  MockSpec<PrefsUtils>(),
  MockSpec<AppRouter>(),
  MockSpec<AuthRepository>(),
  MockSpec<CrashlyticsService>(),
  MockSpec<AnalyticsService>()
])
void main() {
  late MockAnonymousSignupCubit mockAnonymousSignupCubit;
  late MockUserCubit mockUserCubit;
  late MockPrefsUtils mockPrefsUtils;
  late MockAppRouter mockAppRouter;

  Future<void> setupMocks() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    setupFirebaseCoreMocks();
    try {
      await Firebase.initializeApp();
    } catch (e) {
      throw Exception('Failed to initialize Firebase: $e');
    }
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  }

  setUpAll(() async {
    await setupMocks();
    await Injection.init();
  });

  tearDownAll(() {
    sl.reset();
  });

  setUp(() {
    mockAnonymousSignupCubit = MockAnonymousSignupCubit();
    mockUserCubit = MockUserCubit();
    mockPrefsUtils = MockPrefsUtils();
    mockAppRouter = MockAppRouter();

    when(mockAnonymousSignupCubit.stream).thenAnswer(
      (_) => Stream.fromIterable([
        const AnonymousSignupState(status: RequestStatus.initial),
      ]),
    );
    when(mockAnonymousSignupCubit.state).thenReturn(
      const AnonymousSignupState(status: RequestStatus.initial),
    );

    when(mockUserCubit.stream).thenAnswer(
      (_) => Stream.fromIterable([
        const UserState(status: RequestStatus.initial),
      ]),
    );
    when(mockUserCubit.state).thenReturn(
      const UserState(status: RequestStatus.initial),
    );

    when(mockPrefsUtils.authToken).thenAnswer((_) async => '');
    when(mockPrefsUtils.hasVisitedOnboarding).thenReturn(false);
  });

  Future<void> pumpSplashPage(WidgetTester tester) async {
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<UserCubit>.value(value: mockUserCubit),
          BlocProvider<AnonymousSignupCubit>.value(
              value: mockAnonymousSignupCubit),
        ],
        child: SizerUtils(
          builder: (_, __) => const MaterialApp(
            home: SplashPage(),
        ),
      ),
    ));
  }

  Future<void> pumpAndSettle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
  }

  group('SplashPage Visibility Tests', () {
    testWidgets('should show background image initially',
        (WidgetTester tester) async {
      await pumpSplashPage(tester);
      await tester.pump(); // Wait for first frame

      // Find the background container with decoration
      final container = find.byType(Container).first;
      final BoxDecoration decoration =
          tester.widget<Container>(container).decoration as BoxDecoration;

      expect(decoration.image?.image, isA<AssetImage>());
      expect((decoration.image?.image as AssetImage).assetName,
          equals(Assets.imagesSplashBg));

      // Ensure we complete all animations
      await pumpAndSettle(tester);
    });

    testWidgets(
        'should show splash logo with initial 0 opacity and animate to 1',
        (WidgetTester tester) async {
      await pumpSplashPage(tester);

      // Find the logo image widget
      final logoFinder = find.byWidgetPredicate((widget) =>
          widget is AssetImageWidget && widget.path == Assets.imagesSplashLogo);
      expect(logoFinder, findsOneWidget);

      // Check initial opacity
      final initialLogoOpacity = tester.widget<AnimatedOpacity>(
        find.ancestor(
          of: logoFinder,
          matching: find.byType(AnimatedOpacity),
        ),
      );
      expect(initialLogoOpacity.opacity, equals(0.0));

      // Wait for animation
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump();

      // Check final opacity
      final finalLogoOpacity = tester.widget<AnimatedOpacity>(
        find.ancestor(
          of: logoFinder,
          matching: find.byType(AnimatedOpacity),
        ),
      );
      expect(finalLogoOpacity.opacity, equals(1.0));

      // Complete all animations
      await pumpAndSettle(tester);
    });

    testWidgets('should have proper image sizing for logo',
        (WidgetTester tester) async {
      await pumpSplashPage(tester);

      final logoImage = tester.widget<AssetImageWidget>(find.byWidgetPredicate(
          (widget) =>
              widget is AssetImageWidget &&
              widget.path == Assets.imagesSplashLogo));

      expect(logoImage.height, equals(200.h));
      expect(logoImage.width, equals(200.w));
      expect(logoImage.fit, equals(BoxFit.contain));

      // Complete all animations
      await pumpAndSettle(tester);
    });

    testWidgets('status bar configuration and navigation',
        (WidgetTester tester) async {
      await pumpSplashPage(tester);

      // Check status bar configuration
      expect(SystemChrome.latestStyle?.statusBarColor, Colors.transparent);
      expect(
          SystemChrome.latestStyle?.statusBarIconBrightness, Brightness.light);
      expect(SystemChrome.latestStyle?.statusBarBrightness, Brightness.dark);

      // Wait for navigation delay
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(seconds: 2));

      // Check if system UI is restored on dispose
      await tester.pumpWidget(const SizedBox());
    });
  });
}
