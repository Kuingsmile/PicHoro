import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';

import 'package:horopic/picture_host_manage/manage_api/alist_manage_api.dart';
import 'package:horopic/picture_host_configure/configure_page/alist_configure.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/utils/global.dart';

class AlistImageUploadUtils {
  static refreshToken({required Map configMap}) async {
    String today = getToday('yyyyMMdd');
    String alistToday = Global.getTodayAlistUpdate();
    if (alistToday != today && configMap['token'] != '') {
      var res = await AlistManageAPI.getToken(configMap['host'], configMap['alistusername'], configMap['password']);
      if (res[0] != 'success') {
        return ['failed'];
      }
      configMap['token'] = res[1];
      final alistConfig = AlistConfigModel(
        configMap['host'],
        'None',
        configMap['alistusername'],
        configMap['password'],
        configMap['token'],
        configMap['uploadPath'],
        configMap['webPath'] ?? 'None',
        configMap['customUrl'] ?? 'None',
      );
      final alistConfigJson = jsonEncode(alistConfig);
      final alistConfigFile = await AlistManageAPI.localFile;
      alistConfigFile.writeAsString(alistConfigJson);
      Global.setTodayAlistUpdate(today);
    }
  }

  //上传接口
  static uploadApi({
    required String path,
    required String name,
    required Map configMap,
    Function(int, int)? onSendProgress,
  }) async {
    try {
      FormData formdata = FormData.fromMap({
        "file": await MultipartFile.fromFile(path, filename: name),
      });
      String host = configMap['host'];
      String uploadPath = configMap['uploadPath'] ?? 'None';
      String webPath = configMap['webPath'] ?? 'None';
      String customUrl = configMap['customUrl'] ?? 'None';
      if (host.endsWith('/')) {
        host = host.substring(0, host.length - 1);
      }
      if (customUrl.trim().isEmpty) {
        customUrl = 'None';
      }
      if (customUrl.endsWith('/')) {
        customUrl = customUrl.substring(0, customUrl.length - 1);
      }

      String token = configMap['token'];
      String adminToken = configMap['adminToken'] ?? 'None';
      if (adminToken != 'None' && adminToken.trim().isNotEmpty) {
        token = adminToken;
      } else {
        AlistImageUploadUtils.refreshToken(configMap: configMap);
      }

      if (uploadPath == 'None') {
        uploadPath = '/';
      } else {
        if (!uploadPath.startsWith('/')) {
          uploadPath = '/$uploadPath';
        }
        if (!uploadPath.endsWith('/')) {
          uploadPath = '$uploadPath/';
        }
      }

      String filePath = uploadPath + name;

      BaseOptions options = setBaseOptions();
      File uploadFile = File(path);
      int contentLength = await uploadFile.length().then((value) {
        return value;
      });
      options.headers = {
        "Authorization": token,
        "file-path": Uri.encodeComponent(filePath),
        "Content-Length": contentLength,
      };
      Dio dio = Dio(options);
      String uploadUrl = "$host/api/fs/form";
      String infoGetUrl = "$host/api/fs/get";
      String refreshUrl = "$host/api/fs/list";

      var uploadResponse = await dio.put(uploadUrl, data: formdata, onSendProgress: onSendProgress);
      if (uploadResponse.statusCode != 200 || uploadResponse.data!['message'] != 'success') {
        return ['failed'];
      }

      BaseOptions getOptions = setBaseOptions();
      getOptions.headers = {
        "Authorization": token,
        "Content-Type": "application/json",
      };
      Dio dioGet = Dio(getOptions);
      Dio dioRefresh = Dio(getOptions);
      Map getformData = {
        "path": filePath,
      };
      Map refreshListFormData = {"password": "", "page": 1, "per_page": 1, "path": uploadPath, "refresh": true};
      var refreshResponse = await dioRefresh.post(refreshUrl, data: refreshListFormData);
      if (refreshResponse.statusCode != 200 || refreshResponse.data!['message'] != 'success') {
        return ['failed'];
      }
      var responseGet = await dioGet.post(infoGetUrl, data: getformData);
      if (responseGet.statusCode != 200 || responseGet.data['message'] != 'success') {
        return ['failed'];
      }
      String returnUrl = responseGet.data!['data']['raw_url'];
      //返回缩略图地址用来在相册显示
      String displayUrl = responseGet.data!['data']['thumb'] == "" || responseGet.data!['data']['thumb'] == null
          ? returnUrl
          : responseGet.data!['data']['thumb'];
      Map pictureKeyMap = Map.from(configMap);
      pictureKeyMap['sign'] = responseGet.data!['data']['sign'];
      pictureKeyMap['uploadPath'] = uploadPath;
      pictureKeyMap['filenames'] = name;
      String pictureKey = jsonEncode(pictureKeyMap);

      if (webPath != 'None') {
        webPath = '/${webPath.replaceAll(RegExp(r'^/*'), '').replaceAll(RegExp(r'/*$'), '')}/$name';
      }
      String hostPicUrl = '';
      if (customUrl != 'None') {
        hostPicUrl = '$customUrl${webPath != 'None' ? webPath : filePath}';
      } else {
        hostPicUrl = '$host/d${webPath != 'None' ? webPath : filePath}';
        if (responseGet.data!['data']['sign'] != "" && responseGet.data!['data']['sign'] != null) {
          hostPicUrl = '$hostPicUrl?sign=${responseGet.data!['data']['sign']}';
        }
      }

      String formatedURL = getFormatedUrl(hostPicUrl, name);

      return ["success", formatedURL, returnUrl, pictureKey, displayUrl, hostPicUrl];
    } catch (e) {
      flogErr(
          e,
          {
            'path': path,
            'name': name,
          },
          "AlistImageUploadUtils",
          "uploadApi");
      return ['failed'];
    }
  }

  static deleteApi({required Map deleteMap, required Map configMap}) async {
    Map configMapFromPictureKey = jsonDecode(deleteMap['pictureKey']);
    Map<String, dynamic> formdata = {
      "dir": configMapFromPictureKey['uploadPath'],
      "names": [configMapFromPictureKey['filenames']]
    };
    String token = configMap['token'];
    String? adminToken = configMap['adminToken'];
    if (adminToken != null && adminToken != 'None' && adminToken.trim().isNotEmpty) {
      token = adminToken;
    } else {
      AlistImageUploadUtils.refreshToken(configMap: configMap);
    }
    BaseOptions options = setBaseOptions();
    options.headers = {
      "Authorization": token,
      "Content-Type": "application/json",
    };
    Dio dio = Dio(options);
    String deleteUrl = configMapFromPictureKey["host"] + "/api/fs/remove";
    try {
      var response = await dio.post(deleteUrl, data: formdata);
      if (response.statusCode != 200 || response.data!['message'] != "success") {
        return ['failed'];
      }
      return ["success"];
    } catch (e) {
      flogErr(
          e,
          {
            'deleteMap': deleteMap,
            'configMap': configMap,
          },
          "AlistImageUploadUtils",
          "deleteApi");
      return ['failed'];
    }
  }
}
