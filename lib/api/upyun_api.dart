import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:f_logs/f_logs.dart';

import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/utils/global.dart';

class UpyunImageUploadUtils {
  //上传接口
  static uploadApi(
      {required String path,
      required String name,
      required Map configMap}) async {
    String bucket = configMap['bucket'];
    String upyunOperator = configMap['operator'];
    String password = configMap['password'];
    String url = configMap['url'];
    String options = configMap['options'];
    String upyunpath = configMap['path'];
    //格式化
    if (url != "None") {
      if (!url.startsWith('http') && !url.startsWith('https')) {
        url = 'http://$url';
      }
    }
    //格式化
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
    Map<String, dynamic> uploadPolicy = {
      'bucket': bucket,
      'save-key': urlpath,
      'expiration': DateTime.now().millisecondsSinceEpoch + 1800000,
      'date': date,
      'content-md5': uploadFileMd5,
    };
    String base64Policy = base64.encode(utf8.encode(json.encode(uploadPolicy)));
    String stringToSign = 'POST&/$bucket&$date&$base64Policy&$uploadFileMd5';
    String passwordMd5 = md5.convert(utf8.encode(password)).toString();
    String signature = base64.encode(Hmac(sha1, utf8.encode(passwordMd5))
        .convert(utf8.encode(stringToSign))
        .bytes);
    String authorization = 'UPYUN $upyunOperator:$signature';
    FormData formData = FormData.fromMap({
      'authorization': authorization,
      'policy': base64Policy,
      'file': await MultipartFile.fromFile(path, filename: name),
    });
    BaseOptions baseoptions = BaseOptions(
      //连接服务器超时时间，单位是毫秒.
      connectTimeout: 30000,
      //响应超时时间。
      receiveTimeout: 30000,
      sendTimeout: 30000,
    );
    String contentLength = await uploadFile.length().then((value) {
      return value.toString();
    });
    baseoptions.headers = {
      'Host': 'v0.api.upyun.com',
      'Content-Type':
          'multipart/form-data; boundary=----WebKitFormBoundary7MA4YWxkTrZu0gW',
      'Content-Length': contentLength,
      'Date': date,
      'Authorization': authorization,
      'Content-MD5': uploadFileMd5,
    };
    Dio dio = Dio(baseoptions);
    try {
      var response = await dio.post(
        '$host/$bucket',
        data: formData,
      );

      if (response.statusCode == 200) {
        String returnUrl = '';
        String displayUrl = '';

        if (!url.endsWith('/')) {
          returnUrl = '$url/$urlpath';
          displayUrl = '$url/$urlpath';
        } else {
          url = url.substring(0, url.length - 1);
          returnUrl = '$url/$urlpath';
          displayUrl = '$url/$urlpath';
        }

        returnUrl = '$returnUrl$options';
        displayUrl = '$displayUrl$options';

        String formatedURL = '';
        if (Global.isCopyLink == true) {
          formatedURL =
              linkGenerateDict[Global.defaultLKformat]!(returnUrl, name);
        } else {
          formatedURL = returnUrl;
        }
        String pictureKey = 'None';
        return ["success", formatedURL, returnUrl, pictureKey, displayUrl];
      } else {
        return ['failed'];
      }
    } catch (e) {
      if (e is DioError) {
        FLog.error(
            className: "UpyunImageUploadUtils",
            methodName: "uploadApi",
            text: formatErrorMessage({
              'path': path,
              'name': name,
            }, e.toString(), isDioError: true, dioErrorMessage: e),
            dataLogType: DataLogType.ERRORS.toString());
      } else {
        FLog.error(
            className: "UpyunImageUploadUtils",
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
    String fileName = deleteMap['name'];
    String bucket = configMap['bucket'];
    String upyunOperator = configMap['operator'];
    String password = configMap['password'];
    String upyunpath = configMap['path'];

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
    BaseOptions baseOptions = BaseOptions(
      //连接服务器超时时间，单位是毫秒.
      connectTimeout: 30000,
      //响应超时时间。
      receiveTimeout: 30000,
      sendTimeout: 30000,
    );
    var date = HttpDate.format(DateTime.now());
    String method = 'DELETE';
    String canonicalizedResource = '/$bucket/$urlpath';
    String stringToSign = '$method&$canonicalizedResource&$date';
    String passwordMd5 = md5.convert(utf8.encode(password)).toString();
    String signature = base64.encode(Hmac(sha1, utf8.encode(passwordMd5))
        .convert(utf8.encode(stringToSign))
        .bytes);
    String authorization = 'UPYUN $upyunOperator:$signature';
    baseOptions.headers = {
      'Host': 'v0.api.upyun.com',
      'Authorization': authorization,
      'Date': date,
      'x-upyun-async': 'true',
    };
    Dio dio = Dio(baseOptions);
    try {
      var response = await dio.delete(
        deleteHost,
      );
      if (response.statusCode == 200) {
        return [
          "success",
        ];
      } else {
        return ["failed"];
      }
    } catch (e) {
      if (e is DioError) {
        FLog.error(
            className: "UpyunImageUploadUtils",
            methodName: "deleteApi",
            text: formatErrorMessage({
              'fileName': fileName,
            }, e.toString(), isDioError: true, dioErrorMessage: e),
            dataLogType: DataLogType.ERRORS.toString());
      } else {
        FLog.error(
            className: "UpyunImageUploadUtils",
            methodName: "deleteApi",
            text: formatErrorMessage({
              'fileName': fileName,
            }, e.toString()),
            dataLogType: DataLogType.ERRORS.toString());
      }
      return [e.toString()];
    }
  }
}
