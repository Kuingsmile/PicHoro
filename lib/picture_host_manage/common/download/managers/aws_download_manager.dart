import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:minio/minio.dart';

import 'package:horopic/picture_host_manage/common/download/common_service/base_download_manager.dart';
import 'package:horopic/picture_host_manage/common/download/common_service/base_download_status.dart';
import 'package:horopic/picture_host_manage/manage_api/aws_manage_api.dart';

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
  Future<void> download(String url, String savePath, cancelToken, {Map? configMap = const {}}) async {
    await processDownload(url, savePath, cancelToken, 'aws_DownloadManager', configMap: configMap);
  }

  @override
  Future<void> handlePartialDownload(
    String url,
    String savePath,
    String partialFilePath,
    File partialFile,
    CancelToken cancelToken, {
    Map? configMap = const {},
  }) async {
    Map urlMap = jsonDecode(url);
    String urlpath = urlMap['object'];
    String region = urlMap['region'];
    String bucket = urlMap['bucket'];

    Map configMap = await AwsManageAPI().getConfigMap();

    String accessKeyId = configMap['accessKeyId'];
    String secretAccessKey = configMap['secretAccessKey'];
    String endpoint = configMap['endpoint'];
    int? port;
    if (endpoint.contains(':')) {
      List<String> endpointList = endpoint.split(':');
      endpoint = endpointList[0];
      port = int.parse(endpointList[1]);
    }
    bool isEnableSSL = configMap['isEnableSSL'] ?? true;
    if (endpoint.contains('amazonaws.com')) {
      if (!endpoint.contains(region)) {
        endpoint = 's3.$region.amazonaws.com';
      }
    }

    Minio minio = Minio(
        endPoint: endpoint,
        port: port,
        accessKey: accessKeyId,
        secretKey: secretAccessKey,
        useSSL: isEnableSSL,
        region: region == 'None' ? null : region);

    try {
      final stream = await minio.getObject(bucket, urlpath);

      var ioSink = partialFile.openWrite(mode: FileMode.writeOnlyAppend);
      await ioSink.addStream(stream);
      await ioSink.close();
      await partialFile.rename(savePath);

      setStatus(getDownload(url), DownloadStatus.completed);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> handleNewDownload(
      String url, String savePath, String partialFilePath, File partialFile, CancelToken cancelToken,
      {Map? configMap = const {}}) async {
    try {
      Map urlMap = jsonDecode(url);
      String urlpath = urlMap['object'];
      String region = urlMap['region'];
      String bucket = urlMap['bucket'];
      Minio? minio = await AwsManageAPI().getMinioClient(region);
      if (minio == null) {
        throw Exception('Minio client is null');
      }
      final stream = await minio.getObject(bucket, urlpath);
      partialFile.createSync(recursive: true);
      var ioSink = partialFile.openWrite(mode: FileMode.writeOnlyAppend);
      await ioSink.addStream(stream);
      await ioSink.close();
      await partialFile.rename(savePath);
      setStatus(getDownload(url), DownloadStatus.completed);
    } catch (e) {
      rethrow;
    }
  }

  @override
  String getFileNameFromUrl(String url) {
    Map urlMap = jsonDecode(url);
    return urlMap['object'].split('/').last;
  }
}
