import 'package:simple_permissions/simple_permissions.dart';

class PermissionService {
  Future<bool> hasStorageWriteAccess() async {
    PermissionStatus permissionResult = await SimplePermissions.requestPermission(Permission.WriteExternalStorage);
    return permissionResult == PermissionStatus.authorized;
  }
}