import 'package:dio/dio.dart';
import 'package:horopic/picture_host_manage/common/base_manage_api.dart';
import 'package:path_provider/path_provider.dart';

import 'package:horopic/utils/common_functions.dart';

class SmmsManageAPI extends BaseManageApi {
  static final SmmsManageAPI _instance = SmmsManageAPI._internal();

  SmmsManageAPI._internal();

  factory SmmsManageAPI() {
    return _instance;
  }

  String smmsAPIUrl = 'https://smms.app/api/v2/';

  @override
  String configFileName() => 'smms_config.txt';

  List defaultOnSuccess(response) => ['success'];

  _makeRequest(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    required Function onSuccess,
    String method = 'POST',
    String callFunction = 'makeRequest',
  }) async {
    try {
      Map configMap = await getConfigMap();
      String token = configMap['token'];

      String url = '$smmsAPIUrl$endpoint';

      BaseOptions baseoptions = setBaseOptions();
      baseoptions.headers = {
        "Authorization": token,
        ...?headers,
      };
      Dio dio = Dio(baseoptions);

      Response response;
      if (method == 'GET') {
        response = await dio.get(url, queryParameters: queryParameters);
      } else if (method == 'POST') {
        response = await dio.post(url, data: data, queryParameters: queryParameters);
      } else {
        response = await dio.put(url, data: data, queryParameters: queryParameters);
      }

      if (response.statusCode == 200 && response.data['success'] == true) {
        return onSuccess(response);
      }
      flogErr(
        response,
        {
          'url': url,
          'data': data,
          'queryParameters': queryParameters,
          'headers': headers,
        },
        "SmmsManageAPI",
        callFunction,
      );
    } catch (e) {
      flogErr(e, {}, "SmmsManageAPI", callFunction);
    }
    return ['failed'];
  }

  getUserProfile() async {
    return await _makeRequest(
      'profile',
      headers: {
        'Content-Type': 'multipart/form-data',
      },
      data: FormData.fromMap({}),
      onSuccess: (response) {
        return ['success', response.data['data']];
      },
      callFunction: 'getUserProfile',
    );
  }

  Future<List> getFileList({required int page}) async {
    return await _makeRequest(
      'upload_history',
      queryParameters: {
        'page': page,
      },
      headers: {
        'Content-Type': 'multipart/form-data',
      },
      method: 'GET',
      onSuccess: (response) {
        return ['success', response.data];
      },
      callFunction: 'getFileList',
    );
  }

  Future<List<String>> uploadFile(String filename, String path) async {
    return await _makeRequest(
      'upload',
      data: FormData.fromMap({
        "smfile": await MultipartFile.fromFile(path, filename: filename),
        "format": "json",
      }),
      headers: {
        'Content-Type': 'multipart/form-data',
      },
      onSuccess: (response) {
        return ['success'];
      },
      callFunction: 'uploadFile',
    );
  }

  Future<List<String>> uploadNetworkFile(String fileLink) async {
    try {
      String filename = fileLink.substring(fileLink.lastIndexOf("/") + 1, fileLink.length);
      filename = filename.substring(0, !filename.contains("?") ? filename.length : filename.indexOf("?"));
      String savePath = await getTemporaryDirectory().then((value) {
        return value.path;
      });
      String saveFilePath = '$savePath/$filename';
      Dio dio = Dio();
      Response response = await dio.download(fileLink, saveFilePath);
      if (response.statusCode != 200) {
        return ['failed'];
      }

      var uploadResult = await uploadFile(
        filename,
        saveFilePath,
      );
      if (uploadResult[0] == "success") {
        return ['success'];
      }
    } catch (e) {
      flogErr(e, {'fileLink': fileLink}, "SmmsManageAPI", "uploadNetworkFile");
    }
    return ['failed'];
  }

  uploadNetworkFileEntry(
    List fileList,
  ) async {
    int successCount = 0;
    int failCount = 0;
    for (String fileLink in fileList) {
      if (fileLink.isEmpty) {
        continue;
      }
      var uploadResult = await uploadNetworkFile(fileLink);
      if (uploadResult[0] == "success") {
        successCount++;
      } else {
        failCount++;
      }
    }

    if (successCount == 0) {
      return showToast('上传失败');
    } else if (failCount == 0) {
      return showToast('上传成功');
    }
    return showToast('成功$successCount,失败$failCount');
  }

  Future<List<String>> deleteFile(String hash) async {
    return await _makeRequest(
      'delete/$hash',
      queryParameters: {
        "hash": hash,
        "format": "json",
      },
      method: 'GET',
      onSuccess: (response) {
        return ['success'];
      },
      callFunction: 'deleteFile',
    );
  }
}
