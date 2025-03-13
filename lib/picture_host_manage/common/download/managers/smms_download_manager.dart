import 'dart:async';

import 'package:dio/dio.dart';

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
  Future<void> download(String url, String savePath, CancelToken cancelToken,
      {bool forceDownload = false, Map configMap = const {}}) async {
    await processDownload(url, savePath, cancelToken, 'smmsDownloadManager',
        forceDownload: forceDownload, configMap: configMap);
  }
}
