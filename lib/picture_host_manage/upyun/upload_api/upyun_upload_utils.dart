import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:f_logs/f_logs.dart';

import 'package:horopic/picture_host_manage/upyun/upload_api/upyun_upload_request.dart';
import 'package:horopic/pages/upload_pages/upload_status.dart';
import 'package:horopic/picture_host_manage/upyun/upload_api/upyun_upload_task.dart';
import 'package:horopic/utils/common_functions.dart';

class UploadManager {
  final Map<String, UploadTask> _cache = <String, UploadTask>{};
  final Queue<UploadRequest> _queue = Queue();
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

  Future<void> upload(
      String path, String fileName, Map configMap, canceltoken) async {
    try {
      var task = getUpload(fileName);

      if (task == null || task.status.value == UploadStatus.canceled) {
        return;
      }
      setStatus(task, UploadStatus.uploading);

      var response;
      String bucket = configMap['bucket'];
      String upyunOperator = configMap['operator'];
      String password = configMap['password'];
      String url = configMap['url'];
      String upyunpath = configMap['path'];
      //格式化
      if (url != "None") {
        if (!url.startsWith('http') && !url.startsWith('https')) {
          url = 'http://$url';
        }
      }
      //格式化
      if (upyunpath != 'None') {
        if (upyunpath.startsWith('/')) {
          upyunpath = upyunpath.substring(1);
        }
        if (!upyunpath.endsWith('/')) {
          upyunpath = '$upyunpath/';
        }
      }
      String host = 'http://v0.api.upyun.com';
      //云存储的路径
      String urlpath = '';
      if (upyunpath != 'None') {
        urlpath = '/$upyunpath$fileName';
      } else {
        urlpath = '/$fileName';
      }
      String date = HttpDate.format(DateTime.now());
      File uploadFile = File(path);
      String uploadFileMd5 = await uploadFile.readAsBytes().then((value) {
        return md5.convert(value).toString();
      });
      Map<String, dynamic> uploadPolicy = {
        'bucket': bucket,
        'save-key': urlpath,
        'expiration': DateTime.now().millisecondsSinceEpoch + 1800000,
        'date': date,
        'content-md5': uploadFileMd5,
      };
      String base64Policy =
          base64.encode(utf8.encode(json.encode(uploadPolicy)));
      String stringToSign = 'POST&/$bucket&$date&$base64Policy&$uploadFileMd5';
      String passwordMd5 = md5.convert(utf8.encode(password)).toString();
      String signature = base64.encode(Hmac(sha1, utf8.encode(passwordMd5))
          .convert(utf8.encode(stringToSign))
          .bytes);
      String authorization = 'UPYUN $upyunOperator:$signature';
      FormData formData = FormData.fromMap({
        'authorization': authorization,
        'policy': base64Policy,
        'file': await MultipartFile.fromFile(path, filename: fileName),
      });
      BaseOptions baseoptions = BaseOptions(
        //连接服务器超时时间，单位是毫秒.
        connectTimeout: 30000,
        //响应超时时间。
        receiveTimeout: 30000,
        sendTimeout: 30000,
      );
      String contentLength = await uploadFile.length().then((value) {
        return value.toString();
      });
      baseoptions.headers = {
        'Host': 'v0.api.upyun.com',
        'Content-Type':
            'multipart/form-data; boundary=----WebKitFormBoundary7MA4YWxkTrZu0gW',
        'Content-Length': contentLength,
        'Date': date,
        'Authorization': authorization,
        'Content-MD5': uploadFileMd5,
      };
      Dio dio = Dio(baseoptions);
      response = await dio.post(
        '$host/$bucket',
        data: formData,
        onSendProgress: createCallback(path, fileName),
        cancelToken: canceltoken,
      );
      if (response.statusCode == HttpStatus.ok) {
        setStatus(task, UploadStatus.completed);
      }
    } catch (e) {
      FLog.error(
          className: 'UpyunUploadManager',
          methodName: 'upload',
          text: formatErrorMessage({
            'path': path,
            'fileName': fileName,
          }, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      var task = getUpload(fileName)!;
      if (task.status.value != UploadStatus.canceled &&
          task.status.value != UploadStatus.completed) {
        setStatus(task, UploadStatus.failed);
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

  void _startExecution() async {
    if (runningTasks == maxConcurrentTasks || _queue.isEmpty) {
      return;
    }

    while (_queue.isNotEmpty && runningTasks < maxConcurrentTasks) {
      runningTasks++;
      var currentRequest = _queue.removeFirst();
      upload(currentRequest.path, currentRequest.name, currentRequest.configMap,
          currentRequest.cancelToken);
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

  Future<UploadTask?> addUpload(
      String path, String fileName, Map<String, dynamic> configMap) async {
    if (path.isNotEmpty && fileName.isNotEmpty) {
      return await _addUploadRequest(UploadRequest(path, fileName, configMap));
    }
    return null;
  }

  Future<UploadTask> _addUploadRequest(UploadRequest uploadRequest) async {
    if (_cache[uploadRequest.name] != null) {
      if (!_cache[uploadRequest.name]!.status.value.isCompleted &&
          _cache[uploadRequest.name]!.request == uploadRequest) {
        return _cache[uploadRequest.name]!;
      } else {
        _queue.remove(_cache[uploadRequest.name]);
      }
    }
    _queue.add(UploadRequest(
        uploadRequest.path, uploadRequest.name, uploadRequest.configMap));
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

  Future<void> addBatchUploads(List<String> paths, List<String> names,
      List<Map<String, dynamic>> configMaps) async {
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

  Future<void> cancelBatchUploads(
      List<String> paths, List<String> names) async {
    for (var i = 0; i < paths.length; i++) {
      await cancelUpload(paths[i], names[i]);
    }
  }

  Future<void> resumeBatchUploads(
      List<String> paths, List<String> names) async {
    for (var i = 0; i < paths.length; i++) {
      await resumeUpload(paths[i], names[i]);
    }
  }

  ValueNotifier<double> getBatchUploadProgress(
      List<String> paths, List<String> names) {
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

        var progressListener;
        progressListener = () {
          progressMap[paths[i]] = task.progress.value;
          progress.value = progressMap.values.sum / total;
        };

        task.progress.addListener(progressListener);
        var listener;
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

  Future<List<UploadTask?>?> whenBatchUploadsComplete(
      List<String> paths, List<String> names,
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

        var listener;
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
