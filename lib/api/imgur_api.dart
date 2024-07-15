import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';

import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/utils/dio_proxy_adapter.dart';

class ImgurImageUploadUtils {
  //上传接口
  static uploadApi({
    required String path,
    required String name,
    required Map configMap,
    Function(int, int)? onSendProgress,
    CancelToken? cancelToken,
  }) async {
    try {
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

      var response =
          await dio.post(uploadUrl, data: formdata, onSendProgress: onSendProgress, cancelToken: cancelToken);
      if (response.statusCode != 200 || response.data!['success'] != true) {
        return ["failed"];
      }

      String returnUrl = response.data!['data']['link'];
      Map pictureKeyMap = {
        'clientId': configMap['clientId'],
        'deletehash': response.data!['data']['deletehash'],
      };
      String pictureKey = jsonEncode(pictureKeyMap);
      String formatedURL = getFormatedUrl(returnUrl, name);
      String cdnUrl = returnUrl;
      return ["success", formatedURL, returnUrl, pictureKey, cdnUrl];
    } catch (e) {
      flogError(
          e,
          {
            'path': path,
            'name': name,
          },
          "ImgurImageUploadUtils",
          "uploadApi");
      return ['failed'];
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
      if (response.statusCode != 200 || response.data!['success'] != true) {
        return ["failed"];
      }
      return ["success"];
    } catch (e) {
      flogError(e, {}, "ImgurImageUploadUtils", "deleteApi");
      return ["failed"];
    }
  }
}
