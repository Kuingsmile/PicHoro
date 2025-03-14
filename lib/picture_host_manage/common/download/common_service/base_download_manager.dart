import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:horopic/picture_host_manage/common/download/common_service/base_download_task.dart';
import 'package:horopic/picture_host_manage/common/download/common_service/base_download_status.dart';
import 'package:horopic/picture_host_manage/common/download/common_service/base_download_request.dart';
import 'package:horopic/utils/common_functions.dart';

abstract class BaseDownloadManager {
  final Map<String, DownloadTask> _cache = <String, DownloadTask>{};
  final Queue<dynamic> _queue = Queue();
  var dio = Dio();
  static const partialExtension = ".partial";
  static const tempExtension = ".temp";

  int maxConcurrentTasks = 2;
  int runningTasks = 0;

  // Function that will be implemented by specific downloaders
  Future<void> download(String url, String savePath, CancelToken cancelToken,
      {bool forceDownload = false, Map configMap = const {}});

  // Optional method to override for custom authorization headers
  Future<Map<String, dynamic>> getHeaders(String url,
      {bool isPartial = false, int partialFileLength = 0, Map configMap = const {}}) async {
    Map<String, dynamic> headers = {};
    if (isPartial) {
      headers['Range'] = 'bytes=$partialFileLength-';
    }
    return headers;
  }

  // Optional method to override for file name extraction
  String getFileNameFromUrl(String url) {
    return url.split('/').last;
  }

  void Function(int, int) createCallback(url, int partialFileLength) => (int received, int total) {
        getDownload(url)?.progress.value = (received + partialFileLength) / (total + partialFileLength);
        if (total == -1) {}
      };

  void disposeNotifiers(DownloadTask task) {}

  void setStatus(DownloadTask? task, DownloadStatus status) {
    if (task != null) {
      task.status.value = status;
      if (status.isCompleted) {
        disposeNotifiers(task);
      }
    }
  }

  Future<DownloadTask?> addDownload(
    String url,
    String savedDir, {
    String? fileName,
    Map<String, dynamic>? configMap,
  }) async {
    if (url.isNotEmpty) {
      if (savedDir.isEmpty) {
        savedDir = ".";
      }

      String downloadFilename = '';
      if (savedDir.endsWith("/")) {
        if (fileName != null) {
          downloadFilename = savedDir + fileName;
        } else {
          downloadFilename = savedDir + getFileNameFromUrl(url);
        }
      } else {
        downloadFilename = savedDir;
      }

      return await _addDownloadRequest(
          DownloadRequest(url, downloadFilename, fileName: fileName, configMap: configMap));
    }
    return null;
  }

  Future<DownloadTask> _addDownloadRequest(
    DownloadRequest downloadRequest,
  ) async {
    if (_cache[downloadRequest.url] != null) {
      if (!_cache[downloadRequest.url]!.status.value.isCompleted &&
          _cache[downloadRequest.url]!.request == downloadRequest) {
        // Do nothing
        return _cache[downloadRequest.url]!;
      } else {
        _queue.remove(_cache[downloadRequest.url]);
      }
    }

    _queue.add(DownloadRequest(downloadRequest.url, downloadRequest.path,
        fileName: downloadRequest.fileName, configMap: downloadRequest.configMap));
    var task = DownloadTask(_queue.last);

    _cache[downloadRequest.url] = task;

    _startExecution();

    return task;
  }

  Future<void> pauseDownload(String url) async {
    var task = getDownload(url);
    if (task != null) {
      setStatus(task, DownloadStatus.paused);
      task.request.cancelToken.cancel();
      _queue.remove(task.request);
    }
  }

  Future<void> cancelDownload(String url) async {
    var task = getDownload(url);
    if (task != null) {
      setStatus(task, DownloadStatus.canceled);
      _queue.remove(task.request);
      task.request.cancelToken.cancel();
    }
  }

  Future<void> resumeDownload(String url) async {
    var task = getDownload(url);
    if (task != null) {
      setStatus(task, DownloadStatus.downloading);
      task.request.cancelToken = CancelToken();
      _queue.add(task.request);
    }

    _startExecution();
  }

