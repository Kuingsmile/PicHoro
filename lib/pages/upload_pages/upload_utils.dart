import 'dart:async';
import 'dart:collection';
import 'dart:convert';
// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:f_logs/f_logs.dart';
import 'package:horopic/api/api.dart';

import 'package:horopic/pages/upload_pages/upload_request.dart';
import 'package:horopic/pages/upload_pages/upload_status.dart';
import 'package:horopic/pages/upload_pages/upload_task.dart';
import 'package:horopic/utils/event_bus_utils.dart';
import 'package:horopic/utils/uploader.dart';
import 'package:horopic/utils/global.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/album/album_sql.dart';

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

  Future<void> upload(String path, String fileName, canceltoken) async {
    try {
      var task = getUpload(fileName);

      if (task == null || task.status.value == UploadStatus.canceled) {
        return;
      }
      setStatus(task, UploadStatus.uploading);

      String configData = await readPictureHostConfig();
      Map configMap = jsonDecode(configData);
      String defaultPH = Global.getPShost();
      switch (defaultPH) {
        case 'tencent':
          List<String> tencentUploadResult = await TencentImageUploadUtils.uploadApi(
              path: path,
              name: fileName,
              configMap: configMap,
              onSendProgress: createCallback(path, fileName),
              cancelToken: canceltoken);

          if (tencentUploadResult[0] != 'success') {
            throw Exception('上传失败');
          }
          eventBus.fire(AlbumRefreshEvent(albumKeepAlive: false));
          Map<String, dynamic> maps = {};
          var [_, formatedURL, returnUrl, pictureKey, displayUrl] = tencentUploadResult;

          // Comment out automatic clipboard copy for individual uploads
          // This will be handled in batch instead
          // if (Global.isCopyLink) {
          //   await Clipboard.setData(ClipboardData(text: formatedURL));
          // }

          maps = {
            'path': path,
            'name': fileName,
            'url': returnUrl, //tencent文件原始地址
            'PBhost': Global.defaultPShost,
            'pictureKey': pictureKey,
            'hostSpecificArgA': displayUrl, //实际展示的是displayUrl
            'hostSpecificArgB': 'test',
            'hostSpecificArgC': 'test',
            'hostSpecificArgD': 'test',
            'hostSpecificArgE': 'test',
          };
          await AlbumSQL.insertData(Global.imageDB!, hostToTableNameMap[Global.defaultPShost]!, maps);
          // Store formattedUrl in task for later copying
          task.formattedUrl = formatedURL;
          setStatus(task, UploadStatus.completed);

        // Similar changes for other case blocks - remove individual clipboard operations
        case 'aliyun':
          var aliUploadResult = await AliyunImageUploadUtils.uploadApi(
              path: path,
              name: fileName,
              configMap: configMap,
              onSendProgress: createCallback(path, fileName),
              cancelToken: canceltoken);
          if (aliUploadResult[0] != 'success') {
            throw Exception('上传失败');
          }
          eventBus.fire(AlbumRefreshEvent(albumKeepAlive: false));
          var [_, formatedURL, returnUrl, pictureKey, displayUrl] = aliUploadResult;
          // if (Global.isCopyLink) {
          //   await Clipboard.setData(ClipboardData(text: formatedURL));
          // }

          Map<String, dynamic> maps = {
            'path': path,
            'name': fileName,
            'url': returnUrl, //aliyun文件原始地址
            'PBhost': Global.defaultPShost,
            'pictureKey': pictureKey,
            'hostSpecificArgA': displayUrl, //实际展示的是displayUrl
            'hostSpecificArgB': 'test',
            'hostSpecificArgC': 'test',
            'hostSpecificArgD': 'test',
            'hostSpecificArgE': 'test',
          };
          await AlbumSQL.insertData(Global.imageDB!, hostToTableNameMap[Global.defaultPShost]!, maps);
          task.formattedUrl = formatedURL;
          setStatus(task, UploadStatus.completed);

        // Continue with the same pattern for all other cases
        // Just commenting out the clipboard operations and ensuring task.formattedUrl is set

        case 'qiniu':
          var qiniuUploadResult = await QiniuImageUploadUtils.uploadApi(
              path: path,
              name: fileName,
              configMap: configMap,
              onSendProgress: createCallback(path, fileName),
              cancelToken: canceltoken);

          if (qiniuUploadResult[0] != 'success') {
            throw Exception('上传失败');
          }
          eventBus.fire(AlbumRefreshEvent(albumKeepAlive: false));
          var [_, formatedURL, returnUrl, pictureKey, displayUrl] = qiniuUploadResult;
          // if (Global.isCopyLink == true) {
          //   await Clipboard.setData(ClipboardData(text: formatedURL));
          // }

          Map<String, dynamic> maps = {
            'path': path,
            'name': fileName,
            'url': returnUrl, //qiniu文件原始地址
            'PBhost': Global.defaultPShost,
            'pictureKey': pictureKey,
            'hostSpecificArgA': displayUrl, //实际展示的是displayUrl
            'hostSpecificArgB': 'test',
            'hostSpecificArgC': 'test',
            'hostSpecificArgD': 'test',
            'hostSpecificArgE': 'test',
          };
          await AlbumSQL.insertData(Global.imageDB!, hostToTableNameMap[Global.defaultPShost]!, maps);
          task.formattedUrl = formatedURL;
          setStatus(task, UploadStatus.completed);
        case 'upyun':
          var upyunUploadResult = await UpyunImageUploadUtils.uploadApi(
              path: path,
              name: fileName,
              configMap: configMap,
              onSendProgress: createCallback(path, fileName),
              cancelToken: canceltoken);

          if (upyunUploadResult[0] != 'success') {
            throw Exception('上传失败');
          }
          eventBus.fire(AlbumRefreshEvent(albumKeepAlive: false));
          var [_, formatedURL, returnUrl, pictureKey, displayUrl] = upyunUploadResult;
          // if (Global.isCopyLink) {
          //   await Clipboard.setData(ClipboardData(text: formatedURL));
          // }
          Map<String, dynamic> maps = {
            'path': path,
            'name': fileName,
            'url': returnUrl, //upyun文件原始地址
            'PBhost': Global.defaultPShost,
            'pictureKey': pictureKey,
            'hostSpecificArgA': displayUrl, //实际展示的是displayUrl
            'hostSpecificArgB': 'test',
            'hostSpecificArgC': 'test',
            'hostSpecificArgD': 'test',
            'hostSpecificArgE': 'test',
          };
          await AlbumSQL.insertData(Global.imageDB!, hostToTableNameMap[Global.defaultPShost]!, maps);
          task.formattedUrl = formatedURL;
          setStatus(task, UploadStatus.completed);
        case 'lsky.pro':
          var lskyproUploadResult = await LskyproImageUploadUtils.uploadApi(
              path: path,
              name: fileName,
              configMap: configMap,
              onSendProgress: createCallback(path, fileName),
              cancelToken: canceltoken);

          if (lskyproUploadResult[0] != 'success') {
            throw Exception('上传失败');
          }
          eventBus.fire(AlbumRefreshEvent(albumKeepAlive: false));
          var [_, formatedURL, returnUrl, pictureKey, displayUrl] = lskyproUploadResult;
          // if (Global.isCopyLink) {
          //   await Clipboard.setData(ClipboardData(text: formatedURL));
          // }

          Map<String, dynamic> maps = {
            'path': path,
            'name': fileName,
            'url': returnUrl, //原图地址
            'PBhost': Global.defaultPShost,
            'pictureKey': pictureKey,
            'hostSpecificArgA': displayUrl, //实际展示的是缩略图
            'hostSpecificArgB': 'test',
            'hostSpecificArgC': 'test',
            'hostSpecificArgD': 'test',
            'hostSpecificArgE': 'test',
          };
          await AlbumSQL.insertData(Global.imageDB!, hostToTableNameMap[Global.defaultPShost]!, maps);
          task.formattedUrl = formatedURL;
          setStatus(task, UploadStatus.completed);
        case 'sm.ms':
          List<String> smmsUploadResult = await SmmsImageUploadUtils.uploadApi(
              path: path,
              name: fileName,
              configMap: configMap,
              onSendProgress: createCallback(path, fileName),
              cancelToken: canceltoken);

          if (smmsUploadResult[0] != 'success') {
            throw Exception('上传失败');
          }
          eventBus.fire(AlbumRefreshEvent(albumKeepAlive: false));
          var [_, formatedURL, returnUrl, pictureKey] = smmsUploadResult;
          // if (Global.isCopyLink) {
          //   await Clipboard.setData(ClipboardData(text: formatedURL));
          // }
          Map<String, dynamic> maps = {
            'path': path,
            'name': fileName,
            'url': returnUrl,
            'PBhost': Global.defaultPShost,
            'pictureKey': pictureKey,
            'hostSpecificArgA': 'test',
            'hostSpecificArgB': 'test',
            'hostSpecificArgC': 'test',
            'hostSpecificArgD': 'test',
            'hostSpecificArgE': 'test',
          };
          await AlbumSQL.insertData(Global.imageDB!, hostToTableNameMap[Global.defaultPShost]!, maps);
          task.formattedUrl = formatedURL;
          setStatus(task, UploadStatus.completed);
        case 'github':
          maxConcurrentTasks = 1;
          var githubUploadResult = await GithubImageUploadUtils.uploadApi(
            path: path,
            name: fileName,
            configMap: configMap,
            onSendProgress: createCallback(path, fileName),
          );
          if (githubUploadResult[0] != 'success') {
            throw Exception('上传失败');
          }
          eventBus.fire(AlbumRefreshEvent(albumKeepAlive: false));
          var [_, formatedURL, returnUrl, pictureKey, downloadUrl] = githubUploadResult;
          // if (Global.isCopyLink) {
          //   await Clipboard.setData(ClipboardData(text: formatedURL));
          // }
          Map<String, dynamic> maps = {
            'path': path,
            'name': fileName,
            'url': returnUrl,
            'PBhost': Global.defaultPShost,
            'pictureKey': pictureKey,
            'hostSpecificArgA': downloadUrl, //github download url或者自定义域名+路径
            'hostSpecificArgB': 'test',
            'hostSpecificArgC': 'test',
            'hostSpecificArgD': 'test',
            'hostSpecificArgE': 'test',
          };
          await AlbumSQL.insertData(Global.imageDB!, hostToTableNameMap[Global.defaultPShost]!, maps);
          task.formattedUrl = formatedURL;
          setStatus(task, UploadStatus.completed);
        case 'imgur':
          var imgurUploadResult = await ImgurImageUploadUtils.uploadApi(
              path: path,
              name: fileName,
              configMap: configMap,
              onSendProgress: createCallback(path, fileName),
              cancelToken: canceltoken);

          if (imgurUploadResult[0] != 'success') {
            throw Exception('上传失败');
          }
          eventBus.fire(AlbumRefreshEvent(albumKeepAlive: false));
          var [_, formatedURL, returnUrl, pictureKey, cdnUrl] = imgurUploadResult;
          // if (Global.isCopyLink == true) {
          //   await Clipboard.setData(ClipboardData(text: formatedURL));
          // }
          Map<String, dynamic> maps = {
            'path': path,
            'name': fileName,
            'url': returnUrl, //imgur文件原始地址
            'PBhost': Global.defaultPShost,
            'pictureKey': pictureKey,
            'hostSpecificArgA': cdnUrl, //实际展示的是imgur cdn url
            'hostSpecificArgB': 'test',
            'hostSpecificArgC': 'test',
            'hostSpecificArgD': 'test',
            'hostSpecificArgE': 'test',
          };
          await AlbumSQL.insertData(Global.imageDB!, hostToTableNameMap[Global.defaultPShost]!, maps);
          task.formattedUrl = formatedURL;
          setStatus(task, UploadStatus.completed);
        case 'ftp':
          var ftpUploadResult = await FTPImageUploadUtils.uploadApi(
            path: path,
            name: fileName,
            configMap: configMap,
          );
          if (ftpUploadResult[0] != 'success') {
            throw Exception('上传失败');
          }
          eventBus.fire(AlbumRefreshEvent(albumKeepAlive: false));
          var [
            _,
            formatedURL,
            returnUrl,
            pictureKey,
            displayUrl,
            ftpHost,
            ftpPort,
            ftpUser,
            ftpPassword,
            ftpType,
            isAnonymous,
            uploadPath,
            thumbnail
          ] = ftpUploadResult;
          // if (Global.isCopyLink) {
          //   await Clipboard.setData(ClipboardData(text: formatedURL));
          // }
          Map<String, dynamic> maps = {
            'path': path,
            'name': fileName,
            'url': returnUrl, //ftp文件原始地址
            'PBhost': Global.defaultPShost,
            'pictureKey': pictureKey,
            'hostSpecificArgA': displayUrl, //实际展示的是displayUrl
            'hostSpecificArgB': ftpHost, //ftp自定义域名
            'hostSpecificArgC': ftpPort, //ftp端口
            'hostSpecificArgD': ftpUser, //ftp用户名
            'hostSpecificArgE': ftpPassword, //ftp密码
            'hostSpecificArgF': ftpType, //ftp类型
            'hostSpecificArgG': isAnonymous, //ftp是否匿名
            'hostSpecificArgH': uploadPath, //ftp路径
            'hostSpecificArgI': thumbnail, //缩略图路径
          };
          List letter = 'JKLMNOPQRSTUVWXYZ'.split('');
          for (int i = 0; i < letter.length; i++) {
            maps['hostSpecificArg${letter[i]}'] = 'test';
          }
          await AlbumSQL.insertData(Global.imageDBExtend!, hostToTableNameMap[Global.defaultPShost]!, maps);
          task.formattedUrl = formatedURL;
          setStatus(task, UploadStatus.completed);
        case 'aws':
          var awsUploadResult = await AwsImageUploadUtils.uploadApi(
            path: path,
            name: fileName,
            configMap: configMap,
          );
          if (awsUploadResult[0] != 'success') {
            throw Exception('上传失败');
          }
          eventBus.fire(AlbumRefreshEvent(albumKeepAlive: false));
          var [_, formatedURL, returnUrl, pictureKey, displayUrl] = awsUploadResult;
          // if (Global.isCopyLink) {
          //   await Clipboard.setData(ClipboardData(text: formatedURL));
          // }
          Map<String, dynamic> maps = {
            'path': path,
            'name': fileName,
            'url': returnUrl,
            'PBhost': Global.defaultPShost,
            'pictureKey': pictureKey,
            'hostSpecificArgA': displayUrl,
          };
          List letter = 'BCDEFGHIJKLMNOPQRSTUVWXYZ'.split('');
          for (int i = 0; i < letter.length; i++) {
            maps['hostSpecificArg${letter[i]}'] = 'test';
          }
          await AlbumSQL.insertData(Global.imageDBExtend!, hostToTableNameMap[Global.defaultPShost]!, maps);
          task.formattedUrl = formatedURL;
          setStatus(task, UploadStatus.completed);
        case 'alist':
          var alistUploadResult = await AlistImageUploadUtils.uploadApi(
            path: path,
            name: fileName,
            configMap: configMap,
            onSendProgress: createCallback(path, fileName),
          );

          if (alistUploadResult[0] != 'success') {
            throw Exception('上传失败');
          }
          eventBus.fire(AlbumRefreshEvent(albumKeepAlive: false));
          var [_, formatedURL, returnUrl, pictureKey, displayUrl, hostPicUrl] = alistUploadResult;
          // if (Global.isCopyLink) {
          //   await Clipboard.setData(ClipboardData(text: formatedURL));
          // }
          Map<String, dynamic> maps = {
            'path': path,
            'name': fileName,
            'url': returnUrl,
            'PBhost': Global.defaultPShost,
            'pictureKey': pictureKey,
            'hostSpecificArgA': displayUrl,
            'hostSpecificArgB': hostPicUrl,
          };
          List letter = 'CDEFGHIJKLMNOPQRSTUVWXYZ'.split('');
          for (int i = 0; i < letter.length; i++) {
            maps['hostSpecificArg${letter[i]}'] = 'test';
          }
          await AlbumSQL.insertData(Global.imageDBExtend!, hostToTableNameMap[Global.defaultPShost]!, maps);
          task.formattedUrl = formatedURL;
          setStatus(task, UploadStatus.completed);
        case 'webdav':
          var webdavUploadResult =
              await WebdavImageUploadUtils.uploadApi(path: path, name: fileName, configMap: configMap);
          if (webdavUploadResult[0] != 'success') {
            throw Exception('上传失败');
          }
          var [_, formatedURL, returnUrl, pictureKey, displayUrl] = webdavUploadResult;
          eventBus.fire(AlbumRefreshEvent(albumKeepAlive: false));
          // if (Global.isCopyLink) {
          //   await Clipboard.setData(ClipboardData(text: formatedURL));
          // }
          Map<String, dynamic> maps = {
            'path': path,
            'name': fileName,
            'url': returnUrl,
            'PBhost': Global.defaultPShost,
            'pictureKey': pictureKey,
            'hostSpecificArgA': displayUrl,
          };
          List letter = 'BCDEFGHIJKLMNOPQRSTUVWXYZ'.split('');
          for (int i = 0; i < letter.length; i++) {
            maps['hostSpecificArg${letter[i]}'] = 'test';
          }
          await AlbumSQL.insertData(Global.imageDBExtend!, hostToTableNameMap[Global.defaultPShost]!, maps);
          task.formattedUrl = formatedURL;
          setStatus(task, UploadStatus.completed);
        default:
          break;
      }
    } catch (e) {
      FLog.error(
          className: 'UploadTask',
          methodName: 'start',
          text: formatErrorMessage({
            'path': path,
            'fileName': fileName,
          }, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
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
      upload(currentRequest.path, currentRequest.name, currentRequest.cancelToken);
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

  Future<UploadTask?> addUpload(String path, String fileName) async {
    if (path.isNotEmpty && fileName.isNotEmpty) {
      return await _addUploadRequest(UploadRequest(path, fileName));
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
    _queue.add(UploadRequest(uploadRequest.path, uploadRequest.name));
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

  Future<void> addBatchUploads(List<String> paths, List<String> names) async {
    for (var i = 0; i < paths.length; i++) {
      await addUpload(paths[i], names[i]);
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
    if (paths.isEmpty || names.isEmpty) {
      return [];
    }

    var completer = Completer<List<UploadTask?>?>();
    var completed = 0;
    var total = names.length;

    // Initial check for already completed tasks
    for (var i = 0; i < names.length; i++) {
      UploadTask? task = getUpload(names[i]);
      if (task == null) {
        total--;
        continue;
      }

      if (task.status.value.isCompleted) {
        completed++;
      } else {
        dynamic listener;
        listener = () {
          if (task.status.value.isCompleted) {
            completed++;
            task.status.removeListener(listener);

            if (completed >= total) {
              completer.complete(getBatchUploads(paths, names));
            }
          }
        };
        task.status.addListener(listener);
      }
    }

    // If all tasks are already completed or no tasks exist
    if (completed >= total || total == 0) {
      completer.complete(getBatchUploads(paths, names));
    }

    return completer.future.timeout(timeout);
  }

  // Add a method to retrieve the formatted URL for a file
  String? getUploadFormattedUrl(String fileName) {
    var task = getUpload(fileName);
    if (task != null && task.status.value == UploadStatus.completed) {
      return task.formattedUrl;
    }
    return null;
  }
}
