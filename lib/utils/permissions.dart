import 'package:permission_handler/permission_handler.dart';

class Permissions {
  static Future<bool> checkIfAccepted() async {
    bool storagePerm = await checkPermission(Permission.storage);

    return (storagePerm);
  }

  static Future<bool> checkPermission(Permission permission) async {
    final status = await permission.status;
    bool result = false;

    if (status == PermissionStatus.granted) {
      result = true;
    }
    return result;
  }
}
