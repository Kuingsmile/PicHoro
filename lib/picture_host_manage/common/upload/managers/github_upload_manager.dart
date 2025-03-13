import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:dio/dio.dart';

import 'package:horopic/picture_host_manage/common/upload/common_service/base_upload_manager.dart';
import 'package:horopic/utils/common_functions.dart';

class UploadManager extends BaseUploadManager {
  static final UploadManager _instance = UploadManager._internal();

  UploadManager._internal();

  factory UploadManager({int? maxConcurrentTasks}) {
    _instance.maxConcurrentTasks = 1;

    return _instance;
  }

  @override
  Future<void> performUpload(String path, String fileName, Map configMap, CancelToken cancelToken) async {
    Response response;
    String base64Image = base64Encode(File(path).readAsBytesSync());
    Map<String, dynamic> queryBody = {
      'message': 'uploaded by PicHoro app',
      'content': base64Image,
      'branch': configMap["default_branch"], //分支
    };

    BaseOptions baseoptions = setBaseOptions();
    baseoptions.headers = {
      "Authorization": configMap["token"],
      "Accept": "application/vnd.github+json",
    };
    String trimedPath = configMap['savePath'].toString().trim();

    if (trimedPath.startsWith('/')) {
      trimedPath = trimedPath.substring(1);
    }
    if (trimedPath.endsWith('/')) {
      trimedPath = trimedPath.substring(0, trimedPath.length - 1);
    }
    String uploadUrl = '';
    if (trimedPath == '') {
      uploadUrl = "https://api.github.com/repos/${configMap["githubusername"]}/${configMap["repo"]}/contents/$fileName";
    } else {
      uploadUrl =
          "https://api.github.com/repos/${configMap["githubusername"]}/${configMap["repo"]}/contents/$trimedPath/$fileName";
    }
    Dio dio = Dio(baseoptions);
    response = await dio.put(
      uploadUrl,
      data: jsonEncode(queryBody),
      onSendProgress: createCallback(path, fileName),
    );
    if (response.statusCode != HttpStatus.ok && response.statusCode != HttpStatus.created) {
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
        'githubUploadManager',
        'upload');
    super.onUploadError(error, path, fileName);
  }
}
