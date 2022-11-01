import 'dart:async';
import 'dart:collection';
import 'dart:io';
// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:f_logs/f_logs.dart';

import 'package:horopic/picture_host_manage/aliyun/download_api/aliyun_download_task.dart';
import 'package:horopic/picture_host_manage/tencent/download_api/download_status.dart';
import 'package:horopic/picture_host_manage/tencent/download_api/download_request.dart';
import 'package:horopic/picture_host_manage/manage_api/aliyun_manage_api.dart';
import 'package:horopic/utils/common_functions.dart';

class DownloadManager {
  final Map<String, DownloadTask> _cache = <String, DownloadTask>{};
  final Queue<DownloadRequest> _queue = Queue();
  var dio = Dio();
  static const partialExtension = ".partial";
  static const tempExtension = ".temp";

  // var tasks = StreamController<DownloadTask>();

  int maxConcurrentTasks = 2;
  int runningTasks = 0;

  static final DownloadManager _dm = DownloadManager._internal();

  DownloadManager._internal();

  factory DownloadManager({int? maxConcurrentTasks}) {
    if (maxConcurrentTasks != null) {
      _dm.maxConcurrentTasks = maxConcurrentTasks;
    }
    return _dm;
  }

  void Function(int, int) createCallback(url, int partialFileLength) =>
      (int received, int total) {
        getDownload(url)?.progress.value =
            (received + partialFileLength) / (total + partialFileLength);

        if (total == -1) {}
      };

  Future<void> download(String url, String savePath, cancelToken,
      {forceDownload = false}) async {
    try {
      var task = getDownload(url);

      if (task == null || task.status.value == DownloadStatus.canceled) {
        return;
      }
      setStatus(task, DownloadStatus.downloading);

      var file = File(savePath.toString());
      var partialFilePath = savePath + partialExtension;
      var partialFile = File(partialFilePath);

      var fileExist = await file.exists();
      var partialFileExist = await partialFile.exists();

      if (fileExist) {
        setStatus(task, DownloadStatus.completed);
      } else if (partialFileExist) {
        var partialFileLength = await partialFile.length();
        String aliyunHost = url.split('/')[2];
        String bucket = aliyunHost.split('.')[0];

        String urlpath = url.substring(aliyunHost.length + 8);
        String canonicalizedResource = '/$bucket$urlpath';
        String method = 'GET';

        Map<String, dynamic> header = {
          'Host': aliyunHost,
          'Date': HttpDate.format(DateTime.now()),
          'Range': 'bytes=$partialFileLength-',
        };
        String authorization = await AliyunManageAPI.aliyunAuthorization(
            method, canonicalizedResource, header, '', '');
        BaseOptions options = BaseOptions();
        options.headers = header;
        options.headers['Authorization'] = authorization;

        var response = await dio.download(url, partialFilePath + tempExtension,
            onReceiveProgress: createCallback(url, partialFileLength),
            cancelToken: cancelToken,
            deleteOnError: true);

        if (response.statusCode == HttpStatus.ok) {
          var ioSink = partialFile.openWrite(mode: FileMode.writeOnlyAppend);
          var f = File(partialFilePath + tempExtension);
          await ioSink.addStream(f.openRead());
          await f.delete();
          await ioSink.close();
          await partialFile.rename(savePath);

          setStatus(task, DownloadStatus.completed);
        }
      } else {
        String aliyunHost = url.split('/')[2];
        String bucket = aliyunHost.split('.')[0];
        String urlpath = url.substring(aliyunHost.length + 8);
        String canonicalizedResource = '/$bucket$urlpath';
        String method = 'GET';
        Map<String, dynamic> header = {
          'Host': aliyunHost,
          'Date': HttpDate.format(DateTime.now()),
        };

        String authorization = await AliyunManageAPI.aliyunAuthorization(
            method, canonicalizedResource, header, '', '');
        BaseOptions options = BaseOptions();
        options.headers = header;
        options.headers['Authorization'] = authorization;
        Dio dio = Dio(options);
        var response = await dio.download(
          url,
          partialFilePath,
          onReceiveProgress: createCallback(url, 0),
          cancelToken: cancelToken,
          deleteOnError: false,
        );

        if (response.statusCode == HttpStatus.ok) {
          await partialFile.rename(savePath);
          setStatus(task, DownloadStatus.completed);
        }
      }
    } catch (e) {
      if (e is DioError) {
        FLog.error(
            className: 'aliyun_DownloadManager',
            methodName: 'download',
            text: formatErrorMessage({
              'url': url,
              'savePath': savePath,
            }, e.toString(), isDioError: true, dioErrorMessage: e),
            dataLogType: DataLogType.ERRORS.toString());
      } else {
        FLog.error(
            className: 'aliyun_DownloadManager',
            methodName: 'download',
            text: formatErrorMessage({
              'url': url,
              'savePath': savePath,
            }, e.toString()),
            dataLogType: DataLogType.ERRORS.toString());
      }
      var task = getDownload(url)!;
      if (task.status.value != DownloadStatus.canceled &&
          task.status.value != DownloadStatus.paused) {
        setStatus(task, DownloadStatus.failed);
        runningTasks--;

        if (_queue.isNotEmpty) {
          _startExecution();
        }
        rethrow;
      }
    }

    runningTasks--;

    if (_queue.isNotEmpty) {
      _startExecution();
    }
  }

