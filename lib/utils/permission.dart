import 'package:permission_handler/permission_handler.dart';

class Permissionutils {
  static Future<bool> askPermission() async {
    final PermissionStatus status = await Permission.storage.status;
    if (status.isGranted) {
      return true;
    } else {
      final Map<Permission, PermissionStatus> statuses = await [Permission.storage].request();
      return statuses[Permission.storage] == PermissionStatus.granted;
    }
  }

  static Future<bool> askPermissionCamera() async {
    final PermissionStatus status = await Permission.camera.status;
    if (status.isGranted) {
      return true;
    } else {
      final Map<Permission, PermissionStatus> statuses = await [Permission.camera].request();
      return statuses[Permission.camera] == PermissionStatus.granted;
    }
  }

  static Future<bool> askPermissionGallery() async {
    final PermissionStatus status = await Permission.photos.status;
    if (status.isGranted) {
      return true;
    } else {
      final Map<Permission, PermissionStatus> statuses = await [Permission.photos].request();
      return statuses[Permission.photos] == PermissionStatus.granted;
    }
  }

  static Future<bool> askPermissionRequestInstallPackage() async {
    final PermissionStatus status = await Permission.requestInstallPackages.status;
    if (status.isGranted) {
      return true;
    } else {
      final Map<Permission, PermissionStatus> statuses = await [Permission.requestInstallPackages].request();
      return statuses[Permission.requestInstallPackages] == PermissionStatus.granted;
    }
  }

  static Future<bool> askPermissionManageExternalStorage() async {
    final PermissionStatus status = await Permission.manageExternalStorage.status;
    if (status.isGranted) {
      return true;
    } else {
      final Map<Permission, PermissionStatus> statuses = await [Permission.manageExternalStorage].request();
      return statuses[Permission.manageExternalStorage] == PermissionStatus.granted;
    }
  }

  static Future<bool> askPermissionMediaLibrary() async {
    final PermissionStatus status = await Permission.mediaLibrary.status;
    if (status.isGranted) {
      return true;
    } else {
      final Map<Permission, PermissionStatus> statuses = await [Permission.mediaLibrary].request();
      return statuses[Permission.mediaLibrary] == PermissionStatus.granted;
    }
  }
}
