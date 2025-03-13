import 'package:permission_handler/permission_handler.dart';

class Permissionutils {
  static Future<bool> askForPermission(Permission permission) async {
    final PermissionStatus status = await permission.status;
    if (status.isGranted) {
      return true;
    } else {
      final Map<Permission, PermissionStatus> statuses = await [permission].request();
      return statuses[permission] == PermissionStatus.granted;
    }
  }

  static Future<bool> askPermissionStorage() async => askForPermission(Permission.storage);
  static Future<bool> askPermissionCamera() async => askForPermission(Permission.camera);
  static Future<bool> askPermissionPhotos() async => askForPermission(Permission.photos);
  static Future<bool> askPermissionVideo() async => askForPermission(Permission.videos);
  static Future<bool> askPermissionAudio() async => askForPermission(Permission.audio);
  static Future<bool> askPermissionRequestInstallPackage() async => askForPermission(Permission.requestInstallPackages);
  static Future<bool> askPermissionManageExternalStorage() async => askForPermission(Permission.manageExternalStorage);
  static Future<bool> askPermissionMediaLibrary() async => askForPermission(Permission.mediaLibrary);
}
