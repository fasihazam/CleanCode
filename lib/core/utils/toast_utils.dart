import 'package:fluttertoast/fluttertoast.dart';
import 'package:maple_harvest_app/core/config/config.dart';

class ToastUtils {
  static const _defaultDuration = Toast.LENGTH_SHORT;

  void showErrorToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: _defaultDuration,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppColors.error,
      textColor: AppColors.onError,
    );
  }

  void showSuccessToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: _defaultDuration,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppColors.primary,
      textColor: AppColors.onPrimary,
    );
  }
}
