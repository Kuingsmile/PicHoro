import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

//ask for permission at runtime,storage permission and camera permission and gallery permission

class Permissionutils {
  static Future<bool> askPermission() async {
    final PermissionStatus status = await Permission.storage.status;
    if (status.isGranted) {
      return true;
    } else {
      final Map<Permission, PermissionStatus> statuses =
          await [Permission.storage].request();
      return statuses[Permission.storage] == PermissionStatus.granted;
    }
  }

  static Future<bool> askPermissionCamera() async {
    final PermissionStatus status = await Permission.camera.status;
    if (status.isGranted) {
      return true;
    } else {
      final Map<Permission, PermissionStatus> statuses =
          await [Permission.camera].request();
      return statuses[Permission.camera] == PermissionStatus.granted;
    }
  }

  static Future<bool> askPermissionGallery() async {
    final PermissionStatus status = await Permission.photos.status;
    if (status.isGranted) {
      return true;
    } else {
      final Map<Permission, PermissionStatus> statuses =
          await [Permission.photos].request();
      return statuses[Permission.photos] == PermissionStatus.granted;
    }
  }
}
