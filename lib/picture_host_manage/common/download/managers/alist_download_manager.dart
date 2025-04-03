import 'dart:async';
import 'dart:convert';

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
    Map addition = jsonDecode(configMap!['addition']);
    return {
      if (isPartial) 'Range': 'bytes=$partialFileLength-',
      if (configMap['driver'] == 'BaiduNetdisk' && addition['download_api'] == 'official')
        "user-agent": 'pan.baidu.com',
    };
  }

  @override
  Future<void> download(String url, String savePath, cancelToken, {Map? configMap = const {}}) async {
    await processDownload(url, savePath, cancelToken, 'alist_DownloadManager', configMap: configMap);
  }
}
