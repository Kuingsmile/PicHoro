import 'package:flutter/material.dart';

void bottomPickerSheet(BuildContext context, Function _imageFromCamera,
    Function _imageFromGallery) {
  showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
            child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('拍照'),
              onTap: () {
                _imageFromCamera();
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('相册'),
              onTap: () {
                _imageFromGallery();
                Navigator.pop(context);
              },
            )
          ],
        ));
      });
}
