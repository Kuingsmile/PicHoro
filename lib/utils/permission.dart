import 'package:permission_handler/permission_handler.dart';

class PermissionHelper {
  static Future<bool> requestPermission(Permission permission) async {
    final PermissionStatus status = await permission.status;
    if (status.isGranted) {
      return true;
    } else {
      final Map<Permission, PermissionStatus> statuses = await [permission].request();
      return statuses[permission] == PermissionStatus.granted;
    }
  }

  static Future<bool> requestStoragePermission() async => requestPermission(Permission.storage);
  static Future<bool> requestCameraPermission() async => requestPermission(Permission.camera);
  static Future<bool> requestPhotoPermission() async => requestPermission(Permission.photos);
  static Future<bool> requestVideoPermission() async => requestPermission(Permission.videos);
  static Future<bool> requestAudioPermission() async => requestPermission(Permission.audio);
  static Future<bool> requestInstallPackagePermission() async => requestPermission(Permission.requestInstallPackages);
  static Future<bool> requestManageExternalStoragePermission() async =>
      requestPermission(Permission.manageExternalStorage);
  static Future<bool> requestMediaLibraryAccess() async => requestPermission(Permission.mediaLibrary);
}
