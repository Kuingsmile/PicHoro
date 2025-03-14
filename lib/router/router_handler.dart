import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:fluro/fluro.dart';

import 'package:horopic/widgets/web_view.dart';

import 'package:horopic/pages/pichoro_app.dart';
import 'package:horopic/pages/home_page.dart';

import 'package:horopic/album/album_page.dart';
import 'package:horopic/album/network_pic_preview.dart';
import 'package:horopic/album/empty_database.dart';

import 'package:horopic/configure_page/configure_page.dart';
import 'package:horopic/configure_page/logger/logs.dart';
import 'package:horopic/configure_page/common_configure/common_configure.dart';
import 'package:horopic/configure_page/common_configure/select_link_format.dart';
import 'package:horopic/configure_page/common_configure/select_default_picture_host.dart';
import 'package:horopic/configure_page/common_configure/rename_uploaded_file.dart';
import 'package:horopic/configure_page/common_configure/compress_configure.dart';
import 'package:horopic/configure_page/others/update_log.dart';
import 'package:horopic/configure_page/others/author.dart';
import 'package:horopic/configure_page/others/select_theme.dart';

import 'package:horopic/picture_host_configure/configure_page/configure_export.dart';
import 'package:horopic/picture_host_configure/default_picture_host_select.dart';

import 'package:horopic/picture_host_configure/configure_store/configure_store_page.dart';
import 'package:horopic/picture_host_configure/configure_store/configure_store_edit_page/configure_store_edit_export.dart';

import 'package:horopic/picture_host_manage/tencent/tencent_bucket_list_page.dart';
import 'package:horopic/picture_host_manage/tencent/tencent_bucket_information_page.dart';
import 'package:horopic/picture_host_manage/tencent/tencent_new_bucket_configure.dart';
import 'package:horopic/picture_host_manage/tencent/tencent_file_explorer.dart';
import 'package:horopic/picture_host_manage/tencent/tencent_file_information_page.dart';

import 'package:horopic/picture_host_manage/common/file_explorer/local_file_explorer.dart';
import 'package:horopic/picture_host_manage/common/file_explorer/local_image_preview.dart';
import 'package:horopic/picture_host_manage/common/file_explorer/net_video_player.dart';
import 'package:horopic/picture_host_manage/common/base_up_down_load_manage_page.dart';

import 'package:horopic/picture_host_manage/smms/smms_manage_home_page.dart';
import 'package:horopic/picture_host_manage/smms/smms_file_explorer.dart';
import 'package:horopic/picture_host_manage/smms/smms_file_information_page.dart';

import 'package:horopic/picture_host_manage/aliyun/aliyun_bucket_list_page.dart';
import 'package:horopic/picture_host_manage/aliyun/aliyun_new_bucket_configure.dart';
import 'package:horopic/picture_host_manage/aliyun/aliyun_bucket_information_page.dart';
import 'package:horopic/picture_host_manage/aliyun/aliyun_file_explorer.dart';
import 'package:horopic/picture_host_manage/aliyun/aliyun_file_information_page.dart';

import 'package:horopic/picture_host_manage/upyun/upyun_login.dart';
import 'package:horopic/picture_host_manage/upyun/upyun_file_explorer.dart';
import 'package:horopic/picture_host_manage/upyun/upyun_bucket_list_page.dart';
import 'package:horopic/picture_host_manage/upyun/upyun_bucket_information_page.dart';
import 'package:horopic/picture_host_manage/upyun/upyun_token_manage_page.dart';
import 'package:horopic/picture_host_manage/upyun/upyun_new_bucket_configure.dart';
import 'package:horopic/picture_host_manage/upyun/upyun_file_information_page.dart';

import 'package:horopic/picture_host_manage/qiniu/qiniu_bucket_list_page.dart';
import 'package:horopic/picture_host_manage/qiniu/qiniu_new_bucket_configure.dart';
import 'package:horopic/picture_host_manage/qiniu/qiniu_bucket_domain_area_set.dart';
import 'package:horopic/picture_host_manage/qiniu/qiniu_file_explorer.dart';
import 'package:horopic/picture_host_manage/qiniu/qiniu_file_information_page.dart';