  Future<void> removeDownload(String url) async {
    await cancelDownload(url);
    _cache.remove(url);
  }

  DownloadTask? getDownload(String url) {
    return _cache[url];
  }

  Future<DownloadStatus> whenDownloadComplete(String url, {Duration timeout = const Duration(hours: 2)}) async {
    DownloadTask? task = getDownload(url);

    if (task != null) {
      return task.whenDownloadComplete(timeout: timeout);
    } else {
      return Future.error("Not found");
    }
  }

  List<DownloadTask> getAllDownloads() {
    return _cache.values.toList();
  }

  // Batch Download Mechanism
  Future<List<DownloadTask?>> addBatchDownloads(List<String> urls, String savedDir,
      {List<String>? fileNames, List<Map<String, dynamic>>? configMaps}) async {
    List<Future<DownloadTask?>> futures = [];
    for (var url in urls) {
      futures.add(addDownload(url, savedDir,
          fileName: fileNames?[urls.indexOf(url)], configMap: configMaps?[urls.indexOf(url)]));
    }
    return await Future.wait(futures);
  }

  // Add batch downloads with different directories for each URL
  Future<List<DownloadTask?>> addBatchDownloadsWithDirs(
    List<String> urls,
    List<String> savedDirList, {
    List<String>? fileNames,
    List<Map<String, dynamic>>? configMaps,
  }) async {
    if (urls.length != savedDirList.length) {
      throw Exception('URLs and directories lists must have the same length');
    }

    List<Future<DownloadTask?>> futures = [];
    for (var i = 0; i < urls.length; i++) {
      futures.add(addDownload(urls[i], savedDirList[i], fileName: fileNames?[i], configMap: configMaps?[i]));
    }
    return await Future.wait(futures);
  }

  List<DownloadTask?> getBatchDownloads(List<String> urls) {
    return urls.map((e) => _cache[e]).toList();
  }

  Future<void> pauseBatchDownloads(List<String> urls) async {
    await Future.wait(urls.map((url) => pauseDownload(url)));
  }

  Future<void> cancelBatchDownloads(List<String> urls) async {
    await Future.wait(urls.map((url) => cancelDownload(url)));
  }

  Future<void> resumeBatchDownloads(List<String> urls) async {
    await Future.wait(urls.map((url) => resumeDownload(url)));
  }

  ValueNotifier<double> getBatchDownloadProgress(List<String> urls) {
    ValueNotifier<double> progress = ValueNotifier(0);
    var total = urls.length;

    if (total == 0) {
      return progress;
    }

    if (total == 1) {
      return getDownload(urls.first)?.progress ?? progress;
    }

    var progressMap = <String, double>{};

    for (var url in urls) {
      DownloadTask? task = getDownload(url);

      if (task != null) {
        progressMap[url] = 0.0;

        if (task.status.value.isCompleted) {
          progressMap[url] = 1.0;
          progress.value = progressMap.values.sum / total;
        }

        Null Function() progressListener;
        progressListener = () {
          progressMap[url] = task.progress.value;
          progress.value = progressMap.values.sum / total;
        };

        task.progress.addListener(progressListener);

        dynamic listener;
        listener = () {
          if (task.status.value.isCompleted) {
            progressMap[url] = 1.0;
            progress.value = progressMap.values.sum / total;
            task.status.removeListener(listener);
            task.progress.removeListener(progressListener);
          }
        };

        task.status.addListener(listener);
      } else {
        total--;
      }
    }

    return progress;
  }

  Future<List<DownloadTask?>?> whenBatchDownloadsComplete(List<String> urls,
      {Duration timeout = const Duration(hours: 2)}) async {
    var completer = Completer<List<DownloadTask?>?>();

    var completed = 0;
    var total = urls.length;

    for (var url in urls) {
      DownloadTask? task = getDownload(url);

      if (task != null) {
        if (task.status.value.isCompleted) {
          completed++;

          if (completed == total) {
            completer.complete(getBatchDownloads(urls));
          }
        }

        dynamic listener;
        listener = () {
          if (task.status.value.isCompleted) {
            completed++;

            if (completed == total) {
              completer.complete(getBatchDownloads(urls));
              task.status.removeListener(listener);
            }
          }
        };

        task.status.addListener(listener);
      } else {
        total--;

        if (total == 0) {
          completer.complete(null);
        }
      }
    }

    return completer.future.timeout(timeout);
  }

