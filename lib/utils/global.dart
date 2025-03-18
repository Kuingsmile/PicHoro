import 'dart:io';
import 'package:flustars_flutter3/flustars_flutter3.dart';
import 'package:sqflite/sqflite.dart';

import 'package:horopic/album/album_sql.dart';

class Global {
  /// 上传图片的文件名
  static String? imageFile;

  /// 原始图片文件
  static File? imageOriginalFile;

  /// 上传图片的文件名列表
  static List<String> imagesList = [];

  /// 上传图片的文件列表
  static List<File> imagesFileList = [];

  /// 默认上传图床
  static String defaultPShost = 'lsky.pro';

  /// 默认用户名
  static String defaultUser = ' ';

  /// 默认密码
  static String defaultPassword = ' ';
  static String multiUpload = 'fail';

  /// 是否复制链接
  static bool isCopyLink = true;

  /// 复制时是否URL编码
  static bool isURLEncode = false;

  /// 默认复制链接格式
  static String defaultLKformat = 'rawurl';

  /// 自定义链接格式
  static String customLinkFormat = r'![$fileName]($url)';

  /// 是否使用时间戳重命名
  static bool isTimeStamp = false;

  /// 是否使用随机字符串重命名
  static bool isRandomName = false;

  /// 是否自定义重命名
  static bool isCustomRename = false;

  /// 自定义重命名格式
  static String customRenameFormat = r'{Y}{m}{d}{h}{i}{ms}';

  /// 默认相册数据库
  static Database? imageDB;

  /// 扩展相册数据库
  static Database? imageDBExtend;

  /// 相册默认显示的图床
  static String defaultShowedPBhost = 'lskypro';

  /// 是否删除本地图片
  static bool isDeleteLocal = false;

  /// 是否删除远程图片
  static bool isDeleteCloud = false;

  /// 导入扫码结果
  static String qrScanResult = '';

  /// 是否操作完成
  static bool operateDone = false;

  /// AList更新token时间
  static String todayAlistUpdate = '19700101';

  /// 是否压缩图片
  static bool isCompress = false;

  /// 图片压缩最小宽度
  static int minWidth = 1920;

  /// 图片压缩最小高度
  static int minHeight = 1080;

  /// 图片压缩质量
  static int quality = 80;

  /// 图片压缩格式
  static String defaultCompressFormat = 'webp';

  /// 默认网络请求超时时间
  static int defaultOutTime = 30000;

  /// 默认multipart/form-data
  static String multipartString = "multipart/form-data; boundary=----WebKitFormBoundary7MA4YWxkTrZu0gW";
  static Map<String, String> bucketCustomUrl = {};
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
  static List<String> awsDownloadList = [];
  static List<String> awsUploadList = [];
  static List<String> alistDownloadList = [];
  static List<String> alistUploadList = [];
  static List<String> webdavDownloadList = [];
  static List<String> webdavUploadList = [];

  static final List iconList = [
    "3g2",
    "3gp",
    "7z",
    "_page",
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
    "dart",
    "dat",
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
    "gif",
    "gitingore",
    "gitkeep",
    "gz",
    "h",
    "hdri",
    "hlp",
    "hpp",
    "htm",
    "html",
    "ico",
    "ics",
    "int",
    "ipynb",
    "iso",
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
    "license",
    "log",
    "lst",
    "lua",
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
    "mp2",
    "mp3",
    "mp4",
    "mpa",
    "mpe",
    "mpeg",
    "mpeg1",
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
    "webp",
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
    "yaml",
    "yml",
    "z",
    "zip",
    "_blank",
  ];

  static List textExt = [
    "bat",
    "c",
    "cmd",
    "conf",
    "config",
    "cpp",
    "css",
    "csv",
    "dart",
    "gitattributes",
    "gitconfig",
    "gitignore",
    "gitkeep",
    "gitmodules",
    "go",
    "h",
    "hpp",
    "htm",
    "html",
    "ini",
    "java",
    "js",
    "json",
    "log",
    "php",
    "prop",
    "properties",
    "py",
    "rc",
    "sh",
    "tsv",
    "txt",
    "xml",
    "yaml",
    "yml",
    "md",
  ];

