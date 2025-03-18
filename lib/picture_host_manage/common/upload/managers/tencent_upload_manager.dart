import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path/path.dart' as my_path;

import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/utils/global.dart';
import 'package:horopic/api/tencent_api.dart';
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
    String secretId = configMap['secretId'];
    String secretKey = configMap['secretKey'];
    String bucket = configMap['bucket'];
    String area = configMap['area'];
    String tencentpath = configMap['path'];

    if (tencentpath != 'None' && tencentpath != '') {
      if (tencentpath.startsWith('/')) {
        tencentpath = tencentpath.substring(1);
      }
      if (!tencentpath.endsWith('/')) {
        tencentpath = '$tencentpath/';
      }
    }
    String host = '$bucket.cos.$area.myqcloud.com';
    //云存储的路径
    String urlpath = '';
    if (tencentpath != 'None') {
      urlpath = '/$tencentpath$fileName';
    } else {
      urlpath = '/$fileName';
    }
    int startTimestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    int endTimestamp = startTimestamp + 86400;
    String keyTime = '$startTimestamp;$endTimestamp';
    Map<String, dynamic> uploadPolicy = {
      "expiration": "2033-03-03T09:38:12.414Z",
      "conditions": [
        {"acl": "default"},
        {"bucket": bucket},
        {"key": urlpath},
        {"q-sign-algorithm": "sha1"},
        {"q-ak": secretId},
        {"q-sign-time": keyTime}
      ]
    };
    String uploadPolicyStr = jsonEncode(uploadPolicy);
    String singature = TencentImageUploadUtils.getUploadAuthorization(secretKey, keyTime, uploadPolicyStr);
    FormData formData = FormData.fromMap({
      'key': urlpath,
      'policy': base64Encode(utf8.encode(uploadPolicyStr)),
      'acl': 'default',
      'q-sign-algorithm': 'sha1',
      'q-ak': secretId,
      'q-key-time': keyTime,
      'q-sign-time': keyTime,
      'q-signature': singature,
      'file': await MultipartFile.fromFile(path, filename: my_path.basename(path)),
    });

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
        'tencentUploadManager',
        'upload');
    super.onUploadError(error, path, fileName);
  }
}
