import 'dart:convert';
import 'package:webdav_client/webdav_client.dart' as webdav;

import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/picture_host_manage/manage_api/webdav_manage_api.dart';

class WebdavImageUploadUtils {
  //上传接口
  static uploadApi({required String path, required String name, required Map configMap}) async {
    try {
      webdav.Client client = await WebdavManageAPI.getWebdavClient();
      String uploadPath = configMap['uploadPath'];
      String customUrl = configMap['customUrl'] ?? 'None';
      String webPath = configMap['webPath'] ?? 'None';
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

      await client.writeFromFile(path, filePath);

      String returnUrl = '';
      String displayUrl = '';
      if (customUrl != 'None') {
        customUrl = customUrl.replaceAll(RegExp(r'/$'), '');
        if (webPath != 'None') {
          webPath = webPath.replaceAll(RegExp(r'^/*'), '').replaceAll(RegExp(r'/*$'), '');
          returnUrl = '$customUrl/$webPath/$name';
        } else {
          filePath = filePath.replaceAll(RegExp(r'^/*'), '');
          returnUrl = '$customUrl/$filePath';
        }
        displayUrl = returnUrl;
      } else {
        returnUrl = configMap['host'] + filePath;
        displayUrl = returnUrl + generateBasicAuth(configMap['webdavusername'], configMap['password']);
      }

      String formatedURL = getFormatedUrl(returnUrl, name);
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
      flogErr(
          e,
          {
            'path': path,
            'name': name,
          },
          "WebdavImageUploadUtils",
          "uploadApi");

      return ["failed"];
    }
  }

  static deleteApi({required Map deleteMap, required Map configMap}) async {
    try {
      Map configMapFromPictureKey = jsonDecode(deleteMap['pictureKey']);

      String host = configMapFromPictureKey['host'];
      String webdavusername = configMapFromPictureKey['webdavusername'];
      String password = configMapFromPictureKey['password'];

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

      return ["success"];
    } catch (e) {
      flogErr(
          e,
          {
            'deleteMap': deleteMap,
            'configMap': configMap,
          },
          "WebdavImageUploadUtils",
          "deleteApi");
      return ["failed"];
    }
  }
}
