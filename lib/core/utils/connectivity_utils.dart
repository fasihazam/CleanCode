import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityUtils {
  final Connectivity _connectivity;

  ConnectivityUtils(this._connectivity);

  Future<bool> get hasInternet async =>
      !(await _connectivity.checkConnectivity())
          .contains(ConnectivityResult.none);
}