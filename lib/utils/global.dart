import 'dart:io';
import 'package:flustars_flutter3/flustars_flutter3.dart';
//全局共享变量

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
}
