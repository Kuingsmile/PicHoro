// ignore_for_file: unnecessary_brace_in_string_interps
import 'dart:io';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:crypto/crypto.dart';
import 'package:xml2json/xml2json.dart';
import 'package:path_provider/path_provider.dart';

import 'package:horopic/utils/global.dart';
import 'package:horopic/utils/sql_utils.dart';
import 'package:horopic/picture_host_configure/tencent_configure.dart';
import 'package:horopic/api/tencent_api.dart';

class TencentManageAPI {
  static Map<String, String> areaCodeName = {
    'ap-beijing-1': '北京一区',
    'ap-beijing': '北京',
    'ap-nanjing': '南京',
    'ap-shanghai': '上海',
    'ap-guangzhou': '广州',
    'ap-chengdu': '成都',
    'ap-chongqing': '重庆',
    'ap-shenzhen-fsi': '深圳金融',
    'ap-shagnhai-fsi': '上海金融',
    'ap-beijing-fsi': '北京金融',
    'ap-hongkong': '香港',
    'ap-singapore': '新加坡',
    'ap-mumbai': '孟买',
    'ap-jakarta': '雅加达',
    'ap-seoul': '首尔',
    'ap-bangkok': '曼谷',
    'ap-tokyo': '东京',
    'na-siliconvalley': '硅谷(美西)',
    'na-ashburn': '弗吉尼亚(美东)',
    'na-toronto': '多伦多',
    'sa-saopaulo': '圣保罗',
    'eu-frankfurt': '法兰克福',
    'eu-moscow': '莫斯科',
  };

  static Future<File> get _localFile async {
    final path = await _localPath;
    String defaultUser = await Global.getUser();
    return File('$path/${defaultUser}_tencent_config.txt');
  }

  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<String> readTencentConfig() async {
    try {
      final file = await _localFile;
      String contents = await file.readAsString();
      return contents;
    } catch (e) {
      return "Error";
    }
  }

  static Future<Map> getConfigMap() async {
    String configStr = await readTencentConfig();
    Map configMap = json.decode(configStr);
    return configMap;
  }

  //authorization
  static String tecentAuthorization(String method, String urlpath, Map header,
      String secretId, String secretKey, Map? urlParam) {
    int startTimestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    int endTimestamp = startTimestamp + 86400;
    String keyTime = '$startTimestamp;$endTimestamp';

    String signKey = Hmac(sha1, utf8.encode(secretKey))
        .convert(utf8.encode(keyTime))
        .toString();
    String lowerMethod = method.toLowerCase();

    String urlParamList = '';
    String httpParameters = '';

    if (urlParam != null && urlParam.isNotEmpty) {
      Map uriEncodeUrlParam = {};
      urlParam.forEach((key, value) {
        uriEncodeUrlParam[Uri.encodeComponent(key).toLowerCase()] =
            Uri.encodeComponent(value);
      });

      List urlParamKeyList = uriEncodeUrlParam.keys.toList();
      urlParamKeyList.sort();

      for (var i = 0; i < urlParamKeyList.length; i++) {
        urlParamList = '${urlParamList + urlParamKeyList[i]};';
        httpParameters =
            '${httpParameters + urlParamKeyList[i]}=${uriEncodeUrlParam[urlParamKeyList[i]]}&';
      }
      if (httpParameters.isNotEmpty) {
        httpParameters = httpParameters.substring(0, httpParameters.length - 1);
      }
      if (urlParamList.isNotEmpty) {
        urlParamList = urlParamList.substring(0, urlParamList.length - 1);
      }
    }

    String headerList = '';
    String httpHeaders = '';
    Map uriEncodeHeader = {};
    header.forEach((key, value) {
      uriEncodeHeader[Uri.encodeComponent(key).toLowerCase()] =
          Uri.encodeComponent(value);
    });
    List headerKeyList = uriEncodeHeader.keys.toList();
    headerKeyList.sort();
    for (var i = 0; i < headerKeyList.length; i++) {
      headerList = '${headerList + headerKeyList[i]};';
      httpHeaders =
          '${httpHeaders + headerKeyList[i]}=${uriEncodeHeader[headerKeyList[i]]}&';
    }
    if (httpHeaders.isNotEmpty) {
      httpHeaders = httpHeaders.substring(0, httpHeaders.length - 1);
    }
    if (headerList.isNotEmpty) {
      headerList = headerList.substring(0, headerList.length - 1);
    }

    String httpString =
        '$lowerMethod\n$urlpath\n$httpParameters\n$httpHeaders\n';
    String stringtosign =
        'sha1\n$keyTime\n${sha1.convert(utf8.encode(httpString)).toString()}\n';

    String signature = Hmac(sha1, utf8.encode(signKey))
        .convert(utf8.encode(stringtosign))
        .toString();
    String authorization =
        'q-sign-algorithm=sha1&q-ak=$secretId&q-sign-time=$keyTime&q-key-time=$keyTime&q-header-list=$headerList&q-url-param-list=$urlParamList&q-signature=$signature';
    return authorization;
  }

