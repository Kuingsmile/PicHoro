import 'dart:async';
import 'dart:collection';
import 'dart:io';
// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:horopic/picture_host_manage/common_page/upload/pnc_upload_request.dart';
import 'package:horopic/picture_host_manage/common_page/upload/pnc_upload_task.dart';
import 'package:horopic/pages/upload_pages/upload_status.dart';
import 'package:horopic/api/qiniu_api.dart';
import 'package:horopic/utils/common_functions.dart';

class UploadManager {
  final Map<String, UploadTask> _cache = <String, UploadTask>{};
  final Queue<dynamic> _queue = Queue();
  Dio dio = Dio();

  int maxConcurrentTasks = 2;
  int runningTasks = 0;

  static final UploadManager _instance = UploadManager._internal();

  UploadManager._internal();

  factory UploadManager({int? maxConcurrentTasks}) {
    if (maxConcurrentTasks != null) {
      _instance.maxConcurrentTasks = maxConcurrentTasks;
    }
    return _instance;
  }

  void Function(int, int) createCallback(String path, String name) {
    return (int sent, int total) {
      getUpload(name)?.progress.value = sent / total;
    };
  }

  Future<void> upload(String path, String fileName, Map configMap, canceltoken) async {
    try {
      var task = getUpload(fileName);

      if (task == null || task.status.value == UploadStatus.canceled) {
        return;
      }
      setStatus(task, UploadStatus.uploading);

      Response response;
      String accessKey = configMap['accessKey'];
      String secretKey = configMap['secretKey'];
      String bucket = configMap['bucket'];
      String area = configMap['area'];
      String qiniupath = configMap['path'];

      String urlpath = '';
      //不为None才处理
      if (qiniupath != 'None' && qiniupath != '') {
        if (qiniupath.startsWith('/')) {
          qiniupath = qiniupath.substring(1);
        }
        if (!qiniupath.endsWith('/')) {
          qiniupath = '$qiniupath/';
        }
        urlpath = '$qiniupath$fileName';
      } else {
        urlpath = fileName;
      }
      String key = fileName;

      String urlSafeBase64EncodePutPolicy =
          QiniuImageUploadUtils.geturlSafeBase64EncodePutPolicy(bucket, key, qiniupath);
      String uploadToken = QiniuImageUploadUtils.getUploadToken(accessKey, secretKey, urlSafeBase64EncodePutPolicy);
      String host = QiniuImageUploadUtils.areaHostMap[area]!;
      FormData formData = FormData.fromMap({
        "key": urlpath,
        "fileName": fileName,
        "token": uploadToken,
        "file": await MultipartFile.fromFile(path, filename: fileName),
      });
      BaseOptions baseoptions = setBaseOptions();
      baseoptions.headers = {
        'Authorization': 'UpToken $uploadToken',
      };

      Dio dio = Dio(baseoptions);
      response = await dio.post(
        host,
        data: formData,
        onSendProgress: createCallback(path, fileName),
        cancelToken: canceltoken,
      );
      if (response.statusCode == HttpStatus.ok) {
        setStatus(task, UploadStatus.completed);
      }
    } catch (e) {
      flogErr(
          e,
          {
            'path': path,
            'fileName': fileName,
          },
          'QiniuUploadManager',
          'upload');
      var task = getUpload(fileName)!;
      if (task.status.value != UploadStatus.canceled && task.status.value != UploadStatus.completed) {
        setStatus(task, UploadStatus.failed);
      }
    }
    runningTasks--;
    if (_queue.isNotEmpty) {
      _startExecution();
    }
  }

  void _startExecution() async {
    if (runningTasks == maxConcurrentTasks || _queue.isEmpty) {
      return;
    }

    while (_queue.isNotEmpty && runningTasks < maxConcurrentTasks) {
      runningTasks++;
      var currentRequest = _queue.removeFirst();
      if (_cache[currentRequest.name]!.status.value.isCompleted) {
        runningTasks--;
        continue;
      }
      upload(currentRequest.path, currentRequest.name, currentRequest.configMap, currentRequest.cancelToken);
      await Future.delayed(const Duration(milliseconds: 500), null);
    }
  }

  UploadTask? getUpload(String fileName) {
    return _cache[fileName];
  }

  void setStatus(UploadTask? task, UploadStatus status) {
    if (task != null) {
      task.status.value = status;
    }
  }

  Future<UploadTask?> addUpload(String path, String fileName, Map<String, dynamic> configMap) async {
    if (path.isNotEmpty && fileName.isNotEmpty) {
      return await _addUploadRequest(UploadRequest(path, fileName, configMap));
    }
    return null;
  }