  void _startExecution() async {
    if (runningTasks == maxConcurrentTasks || _queue.isEmpty) {
      return;
    }

    while (_queue.isNotEmpty && runningTasks < maxConcurrentTasks) {
      runningTasks++;

      var currentRequest = _queue.removeFirst();

      download(currentRequest.url, currentRequest.path, currentRequest.cancelToken);

      await Future.delayed(const Duration(milliseconds: 500), null);
    }
  }

  // Helper methods for common download operations
  Future<void> processDownload(String url, String savePath, CancelToken cancelToken, String logTag,
      {bool forceDownload = false, Map configMap = const {}}) async {
    try {
      var task = getDownload(url);

      if (task == null || task.status.value == DownloadStatus.canceled) {
        return;
      }
      setStatus(task, DownloadStatus.downloading);

      if (logTag == 'github_DownloadManager') {
        if (savePath.contains('?')) {
          savePath = savePath.substring(0, savePath.indexOf('?'));
        }
      }
      var file = File(savePath.toString());
      var partialFilePath = savePath + partialExtension;
      var partialFile = File(partialFilePath);

      var fileExist = await file.exists();
      var partialFileExist = await partialFile.exists();

      if (fileExist) {
        setStatus(task, DownloadStatus.completed);
      } else if (partialFileExist) {
        await handlePartialDownload(url, savePath, partialFilePath, partialFile, cancelToken, configMap: configMap);
      } else {
        await handleNewDownload(url, savePath, partialFilePath, partialFile, cancelToken, configMap: configMap);
      }
    } catch (e) {
      flogErr(
          e,
          {
            'url': url,
            'savePath': savePath,
          },
          logTag,
          'download');
      var task = getDownload(url)!;
      if (task.status.value != DownloadStatus.canceled && task.status.value != DownloadStatus.paused) {
        setStatus(task, DownloadStatus.failed);
      }
    }

    runningTasks--;

    if (_queue.isNotEmpty) {
      _startExecution();
    }
  }

  Future<void> handlePartialDownload(
    String url,
    String savePath,
    String partialFilePath,
    File partialFile,
    CancelToken cancelToken, {
    Map configMap = const {},
  }) async {
    var partialFileLength = await partialFile.length();
    Map<String, dynamic> headers =
        await getHeaders(url, isPartial: true, partialFileLength: partialFileLength, configMap: configMap);

    var response = await dio.download(url, partialFilePath + tempExtension,
        onReceiveProgress: createCallback(url, partialFileLength),
        options: Options(headers: headers),
        cancelToken: cancelToken,
        deleteOnError: true);

    if (response.statusCode == HttpStatus.partialContent || response.statusCode == HttpStatus.ok) {
      var ioSink = partialFile.openWrite(mode: FileMode.writeOnlyAppend);
      var f = File(partialFilePath + tempExtension);
      await ioSink.addStream(f.openRead());
      await f.delete();
      await ioSink.close();
      await partialFile.rename(savePath);

      setStatus(getDownload(url), DownloadStatus.completed);
    }
  }

  Future<void> handleNewDownload(
      String url, String savePath, String partialFilePath, File partialFile, CancelToken cancelToken,
      {Map configMap = const {}}) async {
    Map<String, dynamic> headers = await getHeaders(url, configMap: configMap);

    var response = await dio.download(url, partialFilePath,
        onReceiveProgress: createCallback(url, 0),
        cancelToken: cancelToken,
        deleteOnError: false,
        options: Options(headers: headers));

    if (response.statusCode == HttpStatus.ok) {
      await partialFile.rename(savePath);
      setStatus(getDownload(url), DownloadStatus.completed);
    }
  }
}