  void disposeNotifiers(DownloadTask task) {
    // task.status.dispose();
    // task.progress.dispose();
  }

  void setStatus(DownloadTask? task, DownloadStatus status) {
    if (task != null) {
      task.status.value = status;

      // tasks.add(task);
      if (status.isCompleted) {
        disposeNotifiers(task);
      }
    }
  }

  Future<DownloadTask?> addDownload(
    String url,
    String savedDir,
  ) async {
    if (url.isNotEmpty) {
      if (savedDir.isEmpty) {
        savedDir = ".";
      }

      var isDirectory = await Directory(savedDir).exists();
      var downloadFilename =
          isDirectory ? "$savedDir/${getFileNameFromUrl(url)}" : savedDir;

      return await _addDownloadRequest(DownloadRequest(url, downloadFilename));
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

    _queue.add(DownloadRequest(downloadRequest.url, downloadRequest.path));
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

  // Do not immediately call getDownload After addDownload, rather use the returned DownloadTask from addDownload
  DownloadTask? getDownload(String url) {
    return _cache[url];
  }

  Future<DownloadStatus> whenDownloadComplete(String url,
      {Duration timeout = const Duration(hours: 2)}) async {
    DownloadTask? task = getDownload(url);

    if (task != null) {
      return task.whenDownloadComplete(timeout: timeout);
    } else {
      return Future.error("Not found");
    }
  }

  List<DownloadTask> getAllDownloads() {
    return _cache.values as List<DownloadTask>;
  }

  // Batch Download Mechanism
  Future<void> addBatchDownloads(List<String> urls, String savedDir) async {
    for (var url in urls) {
      await addDownload(url, savedDir);
    }
  }

  List<DownloadTask?> getBatchDownloads(List<String> urls) {
    return urls.map((e) => _cache[e]).toList();
  }

  Future<void> pauseBatchDownloads(List<String> urls) async {
    for (var element in urls) {
      await pauseDownload(element);
    }
  }

  Future<void> cancelBatchDownloads(List<String> urls) async {
    for (var element in urls) {
      await cancelDownload(element);
    }
  }

  Future<void> resumeBatchDownloads(List<String> urls) async {
    for (var element in urls) {
      await resumeDownload(element);
    }
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

        var progressListener;
        progressListener = () {
          progressMap[url] = task.progress.value;
          progress.value = progressMap.values.sum / total;
        };

        task.progress.addListener(progressListener);

        var listener;
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

        var listener;
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

      download(
          currentRequest.url, currentRequest.path, currentRequest.cancelToken);

      await Future.delayed(const Duration(milliseconds: 500), null);
    }
  }

  /// This function is used for get file name with extension from url
  String getFileNameFromUrl(String url) {
    return url.split('/').last;
  }
}
