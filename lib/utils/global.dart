import 'dart:io';

import 'package:external_path/external_path.dart';
import 'package:flustars_flutter3/flustars_flutter3.dart';
import 'package:sqflite/sqflite.dart';

import 'package:horopic/album/album_sql.dart';
import 'package:horopic/picture_host_manage/common_page/picture_host_sql.dart';

//全局共享变量
class UploadedImage {
  String path;
  String url;
  String pbhost;
  UploadedImage({required this.path, required this.url, required this.pbhost});

  UploadedImage.fromMap(Map<String, dynamic> map)
      : assert(map['path'] != null),
        assert(map['url'] != null),
        assert(map['pbhost'] != null),
        path = map['path'],
        url = map['url'],
        pbhost = map['pbhost'];

  Map<String, dynamic> toMap() {
    return {
      'path': path,
      'url': url,
      'pbhost': pbhost,
    };
  }
}

class Global {
  static String? imageFile;
  static File? imageOriginalFile;
  static List<String> imagesList = [];
  static List<File> imagesFileList = [];
  static String defaultPShost = 'lsky.pro'; //默认图床选择
  static String defaultUser = ' '; //默认用户名
  static String defaultPassword = ' '; //默认密码
  static String multiUpload = 'fail';
  static String defaultLKformat = 'rawurl'; //默认链接格式
  static bool isTimeStamp = false; //是否使用时间戳重命名
  static bool isRandomName = false; //是否使用随机字符串重命名
  static bool isCopyLink = true; //是否复制链接
  static Database? imageDB; //默认相册数据库
  static Database? uploadDB; //默认上传数据库
  static Database? downloadDB; //默认下载数据库
  static String defaultShowedPBhost = 'lskypro'; //默认显示的图床
  static bool isDeleteLocal = false; //是否删除本地图片
  static bool isDeleteCloud = false; //是否删除远程图片
  static String customLinkFormat = r'[$fileName]($url)'; //自定义链接格式
  static String qrScanResult = ''; //扫码结果
  static bool iscustomRename = false; //是否自定义重命名
  static String customRenameFormat = r'{Y}_{m}_{d}_{uuid}'; //自定义重命名格式
  static bool operateDone = false;
  static String tencentDownloadFilePath = ''; //腾讯云下载文件路径
  static List psHostHomePageOrder = [0, 1, 2, 3, 4, 5, 6, 7, 8];
  static final List iconList = [
    "_blank",
    "_page",
    "aac",
    "ai",
    "aiff",
    "avi",
    "bmp",
    "c",
    "cpp",
    "css",
    "csv",
    "dat",
    "dmg",
    "doc",
    "dotx",
    "dwg",
    "dxf",
    "eps",
    "exe",
    "flv",
    "gif",
    "h",
    "hpp",
    "html",
    "ics",
    "iso",
    "java",
    "jpeg",
    "jpg",
    "js",
    "key",
    "less",
    "mid",
    "mp3",
    "mp4",
    "mpg",
    "odf",
    "ods",
    "odt",
    "otp",
    "ots",
    "ott",
    "pdf",
    "php",
    "png",
    "ppt",
    "psd",
    "py",
    "qt",
    "rar",
    "rb",
    "rtf",
    "sass",
    "scss",
    "sql",
    "tga",
    "tgz",
    "tiff",
    "txt",
    "wav",
    "xls",
    "xlsx",
    "xml",
    "yml",
    "zip",
    'docx',
    'pptx',
    'xlsx',
  ];

  static getPShost() async {
    await SpUtil.getInstance();
    String pshost = SpUtil.getString('key_pshost', defValue: 'lsky.pro')!;
    return pshost;
  }

  static getUser() async {
    await SpUtil.getInstance();
    String user = SpUtil.getString('key_user', defValue: ' ')!;
    return user;
  }

  static getPassword() async {
    await SpUtil.getInstance();
    String password = SpUtil.getString('key_password', defValue: ' ')!;
    return password;
  }

  static setPShost(String pshost) async {
    await SpUtil.getInstance();
    SpUtil.putString('key_pshost', pshost);
    defaultPShost = pshost;
  }

  static setUser(String user) async {
    await SpUtil.getInstance();
    SpUtil.putString('key_user', user);
    defaultUser = user;
  }

  static setPassword(String password) async {
    await SpUtil.getInstance();
    SpUtil.putString('key_password', password);
    defaultPassword = password;
  }

  static setLKformat(String lkformat) async {
    await SpUtil.getInstance();
    SpUtil.putString('key_lkformat', lkformat);
    defaultLKformat = lkformat;
  }

  static getLKformat() async {
    await SpUtil.getInstance();
    String lkformat = SpUtil.getString('key_lkformat', defValue: 'rawurl')!;
    return lkformat;
  }

  static setTimeStamp(bool isTimeStamp) async {
    await SpUtil.getInstance();
    SpUtil.putBool('key_isTimeStamp', isTimeStamp);
    Global.isTimeStamp = isTimeStamp;
  }

  static getTimeStamp() async {
    await SpUtil.getInstance();
    bool isTimeStamp = SpUtil.getBool('key_isTimeStamp', defValue: false)!;
    return isTimeStamp;
  }

  static setRandomName(bool isRandomName) async {
    await SpUtil.getInstance();
    SpUtil.putBool('key_isRandomName', isRandomName);
    Global.isRandomName = isRandomName;
  }

  static getRandomName() async {
    await SpUtil.getInstance();
    bool isRandomName = SpUtil.getBool('key_isRandomName', defValue: false)!;
    return isRandomName;
  }

