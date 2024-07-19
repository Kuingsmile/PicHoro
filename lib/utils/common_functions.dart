import 'dart:io';
import 'dart:math';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mime/mime.dart';
import 'package:horopic/picture_host_configure/configure_store/configure_template.dart';

import 'package:path/path.dart' as my_path;
import 'package:uuid/uuid.dart';
import "package:crypto/crypto.dart";
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fluro/fluro.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flustars_flutter3/flustars_flutter3.dart';
import 'package:f_logs/f_logs.dart';

import 'package:horopic/utils/global.dart';
import 'package:horopic/router/application.dart';
import 'package:horopic/router/routers.dart';
import 'package:horopic/utils/permission.dart';
import 'package:horopic/picture_host_configure/configure_store/configure_store_file.dart';

Map<String, String> psNameTranslate = {
  'aliyun': '阿里云',
  'qiniu': '七牛云',
  'tencent': '腾讯云',
  'upyun': '又拍云',
  'aws': 'S3兼容平台',
  'ftp': 'FTP',
  'github': 'GitHub',
  'sm.ms': 'SM.MS',
  'imgur': 'Imgur',
  'lsky.pro': '兰空图床',
  'alist': 'AList V3',
  'webdav': 'WebDAV',
};

Map downloadStatus = {
  'DownloadStatus.downloading': "下载中",
  'DownloadStatus.paused': "暂停",
  'DownloadStatus.canceled': "取消",
  'DownloadStatus.failed': "失败",
  'DownloadStatus.completed': "完成",
  'DownloadStatus.queued': "排队中",
};

Map uploadStatus = {
  'UploadStatus.uploading': "上传中",
  'UploadStatus.canceled': "取消",
  'UploadStatus.failed': "失败",
  'UploadStatus.completed': "完成",
  'UploadStatus.queued': "排队中",
  'UploadStatus.paused': "暂停",
};

flogError(Object e, Map parameters, String className, String methodName) {
  FLog.error(
      className: className,
      methodName: methodName,
      text: e is DioException
          ? formatErrorMessage(parameters, e.toString(), isDioError: true, dioErrorMessage: e)
          : formatErrorMessage(parameters, e.toString()),
      dataLogType: DataLogType.ERRORS.toString());
}

Future<File> ensureFileExists(File file) async {
  if (!(await file.exists())) {
    await file.create(recursive: true);
  }

  return file;
}

/// 默认图床参数和配置文件名对应关系
String getpdconfig(String defaultConfig) {
  const configMap = {
    'lsky.pro': 'host_config',
    'sm.ms': 'smms_config',
  };

  return configMap[defaultConfig] ?? '${defaultConfig}_config';
}

/// defaultLKformat和对应的转换函数
Map<String, Function> linkGeneratorMap = {
  'rawurl': generateUrl,
  'html': generateHtmlFormatedUrl,
  'markdown': generateMarkdownFormatedUrl,
  'bbcode': generateBBcodeFormatedUrl,
  'markdown_with_link': generateMarkdownWithLinkFormatedUrl,
  'custom': generateCustomFormatedUrl,
};

getFormatedUrl(String rawUrl, String fileName, [String? defaultLKformat]) {
  defaultLKformat ??= Global.defaultLKformat;
  if (linkGeneratorMap.containsKey(defaultLKformat)) {
    return linkGeneratorMap[defaultLKformat]!(rawUrl, fileName);
  }
  return rawUrl;
}

generateBasicAuth(String username, String password) {
  return 'Basic ${base64Encode(utf8.encode('$username:$password'))}';
}

getToday(String format) {
  return DateUtil.formatDate(DateTime.now(), format: format);
}

supportedExtensions(String ext) {
  String extLowerCase = ext.toLowerCase();
  if (extLowerCase.startsWith('.')) {
    extLowerCase = extLowerCase.substring(1);
  }
  return Global.imgExt.contains(extLowerCase) ||
      Global.textExt.contains(extLowerCase) ||
      Global.chewieExt.contains(extLowerCase) ||
      Global.vlcExt.contains(extLowerCase) ||
      extLowerCase == 'pdf';
}

BaseOptions setBaseOptions() {
  return BaseOptions(
    sendTimeout: Duration(milliseconds: Global.defaultOutTime),
    receiveTimeout: Duration(milliseconds: Global.defaultOutTime),
    connectTimeout: Duration(milliseconds: Global.defaultOutTime),
  );
}

