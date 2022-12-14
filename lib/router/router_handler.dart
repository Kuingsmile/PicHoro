import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:fluro/fluro.dart';

import 'package:horopic/utils/web_view.dart';

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
import 'package:horopic/configure_page/user_manage/login_page.dart';
import 'package:horopic/configure_page/user_manage/user_information_page.dart';
import 'package:horopic/configure_page/user_manage/picture_host_info_page.dart';

import 'package:horopic/picture_host_configure/configure_page/configure_export.dart';
import 'package:horopic/picture_host_configure/default_picture_host_select.dart';

import 'package:horopic/picture_host_configure/configure_store/configure_store_page.dart';
import 'package:horopic/picture_host_configure/configure_store/configure_store_edit_page/configure_store_edit_export.dart';

import 'package:horopic/picture_host_manage/tencent/tencent_bucket_list_page.dart';
import 'package:horopic/picture_host_manage/tencent/tencent_bucket_information_page.dart';
import 'package:horopic/picture_host_manage/tencent/tencent_new_bucket_configure.dart';
import 'package:horopic/picture_host_manage/tencent/tencent_file_explorer.dart';
import 'package:horopic/picture_host_manage/tencent/tencent_file_information_page.dart';

import 'package:horopic/picture_host_manage/common_page/file_explorer/file_explorer.dart';
import 'package:horopic/picture_host_manage/common_page/file_explorer/local_image_preview.dart';
import 'package:horopic/picture_host_manage/common_page/file_explorer/net_video_player.dart';
import 'package:horopic/picture_host_manage/common_page/base_download_manage_page.dart';

import 'package:horopic/picture_host_manage/smms/smms_manage_home_page.dart';
import 'package:horopic/picture_host_manage/smms/smms_file_explorer.dart';
import 'package:horopic/picture_host_manage/smms/smms_download_manage_page.dart';
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

import 'package:horopic/picture_host_manage/common_page/file_explorer/md_preview.dart';
import 'package:horopic/picture_host_manage/common_page/file_explorer/pdf_viewer.dart';

import 'package:horopic/picture_host_manage/aws/aws_bucket_list_page.dart';
import 'package:horopic/picture_host_manage/aws/aws_new_bucket_configure.dart';
import 'package:horopic/picture_host_manage/aws/aws_file_explorer.dart';
import 'package:horopic/picture_host_manage/aws/aws_file_information_page.dart';

import 'package:horopic/picture_host_manage/alist/alist_bucket_list_page.dart';
import 'package:horopic/picture_host_manage/alist/alist_bucket_information_page.dart';
import 'package:horopic/picture_host_manage/alist/alist_new_bucket_configure.dart';
import 'package:horopic/picture_host_manage/alist/alist_new_bucket_router.dart';
import 'package:horopic/picture_host_manage/alist/alist_file_explorer.dart';
import 'package:horopic/picture_host_manage/alist/alist_file_information_page.dart';
import 'package:horopic/picture_host_manage/alist/alist_download_manage_page.dart';

import 'package:horopic/picture_host_manage/webdav/webdav_file_explorer.dart';
import 'package:horopic/picture_host_manage/webdav/webdav_file_information_page.dart';
import 'package:horopic/picture_host_manage/webdav/webdav_pic_preview.dart';

//webview
Handler webviewHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  String url = params['url']!.first;
  String title = params['title']!.first;
  bool enableJs = params['enableJs']!.first == 'true';
  return WebViewPage(url: url, title: title, enableJs: enableJs);
});

//root
Handler rootHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const PicHoroAPP();
});

//??????
var homePageHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const HomePage();
});

//??????
var albumUploadedImagesHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return UploadedImages();
});

//????????????
var albumImagePreviewHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  var index = params['index']!.first;
  List images = params['images']!.first.split(',');
  return ImagePreview(
    index: int.parse(index),
    images: images,
  );
});

//webdav????????????
var webdavImagePreviewHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  var index = params['index']!.first;
  List images = params['images']!.first.split(',');
  List headersList = json.decode(params['headersList']!.first);
  return WebdavImagePreview(
    index: int.parse(index),
    images: images,
    headersList: headersList,
  );
});

//????????????????????????
var localImagePreviewHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  var index = params['index']!.first;
  List images = params['images']!.first.split(',');
  return LocalImagePreview(
    index: int.parse(index),
    images: images,
  );
});

