import 'dart:async';
import 'dart:io';

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
    String uploadPath = configMap['uploadPath'];
    //格式化
    if (uploadPath == 'None') {
      uploadPath = '/';
    } else {
      if (!uploadPath.startsWith('/')) {
        uploadPath = '/$uploadPath';
      }
      if (!uploadPath.endsWith('/')) {
        uploadPath = '$uploadPath/';
      }
    }
    String filePath = uploadPath + fileName;

    FormData formdata = FormData.fromMap({
      "file": await MultipartFile.fromFile(path, filename: fileName),
    });
    File uploadFile = File(path);
    int contentLength = await uploadFile.length().then((value) {
      return value;
    });
    BaseOptions baseoptions = setBaseOptions();

    baseoptions.headers = {
      "Authorization": configMap["token"],
      "Content-Type": Global.multipartString,
      "file-path": Uri.encodeComponent(filePath),
      "Content-Length": contentLength,
    };
    Dio dio = Dio(baseoptions);
    Response response = await dio.put(
      '${configMap["host"]}/api/fs/form',
      data: formdata,
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
        'alistUploadManager',
        'upload');
    super.onUploadError(error, path, fileName);
  }
}