  static List imgExt = [
    'bmp',
    'gif',
    'heif',
    'ico',
    'jpeg',
    'png',
    'svg',
    'tif',
    'tiff',
    'webp',
    'jpg',
  ];

  static String getPShost() {
    return SpUtil.getString('key_pshost', defValue: 'lsky.pro')!;
  }

  static void setPShost(String pshost) {
    SpUtil.putString('key_pshost', pshost);
    defaultPShost = pshost;
  }

  static String getUser() {
    return SpUtil.getString('key_user', defValue: ' ')!;
  }

  static void setUser(String user) {
    SpUtil.putString('key_user', user);
    defaultUser = user;
  }

  static String getPassword() {
    return SpUtil.getString('key_password', defValue: ' ')!;
  }

  static void setPassword(String password) {
    SpUtil.putString('key_password', password);
    defaultPassword = password;
  }

  static String getLKformat() {
    return SpUtil.getString('key_lkformat', defValue: 'rawurl')!;
  }

  static void setLKformat(String lkformat) {
    SpUtil.putString('key_lkformat', lkformat);
    defaultLKformat = lkformat;
  }

  static bool getIsTimeStamp() {
    return SpUtil.getBool('key_isTimeStamp', defValue: false)!;
  }

  static void setIsTimeStamp(bool isTimeStamp) {
    SpUtil.putBool('key_isTimeStamp', isTimeStamp);
    Global.isTimeStamp = isTimeStamp;
  }

  static bool getIsRandomName() {
    return SpUtil.getBool('key_isRandomName', defValue: false)!;
  }

  static void setIsRandomName(bool isRandomName) {
    SpUtil.putBool('key_isRandomName', isRandomName);
    Global.isRandomName = isRandomName;
  }

  static bool getIsCustomeRename() {
    return SpUtil.getBool('key_iscustomRename', defValue: false)!;
  }

  static void setIsCustomeRename(bool iscustomRename) {
    SpUtil.putBool('key_iscustomRename', iscustomRename);
    Global.isCustomRename = iscustomRename;
  }

  static bool getIsCopyLink() {
    return SpUtil.getBool('key_isCopyLink', defValue: true)!;
  }

  static void setIsCopyLink(bool isCopyLink) {
    SpUtil.putBool('key_isCopyLink', isCopyLink);
    Global.isCopyLink = isCopyLink;
  }

  static bool getIsURLEncode() {
    return SpUtil.getBool('key_isURLEncode', defValue: false)!;
  }

  static void setIsURLEncode(bool isURLEncode) {
    SpUtil.putBool('key_isURLEncode', isURLEncode);
    Global.isURLEncode = isURLEncode;
  }

  static getDatabase() async {
    return await AlbumSQL.getDatabase();
  }

  static setDatabase(Database db) async {
    imageDB = db;
  }

  static getDatabaseExtend() async {
    return await AlbumSQL.getExtendDatabase();
  }

  static setDatabaseExtend(Database db) async {
    imageDBExtend = db;
  }

  static String getShowedPBhost() {
    return SpUtil.getString('key_showedPBhost', defValue: 'lskypro')!;
  }

  static void setShowedPBhost(String showedPBhost) {
    SpUtil.putString('key_showedPBhost', showedPBhost);
    defaultShowedPBhost = showedPBhost;
  }

  static bool getIsDeleteLocal() {
    return SpUtil.getBool('key_isDeleteLocal', defValue: false)!;
  }

  static void setIsDeleteLocal(bool isDeleteLocal) {
    SpUtil.putBool('key_isDeleteLocal', isDeleteLocal);
    Global.isDeleteLocal = isDeleteLocal;
  }

  static Map<String, String> getBucketCustomUrl() {
    return SpUtil.getObj('key_bucketCustomUrl', (v) => Map<String, String>.from(v), defValue: {})!;
  }

  static void setBucketCustomUrl(Map<String, String> bucketCustomUrl) {
    SpUtil.putObject('key_bucketCustomUrl', bucketCustomUrl);
    Global.bucketCustomUrl = bucketCustomUrl;
  }

