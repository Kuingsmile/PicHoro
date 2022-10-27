import 'dart:io';
import 'dart:math';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:path/path.dart' as my_path;
import 'package:uuid/uuid.dart';
import "package:crypto/crypto.dart";
import 'package:fluttertoast/fluttertoast.dart';

import 'package:horopic/utils/global.dart';

//defaultLKformat和对应的转换函数
Map<String, Function> linkGenerateDict = {
  'rawurl': generateUrl,
  'html': generateHtmlFormatedUrl,
  'markdown': generateMarkdownFormatedUrl,
  'bbcode': generateBBcodeFormatedUrl,
  'markdown_with_link': generateMarkdownWithLinkFormatedUrl,
  'custom': generateCustomFormatedUrl,
};

//图片检查,有点问题，暂时不用
bool imageConstraint({required BuildContext context, required File image}) {
  /*if (!['bmp', 'jpg', 'jpeg', 'png', 'gif', 'webp']
      .contains(image.path.split('.').last.toString())) {
    showAlertDialog(
        context: context,
        title: "上传失败!",
        content: "图片格式应为bmp,jpg,jpeg,png,gif,webp.");
    return false;
  }*/
  return true;
}

//弹出对话框
showAlertDialog({
  bool? barrierDismissible,
  required BuildContext context,
  required String title,
  required String content,
}) {
  return showDialog(
      context: context,
      barrierDismissible: barrierDismissible == true ? true : false,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.only(left: 20, right: 20),
          title: Center(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 23.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          content: SizedBox(
            height: 200,
            width: 300,
            child: ListView(
              children: [
                const SizedBox(
                  height: 20,
                ),
                Text(content)
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Center(
                child: Text(
                  '确  定',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        );
      });
}

//cupertino风格的alertDialog
showCupertinoAlertDialog({
  bool? barrierDismissible,
  required BuildContext context,
  required String title,
  required String content,
}) {
  return showCupertinoDialog(
      context: context,
      barrierDismissible: barrierDismissible == true ? true : false,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Center(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 23.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          content: SizedBox(
            height: 150,
            width: 300,
            child: ListView(
              children: [Text(content)],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Center(
                child: Text(
                  '确定',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        );
      });
}

//cupertino风格的alertDialog Style 2
showCupertinoAlertDialogWithConfirmFunc({
  required BuildContext context,
  required String title,
  required String content,
  required onConfirm,
}) {
  return showCupertinoDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            CupertinoDialogAction(
              child: const Text('取消', style: TextStyle(color: Colors.blue)),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            CupertinoDialogAction(
              onPressed: onConfirm,
              child: const Text('确定', style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      });
}

//弹出toast
showToast(String msg) {
  Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      timeInSecForIosWeb: 2,
      fontSize: 16.0);
}

//带context的toast
showToastWithContext(BuildContext context, String msg) {
  Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      timeInSecForIosWeb: 2,
      backgroundColor: Theme.of(context).brightness == Brightness.light
          ? Colors.black
          : Colors.white,
      textColor: Theme.of(context).brightness == Brightness.light
          ? Colors.white
          : Colors.black,
      fontSize: 16.0);
}

//底部选择框
void bottomPickerSheet(
    BuildContext context, Function imageFromCamera, Function imageFromGallery) {
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
                imageFromCamera();
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('相册'),
              onTap: () {
                imageFromGallery();
                Navigator.pop(context);
              },
            )
          ],
        ));
      });
}

