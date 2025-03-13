import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as my_path;

import 'package:horopic/utils/common_functions.dart';

class QiniuImageUploadUtils {
  static Map<String, String> areaHostMap = {
    'z0': 'https://upload.qiniup.com', //华东
    'cn-east-2': 'https://upload-cn-east-2.qiniup.com', //华东 浙江2
    'z1': 'https://upload-z1.qiniup.com', //华北
    'z2': 'https://upload-z2.qiniup.com', //华南
    'na0': 'https://upload-na0.qiniup.com', //北美
    'as0': 'https://upload-as0.qiniup.com', //东南亚
    'ap-northeast-1': 'https://upload-ap-northeast-1.qiniup.com', //亚太首尔
    'ap-southeast-2': 'https://upload-ap-southeast-2.qiniup.com', //亚太-河内
  };
  //url安全的base64编码
  static String urlSafeBase64Encode(List<int> bytes) {
    String base64 = base64Encode(bytes);
    return base64.replaceAll('+', '-').replaceAll('/', '_');
  }

  //url安全的base64编码的上传策略
  static String geturlSafeBase64EncodePutPolicy(String bucket, String key, String path) {
    Map<String, dynamic> putPolicy;
    if (path == 'None') {
      putPolicy = {
        'scope': bucket,
        'deadline': 2075813285, //过期时间2035年
        'saveKey': key,
      };
    } else {
      putPolicy = {
        'scope': bucket,
        'deadline': 2075813285,
        'saveKey': '$path$key',
      };
    }
    String putPolicyJson = jsonEncode(putPolicy);
    return urlSafeBase64Encode(utf8.encode(putPolicyJson));
  }

  //获取上传凭证
  static String getUploadToken(String accessKey, String secretKey, String urlSafeBase64EncodePutPolicy) {
    var hmacSha1 = Hmac(sha1, utf8.encode(secretKey));
    var sign = hmacSha1.convert(utf8.encode(urlSafeBase64EncodePutPolicy));
    String encodedSign = urlSafeBase64Encode(sign.bytes);
    return '$accessKey:$encodedSign:$urlSafeBase64EncodePutPolicy';
  }

  //获取管理凭证
  static String getAuthToken(String method, String path, String? query, String host, String contentType, String body,
      String accessKey, String secretKey) {
    var signStr = '${method.toUpperCase()} $path';

    if (query != null && query.isNotEmpty) {
      signStr += '?$query';
    }
    signStr += '\nHost: $host';
    if (contentType.isNotEmpty) {
      signStr += '\nContent-Type: $contentType';
    }

    signStr += '\n\n';
    if (contentType != 'application/octet-stream' && body.isNotEmpty) {
      signStr += body;
    }
    // 使用SecertKey对上一步生成的原始字符串计算HMAC-SHA1签名：
    var hmacsha1 = Hmac(sha1, utf8.encode(secretKey));
    var sign = hmacsha1.convert(utf8.encode(signStr));
    var encodedSign = urlSafeBase64Encode(sign.bytes);
    return '$accessKey:$encodedSign';
  }

  //上传接口
  static uploadApi({
    required String path,
    required String name,
    required Map configMap,
    Function(int, int)? onSendProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      String accessKey = configMap['accessKey'] ?? '';
      String secretKey = configMap['secretKey'] ?? '';
      String bucket = configMap['bucket'] ?? '';
      String url = configMap['url'] ?? '';
      String area = configMap['area'] ?? '';
      String options = configMap['options'] ?? '';
      String qiniupath = configMap['path'] ?? 'None';

      if (!url.startsWith('http') && !url.startsWith('https')) {
        url = 'http://$url';
      }
      if (url.endsWith('/')) {
        url = url.substring(0, url.length - 1);
      }
      String urlpath = '';
      //不为None才处理
      if (qiniupath != 'None') {
        if (qiniupath.startsWith('/')) {
          qiniupath = qiniupath.substring(1);
        }
        if (!qiniupath.endsWith('/')) {
          qiniupath = '$qiniupath/';
        }
        urlpath = '$qiniupath$name';
      } else {
        urlpath = name;
      }
      String key = name;

      String urlSafeBase64EncodePutPolicy = geturlSafeBase64EncodePutPolicy(bucket, key, qiniupath);
      String uploadToken = getUploadToken(accessKey, secretKey, urlSafeBase64EncodePutPolicy);
      String host = QiniuImageUploadUtils.areaHostMap[area]!;
      FormData formData = FormData.fromMap({
        "key": urlpath,
        "fileName": name,
        "token": uploadToken,
        "file": await MultipartFile.fromFile(path, filename: my_path.basename(path)),
      });
      BaseOptions baseoptions = setBaseOptions();
      //不需要加Content-Type，host，Content-Length
      baseoptions.headers = {
        'Authorization': 'UpToken $uploadToken',
      };
      Dio dio = Dio(baseoptions);
      var response = await dio.post(
        host,
        data: formData,
        onSendProgress: onSendProgress,
        cancelToken: cancelToken,
      );

      if (response.statusCode == HttpStatus.ok) {
        String returnUrl = '';
        String displayUrl = '';

        if (options == 'None') {
          returnUrl = '$url/${response.data['key']}';
          displayUrl = '$url/${response.data['key']}?imageView2/2/w/500/h/500';
        } else {
          if (!options.startsWith('?')) {
            options = '?$options';
          }
          returnUrl = '$url/${response.data['key']}$options';
          displayUrl = '$url/${response.data['key']}$options';
        }
        String formatedURL = getFormatedUrl(returnUrl, name);
        Map pictureKeyMap = Map.from(configMap);
        String pictureKey = jsonEncode(pictureKeyMap);
        return ["success", formatedURL, returnUrl, pictureKey, displayUrl];
      } else {
        return ['failed'];
      }
    } catch (e) {
      flogErr(
          e,
          {
            'path': path,
            'name': name,
          },
          "QiniuImageUploadUtils",
          "uploadApi");
      return ['failed'];
    }
  }

  static deleteApi({required Map deleteMap, required Map configMap}) async {
    String fileName = deleteMap['name'];
    Map configMapFromPictureKey = jsonDecode(deleteMap['pictureKey']);

    String accessKey = configMapFromPictureKey['accessKey'];
    String secretKey = configMapFromPictureKey['secretKey'];
    String bucket = configMapFromPictureKey['bucket'];
    String qiniupath = configMapFromPictureKey['path'];
    String key = '';
    if (qiniupath.startsWith('/')) {
      qiniupath = qiniupath.substring(1);
    }
    if (fileName.startsWith('/')) {
      fileName = fileName.substring(1);
    }

    if (qiniupath == 'None') {
      key = fileName;
    } else {
      key = '$qiniupath/$fileName';
    }

    String encodedEntryURI = urlSafeBase64Encode(utf8.encode('$bucket:$key'));

    BaseOptions baseOptions = setBaseOptions();
    String authToken = getAuthToken('DELETE', '/delete/$encodedEntryURI', null, 'rs.qiniuapi.com',
        'application/x-www-form-urlencoded', '', accessKey, secretKey);
    baseOptions.headers = {
      "Authorization": "Qiniu $authToken",
      "Content-Type": "application/x-www-form-urlencoded",
    };

    Dio dio = Dio(baseOptions);
    String deleteUrl = "http://rs.qiniuapi.com/delete/$encodedEntryURI";

    try {
      var response = await dio.delete(deleteUrl);
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
          "QiniuImageUploadUtils",
          "deleteApi");
      return ["failed"];
    }
  }
}