downloadTxtFile(String urlpath, String fileName, Map<String, dynamic>? headers) async {
  try {
    BaseOptions baseOptions = setBaseOptions();
    Dio dio = Dio(baseOptions);
    String tempDir = (await getTemporaryDirectory()).path;
    var tempfile = File('$tempDir/$fileName');
    var response = await dio.download(
      urlpath,
      tempfile.path,
      deleteOnError: false,
      options: Options(
        headers: headers ?? {},
      ),
    );
    if (response.statusCode == 200) {
      return tempfile.path;
    }
    return 'error';
  } catch (e) {
    flogErr(
      e,
      {},
      'common_functions',
      "downloadTxtFile",
    );
    return 'error';
  }
}

/// 弹出对话框
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

/// cupertino风格的alertDialog
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

/// cupertino风格的alertDialog Style 2
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

/// 弹出toast
showToast(String msg) {
  Fluttertoast.showToast(msg: msg, toastLength: Toast.LENGTH_SHORT, timeInSecForIosWeb: 2, fontSize: 16.0);
}

/// 带context的toast
showToastWithContext(BuildContext context, String msg) {
  Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      timeInSecForIosWeb: 2,
      backgroundColor: Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white,
      textColor: Theme.of(context).brightness == Brightness.light ? Colors.white : Colors.black,
      fontSize: 16.0);
}

