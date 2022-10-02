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
              leading: Icon(Icons.photo_camera),
              title: Text('Camera'),
              onTap: () {
                _imageFromCamera();
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Gallery'),
              onTap: () {
                _imageFromGallery();
                Navigator.pop(context);
              },
            )
          ],
        ));
      });
}