import 'package:horopic/picture_host_manage/lskypro/lskypro_manage_home_page.dart';
import 'package:horopic/picture_host_manage/lskypro/lskypro_file_explorer.dart';
import 'package:horopic/picture_host_manage/lskypro/lskypro_file_information_page.dart';

import 'package:horopic/picture_host_manage/github/github_manage_home_page.dart';
import 'package:horopic/picture_host_manage/github/github_repos_list_page.dart';
import 'package:horopic/picture_host_manage/github/github_repo_information_page.dart';
import 'package:horopic/picture_host_manage/github/github_new_repo_configure.dart';
import 'package:horopic/picture_host_manage/github/github_file_explorer.dart';
import 'package:horopic/picture_host_manage/github/github_file_information_page.dart';

import 'package:horopic/picture_host_manage/imgur/imgur_login.dart';
import 'package:horopic/picture_host_manage/imgur/imgur_file_explorer.dart';
import 'package:horopic/picture_host_manage/imgur/imgur_token_manage_page.dart';
import 'package:horopic/picture_host_manage/imgur/imgur_file_information_page.dart';

import 'package:horopic/picture_host_manage/ftp/sftp_file_explorer.dart';
import 'package:horopic/picture_host_manage/ftp/sftp_file_information_page.dart';
import 'package:horopic/picture_host_manage/ftp/ssh_terminal.dart';
import 'package:horopic/picture_host_manage/ftp/sftp_local_image_preview.dart';

import 'package:horopic/picture_host_manage/common/file_explorer/md_preview.dart';
import 'package:horopic/picture_host_manage/common/file_explorer/pdf_viewer.dart';

import 'package:horopic/picture_host_manage/aws/aws_bucket_list_page.dart';
import 'package:horopic/picture_host_manage/aws/aws_new_bucket_configure.dart';
import 'package:horopic/picture_host_manage/aws/aws_file_explorer.dart';
import 'package:horopic/picture_host_manage/aws/aws_file_information_page.dart';

import 'package:horopic/picture_host_manage/alist/alist_bucket_list_page.dart';
import 'package:horopic/picture_host_manage/alist/alist_bucket_information_page.dart';
import 'package:horopic/picture_host_manage/alist/alist_file_explorer.dart';
import 'package:horopic/picture_host_manage/alist/alist_file_information_page.dart';

import 'package:horopic/picture_host_manage/webdav/webdav_file_explorer.dart';
import 'package:horopic/picture_host_manage/webdav/webdav_file_information_page.dart';
import 'package:horopic/picture_host_manage/webdav/webdav_pic_preview.dart';

//webview
Handler webviewHandler = Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  String url = params['url']!.first;
  String title = params['title']!.first;
  bool enableJs = params['enableJs']!.first == 'true';
  return WebViewPage(url: url, title: title, enableJs: enableJs);
});

///root
Handler rootHandler = Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const PicHoroAPP();
});

///主页
var homePageHandler = Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const HomePage();
});

///相册
var albumUploadedImagesHandler = Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const UploadedImages();
});

///相册预览
var albumImagePreviewHandler = Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  var index = params['index']!.first;
  List images = params['images']!.first.split(',');
  return ImagePreview(
    index: int.parse(index),
    images: images,
  );
});

///webdav图片预览
var webdavImagePreviewHandler = Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  var index = params['index']!.first;
  List images = params['images']!.first.split(',');
  List headersList = json.decode(params['headersList']!.first);
  return WebdavImagePreview(
    index: int.parse(index),
    images: images,
    headersList: headersList,
  );
});

///本地文件相册预览
var localImagePreviewHandler = Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  var index = params['index']!.first;
  List images = params['images']!.first.split(',');
  return LocalImagePreview(
    index: int.parse(index),
    images: images,
  );
});

///配置页面
var configurePageHandler = Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const ConfigurePage();
});

///图片压缩设置页面
var compressConfigureHandler = Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const CompressConfigure();
});

///日志
var logsHandler = Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const LogPage();
});

///图床配置页面
var allPShostHandler = Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const AllPShost();
});

///默认图床配置页面
var defaultPShostSelectHandler = Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const DefaultPShostSelect();
});

//兰空图床配置页面
var lskyproPShostSelectHandler = Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const HostConfig();
});

//sm.ms图床配置页面
var smmsPShostSelectHandler = Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const SmmsConfig();
});

//github图床配置页面
var githubPShostSelectHandler = Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const GithubConfig();
});

