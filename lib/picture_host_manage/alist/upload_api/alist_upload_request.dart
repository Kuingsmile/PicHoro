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
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UploadRequest &&
          runtimeType == other.runtimeType &&
          path == other.path &&
          name == other.name &&
          configMap.toString() == other.configMap.toString();

  @override
  int get hashCode => path.hashCode ^ name.hashCode ^ configMap.toString().hashCode;
}
