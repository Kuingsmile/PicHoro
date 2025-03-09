import 'dart:async';
import 'package:flutter/material.dart';
import 'package:horopic/pages/upload_pages/upload_request.dart';
import 'package:horopic/pages/upload_pages/upload_status.dart';

class UploadTask {
  final UploadRequest request;
  final ValueNotifier<UploadStatus> status = ValueNotifier(UploadStatus.queued);
  final ValueNotifier<double> progress = ValueNotifier(0.0);
  String formattedUrl = ''; // Store the formatted URL for clipboard

  UploadTask(this.request);

  Future<UploadStatus> whenUploadComplete({Duration timeout = const Duration(hours: 2)}) {
    var completer = Completer<UploadStatus>();

    if (status.value.isCompleted) {
      completer.complete(status.value);
    }

    void listener() {
      if (status.value.isCompleted) {
        completer.complete(status.value);
        status.removeListener(listener);
      }
    }

    status.addListener(listener);
    return completer.future.timeout(timeout);
  }

  String? getFormattedUrl() {
    return status.value == UploadStatus.completed ? formattedUrl : null;
  }
}
