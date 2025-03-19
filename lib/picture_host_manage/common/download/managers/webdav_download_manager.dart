import 'dart:async';

import 'package:dio/dio.dart';

import 'package:horopic/picture_host_manage/manage_api/webdav_manage_api.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/picture_host_manage/common/download/common_service/base_download_manager.dart';

class DownloadManager extends BaseDownloadManager {
  static final DownloadManager _dm = DownloadManager._internal();

  DownloadManager._internal();

  factory DownloadManager({int? maxConcurrentTasks}) {
    if (maxConcurrentTasks != null) {
      _dm.maxConcurrentTasks = maxConcurrentTasks;
    }
    return _dm;
  }

  @override
  Future<Map<String, dynamic>> getHeaders(String url,
      {bool isPartial = false, int partialFileLength = 0, Map? configMap = const {}}) async {
    Map configMap = await WebdavManageAPI.getConfigMap();
    String webdavusername = configMap['webdavusername'];
    String password = configMap['password'];

    Map<String, dynamic> headers = {
      'Authorization': generateBasicAuth(webdavusername, password),
      'User-Agent': 'pan.baidu.com',
    };

    if (isPartial) {
      headers['Range'] = 'bytes=$partialFileLength-';
    }

    return headers;
  }

  @override
  Future<void> download(String url, String savePath, CancelToken cancelToken, {Map? configMap = const {}}) async {
    await processDownload(url, savePath, cancelToken, 'webdav_DownloadManager', configMap: configMap);
  }
}
