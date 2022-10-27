import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'package:fluro/fluro.dart';

import 'package:horopic/router/router_handler.dart';

class Routes {
  static String root = "/";
  static String homePage = "/homePage";
  static String albumUploadedImages = "/albumUploadedImages";
  static String albumImagePreview = "/albumImagePreview";
  static String localImagePreview = "/localImagePreview";
  static String configurePage = "/configurePage";
  static String appPassword = "/appPassword";
  static String allPShost = "/allPShost";
  static String defaultPShostSelect = "/defaultPShostSelect";
  static String lskyproPShostSelect = "/lskyproPShostSelect";
  static String smmsPShostSelect = "/smmsPShostSelect";
  static String githubPShostSelect = "/githubPShostSelect";
  static String imgurPShostSelect = "/imgurPShostSelect";
  static String aliyunPShostSelect = "/aliyunPShostSelect";
  static String tencentPShostSelect = "/tencentPShostSelect";
  static String qiniuPShostSelect = "/qiniuPShostSelect";
  static String upyunPShostSelect = "/upyunPShostSelect";
  static String commonConfig = "/commonConfig";
  static String renameFile = "/renameFile";
  static String linkFormatSelect = "/linkFormatSelect";
  static String changeTheme = "/changeTheme";
  static String emptyDatabase = "/emptyDatabase";
  static String authorInformation = "/authorInformation";
  static String updateLog = "/updateLog";
  static String tencentBucketInformation = "/tencentBucketInformation";
  static String tencentNewBucketConfig = "/tencentNewBucketConfig";
  static String tencentFileExplorer = "/tencentFileExplorer";
  static String tencentBucketList = "/tencentBucketList";
  static String tencentUpDownloadManagePage = "/tencentUpDownloadManagePage";
  static String fileExplorer = "/fileExplorer";
  static String smmsManageHomePage = "/smmsManageHomePage";
  static String smmsFileExplorer = "/smmsFileExplorer";
  static String smmsUpDownloadManagePage = "/smmsUpDownloadManagePage";

  static void configureRoutes(FluroRouter router) {
    router.notFoundHandler = Handler(
        handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
      if (kDebugMode) {
        print("ROUTE WAS NOT FOUND !!!");
      }
      return null;
    });
    router.define(root, handler: rootHandler);
    router.define(homePage, handler: homePageHandler);
    router.define(albumUploadedImages, handler: albumUploadedImagesHandler);
    router.define(albumImagePreview, handler: albumImagePreviewHandler);
    router.define(localImagePreview, handler: localImagePreviewHandler);
    router.define(configurePage, handler: configurePageHandler);
    router.define(appPassword, handler: appPasswordHandler);
    router.define(allPShost, handler: allPShostHandler);
    router.define(defaultPShostSelect, handler: defaultPShostSelectHandler);
    router.define(lskyproPShostSelect, handler: lskyproPShostSelectHandler);
    router.define(smmsPShostSelect, handler: smmsPShostSelectHandler);
    router.define(githubPShostSelect, handler: githubPShostSelectHandler);
    router.define(imgurPShostSelect, handler: imgurPShostSelectHandler);
    router.define(aliyunPShostSelect, handler: aliyunPShostSelectHandler);
    router.define(tencentPShostSelect, handler: tencentPShostSelectHandler);
    router.define(qiniuPShostSelect, handler: qiniuPShostSelectHandler);
    router.define(upyunPShostSelect, handler: upyunPShostSelectHandler);
    router.define(commonConfig, handler: commonConfigHandler);
    router.define(renameFile, handler: renameFileHandler);
    router.define(linkFormatSelect, handler: linkFormatSelectHandler);
    router.define(changeTheme, handler: changeThemeHandler);
    router.define(emptyDatabase, handler: emptyDatabaseHandler);
    router.define(authorInformation, handler: authorInformationHandler);
    router.define(updateLog, handler: updateLogHandler);
    router.define(tencentBucketInformation,
        handler: tencentBucketInformationHandler);
    router.define(tencentNewBucketConfig, handler: newTencentBucketHandler);
    router.define(tencentFileExplorer, handler: tencentFileExplorerHandler);
    router.define(tencentBucketList, handler: tencentBucketListHandler);
    router.define(tencentUpDownloadManagePage,
        handler: tencentDownloadFileHandler);
    router.define(fileExplorer, handler: fileExplorerHandler);
    router.define(smmsManageHomePage, handler: smmsManageHomePageHandler);
    router.define(smmsFileExplorer, handler: smmsFileExplorerHandler);
    router.define(smmsUpDownloadManagePage, handler: smmsUpDownloadFileHandler);
  }
}