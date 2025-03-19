import 'dart:async';

import 'package:dio/dio.dart';

import 'package:horopic/picture_host_manage/manage_api/tencent_manage_api.dart';
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
    String tencentHost = url.split('/')[2];
    String urlpath = url.substring(tencentHost.length + 8);
    String method = 'GET';
    Map tencentConfig = await TencentManageAPI.getConfigMap();

    String secretId = tencentConfig['secretId'];
    String secretKey = tencentConfig['secretKey'];

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
  Future<void> download(String url, String savePath, CancelToken cancelToken, {Map? configMap = const {}}) async {
    await processDownload(url, savePath, cancelToken, 'tencent_DownloadManager', configMap: configMap);
  }
}
