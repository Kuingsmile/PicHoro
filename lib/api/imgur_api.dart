import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:f_logs/f_logs.dart';

import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/utils/global.dart';
import 'package:horopic/utils/dio_proxy_adapter.dart';

class ImgurImageUploadUtils {
  //上传接口
  static uploadApi({required String path, required String name, required Map configMap}) async {
    String formatedURL = '';
    String base64Image = base64Encode(File(path).readAsBytesSync());

    FormData formdata = FormData.fromMap({
      "image": base64Image,
    });

    BaseOptions options = setBaseOptions();
    options.headers = {
      "Authorization": "Client-ID ${configMap["clientId"]}",
    };
    Dio dio = Dio(options);
    String proxy = configMap["proxy"];
    String proxyClean = '';
    if (proxy != 'None') {
      if (proxy.startsWith(RegExp(r'^https?://'))) {
        proxyClean = proxy.split('://')[1];
      } else {
        proxyClean = proxy;
      }
      dio.httpClientAdapter = useProxy(proxyClean);
    }
    //官方文档里写的是https://api.imgur.com/3/upload emmmmmm
    String uploadUrl = "https://api.imgur.com/3/image";
    try {
      var response = await dio.post(uploadUrl, data: formdata);
      if (response.statusCode == 200 && response.data!['success'] == true) {
        String returnUrl = response.data!['data']['link'];
        Map pictureKeyMap = {
          'clientId': configMap['clientId'],
          'deletehash': response.data!['data']['deletehash'],
        };
        String pictureKey = jsonEncode(pictureKeyMap);
        if (Global.isCopyLink == true) {
          formatedURL = linkGenerateDict[Global.defaultLKformat]!(returnUrl, name);
        } else {
          formatedURL = returnUrl;
        }
        //相册显示地址用cdn加速,但是复制的时候还是用原图地址
        //https://search.pstatic.net/common?src=

        String cdnUrl = 'https://search.pstatic.net/common?src=$returnUrl';
        return ["success", formatedURL, returnUrl, pictureKey, cdnUrl];
      } else {
        return ["failed"];
      }
    } catch (e) {
      if (e is DioException) {
        FLog.error(
            className: "ImgurImageUploadUtils",
            methodName: "uploadApi",
            text: formatErrorMessage({
              'path': path,
              'name': name,
            }, e.toString(), isDioError: true, dioErrorMessage: e),
            dataLogType: DataLogType.ERRORS.toString());
      } else {
        FLog.error(
            className: "ImgurImageUploadUtils",
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
    Map deleteMapFromPictureKey = jsonDecode(deleteMap['pictureKey']);
    String deletehash = deleteMapFromPictureKey["deletehash"];

    BaseOptions options = setBaseOptions();
    options.headers = {
      "Authorization": "Client-ID ${deleteMapFromPictureKey["clientId"]}",
    };
    Dio dio = Dio(options);
    String deleteUrl = "https://api.imgur.com/3/image/$deletehash";
    String proxy = configMap["proxy"];
    String proxyClean = '';
    if (proxy != 'None') {
      if (proxy.startsWith('http://') || proxy.startsWith('https://')) {
        proxyClean = proxy.split('://')[1];
      } else {
        proxyClean = proxy;
      }
      dio.httpClientAdapter = useProxy(proxyClean);
    }

    try {
      var response = await dio.delete(deleteUrl);
      if (response.statusCode == 200 && response.data!['success'] == true) {
        return ["success"];
      } else {
        return ["failed"];
      }
    } catch (e) {
      if (e is DioException) {
        FLog.error(
            className: "ImgurImageUploadUtils",
            methodName: "deleteApi",
            text: formatErrorMessage({}, e.toString(), isDioError: true, dioErrorMessage: e),
            dataLogType: DataLogType.ERRORS.toString());
      } else {
        FLog.error(
            className: "ImgurImageUploadUtils",
            methodName: "deleteApi",
            text: formatErrorMessage({}, e.toString()),
            dataLogType: DataLogType.ERRORS.toString());
      }
      return [e.toString()];
    }
  }
}
