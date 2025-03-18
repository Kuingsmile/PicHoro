import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';

import 'package:horopic/picture_host_manage/common/upload/common_service/base_upload_manager.dart';
import 'package:horopic/api/qiniu_api.dart';
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
    Response response;
    String accessKey = configMap['accessKey'];
    String secretKey = configMap['secretKey'];
    String bucket = configMap['bucket'];
    String area = configMap['area'];
    String qiniupath = configMap['path'];

    String urlpath = '';
    //不为None才处理
    if (qiniupath != 'None' && qiniupath != '') {
      if (qiniupath.startsWith('/')) {
        qiniupath = qiniupath.substring(1);
      }
      if (!qiniupath.endsWith('/')) {
        qiniupath = '$qiniupath/';
      }
      urlpath = '$qiniupath$fileName';
    } else {
      urlpath = fileName;
    }
    String key = fileName;

    String urlSafeBase64EncodePutPolicy = QiniuImageUploadUtils.geturlSafeBase64EncodePutPolicy(bucket, key, qiniupath);
    String uploadToken = QiniuImageUploadUtils.getUploadToken(accessKey, secretKey, urlSafeBase64EncodePutPolicy);
    String host = QiniuImageUploadUtils.areaHostMap[area]!;
    FormData formData = FormData.fromMap({
      "key": urlpath,
      "fileName": fileName,
      "token": uploadToken,
      "file": await MultipartFile.fromFile(path, filename: fileName),
    });
    BaseOptions baseoptions = setBaseOptions();
    baseoptions.headers = {
      'Authorization': 'UpToken $uploadToken',
    };

    Dio dio = Dio(baseoptions);
    response = await dio.post(
      host,
      data: formData,
      onSendProgress: createCallback(path, fileName),
      cancelToken: cancelToken,
    );
    if (response.statusCode != HttpStatus.ok) {
      throw Exception('Upload failed: ${response.statusCode} - ${response.data}');
    }
  }

  @override
  void onUploadError(dynamic error, String path, String fileName) {
    flogErr(
        error,
        {
          'path': path,
          'fileName': fileName,
        },
        'QiniuUploadManager',
        'upload');
    super.onUploadError(error, path, fileName);
  }
}
