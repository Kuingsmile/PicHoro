import 'dart:async';

import 'package:dio/dio.dart';

import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/picture_host_manage/manage_api/webdav_manage_api.dart';
import 'package:horopic/picture_host_manage/common/upload/common_service/base_upload_manager.dart';

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
    flogErr(
        error,
        {
          'path': path,
          'fileName': fileName,
        },
        'webdavUploadManager',
        'upload');
    super.onUploadError(error, path, fileName);
  }
}
