import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';

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
    Response response;
    FormData formdata = FormData.fromMap({
      "file": await MultipartFile.fromFile(path, filename: fileName),
      if (configMap["strategy_id"] != "None") "strategy_id": configMap["strategy_id"],
      if (configMap["album_id"] != "None") "album_id": configMap["album_id"].toString(),
    });
    String token = configMap["token"];

    BaseOptions baseoptions = setBaseOptions();
    baseoptions.headers = {
      "Authorization": token,
      "Accept": "application/json",
      "Content-Type": "multipart/form-data",
    };
    Dio dio = Dio(baseoptions);
    String uploadUrl = configMap["host"] + "/api/v1/upload";
    response = await dio.post(
      uploadUrl,
      data: formdata,
      onSendProgress: createCallback(path, fileName),
      cancelToken: cancelToken,
    );
    if (!(response.statusCode == HttpStatus.ok && response.data!['status'] == true)) {
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
        'lskyproUploadManager',
        'upload');
    super.onUploadError(error, path, fileName);
  }
}
