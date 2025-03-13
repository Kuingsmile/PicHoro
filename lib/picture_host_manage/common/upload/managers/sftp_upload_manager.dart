import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dartssh2/dartssh2.dart';

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
    String ftpHost = configMap["ftpHost"];
    String ftpPort = configMap["ftpPort"];
    String ftpUser = configMap["ftpUser"];
    String ftpPassword = configMap["ftpPassword"];
    String uploadPath = configMap["uploadPath"];

    final socket = await SSHSocket.connect(ftpHost, int.parse(ftpPort.toString()));
    final client = SSHClient(
      socket,
      username: ftpUser,
      onPasswordRequest: () {
        return ftpPassword;
      },
    );
    final sftp = await client.sftp();
    if (uploadPath == 'None') {
      uploadPath = '/';
    }
    if (!uploadPath.startsWith('/')) {
      uploadPath = '/$uploadPath';
    }
    if (!uploadPath.endsWith('/')) {
      uploadPath = '$uploadPath/';
    }
    String urlPath = uploadPath + fileName;
    var file = await sftp.open(urlPath, mode: SftpFileOpenMode.create | SftpFileOpenMode.write);
    int fileSize = File(path).lengthSync();
    bool operateDone = false;
    file.write(File(path).openRead().cast(), onProgress: (int sent) {
      getUpload(fileName)?.progress.value = sent / fileSize;
      if (sent == fileSize) {
        operateDone = true;
      }
    });
    while (!operateDone) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    client.close();
  }

  @override
  void onUploadError(dynamic error, String path, String fileName) {
    flogErr(
        error,
        {
          'path': path,
          'fileName': fileName,
        },
        'sftpUploadManager',
        'upload');
    super.onUploadError(error, path, fileName);
  }
}
