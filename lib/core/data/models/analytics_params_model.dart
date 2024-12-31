class AnalyticsParamsModel {
  static const timestampKey = 'timestamp';
  static const errorInfoKey = 'errorInfo';

  final Map<String, dynamic> _params = {};

  Map<String, Object> build() => Map.unmodifiable(_params.map(
        (key, value) {
          if (value == null) {
            throw ArgumentError('Parameter value cannot be null for key: $key');
          }
          return MapEntry(key, value as Object);
        },
      ));

  AnalyticsParamsModel addUserInfo(UserAnalyticsModel userInfo) {
    _params.addAll(userInfo.toJson());
    return this;
  }

  AnalyticsParamsModel addScreenInfo(ScreenInfoModel screenInfo) {
    _params.addAll(screenInfo.toJson());
    return this;
  }

  AnalyticsParamsModel addCustomParams(Map<String, dynamic> params) {
    if (params.isEmpty) return this;
    params.forEach((key, value) {
      if (value == null) {
        throw ArgumentError('Parameter value cannot be null for key: $key');
      }
    });
    _params.addAll(params);
    return this;
  }

  AnalyticsParamsModel addTimestamp() {
    _params[timestampKey] = DateTime.now().millisecondsSinceEpoch;
    return this;
  }
}

class ScreenInfoModel {
  static const screenNameKey = 'screen_name';
  static const previousScreenKey = 'previous_screen';
  static const routeNameKey = 'route_name';

  final String screenName;
  final String? previousScreen;
  final String? routeName;

  const ScreenInfoModel({
    required this.screenName,
    this.previousScreen,
    this.routeName,
  });

  Map<String, dynamic> toJson() => {
        screenNameKey: screenName,
        if (previousScreen != null) previousScreenKey: previousScreen,
        if (routeName != null) routeNameKey: routeName,
      };

  @override
  String toString() => 'ScreenInfoModel(screenName: $screenName, '
      'previousScreen: $previousScreen, '
      'routeName: $routeName)';
}

class UserAnalyticsModel {
  static const userIdKey = 'user_id';
  static const isAnonymousKey = 'is_anonymous';

  final String userId;
  final bool isAnonymous;

  const UserAnalyticsModel({
    required this.userId,
    this.isAnonymous = false,
  });

  Map<String, dynamic> toJson() => {
        userIdKey: userId,
        isAnonymousKey: isAnonymous.toString(),
      };
}
