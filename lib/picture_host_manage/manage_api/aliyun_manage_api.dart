import 'dart:io';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:f_logs/f_logs.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as my_path;
import 'package:xml2json/xml2json.dart';

import 'package:horopic/utils/global.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/picture_host_configure/configure_page/aliyun_configure.dart';

class AliyunManageAPI {
  static Map<String, String> areaCodeName = {
    'oss-cn-hangzhou': '华东1(杭州)',
    'oss-cn-shanghai': '华东2(上海)',
    'oss-cn-nanjing': '华东5(南京本地地域)',
    'oss-cn-fuzhou': '华东6(福州本地地域)',
    'oss-cn-wuhan': '华中1(武汉本地地域)',
    'oss-cn-qingdao': '华北1(青岛)',
    'oss-cn-beijing': '华北2(北京)',
    'oss-cn-zhangjiakou': '华北3(张家口)',
    'oss-cn-huhehaote': '华北5(呼和浩特)',
    'oss-cn-wulanchabu': '华北6(乌兰察布)',
    'oss-cn-shenzhen': '华南1(深圳)',
    'oss-cn-heyuan': '华南2(河源)',
    'oss-cn-guangzhou': '华南3(广州)',
    'oss-cn-chengdu': '西南1(成都)',
    'oss-cn-hongkong': '中国香港',
    'oss-us-west-1': '美国(硅谷)',
    'oss-us-east-1': '美国(弗吉尼亚)',
    'oss-ap-northeast-1': '日本(东京)',
    'oss-ap-northeast-2': '韩国(首尔)',
    'oss-ap-southeast-1': '新加坡',
    'oss-ap-southeast-2': '澳大利亚(悉尼)',
    'oss-ap-southeast-3': '马来西亚(吉隆坡)',
    'oss-ap-southeast-5': '印度尼西亚(雅加达)',
    'oss-ap-southeast-6': '菲律宾(马尼拉)',
    'oss-ap-southeast-7': '泰国(曼谷)',
    'oss-ap-south-1': '印度(孟买)',
    'oss-eu-central-1': '德国(法兰克福)',
    'oss-eu-west-1': '英国(伦敦)',
    'oss-me-east-1': '阿联酋(迪拜)',
    'oss-rg-china-mainland': '无地域属性'
  };

