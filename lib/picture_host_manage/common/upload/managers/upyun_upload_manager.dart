import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';

import 'package:horopic/picture_host_manage/common/upload/common_service/base_upload_manager.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/utils/global.dart';

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
    String bucket = configMap['bucket'];
    String upyunOperator = configMap['operator'];
    String password = configMap['password'];
    String url = configMap['url'];
    String upyunpath = configMap['path'];
    //格式化
    if (url != "None") {
      if (!url.startsWith('http') && !url.startsWith('https')) {
        url = 'http://$url';
      }
    }
    //格式化
    if (upyunpath != 'None') {
      if (upyunpath.startsWith('/')) {
        upyunpath = upyunpath.substring(1);
      }
      if (!upyunpath.endsWith('/')) {
        upyunpath = '$upyunpath/';
      }
    }
    String host = 'http://v0.api.upyun.com';
    //云存储的路径
    String urlpath = '';
    if (upyunpath != 'None') {
      urlpath = '/$upyunpath$fileName';
    } else {
      urlpath = '/$fileName';
    }
    String date = HttpDate.format(DateTime.now());
    File uploadFile = File(path);
    String uploadFileMd5 = await uploadFile.readAsBytes().then((value) {
      return md5.convert(value).toString();
    });
    Map<String, dynamic> uploadPolicy = {
      'bucket': bucket,
      'save-key': urlpath,
      'expiration': DateTime.now().millisecondsSinceEpoch + 1800000,
      'date': date,
      'content-md5': uploadFileMd5,
    };
    String base64Policy = base64.encode(utf8.encode(json.encode(uploadPolicy)));
    String stringToSign = 'POST&/$bucket&$date&$base64Policy&$uploadFileMd5';
    String passwordMd5 = md5.convert(utf8.encode(password)).toString();
    String signature = base64.encode(Hmac(sha1, utf8.encode(passwordMd5)).convert(utf8.encode(stringToSign)).bytes);
    String authorization = 'UPYUN $upyunOperator:$signature';
    FormData formData = FormData.fromMap({
      'authorization': authorization,
      'policy': base64Policy,
      'file': await MultipartFile.fromFile(path, filename: fileName),
    });
    BaseOptions baseoptions = setBaseOptions();
    String contentLength = await uploadFile.length().then((value) {
      return value.toString();
    });
    baseoptions.headers = {
      'Host': 'v0.api.upyun.com',
      'Content-Type': Global.multipartString,
      'Content-Length': contentLength,
      'Date': date,
      'Authorization': authorization,
      'Content-MD5': uploadFileMd5,
    };
    Dio dio = Dio(baseoptions);
    response = await dio.post(
      '$host/$bucket',
      data: formData,
      onSendProgress: createCallback(path, fileName),
      cancelToken: cancelToken,
    );
    if (response.statusCode != HttpStatus.ok) {
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
        'UpyunUploadManager',
        'upload');
    super.onUploadError(error, path, fileName);
  }
}
