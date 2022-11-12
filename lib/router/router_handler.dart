import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:fluro/fluro.dart';
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
import 'package:horopic/configure_page/others/update_log.dart';
import 'package:horopic/configure_page/others/author.dart';
import 'package:horopic/configure_page/others/select_theme.dart';
import 'package:horopic/configure_page/user_manage/login_page.dart';
import 'package:horopic/configure_page/user_manage/user_information_page.dart';
import 'package:horopic/configure_page/user_manage/picture_host_info_page.dart';

import 'package:horopic/picture_host_configure/imgur_configure.dart';
import 'package:horopic/picture_host_configure/smms_configure.dart';
import 'package:horopic/picture_host_configure/lskypro_configure.dart';
import 'package:horopic/picture_host_configure/github_configure.dart';
import 'package:horopic/picture_host_configure/aliyun_configure.dart';
import 'package:horopic/picture_host_configure/tencent_configure.dart';
import 'package:horopic/picture_host_configure/qiniu_configure.dart';
import 'package:horopic/picture_host_configure/upyun_configure.dart';
import 'package:horopic/picture_host_configure/default_picture_host_select.dart';

import 'package:horopic/picture_host_manage/tencent/tencent_bucket_list_page.dart';
import 'package:horopic/picture_host_manage/tencent/tencent_bucket_information_page.dart';
import 'package:horopic/picture_host_manage/tencent/tencent_new_bucket_configure.dart';
import 'package:horopic/picture_host_manage/tencent/tencent_file_explorer.dart';
import 'package:horopic/picture_host_manage/tencent/tencent_download_manage_page.dart';
import 'package:horopic/picture_host_manage/tencent/tencent_file_information_page.dart';

import 'package:horopic/picture_host_manage/common_page/file_explorer/file_explorer.dart';
import 'package:horopic/picture_host_manage/common_page/file_explorer/local_image_preview.dart';

import 'package:horopic/picture_host_manage/smms/smms_manage_home_page.dart';
import 'package:horopic/picture_host_manage/smms/smms_file_explorer.dart';
import 'package:horopic/picture_host_manage/smms/smms_download_manage_page.dart';
import 'package:horopic/picture_host_manage/smms/smms_file_information_page.dart';

import 'package:horopic/picture_host_manage/aliyun/aliyun_bucket_list_page.dart';
import 'package:horopic/picture_host_manage/aliyun/aliyun_new_bucket_configure.dart';
import 'package:horopic/picture_host_manage/aliyun/aliyun_bucket_information_page.dart';
import 'package:horopic/picture_host_manage/aliyun/aliyun_file_explorer.dart';
import 'package:horopic/picture_host_manage/aliyun/aliyun_download_manage_page.dart';
import 'package:horopic/picture_host_manage/aliyun/aliyun_file_information_page.dart';

import 'package:horopic/picture_host_manage/upyun/upyun_login.dart';
import 'package:horopic/picture_host_manage/upyun/upyun_file_explorer.dart';
import 'package:horopic/picture_host_manage/upyun/upyun_bucket_list_page.dart';
import 'package:horopic/picture_host_manage/upyun/upyun_bucket_information_page.dart';
import 'package:horopic/picture_host_manage/upyun/upyun_token_manage_page.dart';
import 'package:horopic/picture_host_manage/upyun/upyun_new_bucket_configure.dart';
import 'package:horopic/picture_host_manage/upyun/upyun_download_manage_page.dart';
import 'package:horopic/picture_host_manage/upyun/upyun_file_information_page.dart';

import 'package:horopic/picture_host_manage/qiniu/qiniu_bucket_list_page.dart';
import 'package:horopic/picture_host_manage/qiniu/qiniu_new_bucket_configure.dart';
import 'package:horopic/picture_host_manage/qiniu/qiniu_bucket_domain_area_set.dart';
import 'package:horopic/picture_host_manage/qiniu/qiniu_file_explorer.dart';
import 'package:horopic/picture_host_manage/qiniu/qiniu_file_information_page.dart';
import 'package:horopic/picture_host_manage/qiniu/qiniu_download_manage_page.dart';