//Imgur图床配置页面
var imgurPShostSelectHandler = Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const ImgurConfig();
});

//阿里云图床配置页面
var aliyunPShostSelectHandler = Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const AliyunConfig();
});

//腾讯云图床配置页面
var tencentPShostSelectHandler = Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const TencentConfig();
});

//七牛云图床配置页面
var qiniuPShostSelectHandler = Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const QiniuConfig();
});

//又拍云图床配置页面
var upyunPShostSelectHandler = Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const UpyunConfig();
});

//ftp图床配置页面
var ftpPShostSelectHandler = Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const FTPConfig();
});

//aws图床配置页面
var awsPShostSelectHandler = Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const AwsConfig();
});

//alist图床配置页面
var alistPShostSelectHandler = Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const AlistConfig();
});

//webdav图床配置页面
var webdavPShostSelectHandler = Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const WebdavConfig();
});

//备用配置查看页面

var configureStorePageHandler = Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  String psHost = params['psHost']!.first;
  return ConfigureStorePage(
    psHost: psHost,
  );
});

//alist备用配置编辑页面
var alistConfigureStoreEditPageHandler =
    Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  String storeKey = params['storeKey']!.first;
  Map psInfo = json.decode(params['psInfo']!.first);
  return AlistConfigureStoreEdit(
    storeKey: storeKey,
    psInfo: psInfo,
  );
});

//aliyun备用配置编辑页面
var aliyunConfigureStoreEditPageHandler =
    Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  String storeKey = params['storeKey']!.first;
  Map psInfo = json.decode(params['psInfo']!.first);
  return AliyunConfigureStoreEdit(
    storeKey: storeKey,
    psInfo: psInfo,
  );
});

//aws备用配置编辑页面
var awsConfigureStoreEditPageHandler = Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  String storeKey = params['storeKey']!.first;
  Map psInfo = json.decode(params['psInfo']!.first);
  return AwsConfigureStoreEdit(
    storeKey: storeKey,
    psInfo: psInfo,
  );
});

//ftp备用配置编辑页面
var ftpConfigureStoreEditPageHandler = Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  String storeKey = params['storeKey']!.first;
  Map psInfo = json.decode(params['psInfo']!.first);
  return FtpConfigureStoreEdit(
    storeKey: storeKey,
    psInfo: psInfo,
  );
});

//github备用配置编辑页面
var githubConfigureStoreEditPageHandler =
    Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  String storeKey = params['storeKey']!.first;
  Map psInfo = json.decode(params['psInfo']!.first);
  return GithubConfigureStoreEdit(
    storeKey: storeKey,
    psInfo: psInfo,
  );
});

//imgur备用配置编辑页面
var imgurConfigureStoreEditPageHandler =
    Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  String storeKey = params['storeKey']!.first;
  Map psInfo = json.decode(params['psInfo']!.first);
  return ImgurConfigureStoreEdit(
    storeKey: storeKey,
    psInfo: psInfo,
  );
});

//lskypro备用配置编辑页面
var lskyproConfigureStoreEditPageHandler =
    Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  String storeKey = params['storeKey']!.first;
  Map psInfo = json.decode(params['psInfo']!.first);
  return LskyproConfigureStoreEdit(
    storeKey: storeKey,
    psInfo: psInfo,
  );
});

//qiniu备用配置编辑页面
var qiniuConfigureStoreEditPageHandler =
    Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  String storeKey = params['storeKey']!.first;
  Map psInfo = json.decode(params['psInfo']!.first);
  return QiniuConfigureStoreEdit(
    storeKey: storeKey,
    psInfo: psInfo,
  );
});

//smms备用配置编辑页面
var smmsConfigureStoreEditPageHandler = Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  String storeKey = params['storeKey']!.first;
  Map psInfo = json.decode(params['psInfo']!.first);
  return SmmsConfigureStoreEdit(
    storeKey: storeKey,
    psInfo: psInfo,
  );
});

//tencent备用配置编辑页面
var tencentConfigureStoreEditPageHandler =
    Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  String storeKey = params['storeKey']!.first;
  Map psInfo = json.decode(params['psInfo']!.first);
  return TencentConfigureStoreEdit(
    storeKey: storeKey,
    psInfo: psInfo,
  );
});

