import 'dart:io';

import 'package:flustars_flutter3/flustars_flutter3.dart';
import 'package:sqflite/sqflite.dart';

import 'package:horopic/album/album_sql.dart';

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
  static Database? imageDBExtend; //扩展相册数据库
  static String defaultShowedPBhost = 'lskypro'; //默认显示的图床
  static bool isDeleteLocal = false; //是否删除本地图片
  static bool isDeleteCloud = false; //是否删除远程图片
  static String customLinkFormat = r'[$fileName]($url)'; //自定义链接格式
  static String qrScanResult = ''; //扫码结果
  static bool iscustomRename = false; //是否自定义重命名
  static String customRenameFormat = r'{Y}_{m}_{d}_{uuid}'; //自定义重命名格式
  static bool operateDone = false;
  static List psHostHomePageOrder = [
    0,
    1,
    2,
    3,
    4,
    5,
    6,
    7,
    8,
    9,
    10,
    11,
    12,
    13,
    14,
    15,
    16,
    17,
    18,
    19,
    20,
    21,
  ]; //图床首页顺序
  //图床管理上传下载页面的任务保存列表
  static List<String> tencentDownloadList = [];
  static List<String> tencentUploadList = [];
  static List<String> qiniuDownloadList = [];
  static List<String> qiniuUploadList = [];
  static List<String> smmsDownloadList = [];
  static List<String> smmsSavedNameList = [];
  static List<String> smmsUploadList = [];
  static List<String> upyunDownloadList = [];
  static List<String> upyunUploadList = [];
  static List<String> imgurDownloadList = [];
  static List<String> imgurUploadList = [];
  static List<String> githubDownloadList = [];
  static List<String> githubUploadList = [];
  static List<String> lskyproDownloadList = [];
  static List<String> lskyproUploadList = [];
  static List<String> aliyunDownloadList = [];
  static List<String> aliyunUploadList = [];
  static List<String> ftpDownloadList = [];
  static List<String> ftpUploadList = [];

  static final List iconList = [
    "_blank",
    "_page",
    "7z",
    "aac",
    "accdb",
    "adt",
    "ai",
    "aiff",
    "aly",
    "amiga",
    "amr",
    "ape",
    "apk",
    "arj",
    "asf",
    "asm",
    "asx",
    "au",
    "avc",
    "avi",
    "avs",
    "bak",
    "bas",
    "bat",
    "bmp",
    "bom",
    "c",
    "cda",
    "cdr",
    "chm",
    "class",
    "cmd",
    "com",
    "cpp",
    "css",
    "csv",
    "dat",
    "dart",
    "ddb",
    "dif",
    "divx",
    "dll",
    "dmg",
    "doc",
    "docm",
    "docx",
    "dot",
    "dotm",
    "dotx",
    "dsl",
    "dv",
    "dvd",
    "dvdaudio",
    "dwg",
    "dxf",
    "emf",
    "env",
    "eot",
    "eps",
    "exe",
    "exif",
    "flc",
    "fli",
    "flv",
    "folder",
    "fon",
    "font",
    "for",
    "fpx",
    "fv",
    "3g2",
    "gif",
    "3gp",
    "gz",
    "gitingore",
    "gitkeep",
    "h",
    "hdri",
    "hlp",
    "hpp",
    "htm",
    "html",
    "ics",
    "ico",
    "int",
    "iso",
    "ipynb",
    "java",
    "jpeg",
    "jpg",
    "js",
    "json",
    "key",
    "ksp",
    "less",
    "lib",
    "lic",
    "log",
    "lst",
    "lua",
    "license",
    "mac",
    "map",
    "markdown",
    "md",
    "mdf",
    "mht",
    "mhtml",
    "mid",
    "midi",
    "mkv",
    "mmf",
    "mod",
    "mov",
    "mp3",
    "mp4",
    "mpa",
    "mpe",
    "mpeg",
    "mpeg1",
    "mp2",
    "mpeg2",
    "mpg",
    "mppro",
    "msg",
    "mts",
    "mux",
    "mv",
    "navi",
    "obj",
    "odf",
    "ods",
    "odt",
    "ogg",
    "one",
    "otf",
    "otp",
    "ots",
    "ott",
    "pas",
    "pcd",
    "pcx",
    "pdf",
    "php",
    "pic",
    "png",
    "ppt",
    "pptx",
    "proe",
    "prt",
    "psd",
    "py",
    "pyc",
    "qsv",
    "qt",
    "quicktime",
    "ra",
    "ram",
    "rar",
    "raw",
    "rb",
    "realaudio",
    "rm",
    "rmvb",
    "rp",
    "rtf",
    "s48",
    "sacd",
    "sass",
    "sch",
    "scss",
    "sh",
    "sql",
    "stp",
    "svcd",
    "svg",
    "swf",
    "sys",
    "tga",
    "tgz",
    "tiff",
    "tmp",
    "ts",
    "ttc",
    "ttf",
    "txt",
    "ufo",
    "unknown",
    "vcd",
    "vob",
    "voc",
    "vqf",
    "vue",
    "wav",
    "wdl",
    "webm",
    "wki",
    "wma",
    "wmf",
    "wmv",
    "wmvhd",
    "woff",
    "woff2",
    "wps",
    "wpt",
    "x_t",
    "xls",
    "xlsm",
    "xlsx",
    "xlt",
    "xltm",
    "xltx",
    "xmind",
    "xml",
    "xv",
    "xvid",
    "yml",
    "yaml",
    "z",
    "zip",
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

  static getDatabaseExtend() async {
    imageDBExtend = await AlbumSQL.getExtendDatabase();
    return imageDBExtend;
  }

  static setDatabaseExtend(Database db) async {
    imageDBExtend = db;
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
        SpUtil.getString('key_customRenameFormat', defValue: r'{filename}')!;
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

  static setpsHostHomePageOrder(List<String> psHostHomePageOrder) async {
    await SpUtil.getInstance();
    SpUtil.putStringList('key_psHostHomePageOrder', psHostHomePageOrder);
    Global.psHostHomePageOrder = psHostHomePageOrder;
  }

  static getpsHostHomePageOrder() async {
    await SpUtil.getInstance();
    List psHostHomePageOrder =
        SpUtil.getStringList('key_psHostHomePageOrder', defValue: [
      '0',
      '1',
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
      '8',
      '9',
      '10',
      '11',
      '12',
      '13',
      '14',
      '15',
      '16',
      '17',
      '18',
      '19',
      '20',
      '21',
    ])!;
    return psHostHomePageOrder;
  }

  static setTencentUploadList(List<String> tencentUploadList) async {
    await SpUtil.getInstance();
    SpUtil.putStringList('key_tencentUploadList', tencentUploadList);
    Global.tencentUploadList = tencentUploadList;
  }

  static getTencentUploadList() async {
    await SpUtil.getInstance();
    List tencentUploadList =
        SpUtil.getStringList('key_tencentUploadList', defValue: [])!;
    return tencentUploadList;
  }

  static setTencentDownloadList(List<String> tencentDownloadList) async {
    await SpUtil.getInstance();
    SpUtil.putStringList('key_tencentDownloadList', tencentDownloadList);
    Global.tencentDownloadList = tencentDownloadList;
  }

  static getTencentDownloadList() async {
    await SpUtil.getInstance();
    List tencentDownloadList =
        SpUtil.getStringList('key_tencentDownloadList', defValue: [])!;
    return tencentDownloadList;
  }

  static setAliyunUploadList(List<String> aliyunUploadList) async {
    await SpUtil.getInstance();
    SpUtil.putStringList('key_aliyunUploadList', aliyunUploadList);
    Global.aliyunUploadList = aliyunUploadList;
  }

  static getAliyunUploadList() async {
    await SpUtil.getInstance();
    List aliyunUploadList =
        SpUtil.getStringList('key_aliyunUploadList', defValue: [])!;
    return aliyunUploadList;
  }

  static setAliyunDownloadList(List<String> aliyunDownloadList) async {
    await SpUtil.getInstance();
    SpUtil.putStringList('key_aliyunDownloadList', aliyunDownloadList);
    Global.aliyunDownloadList = aliyunDownloadList;
  }

  static getAliyunDownloadList() async {
    await SpUtil.getInstance();
    List aliyunDownloadList =
        SpUtil.getStringList('key_aliyunDownloadList', defValue: [])!;
    return aliyunDownloadList;
  }

  static setUpyunUploadList(List<String> upyunUploadList) async {
    await SpUtil.getInstance();
    SpUtil.putStringList('key_upyunUploadList', upyunUploadList);
    Global.upyunUploadList = upyunUploadList;
  }

  static getUpyunUploadList() async {
    await SpUtil.getInstance();
    List upyunUploadList =
        SpUtil.getStringList('key_upyunUploadList', defValue: [])!;
    return upyunUploadList;
  }

  static setUpyunDownloadList(List<String> upyunDownloadList) async {
    await SpUtil.getInstance();
    SpUtil.putStringList('key_upyunDownloadList', upyunDownloadList);
    Global.upyunDownloadList = upyunDownloadList;
  }

  static getUpyunDownloadList() async {
    await SpUtil.getInstance();
    List upyunDownloadList =
        SpUtil.getStringList('key_upyunDownloadList', defValue: [])!;
    return upyunDownloadList;
  }

  static setQiniuUploadList(List<String> qiniuUploadList) async {
    await SpUtil.getInstance();
    SpUtil.putStringList('key_qiniuUploadList', qiniuUploadList);
    Global.qiniuUploadList = qiniuUploadList;
  }

  static getQiniuUploadList() async {
    await SpUtil.getInstance();
    List qiniuUploadList =
        SpUtil.getStringList('key_qiniuUploadList', defValue: [])!;
    return qiniuUploadList;
  }

  static setQiniuDownloadList(List<String> qiniuDownloadList) async {
    await SpUtil.getInstance();
    SpUtil.putStringList('key_qiniuDownloadList', qiniuDownloadList);
    Global.qiniuDownloadList = qiniuDownloadList;
  }

  static getQiniuDownloadList() async {
    await SpUtil.getInstance();
    List qiniuDownloadList =
        SpUtil.getStringList('key_qiniuDownloadList', defValue: [])!;
    return qiniuDownloadList;
  }

  static setImgurUploadList(List<String> imgurUploadList) async {
    await SpUtil.getInstance();
    SpUtil.putStringList('key_imgurUploadList', imgurUploadList);
    Global.imgurUploadList = imgurUploadList;
  }

  static getImgurUploadList() async {
    await SpUtil.getInstance();
    List imgurUploadList =
        SpUtil.getStringList('key_imgurUploadList', defValue: [])!;
    return imgurUploadList;
  }

  static setImgurDownloadList(List<String> imgurDownloadList) async {
    await SpUtil.getInstance();
    SpUtil.putStringList('key_imgurDownloadList', imgurDownloadList);
    Global.imgurDownloadList = imgurDownloadList;
  }

  static getImgurDownloadList() async {
    await SpUtil.getInstance();
    List imgurDownloadList =
        SpUtil.getStringList('key_imgurDownloadList', defValue: [])!;
    return imgurDownloadList;
  }

  static setSmmsUploadList(List<String> smmsUploadList) async {
    await SpUtil.getInstance();
    SpUtil.putStringList('key_smmsUploadList', smmsUploadList);
    Global.smmsUploadList = smmsUploadList;
  }

  static getSmmsUploadList() async {
    await SpUtil.getInstance();
    List smmsUploadList =
        SpUtil.getStringList('key_smmsUploadList', defValue: [])!;
    return smmsUploadList;
  }

  static setSmmsDownloadList(List<String> smmsDownloadList) async {
    await SpUtil.getInstance();
    SpUtil.putStringList('key_smmsDownloadList', smmsDownloadList);
    Global.smmsDownloadList = smmsDownloadList;
  }

  static getSmmsDownloadList() async {
    await SpUtil.getInstance();
    List smmsDownloadList =
        SpUtil.getStringList('key_smmsDownloadList', defValue: [])!;
    return smmsDownloadList;
  }

  static setSmmsSavedNameList(List<String> smmsSavedNameList) async {
    await SpUtil.getInstance();
    SpUtil.putStringList('key_smmsSavedNameList', smmsSavedNameList);
    Global.smmsSavedNameList = smmsSavedNameList;
  }

  static getSmmsSavedNameList() async {
    await SpUtil.getInstance();
    List smmsSavedNameList =
        SpUtil.getStringList('key_smmsSavedNameList', defValue: [])!;
    return smmsSavedNameList;
  }

  static setGithubUploadList(List<String> githubUploadList) async {
    await SpUtil.getInstance();
    SpUtil.putStringList('key_githubUploadList', githubUploadList);
    Global.githubUploadList = githubUploadList;
  }

  static getGithubUploadList() async {
    await SpUtil.getInstance();
    List githubUploadList =
        SpUtil.getStringList('key_githubUploadList', defValue: [])!;
    return githubUploadList;
  }

  static setGithubDownloadList(List<String> githubDownloadList) async {
    await SpUtil.getInstance();
    SpUtil.putStringList('key_githubDownloadList', githubDownloadList);
    Global.githubDownloadList = githubDownloadList;
  }

  static getGithubDownloadList() async {
    await SpUtil.getInstance();
    List githubDownloadList =
        SpUtil.getStringList('key_githubDownloadList', defValue: [])!;
    return githubDownloadList;
  }

  static setLskyproUploadList(List<String> lskyproUploadList) async {
    await SpUtil.getInstance();
    SpUtil.putStringList('key_lskyproUploadList', lskyproUploadList);
    Global.lskyproUploadList = lskyproUploadList;
  }

  static getLskyproUploadList() async {
    await SpUtil.getInstance();
    List lskyproUploadList =
        SpUtil.getStringList('key_lskyproUploadList', defValue: [])!;
    return lskyproUploadList;
  }

  static setLskyproDownloadList(List<String> lskyproDownloadList) async {
    await SpUtil.getInstance();
    SpUtil.putStringList('key_lskyproDownloadList', lskyproDownloadList);
    Global.lskyproDownloadList = lskyproDownloadList;
  }

  static getLskyproDownloadList() async {
    await SpUtil.getInstance();
    List lskyproDownloadList =
        SpUtil.getStringList('key_lskyproDownloadList', defValue: [])!;
    return lskyproDownloadList;
  }

  static setFtpUploadList(List<String> ftpUploadList) async {
    await SpUtil.getInstance();
    SpUtil.putStringList('key_ftpUploadList', ftpUploadList);
    Global.ftpUploadList = ftpUploadList;
  }

  static getFtpUploadList() async {
    await SpUtil.getInstance();
    List ftpUploadList =
        SpUtil.getStringList('key_ftpUploadList', defValue: [])!;
    return ftpUploadList;
  }

  static setFtpDownloadList(List<String> ftpDownloadList) async {
    await SpUtil.getInstance();
    SpUtil.putStringList('key_ftpDownloadList', ftpDownloadList);
    Global.ftpDownloadList = ftpDownloadList;
  }

  static getFtpDownloadList() async {
    await SpUtil.getInstance();
    List ftpDownloadList =
        SpUtil.getStringList('key_ftpDownloadList', defValue: [])!;
    return ftpDownloadList;
  }
}
