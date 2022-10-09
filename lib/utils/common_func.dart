import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:path/path.dart' as mypath;

//defaultLKformat和对应的转换函数
Map<String, Function> linkGenerateDict = {
  'rawurl': generateUrl,
  'html': generateHtmlFormatedUrl,
  'markdown': generateMarkdownFormatedUrl,
  'bbcode': generateBBcodeFormatedUrl,
  'markdown_with_link': generateMarkdownWithLinkFormatedUrl,
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
          content: Container(
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

//底部选择框
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
  var extension = mypath.extension(path);
  var newFileName = renameFileWithTimestamp() + extension;
  var newPath = path.substring(0, lastSeparator + 1) + newFileName;
  return file.rename(newPath);
}

//rename picture with random string
Future<File> renamePictureWithRandomString(File file) {
  var path = file.path;
  var lastSeparator = path.lastIndexOf(Platform.pathSeparator);
  var extension = mypath.extension(path);
  var newFileName = renameFileWithRandomString(30) + extension;
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