import 'package:horopic/picture_host_manage/lskypro/lskypro_manage_home_page.dart';
import 'package:horopic/picture_host_manage/lskypro/lskypro_file_explorer.dart';
import 'package:horopic/picture_host_manage/lskypro/lskypro_file_information_page.dart';
import 'package:horopic/picture_host_manage/lskypro/lskypro_download_manage_page.dart';

import 'package:horopic/picture_host_manage/github/github_manage_home_page.dart';
import 'package:horopic/picture_host_manage/github/github_repos_list_page.dart';
import 'package:horopic/picture_host_manage/github/github_repo_information_page.dart';
import 'package:horopic/picture_host_manage/github/github_new_repo_configure.dart';
import 'package:horopic/picture_host_manage/github/github_file_explorer.dart';
import 'package:horopic/picture_host_manage/github/github_file_information_page.dart';
import 'package:horopic/picture_host_manage/github/github_download_manage_page.dart';

//root
Handler rootHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const PicHoroAPP();
});

//主页
var homePageHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const HomePage();
});

//相册
var albumUploadedImagesHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return UploadedImages();
});

//相册预览
var albumImagePreviewHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  var index = params['index']!.first;
  List images = params['images']!.first.split(',');
  return ImagePreview(
    index: int.parse(index),
    images: images,
  );
});

//本地文件相册预览
var localImagePreviewHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  var index = params['index']!.first;
  List images = params['images']!.first.split(',');
  return LocalImagePreview(
    index: int.parse(index),
    images: images,
  );
});

//配置页面
var configurePageHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const ConfigurePage();
});

//日志
var logsHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const LogPage();
});
//用户登录页面
var appPasswordHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const APPPassword();
});

//图床配置页面
var allPShostHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const AllPShost();
});

//默认图床配置页面
var defaultPShostSelectHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const DefaultPShostSelect();
});

//兰空图床配置页面
var lskyproPShostSelectHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const HostConfig();
});

//sm.ms图床配置页面
var smmsPShostSelectHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const SmmsConfig();
});

//github图床配置页面
var githubPShostSelectHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const GithubConfig();
});

//Imgur图床配置页面
var imgurPShostSelectHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const ImgurConfig();
});

//阿里云图床配置页面
var aliyunPShostSelectHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const AliyunConfig();
});

//腾讯云图床配置页面
var tencentPShostSelectHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const TencentConfig();
});

//七牛云图床配置页面
var qiniuPShostSelectHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const QiniuConfig();
});

//又拍云图床配置页面
var upyunPShostSelectHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const UpyunConfig();
});

//通用配置页面
var commonConfigHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const CommonConfig();
});

//文件重命名格式配置页面
var renameFileHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const RenameFile();
});

//链接格式配置页面
var linkFormatSelectHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const LinkFormatSelect();
});

//主题配置页面
var changeThemeHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const ChangeTheme();
});

//清空数据库页面
var emptyDatabaseHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const EmptyDatabase();
});

//作者页面
var authorInformationHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const AuthorInformation();
});

//更新日志页面
var updateLogHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const UpdateLog();
});

//腾讯云存储桶列表页面
var tencentBucketListHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const TencentBucketList();
});

//腾讯云存储桶详情页面
var tencentBucketInformationHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  var bucketMap = json.decode(params['bucketMap']!.first);
  return BucketInformation(
    bucketMap: bucketMap,
  );
});

//腾讯云新建存储桶页面
var newTencentBucketHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const NewBucketConfig();
});

//腾讯云存储桶文件列表页面
var tencentFileExplorerHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  var element = json.decode(params['element']!.first);
  var bucketPrefix = params['bucketPrefix']!.first;
  return TencentFileExplorer(
    element: element,
    bucketPrefix: bucketPrefix,
  );
});