  static Future<File> get localFile async {
    final path = await _localPath;
    String defaultUser = await Global.getUser();
    return ensureFileExists(File('$path/${defaultUser}_aliyun_config.txt'));
  }

  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<String> readAliyunConfig() async {
    try {
      final file = await localFile;
      String contents = await file.readAsString();
      return contents;
    } catch (e) {
      FLog.error(
          className: 'AliyunManageAPI',
          methodName: 'readAliyunConfig',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      return "Error";
    }
  }

  static Future<Map> getConfigMap() async {
    String configStr = await readAliyunConfig();
    if (configStr == '') {
      return {};
    }
    Map configMap = json.decode(configStr);
    return configMap;
  }

  static isString(var variable) {
    return variable is String;
  }

  static isFile(var variable) {
    return variable is File;
  }

  //get MD5
  static getContentMd5(var variable) async {
    if (isString(variable)) {
      return base64.encode(md5.convert(utf8.encode(variable)).bytes);
    } else if (isFile(variable)) {
      List<int> bytes = await variable.readAsBytes();
      return base64.encode(md5.convert(bytes).bytes);
    } else {
      return "";
    }
  }

  //get CanonicalizedOSSHeaders
  static getCanonicalizedOSSHeaders(Map headers) {
    //小写
    Map<String, String> lowerHeaders = {};
    headers.forEach((key, value) {
      lowerHeaders[key.toLowerCase()] = value;
    });
    String canonicalizedOSSHeaders = "";
    List headerKeys = lowerHeaders.keys.toList();
    headerKeys.sort();
    for (var key in headerKeys) {
      if (key.startsWith("x-oss-")) {
        canonicalizedOSSHeaders += "$key:${lowerHeaders[key]}\n";
      }
    }
    return canonicalizedOSSHeaders;
  }

  //get authorization
  static Future<String> aliyunAuthorization(
      String method, String canonicalizedResource, Map headers, String contentMd5, String contentType) async {
    try {
      Map configMap = await getConfigMap();
      String accessKeyId = configMap['keyId'];
      String accessKeySecret = configMap['keySecret'];
      String gmtDate = HttpDate.format(DateTime.now());
      String uperCaseMethod = method.toUpperCase();
      String canonicalizedOSSHeaders = getCanonicalizedOSSHeaders(headers);
      String stringToSign =
          "$uperCaseMethod\n$contentMd5\n$contentType\n$gmtDate\n$canonicalizedOSSHeaders$canonicalizedResource";
      String signature =
          base64.encode(Hmac(sha1, utf8.encode(accessKeySecret)).convert(utf8.encode(stringToSign)).bytes);
      String authorization = "OSS $accessKeyId:$signature";
      return authorization;
    } catch (e) {
      FLog.error(
          className: 'AliyunManageAPI',
          methodName: 'aliyunAuthorization',
          text: formatErrorMessage({
            'method': method,
            'canonicalizedResource': canonicalizedResource,
            'headers': headers,
            'contentMd5': contentMd5,
            'contentType': contentType,
          }, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      rethrow;
    }
  }

  //获取bucket列表
  static getBucketList() async {
    try {
      String method = 'GET';
      String canonicalizedResource = '/';
      String contentMd5 = '';
      String contentType = '';
      String host = 'oss-cn-hangzhou.aliyuncs.com';
      String authorization = await aliyunAuthorization(method, canonicalizedResource, {}, contentMd5, contentType);
      BaseOptions baseoptions = setBaseOptions();
      baseoptions.headers = {
        'Authorization': authorization,
        'Date': HttpDate.format(DateTime.now()),
      };
      Map<String, dynamic> queryParameters = {
        'max-keys': 1000,
      };

      Dio dio = Dio(baseoptions);

      var response = await dio.get('https://$host', queryParameters: queryParameters);
      if (response.statusCode == 200) {
        String responseBody = response.data;
        final myTransformer = Xml2Json();
        myTransformer.parse(responseBody);
        Map responseMap = json.decode(myTransformer.toParker());
        return ['success', responseMap];
      } else {
        return ['failed'];
      }
    } catch (e) {
      flogError(e, {}, "AliyunManageAPI", "getBucketList");
      return [e.toString()];
    }
  }

  //新建存储桶
  static createBucket(Map newBucketConfigMap) async {
    try {
      String method = 'PUT';
      String bucketName = newBucketConfigMap['bucketName'];
      String region = newBucketConfigMap['region'];
      bool multiAZ = newBucketConfigMap['multiAZ'];
      String xCosACL = newBucketConfigMap['xCosACL'];

      if (multiAZ == true &&
          region != 'oss-cn-shenzhen' &&
          region != 'oss-cn-beijing' &&
          region != 'oss-cn-hangzhou' &&
          region != 'oss-cn-shanghai' &&
          region != 'oss-cn-hongkong' &&
          region != 'oss-ap-southeast-1' &&
          region != 'oss-ap-southeast-5') {
        return [
          'multiAZ error',
        ];
      }
      var body = '<CreateBucketConfiguration><DataRedundancyType>ZRS</DataRedundancyType></CreateBucketConfiguration>';
      BaseOptions baseoptions = setBaseOptions();
      baseoptions.headers = {
        'Date': HttpDate.format(DateTime.now()),
        'x-oss-acl': xCosACL,
      };
      if (multiAZ == true) {
        baseoptions.headers['content-type'] = 'application/xml';
        baseoptions.headers['content-length'] = body.length.toString();
        String contentMd5 = await getContentMd5(body);
        baseoptions.headers['content-md5'] = await getContentMd5(body);
        String authorization =
            await aliyunAuthorization(method, '/$bucketName/', baseoptions.headers, contentMd5, 'application/xml');
        baseoptions.headers['Authorization'] = authorization;
      } else {
        baseoptions.headers['content-type'] = 'application/json';
        String authorization =
            await aliyunAuthorization(method, '/$bucketName/', baseoptions.headers, '', 'application/json');
        baseoptions.headers['Authorization'] = authorization;
      }
      Dio dio = Dio(baseoptions);

      Response response;
      if (multiAZ == true) {
        response = await dio.put('https://$bucketName.$region.aliyuncs.com', data: body);
      } else {
        response = await dio.put('https://$bucketName.$region.aliyuncs.com');
      }
      if (response.statusCode == 200) {
        return ['success'];
      } else {
        return ['failed'];
      }
    } catch (e) {
      flogError(
          e,
          {
            'newBucketConfigMap': newBucketConfigMap,
          },
          "AliyunManageAPI",
          "createBucket");
      return [e.toString()];
    }
  }

  //查询存储桶权限
  static queryACLPolicy(Map element) async {
    try {
      String bucket = element['name'];
      String region = element['location'];
      String method = 'GET';
      String urlpath = '/$bucket/?acl';
      String host = '$bucket.$region.aliyuncs.com';

      BaseOptions baseoptions = setBaseOptions();
      baseoptions.headers = {
        'Date': HttpDate.format(DateTime.now()),
      };
      String authorization = await aliyunAuthorization(method, urlpath, baseoptions.headers, '', '');
      baseoptions.headers['Authorization'] = authorization;

      Dio dio = Dio(baseoptions);
      var response = await dio.get('https://$host?acl', queryParameters: {'acl': ''});
      var responseBody = response.data;
      final myTransformer = Xml2Json();
      myTransformer.parse(responseBody);
      Map responseMap = json.decode(myTransformer.toParker());
      if (response.statusCode == 200) {
        return ['success', responseMap];
      } else {
        return ['failed'];
      }
    } catch (e) {
      flogError(e, {'element': element}, "AliyunManageAPI", "queryACLPolicy");
      return [e.toString()];
    }
  }

  //删除存储桶
  static deleteBucket(Map element) async {
    try {
      String bucket = element['name'];
      String region = element['location'];

      String method = 'DELETE';
      String urlpath = '/$bucket/';

      String host = '$bucket.$region.aliyuncs.com';
      BaseOptions baseoptions = setBaseOptions();
      baseoptions.headers = {
        'Date': HttpDate.format(DateTime.now()),
        'content-type': 'application/json',
      };
      String authorization = await aliyunAuthorization(method, urlpath, baseoptions.headers, '', 'application/json');

      baseoptions.headers['Authorization'] = authorization;
      Dio dio = Dio(baseoptions);

      var response = await dio.delete('https://$host');

      if (response.statusCode == 204) {
        return ['success'];
      } else {
        return ['failed'];
      }
    } catch (e) {
      flogError(
          e,
          {
            'element': element,
          },
          "AliyunManageAPI",
          "deleteBucket");
      return [e.toString()];
    }
  }

  //更改存储桶权限
  static changeACLPolicy(Map element, String newACL) async {
    try {
      String bucket = element['name'];
      String region = element['location'];

      String method = 'PUT';
      String urlpath = '/$bucket/?acl';

      String host = '$bucket.$region.aliyuncs.com';
      BaseOptions baseoptions = setBaseOptions();
      Map<String, dynamic> header = {
        'Date': HttpDate.format(DateTime.now()),
        'x-oss-acl': newACL,
        'content-type': 'application/json',
      };
      String authorization = await aliyunAuthorization(method, urlpath, header, '', 'application/json');

      baseoptions.headers = header;
      baseoptions.headers['Authorization'] = authorization;
      Dio dio = Dio(baseoptions);

      var response = await dio.put('https://$host/?acl');
      if (response.statusCode == 200) {
        return ['success'];
      } else {
        return ['failed'];
      }
    } catch (e) {
      flogError(
          e,
          {
            'element': element,
            'newACL': newACL,
          },
          "AliyunManageAPI",
          "changeACLPolicy");
      return [e.toString()];
    }
  }

  //存储桶设为默认图床
  static setDefaultBucket(Map element, String? folder) async {
    try {
      Map configMap = await getConfigMap();
      String accessKeyId = configMap['keyId'];
      String accessKeySecret = configMap['keySecret'];
      String path = '';
      String customUrl = configMap['customUrl'];
      String options = configMap['options'];
      String area = element['location'];
      String bucket = element['name'];

      if (folder == null) {
        path = configMap['path'];
      } else {
        path = folder;
      }

      final aliyunConfig = AliyunConfigModel(accessKeyId, accessKeySecret, bucket, area, path, customUrl, options);
      final aliyunConfigJson = jsonEncode(aliyunConfig);
      final aliyunConfigFile = await localFile;
      await aliyunConfigFile.writeAsString(aliyunConfigJson);
      return ['success'];
    } catch (e) {
      FLog.error(
          className: "AliyunManageAPI",
          methodName: "setDefaultBucket",
          text: formatErrorMessage({
            'element': element,
            'folder': folder,
          }, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      return ['failed'];
    }
  }

  //查询存储桶文件列表
  static queryBucketFiles(Map element, Map<String, dynamic> query) async {
    try {
      String bucket = element['name'];
      String region = element['location'];

      String method = 'GET';
      String urlpath = '/$bucket/';

      String host = '$bucket.$region.aliyuncs.com';
      BaseOptions baseoptions = setBaseOptions();
      baseoptions.headers = {
        'Date': HttpDate.format(DateTime.now()),
      };
      query['max-keys'] = 1000;
      query['list-type'] = 2;
      String authorization = await aliyunAuthorization(method, urlpath, baseoptions.headers, '', '');
      baseoptions.headers['Authorization'] = authorization;

      Dio dio = Dio(baseoptions);

      String marker = '';
      var response = await dio.get('https://$host/', queryParameters: query);
      var responseBody = response.data;
      final myTransformer = Xml2Json();
      myTransformer.parse(responseBody);
      Map responseMap = json.decode(myTransformer.toParker());
      if (response.statusCode == 200) {
        if (responseMap['ListBucketResult']['IsTruncated'] == null ||
            responseMap['ListBucketResult']['IsTruncated'] == 'false') {
          return ['success', responseMap];
        } else {
          Map tempMap = Map.from(responseMap);
          while (tempMap['ListBucketResult']['IsTruncated'] == 'true') {
            marker = tempMap['ListBucketResult']['NextContinuationToken'];
            query['continuation-token'] = marker;
            urlpath = '/$bucket/?continuation-token=$marker';
            baseoptions.headers = {
              'Date': HttpDate.format(DateTime.now()),
            };
            String authorization = await aliyunAuthorization(method, urlpath, baseoptions.headers, '', '');
            baseoptions.headers['Authorization'] = authorization;

            dio = Dio(baseoptions);
            response = await dio.get('https://$host/', queryParameters: query);
            responseBody = response.data;
            myTransformer.parse(responseBody);
            tempMap.clear();
            tempMap = json.decode(myTransformer.toParker());
            if (response.statusCode == 200) {
              if (tempMap['ListBucketResult']['Contents'] != null) {
                if (tempMap['ListBucketResult']['Contents'] is! List) {
                  tempMap['ListBucketResult']['Contents'] = [tempMap['ListBucketResult']['Contents']];
                }
                if (responseMap['ListBucketResult']['Contents'] == null) {
                  responseMap['ListBucketResult']['Contents'] = tempMap['ListBucketResult']['Contents'];
                } else {
                  if (responseMap['ListBucketResult']['Contents'] is! List) {
                    responseMap['ListBucketResult']['Contents'] = [responseMap['ListBucketResult']['Contents']];
                  }
                  responseMap['ListBucketResult']['Contents'].addAll(tempMap['ListBucketResult']['Contents']);
                }
              }
              if (tempMap['ListBucketResult']['CommonPrefixes'] != null) {
                if (tempMap['ListBucketResult']['CommonPrefixes'] is! List) {
                  tempMap['ListBucketResult']['CommonPrefixes'] = [tempMap['ListBucketResult']['CommonPrefixes']];
                }
                if (responseMap['ListBucketResult']['CommonPrefixes'] == null) {
                  responseMap['ListBucketResult']['CommonPrefixes'] = tempMap['ListBucketResult']['CommonPrefixes'];
                } else {
                  if (responseMap['ListBucketResult']['CommonPrefixes'] is! List) {
                    responseMap['ListBucketResult']
                        ['CommonPrefixes'] = [responseMap['ListBucketResult']['CommonPrefixes']];
                  }
                  responseMap['ListBucketResult']['CommonPrefixes']
                      .addAll(tempMap['ListBucketResult']['CommonPrefixes']);
                }
              }
            } else {
              return ['failed'];
            }
          }
          return ['success', responseMap];
        }
      } else {
        return ['failed'];
      }
    } catch (e) {
      flogError(
          e,
          {
            'element': element,
            'query': query,
          },
          "AliyunManageAPI",
          "queryBucketFiles");
      return [e.toString()];
    }
  }

  //判断是否为空存储桶
  static isEmptyBucket(Map element) async {
    var queryResult = await queryBucketFiles(element, {});
    if (queryResult[0] == 'success') {
      if (queryResult[1]['ListBucketResult']['Contents'] == null &&
          queryResult[1]['ListBucketResult']['CommonPrefixes'] == null) {
        return ['empty'];
      } else {
        return ['notempty'];
      }
    } else {
      return ['error'];
    }
  }

  //重命名文件
  static copyFile(Map element, String key, String newKey) async {
    try {
      String bucket = element['name'];
      String region = element['location'];
      String method = 'PUT';
      String host = '$bucket.$region.aliyuncs.com';
      String newName = '';
      if (key.substring(0, key.lastIndexOf('/') + 1) == '') {
        newName = newKey;
      } else {
        newName = key.substring(0, key.lastIndexOf('/') + 1) + newKey;
      }

      String urlpath = '/$bucket/$newName';
      String xOssCopySource = '/$bucket/${Uri.encodeComponent(key)}';
      BaseOptions baseoptions = setBaseOptions();
      baseoptions.headers = {
        'Date': HttpDate.format(DateTime.now()),
        'x-oss-copy-source': xOssCopySource,
        'x-oss-forbid-overwrite': 'false',
        'Host': host,
        'content-type': 'application/json',
      };
      String authorization = await aliyunAuthorization(method, urlpath, baseoptions.headers, '', 'application/json');
      baseoptions.headers['Authorization'] = authorization;

      Dio dio = Dio(baseoptions);

      var response = await dio.put('https://$host/${Uri.encodeComponent(newName)}');
      if (response.statusCode == 200) {
        return ['success'];
      } else {
        return ['failed'];
      }
    } catch (e) {
      flogError(
          e,
          {
            'element': element,
            'key': key,
            'newKey': newKey,
          },
          "AliyunManageAPI",
          "copyFile");
      return [e.toString()];
    }
  }

  //删除文件
  static deleteFile(Map element, String key) async {
    try {
      String bucket = element['name'];
      String region = element['location'];
      String method = 'DELETE';
      String urlpath = '/$bucket/$key';
      String host = '$bucket.$region.aliyuncs.com';

      BaseOptions baseoptions = setBaseOptions();
      String contentMD5 = '';
      String contentType = 'application/json';
      baseoptions.headers = {
        'Date': HttpDate.format(DateTime.now()),
        'content-type': contentType,
      };

      String authorization = await aliyunAuthorization(method, urlpath, baseoptions.headers, contentMD5, contentType);

      baseoptions.headers['Authorization'] = authorization;
      Dio dio = Dio(baseoptions);

      var response = await dio.delete('https://$host/$key');
      if (response.statusCode == HttpStatus.noContent) {
        return ['success'];
      } else {
        return ['failed'];
      }
    } catch (e) {
      flogError(
          e,
          {
            'element': element,
            'key': key,
          },
          "AliyunManageAPI",
          "deleteFile");
      return [e.toString()];
    }
  }

  //删除文件夹
  static deleteFolder(Map element, String key) async {
    var queryResult = await queryBucketFiles(element, {
      'prefix': key,
      'delimiter': '/',
    });
    if (queryResult[0] == 'success') {
      if (queryResult[1]['ListBucketResult']['Contents'] != null) {
        var contents = queryResult[1]['ListBucketResult']['Contents'];
        if (contents is List) {
          for (var i = 0; i < contents.length; i++) {
            var deleteResult = await deleteFile(element, contents[i]['Key']);
            if (deleteResult[0] != 'success') {
              return ['failed'];
            }
          }
        } else {
          var deleteResult = await deleteFile(element, contents['Key']);
          if (deleteResult[0] != 'success') {
            return ['failed'];
          }
        }
      }
      if (queryResult[1]['ListBucketResult']['CommonPrefixes'] != null) {
        var commonPrefixes = queryResult[1]['ListBucketResult']['CommonPrefixes'];
        if (commonPrefixes is List) {
          for (var i = 0; i < commonPrefixes.length; i++) {
            var deleteResult = await deleteFolder(element, commonPrefixes[i]['Prefix']);
            if (deleteResult[0] != 'success') {
              return ['failed'];
            }
          }
        } else {
          var deleteResult = await deleteFolder(element, commonPrefixes['Prefix']);
          if (deleteResult[0] != 'success') {
            return ['failed'];
          }
        }
      }
      return ['success'];
    } else {
      return ['failed'];
    }
  }

  //查询是否有重名文件
  static queryDuplicateName(Map element, String? prefix, String key) async {
    var queryResult = await queryBucketFiles(element, {
      'prefix': prefix,
      'delimiter': '/',
    });

    if (queryResult[0] == 'success') {
      if (queryResult[1]['ListBucketResult']['Contents'] != null) {
        var contents = queryResult[1]['ListBucketResult']['Contents'];
        if (contents is List) {
          for (var i = 0; i < contents.length; i++) {
            if (contents[i]['Key'] == key) {
              return ['duplicate'];
            }
          }
        } else {
          if (contents['Key'] == key) {
            return ['duplicate'];
          }
        }
      }
      if (queryResult[1]['ListBucketResult']['CommonPrefixes'] != null) {
        var commonPrefixes = queryResult[1]['ListBucketResult']['CommonPrefixes'];
        if (commonPrefixes is List) {
          for (var i = 0; i < commonPrefixes.length; i++) {
            if (commonPrefixes[i]['Prefix'] == key) {
              return ['duplicate'];
            }
          }
        } else {
          if (commonPrefixes['Prefix'] == key) {
            return ['duplicate'];
          }
        }
      }
      return ['notduplicate'];
    } else {
      return ['error'];
    }
  }

  //新建文件夹
  static createFolder(Map element, String prefix, String newfolder) async {
    try {
      String bucket = element['name'];
      String region = element['location'];

      String method = 'PUT';

      String host = '$bucket.$region.aliyuncs.com';

      String urlpath = '/$bucket/$prefix$newfolder/';
      if (urlpath.substring(urlpath.length - 1) != '/') {
        urlpath = '$urlpath/';
      }
      BaseOptions baseoptions = setBaseOptions();
      String contentMD5 = '';
      String contentType = 'application/json';
      baseoptions.headers = {
        'Date': HttpDate.format(DateTime.now()),
        'content-type': contentType,
        'content-length': '0',
        'Host': host,
      };
      String authorization = await aliyunAuthorization(method, urlpath, baseoptions.headers, contentMD5, contentType);

      baseoptions.headers['Authorization'] = authorization;
      Dio dio = Dio(baseoptions);

      String url = 'https://$host/$prefix$newfolder';
      if (url.substring(url.length - 1) != '/') {
        url = '$url/';
      }
      var response = await dio.put(url);
      if (response.statusCode == 200) {
        return ['success'];
      } else {
        return ['failed'];
      }
    } catch (e) {
      flogError(
          e,
          {
            'element': element,
            'prefix': prefix,
            'newfolder': newfolder,
          },
          "AliyunManageAPI",
          "createFolder");
      return [e.toString()];
    }
  }

  //上传文件
  static uploadFile(
    Map element,
    String filename,
    String filepath,
    String prefix,
  ) async {
    try {
      Map configMap = await getConfigMap();
      String bucket = element['name'];
      String region = element['location'];

      String keyId = configMap['keyId'];
      String keySecret = configMap['keySecret'];
      String host = '$bucket.$region.aliyuncs.com';
      //不要加/，否则会导致签名错误
      String urlpath = '$prefix$filename';
      //上传策略
      Map<String, dynamic> uploadPolicy = {
        "expiration": "2034-12-01T12:00:00.000Z",
        "conditions": [
          {"bucket": bucket},
          ["content-length-range", 0, 104857600],
          {"key": urlpath}
        ]
      };
      String base64Policy = base64.encode(utf8.encode(json.encode(uploadPolicy)));
      String singature = base64.encode(Hmac(sha1, utf8.encode(keySecret)).convert(utf8.encode(base64Policy)).bytes);

      Map<String, dynamic> formMap = {
        'key': urlpath,
        'OSSAccessKeyId': keyId,
        'policy': base64Policy,
        'Signature': singature,
        'file': await MultipartFile.fromFile(filepath, filename: filename),
      };
      formMap['x-oss-content-type'] = getContentType(my_path.extension(filepath));
      FormData formData = FormData.fromMap(formMap);

      BaseOptions baseoptions = setBaseOptions();
      File uploadFile = File(filepath);
      String contentLength = await uploadFile.length().then((value) {
        return value.toString();
      });
      baseoptions.headers = {
        'Host': host,
        'Content-Type': Global.multipartString,
        'Content-Length': contentLength,
      };
      Dio dio = Dio(baseoptions);

      var response = await dio.post(
        'https://$host',
        data: formData,
      );
      if (response.statusCode == 204) {
        return ['success'];
      } else {
        return ['failed'];
      }
    } catch (e) {
      flogError(
          e,
          {
            'element': element,
            'filename': filename,
            'filepath': filepath,
            'prefix': prefix,
          },
          "AliyunManageAPI",
          "uploadFile");
      return ['error'];
    }
  }

  //上传文件API入口
  static upLoadFileEntry(List fileList, Map element, String prefix) async {
    int successCount = 0;
    int failCount = 0;

    for (File fileToTread in fileList) {
      String path = fileToTread.path;
      var name = path.substring(path.lastIndexOf("/") + 1, path.length);

      var uploadResult = await uploadFile(
        element,
        name,
        path,
        prefix,
      );
      if (uploadResult[0] == "Error") {
        return Fluttertoast.showToast(
            msg: '配置错误', toastLength: Toast.LENGTH_SHORT, timeInSecForIosWeb: 2, fontSize: 16.0);
      } else if (uploadResult[0] == "success") {
        successCount++;
      } else {
        failCount++;
      }
    }

    if (successCount == 0) {
      return Fluttertoast.showToast(
          msg: '上传失败', toastLength: Toast.LENGTH_SHORT, timeInSecForIosWeb: 2, fontSize: 16.0);
    } else if (failCount == 0) {
      return Fluttertoast.showToast(
          msg: '上传成功', toastLength: Toast.LENGTH_SHORT, timeInSecForIosWeb: 2, fontSize: 16.0);
    } else {
      return Fluttertoast.showToast(
          msg: '成功$successCount,失败$failCount', toastLength: Toast.LENGTH_SHORT, timeInSecForIosWeb: 2, fontSize: 16.0);
    }
  }

  //从网络链接下载文件后上传
  static uploadNetworkFile(String fileLink, Map element, String prefix) async {
    try {
      String filename = fileLink.substring(fileLink.lastIndexOf("/") + 1, fileLink.length);
      filename = filename.substring(0, !filename.contains("?") ? filename.length : filename.indexOf("?"));
      String savePath = await getTemporaryDirectory().then((value) {
        return value.path;
      });
      String saveFilePath = '$savePath/$filename';
      Dio dio = Dio();
      Response response = await dio.download(fileLink, saveFilePath);
      if (response.statusCode == 200) {
        var uploadResult = await uploadFile(
          element,
          filename,
          saveFilePath,
          prefix,
        );
        if (uploadResult[0] == "success") {
          return ['success'];
        } else {
          return ['failed'];
        }
      } else {
        return ['failed'];
      }
    } catch (e) {
      flogError(
          e, {'fileLink': fileLink, 'element': element, 'prefix': prefix}, "AliyunManageAPI", "uploadNetworkFile");
      return ['failed'];
    }
  }

  static uploadNetworkFileEntry(List fileList, Map element, String prefix) async {
    int successCount = 0;
    int failCount = 0;

    for (String fileLink in fileList) {
      if (fileLink.isEmpty) {
        continue;
      }
      var uploadResult = await uploadNetworkFile(fileLink, element, prefix);
      if (uploadResult[0] == "success") {
        successCount++;
      } else {
        failCount++;
      }
    }

    if (successCount == 0) {
      return Fluttertoast.showToast(
          msg: '上传失败', toastLength: Toast.LENGTH_SHORT, timeInSecForIosWeb: 2, fontSize: 16.0);
    } else if (failCount == 0) {
      return Fluttertoast.showToast(
          msg: '上传成功', toastLength: Toast.LENGTH_SHORT, timeInSecForIosWeb: 2, fontSize: 16.0);
    } else {
      return Fluttertoast.showToast(
          msg: '成功$successCount,失败$failCount', toastLength: Toast.LENGTH_SHORT, timeInSecForIosWeb: 2, fontSize: 16.0);
    }
  }
}
