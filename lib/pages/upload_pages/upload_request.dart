import 'package:dio/dio.dart';

class UploadRequest{
  final String path;
  var cancelToken = CancelToken();

  UploadRequest(
    this.path,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UploadRequest &&
          runtimeType == other.runtimeType &&
          path == other.path;
  
  @override
  int get hashCode => path.hashCode;
}