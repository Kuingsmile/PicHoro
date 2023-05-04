import 'dart:io';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:f_logs/f_logs.dart';
import 'package:path_provider/path_provider.dart';

import 'package:horopic/utils/global.dart';
import 'package:horopic/utils/common_functions.dart';

class SmmsManageAPI {
  static const String smmsAPIUrl = 'https://smms.app/api/v2/';

  static Future<File> get _localFile async {
    final path = await _localPath;
    String defaultUser = await Global.getUser();
    return File('$path/${defaultUser}_smms_config.txt');
  }

  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<String> readSmmsConfig() async {
    try {
      final file = await _localFile;
      String contents = await file.readAsString();
      return contents;
    } catch (e) {
      FLog.error(
          className: 'SmmsManageAPI',
          methodName: 'readSmmsConfig',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      return "Error";
    }
  }

  static Future<Map> getConfigMap() async {
    String configStr = await readSmmsConfig();
    Map configMap = json.decode(configStr);
    return configMap;
  }

  static getUserProfile() async {
    Map configMap = await getConfigMap();
    String token = configMap['token'];

    BaseOptions baseoptions = setBaseOptions();
    baseoptions.headers = {
      'Authorization': token,
      'Content-Type': 'multipart/form-data',
    };
    Dio dio = Dio(baseoptions);
    FormData formData = FormData.fromMap({});

    try {
      var response = await dio.post('${smmsAPIUrl}profile', data: formData);
      if (response.statusCode == 200 && response.data['success'] == true) {
        Map userProfile = response.data['data'];
        return ['success', userProfile];
      } else {
        return ['failed'];
      }
    } catch (e) {
      if (e is DioError) {
        FLog.error(
            className: "SmmsManageAPI",
            methodName: "getUserProfile",
            text: formatErrorMessage({}, e.toString(), isDioError: true, dioErrorMessage: e),
            dataLogType: DataLogType.ERRORS.toString());
      } else {
        FLog.error(
            className: "SmmsManageAPI",
            methodName: "getUserProfile",
            text: formatErrorMessage({}, e.toString()),
            dataLogType: DataLogType.ERRORS.toString());
      }
      return [e.toString()];
    }
  }

  static getFileList({required int page}) async {
    Map configMap = await getConfigMap();
    String token = configMap['token'];

    BaseOptions baseoptions = setBaseOptions();
    baseoptions.headers = {
      'Authorization': token,
      'Content-Type': 'multipart/form-data',
    };
    Dio dio = Dio(baseoptions);
    Map<String, dynamic> params = {
      'page': page,
    };

    try {
      var response = await dio.get('${smmsAPIUrl}upload_history', queryParameters: params);
      if (response.statusCode == 200 && response.data['success'] == true) {
        Map result = response.data;
        return ['success', result];
      } else {
        return ['failed'];
      }
    } catch (e) {
      if (e is DioError) {
        FLog.error(
            className: "SmmsManageAPI",
            methodName: "getFileList",
            text: formatErrorMessage({'page': page}, e.toString(), isDioError: true, dioErrorMessage: e),
            dataLogType: DataLogType.ERRORS.toString());
      } else {
        FLog.error(
            className: "SmmsManageAPI",
            methodName: "getFileList",
            text: formatErrorMessage({'page': page}, e.toString()),
            dataLogType: DataLogType.ERRORS.toString());
      }
      return [e.toString()];
    }
  }

  static uploadFile(String filename, String path) async {
    Map configMap = await getConfigMap();
    FormData formdata = FormData.fromMap({
      "smfile": await MultipartFile.fromFile(path, filename: filename),
      "format": "json",
    });
    BaseOptions options = setBaseOptions();
    options.headers = {
      "Authorization": configMap["token"],
      "Content-Type": "multipart/form-data",
    };
    Dio dio = Dio(options);
    try {
      var response = await dio.post('${smmsAPIUrl}upload', data: formdata);
      if (response.statusCode == 200 && response.data!['success'] == true) {
        return [
          "success",
        ];
      } else {
        return ["failed"];
      }
    } catch (e) {
      if (e is DioError) {
        FLog.error(
            className: "SmmsManageAPI",
            methodName: "uploadFile",
            text: formatErrorMessage({'filename': filename, 'path': path}, e.toString(),
                isDioError: true, dioErrorMessage: e),
            dataLogType: DataLogType.ERRORS.toString());
      } else {
        FLog.error(
            className: "SmmsManageAPI",
            methodName: "uploadFile",
            text: formatErrorMessage({'filename': filename, 'path': path}, e.toString()),
            dataLogType: DataLogType.ERRORS.toString());
      }
      return ['error'];
    }
  }

  static upLoadFileEntry(
    List fileList,
  ) async {
    int successCount = 0;
    int failCount = 0;

    for (File fileToTread in fileList) {
      String path = fileToTread.path;
      var filename = path.substring(path.lastIndexOf("/") + 1, path.length);

      var uploadResult = await uploadFile(
        filename,
        path,
      );
      if (uploadResult[0] == "Error") {
        return Fluttertoast.showToast(
            msg: '配置错误', toastLength: Toast.LENGTH_SHORT, timeInSecForIosWeb: 2, fontSize: 16.0);
      } else if (uploadResult[0] == "success") {
        successCount++;
      } else {
        failCount++;
      }
    }

    if (successCount == 0) {
      return Fluttertoast.showToast(
          msg: '上传失败', toastLength: Toast.LENGTH_SHORT, timeInSecForIosWeb: 2, fontSize: 16.0);
    } else if (failCount == 0) {
      return Fluttertoast.showToast(
          msg: '上传成功', toastLength: Toast.LENGTH_SHORT, timeInSecForIosWeb: 2, fontSize: 16.0);
    } else {
      return Fluttertoast.showToast(
          msg: '成功$successCount,失败$failCount', toastLength: Toast.LENGTH_SHORT, timeInSecForIosWeb: 2, fontSize: 16.0);
    }
  }

  static uploadNetworkFile(String fileLink) async {
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
            className: "SmmsManageAPI",
            methodName: "uploadNetworkFile",
            text: formatErrorMessage({'fileLink': fileLink}, e.toString(), isDioError: true, dioErrorMessage: e),
            dataLogType: DataLogType.ERRORS.toString());
      } else {
        FLog.error(
            className: "SmmsManageAPI",
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
          msg: '上传失败', toastLength: Toast.LENGTH_SHORT, timeInSecForIosWeb: 2, fontSize: 16.0);
    } else if (failCount == 0) {
      return Fluttertoast.showToast(
          msg: '上传成功', toastLength: Toast.LENGTH_SHORT, timeInSecForIosWeb: 2, fontSize: 16.0);
    } else {
      return Fluttertoast.showToast(
          msg: '成功$successCount,失败$failCount', toastLength: Toast.LENGTH_SHORT, timeInSecForIosWeb: 2, fontSize: 16.0);
    }
  }

  static deleteFile(String hash) async {
    Map configMap = await getConfigMap();
    Map<String, dynamic> formdata = {
      "hash": hash,
      "format": "json",
    };

    BaseOptions options = setBaseOptions();
    options.headers = {
      "Authorization": configMap["token"],
    };
    Dio dio = Dio(options);
    String deleteUrl = "${smmsAPIUrl}delete/$hash";

    try {
      var response = await dio.get(deleteUrl, queryParameters: formdata);
      if (response.statusCode == 200 && response.data!['success'] == true) {
        return ["success"];
      } else {
        return ["failed"];
      }
    } catch (e) {
      if (e is DioError) {
        FLog.error(
            className: "SmmsManageAPI",
            methodName: "deleteFile",
            text: formatErrorMessage({'hash': hash}, e.toString(), isDioError: true, dioErrorMessage: e),
            dataLogType: DataLogType.ERRORS.toString());
      } else {
        FLog.error(
            className: "SmmsManageAPI",
            methodName: "deleteFile",
            text: formatErrorMessage({'hash': hash}, e.toString()),
            dataLogType: DataLogType.ERRORS.toString());
      }
      return [e.toString()];
    }
  }
}