/// 底部选择框
void bottomPickerSheet(BuildContext context, Function imageFromCamera, Function imageFromGallery) {
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

/// title text
Widget titleText(String title,
    {double? fontsize = 20, FontWeight fontWeight = FontWeight.bold, Color? color = Colors.white}) {
  return Text(
    title,
    style: TextStyle(
      fontSize: fontsize,
      color: color,
      fontWeight: fontWeight,
    ),
  );
}

/// random String Generator
String randomStringGenerator(int length) {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  Random rnd = Random();
  return String.fromCharCodes(Iterable.generate(length, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
}

/// rename file with timestamp
String renameFileWithTimestamp() {
  return DateTime.now().millisecondsSinceEpoch.toString();
}

/// rename file with random string
String renameFileWithRandomString(int length) {
  return randomStringGenerator(length);
}

/// rename picture with timestamp
renamePictureWithTimestamp(File file) {
  var fileExtension = my_path.extension(file.path);
  return renameFileWithTimestamp() + fileExtension;
}

/// rename picture with random string
renamePictureWithRandomString(File file) {
  var fileExtension = my_path.extension(file.path);
  return renameFileWithRandomString(30) + fileExtension;
}

/// rename picture with custom format
renamePictureWithCustomFormat(File file) async {
  String customFormat = await Global.getCustomeRenameFormat();
  var path = file.path;
  var fileExtension = my_path.extension(path);

  DateTime now = DateTime.now();
  String yearFourDigit = now.year.toString();
  String yearTwoDigit = yearFourDigit.substring(2, 4);
  String month = now.month.toString().padLeft(2, '0');
  String day = now.day.toString().padLeft(2, '0');
  String hour = now.hour.toString().padLeft(2, '0');
  String minute = now.minute.toString().padLeft(2, '0');
  String second = now.second.toString().padLeft(2, '0');
  String milliSecond = now.millisecond.toString().padLeft(3, '0');
  String timestampMilliSecond = (now.millisecondsSinceEpoch).floor().toString();

  String uuidWithoutDash = const Uuid().v4().replaceAll('-', '');
  String randommd5 = md5.convert(utf8.encode(uuidWithoutDash)).toString();
  String randommd5Short = randommd5.substring(0, 16);

  String oldFileName = my_path.basename(path).replaceAll(fileExtension, '');
  String newFileName = customFormat
      .replaceAll('{Y}', yearFourDigit)
      .replaceAll('{y}', yearTwoDigit)
      .replaceAll('{m}', month)
      .replaceAll('{d}', day)
      .replaceAll('{h}', hour)
      .replaceAll('{i}', minute)
      .replaceAll('{s}', second)
      .replaceAll('{ms}', milliSecond)
      .replaceAll('{timestamp}', timestampMilliSecond)
      .replaceAll('{uuid}', uuidWithoutDash)
      .replaceAll('{md5}', randommd5)
      .replaceAll('{md5-16}', randommd5Short)
      .replaceAllMapped(RegExp(r'\{str-(\d+)\}'), (match) => randomStringGenerator(int.parse(match.group(1) ?? '0')))
      .replaceAll('{filename}', oldFileName);
  newFileName = newFileName + fileExtension;
  return newFileName;
}

/// generate url formated url by raw url
String generateUrl(String rawUrl, String fileName) {
  return Global.isURLEncode ? Uri.encodeFull(rawUrl) : rawUrl;
}

String generateHtmlFormatedUrl(String rawUrl, String fileName) {
  String encodedUrl = generateUrl(rawUrl, fileName);
  return '<img src="$encodedUrl" alt="${my_path.basename(fileName)}" title="${my_path.basename(fileName)}" />';
}

String generateMarkdownFormatedUrl(String rawUrl, String fileName) {
  String encodedUrl = generateUrl(rawUrl, fileName);
  return '![${my_path.basename(fileName)}]($encodedUrl)';
}

String generateMarkdownWithLinkFormatedUrl(String rawUrl, String fileName) {
  String encodedUrl = generateUrl(rawUrl, fileName);
  return '[![${my_path.basename(fileName)}]($encodedUrl)]($encodedUrl)';
}

String generateBBcodeFormatedUrl(String rawUrl, String fileName) {
  String encodedUrl = generateUrl(rawUrl, fileName);
  return '[img]$encodedUrl[/img]';
}

String generateCustomFormatedUrl(String rawUrl, String filename) {
  String encodeUrl = generateUrl(rawUrl, filename);
  return Global.customLinkFormat.replaceAll(r'$fileName', my_path.basename(filename)).replaceAll(r'$url', encodeUrl);
}

String getFileSize(int fileSize) {
  return fileSize < 1024
      ? '${fileSize}B'
      : fileSize < 1024 * 1024
          ? '${(fileSize / 1024).toStringAsFixed(2)}KB'
          : fileSize < 1024 * 1024 * 1024
              ? '${(fileSize / 1024 / 1024).toStringAsFixed(2)}MB'
              : '${(fileSize / 1024 / 1024 / 1024).toStringAsFixed(2)}GB';
}

/// 选择文件图标
String selectIcon(String ext) {
  if (ext == '') {
    return 'assets/icons/unknown.png';
  }
  if (!ext.startsWith('.')) {
    ext = '.$ext';
  }
  String extNoDot = ext.substring(1).toLowerCase();
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

/// 获得content-type
String getContentType(String ext) {
  if (!ext.startsWith('.')) {
    ext = '.$ext';
  }
  try {
    return lookupMimeType('file${ext.toLowerCase()}') ?? 'application/octet-stream';
  } catch (e) {
    return 'application/octet-stream';
  }
}

/// 格式化错误信息
formatErrorMessage(
  Map parameters,
  String error, {
  bool isDioError = false,
  DioException? dioErrorMessage,
}) {
  String formatedParameters = '';
  String formatedError = '';
  String? formatedDioError = '';

  if (parameters.isNotEmpty) {
    parameters.forEach((key, value) {
      formatedParameters += '$key: $value\n';
    });
  }
  if (error.isNotEmpty) {
    formatedError = error;
  }
  if (dioErrorMessage != null) {
    formatedDioError = dioErrorMessage.response != null
        ? '${dioErrorMessage.message}\n${dioErrorMessage.response!.data}'
        : dioErrorMessage.message;
  }
  String formateTemplate =
      '参数:\n\n$formatedParameters\n错误信息:\n$formatedError\n\n是否DIO错误:\n$isDioError\n\nDIO报错信息:\n$formatedDioError';
  return formateTemplate;
}

/// 错误日志生成函数
flogErr(Object e, Map parameters, String className, String methodName) {
  FLog.error(
      className: className,
      methodName: methodName,
      text: e is DioException
          ? formatErrorMessage(parameters, e.toString(), isDioError: true, dioErrorMessage: e)
          : formatErrorMessage(parameters, e.toString()),
      dataLogType: DataLogType.ERRORS.toString());
}

/// 清理下载的apk文件
Future<void> deleteApkFile() async {
  try {
    var directory = await getExternalStorageDirectory();
    if (directory == null) return;
    var apkFilePath = '${directory.path}/Download';
    var apkFileDirectory = Directory(apkFilePath);
    if (await apkFileDirectory.exists()) {
      await for (var file in apkFileDirectory.list()) {
        if (file.path.endsWith('.apk')) {
          file.delete();
        }
      }
    }
  } catch (e) {
    return;
  }
}

/// APPinit
mainInit() async {
  await Permissionutils.askPermissionStorage();
  await Permissionutils.askPermissionCamera();
  await Permissionutils.askPermissionGallery();
  await Permissionutils.askPermissionManageExternalStorage();
  await Permissionutils.askPermissionMediaLibrary();
  await Permissionutils.askPermissionRequestInstallPackage();
  String initUser = await Global.getUser();
  await Global.setUser(initUser);
  deleteApkFile();
  await Global.setPassword(await Global.getPassword());
  await Global.setPShost(await Global.getPShost());
  await ConfigureStoreFile().generateConfigureFile();
  Global.setLKformat(await Global.getLKformat());
  Global.setIsTimeStamp(await Global.getIsTimeStamp());
  Global.setIsRandomName(await Global.getIsRandomName());
  Global.setIsCopyLink(await Global.getIsCopyLink());
  Global.setIsURLEncode(await Global.getIsURLEncode());
  await Global.setShowedPBhost(await Global.getShowedPBhost());
  Global.setIsDeleteLocal(await Global.getIsDeleteLocal());
  Global.setCustomLinkFormat(await Global.getCustomLinkFormat());
  Global.setIsDeleteCloud(await Global.getIsDeleteCloud());
  Global.setIsCustomeRename(await Global.getIsCustomeRename());
  Global.setCustomeRenameFormat(await Global.getCustomeRenameFormat());
  Global.setTodayAlistUpdate(await Global.getTodayAlistUpdate());
  Global.setBucketCustomUrl(await Global.getBucketCustomUrl());

  //初始化图片压缩选项
  Global.setIsCompress(await Global.getIsCompress());
  Global.setminWidth(await Global.getminWidth());
  Global.setminHeight(await Global.getminHeight());
  Global.setQuality(await Global.getQuality());
  Global.setDefaultCompressFormat(await Global.getDefaultCompressFormat());

  //初始化图床相册数据库
  await Global.setDatabase(await Global.getDatabase());
  //初始化扩展图床相册数据库
  await Global.setDatabaseExtend(await Global.getDatabaseExtend());

  //初始化路由
  FluroRouter router = FluroRouter();
  Application.router = router;
  Routes.configureRoutes(router);
  //初始化图床管理页面排列顺序
  List<String> psHostHomePageOrder = await Global.getpsHostHomePageOrder();
  if (psHostHomePageOrder.length <= 22) {
    int length = psHostHomePageOrder.length;
    for (int i = length; i < 22; i++) {
      psHostHomePageOrder.add(i.toString());
    }
  } else if (psHostHomePageOrder.length > 22) {
    for (int i = 0; i < 22; i++) {
      psHostHomePageOrder.clear();
      psHostHomePageOrder.add(i.toString());
    }
  }
  await Global.setpsHostHomePageOrder(psHostHomePageOrder);

  //初始化上传下载列表
  Global.setTencentUploadList(await Global.getTencentUploadList());
  Global.setTencentDownloadList(await Global.getTencentDownloadList());
  Global.setAliyunUploadList(await Global.getAliyunUploadList());
  Global.setAliyunDownloadList(await Global.getAliyunDownloadList());
  Global.setQiniuUploadList(await Global.getQiniuUploadList());
  Global.setQiniuDownloadList(await Global.getQiniuDownloadList());
  Global.setUpyunUploadList(await Global.getUpyunUploadList());
  Global.setUpyunDownloadList(await Global.getUpyunDownloadList());
  Global.setSmmsUploadList(await Global.getSmmsUploadList());
  Global.setSmmsDownloadList(await Global.getSmmsDownloadList());
  Global.setSmmsSavedNameList(await Global.getSmmsSavedNameList());
  Global.setImgurUploadList(await Global.getImgurUploadList());
  Global.setImgurDownloadList(await Global.getImgurDownloadList());
  Global.setGithubUploadList(await Global.getGithubUploadList());
  Global.setGithubDownloadList(await Global.getGithubDownloadList());
  Global.setLskyproUploadList(await Global.getLskyproUploadList());
  Global.setLskyproDownloadList(await Global.getLskyproDownloadList());
  Global.setFtpUploadList(await Global.getFtpUploadList());
  Global.setFtpDownloadList(await Global.getFtpDownloadList());
  Global.setAwsUploadList(await Global.getAwsUploadList());
  Global.setAwsDownloadList(await Global.getAwsDownloadList());
  Global.setAlistUploadList(await Global.getAlistUploadList());
  Global.setAlistDownloadList(await Global.getAlistDownloadList());
  Global.setWebdavUploadList(await Global.getWebdavUploadList());
  Global.setWebdavDownloadList(await Global.getWebdavDownloadList());
}

//获得小图标，图片预览
Widget getImageIcon(String path) {
  try {
    List imageType = ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp'];
    if (imageType.contains(path.substring(path.lastIndexOf('.')).toLowerCase())) {
      return Image.file(File(path), width: 30, height: 30, fit: BoxFit.fill);
    } else if (Global.iconList.contains(my_path.extension(path).substring(1).toLowerCase())) {
      return Image.asset(
        'assets/icons/${my_path.extension(path).substring(1)}.png',
        width: 30,
        height: 30,
        fit: BoxFit.fill,
      );
    } else {
      return Image.asset('assets/icons/unknown.png', width: 30, height: 30, fit: BoxFit.fill);
    }
  } catch (e) {
    return Image.asset('assets/icons/unknown.png', width: 30, height: 30, fit: BoxFit.fill);
  }
}

void setControllerText(TextEditingController controller, String? value) {
  if (value != 'None' && value != null) {
    controller.text = value;
  } else {
    controller.clear();
  }
}

String checkPlaceholder(String? value) {
  return (value == ConfigureTemplate.placeholder || value == null) ? 'None' : value;
}
