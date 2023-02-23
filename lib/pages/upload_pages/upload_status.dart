enum UploadStatus { queued, uploading, completed, failed, paused, canceled }

extension UploadStatueExtension on UploadStatus {
  bool get isCompleted {
    switch (this) {
      case UploadStatus.queued:
        return false;
      case UploadStatus.uploading:
        return false;
      case UploadStatus.paused:
        return false;
      case UploadStatus.completed:
        return true;
      case UploadStatus.failed:
        return true;
      case UploadStatus.canceled:
        return true;
    }
  }
}
