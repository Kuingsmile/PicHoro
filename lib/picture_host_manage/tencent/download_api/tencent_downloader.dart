import 'dart:async';

import 'package:dio/dio.dart';

import 'package:horopic/picture_host_manage/manage_api/tencent_manage_api.dart';
import 'package:horopic/picture_host_manage/common_page/download/base_downloader.dart';

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
  Future<Map<String, dynamic>> getHeaders(String url, {bool isPartial = false, int partialFileLength = 0}) async {
    String tencentHost = url.split('/')[2];
    String urlpath = url.substring(tencentHost.length + 8);
    String method = 'GET';
    Map configMap = await TencentManageAPI.getConfigMap();

    String secretId = configMap['secretId'];
    String secretKey = configMap['secretKey'];

    Map<String, dynamic> headers = {
      'Host': tencentHost,
    };

    if (isPartial) {
      headers['Range'] = 'bytes=$partialFileLength-';
    }

    String authorization = TencentManageAPI.tecentAuthorization(method, urlpath, headers, secretId, secretKey, {});
    headers['Authorization'] = authorization;

    return headers;
  }

  @override
  Future<void> download(String url, String savePath, CancelToken cancelToken, {bool forceDownload = false}) async {
    await processDownload(url, savePath, cancelToken, 'tencent_DownloadManager', forceDownload: forceDownload);
  }
}