//腾讯云存储下载文件页面
var tencentDownloadFileHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  var bucketName = params['bucketName']!.first;
  String downloadPath = params['downloadPath']!.first;
  String tabIndex = params['tabIndex']!.first;
  return TencentUpDownloadManagePage(
      bucketName: bucketName, downloadPath: downloadPath, tabIndex: tabIndex);
});

//阿里云文件详情页面
var tencentFileInformationHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  var fileMap = json.decode(params['fileMap']!.first);
  return TencentFileInformation(
    fileMap: fileMap,
  );
});

//文件浏览页面
var fileExplorerHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  var currentDirPath = params['currentDirPath']!.first;
  var rootPath = params['rootPath']!.first;
  return FileExplorer(
    currentDirPath: currentDirPath,
    rootPath: rootPath,
  );
});

//SMMS图床管理首页
var smmsManageHomePageHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const SmmsManageHomePage();
});

//SMMS图床管理文件列表页面
var smmsFileExplorerHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const SmmsFileExplorer();
});

//SMMS文件详情页面
var smmsFileInformationHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  var fileMap = json.decode(params['fileMap']!.first);
  return SmmsFileInformation(
    fileMap: fileMap,
  );
});

//SM.MS存储下载文件页面
var smmsUpDownloadFileHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  String downloadPath = params['downloadPath']!.first;
  String tabIndex = params['tabIndex']!.first;
  return SmmsUpDownloadManagePage(
      downloadPath: downloadPath, tabIndex: tabIndex);
});

//用户信息页面
var userInformationPageHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const UserInformationPage();
});

//用户图床信息页面
var pictureHostInfoPageHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const PictureHostInfoPage();
});

//阿里云存储桶列表页面
var aliyunBucketListHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const AliyunBucketList();
});

//阿里云新建存储桶页面
var newAliyunBucketHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const AliyunNewBucketConfig();
});

//阿里云存储桶详情页面
var aliyunBucketInformationHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  var bucketMap = json.decode(params['bucketMap']!.first);
  return AliyunBucketInformation(
    bucketMap: bucketMap,
  );
});

//阿里云存储桶文件列表页面
var aliyunFileExplorerHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  var element = json.decode(params['element']!.first);
  var bucketPrefix = params['bucketPrefix']!.first;
  return AliyunFileExplorer(
    element: element,
    bucketPrefix: bucketPrefix,
  );
});

//阿里云文件详情页面
var aliyunFileInformationHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  var fileMap = json.decode(params['fileMap']!.first);
  return AliyunFileInformation(
    fileMap: fileMap,
  );
});

//阿里云存储下载文件页面
var aliyunDownloadFileHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  var bucketName = params['bucketName']!.first;
  String downloadPath = params['downloadPath']!.first;
  String tabIndex = params['tabIndex']!.first;
  return AliyunUpDownloadManagePage(
      bucketName: bucketName, downloadPath: downloadPath, tabIndex: tabIndex);
});

//又拍云登录页面
var upyunLogInHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const UpyunLogIn();
});

//又拍云存储桶文件列表页面
var upyunFileExplorerHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  var element = json.decode(params['element']!.first);
  var bucketPrefix = params['bucketPrefix']!.first;
  return UpyunFileExplorer(
    element: element,
    bucketPrefix: bucketPrefix,
  );
});

//拍云存储桶列表页面
var upyunBucketListHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const UpyunBucketList();
});

//又拍云存储桶详情页面
var upyunBucketInformationHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  var bucketMap = json.decode(params['bucketMap']!.first);
  return UpyunBucketInformation(
    bucketMap: bucketMap,
  );
});

//又拍云文件详情页面
var upyunFileInformationHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  var fileMap = json.decode(params['fileMap']!.first);
  return UpyunFileInformation(
    fileMap: fileMap,
  );
});

//又拍云Token管理页面
var upyunTokenManageHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const UpyunTokenManage();
});

//又拍云新建存储桶页面
var newUpyunBucketHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const UpyunNewBucketConfig();
});

