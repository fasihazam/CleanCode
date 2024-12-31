import 'package:flutter_test/flutter_test.dart';
import 'package:maple_harvest_app/core/core.dart';

void main() {
  late AnalyticsParamsModel analyticsParams;

  setUp(() {
    analyticsParams = AnalyticsParamsModel();
  });

  test('builds empty params correctly', () {
    final result = analyticsParams.build();
    expect(result, isEmpty);
    expect(result, isA<Map<String, Object>>());
  });

  test('adds user info correctly', () {
    const userInfo = UserAnalyticsModel(
      userId: 'test-user-123',
      isAnonymous: false,
    );

    final result = analyticsParams.addUserInfo(userInfo).build();

    expect(result[UserAnalyticsModel.userIdKey], equals('test-user-123'));
    expect(result[UserAnalyticsModel.isAnonymousKey], equals('false'));
  });

  test('adds screen info correctly', () {
    const screenInfo = ScreenInfoModel(
      screenName: 'HomeScreen',
      previousScreen: 'LoginScreen',
      routeName: '/home',
    );

    final result = analyticsParams.addScreenInfo(screenInfo).build();

    expect(result[ScreenInfoModel.screenNameKey], equals('HomeScreen'));
    expect(result[ScreenInfoModel.previousScreenKey], equals('LoginScreen'));
    expect(result[ScreenInfoModel.routeNameKey], equals('/home'));
  });

  test('adds custom params correctly', () {
    final customParams = {
      'itemId': '123',
      'category': 'electronics',
      'value': 99.99,
    };

    final result = analyticsParams.addCustomParams(customParams).build();

    expect(result['itemId'], equals('123'));
    expect(result['category'], equals('electronics'));
    expect(result['value'], equals(99.99));
  });

  test('adds timestamp correctly', () {
    final result = analyticsParams.addTimestamp().build();

    expect(result[AnalyticsParamsModel.timestampKey], isA<int>());
    expect(
      result[AnalyticsParamsModel.timestampKey] as int,
      closeTo(DateTime.now().millisecondsSinceEpoch, 1000),
    );
  });

  test('combines multiple param types correctly', () {
    const userInfo = UserAnalyticsModel(userId: 'user-123', isAnonymous: true);
    const screenInfo = ScreenInfoModel(screenName: 'ProductScreen');
    final customParams = {'productId': 'prod-456'};

    final result = analyticsParams
        .addUserInfo(userInfo)
        .addScreenInfo(screenInfo)
        .addCustomParams(customParams)
        .addTimestamp()
        .build();

    expect(result[UserAnalyticsModel.userIdKey], equals('user-123'));
    expect(result[UserAnalyticsModel.isAnonymousKey], equals('true'));
    expect(result[ScreenInfoModel.screenNameKey], equals('ProductScreen'));
    expect(result['productId'], equals('prod-456'));
    expect(result[AnalyticsParamsModel.timestampKey], isA<int>());
  });

  test('returns unmodifiable map', () {
    final result = analyticsParams.addCustomParams({'key': 'value'}).build();

    expect(() => (result as dynamic)['newKey'] = 'newValue',
        throwsUnsupportedError);
  });
}