  Future<UploadTask> _addUploadRequest(UploadRequest uploadRequest) async {
    if (_cache[uploadRequest.name] != null) {
      if ((_cache[uploadRequest.name]!.status.value == UploadStatus.completed ||
              _cache[uploadRequest.name]!.status.value == UploadStatus.uploading) &&
          _cache[uploadRequest.name]!.request == uploadRequest) {
        return _cache[uploadRequest.name]!;
      } else {
        _queue.remove(_cache[uploadRequest.name]);
      }
    }
    _queue.add(UploadRequest(uploadRequest.path, uploadRequest.name, uploadRequest.configMap));
    var task = UploadTask(_queue.last);
    _cache[uploadRequest.name] = task;
    _startExecution();
    return task;
  }

  Future<void> pauseUpload(String path, String fileName) async {
    var task = getUpload(fileName);
    if (task != null) {
      setStatus(task, UploadStatus.paused);
      _queue.remove(task.request);
      task.request.cancelToken.cancel();
    }
  }

  Future<void> cancelUpload(String path, String fileName) async {
    var task = getUpload(fileName);
    if (task != null) {
      setStatus(task, UploadStatus.canceled);
      _queue.remove(task.request);
      task.request.cancelToken.cancel();
    }
  }

  Future<void> resumeUpload(String path, String fileName) async {
    var task = getUpload(fileName);
    if (task != null) {
      setStatus(task, UploadStatus.uploading);
      task.request.cancelToken = CancelToken();
      _queue.add(task.request);
    }
    _startExecution();
  }

  Future<void> removeUpload(String path, String fileName) async {
    await cancelUpload(path, fileName);
    _cache.remove(path);
  }

  Future<UploadStatus> whenUploadComplete(String path, String fileName,
      {Duration timeout = const Duration(hours: 2)}) async {
    UploadTask? task = getUpload(fileName);

    if (task != null) {
      return task.whenUploadComplete(timeout: timeout);
    } else {
      return Future.error("Upload not found");
    }
  }

  List<UploadTask> getALlUpload() {
    return _cache.values as List<UploadTask>;
  }

  Future<void> addBatchUploads(List<String> paths, List<String> names, List<Map<String, dynamic>> configMaps) async {
    for (var i = 0; i < paths.length; i++) {
      await addUpload(paths[i], names[i], configMaps[i]);
    }
  }

  List<UploadTask?> getBatchUploads(List<String> paths, List<String> names) {
    return names.map((e) => _cache[e]).toList();
  }

  Future<void> pauseBatchUploads(List<String> paths, List<String> names) async {
    for (var i = 0; i < paths.length; i++) {
      await pauseUpload(paths[i], names[i]);
    }
  }

  Future<void> cancelBatchUploads(List<String> paths, List<String> names) async {
    for (var i = 0; i < paths.length; i++) {
      await cancelUpload(paths[i], names[i]);
    }
  }

  Future<void> resumeBatchUploads(List<String> paths, List<String> names) async {
    for (var i = 0; i < paths.length; i++) {
      await resumeUpload(paths[i], names[i]);
    }
  }

  ValueNotifier<double> getBatchUploadProgress(List<String> paths, List<String> names) {
    ValueNotifier<double> progress = ValueNotifier(0);
    var total = paths.length;

    if (total == 0) {
      return progress;
    }

    if (total == 1) {
      return getUpload(names.first)?.progress ?? progress;
    }

    var progressMap = <String, double>{};

    for (var i = 0; i < paths.length; i++) {
      UploadTask? task = getUpload(names[i]);
      if (task != null) {
        progressMap[paths[i]] = 0.0;
        if (task.status.value.isCompleted) {
          progressMap[paths[i]] = 1.0;
          progress.value = progressMap.values.sum / total;
        }

        Null Function() progressListener;
        progressListener = () {
          progressMap[paths[i]] = task.progress.value;
          progress.value = progressMap.values.sum / total;
        };

        task.progress.addListener(progressListener);
        dynamic listener;
        listener = () {
          if (task.status.value.isCompleted) {
            progressMap[paths[i]] = 1.0;
            progress.value = progressMap.values.sum / total;
            task.progress.removeListener(progressListener);
            task.status.removeListener(listener);
          }
        };
        task.status.addListener(listener);
      } else {
        total--;
      }
    }
    return progress;
  }

  Future<List<UploadTask?>?> whenBatchUploadsComplete(List<String> paths, List<String> names,
      {Duration timeout = const Duration(hours: 2)}) async {
    var completer = Completer<List<UploadTask?>?>();
    var completed = 0;
    var total = paths.length;
    for (var i = 0; i < paths.length; i++) {
      UploadTask? task = getUpload(names[i]);

      if (task != null) {
        if (task.status.value.isCompleted) {
          completed++;

          if (completed == total) {
            completer.complete(getBatchUploads(paths, names));
          }
        }

        dynamic listener;
        listener = () {
          if (task.status.value.isCompleted) {
            completed++;

            if (completed == total) {
              completer.complete(getBatchUploads(paths, names));
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
}
