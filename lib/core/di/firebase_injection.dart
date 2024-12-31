import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:maple_harvest_app/core/core.dart';

class FirebaseInjection {
  static Future<void> init() async {
    // Crashlytics is already registered in CoreInjection
    sl.registerSingleton<FirebaseAnalytics>(FirebaseAnalytics.instance);
    sl.registerSingleton<FlutterLocalNotificationsPlugin>(
      FlutterLocalNotificationsPlugin(),
    );
    sl.registerSingleton<FirebaseMessaging>(FirebaseMessaging.instance);
  }

  FirebaseInjection._();
}
