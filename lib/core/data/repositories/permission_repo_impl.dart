import 'package:maple_harvest_app/core/core.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionRepoImpl implements PermissionRepository {

  @override
  Future<PermissionStatus> checkStatus(Permission permission) async {
    final status = await permission.status;
    return status;
  }

  @override
  Future<bool> request(Permission permission) async {
    final status = await permission.request();
    return status.isGranted;
  }

  @override
  Future<bool> openSettings() async => await openAppSettings();
}