//????????????
var configurePageHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const ConfigurePage();
});

//????????????????????????
var compressConfigureHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const CompressConfigure();
});

//??????
var logsHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const LogPage();
});
//??????????????????
var appPasswordHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const APPPassword();
});

//??????????????????
var allPShostHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const AllPShost();
});

//????????????????????????
var defaultPShostSelectHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const DefaultPShostSelect();
});

//????????????????????????
var lskyproPShostSelectHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const HostConfig();
});

//sm.ms??????????????????
var smmsPShostSelectHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const SmmsConfig();
});

//github??????????????????
var githubPShostSelectHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const GithubConfig();
});

//Imgur??????????????????
var imgurPShostSelectHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const ImgurConfig();
});

//???????????????????????????
var aliyunPShostSelectHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const AliyunConfig();
});

//???????????????????????????
var tencentPShostSelectHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const TencentConfig();
});

//???????????????????????????
var qiniuPShostSelectHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const QiniuConfig();
});

//???????????????????????????
var upyunPShostSelectHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const UpyunConfig();
});

//ftp??????????????????
var ftpPShostSelectHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const FTPConfig();
});

//aws??????????????????
var awsPShostSelectHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const AwsConfig();
});

//alist??????????????????
var alistPShostSelectHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const AlistConfig();
});

//webdav??????????????????
var webdavPShostSelectHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const WebdavConfig();
});

//????????????????????????

var configureStorePageHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  String psHost = params['psHost']!.first;
  return ConfigureStorePage(
    psHost: psHost,
  );
});

//alist????????????????????????
var alistConfigureStoreEditPageHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  String storeKey = params['storeKey']!.first;
  Map psInfo = json.decode(params['psInfo']!.first);
  return AlistConfigureStoreEdit(
    storeKey: storeKey,
    psInfo: psInfo,
  );
});

//aliyun????????????????????????
var aliyunConfigureStoreEditPageHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  String storeKey = params['storeKey']!.first;
  Map psInfo = json.decode(params['psInfo']!.first);
  return AliyunConfigureStoreEdit(
    storeKey: storeKey,
    psInfo: psInfo,
  );
});

//aws????????????????????????
var awsConfigureStoreEditPageHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  String storeKey = params['storeKey']!.first;
  Map psInfo = json.decode(params['psInfo']!.first);
  return AwsConfigureStoreEdit(
    storeKey: storeKey,
    psInfo: psInfo,
  );
});

//ftp????????????????????????
var ftpConfigureStoreEditPageHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  String storeKey = params['storeKey']!.first;
  Map psInfo = json.decode(params['psInfo']!.first);
  return FtpConfigureStoreEdit(
    storeKey: storeKey,
    psInfo: psInfo,
  );
});

//github????????????????????????
var githubConfigureStoreEditPageHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  String storeKey = params['storeKey']!.first;
  Map psInfo = json.decode(params['psInfo']!.first);
  return GithubConfigureStoreEdit(
    storeKey: storeKey,
    psInfo: psInfo,
  );
});

//imgur????????????????????????
var imgurConfigureStoreEditPageHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  String storeKey = params['storeKey']!.first;
  Map psInfo = json.decode(params['psInfo']!.first);
  return ImgurConfigureStoreEdit(
    storeKey: storeKey,
    psInfo: psInfo,
  );
});

//lskypro????????????????????????
var lskyproConfigureStoreEditPageHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  String storeKey = params['storeKey']!.first;
  Map psInfo = json.decode(params['psInfo']!.first);
  return LskyproConfigureStoreEdit(
    storeKey: storeKey,
    psInfo: psInfo,
  );
});

//qiniu????????????????????????
var qiniuConfigureStoreEditPageHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  String storeKey = params['storeKey']!.first;
  Map psInfo = json.decode(params['psInfo']!.first);
  return QiniuConfigureStoreEdit(
    storeKey: storeKey,
    psInfo: psInfo,
  );
});

//smms????????????????????????
var smmsConfigureStoreEditPageHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  String storeKey = params['storeKey']!.first;
  Map psInfo = json.decode(params['psInfo']!.first);
  return SmmsConfigureStoreEdit(
    storeKey: storeKey,
    psInfo: psInfo,
  );
});

