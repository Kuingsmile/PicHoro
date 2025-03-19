import 'dart:async';
import 'dart:io';

import 'package:dartssh2/dartssh2.dart';
import 'package:dio/dio.dart';

import 'package:horopic/picture_host_manage/common/download/common_service/base_download_manager.dart';
import 'package:horopic/picture_host_manage/common/download/common_service/base_download_status.dart';
import 'package:horopic/picture_host_manage/manage_api/ftp_manage_api.dart';

class DownloadManager extends BaseDownloadManager {
  static final DownloadManager _dm = DownloadManager._internal();

  DownloadManager._internal();

  factory DownloadManager({int? maxConcurrentTasks}) {
    _dm.maxConcurrentTasks = 1;
    return _dm;
  }

  @override
  Future<void> download(String url, String savePath, cancelToken, {Map? configMap = const {}}) async {
    await processDownload(url, savePath, cancelToken, 'sftp_DownloadManager', configMap: configMap);
  }

  @override
  Future<void> handlePartialDownload(
    String url,
    String savePath,
    String partialFilePath,
    File partialFile,
    CancelToken cancelToken, {
    Map? configMap = const {},
  }) async {
    var partialFileLength = await partialFile.length();
    Map configMapFTP = await FTPManageAPI.getConfigMap();
    String ftpHost = configMapFTP['ftpHost'];
    String ftpPort = configMapFTP['ftpPort'];
    String ftpUser = configMapFTP['ftpUser'];
    String ftpPassword = configMapFTP['ftpPassword'];
    try {
      final socket = await SSHSocket.connect(ftpHost, int.parse(ftpPort));
      final client = SSHClient(
        socket,
        username: ftpUser,
        onPasswordRequest: () {
          return ftpPassword;
        },
      );
      final sftp = await client.sftp();
      var remoteFile = await sftp.open(url, mode: SftpFileOpenMode.read);
      var fileSize = await remoteFile.stat().then((value) => value.size);
      fileSize ??= -1;
      var read = remoteFile.read(
        offset: partialFileLength,
        onProgress: (
          int received,
        ) {
          getDownload(url)?.progress.value = (received + partialFileLength) / (fileSize!);
          if (fileSize == -1) {}
        },
      );
      var ioSink = partialFile.openWrite(mode: FileMode.writeOnlyAppend);
      await ioSink.addStream(read);
      await ioSink.close();
      await partialFile.rename(savePath);
      client.close();
      setStatus(getDownload(url), DownloadStatus.completed);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> handleNewDownload(
      String url, String savePath, String partialFilePath, File partialFile, CancelToken cancelToken,
      {Map? configMap = const {}}) async {
    Map configMapFTP = await FTPManageAPI.getConfigMap();
    String ftpHost = configMapFTP['ftpHost'];
    String ftpPort = configMapFTP['ftpPort'];
    String ftpUser = configMapFTP['ftpUser'];
    String ftpPassword = configMapFTP['ftpPassword'];
    try {
      final socket = await SSHSocket.connect(ftpHost, int.parse(ftpPort));
      final client = SSHClient(
        socket,
        username: ftpUser,
        onPasswordRequest: () {
          return ftpPassword;
        },
      );
      final sftp = await client.sftp();
      var remoteFile = await sftp.open(url, mode: SftpFileOpenMode.read);
      var fileSize = await remoteFile.stat().then((value) => value.size);
      fileSize ??= -1;
      var read = remoteFile.read(
        onProgress: (
          int received,
        ) {
          getDownload(url)?.progress.value = (received) / (fileSize!);
          if (fileSize == -1) {}
        },
      );
      partialFile.createSync(recursive: true);
      var ioSink = partialFile.openWrite(mode: FileMode.writeOnly);
      await ioSink.addStream(
        read,
      );
      await ioSink.close();
      await partialFile.rename(savePath);
      client.close();
      setStatus(getDownload(url), DownloadStatus.completed);
    } catch (e) {
      rethrow;
    }
  }
}
