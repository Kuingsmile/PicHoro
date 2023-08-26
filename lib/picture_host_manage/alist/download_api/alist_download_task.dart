import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:f_logs/f_logs.dart';

import 'package:horopic/picture_host_manage/tencent/download_api/download_status.dart';
import 'package:horopic/picture_host_manage/alist/download_api/alist_download_request.dart';
import 'package:horopic/utils/common_functions.dart';

class DownloadTask {
  final DownloadRequest request;
  ValueNotifier<DownloadStatus> status = ValueNotifier(DownloadStatus.queued);
  ValueNotifier<double> progress = ValueNotifier(0);

  DownloadTask(
    this.request,
  );

  Future<DownloadStatus> whenDownloadComplete({Duration timeout = const Duration(hours: 2)}) async {
    var completer = Completer<DownloadStatus>();

    if (status.value.isCompleted) {
      completer.complete(status.value);
    }

    dynamic listener;
    listener = () {
      if (status.value.isCompleted) {
        try {
          completer.complete(status.value);
          status.removeListener(listener);
        } catch (e) {
          FLog.error(
              className: 'alistDownloadTask',
              methodName: 'whenDownloadComplete',
              text: formatErrorMessage({}, e.toString()),
              dataLogType: DataLogType.ERRORS.toString());
          status.removeListener(listener);
        }
      }
    };

    status.addListener(listener);

    return completer.future.timeout(timeout);
  }
}