//tencent????????????????????????
var tencentConfigureStoreEditPageHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  String storeKey = params['storeKey']!.first;
  Map psInfo = json.decode(params['psInfo']!.first);
  return TencentConfigureStoreEdit(
    storeKey: storeKey,
    psInfo: psInfo,
  );
});

//upyun????????????????????????
var upyunConfigureStoreEditPageHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  String storeKey = params['storeKey']!.first;
  Map psInfo = json.decode(params['psInfo']!.first);
  return UpyunConfigureStoreEdit(
    storeKey: storeKey,
    psInfo: psInfo,
  );
});

//webdav????????????????????????
var webdavConfigureStoreEditPageHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  String storeKey = params['storeKey']!.first;
  Map psInfo = json.decode(params['psInfo']!.first);
  return WebdavConfigureStoreEdit(
    storeKey: storeKey,
    psInfo: psInfo,
  );
});

//??????????????????
var commonConfigHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const CommonConfig();
});

//?????????????????????????????????
var renameFileHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const RenameFile();
});

//????????????????????????
var linkFormatSelectHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const LinkFormatSelect();
});

//??????????????????
var changeThemeHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const ChangeTheme();
});

//?????????????????????
var emptyDatabaseHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const EmptyDatabase();
});

//????????????
var authorInformationHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const AuthorInformation();
});

//??????????????????
var updateLogHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const UpdateLog();
});

//??????????????????????????????
var tencentBucketListHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const TencentBucketList();
});

//??????????????????????????????
var tencentBucketInformationHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  var bucketMap = json.decode(params['bucketMap']!.first);
  return BucketInformation(
    bucketMap: bucketMap,
  );
});

//??????????????????????????????
var newTencentBucketHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const NewBucketConfig();
});

//????????????????????????????????????
var tencentFileExplorerHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  var element = json.decode(params['element']!.first);
  var bucketPrefix = params['bucketPrefix']!.first;
  return TencentFileExplorer(
    element: element,
    bucketPrefix: bucketPrefix,
  );
});

//???????????????????????????
var tencentFileInformationHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  var fileMap = json.decode(params['fileMap']!.first);
  return TencentFileInformation(
    fileMap: fileMap,
  );
});

//??????????????????
var fileExplorerHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  var currentDirPath = params['currentDirPath']!.first;
  var rootPath = params['rootPath']!.first;
  return FileExplorer(
    currentDirPath: currentDirPath,
    rootPath: rootPath,
  );
});

//??????????????????
var netVideoPlayerHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  var videoList = json.decode(params['videoList']!.first);
  int index = int.parse(params['index']!.first);
  String type = params['type']!.first;
  Map<String, String> headers =
      Map<String, String>.from(json.decode(params['headers']!.first));
  return NetVideoPlayer(
    videoList: videoList,
    index: index,
    type: type,
    headers: headers,
  );
});

//SMMS??????????????????
var smmsManageHomePageHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const SmmsManageHomePage();
});

//SMMS??????????????????????????????
var smmsFileExplorerHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const SmmsFileExplorer();
});

//SMMS??????????????????
var smmsFileInformationHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  var fileMap = json.decode(params['fileMap']!.first);
  return SmmsFileInformation(
    fileMap: fileMap,
  );
});

//SM.MS????????????????????????
var smmsUpDownloadFileHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  String downloadPath = params['downloadPath']!.first;
  String tabIndex = params['tabIndex']!.first;
  return SmmsUpDownloadManagePage(
      downloadPath: downloadPath, tabIndex: tabIndex);
});

//??????????????????
var userInformationPageHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const UserInformationPage();
});

//????????????????????????
var pictureHostInfoPageHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const PictureHostInfoPage();
});

//??????????????????????????????
var aliyunBucketListHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const AliyunBucketList();
});

//??????????????????????????????
var newAliyunBucketHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const AliyunNewBucketConfig();
});

//??????????????????????????????
var aliyunBucketInformationHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  var bucketMap = json.decode(params['bucketMap']!.first);
  return AliyunBucketInformation(
    bucketMap: bucketMap,
  );
});

//????????????????????????????????????
var aliyunFileExplorerHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  var element = json.decode(params['element']!.first);
  var bucketPrefix = params['bucketPrefix']!.first;
  return AliyunFileExplorer(
    element: element,
    bucketPrefix: bucketPrefix,
  );
});

//???????????????????????????
var aliyunFileInformationHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  var fileMap = json.decode(params['fileMap']!.first);
  return AliyunFileInformation(
    fileMap: fileMap,
  );
});

