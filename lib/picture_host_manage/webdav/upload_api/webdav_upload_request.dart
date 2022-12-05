import 'package:dio/dio.dart';

class UploadRequest {
  final String path;
  final String name;
  final Map<String, dynamic> configMap;
  var cancelToken = CancelToken();

  UploadRequest(
    this.path,
    this.name,
    this.configMap,
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    if (other is UploadRequest) {
      return other.runtimeType == runtimeType &&
          other.path == path &&
          other.name == name &&
          other.configMap.toString() == configMap.toString();
    } else {
      return false;
    }
  }

  @override
  int get hashCode =>
      path.hashCode ^ name.hashCode ^ configMap.toString().hashCode;
}
