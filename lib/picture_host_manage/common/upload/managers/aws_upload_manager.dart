import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:minio/minio.dart';
import 'package:path/path.dart' as my_path;

import 'package:horopic/picture_host_manage/common/upload/common_service/base_upload_manager.dart';
import 'package:horopic/utils/common_functions.dart';

class UploadManager extends BaseUploadManager {
  static final UploadManager _instance = UploadManager._internal();

  UploadManager._internal();

  factory UploadManager({int? maxConcurrentTasks}) {
    if (maxConcurrentTasks != null) {
      _instance.maxConcurrentTasks = maxConcurrentTasks;
    }
    return _instance;
  }

  @override
  Future<void> performUpload(String path, String fileName, Map configMap, CancelToken cancelToken) async {
    String accessKeyId = configMap['accessKeyId'];
    String secretAccessKey = configMap['secretAccessKey'];
    String bucket = configMap['bucket'];
    String endpoint = configMap['endpoint'];
    int? port;
    if (endpoint.contains(':')) {
      List<String> endpointList = endpoint.split(':');
      endpoint = endpointList[0];
      port = int.parse(endpointList[1]);
    }
    String region = configMap['region'];
    String uploadPath = configMap['uploadPath'];
    bool isEnableSSL = configMap['isEnableSSL'] ?? true;
    if (endpoint.contains('amazonaws.com')) {
      if (!endpoint.contains(region)) {
        endpoint = 's3.$region.amazonaws.com';
      }
    }

    //云存储的路径
    String urlpath = '';
    if (uploadPath != '') {
      urlpath = '$uploadPath$fileName';
    } else {
      urlpath = fileName;
    }
    Minio minio;
    if (region == 'None') {
      minio = Minio(
        endPoint: endpoint,
        port: port,
        accessKey: accessKeyId,
        secretKey: secretAccessKey,
        useSSL: isEnableSSL,
      );
    } else {
      minio = Minio(
        endPoint: endpoint,
        port: port,
        accessKey: accessKeyId,
        secretKey: secretAccessKey,
        useSSL: isEnableSSL,
        region: region,
      );
    }

    int fileSize = File(path).lengthSync();
    Stream<Uint8List> stream = File(path).openRead().cast();
    String? contentType = getContentType(my_path.extension(path).substring(1));

    await minio.putObject(bucket, urlpath, stream, metadata: {"Content-Type": contentType}, onProgress: (int sent) {
      getUpload(fileName)?.progress.value = sent / fileSize;
    });
  }

  @override
  void onUploadError(dynamic error, String path, String fileName) {
    flogErr(
        error,
        {
          'path': path,
          'fileName': fileName,
        },
        'awsUploadManager',
        'upload');
    super.onUploadError(error, path, fileName);
  }
}