//?????????????????????
var upyunLogInHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const UpyunLogIn();
});

//????????????????????????????????????
var upyunFileExplorerHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  var element = json.decode(params['element']!.first);
  var bucketPrefix = params['bucketPrefix']!.first;
  return UpyunFileExplorer(
    element: element,
    bucketPrefix: bucketPrefix,
  );
});

//??????????????????????????????
var upyunBucketListHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const UpyunBucketList();
});

//??????????????????????????????
var upyunBucketInformationHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  var bucketMap = json.decode(params['bucketMap']!.first);
  return UpyunBucketInformation(
    bucketMap: bucketMap,
  );
});

//???????????????????????????
var upyunFileInformationHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  var fileMap = json.decode(params['fileMap']!.first);
  return UpyunFileInformation(
    fileMap: fileMap,
  );
});

//?????????Token????????????
var upyunTokenManageHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const UpyunTokenManage();
});

//??????????????????????????????
var newUpyunBucketHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const UpyunNewBucketConfig();
});

//??????????????????????????????
var qiniuBucketListHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const QiniuBucketList();
});

//??????????????????????????????
var newQiniuBucketHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const QiniuNewBucketConfig();
});

//??????????????????????????????
var qiniuBucketDomainAreaConfigHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  var element = json.decode(params['element']!.first);
  return QiniuBucketDomainAreaConfig(
    element: element,
  );
});

//????????????????????????????????????
var qiniuFileExplorerHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  var element = json.decode(params['element']!.first);
  var bucketPrefix = params['bucketPrefix']!.first;
  return QiniuFileExplorer(
    element: element,
    bucketPrefix: bucketPrefix,
  );
});

//???????????????????????????
var qiniuFileInformationHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  var fileMap = json.decode(params['fileMap']!.first);
  return QiniuFileInformation(
    fileMap: fileMap,
  );
});

//lskypro??????????????????
var lskyproManageHomePageHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const LskyproManageHomePage();
});

//lskypro??????????????????
var lskyproFileExplorerHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  var userProfile = json.decode(params['userProfile']!.first);
  var albumInfo = json.decode(params['albumInfo']!.first);
  return LskyproFileExplorer(
    userProfile: userProfile,
    albumInfo: albumInfo,
  );
});

//lskypro??????????????????
var lskyproFileInformationHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  var fileMap = json.decode(params['fileMap']!.first);
  return LskyproFileInformation(
    fileMap: fileMap,
  );
});

//github??????????????????
var githubManageHomePageHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const GithubManageHomePage();
});

//github??????????????????
var githubReposListHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  String showedUsername = params['showedUsername']!.first;
  return GithubReposList(
    showedUsername: showedUsername,
  );
});

//github??????????????????
var githubRepoInformationHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  var repoMap = json.decode(params['repoMap']!.first);
  return GithubRepoInformation(
    repoMap: repoMap,
  );
});

//github??????????????????
var githubNewRepoConfigHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const GithubNewRepoConfig();
});

//github??????????????????
var githubFileExplorerHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  var element = json.decode(params['element']!.first);
  var bucketPrefix = params['bucketPrefix']!.first;
  return GithubFileExplorer(
    element: element,
    bucketPrefix: bucketPrefix,
  );
});

//github??????????????????
var githubFileInformationHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  var fileMap = json.decode(params['fileMap']!.first);
  return GithubFileInformation(
    fileMap: fileMap,
  );
});

//Imgur????????????
var imgurLogInHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const ImgurLogIn();
});

//Imgur??????????????????
var imgurFileExplorerHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  var userProfile = json.decode(params['userProfile']!.first);
  var albumInfo = json.decode(params['albumInfo']!.first);
  var allImages = json.decode(params['allImages']!.first);
  return ImgurFileExplorer(
    userProfile: userProfile,
    albumInfo: albumInfo,
    allImages: allImages,
  );
});

//ImgurToken????????????
var imgurTokenManageHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const ImgurTokenManage();
});

//Imgur??????????????????
var imgurFileInformationHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  var fileMap = json.decode(params['fileMap']!.first);
  return ImgurFileInformation(
    fileMap: fileMap,
  );
});

//SFTP??????????????????
var sftpFileExplorerHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  var element = json.decode(params['element']!.first);
  var bucketPrefix = params['bucketPrefix']!.first;
  return SFTPFileExplorer(
    element: element,
    bucketPrefix: bucketPrefix,
  );
});