//upyun备用配置编辑页面
var upyunConfigureStoreEditPageHandler =
    Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  String storeKey = params['storeKey']!.first;
  Map psInfo = json.decode(params['psInfo']!.first);
  return UpyunConfigureStoreEdit(
    storeKey: storeKey,
    psInfo: psInfo,
  );
});

//webdav备用配置编辑页面
var webdavConfigureStoreEditPageHandler =
    Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  String storeKey = params['storeKey']!.first;
  Map psInfo = json.decode(params['psInfo']!.first);
  return WebdavConfigureStoreEdit(
    storeKey: storeKey,
    psInfo: psInfo,
  );
});

//通用配置页面
var commonConfigHandler = Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const CommonConfig();
});

//文件重命名格式配置页面
var renameFileHandler = Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const RenameFile();
});

//链接格式配置页面
var linkFormatSelectHandler = Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const LinkFormatSelect();
});

//主题配置页面
var changeThemeHandler = Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const ChangeTheme();
});

//清空数据库页面
var emptyDatabaseHandler = Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const EmptyDatabase();
});

//作者页面
var authorInformationHandler = Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const AuthorInformation();
});

//更新日志页面
var updateLogHandler = Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const UpdateLog();
});

//腾讯云存储桶列表页面
var tencentBucketListHandler = Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const TencentBucketList();
});

//腾讯云存储桶详情页面
var tencentBucketInformationHandler = Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  var bucketMap = json.decode(params['bucketMap']!.first);
  return BucketInformation(
    bucketMap: bucketMap,
  );
});

//腾讯云新建存储桶页面
var newTencentBucketHandler = Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const NewBucketConfig();
});

//腾讯云存储桶文件列表页面
var tencentFileExplorerHandler = Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  var element = json.decode(params['element']!.first);
  var bucketPrefix = params['bucketPrefix']!.first;
  return TencentFileExplorer(
    element: element,
    bucketPrefix: bucketPrefix,
  );
});

//阿里云文件详情页面
var tencentFileInformationHandler = Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  var fileMap = json.decode(params['fileMap']!.first);
  return TencentFileInformation(
    fileMap: fileMap,
  );
});

//文件浏览页面
var fileExplorerHandler = Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  var currentDirPath = params['currentDirPath']!.first;
  var rootPath = params['rootPath']!.first;
  return FileExplorer(
    currentDirPath: currentDirPath,
    rootPath: rootPath,
  );
});

//视频播放页面
var netVideoPlayerHandler = Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  var videoList = json.decode(params['videoList']!.first);
  int index = int.parse(params['index']!.first);
  String type = params['type']!.first;
  Map<String, String> headers = Map<String, String>.from(json.decode(params['headers']!.first));
  return NetVideoPlayer(
    videoList: videoList,
    index: index,
    type: type,
    headers: headers,
  );
});

//SMMS图床管理首页
var smmsManageHomePageHandler = Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const SmmsManageHomePage();
});

//SMMS图床管理文件列表页面
var smmsFileExplorerHandler = Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const SmmsFileExplorer();
});

//SMMS文件详情页面
var smmsFileInformationHandler = Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  var fileMap = json.decode(params['fileMap']!.first);
  return SmmsFileInformation(
    fileMap: fileMap,
  );
});

//阿里云存储桶列表页面
var aliyunBucketListHandler = Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const AliyunBucketList();
});

//阿里云新建存储桶页面
var newAliyunBucketHandler = Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const AliyunNewBucketConfig();
});

//阿里云存储桶详情页面
var aliyunBucketInformationHandler = Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  var bucketMap = json.decode(params['bucketMap']!.first);
  return AliyunBucketInformation(
    bucketMap: bucketMap,
  );
});

//阿里云存储桶文件列表页面
var aliyunFileExplorerHandler = Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  var element = json.decode(params['element']!.first);
  var bucketPrefix = params['bucketPrefix']!.first;
  return AliyunFileExplorer(
    element: element,
    bucketPrefix: bucketPrefix,
  );
});

//阿里云文件详情页面
var aliyunFileInformationHandler = Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  var fileMap = json.decode(params['fileMap']!.first);
  return AliyunFileInformation(
    fileMap: fileMap,
  );
});

//又拍云登录页面
var upyunLogInHandler = Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const UpyunLogIn();
});

