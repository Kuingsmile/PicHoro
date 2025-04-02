import 'package:dio/dio.dart';
import 'package:horopic/picture_host_manage/common/base_manage_api.dart';
import 'package:path_provider/path_provider.dart';

import 'package:horopic/utils/common_functions.dart';

class LskyproManageAPI extends BaseManageApi {
  static final LskyproManageAPI _instance = LskyproManageAPI._internal();

  LskyproManageAPI._internal();

  factory LskyproManageAPI() {
    return _instance;
  }

  @override
  String configFileName() => 'host_config.txt';

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
      String token = configMap["token"];
      String host = configMap["host"];

      String url = '$host$endpoint';

      BaseOptions baseoptions = setBaseOptions();
      baseoptions.headers = {
        "Authorization": token,
        "Accept": "application/json",
        ...?headers,
      };
      Dio dio = Dio(baseoptions);

      Response response;
      if (method == 'GET') {
        response = await dio.get(url, queryParameters: queryParameters);
      } else if (method == 'POST') {
        response = await dio.post(url, data: data, queryParameters: queryParameters);
      } else if (method == 'DELETE') {
        response = await dio.delete(url, data: data, queryParameters: queryParameters);
      } else {
        response = await dio.put(url, data: data, queryParameters: queryParameters);
      }

      if (response.statusCode == 200 && response.data?['status'] == true) {
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
        "LskyproManageAPI",
        callFunction,
      );
      return ['failed'];
    } catch (e) {
      flogErr(
          e,
          {
            'endpoint': endpoint,
            'data': data,
            'queryParameters': queryParameters,
            'headers': headers,
          },
          "LskyproManageAPI",
          callFunction);
      return [e.toString()];
    }
  }

  getUserInfo() async {
    return await _makeRequest(
      '/api/v1/profile',
      onSuccess: (response) {
        return ['success', response.data];
      },
      method: 'GET',
      callFunction: 'getUserInfo',
    );
  }

  getAlbums() async {
    try {
      Map configMap = await getConfigMap();
      String token = configMap["token"];
      String host = configMap["host"];
      BaseOptions options = setBaseOptions();
      options.headers = {
        "Authorization": token,
        "Accept": "application/json",
      };
      Dio dio = Dio(options);
      String userInfoUrl = "$host/api/v1/albums";

      int page = 1;
      int lastPage = 1;
      List albums = [];
      var response = await dio.get(userInfoUrl);
      if (response.statusCode == 200 && response.data['status'] == true) {
        lastPage = response.data['data']['last_page'];
        if (response.data['data']['data'].isEmpty) {
          return ['success', []];
        }
        albums.addAll(response.data['data']['data']);
        for (page = 2; page <= lastPage; page++) {
          response = await dio.get(userInfoUrl, queryParameters: {"page": page});
          if (response.statusCode == 200 && response.data['status'] == true) {
            albums.addAll(response.data['data']['data']);
          } else {
            flogErr(
              response,
              {
                'url': userInfoUrl,
                'headers': options.headers,
              },
              'LskyproManageAPI',
              'getAlbums',
            );
            return [response.toString()];
          }
        }
        return ['success', albums];
      }
      flogErr(
        response,
        {
          'url': userInfoUrl,
          'headers': options.headers,
        },
        'LskyproManageAPI',
        'getAlbums',
      );
      return [response.toString()];
    } catch (e) {
      flogErr(e, {}, 'LskyproManageAPI', 'getAlbums');
      return [e.toString()];
    }
  }

  getPhoto(int? albumId) async {
    try {
      Map configMap = await getConfigMap();
      String token = configMap["token"];
      String host = configMap["host"];
      BaseOptions options = setBaseOptions();
      options.headers = {
        "Authorization": token,
        "Accept": "application/json",
      };
      Dio dio = Dio(options);
      String userInfoUrl = "$host/api/v1/images";

      int page = 1;
      int lastPage = 1;
      List images = [];
      var response = await dio.get(userInfoUrl, queryParameters: albumId == null ? {} : {"album_id": albumId});
      if (response.statusCode == 200 && response.data!['status'] == true) {
        lastPage = response.data!['data']['last_page'];
        if (response.data!['data']['data'].isEmpty) {
          return ['success', []];
        }
        images.addAll(response.data!['data']['data']);
        for (page = 2; page <= lastPage; page++) {
          response = await dio.get(userInfoUrl,
              queryParameters: albumId == null ? {"page": page} : {"album_id": albumId, "page": page});
          if (response.statusCode == 200 && response.data!['status'] == true) {
            images.addAll(response.data!['data']['data']);
          } else {
            flogErr(
              response,
              {
                'url': userInfoUrl,
                'headers': options.headers,
              },
              'LskyproManageAPI',
              'getPhoto',
            );
            return [response.toString()];
          }
        }
        return ['success', images];
      }
      flogErr(
        response,
        {
          'url': userInfoUrl,
          'headers': options.headers,
        },
        'LskyproManageAPI',
        'getPhoto',
      );
      return [response.toString()];
    } catch (e) {
      flogErr(
          e,
          {
            'albumId': albumId,
          },
          'LskyproManageAPI',
          'getPhoto');
      return [e.toString()];
    }
  }

  deleteFile(String deleteKey) async {
    return await _makeRequest(
      '/api/v1/images/$deleteKey',
      data: {
        "key": deleteKey,
      },
      onSuccess: (response) => ['success'],
      method: 'DELETE',
      callFunction: 'deleteFile',
    );
  }

  deleteAlbum(String id) async {
    return await _makeRequest(
      '/api/v1/albums/$id',
      data: {
        "id": id,
      },
      onSuccess: (response) => ['success'],
      method: 'DELETE',
      callFunction: 'deleteAlbum',
    );
  }

  uploadFile(String filename, String path, dynamic albumId) async {
    Map configMap = await getConfigMap();
    FormData formdata = FormData.fromMap({
      "file": await MultipartFile.fromFile(path, filename: filename),
      if (configMap["strategy_id"] != "None") "strategy_id": configMap["strategy_id"],
      if (albumId != "None") "album_id": albumId.toString(),
    });
    return await _makeRequest(
      '/api/v1/upload',
      data: formdata,
      headers: {
        'Content-Type': 'multipart/form-data',
      },
      onSuccess: (response) => ['success'],
      callFunction: 'uploadFile',
    );
  }

  uploadNetworkFile(String fileLink, dynamic albumId) async {
    try {
      String filename = fileLink.substring(fileLink.lastIndexOf("/") + 1, fileLink.length);
      filename = filename.substring(0, !filename.contains("?") ? filename.length : filename.indexOf("?"));
      String savePath = await getTemporaryDirectory().then((value) {
        return value.path;
      });
      String saveFilePath = '$savePath/$filename';
      Dio dio = Dio();
      Response response = await dio.download(fileLink, saveFilePath);
      if (response.statusCode == 200) {
        var uploadResult = await uploadFile(filename, saveFilePath, albumId);
        if (uploadResult[0] == "success") {
          return ['success'];
        }
        return ['failed'];
      }
      return ['failed'];
    } catch (e) {
      flogErr(
          e,
          {
            'fileLink': fileLink,
          },
          'LskyproManageAPI',
          'uploadNetworkFile');
      return ['failed'];
    }
  }

  uploadNetworkFileEntry(
    List fileList,
    dynamic albumId,
  ) async {
    int successCount = 0;
    int failCount = 0;
    for (String fileLink in fileList) {
      if (fileLink.isEmpty) {
        continue;
      }
      var uploadResult = await uploadNetworkFile(fileLink, albumId);
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
}
