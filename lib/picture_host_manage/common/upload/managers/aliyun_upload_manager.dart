import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as my_path;

import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/utils/global.dart';
import 'package:horopic/picture_host_manage/common/upload/common_service/base_upload_manager.dart';

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
    String keyId = configMap['keyId'];
    String keySecret = configMap['keySecret'];
    String bucket = configMap['bucket'];
    String area = configMap['area'];
    String aliyunpath = configMap['path'];

    //格式化
    if (aliyunpath != 'None' && aliyunpath != '') {
      if (aliyunpath.startsWith('/')) {
        aliyunpath = aliyunpath.substring(1);
      }
      if (!aliyunpath.endsWith('/')) {
        aliyunpath = '$aliyunpath/';
      }
    }
    String host = '$bucket.$area.aliyuncs.com';
    //云存储的路径
    String urlpath = '';
    //阿里云不能以/开头
    if (aliyunpath != 'None') {
      urlpath = '$aliyunpath$fileName';
    } else {
      urlpath = fileName;
    }

    Map<String, dynamic> uploadPolicy = {
      "expiration": "2034-12-01T12:00:00.000Z",
      "conditions": [
        {"bucket": bucket},
        ["content-length-range", 0, 104857600],
        {"key": urlpath}
      ]
    };
    String base64Policy = base64.encode(utf8.encode(json.encode(uploadPolicy)));
    String singature = base64.encode(Hmac(sha1, utf8.encode(keySecret)).convert(utf8.encode(base64Policy)).bytes);
    Map<String, dynamic> formMap = {
      'key': urlpath,
      'OSSAccessKeyId': keyId,
      'policy': base64Policy,
      'Signature': singature,
      'file': await MultipartFile.fromFile(path, filename: fileName),
    };
    formMap['x-oss-content-type'] = getContentType(my_path.extension(path));
    FormData formData = FormData.fromMap(formMap);
    BaseOptions baseoptions = setBaseOptions();
    File uploadFile = File(path);
    String contentLength = await uploadFile.length().then((value) {
      return value.toString();
    });
    baseoptions.headers = {
      'Host': host,
      'Content-Type': Global.multipartString,
      'Content-Length': contentLength,
    };
    Dio dio = Dio(baseoptions);
    response = await dio.post(
      'https://$host',
      data: formData,
      onSendProgress: createCallback(path, fileName),
      cancelToken: cancelToken,
    );
    if (response.statusCode != HttpStatus.noContent) {
      throw Exception('Upload failed with status code: ${response.statusCode}');
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
        'AliyunUploadManager',
        'upload');
    super.onUploadError(error, path, fileName);
  }
}
