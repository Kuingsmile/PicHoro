import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';

import 'package:horopic/picture_host_manage/common/upload/common_service/base_upload_manager.dart';

import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/utils/dio_proxy_adapter.dart';

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
    String accesstoken = configMap['accesstoken'];
    String albumHash = configMap['albumhash'];
    String proxy = configMap['proxy'];
    FormData formdata;
    if (albumHash == 'None') {
      formdata = FormData.fromMap({
        "image": await MultipartFile.fromFile(path, filename: fileName),
        "type": "file",
        "name": fileName,
        "description": "Uploaded by PicHoro",
      });
    } else {
      formdata = FormData.fromMap({
        "image": await MultipartFile.fromFile(path, filename: fileName),
        "type": "file",
        "album": albumHash,
        "name": fileName,
        "description": "Uploaded by PicHoro",
      });
    }
    BaseOptions baseoptions = setBaseOptions();
    baseoptions.headers = {
      "Authorization": "Bearer $accesstoken",
    };
    Dio dio = Dio(baseoptions);
    String proxyClean = '';
    //判断是否有代理
    if (proxy != 'None') {
      if (proxy.startsWith('http://') || proxy.startsWith('https://')) {
        proxyClean = proxy.split('://')[1];
      } else {
        proxyClean = proxy;
      }
      dio.httpClientAdapter = useProxy(proxyClean);
    }
    String accountUrl = "https://api.imgur.com/3/image";
    Response response = await dio.post(
      accountUrl,
      data: formdata,
      onSendProgress: createCallback(path, fileName),
      cancelToken: cancelToken,
    );
    if (!(response.statusCode == HttpStatus.ok && response.data['success'] == true)) {
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
        'imgurUploadManager',
        'upload');
    super.onUploadError(error, path, fileName);
  }
}
