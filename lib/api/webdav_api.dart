import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:f_logs/f_logs.dart';
import 'package:webdav_client/webdav_client.dart' as webdav;

import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/utils/global.dart';
import 'package:horopic/picture_host_manage/manage_api/webdav_manage_api.dart';

class WebdavImageUploadUtils {
  //上传接口
  static uploadApi(
      {required String path,
      required String name,
      required Map configMap}) async {
    String formatedURL = '';
    webdav.Client client = await WebdavManageAPI.getWebdavClient();
    String uploadPath = configMap['uploadPath'];

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

    try {
      await client.writeFromFile(path, filePath);

      String returnUrl = '';
      String displayUrl = '';
      returnUrl = configMap['host'] + filePath;
      displayUrl = returnUrl +
          generateBasicAuth(configMap['webdavusername'], configMap['password']);
      if (Global.isCopyLink == true) {
        formatedURL =
            linkGenerateDict[Global.defaultLKformat]!(returnUrl, name);
      } else {
        formatedURL = returnUrl;
      }
      Map pictureKeyMap = Map.from(configMap);
      pictureKeyMap['pictureKey'] = filePath;
      String pictureKey = jsonEncode(pictureKeyMap);

      return [
        "success",
        formatedURL,
        returnUrl,
        pictureKey,
        displayUrl,
      ];
    } catch (e) {
      if (e is DioError) {
        FLog.error(
            className: "WebdavImageUploadUtils",
            methodName: "uploadApi",
            text: formatErrorMessage({
              'path': path,
              'name': name,
            }, e.toString(), isDioError: true, dioErrorMessage: e),
            dataLogType: DataLogType.ERRORS.toString());
      } else {
        FLog.error(
            className: "WebdavImageUploadUtils",
            methodName: "uploadApi",
            text: formatErrorMessage({
              'path': path,
              'name': name,
            }, e.toString()),
            dataLogType: DataLogType.ERRORS.toString());
      }
      return [e.toString()];
    }
  }

  static deleteApi({required Map deleteMap, required Map configMap}) async {
    Map configMapFromPictureKey = jsonDecode(deleteMap['pictureKey']);
    String host = configMapFromPictureKey['host'];
    String webdavusername = configMapFromPictureKey['webdavusername'];
    String password = configMapFromPictureKey['password'];

    try {
      webdav.Client client = webdav.newClient(
        host,
        user: webdavusername,
        password: password,
      );
      client.setHeaders({'accept-charset': 'utf-8'});
      client.setConnectTimeout(30000);
      client.setSendTimeout(30000);
      client.setReceiveTimeout(30000);
      await client.remove(configMapFromPictureKey['pictureKey']);

      return [
        "success",
      ];
    } catch (e) {
      if (e is DioError) {
        FLog.error(
            className: "WebdavImageUploadUtils",
            methodName: "deleteApi",
            text: formatErrorMessage({}, e.toString(),
                isDioError: true, dioErrorMessage: e),
            dataLogType: DataLogType.ERRORS.toString());
      } else {
        FLog.error(
            className: "WebdavImageUploadUtils",
            methodName: "deleteApi",
            text: formatErrorMessage({}, e.toString()),
            dataLogType: DataLogType.ERRORS.toString());
      }
      return [e.toString()];
    }
  }
}
