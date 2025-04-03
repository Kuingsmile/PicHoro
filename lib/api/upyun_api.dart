import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as my_path;

import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/utils/global.dart';
import 'package:horopic/utils/picbed/upyun.dart';

class UpyunImageUploadUtils {
  //上传接口
  static uploadApi({
    required String path,
    required String name,
    required Map configMap,
    Function(int, int)? onSendProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      String bucket = configMap['bucket'] ?? '';
      String upyunOperator = configMap['operator'] ?? '';
      String password = configMap['password'] ?? '';
      String url = configMap['url'] ?? '';
      String options = configMap['options'] ?? '';
      String upyunpath = configMap['path'] ?? '';
      String antiLeechToken = configMap['antiLeechToken'] ?? '';
      String antiLeechExpiration = configMap['antiLeechExpiration'] ?? '';
      if (options.trim() == '') {
        options = '';
      }

      if (url != "None") {
        if (!url.startsWith(RegExp(r'http(s)?://'))) {
          url = 'http://$url';
        }
      }
      if (upyunpath == '/' || upyunpath == '') {
        upyunpath = 'None';
      }
      if (upyunpath != 'None') {
        if (upyunpath.startsWith('/')) {
          upyunpath = upyunpath.substring(1);
        }
        if (!upyunpath.endsWith('/')) {
          upyunpath = '$upyunpath/';
        }
      }
      String host = 'http://v0.api.upyun.com';
      //云存储的路径
      String urlpath = '';
      if (upyunpath != 'None') {
        urlpath = '/$upyunpath$name';
      } else {
        urlpath = '/$name';
      }
      String date = HttpDate.format(DateTime.now());
      File uploadFile = File(path);
      String uploadFileMd5 = await uploadFile.readAsBytes().then((value) {
        return md5.convert(value).toString();
      });
      String base64Policy =
          getUpyunUploadPolicy(bucket: bucket, saveKey: urlpath, contentMd5: uploadFileMd5, date: date);

      String authorization = getUpyunUploadAuthHeader(
          bucket: bucket,
          saveKey: urlpath,
          contentMd5: uploadFileMd5,
          operator: upyunOperator,
          password: password,
          base64Policy: base64Policy,
          date: date);
      FormData formData = FormData.fromMap({
        'authorization': authorization,
        'policy': base64Policy,
        'file': await MultipartFile.fromFile(path, filename: my_path.basename(path)),
      });
      BaseOptions baseoptions = setBaseOptions();
      String contentLength = await uploadFile.length().then((value) {
        return value.toString();
      });
      baseoptions.headers = {
        'Host': 'v0.api.upyun.com',
        'Content-Type': Global.multipartString,
        'Content-Length': contentLength,
        'Date': date,
        'Authorization': authorization,
        'Content-MD5': uploadFileMd5,
      };
      Dio dio = Dio(baseoptions);

      var response = await dio.post(
        '$host/$bucket',
        data: formData,
        onSendProgress: onSendProgress,
        cancelToken: cancelToken,
      );
      if (response.statusCode != 200) {
        return ['failed'];
      }
      String returnUrl = '';
      String displayUrl = '';
      String antiLeechQuery = getUpyunAntiLeechParam(
          saveKey: urlpath, antiLeechToken: antiLeechToken, antiLeechExpiration: antiLeechExpiration);
      if (urlpath.startsWith('/')) {
        urlpath = urlpath.substring(1);
      }
      if (url.endsWith('/')) {
        url = url.substring(0, url.length - 1);
      }

      returnUrl = '$url/$urlpath$options';
      if (antiLeechQuery != '') {
        if (options != '') {
          returnUrl = '$url/$urlpath$options&$antiLeechQuery';
        } else {
          returnUrl = '$url/$urlpath?$antiLeechQuery';
        }
      }
      displayUrl = returnUrl;
      String formatedURL = getFormatedUrl(returnUrl, my_path.basename(path));
      Map pictureKeyMap = Map.from(configMap);
      String pictureKey = jsonEncode(pictureKeyMap);
      return ["success", formatedURL, returnUrl, pictureKey, displayUrl];
    } catch (e) {
      flogErr(
          e,
          {
            'path': path,
            'name': name,
          },
          "UpyunImageUploadUtils",
          "uploadApi");
      return ["failed"];
    }
  }

  static deleteApi({required Map deleteMap, required Map configMap}) async {
    try {
      String fileName = deleteMap['name'];
      Map configMapFromPictureKey = jsonDecode(deleteMap['pictureKey']);
      String bucket = configMapFromPictureKey['bucket'];
      String upyunOperator = configMapFromPictureKey['operator'];
      String password = configMapFromPictureKey['password'];
      String upyunpath = configMapFromPictureKey['path'];

      String deleteHost = 'http://v0.api.upyun.com';
      String urlpath = '';
      if (upyunpath != 'None') {
        if (upyunpath.startsWith('/')) {
          upyunpath = upyunpath.substring(1);
        }

        if (!upyunpath.endsWith('/')) {
          upyunpath = '$upyunpath/';
        }
        deleteHost = '$deleteHost/$bucket/$upyunpath$fileName';
        urlpath = '$upyunpath$fileName';
      } else {
        deleteHost = '$deleteHost/$bucket/$fileName';
        urlpath = fileName;
      }
      BaseOptions baseOptions = setBaseOptions();
      var date = HttpDate.format(DateTime.now());
      String method = 'DELETE';
      String uri = '/$bucket/$urlpath';
      String codedUri = Uri.encodeFull(uri);
      String stringToSign = '$method&$codedUri&$date';
      String passwordMd5 = md5.convert(utf8.encode(password)).toString();
      String signature = base64.encode(Hmac(sha1, utf8.encode(passwordMd5)).convert(utf8.encode(stringToSign)).bytes);
      String authorization = 'UPYUN $upyunOperator:$signature';
      baseOptions.headers = {
        'Host': 'v0.api.upyun.com',
        'Authorization': authorization,
        'Date': date,
        'x-upyun-async': 'true',
      };
      Dio dio = Dio(baseOptions);

      var response = await dio.delete(
        deleteHost,
      );
      if (response.statusCode != 200) {
        return ["failed"];
      }
      return ["success"];
    } catch (e) {
      flogErr(
          e,
          {
            'deleteMap': deleteMap,
            'configMap': configMap,
          },
          "UpyunImageUploadUtils",
          "deleteApi");
      return ["failed"];
    }
  }
}
