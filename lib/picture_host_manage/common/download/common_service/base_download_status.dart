enum DownloadStatus { queued, downloading, completed, failed, paused, canceled, uninitialized }

extension DownloadStatusExtension on DownloadStatus {
  bool get isCompleted =>
      this == DownloadStatus.completed || this == DownloadStatus.failed || this == DownloadStatus.canceled;
}
