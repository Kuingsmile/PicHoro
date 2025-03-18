import 'dart:async';
import 'dart:io';

import 'package:horopic/picture_host_manage/common/download/common_service/base_download_manager.dart';
import 'package:horopic/picture_host_manage/manage_api/aliyun_manage_api.dart';

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
    String aliyunHost = url.split('/')[2];
    String bucket = aliyunHost.split('.')[0];
    String urlpath = url.substring(aliyunHost.length + 8);
    String canonicalizedResource = '/$bucket$urlpath';
    String method = 'GET';
    Map<String, dynamic> header = {
      'Host': aliyunHost,
      'Date': HttpDate.format(DateTime.now()),
    };
    if (isPartial) {
      header['Range'] = 'bytes=$partialFileLength-';
    }
    String authorization = await AliyunManageAPI.aliyunAuthorization(method, canonicalizedResource, header, '', '');
    header['Authorization'] = authorization;
    return header;
  }

  @override
  Future<void> download(String url, String savePath, cancelToken, {Map configMap = const {}}) async {
    await processDownload(url, savePath, cancelToken, 'aliyun_DownloadManager', configMap: configMap);
  }
}