  //获取存储桶列表
  static getBucketList() async {
    Map configMap = await getConfigMap();
    String method = 'GET';
    String urlpath = '/';
    String secretId = configMap['secretId'];
    String secretKey = configMap['secretKey'];

    String host = 'service.cos.myqcloud.com';

    Map header = {
      'Host': 'service.cos.myqcloud.com',
    };

    String authorization =
        tecentAuthorization(method, urlpath, header, secretId, secretKey, {});

    BaseOptions baseoptions = BaseOptions(
      sendTimeout: 30000,
      receiveTimeout: 30000,
      connectTimeout: 30000,
    );
    baseoptions.headers = {
      'Authorization': authorization,
      'Host': host,
    };
    Dio dio = Dio(baseoptions);
    try {
      var response = await dio.get('https://$host');
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
      return [e.toString()];
    }
  }

  //新建存储桶
  static createBucket(Map newBucketConfigMap) async {
    Map configMap = await getConfigMap();
    String appId = configMap['appId'];
    String bucket = newBucketConfigMap['bucketName'];
    String region = newBucketConfigMap['region'];
    bool multiAZ = newBucketConfigMap['multiAZ'];
    String xCosACL = newBucketConfigMap['xCosACL'];

    if (multiAZ == true &&
        (region != 'ap-beijing' && region != 'ap-guangzhou') &&
        (region != 'ap-shanghai' && region != 'ap-singapore')) {
      return [
        'multiAZ error',
      ];
    }
    var body =
        '<CreateBucketConfiguration><BucketAZConfig>MAZ</BucketAZConfig></CreateBucketConfiguration>';
    var bodyMd5 = md5.convert(utf8.encode(body));
    String base64BodyMd5 = base64.encode(bodyMd5.bytes);
    if (!bucket.endsWith('-appId')) {
      bucket = '$bucket-$appId';
    }

    String method = 'PUT';
    String urlpath = '/';
    String secretId = configMap['secretId'];
    String secretKey = configMap['secretKey'];
    String host = '$bucket.cos.$region.myqcloud.com';
    Map<String, dynamic> header = {
      'Host': host,
      'x-cos-acl': xCosACL,
    };

    if (multiAZ == true) {
      header['content-type'] = 'application/xml';
      header['content-length'] = body.length.toString();
      header['content-md5'] = base64BodyMd5;
    }

    String authorization =
        tecentAuthorization(method, urlpath, header, secretId, secretKey, {});

    BaseOptions baseoptions = BaseOptions(
      sendTimeout: 30000,
      receiveTimeout: 30000,
      connectTimeout: 30000,
    );
    baseoptions.headers = header;
    baseoptions.headers['Authorization'] = authorization;
    Dio dio = Dio(baseoptions);
    try {
      Response response;
      if (multiAZ == true) {
        response = await dio.put('https://$host', data: body);
      } else {
        response = await dio.put('https://$host');
      }

      if (response.statusCode == 200) {
        return ['success'];
      } else {
        return ['failed'];
      }
    } catch (e) {
      return [e.toString()];
    }
  }

  //删除存储桶
  static deleteBucket(Map element) async {
    Map configMap = await getConfigMap();
    String bucket = element['name'];
    String region = element['location'];

    String method = 'DELETE';
    String urlpath = '/';
    String secretId = configMap['secretId'];
    String secretKey = configMap['secretKey'];
    String host = '$bucket.cos.$region.myqcloud.com';
    Map<String, dynamic> header = {
      'Host': host,
    };
    String authorization =
        tecentAuthorization(method, urlpath, header, secretId, secretKey, {});

    BaseOptions baseoptions = BaseOptions(
      sendTimeout: 30000,
      receiveTimeout: 30000,
      connectTimeout: 30000,
    );
    baseoptions.headers = header;
    baseoptions.headers['Authorization'] = authorization;
    Dio dio = Dio(baseoptions);
    try {
      var response = await dio.delete('https://$host');

      if (response.statusCode == 204) {
        return ['success'];
      } else {
        return ['failed'];
      }
    } catch (e) {
      return [e.toString()];
    }
  }

