import 'dart:io';
import 'dart:math';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:path/path.dart' as my_path;
import 'package:uuid/uuid.dart';
import "package:crypto/crypto.dart";
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sqflite/sqflite.dart';
import 'package:fluro/fluro.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flustars_flutter3/flustars_flutter3.dart';
import 'package:f_logs/f_logs.dart';

import 'package:horopic/utils/global.dart';
import 'package:horopic/router/application.dart';
import 'package:horopic/router/routers.dart';
import 'package:horopic/utils/permission.dart';
import 'package:horopic/picture_host_configure/configure_store/configure_store_file.dart';

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

//默认图床参数和配置文件名对应关系
String getpdconfig(String defaultConfig) {
  return defaultConfig == 'lsky.pro'
      ? 'host_config'
      : defaultConfig == 'sm.ms'
          ? 'smms_config'
          : '${defaultConfig}_config';
}

//defaultLKformat和对应的转换函数
Map<String, Function> linkGenerateDict = {
  'rawurl': generateUrl,
  'html': generateHtmlFormatedUrl,
  'markdown': generateMarkdownFormatedUrl,
  'bbcode': generateBBcodeFormatedUrl,
  'markdown_with_link': generateMarkdownWithLinkFormatedUrl,
  'custom': generateCustomFormatedUrl,
};

generateBasicAuth(String username, String password) {
  return 'Basic ${base64Encode(utf8.encode('$username:$password'))}';
}

getToday(String format) {
  String today = DateUtil.formatDate(DateTime.now(), format: format);
  return today;
}

supportedExtensions(String ext) {
  String extLowerCase = ext.toLowerCase();

  if (!Global.imgExt.contains(extLowerCase) &&
      !Global.textExt.contains(extLowerCase) &&
      !Global.chewieExt.contains(extLowerCase) &&
      !Global.vlcExt.contains(extLowerCase) &&
      extLowerCase != 'pdf') {
    return false;
  } else {
    return true;
  }
}

BaseOptions setBaseOptions() {
  BaseOptions baseOptions = BaseOptions(
    sendTimeout: Global.defaultOutTime,
    receiveTimeout: Global.defaultOutTime,
    connectTimeout: Global.defaultOutTime,
  );
  return baseOptions;
}

downloadTxtFile(
    String urlpath, String fileName, Map<String, dynamic>? headers) async {
  BaseOptions baseOptions = setBaseOptions();
  Dio dio = Dio(baseOptions);
  String tempDir = (await getTemporaryDirectory()).path;
  var tempfile = File('$tempDir/$fileName');
  try {
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
    } else {
      return 'error';
    }
  } catch (e) {
    FLog.error(
        className: "common_functions",
        methodName: "downloadTxtFile",
        text: formatErrorMessage({}, e.toString()),
        dataLogType: DataLogType.ERRORS.toString());
  }
  return 'error';
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

