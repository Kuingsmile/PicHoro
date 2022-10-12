import 'dart:io';
import 'package:flustars_flutter3/flustars_flutter3.dart';
//全局共享变量
import 'package:sqflite/sqflite.dart';
import 'package:horopic/album/albumSQL.dart';

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
  static File? imageFile;
  static List<File> imagesList = [];
  static String defaultPShost = 'lsky.pro'; //默认图床选择
  static String defaultUser = ' '; //默认用户名
  static String defaultPassword = ' '; //默认密码
  static String multiUpload = 'fail';
  static String defaultLKformat = 'rawurl'; //默认链接格式
  static bool isTimeStamp = false; //是否使用时间戳重命名
  static bool isRandomName = false; //是否使用随机名重命名
  static bool isCopyLink = true; //是否复制链接
  static Database? imageDB; //默认数据库
  static String defaultShowedPBhost = 'lskypro'; //默认显示的图床
  static bool isDeleteLocal = false; //是否删除本地图片
  static bool isDeleteCloud = false; //是否删除远程图片
  static String customLinkFormat = r'[${fileName}][${url}]'; //自定义链接格式
  static String qrScanResult = ''; //扫码结果


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
    String customLinkFormat =
        SpUtil.getString('key_customLinkFormat', defValue: 'rawurl')!;
    return customLinkFormat;
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
}