//又拍云存储下载文件页面
var upyunDownloadFileHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  var bucketName = params['bucketName']!.first;
  String downloadPath = params['downloadPath']!.first;
  String tabIndex = params['tabIndex']!.first;
  return UpyunUpDownloadManagePage(
      bucketName: bucketName, downloadPath: downloadPath, tabIndex: tabIndex);
});

//七牛云存储桶列表页面
var qiniuBucketListHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const QiniuBucketList();
});

//七牛云新建存储桶页面
var newQiniuBucketHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const QiniuNewBucketConfig();
});

//七牛云存储桶设置页面
var qiniuBucketDomainAreaConfigHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  var element = json.decode(params['element']!.first);
  return QiniuBucketDomainAreaConfig(
    element: element,
  );
});

//七牛云存储桶文件列表页面
var qiniuFileExplorerHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  var element = json.decode(params['element']!.first);
  var bucketPrefix = params['bucketPrefix']!.first;
  return QiniuFileExplorer(
    element: element,
    bucketPrefix: bucketPrefix,
  );
});

//七牛云文件详情页面
var qiniuFileInformationHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  var fileMap = json.decode(params['fileMap']!.first);
  return QiniuFileInformation(
    fileMap: fileMap,
  );
});

//七牛云存储下载文件页面
var qiniuDownloadFileHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  var bucketName = params['bucketName']!.first;
  String downloadPath = params['downloadPath']!.first;
  String tabIndex = params['tabIndex']!.first;
  return QiniuUpDownloadManagePage(
      bucketName: bucketName, downloadPath: downloadPath, tabIndex: tabIndex);
});

//lskypro图床管理首页
var lskyproManageHomePageHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const LskyproManageHomePage();
});

//lskypro文件列表页面
var lskyproFileExplorerHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  var userProfile = json.decode(params['userProfile']!.first);
  var albumInfo = json.decode(params['albumInfo']!.first);
  return LskyproFileExplorer(
    userProfile: userProfile,
    albumInfo: albumInfo,
  );
});

//lskypro文件详情页面
var lskyproFileInformationHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  var fileMap = json.decode(params['fileMap']!.first);
  return LskyproFileInformation(
    fileMap: fileMap,
  );
});

//lskypro存储下载文件页面
var lskyproDownloadFileHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  var albumName = params['albumName']!.first;
  String downloadPath = params['downloadPath']!.first;
  String tabIndex = params['tabIndex']!.first;
  return LskyproUpDownloadManagePage(
      albumName: albumName, downloadPath: downloadPath, tabIndex: tabIndex);
});

//github图床管理首页
var githubManageHomePageHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const GithubManageHomePage();
});

//github仓库列表页面
var githubReposListHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  String showedUsername = params['showedUsername']!.first;
  return GithubReposList(
    showedUsername: showedUsername,
  );
});

//github仓库详情页面
var githubRepoInformationHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  var repoMap = json.decode(params['repoMap']!.first);
  return GithubRepoInformation(
    repoMap: repoMap,
  );
});

//github新建仓库页面
var githubNewRepoConfigHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const GithubNewRepoConfig();
});

//github文件列表页面
var githubFileExplorerHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  var element = json.decode(params['element']!.first);
  var bucketPrefix = params['bucketPrefix']!.first;
  return GithubFileExplorer(
    element: element,
    bucketPrefix: bucketPrefix,
  );
});

//github文件详情页面
var githubFileInformationHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  var fileMap = json.decode(params['fileMap']!.first);
  return GithubFileInformation(
    fileMap: fileMap,
  );
});

//Github存储下载文件页面
var githubDownloadFileHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  var userName = params['userName']!.first;
  var repoName = params['repoName']!.first;
  String downloadPath = params['downloadPath']!.first;
  String tabIndex = params['tabIndex']!.first;
  return GithubUpDownloadManagePage(
      userName: userName,
      repoName: repoName,
      downloadPath: downloadPath,
      tabIndex: tabIndex);
});