  //查询存储桶权限
  static queryACLPolicy(Map element) async {
    Map configMap = await getConfigMap();
    String bucket = element['name'];
    String region = element['location'];

    String method = 'GET';
    String urlpath = '/';
    String secretId = configMap['secretId'];
    String secretKey = configMap['secretKey'];
    String host = '$bucket.cos.$region.myqcloud.com';
    Map<String, dynamic> header = {
      'Host': host,
    };
    String authorization = tecentAuthorization(
        method, urlpath, header, secretId, secretKey, {'acl': ''});

    BaseOptions baseoptions = BaseOptions(
      sendTimeout: 30000,
      receiveTimeout: 30000,
      connectTimeout: 30000,
    );
    baseoptions.headers = header;
    baseoptions.headers['Authorization'] = authorization;
    Dio dio = Dio(baseoptions);

    try {
      var response = await dio.get('https://$host/?acl');
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
      return [e.toString()];
    }
  }

  //更改存储桶权限
  static changeACLPolicy(Map element, String newACL) async {
    Map configMap = await getConfigMap();
    String bucket = element['name'];
    String region = element['location'];

    String method = 'PUT';
    String urlpath = '/';
    String secretId = configMap['secretId'];
    String secretKey = configMap['secretKey'];
    String host = '$bucket.cos.$region.myqcloud.com';
    Map<String, dynamic> header = {
      'Host': host,
      'x-cos-acl': newACL,
    };
    String authorization = tecentAuthorization(
        method, urlpath, header, secretId, secretKey, {'acl': ''});

    BaseOptions baseoptions = BaseOptions(
      sendTimeout: 30000,
      receiveTimeout: 30000,
      connectTimeout: 30000,
    );
    baseoptions.headers = header;
    baseoptions.headers['Authorization'] = authorization;
    Dio dio = Dio(baseoptions);

    try {
      var response = await dio.put('https://$host/?acl');
      if (response.statusCode == 200) {
        return ['success'];
      } else {
        return ['failed'];
      }
    } catch (e) {
      return [e.toString()];
    }
  }

  //存储桶设为默认图床
  static setDefaultBucket(Map element, String? folder) async {
    try {
      Map configMap = await getConfigMap();
      String secretId = configMap['secretId'];
      String secretKey = configMap['secretKey'];
      String appId = configMap['appId'];
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
      List sqlconfig = [];
      sqlconfig.add(secretId);
      sqlconfig.add(secretKey);
      sqlconfig.add(bucket);
      sqlconfig.add(appId);
      sqlconfig.add(area);
      sqlconfig.add(path);
      sqlconfig.add(customUrl);
      sqlconfig.add(options);
      String defaultUser = await Global.getUser();
      sqlconfig.add(defaultUser);
      var queryTencent = await MySqlUtils.queryTencent(username: defaultUser);
      var queryuser = await MySqlUtils.queryUser(username: defaultUser);

      if (queryuser == 'Empty') {
        return ['failed'];
      }
      var sqlResult = '';

      if (queryTencent == 'Empty') {
        sqlResult = await MySqlUtils.insertTencent(content: sqlconfig);
      } else {
        sqlResult = await MySqlUtils.updateTencent(content: sqlconfig);
      }

      if (sqlResult == "Success") {
        final tencentConfig = TencentConfigModel(
            secretId, secretKey, bucket, appId, area, path, customUrl, options);
        final tencentConfigJson = jsonEncode(tencentConfig);
        final tencentConfigFile = await _localFile;
        await tencentConfigFile.writeAsString(tencentConfigJson);
        return ['success'];
      } else {
        return ['failed'];
      }
    } catch (e) {
      return ['failed'];
    }
  }