//又拍云存储桶文件列表页面
var upyunFileExplorerHandler = Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  var element = json.decode(params['element']!.first);
  var bucketPrefix = params['bucketPrefix']!.first;
  return UpyunFileExplorer(
    element: element,
    bucketPrefix: bucketPrefix,
  );
});

//又拍云存储桶列表页面
var upyunBucketListHandler = Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const UpyunBucketList();
});

//又拍云存储桶详情页面
var upyunBucketInformationHandler = Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  var bucketMap = json.decode(params['bucketMap']!.first);
  return UpyunBucketInformation(
    bucketMap: bucketMap,
  );
});

//又拍云文件详情页面
var upyunFileInformationHandler = Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  var fileMap = json.decode(params['fileMap']!.first);
  return UpyunFileInformation(
    fileMap: fileMap,
  );
});

//又拍云Token管理页面
var upyunTokenManageHandler = Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const UpyunTokenManage();
});

//又拍云新建存储桶页面
var newUpyunBucketHandler = Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const UpyunNewBucketConfig();
});

//七牛云存储桶列表页面
var qiniuBucketListHandler = Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const QiniuBucketList();
});

//七牛云新建存储桶页面
var newQiniuBucketHandler = Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const QiniuNewBucketConfig();
});

//七牛云存储桶设置页面
var qiniuBucketDomainAreaConfigHandler =
    Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  var element = json.decode(params['element']!.first);
  return QiniuBucketDomainAreaConfig(
    element: element,
  );
});

//七牛云存储桶文件列表页面
var qiniuFileExplorerHandler = Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  var element = json.decode(params['element']!.first);
  var bucketPrefix = params['bucketPrefix']!.first;
  return QiniuFileExplorer(
    element: element,
    bucketPrefix: bucketPrefix,
  );
});

//七牛云文件详情页面
var qiniuFileInformationHandler = Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  var fileMap = json.decode(params['fileMap']!.first);
  return QiniuFileInformation(
    fileMap: fileMap,
  );
});

//lskypro图床管理首页
var lskyproManageHomePageHandler = Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const LskyproManageHomePage();
});

//lskypro文件列表页面
var lskyproFileExplorerHandler = Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  var userProfile = json.decode(params['userProfile']!.first);
  var albumInfo = json.decode(params['albumInfo']!.first);
  return LskyproFileExplorer(
    userProfile: userProfile,
    albumInfo: albumInfo,
  );
});

//lskypro文件详情页面
var lskyproFileInformationHandler = Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  var fileMap = json.decode(params['fileMap']!.first);
  return LskyproFileInformation(
    fileMap: fileMap,
  );
});

//github图床管理首页
var githubManageHomePageHandler = Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const GithubManageHomePage();
});

//github仓库列表页面
var githubReposListHandler = Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  String showedUsername = params['showedUsername']!.first;
  return GithubReposList(
    showedUsername: showedUsername,
  );
});

//github仓库详情页面
var githubRepoInformationHandler = Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  var repoMap = json.decode(params['repoMap']!.first);
  return GithubRepoInformation(
    repoMap: repoMap,
  );
});

//github新建仓库页面
var githubNewRepoConfigHandler = Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const GithubNewRepoConfig();
});

//github文件列表页面
var githubFileExplorerHandler = Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  var element = json.decode(params['element']!.first);
  var bucketPrefix = params['bucketPrefix']!.first;
  return GithubFileExplorer(
    element: element,
    bucketPrefix: bucketPrefix,
  );
});

//github文件详情页面
var githubFileInformationHandler = Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  var fileMap = json.decode(params['fileMap']!.first);
  return GithubFileInformation(
    fileMap: fileMap,
  );
});

//Imgur登录页面
var imgurLogInHandler = Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const ImgurLogIn();
});

//Imgur文件列表页面
var imgurFileExplorerHandler = Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  var userProfile = json.decode(params['userProfile']!.first);
  var albumInfo = json.decode(params['albumInfo']!.first);
  var allImages = json.decode(params['allImages']!.first);
  return ImgurFileExplorer(
    userProfile: userProfile,
    albumInfo: albumInfo,
    allImages: allImages,
  );
});

//ImgurToken管理页面
var imgurTokenManageHandler = Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const ImgurTokenManage();
});

//Imgur文件详情页面
var imgurFileInformationHandler = Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  var fileMap = json.decode(params['fileMap']!.first);
  return ImgurFileInformation(
    fileMap: fileMap,
  );
});

