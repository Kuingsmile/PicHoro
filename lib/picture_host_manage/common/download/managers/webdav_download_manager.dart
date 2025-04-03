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
    Map configMap = await WebdavManageAPI().getConfigMap();
    return {
      'Authorization': generateBasicAuth(configMap['webdavusername'], configMap['password']),
      'User-Agent': 'pan.baidu.com',
      if (isPartial) 'Range': 'bytes=$partialFileLength-',
    };
  }

  @override
  Future<void> download(String url, String savePath, CancelToken cancelToken, {Map? configMap = const {}}) async {
    await processDownload(url, savePath, cancelToken, 'webdav_DownloadManager', configMap: configMap);
  }
}
