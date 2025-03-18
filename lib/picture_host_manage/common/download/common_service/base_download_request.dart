import 'package:dio/dio.dart';

class DownloadRequest {
  final String url;
  final String path;
  final String? fileName;
  final Map<String, dynamic>? configMap;
  var cancelToken = CancelToken();

  DownloadRequest(
    this.url,
    this.path, {
    this.fileName = '',
    this.configMap = const {},
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DownloadRequest &&
          runtimeType == other.runtimeType &&
          url == other.url &&
          path == other.path &&
          fileName == other.fileName &&
          configMap.toString() == other.configMap.toString();

  @override
  int get hashCode => url.hashCode ^ path.hashCode ^ fileName.hashCode ^ configMap.toString().hashCode;
}
