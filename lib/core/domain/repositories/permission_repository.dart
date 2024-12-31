import 'package:permission_handler/permission_handler.dart';

abstract class PermissionRepository {
  Future<PermissionStatus> checkStatus(Permission permission);

  Future<bool> request(Permission permission);

  Future<bool> openSettings();
}