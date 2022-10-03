import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:horopic/AlertDialog.dart';

bool imageConstraint({required BuildContext context, required File image}) {
  if (!['bmp', 'jpg', 'jpeg', 'png', 'gif', 'webp']
      .contains(image.path.split('.').last.toString())) {
    showAlertDialog(
        context: context,
        title: "上传失败!",
        content: "图片格式应为bmp,jpg,jpeg,png,gif,webp.");
    return false;
  }
  return true;
}