//title text
Widget titleText(String title,
    {double? fontsize = 20,
    FontWeight fontWeight = FontWeight.bold,
    Color? color = Colors.white}) {
  return Text(
    title,
    style: TextStyle(
      fontSize: fontsize,
      color: color,
      fontWeight: fontWeight,
    ),
  );
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
renamePictureWithTimestamp(File file) {
  var path = file.path;
  var fileExtension = my_path.extension(path);
  var newFileName = renameFileWithTimestamp() + fileExtension;
  return newFileName;
}

//rename picture with random string
renamePictureWithRandomString(File file) {
  var path = file.path;
  var fileExtension = my_path.extension(path);
  var newFileName = renameFileWithRandomString(30) + fileExtension;
  return newFileName;
}

//rename picture with custom format
renamePictureWithCustomFormat(File file) async {
  String customFormat = await Global.getCustomeRenameFormat();
  var path = file.path;
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
  return newFileName;
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
    extNoDot = extNoDot.toLowerCase();
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

//获得content-type
String? getContentType(String ext) {
  if (!ext.startsWith('.')) {
    ext = '.$ext';
  }
  Map imageContentType = {
    '.fax': 'image/fax',
    '.gif': 'image/gif',
    '.ico': 'image/x-icon',
    '.jpg': 'image/jpeg',
    '.jpeg': 'image/jpeg',
    '.jpe': 'image/jpeg',
    '.jfif': 'image/jpeg',
    '.tif': 'image/tiff',
    '.net': 'image/pnetvue',
    '.png': 'image/png',
    '.rp': 'image/vnd.rn-realpix',
    '.tiff': 'image/tiff',
    '.wbmp': 'image/vnd.wap.wbmp',
  };
  return imageContentType[ext];
}

//格式化错误信息
formatErrorMessage(
  Map parameters,
  String error, {
  bool isDioError = false,
  DioError? dioErrorMessage = null,
}) {
  String formatedParameters = '';
  String formatedError = '';
  String formatedDioError = '';

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

//错误日志生成函数
flogErr(Object e, Map parameters, String className, String methodName) {
  FLog.error(
      className: className,
      methodName: methodName,
      text: e is DioError
          ? formatErrorMessage(parameters, e.toString(),
              isDioError: true, dioErrorMessage: e)
          : formatErrorMessage(parameters, e.toString()),
      dataLogType: DataLogType.ERRORS.toString());
}

//清理下载的apk文件
Future<void> deleteApkFile() async {
  try {
    var directory = await getExternalStorageDirectory();
    var path = directory!.path;
    String apkFilePath = '$path/Download';
    Directory apkFileDirectory = Directory(apkFilePath);
    if (await apkFileDirectory.exists()) {
      apkFileDirectory.list().listen((file) {
        if (file.path.endsWith('.apk')) {
          file.delete();
        }
      });
    }
  } catch (e) {
    return;
  }
}

//APPinit
mainInit() async {
  await Permissionutils.askPermission();
  await Permissionutils.askPermissionCamera();
  await Permissionutils.askPermissionGallery();
  await Permissionutils.askPermissionManageExternalStorage();
  await Permissionutils.askPermissionMediaLibrary();
  //初始化全局信息，会在APP启动时执行
  String initUser = await Global.getUser();
  await Global.setUser(initUser);
  deleteApkFile();
  String initPassword = await Global.getPassword();
  await Global.setPassword(initPassword);
  String initPShost = await Global.getPShost();
  await Global.setPShost(initPShost);
  await ConfigureStoreFile().generateConfigureFile();
  String initLKformat = await Global.getLKformat();
  Global.setLKformat(initLKformat);
  bool initIsTimeStamp = await Global.getTimeStamp();
  Global.setTimeStamp(initIsTimeStamp);
  bool initIsRandomName = await Global.getRandomName();
  Global.setRandomName(initIsRandomName);
  bool initIsCopyLink = await Global.getCopyLink();
  Global.setCopyLink(initIsCopyLink);
  String initShowedPBhost = await Global.getShowedPBhost();
  await Global.setShowedPBhost(initShowedPBhost);
  bool isDeleteLocal = await Global.getDeleteLocal();
  Global.setDeleteLocal(isDeleteLocal);
  String initCustomLinkFormat = await Global.getCustomLinkFormat();
  Global.setCustomLinkFormat(initCustomLinkFormat);
  bool isDeleteCloud = await Global.getDeleteCloud();
  Global.setDeleteCloud(isDeleteCloud);
  bool iscustomRename = await Global.getCustomeRename();
  Global.setCustomeRename(iscustomRename);
  String initCustomRenameFormat = await Global.getCustomeRenameFormat();
  Global.setCustomeRenameFormat(initCustomRenameFormat);
  String todayAlistUpdate = await Global.getTodayAlistUpdate();
  Global.setTodayAlistUpdate(todayAlistUpdate);

  //初始化图片压缩选项
  bool isCompress = await Global.getisCompress();
  Global.setisCompress(isCompress);
  int minWidth = await Global.getminWidth();
  Global.setminWidth(minWidth);
  int minHeight = await Global.getminHeight();
  Global.setminHeight(minHeight);
  int quality = await Global.getquality();
  Global.setquality(quality);
  String defaultCompressFormat = await Global.getdefaultCompressFormat();
  Global.setdefaultCompressFormat(defaultCompressFormat);

  //初始化图床相册数据库
  Database db = await Global.getDatabase();
  await Global.setDatabase(db);
  //初始化扩展图床相册数据库
  Database dbExtend = await Global.getDatabaseExtend();
  await Global.setDatabaseExtend(dbExtend);

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
  List<String> tencentUploadList = await Global.getTencentUploadList();
  Global.setTencentUploadList(tencentUploadList);
  List<String> tencentDownloadList = await Global.getTencentDownloadList();
  Global.setTencentDownloadList(tencentDownloadList);
  List<String> aliyunUploadList = await Global.getAliyunUploadList();
  Global.setAliyunUploadList(aliyunUploadList);
  List<String> aliyunDownloadList = await Global.getAliyunDownloadList();
  Global.setAliyunDownloadList(aliyunDownloadList);
  List<String> qiniuUploadList = await Global.getQiniuUploadList();
  Global.setQiniuUploadList(qiniuUploadList);
  List<String> qiniuDownloadList = await Global.getQiniuDownloadList();
  Global.setQiniuDownloadList(qiniuDownloadList);
  List<String> upyunUploadList = await Global.getUpyunUploadList();
  Global.setUpyunUploadList(upyunUploadList);
  List<String> upyunDownloadList = await Global.getUpyunDownloadList();
  Global.setUpyunDownloadList(upyunDownloadList);
  List<String> smmsUploadList = await Global.getSmmsUploadList();
  Global.setSmmsUploadList(smmsUploadList);
  List<String> smmsDownloadList = await Global.getSmmsDownloadList();
  Global.setSmmsDownloadList(smmsDownloadList);
  List<String> smmsSavedNameList = await Global.getSmmsSavedNameList();
  Global.setSmmsSavedNameList(smmsSavedNameList);
  List<String> imgurUploadList = await Global.getImgurUploadList();
  Global.setImgurUploadList(imgurUploadList);
  List<String> imgurDownloadList = await Global.getImgurDownloadList();
  Global.setImgurDownloadList(imgurDownloadList);
  List<String> githubUploadList = await Global.getGithubUploadList();
  Global.setGithubUploadList(githubUploadList);
  List<String> githubDownloadList = await Global.getGithubDownloadList();
  Global.setGithubDownloadList(githubDownloadList);
  List<String> lskyproUploadList = await Global.getLskyproUploadList();
  Global.setLskyproUploadList(lskyproUploadList);
  List<String> lskyproDownloadList = await Global.getLskyproDownloadList();
  Global.setLskyproDownloadList(lskyproDownloadList);
  List<String> ftpUploadList = await Global.getFtpUploadList();
  Global.setFtpUploadList(ftpUploadList);
  List<String> ftpDownloadList = await Global.getFtpDownloadList();
  Global.setFtpDownloadList(ftpDownloadList);
  List<String> awsUploadList = await Global.getAwsUploadList();
  Global.setAwsUploadList(awsUploadList);
  List<String> awsDownloadList = await Global.getAwsDownloadList();
  Global.setAwsDownloadList(awsDownloadList);
  List<String> alistUploadList = await Global.getAlistUploadList();
  Global.setAlistUploadList(alistUploadList);
  List<String> alistDownloadList = await Global.getAlistDownloadList();
  Global.setAlistDownloadList(alistDownloadList);
  List<String> webdavUploadList = await Global.getWebdavUploadList();
  Global.setWebdavUploadList(webdavUploadList);
  List<String> webdavDownloadList = await Global.getWebdavDownloadList();
  Global.setWebdavDownloadList(webdavDownloadList);
}

//获得小图标，图片预览
Widget getImageIcon(String path) {
  try {
    List imageType = ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp'];
    if (imageType
        .contains(path.substring(path.lastIndexOf('.')).toLowerCase())) {
      return Image.file(File(path), width: 30, height: 30, fit: BoxFit.fill);
    } else if (Global.iconList
        .contains(my_path.extension(path).substring(1).toLowerCase())) {
      return Image.asset(
        'assets/icons/${my_path.extension(path).substring(1)}.png',
        width: 30,
        height: 30,
        fit: BoxFit.fill,
      );
    } else {
      return Image.asset('assets/icons/unknown.png',
          width: 30, height: 30, fit: BoxFit.fill);
    }
  } catch (e) {
    return Image.asset('assets/icons/unknown.png',
        width: 30, height: 30, fit: BoxFit.fill);
  }
}