  static String getCustomLinkFormat() {
    return SpUtil.getString('key_customLinkFormat', defValue: r'[$fileName]($url)')!;
  }

  static void setCustomLinkFormat(String customLinkFormat) {
    SpUtil.putString('key_customLinkFormat', customLinkFormat);
    Global.customLinkFormat = customLinkFormat;
  }

  static String getCustomeRenameFormat() {
    return SpUtil.getString('key_customRenameFormat', defValue: r'{filename}')!;
  }

  static void setCustomeRenameFormat(String customRenameFormat) {
    SpUtil.putString('key_customRenameFormat', customRenameFormat);
    Global.customRenameFormat = customRenameFormat;
  }

  static bool getIsDeleteCloud() {
    return SpUtil.getBool('key_isDeleteCloud', defValue: false)!;
  }

  static void setIsDeleteCloud(bool isDeleteCloud) {
    SpUtil.putBool('key_isDeleteCloud', isDeleteCloud);
    Global.isDeleteCloud = isDeleteCloud;
  }

  static bool getOperateDone() {
    return SpUtil.getBool('key_operateDone', defValue: false)!;
  }

  static void setOperateDone(bool operateDone) {
    SpUtil.putBool('key_operateDone', operateDone);
    Global.operateDone = operateDone;
  }

  static bool getIsCompress() {
    return SpUtil.getBool('key_isCompress', defValue: false)!;
  }

  static void setIsCompress(bool isCompress) {
    SpUtil.putBool('key_isCompress', isCompress);
    Global.isCompress = isCompress;
  }

  static int getminWidth() {
    return SpUtil.getInt('key_minWidth', defValue: 1920)!;
  }

  static void setminWidth(int minWidth) {
    SpUtil.putInt('key_minWidth', minWidth);
    Global.minWidth = minWidth;
  }

  static int getminHeight() {
    return SpUtil.getInt('key_minHeight', defValue: 1080)!;
  }

  static void setminHeight(int minHeight) {
    SpUtil.putInt('key_minHeight', minHeight);
    Global.minHeight = minHeight;
  }

  static int getQuality() {
    return SpUtil.getInt('key_quality', defValue: 80)!;
  }

  static void setQuality(int quality) {
    SpUtil.putInt('key_quality', quality);
    Global.quality = quality;
  }

  static String getDefaultCompressFormat() {
    return SpUtil.getString('key_defaultCompressFormat', defValue: 'webp')!;
  }

  static void setDefaultCompressFormat(String defaultCompressFormat) {
    SpUtil.putString('key_defaultCompressFormat', defaultCompressFormat);
    Global.defaultCompressFormat = defaultCompressFormat;
  }

  static void setpsHostHomePageOrder(List<String> psHostHomePageOrder) {
    SpUtil.putStringList('key_psHostHomePageOrder', psHostHomePageOrder);
    Global.psHostHomePageOrder = psHostHomePageOrder;
  }

