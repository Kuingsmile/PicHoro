import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as my_path;

import 'package:horopic/picture_host_manage/common_page/upload/base_upload_manager.dart';
import 'package:horopic/utils/common_functions.dart';

class UploadManager extends BaseUploadManager {
  static final UploadManager _instance = UploadManager._internal();

  UploadManager._internal() {
    maxConcurrentTasks = 2;
  }

  factory UploadManager({int? maxConcurrentTasks}) {
    if (maxConcurrentTasks != null) {
      _instance.maxConcurrentTasks = maxConcurrentTasks;
    }
    return _instance;
  }

  @override
  Future<void> performUpload(String path, String fileName, Map configMap, CancelToken cancelToken) async {
    FormData formdata = FormData.fromMap({
      "smfile": await MultipartFile.fromFile(path, filename: my_path.basename(path)),
      "format": "json",
    });

    String token = configMap['token'];
    BaseOptions options = setBaseOptions();
    options.headers = {
      "Authorization": token,
      "Content-Type": "multipart/form-data",
    };

    Dio dio = Dio(options);
    String uploadUrl = "https://smms.app/api/v2/upload";

    Response response = await dio.post(
      uploadUrl,
      data: formdata,
      onSendProgress: createCallback(path, fileName),
      cancelToken: cancelToken,
    );

    if (response.statusCode != HttpStatus.ok || response.data!['success'] != true) {
      throw Exception("Upload failed: ${response.statusCode} - ${response.data}");
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
        'smmsUploadManager',
        'upload');

    super.onUploadError(error, path, fileName);
  }
}
