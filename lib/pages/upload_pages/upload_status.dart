enum UploadStatus { queued, uploading, completed, failed, paused, canceled }

extension UploadStatusExtension on UploadStatus {
  bool get isCompleted {
    switch (this) {
      case UploadStatus.completed:
      case UploadStatus.failed:
      case UploadStatus.canceled:
        return true;
      case UploadStatus.queued:
      case UploadStatus.uploading:
      case UploadStatus.paused:
        return false;
    }
  }
}