  //查询存储桶文件列表
  static queryBucketFiles(Map element, Map<String, dynamic> query) async {
    Map configMap = await getConfigMap();
    String bucket = element['name'];
    String region = element['location'];

    String method = 'GET';
    String urlpath = '/';
    String secretId = configMap['secretId'];
    String secretKey = configMap['secretKey'];
    String host = '$bucket.cos.$region.myqcloud.com';
    Map<String, dynamic> header = {
      'Host': host,
    };
    String authorization = tecentAuthorization(
        method, urlpath, header, secretId, secretKey, query);

    BaseOptions baseoptions = BaseOptions(
      sendTimeout: 30000,
      receiveTimeout: 30000,
      connectTimeout: 30000,
    );
    baseoptions.headers = header;
    baseoptions.headers['Authorization'] = authorization;
    Dio dio = Dio(baseoptions);

    try {
      var response = await dio.get('https://$host', queryParameters: query);
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

  //删除文件
  static deleteFile(Map element, String key) async {
    Map configMap = await getConfigMap();
    String bucket = element['name'];
    String region = element['location'];

    String method = 'DELETE';
    String urlpath = '/$key';
    String secretId = configMap['secretId'];
    String secretKey = configMap['secretKey'];
    String host = '$bucket.cos.$region.myqcloud.com';
    Map<String, dynamic> header = {
      'Host': host,
    };
    String authorization =
        tecentAuthorization(method, urlpath, header, secretId, secretKey, {});

    BaseOptions baseoptions = BaseOptions(
      sendTimeout: 30000,
      receiveTimeout: 30000,
      connectTimeout: 30000,
    );
    baseoptions.headers = header;
    baseoptions.headers['Authorization'] = authorization;
    Dio dio = Dio(baseoptions);

    try {
      var response = await dio.delete('https://$host/$key');
      if (response.statusCode == 204) {
        return ['success'];
      } else {
        return ['failed'];
      }
    } catch (e) {
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
        var commonPrefixes =
            queryResult[1]['ListBucketResult']['CommonPrefixes'];
        if (commonPrefixes is List) {
          for (var i = 0; i < commonPrefixes.length; i++) {
            var deleteResult =
                await deleteFolder(element, commonPrefixes[i]['Prefix']);
            if (deleteResult[0] != 'success') {
              return ['failed'];
            }
          }
        } else {
          var deleteResult =
              await deleteFolder(element, commonPrefixes['Prefix']);
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

  //重命名文件
  static copyFile(Map element, String key, String newKey) async {
    Map configMap = await getConfigMap();
    String bucket = element['name'];
    String region = element['location'];

    String method = 'PUT';

    String secretId = configMap['secretId'];
    String secretKey = configMap['secretKey'];
    String host = '$bucket.cos.$region.myqcloud.com';
    String newName = '';
    if (key.substring(0, key.lastIndexOf('/') + 1) == '') {
      newName = newKey;
    } else {
      newName = key.substring(0, key.lastIndexOf('/') + 1) + newKey;
    }
    String urlpath = '/$newName';
    String xCosCopySource =
        '/$bucket.cos.$region.myqcloud.com/${Uri.encodeComponent(key)}';

    Map<String, dynamic> header = {
      'Host': host,
      'x-cos-copy-source': xCosCopySource,
    };
    String authorization =
        tecentAuthorization(method, urlpath, header, secretId, secretKey, {});

    BaseOptions baseoptions = BaseOptions(
      sendTimeout: 30000,
      receiveTimeout: 30000,
      connectTimeout: 30000,
    );
    baseoptions.headers = header;
    baseoptions.headers['Authorization'] = authorization;
    Dio dio = Dio(baseoptions);

    try {
      var response = await dio.put('https://$host/$newName');
      if (response.statusCode == 200) {
        return ['success'];
      } else {
        return ['failed'];
      }
    } catch (e) {
      return [e.toString()];
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
        var commonPrefixes =
            queryResult[1]['ListBucketResult']['CommonPrefixes'];
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

  //下载文件
  static downloadFile(Map element, String key, String path) async {
    Map configMap = await getConfigMap();
    String bucket = element['name'];
    String region = element['location'];

    String method = 'GET';

    String secretId = configMap['secretId'];
    String secretKey = configMap['secretKey'];
    String host = '$bucket.cos.$region.myqcloud.com';

    String urlpath = '/$key';

    Map<String, dynamic> header = {
      'Host': host,
    };
    String authorization =
        tecentAuthorization(method, urlpath, header, secretId, secretKey, {});

    BaseOptions baseoptions = BaseOptions(
      sendTimeout: 30000,
      receiveTimeout: 30000,
      connectTimeout: 30000,
    );
    baseoptions.headers = header;
    baseoptions.headers['Authorization'] = authorization;
    Dio dio = Dio(baseoptions);
    try {
      Response response = await dio.download('https://$host/$key', path);
      if (response.statusCode == 200) {
        return ['success'];
      } else {
        return ['failed'];
      }
    } catch (e) {
      return [e.toString()];
    }
  }

  //新建文件夹
  static createFolder(Map element, String prefix, String newfolder) async {
    Map configMap = await getConfigMap();
    String bucket = element['name'];
    String region = element['location'];

    String method = 'PUT';

    String secretId = configMap['secretId'];
    String secretKey = configMap['secretKey'];
    String host = '$bucket.cos.$region.myqcloud.com';

    String urlpath = '/$prefix$newfolder';
    if (urlpath.substring(urlpath.length - 1) != '/') {
      urlpath = '$urlpath/';
    }

    Map<String, dynamic> header = {
      'Host': host,
    };
    String authorization =
        tecentAuthorization(method, urlpath, header, secretId, secretKey, {});

    BaseOptions baseoptions = BaseOptions(
      sendTimeout: 30000,
      receiveTimeout: 30000,
      connectTimeout: 30000,
    );
    baseoptions.headers = header;
    baseoptions.headers['Authorization'] = authorization;
    Dio dio = Dio(baseoptions);
    try {
      var response = await dio.put('https://$host$urlpath');
      if (response.statusCode == 200) {
        return ['success'];
      } else {
        return ['failed'];
      }
    } catch (e) {
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
    Map configMap = await getConfigMap();
    String bucket = element['name'];
    String region = element['location'];

    String secretId = configMap['secretId'];
    String secretKey = configMap['secretKey'];
    String host = '$bucket.cos.$region.myqcloud.com';

    String urlpath = '/$prefix$filename';
    //上传策略
    int startTimestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    int endTimestamp = startTimestamp + 86400;
    String keyTime = '$startTimestamp;$endTimestamp';
    Map<String, dynamic> uploadPolicy = {
      "expiration": "2033-03-03T09:38:12.414Z",
      "conditions": [
        {"acl": "default"},
        {"bucket": bucket},
        {"key": urlpath},
        {"q-sign-algorithm": "sha1"},
        {"q-ak": secretId},
        {"q-sign-time": keyTime}
      ]
    };
    String uploadPolicyStr = jsonEncode(uploadPolicy);
    String singature = TencentImageUploadUtils.getUploadAuthorization(
        secretKey, keyTime, uploadPolicyStr);
    FormData formData = FormData.fromMap({
      'key': urlpath,
      'policy': base64Encode(utf8.encode(uploadPolicyStr)),
      'acl': 'default',
      'q-sign-algorithm': 'sha1',
      'q-ak': secretId,
      'q-key-time': keyTime,
      'q-sign-time': keyTime,
      'q-signature': singature,
      'file': await MultipartFile.fromFile(filepath, filename: filename),
    });

    BaseOptions baseoptions = BaseOptions(
      sendTimeout: 30000,
      receiveTimeout: 30000,
      connectTimeout: 30000,
    );
    File uploadFile = File(filepath);
    String contentLength = await uploadFile.length().then((value) {
      return value.toString();
    });
    baseoptions.headers = {
      'Host': host,
      'Content-Type':
          'multipart/form-data; boundary=----WebKitFormBoundary7MA4YWxkTrZu0gW',
      'Content-Length': contentLength,
    };
    Dio dio = Dio(baseoptions);
    try {
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
            msg: '配置错误',
            toastLength: Toast.LENGTH_SHORT,
            timeInSecForIosWeb: 2,
            fontSize: 16.0);
      } else if (uploadResult[0] == "success") {
        successCount++;
      } else {
        failCount++;
      }
    }

    if (successCount == 0) {
      return Fluttertoast.showToast(
          msg: '上传失败',
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 2,
          fontSize: 16.0);
    } else if (failCount == 0) {
      return Fluttertoast.showToast(
          msg: '上传成功',
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 2,
          fontSize: 16.0);
    } else {
      return Fluttertoast.showToast(
          msg: '成功$successCount,失败$failCount',
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 2,
          fontSize: 16.0);
    }
  }

  //从网络链接下载文件后上传
  static uploadNetworkFile(String fileLink, Map element, String prefix) async {
    try {
      String filename =
          fileLink.substring(fileLink.lastIndexOf("/") + 1, fileLink.length);
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
      return ['failed'];
    }
  }

  static uploadNetworkFileEntry(
      List fileList, Map element, String prefix) async {
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
          msg: '上传失败',
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 2,
          fontSize: 16.0);
    } else if (failCount == 0) {
      return Fluttertoast.showToast(
          msg: '上传成功',
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 2,
          fontSize: 16.0);
    } else {
      return Fluttertoast.showToast(
          msg: '成功$successCount,失败$failCount',
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 2,
          fontSize: 16.0);
    }
  }
}