//SFTP文件列表页面
var sftpFileExplorerHandler = Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  var element = json.decode(params['element']!.first);
  var bucketPrefix = params['bucketPrefix']!.first;
  return SFTPFileExplorer(
    element: element,
    bucketPrefix: bucketPrefix,
  );
});

//SFTP文件详情页面
var sftpFileInformationHandler = Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  var fileMap = json.decode(params['fileMap']!.first);
  return SFTPFileInformation(
    fileMap: fileMap,
  );
});

//ssh terminal页面
var sshTerminalHandler = Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  var configMap = json.decode(params['configMap']!.first);
  return SSHTermimal(configMap: configMap);
});

//sftp图片预览
var sftplocalImagePreviewHandler = Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  var configMap = json.decode(params['configMap']!.first);
  String image = params['image']!.first;
  return SFTPLocalImagePreview(
    configMap: configMap,
    image: image,
  );
});

//md文件预览
var mdFilePreviewHandler = Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  String filePath = params['filePath']!.first;
  String fileName = params['fileName']!.first;
  return MarkDownPreview(
    filePath: filePath,
    fileName: fileName,
  );
});

//Aws存储桶列表页面
var awsBucketListHandler = Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const AwsBucketList();
});

//Aws新建存储桶页面
var newAwsBucketHandler = Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const AwsNewBucketConfig();
});

//Aws存储桶文件列表页面
var awsFileExplorerHandler = Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  var element = json.decode(params['element']!.first);
  var bucketPrefix = params['bucketPrefix']!.first;
  return AwsFileExplorer(
    element: element,
    bucketPrefix: bucketPrefix,
  );
});

//Aws文件详情页面
var awsFileInformationHandler = Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  var fileMap = json.decode(params['fileMap']!.first);
  return AwsFileInformation(
    fileMap: fileMap,
  );
});

//Alist存储桶列表页面
var alistBucketListHandler = Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const AlistBucketList();
});

//Alist存储桶详情页面
var alistBucketInformationHandler = Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  var bucketMap = json.decode(params['bucketMap']!.first);
  return AlistBucketInformation(
    bucketMap: bucketMap,
  );
});

//Alist存储桶文件列表页面
var alistFileExplorerHandler = Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  var element = json.decode(params['element']!.first);
  var bucketPrefix = params['bucketPrefix']!.first;
  String refresh = params['refresh']!.first;
  return AlistFileExplorer(
    element: element,
    bucketPrefix: bucketPrefix,
    refresh: refresh,
  );
});

//Alist文件详情页面
var alistFileInformationHandler = Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  var fileMap = json.decode(params['fileMap']!.first);
  return AlistFileInformation(
    fileMap: fileMap,
  );
});
//pdfviewer
var pdfViewerHandler = Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  String url = params['url']!.first;
  String fileName = params['fileName']!.first;
  Map<String, String>? headers = Map<String, String>.from(json.decode(params['headers']!.first));
  return PdfViewer(
    url: url,
    fileName: fileName,
    headers: headers,
  );
});

//Webdav存储桶文件列表页面
var webdavFileExplorerHandler = Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  var element = json.decode(params['element']!.first);
  var bucketPrefix = params['bucketPrefix']!.first;
  return WebdavFileExplorer(
    element: element,
    bucketPrefix: bucketPrefix,
  );
});

//Webdav文件详情页面
var webdavFileInformationHandler = Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  var fileMap = json.decode(params['fileMap']!.first);
  return WebdavFileInformation(
    fileMap: fileMap,
  );
});

//通用下载文件页面
var baseDownloadFileHandler = Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  String userName = params['userName']?.first ?? '';
  String repoName = params['repoName']?.first ?? '';
  String albumName = params['albumName']?.first ?? '';
  String ftpHost = params['ftpHost']?.first ?? '';
  String bucketName = params['bucketName']?.first ?? '';
  String downloadPath = params['downloadPath']!.first;
  String tabIndex = params['tabIndex']!.first;
  int currentListIndex = int.parse(params['currentListIndex']!.first);

  return BaseUpDownloadManagePage(
    userName: userName,
    repoName: repoName,
    albumName: albumName,
    ftpHost: ftpHost,
    bucketName: bucketName,
    downloadPath: downloadPath,
    tabIndex: tabIndex,
    currentListIndex: currentListIndex,
  );
});
