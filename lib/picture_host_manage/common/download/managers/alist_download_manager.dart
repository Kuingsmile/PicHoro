import 'dart:async';
import 'dart:convert';
import 'dart:io';

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
      {bool isPartial = false, int partialFileLength = 0, Map configMap = const {}}) async {
    Map addition = jsonDecode(configMap['addition']);
    Map<String, dynamic> headers = {};
    if (configMap['driver'] == 'BaiduNetdisk' && addition['download_api'] == 'official') {
      headers[HttpHeaders.userAgentHeader] = 'pan.baidu.com';
    }
    if (isPartial) {
      headers['Range'] = 'bytes=$partialFileLength-';
    }
    return headers;
  }

  @override
  Future<void> download(String url, String savePath, cancelToken,
      {Map configMap = const {}, forceDownload = false}) async {
    await processDownload(url, savePath, cancelToken, 'alist_DownloadManager',
        forceDownload: forceDownload, configMap: configMap);
  }
}