  static setCustomeRename(bool iscustomRename) async {
    await SpUtil.getInstance();
    SpUtil.putBool('key_iscustomRename', iscustomRename);
    Global.iscustomRename = iscustomRename;
  }

  static getCustomeRename() async {
    await SpUtil.getInstance();
    bool iscustomRename =
        SpUtil.getBool('key_iscustomRename', defValue: false)!;
    return iscustomRename;
  }

  static setCopyLink(bool isCopyLink) async {
    await SpUtil.getInstance();
    SpUtil.putBool('key_isCopyLink', isCopyLink);
    Global.isCopyLink = isCopyLink;
  }

  static getCopyLink() async {
    await SpUtil.getInstance();
    bool isCopyLink = SpUtil.getBool('key_isCopyLink', defValue: true)!;
    return isCopyLink;
  }

  static getDatabase() async {
    imageDB = await AlbumSQL.getDatabase();
    return imageDB;
  }

  static setDatabase(Database db) async {
    imageDB = db;
  }

  static getUploadDatabase() async {
    uploadDB = await PSHostSQL.getUploadDatabase();
    return uploadDB;
  }

  static setUploadDatabase(Database db) async {
    uploadDB = db;
  }

  static getDownloadDatabase() async {
    downloadDB = await PSHostSQL.getDownloadDatabase();
    return downloadDB;
  }

  static setDownloadDatabase(Database db) async {
    downloadDB = db;
  }

  static setShowedPBhost(String showedPBhost) async {
    await SpUtil.getInstance();
    SpUtil.putString('key_showedPBhost', showedPBhost);
    defaultShowedPBhost = showedPBhost;
  }

  static getShowedPBhost() async {
    await SpUtil.getInstance();
    String showedPBhost =
        SpUtil.getString('key_showedPBhost', defValue: 'lskypro')!;
    return showedPBhost;
  }

  static setDeleteLocal(bool isDeleteLocal) async {
    await SpUtil.getInstance();
    SpUtil.putBool('key_isDeleteLocal', isDeleteLocal);
    Global.isDeleteLocal = isDeleteLocal;
  }

  static getDeleteLocal() async {
    await SpUtil.getInstance();
    bool isDeleteLocal = SpUtil.getBool('key_isDeleteLocal', defValue: false)!;
    return isDeleteLocal;
  }

  static setCustomLinkFormat(String customLinkFormat) async {
    await SpUtil.getInstance();
    SpUtil.putString('key_customLinkFormat', customLinkFormat);
    Global.customLinkFormat = customLinkFormat;
  }

  static getCustomLinkFormat() async {
    await SpUtil.getInstance();
    String customLinkFormat = SpUtil.getString('key_customLinkFormat',
        defValue: r'[$fileName]($url)')!;
    return customLinkFormat;
  }

  static setCustomeRenameFormat(String customRenameFormat) async {
    await SpUtil.getInstance();
    SpUtil.putString('key_customRenameFormat', customRenameFormat);
    Global.customRenameFormat = customRenameFormat;
  }

  static getCustomeRenameFormat() async {
    await SpUtil.getInstance();
    String customRenameFormat =
        SpUtil.getString('key_customRenameFormat', defValue: r'${filename}')!;
    return customRenameFormat;
  }

  static setDeleteCloud(bool isDeleteCloud) async {
    await SpUtil.getInstance();
    SpUtil.putBool('key_isDeleteCloud', isDeleteCloud);
    Global.isDeleteCloud = isDeleteCloud;
  }

  static getDeleteCloud() async {
    await SpUtil.getInstance();
    bool isDeleteCloud = SpUtil.getBool('key_isDeleteCloud', defValue: false)!;
    return isDeleteCloud;
  }

  static setOperateDone(bool operateDone) async {
    await SpUtil.getInstance();
    SpUtil.putBool('key_operateDone', operateDone);
    Global.operateDone = operateDone;
  }

  static getOperateDone() async {
    await SpUtil.getInstance();
    bool operateDone = SpUtil.getBool('key_operateDone', defValue: false)!;
    return operateDone;
  }

  static setTencentDownloadFilePath(String tencentDownloadFilePath) async {
    await SpUtil.getInstance();
    SpUtil.putString('key_tencentDownloadFilePath', tencentDownloadFilePath);
    Global.tencentDownloadFilePath = tencentDownloadFilePath;
  }

  static getTencentDownloadFilePath() async {
    await SpUtil.getInstance();
    String externalStorageDirectory =
        await ExternalPath.getExternalStoragePublicDirectory(
            ExternalPath.DIRECTORY_DOWNLOADS);
    externalStorageDirectory =
        '$externalStorageDirectory/PicHoro/Download/tencent';
    String tencentDownloadFilePath = SpUtil.getString(
        'key_tencentDownloadFilePath',
        defValue: externalStorageDirectory)!;
    return tencentDownloadFilePath;
  }

  static setpsHostHomePageOrder(List<String> psHostHomePageOrder) async {
    await SpUtil.getInstance();
    SpUtil.putStringList('key_psHostHomePageOrder', psHostHomePageOrder);
    Global.psHostHomePageOrder = psHostHomePageOrder;
  }

  static getpsHostHomePageOrder() async {
    await SpUtil.getInstance();
    List psHostHomePageOrder = SpUtil.getStringList('key_psHostHomePageOrder',
        defValue: ['0', '1', '2', '3', '4', '5', '6', '7', '8'])!;
    return psHostHomePageOrder;
  }
}
