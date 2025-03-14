import 'dart:io';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

import 'package:horopic/utils/global.dart';
import 'package:horopic/utils/common_functions.dart';

class SmmsManageAPI {
  static const String smmsAPIUrl = 'https://smms.app/api/v2/';

  static Future<File> get localFile async {
    String path = await _localPath;
    String defaultUser = Global.getUser();
    return ensureFileExists(File('$path/${defaultUser}_smms_config.txt'));
  }

  static Future<String> get _localPath async {
    Directory directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<String> readSmmsConfig() async {
    try {
      final file = await localFile;
      return await file.readAsString();
    } catch (e) {
      flogErr(e, {}, "SmmsManageAPI", "readSmmsConfig");
      return "Error";
    }
  }

  static Future<Map> getConfigMap() async {
    String configStr = await readSmmsConfig();
    if (configStr == '') {
      return {};
    }
    Map configMap = json.decode(configStr);
    return configMap;
  }

  static getUserProfile() async {
    try {
      Map configMap = await getConfigMap();
      String token = configMap['token'];

      BaseOptions baseoptions = setBaseOptions();
      baseoptions.headers = {
        'Authorization': token,
        'Content-Type': 'multipart/form-data',
      };
      Dio dio = Dio(baseoptions);
      FormData formData = FormData.fromMap({});

      var response = await dio.post('${smmsAPIUrl}profile', data: formData);
      if (response.statusCode == 200 && response.data['success'] == true) {
        Map userProfile = response.data['data'];
        return ['success', userProfile];
      } else {
        return ['failed'];
      }
    } catch (e) {
      flogErr(e, {}, "SmmsManageAPI", "getUserProfile");
      return [e.toString()];
    }
  }

  static getFileList({required int page}) async {
    try {
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

      var response = await dio.get('${smmsAPIUrl}upload_history', queryParameters: params);
      if (response.statusCode == 200 && response.data['success'] == true) {
        Map result = response.data;
        return ['success', result];
      } else {
        return ['failed'];
      }
    } catch (e) {
      flogErr(e, {'page': page}, "SmmsManageAPI", "getFileList");
      return [e.toString()];
    }
  }

  static uploadFile(String filename, String path) async {
    try {
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

      var response = await dio.post('${smmsAPIUrl}upload', data: formdata);
      if (response.statusCode == 200 && response.data!['success'] == true) {
        return ["success"];
      } else {
        return ["failed"];
      }
    } catch (e) {
      flogErr(e, {'filename': filename, 'path': path}, "SmmsManageAPI", "uploadFile");
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
        return showToast('配置错误');
      } else if (uploadResult[0] == "success") {
        successCount++;
      } else {
        failCount++;
      }
    }

    if (successCount == 0) {
      return showToast('上传失败');
    } else if (failCount == 0) {
      return showToast('上传成功');
    } else {
      return showToast('成功$successCount,失败$failCount');
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
      if (response.statusCode != 200) {
        return ['failed'];
      }

      var uploadResult = await uploadFile(
        filename,
        saveFilePath,
      );
      if (uploadResult[0] != "success") {
        return ['failed'];
      }
      return ['success'];
    } catch (e) {
      flogErr(e, {'fileLink': fileLink}, "SmmsManageAPI", "uploadNetworkFile");
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
      return showToast('上传失败');
    } else if (failCount == 0) {
      return showToast('上传成功');
    } else {
      return showToast('成功$successCount,失败$failCount');
    }
  }

  static deleteFile(String hash) async {
    try {
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

      var response = await dio.get(deleteUrl, queryParameters: formdata);
      if (response.statusCode == 200 && response.data!['success'] == true) {
        return ["success"];
      } else {
        return ["failed"];
      }
    } catch (e) {
      flogErr(e, {'hash': hash}, "SmmsManageAPI", "deleteFile");
      return [e.toString()];
    }
  }
}
