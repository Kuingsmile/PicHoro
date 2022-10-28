import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:horopic/pages/upload_pages/upload_request.dart';
import 'package:horopic/pages/upload_pages/upload_status.dart';

class UploadTask {
  final UploadRequest request;
  ValueNotifier<UploadStatus> status = ValueNotifier(UploadStatus.queued);
  ValueNotifier<double> progress = ValueNotifier(0);

  UploadTask(
    this.request,
  );

  Future<UploadStatus> whenUploadComplete(
      {Duration timeout = const Duration(hours: 2)}) async {
    var completer = Completer<UploadStatus>();

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