  static List<String> getpsHostHomePageOrder() {
    return SpUtil.getStringList('key_psHostHomePageOrder', defValue: [
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
  }

  static void setTencentUploadList(List<String> tencentUploadList) {
    SpUtil.putStringList('key_tencentUploadList', tencentUploadList);
    Global.tencentUploadList = tencentUploadList;
  }

  static List<String> getTencentUploadList() {
    return SpUtil.getStringList('key_tencentUploadList', defValue: [])!;
  }

  static void setTencentDownloadList(List<String> tencentDownloadList) {
    SpUtil.putStringList('key_tencentDownloadList', tencentDownloadList);
    Global.tencentDownloadList = tencentDownloadList;
  }

  static List<String> getTencentDownloadList() {
    return SpUtil.getStringList('key_tencentDownloadList', defValue: [])!;
  }

  static void setAliyunUploadList(List<String> aliyunUploadList) {
    SpUtil.putStringList('key_aliyunUploadList', aliyunUploadList);
    Global.aliyunUploadList = aliyunUploadList;
  }

  static List<String> getAliyunUploadList() {
    return SpUtil.getStringList('key_aliyunUploadList', defValue: [])!;
  }

  static void setAliyunDownloadList(List<String> aliyunDownloadList) {
    SpUtil.putStringList('key_aliyunDownloadList', aliyunDownloadList);
    Global.aliyunDownloadList = aliyunDownloadList;
  }

  static List<String> getAliyunDownloadList() {
    return SpUtil.getStringList('key_aliyunDownloadList', defValue: [])!;
  }

  static void setUpyunUploadList(List<String> upyunUploadList) {
    SpUtil.putStringList('key_upyunUploadList', upyunUploadList);
    Global.upyunUploadList = upyunUploadList;
  }

  static List<String> getUpyunUploadList() {
    return SpUtil.getStringList('key_upyunUploadList', defValue: [])!;
  }

  static void setUpyunDownloadList(List<String> upyunDownloadList) {
    SpUtil.putStringList('key_upyunDownloadList', upyunDownloadList);
    Global.upyunDownloadList = upyunDownloadList;
  }

  static List<String> getUpyunDownloadList() {
    return SpUtil.getStringList('key_upyunDownloadList', defValue: [])!;
  }

  static void setQiniuUploadList(List<String> qiniuUploadList) {
    SpUtil.putStringList('key_qiniuUploadList', qiniuUploadList);
    Global.qiniuUploadList = qiniuUploadList;
  }

  static List<String> getQiniuUploadList() {
    return SpUtil.getStringList('key_qiniuUploadList', defValue: [])!;
  }

  static void setQiniuDownloadList(List<String> qiniuDownloadList) {
    SpUtil.putStringList('key_qiniuDownloadList', qiniuDownloadList);
    Global.qiniuDownloadList = qiniuDownloadList;
  }

  static List<String> getQiniuDownloadList() {
    return SpUtil.getStringList('key_qiniuDownloadList', defValue: [])!;
  }

  static void setImgurUploadList(List<String> imgurUploadList) {
    SpUtil.putStringList('key_imgurUploadList', imgurUploadList);
    Global.imgurUploadList = imgurUploadList;
  }

  static List<String> getImgurUploadList() {
    return SpUtil.getStringList('key_imgurUploadList', defValue: [])!;
  }

  static void setImgurDownloadList(List<String> imgurDownloadList) {
    SpUtil.putStringList('key_imgurDownloadList', imgurDownloadList);
    Global.imgurDownloadList = imgurDownloadList;
  }

  static List<String> getImgurDownloadList() {
    return SpUtil.getStringList('key_imgurDownloadList', defValue: [])!;
  }

  static void setSmmsUploadList(List<String> smmsUploadList) {
    SpUtil.putStringList('key_smmsUploadList', smmsUploadList);
    Global.smmsUploadList = smmsUploadList;
  }

  static List<String> getSmmsUploadList() {
    return SpUtil.getStringList('key_smmsUploadList', defValue: [])!;
  }

  static void setSmmsDownloadList(List<String> smmsDownloadList) {
    SpUtil.putStringList('key_smmsDownloadList', smmsDownloadList);
    Global.smmsDownloadList = smmsDownloadList;
  }

  static List<String> getSmmsDownloadList() {
    return SpUtil.getStringList('key_smmsDownloadList', defValue: [])!;
  }

  static void setSmmsSavedNameList(List<String> smmsSavedNameList) {
    SpUtil.putStringList('key_smmsSavedNameList', smmsSavedNameList);
    Global.smmsSavedNameList = smmsSavedNameList;
  }

  static List<String> getSmmsSavedNameList() {
    return SpUtil.getStringList('key_smmsSavedNameList', defValue: [])!;
  }

  static void setGithubUploadList(List<String> githubUploadList) {
    SpUtil.putStringList('key_githubUploadList', githubUploadList);
    Global.githubUploadList = githubUploadList;
  }

  static List<String> getGithubUploadList() {
    return SpUtil.getStringList('key_githubUploadList', defValue: [])!;
  }

  static void setGithubDownloadList(List<String> githubDownloadList) {
    SpUtil.putStringList('key_githubDownloadList', githubDownloadList);
    Global.githubDownloadList = githubDownloadList;
  }

  static List<String> getGithubDownloadList() {
    return SpUtil.getStringList('key_githubDownloadList', defValue: [])!;
  }

  static void setLskyproUploadList(List<String> lskyproUploadList) {
    SpUtil.putStringList('key_lskyproUploadList', lskyproUploadList);
    Global.lskyproUploadList = lskyproUploadList;
  }

  static List<String> getLskyproUploadList() {
    return SpUtil.getStringList('key_lskyproUploadList', defValue: [])!;
  }

  static void setLskyproDownloadList(List<String> lskyproDownloadList) {
    SpUtil.putStringList('key_lskyproDownloadList', lskyproDownloadList);
    Global.lskyproDownloadList = lskyproDownloadList;
  }

  static List<String> getLskyproDownloadList() {
    return SpUtil.getStringList('key_lskyproDownloadList', defValue: [])!;
  }

  static void setFtpUploadList(List<String> ftpUploadList) {
    SpUtil.putStringList('key_ftpUploadList', ftpUploadList);
    Global.ftpUploadList = ftpUploadList;
  }

  static List<String> getFtpUploadList() {
    return SpUtil.getStringList('key_ftpUploadList', defValue: [])!;
  }

  static void setFtpDownloadList(List<String> ftpDownloadList) {
    SpUtil.putStringList('key_ftpDownloadList', ftpDownloadList);
    Global.ftpDownloadList = ftpDownloadList;
  }

  static List<String> getFtpDownloadList() {
    return SpUtil.getStringList('key_ftpDownloadList', defValue: [])!;
  }

  static void setAwsUploadList(List<String> awsUploadList) {
    SpUtil.putStringList('key_awsUploadList', awsUploadList);
    Global.awsUploadList = awsUploadList;
  }

  static List<String> getAwsUploadList() {
    return SpUtil.getStringList('key_awsUploadList', defValue: [])!;
  }

  static void setAwsDownloadList(List<String> awsDownloadList) {
    SpUtil.putStringList('key_awsDownloadList', awsDownloadList);
    Global.awsDownloadList = awsDownloadList;
  }

  static List<String> getAwsDownloadList() {
    return SpUtil.getStringList('key_awsDownloadList', defValue: [])!;
  }

  static void setAlistUploadList(List<String> alistUploadList) {
    SpUtil.putStringList('key_alistUploadList', alistUploadList);
    Global.alistUploadList = alistUploadList;
  }

  static List<String> getAlistUploadList() {
    return SpUtil.getStringList('key_alistUploadList', defValue: [])!;
  }

  static void setAlistDownloadList(List<String> alistDownloadList) {
    SpUtil.putStringList('key_alistDownloadList', alistDownloadList);
    Global.alistDownloadList = alistDownloadList;
  }

  static List<String> getAlistDownloadList() {
    return SpUtil.getStringList('key_alistDownloadList', defValue: [])!;
  }

  static void setWebdavUploadList(List<String> webdavUploadList) {
    SpUtil.putStringList('key_webdavUploadList', webdavUploadList);
    Global.webdavUploadList = webdavUploadList;
  }

  static List<String> getWebdavUploadList() {
    return SpUtil.getStringList('key_webdavUploadList', defValue: [])!;
  }

  static void setWebdavDownloadList(List<String> webdavDownloadList) {
    SpUtil.putStringList('key_webdavDownloadList', webdavDownloadList);
    Global.webdavDownloadList = webdavDownloadList;
  }

  static List<String> getWebdavDownloadList() {
    return SpUtil.getStringList('key_webdavDownloadList', defValue: [])!;
  }

  static String getTodayAlistUpdate() {
    return SpUtil.getString('key_todayAlistUpdate', defValue: '19700101')!;
  }

  static void setTodayAlistUpdate(String todayAlistUpdate) {
    SpUtil.putString('key_todayAlistUpdate', todayAlistUpdate);
    Global.todayAlistUpdate = todayAlistUpdate;
  }
}