//SFTP??????????????????
var sftpFileInformationHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  var fileMap = json.decode(params['fileMap']!.first);
  return SFTPFileInformation(
    fileMap: fileMap,
  );
});

//ssh terminal??????
var sshTerminalHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  var configMap = json.decode(params['configMap']!.first);
  return SSHTermimal(configMap: configMap);
});

//sftp????????????
var sftplocalImagePreviewHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  var configMap = json.decode(params['configMap']!.first);
  String image = params['image']!.first;
  return SFTPLocalImagePreview(
    configMap: configMap,
    image: image,
  );
});

//md????????????
var mdFilePreviewHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  String filePath = params['filePath']!.first;
  String fileName = params['fileName']!.first;
  return MarkDownPreview(
    filePath: filePath,
    fileName: fileName,
  );
});

//Aws?????????????????????
var awsBucketListHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const AwsBucketList();
});

//Aws?????????????????????
var newAwsBucketHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const AwsNewBucketConfig();
});

//Aws???????????????????????????
var awsFileExplorerHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  var element = json.decode(params['element']!.first);
  var bucketPrefix = params['bucketPrefix']!.first;
  return AwsFileExplorer(
    element: element,
    bucketPrefix: bucketPrefix,
  );
});

//Aws??????????????????
var awsFileInformationHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  var fileMap = json.decode(params['fileMap']!.first);
  return AwsFileInformation(
    fileMap: fileMap,
  );
});

//Alist?????????????????????
var alistBucketListHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const AlistBucketList();
});

//Alist?????????????????????
var alistBucketInformationHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  var bucketMap = json.decode(params['bucketMap']!.first);
  return AlistBucketInformation(
    bucketMap: bucketMap,
  );
});

//Alist?????????????????????
var newAlistBucketHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  String driver = params['driver']!.first;
  String update = params['update']!.first;
  Map<String, dynamic> bucketMap = json.decode(params['bucketMap']!.first);
  return AlistNewBucketConfig(
    driver: driver,
    update: update,
    bucketMap: bucketMap,
  );
});

//Alist????????????????????????
var newAlistBucketNavigationHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const AlistNewBucketRouter();
});

//Alist???????????????????????????
var alistFileExplorerHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  var element = json.decode(params['element']!.first);
  var bucketPrefix = params['bucketPrefix']!.first;
  String refresh = params['refresh']!.first;
  return AlistFileExplorer(
    element: element,
    bucketPrefix: bucketPrefix,
    refresh: refresh,
  );
});

//Alist??????????????????
var alistFileInformationHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  var fileMap = json.decode(params['fileMap']!.first);
  return AlistFileInformation(
    fileMap: fileMap,
  );
});

//Alist????????????????????????
var alistDownloadFileHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  var bucketName = params['bucketName']!.first;
  String downloadPath = params['downloadPath']!.first;
  String tabIndex = params['tabIndex']!.first;
  return AlistUpDownloadManagePage(
      bucketName: bucketName, downloadPath: downloadPath, tabIndex: tabIndex);
});

//pdfviewer
var pdfViewerHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  String url = params['url']!.first;
  String fileName = params['fileName']!.first;
  Map<String, String>? headers =
      Map<String, String>.from(json.decode(params['headers']!.first));
  return PdfViewer(
    url: url,
    fileName: fileName,
    headers: headers,
  );
});

//Webdav???????????????????????????
var webdavFileExplorerHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  var element = json.decode(params['element']!.first);
  var bucketPrefix = params['bucketPrefix']!.first;
  return WebdavFileExplorer(
    element: element,
    bucketPrefix: bucketPrefix,
  );
});

//Webdav??????????????????
var webdavFileInformationHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  var fileMap = json.decode(params['fileMap']!.first);
  return WebdavFileInformation(
    fileMap: fileMap,
  );
});

//????????????????????????
var baseDownloadFileHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  String userName = params['userName'] == null ? '' : params['userName']!.first;
  String repoName = params['repoName'] == null ? '' : params['repoName']!.first;
  String albumName = params['albumName'] == null ? '' : params['albumName']!.first;
  String ftpHost = params['ftpHost'] == null ? '' : params['ftpHost']!.first;
  var bucketName = params['bucketName']== null ? '' : params['bucketName']!.first;
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
