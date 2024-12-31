import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:maple_harvest_app/core/core.dart';

class NetworkInjection {
  static Future<void> init() async {
    sl.registerSingleton(Connectivity());
    sl.registerSingleton<ConnectivityUtils>(ConnectivityUtils(sl()));
    sl.registerSingleton<ToastUtils>(ToastUtils());
    sl.registerSingleton<Dio>(Dio());
  }

  NetworkInjection._();
}
