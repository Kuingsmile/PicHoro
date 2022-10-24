import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:horopic/PShostFileManage/tencent/downloadAPI/downloader.dart';
import 'package:horopic/PShostFileManage/tencent/downloadAPI/download_status.dart';
import 'package:horopic/PShostFileManage/tencent/downloadAPI/download_request.dart';
class DownloadTask {
  final DownloadRequest request;
  ValueNotifier<DownloadStatus> status = ValueNotifier(DownloadStatus.queued);
  ValueNotifier<double> progress = ValueNotifier(0);

  DownloadTask(
    this.request,
  );

  Future<DownloadStatus> whenDownloadComplete(
      {Duration timeout = const Duration(hours: 2)}) async {
    var completer = Completer<DownloadStatus>();

    if (status.value.isCompleted) {
      completer.complete(status.value);
    }

    var listener;
    listener = () {
      if (status.value.isCompleted) {
        try{
        completer.complete(status.value);
        status.removeListener(listener);
        } catch(e){
          status.removeListener(listener);
        }
      }
    };

    status.addListener(listener);

    return completer.future.timeout(timeout);
  }
}
