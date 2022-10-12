import 'package:dio/dio.dart';
import 'package:horopic/utils/common_func.dart';
import 'package:horopic/utils/global.dart';
import 'dart:convert';
import 'dart:io';
import 'package:dio_proxy_adapter/dio_proxy_adapter.dart';

class ImgurImageUploadUtils {
  //上传接口
  static uploadApi(
      {required String path,
      required String name,
      required Map configMap}) async {
    String formatedURL = '';
    String base64Image = base64Encode(File(path).readAsBytesSync());

    FormData formdata = FormData.fromMap({
      "image": base64Image,
    });

    BaseOptions options = BaseOptions(
      //连接服务器超时时间，单位是毫秒.
      connectTimeout: 10000,
      //响应超时时间。
      receiveTimeout: 10000,
    );
    options.headers = {
      "Authorization": "Client-ID ${configMap["clientId"]}",
    };
    Dio dio = Dio(options);
    String proxy = configMap["proxy"];
    String proxyClean = '';
    //判断是否有代理
    if (proxy != 'None') {
      if (proxy.startsWith('http://') || proxy.startsWith('https://')) {
        proxyClean = proxy.split('://')[1];
      } else {
        proxyClean = proxy;
      }
      dio.useProxy(proxyClean);
    }
    //官方文档里写的是https://api.imgur.com/3/upload emmmmmm
    String uploadUrl = "https://api.imgur.com/3/image";
    try {
      var response = await dio.post(uploadUrl, data: formdata);
      if (response.statusCode == 200 && response.data!['success'] == true) {
        String returnUrl = response.data!['data']['link'];
        String pictureKey = response.data!['data']['deletehash'];

        if (Global.isCopyLink == true) {
          formatedURL =
              linkGenerateDict[Global.defaultLKformat]!(returnUrl, name);
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
      return [e.toString()];
    }
  }

  static deleteApi({required Map deleteMap, required Map configMap}) async {
    String deletehash = deleteMap["pictureKey"];

    BaseOptions options = BaseOptions(
      //连接服务器超时时间，单位是毫秒.
      connectTimeout: 10000,
      //响应超时时间。
      receiveTimeout: 10000,
    );
    options.headers = {
      "Authorization": "Client-ID ${configMap["clientId"]}",
    };
    Dio dio = Dio(options);
    String deleteUrl = "https://api.imgur.com/3/image/$deletehash";
    //判断是否有代理
    String proxy = configMap["proxy"];
    String proxyClean = '';
    if (proxy != 'None') {
      if (proxy.startsWith('http://') || proxy.startsWith('https://')) {
        proxyClean = proxy.split('://')[1];
      } else {
        proxyClean = proxy;
      }
      dio.useProxy(proxyClean);
    }

    try {
      var response = await dio.delete(deleteUrl);
      if (response.statusCode == 200 && response.data!['success'] == true) {
        return ["success"];
      } else {
        return ["failed"];
      }
    } catch (e) {
      return [e.toString()];
    }
  }
}
