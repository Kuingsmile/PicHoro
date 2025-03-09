import 'dart:async';

// ignore: depend_on_referenced_packages
import 'package:dio/dio.dart';
import 'package:f_logs/f_logs.dart';

import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/picture_host_manage/manage_api/webdav_manage_api.dart';
import 'package:horopic/picture_host_manage/common_page/upload/base_upload_manager.dart';

import 'package:webdav_client/webdav_client.dart' as webdav;

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
    String uploadPath = configMap['uploadPath'];
    if (uploadPath == 'None') {
      uploadPath = '/';
    }
    if (!uploadPath.endsWith('/')) {
      uploadPath = '$uploadPath/';
    }
    webdav.Client client = await WebdavManageAPI.getWebdavClient();
    await client.writeFromFile(path, uploadPath + fileName, onProgress: createCallback(path, fileName));
  }

  @override
  void onUploadError(dynamic error, String path, String fileName) {
    FLog.error(
        className: 'webdavUploadManager',
        methodName: 'upload',
        text: formatErrorMessage({
          'path': path,
          'fileName': fileName,
        }, error.toString()),
        dataLogType: DataLogType.ERRORS.toString());

    super.onUploadError(error, path, fileName);
  }
}