//random String Generator
String randomStringGenerator(int length) {
  const chars =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  final Random rnd = Random();
  return String.fromCharCodes(Iterable.generate(
      length, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
}

//rename file with timestamp
String renameFileWithTimestamp() {
  var now = DateTime.now();
  var timestamp = now.millisecondsSinceEpoch;
  var newFileName = timestamp.toString() + randomStringGenerator(5);
  return newFileName;
}

//rename file with random string
String renameFileWithRandomString(int length) {
  String randomString = randomStringGenerator(length);
  return randomString;
}

//rename picture with timestamp
Future<File> renamePictureWithTimestamp(File file) {
  var path = file.path;
  var lastSeparator = path.lastIndexOf(Platform.pathSeparator);
  var fileExtension = my_path.extension(path);
  var newFileName = renameFileWithTimestamp() + fileExtension;
  var newPath = path.substring(0, lastSeparator + 1) + newFileName;
  return file.rename(newPath);
}

//rename picture with random string
Future<File> renamePictureWithRandomString(File file) {
  var path = file.path;
  var lastSeparator = path.lastIndexOf(Platform.pathSeparator);
  var fileExtension = my_path.extension(path);
  var newFileName = renameFileWithRandomString(30) + fileExtension;
  var newPath = path.substring(0, lastSeparator + 1) + newFileName;
  return file.rename(newPath);
}

//rename picture with custom format
Future<File> renamePictureWithCustomFormat(File file) async {
  String customFormat = await Global.getCustomeRenameFormat();
  var path = file.path;
  var lastSeparator = path.lastIndexOf(Platform.pathSeparator);
  var fileExtension = my_path.extension(path);
  String yearFourDigit = DateTime.now().year.toString();
  String yearTwoDigit = yearFourDigit.substring(2, 4);
  String month = DateTime.now().month.toString();
  String day = DateTime.now().day.toString();
  String timestampSecond =
      (DateTime.now().millisecondsSinceEpoch / 1000).floor().toString();
  String uuidWithoutDash = Uuid().v4().replaceAll('-', '');
  String randommd5 = md5.convert(utf8.encode(uuidWithoutDash)).toString();
  String randommd5Short = randommd5.substring(0, 16);
  String tenRandomString = randomStringGenerator(10);
  String twentyRandomString = randomStringGenerator(20);
  String oldFileName = my_path.basename(path).replaceAll(fileExtension, '');
  String newFileName = customFormat
      .replaceAll('{Y}', yearFourDigit)
      .replaceAll('{y}', yearTwoDigit)
      .replaceAll('{m}', month)
      .replaceAll('{d}', day)
      .replaceAll('{timestamp}', timestampSecond)
      .replaceAll('{uuid}', uuidWithoutDash)
      .replaceAll('{md5}', randommd5)
      .replaceAll('{md5-16}', randommd5Short)
      .replaceAll('{str-10}', tenRandomString)
      .replaceAll('{str-20}', twentyRandomString)
      .replaceAll('{filename}', oldFileName);
  newFileName = newFileName + fileExtension;
  var newPath = path.substring(0, lastSeparator + 1) + newFileName;
  return file.rename(newPath);
}

//generate url formated url by raw url
String generateUrl(String rawUrl, String fileName) {
  return rawUrl;
}

//generate html formated url by raw url
String generateHtmlFormatedUrl(String rawUrl, String fileName) {
  String htmlFormatedUrl =
      '<img src="$rawUrl" alt="$fileName" title="$fileName" />';
  return htmlFormatedUrl;
}

//generate markdown formated url by raw url
String generateMarkdownFormatedUrl(String rawUrl, String fileName) {
  String markdownFormatedUrl = '![$fileName]($rawUrl)';
  return markdownFormatedUrl;
}

//generate markdown with link formated url by raw url
String generateMarkdownWithLinkFormatedUrl(String rawUrl, String fileName) {
  String markdownWithLinkFormatedUrl = '[![$fileName]($rawUrl)]($rawUrl)';
  return markdownWithLinkFormatedUrl;
}

//generate BBCode formated url by raw url
String generateBBcodeFormatedUrl(String rawUrl, String fileName) {
  String bbCodeFormatedUrl = '[img]$rawUrl[/img]';
  return bbCodeFormatedUrl;
}

//generate custom formated url by url and format
String generateCustomFormatedUrl(String url, String filename) {
  String fileName = filename;
  String rawUrl = url;
  String customLinkFormat = Global.customLinkFormat;
  String customFormatedUrl = customLinkFormat
      .replaceAll(r'$fileName', fileName)
      .replaceAll(r'$url', rawUrl);
  return customFormatedUrl;
}

//计算文件大小
String getFileSize(int fileSize) {
  String str = '';

  if (fileSize < 1024) {
    str = '${fileSize}B';
  } else if (fileSize < 1024 * 1024) {
    str = '${(fileSize / 1024).toStringAsFixed(2)}KB';
  } else if (fileSize < 1024 * 1024 * 1024) {
    str = '${(fileSize / 1024 / 1024).toStringAsFixed(2)}MB';
  } else {
    str = '${(fileSize / 1024 / 1024 / 1024).toStringAsFixed(2)}GB';
  }
  return str;
}

//选择文件图标
String selectIcon(String ext) {
  if (ext == '') {
    return 'assets/icons/unknown.png';
  } else {
    String extNoDot = ext.substring(1);
    String iconPath = 'assets/icons/';
    if (extNoDot == '') {
      iconPath += '_blank.png';
    } else if (Global.iconList.contains(extNoDot)) {
      iconPath += '$extNoDot.png';
    } else {
      iconPath += 'unknown.png';
    }
    return iconPath;
  }
}