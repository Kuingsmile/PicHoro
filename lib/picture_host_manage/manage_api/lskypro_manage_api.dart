import 'dart:io';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:f_logs/f_logs.dart';
import 'package:path_provider/path_provider.dart';

import 'package:horopic/utils/global.dart';
import 'package:horopic/utils/common_functions.dart';

class LskyproManageAPI {
  static Future<File> get _localFile async {
    final path = await _localPath;
    String defaultUser = await Global.getUser();
    return File('$path/${defaultUser}_host_config.txt');
  }

  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<String> readLskyproConfig() async {
    try {
      final file = await _localFile;
      String contents = await file.readAsString();
      return contents;
    } catch (e) {
      FLog.error(
          className: 'LskyproManageAPI',
          methodName: 'readLskyproConfig',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      return "Error";
    }
  }

  static Future<Map> getConfigMap() async {
    String configStr = await readLskyproConfig();
    Map configMap = json.decode(configStr);
    return configMap;
  }

  static isString(var variable) {
    return variable is String;
  }

  static isFile(var variable) {
    return variable is File;
  }

  static getUserInfo() async {
    Map configMap = await getConfigMap();
    String token = configMap["token"];
    String host = configMap["host"];
    BaseOptions options = setBaseOptions();
    options.headers = {
      "Authorization": token,
      "Accept": "application/json",
    };
    Dio dio = Dio(options);
    String userInfoUrl = "$host/api/v1/profile";
    try {
      var response = await dio.get(userInfoUrl);
      if (response.statusCode == 200 && response.data!['status'] == true) {
        return ['success', response.data];
      } else {
        return ['failed'];
      }
    } catch (e) {
      if (e is DioError) {
        FLog.error(
            className: "LskyproManageAPI",
            methodName: "getUserInfo",
            text: formatErrorMessage({}, e.toString(),
                isDioError: true, dioErrorMessage: e),
            dataLogType: DataLogType.ERRORS.toString());
      } else {
        FLog.error(
            className: "LskyproManageAPI",
            methodName: "getUserInfo",
            text: formatErrorMessage({}, e.toString(), isDioError: false),
            dataLogType: DataLogType.ERRORS.toString());
      }
      return [e.toString()];
    }
  }

  static getAlbums() async {
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
    try {
      int page = 1;
      int lastPage = 1;
      List albums = [];
      var response = await dio.get(userInfoUrl);
      if (response.statusCode == 200 && response.data!['status'] == true) {
        lastPage = response.data!['data']['last_page'];
        if (response.data!['data']['data'].isEmpty) {
          return ['success', []];
        }
        albums.addAll(response.data!['data']['data']);
        for (page = 2; page <= lastPage; page++) {
          response =
              await dio.get(userInfoUrl, queryParameters: {"page": page});
          if (response.statusCode == 200 && response.data!['status'] == true) {
            albums.addAll(response.data!['data']['data']);
          } else {
            return ['failed'];
          }
        }
        return ['success', albums];
      } else {
        return ['failed'];
      }
    } catch (e) {
      if (e is DioError) {
        FLog.error(
            className: "LskyproManageAPI",
            methodName: "getAlbums",
            text: formatErrorMessage({}, e.toString(),
                isDioError: true, dioErrorMessage: e),
            dataLogType: DataLogType.ERRORS.toString());
      } else {
        FLog.error(
            className: "LskyproManageAPI",
            methodName: "getAlbums",
            text: formatErrorMessage({}, e.toString(), isDioError: false),
            dataLogType: DataLogType.ERRORS.toString());
      }
      return [e.toString()];
    }
  }

  static getPhoto(int? albumId) async {
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

    try {
      int page = 1;
      int lastPage = 1;
      List images = [];
      var response = await dio.get(userInfoUrl,
          queryParameters: albumId == null ? {} : {"album_id": albumId});
      if (response.statusCode == 200 && response.data!['status'] == true) {
        lastPage = response.data!['data']['last_page'];
        if (response.data!['data']['data'].isEmpty) {
          return ['success', []];
        }
        images.addAll(response.data!['data']['data']);
        for (page = 2; page <= lastPage; page++) {
          response = await dio.get(userInfoUrl,
              queryParameters: albumId == null
                  ? {"page": page}
                  : {"album_id": albumId, "page": page});
          if (response.statusCode == 200 && response.data!['status'] == true) {
            images.addAll(response.data!['data']['data']);
          } else {
            return ['failed'];
          }
        }
        return ['success', images];
      } else {
        return ['failed'];
      }
    } catch (e) {
      if (e is DioError) {
        FLog.error(
            className: "LskyproManageAPI",
            methodName: "getPhoto",
            text: formatErrorMessage({}, e.toString(),
                isDioError: true, dioErrorMessage: e),
            dataLogType: DataLogType.ERRORS.toString());
      } else {
        FLog.error(
            className: "LskyproManageAPI",
            methodName: "getPhoto",
            text: formatErrorMessage({}, e.toString(), isDioError: false),
            dataLogType: DataLogType.ERRORS.toString());
      }
      return [e.toString()];
    }
  }

  //删除图片

  static deleteFile(String deleteKey) async {
    Map configMap = await getConfigMap();
    String token = configMap["token"];
    String host = configMap["host"];
    Map<String, dynamic> formdata = {
      "key": deleteKey,
    };
    BaseOptions options = setBaseOptions();
    options.headers = {
      "Authorization": token,
      "Accept": "application/json",
    };
    Dio dio = Dio(options);
    String deleteUrl = "$host/api/v1/images/$deleteKey";
    try {
      var response = await dio.delete(deleteUrl, data: formdata);
      if (response.statusCode == 200 && response.data!['status'] == true) {
        return ['success'];
      } else {
        return ['failed'];
      }
    } catch (e) {
      if (e is DioError) {
        FLog.error(
            className: "LskyproManageAPI",
            methodName: "deleteFile",
            text: formatErrorMessage({}, e.toString(),
                isDioError: true, dioErrorMessage: e),
            dataLogType: DataLogType.ERRORS.toString());
      } else {
        FLog.error(
            className: "LskyproManageAPI",
            methodName: "deleteFile",
            text: formatErrorMessage({}, e.toString(), isDioError: false),
            dataLogType: DataLogType.ERRORS.toString());
      }
      return [e.toString()];
    }
  }

  //删除相册
  static deleteAlbum(String id) async {
    Map configMap = await getConfigMap();
    String token = configMap["token"];
    String host = configMap["host"];
    Map<String, dynamic> formdata = {
      "id": id,
    };
    BaseOptions options = setBaseOptions();
    options.headers = {
      "Authorization": token,
      "Accept": "application/json",
    };
    Dio dio = Dio(options);
    String deleteUrl = "$host/api/v1/albums/$id";
    try {
      var response = await dio.delete(deleteUrl, data: formdata);
      if (response.statusCode == 200 && response.data!['status'] == true) {
        return ['success'];
      } else {
        return ['failed'];
      }
    } catch (e) {
      if (e is DioError) {
        FLog.error(
            className: "LskyproManageAPI",
            methodName: "deleteAlbum",
            text: formatErrorMessage({}, e.toString(),
                isDioError: true, dioErrorMessage: e),
            dataLogType: DataLogType.ERRORS.toString());
      } else {
        FLog.error(
            className: "LskyproManageAPI",
            methodName: "deleteAlbum",
            text: formatErrorMessage({}, e.toString(), isDioError: false),
            dataLogType: DataLogType.ERRORS.toString());
      }
      return [e.toString()];
    }
  }

  static uploadFile(String filename, String path) async {
    Map configMap = await getConfigMap();
    String token = configMap["token"];
    String host = configMap["host"];
    FormData formdata = FormData.fromMap({
      "file": await MultipartFile.fromFile(path, filename: filename),
    });
    if (configMap["strategy_id"] == "None") {
      formdata = FormData.fromMap({});
    } else {
      formdata = FormData.fromMap({
        "file": await MultipartFile.fromFile(path, filename: filename),
        "strategy_id": configMap["strategy_id"],
      });
    }
    BaseOptions options = setBaseOptions();
    options.headers = {
      "Authorization": token,
      "Accept": "application/json",
      "Content-Type": "multipart/form-data",
    };
    Dio dio = Dio(options);
    String uploadUrl = "$host/api/v1/upload";
    try {
      var response = await dio.post(uploadUrl, data: formdata);
      if (response.statusCode == 200 && response.data!['status'] == true) {
        return ['success'];
      } else {
        return ['failed'];
      }
    } catch (e) {
      if (e is DioError) {
        FLog.error(
            className: "LskyproManageAPI",
            methodName: "uploadFile",
            text: formatErrorMessage({}, e.toString(),
                isDioError: true, dioErrorMessage: e),
            dataLogType: DataLogType.ERRORS.toString());
      } else {
        FLog.error(
            className: "LskyproManageAPI",
            methodName: "uploadFile",
            text: formatErrorMessage({}, e.toString(), isDioError: false),
            dataLogType: DataLogType.ERRORS.toString());
      }
      return [e.toString()];
    }
  }

  
  static uploadNetworkFile(String fileLink) async {
    try {
      String filename =
          fileLink.substring(fileLink.lastIndexOf("/") + 1, fileLink.length);
      filename = filename.substring(
          0, !filename.contains("?") ? filename.length : filename.indexOf("?"));
      String savePath = await getTemporaryDirectory().then((value) {
        return value.path;
      });
      String saveFilePath = '$savePath/$filename';
      Dio dio = Dio();
      Response response = await dio.download(fileLink, saveFilePath);
      if (response.statusCode == 200) {
        var uploadResult = await uploadFile(
          filename,
          saveFilePath,
        );
        if (uploadResult[0] == "success") {
          return ['success'];
        } else {
          return ['failed'];
        }
      } else {
        return ['failed'];
      }
    } catch (e) {
      if (e is DioError) {
        FLog.error(
            className: "LskyproManageAPI",
            methodName: "uploadNetworkFile",
            text: formatErrorMessage({'fileLink': fileLink}, e.toString(),
                isDioError: true, dioErrorMessage: e),
            dataLogType: DataLogType.ERRORS.toString());
      } else {
        FLog.error(
            className: "LskyproManageAPI",
            methodName: "uploadNetworkFile",
            text: formatErrorMessage({'fileLink': fileLink}, e.toString()),
            dataLogType: DataLogType.ERRORS.toString());
      }
      return ['failed'];
    }
  }

  static uploadNetworkFileEntry(
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
      return Fluttertoast.showToast(
          msg: '上传失败',
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 2,
          fontSize: 16.0);
    } else if (failCount == 0) {
      return Fluttertoast.showToast(
          msg: '上传成功',
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 2,
          fontSize: 16.0);
    } else {
      return Fluttertoast.showToast(
          msg: '成功$successCount,失败$failCount',
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 2,
          fontSize: 16.0);
    }
  }
}
