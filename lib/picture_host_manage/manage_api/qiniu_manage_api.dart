import 'dart:io';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:f_logs/f_logs.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as my_path;
import 'package:xml2json/xml2json.dart';
import 'package:qiniu_flutter_sdk/qiniu_flutter_sdk.dart';

import 'package:horopic/utils/global.dart';
import 'package:horopic/utils/sql_utils.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/api/qiniu_api.dart';
import 'package:horopic/picture_host_configure/qiniu_configure.dart';

class QiniuManageAPI {
  static Map<String, String> areaUploadCodeName = {
    'z0': 'https://upload.qiniup.com', //华东
    'cn-east-2': 'https://upload-cn-east-2.qiniup.com', //华东 浙江2
    'z1': 'https://upload-z1.qiniup.com', //华北
    'z2': 'https://upload-z2.qiniup.com', //华南
    'na0': 'https://upload-na0.qiniup.com', //北美
    'as0': 'https://upload-as0.qiniup.com', //东南亚
    'ap-northeast-1': 'https://upload-ap-northeast-1.qiniup.com', //亚太首尔
  };

  static Map<String, String> areaCodeName = {
    'z0': '华东-浙江',
    'cn-east-2': '华东 浙江2',
    'z1': '华北-河北',
    'z2': '华南-广东',
    'na0': '北美-洛杉矶',
    'as0': '亚太-新加坡',
    'ap-northeast-1': '亚太-首尔',
  };

  static Future<File> get _localFile async {
    final path = await _localPath;
    String defaultUser = await Global.getUser();
    return File('$path/${defaultUser}_qiniu_config.txt');
  }

  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<String> readQiniuConfig() async {
    try {
      final file = await _localFile;
      String contents = await file.readAsString();
      return contents;
    } catch (e) {
      FLog.error(
          className: 'QiniuManageAPI',
          methodName: 'readQiniuConfig',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      return "Error";
    }
  }

  static Future<Map> getConfigMap() async {
    String configStr = await readQiniuConfig();
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

  //url安全的base64编码
  static String urlSafeBase64Encode(List<int> bytes) {
    String base64 = base64Encode(bytes);
    return base64.replaceAll('+', '-').replaceAll('/', '_');
  }

  //url安全的base64编码的上传策略
  static String geturlSafeBase64EncodePutPolicy(
      String bucket, String key, String path) {
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
  static String getUploadToken(
      String accessKey, String secretKey, String urlSafeBase64EncodePutPolicy) {
    var hmacSha1 = Hmac(sha1, utf8.encode(secretKey));
    var sign = hmacSha1.convert(utf8.encode(urlSafeBase64EncodePutPolicy));
    String encodedSign = urlSafeBase64Encode(sign.bytes);
    return '$accessKey:$encodedSign:$urlSafeBase64EncodePutPolicy';
  }

  /*signingStr=req.Method（HTTP协议的Method是大小写敏感的） + " "（空格） +req.Path
如果query为非空字符串(query不包含问号(?)字符)
signingStr=req.Method + " "（空格） +req.Path+?(英文问号)+req.query

接下来增加Host信息
signingStr=signingStr+\n(换行符)Host:(英文符号冒号) （空格）+req.Host

如果您设置了Content-Type的 Header,也需要添加
signingStr=signingStr+\n(换行符)Content-Type:(英文符号冒号) (空格)+req.Content-Type

对于七牛特殊的X-Qiniu-<key>头信息，如果有也需要添加， ”X-Qiniu-<key>“header是指在请求Header中以“X-Qiniu-”字符串开头的头部信息对,为七牛服务端理解。其中key不可为空字符。在生成签名算法中对key有一定的格式转换要求，第一个字母和连字符（-）后面的字母大写，其余字母都是小写。满足以上条件的键值对，根据<key>字符串 ASCII大小排序后，由小到大，依次加入待签名字符串
signingStr=signingStr+\n(换行符)+<key1>:(英文符号冒号) (空格)+<value1>+\n(换行符)+<key2>:(英文符号冒号) (空格)+<value2>+...

完成以上信息之后加入2个连续对换行符
signingStr=signingStr+\n(换行符)+\n(换行符)

如果您设置了请求Body，并且设置Content-Type不为"application/octet-stream"类型，Body也需要加入待签名字符串
signingStr=signingStr+<body>
*/
  //get authorization
  static Future<String> qiniuAuthorization(
      String method,
      String path,
      String? query,
      String host,
      String? contentType,
      Map? xQiniuHeaders,
      String body,
      String accessKey,
      String secretKey) async {
    try {
      var signStr = '${method.toUpperCase()} $path';

      if (query != null && query.isNotEmpty) {
        signStr += '?$query';
      }
      signStr += '\nHost: $host';
      if (contentType != null && contentType.isNotEmpty) {
        signStr += '\nContent-Type: $contentType';
      }
      //添加xQiniuHeaders
      String xQiniuHeadersStr = '';
      if (xQiniuHeaders != null && xQiniuHeaders.isNotEmpty) {
        List xQiniuHeadersKeys = xQiniuHeaders.keys.toList();
        xQiniuHeadersKeys.sort();
        for (var key in xQiniuHeadersKeys) {
          xQiniuHeadersStr += '\n$key: ${xQiniuHeaders[key]}';
        }
        signStr += xQiniuHeadersStr;
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
    } catch (e) {
      FLog.error(
          className: 'QiniuManageAPI',
          methodName: 'QiniuAuthorization',
          text: formatErrorMessage({
            'method': method,
            'path': path,
            'query': query,
            'host': host,
            'contentType': contentType,
            'body': body,
          }, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      return "";
    }
  }

  //获取存储桶名字列表
  static getBucketNameList() async {
    Map configMap = await getConfigMap();
    String method = 'GET';
    String urlpath = '/buckets';
    String accessKey = configMap['accessKey'];
    String secretKey = configMap['secretKey'];
    String host = 'uc.qbox.me';

    String authorization = await qiniuAuthorization(
        method, urlpath, null, host, null, null, '', accessKey, secretKey);
    authorization = 'Qiniu $authorization';
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
      var response = await dio.get('https://$host/buckets');
      if (response.statusCode == 200) {
        return ['success', response.data];
      } else {
        return ['failed'];
      }
    } catch (e) {
      if (e is DioError) {
        FLog.error(
            className: "QiniuManageAPI",
            methodName: "getBucketList",
            text: formatErrorMessage({}, e.toString(),
                isDioError: true, dioErrorMessage: e),
            dataLogType: DataLogType.ERRORS.toString());
      } else {
        FLog.error(
            className: "QiniuManageAPI",
            methodName: "getBucketList",
            text: formatErrorMessage({}, e.toString()),
            dataLogType: DataLogType.ERRORS.toString());
      }
      return [e.toString()];
    }
  }

  //新建存储桶
  static createBucket(Map newBucketConfigMap) async {
    Map configMap = await getConfigMap();
    String bucket = newBucketConfigMap['bucketName'];
    String region = newBucketConfigMap['region'];

    String method = 'POST';
    String urlpath = '/mkbucketv3/$bucket/region/$region';
    String accessKey = configMap['accessKey'];
    String secretKey = configMap['secretKey'];
    String host = 'uc.qbox.me';

    String authorization = await qiniuAuthorization(method, urlpath, null, host,
        'application/json', null, '', accessKey, secretKey);

    BaseOptions baseoptions = BaseOptions(
      sendTimeout: 30000,
      receiveTimeout: 30000,
      connectTimeout: 30000,
    );
    baseoptions.headers = {
      'Authorization': 'Qiniu $authorization',
      'Host': host,
      'Content-Type': 'application/json',
    };

    Dio dio = Dio(baseoptions);
    try {
      var response = await dio.post(
        'https://$host$urlpath',
      );

      if (response.statusCode == 200) {
        return ['success'];
      } else {
        return ['failed'];
      }
    } catch (e) {
      if (e is DioError) {
        FLog.error(
            className: "QiniuManageAPI",
            methodName: "createBucket",
            text: formatErrorMessage(
                {'newBucketConfigMap': newBucketConfigMap}, e.toString(),
                isDioError: true, dioErrorMessage: e),
            dataLogType: DataLogType.ERRORS.toString());
      } else {
        FLog.error(
            className: "QiniuManageAPI",
            methodName: "createBucket",
            text: formatErrorMessage(
                {'newBucketConfigMap': newBucketConfigMap}, e.toString()),
            dataLogType: DataLogType.ERRORS.toString());
      }
      return [e.toString()];
    }
  }

  //删除存储桶
  static deleteBucket(Map element) async {
    Map configMap = await getConfigMap();
    String bucket = element['name'];

    String method = 'POST';
    String urlpath = '/drop/$bucket';
    String accessKey = configMap['accessKey'];
    String secretKey = configMap['secretKey'];
    String host = 'uc.qbox.me';

    String authorization = await qiniuAuthorization(method, urlpath, null, host,
        'application/json', null, '', accessKey, secretKey);

    BaseOptions baseoptions = BaseOptions(
      sendTimeout: 30000,
      receiveTimeout: 30000,
      connectTimeout: 30000,
    );
    baseoptions.headers = {
      'Authorization': 'Qiniu $authorization',
      'Host': host,
      'Content-Type': 'application/json',
    };
    Dio dio = Dio(baseoptions);
    try {
      var response = await dio.post('https://$host$urlpath');

      if (response.statusCode == 200) {
        return ['success'];
      } else {
        return ['failed'];
      }
    } catch (e) {
      if (e is DioError) {
        FLog.error(
            className: "QiniuManageAPI",
            methodName: "deleteBucket",
            text: formatErrorMessage({'element': element}, e.toString(),
                isDioError: true, dioErrorMessage: e),
            dataLogType: DataLogType.ERRORS.toString());
      } else {
        FLog.error(
            className: "QiniuManageAPI",
            methodName: "deleteBucket",
            text: formatErrorMessage({'element': element}, e.toString()),
            dataLogType: DataLogType.ERRORS.toString());
      }
      return [e.toString()];
    }
  }

  //查询绑定域名
  static queryDomains(Map element) async {
    Map configMap = await getConfigMap();
    String bucket = element['name'];

    String method = 'GET';
    String urlpath = '/v2/domains?tbl=$bucket';
    String accessKey = configMap['accessKey'];
    String secretKey = configMap['secretKey'];
    String host = 'uc.qbox.me';

    String authorization = await qiniuAuthorization(method, urlpath, null, host,
        'application/x-www-form-urlencoded', null, '', accessKey, secretKey);

    BaseOptions baseoptions = BaseOptions(
      sendTimeout: 30000,
      receiveTimeout: 30000,
      connectTimeout: 30000,
    );
    Dio dio = Dio(baseoptions);
    try {
      var response = await dio.get(
        'https://uc.qbox.me/v2/domains',
        queryParameters: {
          'tbl': bucket,
        },
        options: Options(
          headers: {
            'Authorization': 'Qiniu $authorization',
            'Host': host,
            'Content-Type': 'application/x-www-form-urlencoded',
          },
        ),
      );

      if (response.statusCode == 200) {
        return ['success', response.data];
      } else {
        return ['failed'];
      }
    } catch (e) {
      if (e is DioError) {
        FLog.error(
            className: "QiniuManageAPI",
            methodName: "queryDomains",
            text: formatErrorMessage({'element': element}, e.toString(),
                isDioError: true, dioErrorMessage: e),
            dataLogType: DataLogType.ERRORS.toString());
      } else {
        FLog.error(
            className: "QiniuManageAPI",
            methodName: "queryDomains",
            text: formatErrorMessage({'element': element}, e.toString()),
            dataLogType: DataLogType.ERRORS.toString());
      }
      return [e.toString()];
    }
  }

  //设置权限
  static setACL(Map element, String acl) async {
    Map configMap = await getConfigMap();
    String bucket = element['name'];

    String method = 'POST';
    String urlpath = '/private?bucket=$bucket&private=$acl';
    String accessKey = configMap['accessKey'];
    String secretKey = configMap['secretKey'];
    String host = 'uc.qbox.me';

    String authorization = await qiniuAuthorization(method, urlpath, null, host,
        'application/x-www-form-urlencoded', null, '', accessKey, secretKey);

    BaseOptions baseoptions = BaseOptions(
      sendTimeout: 30000,
      receiveTimeout: 30000,
      connectTimeout: 30000,
    );
    Dio dio = Dio(baseoptions);
    try {
      var response = await dio.post(
        'https://uc.qbox.me/private',
        queryParameters: {
          'bucket': bucket,
          'private': acl,
        },
        options: Options(
          headers: {
            'Authorization': 'Qiniu $authorization',
            'Host': host,
            'Content-Type': 'application/x-www-form-urlencoded',
          },
        ),
      );

      if (response.statusCode == 200) {
        return ['success', response.data];
      } else {
        return ['failed'];
      }
    } catch (e) {
      if (e is DioError) {
        FLog.error(
            className: "QiniuManageAPI",
            methodName: "setACL",
            text: formatErrorMessage({'element': element}, e.toString(),
                isDioError: true, dioErrorMessage: e),
            dataLogType: DataLogType.ERRORS.toString());
      } else {
        FLog.error(
            className: "QiniuManageAPI",
            methodName: "setACL",
            text: formatErrorMessage({'element': element}, e.toString()),
            dataLogType: DataLogType.ERRORS.toString());
      }
      return [e.toString()];
    }
  }

  //存储桶设为默认图床
  static setDefaultBucketFromListPage(
      Map element, Map textMap, String? folder) async {
    try {
      Map configMap = await getConfigMap();
      String accessKey = configMap['accessKey'];
      String secretKey = configMap['secretKey'];
      String bucket = element['name'];
      String usernameBucket = '${Global.defaultUser}_${element['name']}';
      var queryQiniuManage =
          await MySqlUtils.queryQiniuManage(username: usernameBucket);
      if (queryQiniuManage == 'Error' || queryQiniuManage == 'Empty') {
        return ['failed'];
      }
      String domain = queryQiniuManage['domain'];
      String area = queryQiniuManage['area'];
      String httpPrefix = 'http://';
      String url = '';

      if (domain.startsWith('https//') || domain.startsWith('http//')) {
        url = domain;
      } else {
        url = httpPrefix + domain;
      }
      String path = '';
      String options = textMap['option'] ?? configMap['options'];
      if (folder == null) {
        path = textMap['path'];
      } else {
        path = folder;
      }

      if (path.isEmpty || path.replaceAll(' ', '').isEmpty) {
        path = 'None';
      } else {
        if (!path.endsWith('/')) {
          path = '$path/';
        }
        if (path.startsWith('/')) {
          path = path.substring(1);
        }
      }

      List sqlconfig = [];
      sqlconfig.add(accessKey);
      sqlconfig.add(secretKey);
      sqlconfig.add(bucket);
      sqlconfig.add(url);
      sqlconfig.add(area);
      sqlconfig.add(options);
      sqlconfig.add(path);
      String defaultUser = await Global.getUser();
      sqlconfig.add(defaultUser);
      var queryQiniu = await MySqlUtils.queryQiniu(username: defaultUser);
      var queryuser = await MySqlUtils.queryUser(username: defaultUser);

      if (queryuser == 'Empty') {
        return ['failed'];
      }
      var sqlResult = '';

      if (queryQiniu == 'Empty') {
        sqlResult = await MySqlUtils.insertQiniu(content: sqlconfig);
      } else {
        sqlResult = await MySqlUtils.updateQiniu(content: sqlconfig);
      }

      if (sqlResult == "Success") {
        final qiniuConfig = QiniuConfigModel(
            accessKey, secretKey, bucket, url, area, options, path);
        final qiniuConfigJson = jsonEncode(qiniuConfig);
        final qiniuConfigFile = await _localFile;
        await qiniuConfigFile.writeAsString(qiniuConfigJson);
        return ['success'];
      } else {
        return ['failed'];
      }
    } catch (e) {
      FLog.error(
          className: "QiniuManageAPI",
          methodName: "setDefaultBucketFromListPage",
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      return ['failed'];
    }
  }

  //查询存储桶文件列表
  static queryBucketFiles(Map element, Map<String, dynamic> query) async {
    Map configMap = await getConfigMap();
    String bucket = element['name'];

    String method = 'GET';
    String urlpath = '/list';
    String accessKey = configMap['accessKey'];
    String secretKey = configMap['secretKey'];
    String host = 'rsf.qiniuapi.com';
    String queryStr = '';

    if (query['delimiter'] == null && query['prefix'] == null) {
      queryStr = 'bucket=$bucket&limit=1000';
    } else if (query['delimiter'] == null && query['prefix'] != null) {
      queryStr =
          'bucket=$bucket&limit=1000&prefix=${Uri.encodeComponent(query['prefix'])}';
    } else if (query['delimiter'] != null && query['prefix'] == null) {
      queryStr =
          'bucket=$bucket&limit=1000&delimiter=${Uri.encodeComponent(query['delimiter'])}';
    } else {
      queryStr =
          'bucket=$bucket&limit=1000&prefix=${Uri.encodeComponent(query['prefix'])}&delimiter=${Uri.encodeComponent(query['delimiter'])}';
    }

    String authorization = await qiniuAuthorization(
        method,
        urlpath,
        queryStr,
        host,
        'application/x-www-form-urlencoded',
        null,
        '',
        accessKey,
        secretKey);

    BaseOptions baseoptions = BaseOptions(
      sendTimeout: 30000,
      receiveTimeout: 30000,
      connectTimeout: 30000,
    );
    Dio dio = Dio(baseoptions);

    try {
      var response = await dio.get(
        'https://$host$urlpath?$queryStr',
        options: Options(
          headers: {
            'Authorization': 'Qiniu $authorization',
            'Host': host,
            'Content-Type': 'application/x-www-form-urlencoded',
          },
        ),
      );

      if (response.statusCode == 200) {
        return ['success', response.data];
      } else {
        return ['failed'];
      }
    } catch (e) {
      if (e is DioError) {
        FLog.error(
            className: "QiniuManageAPI",
            methodName: "queryBucketFiles",
            text: formatErrorMessage(
                {'element': element, 'query': query}, e.toString(),
                isDioError: true, dioErrorMessage: e),
            dataLogType: DataLogType.ERRORS.toString());
      } else {
        FLog.error(
            className: "QiniuManageAPI",
            methodName: "queryBucketFiles",
            text: formatErrorMessage(
                {'element': element, 'query': query}, e.toString()),
            dataLogType: DataLogType.ERRORS.toString());
      }
      return [e.toString()];
    }
  }

  //判断是否为空存储桶
  static isEmptyBucket(Map element) async {
    var queryResult = await queryBucketFiles(element, {
      'bucket': element['name'],
      'limit': 1000,
      'delimiter': '/',
    });
    if (queryResult[0] == 'success') {
      if ((queryResult[1]['items'] == null ||
              queryResult[1]['items'].length == 0) &&
          (queryResult[1]['commonPrefixes'] == null ||
              queryResult[1]['commonPrefixes'].length == 0)) {
        return ['empty'];
      } else {
        return ['notempty'];
      }
    } else {
      return ['error'];
    }
  }

  //新建文件夹
  static createFolder(Map element, String prefix, String newfolder) async {
    Map configMap = await getConfigMap();
    String bucket = element['name'];
    String area = element['area'];
    String host = QiniuImageUploadUtils.areaHostMap[area]!;
    String accessKey = configMap['accessKey'];
    String secretKey = configMap['secretKey'];
    String urlSafeBase64EncodePutPolicy =
        QiniuImageUploadUtils.geturlSafeBase64EncodePutPolicy(
            bucket, prefix, newfolder);
    String uploadToken = QiniuImageUploadUtils.getUploadToken(
        accessKey, secretKey, urlSafeBase64EncodePutPolicy);

    String urlpath = '$prefix$newfolder';
    FormData formData = FormData.fromMap({
      "key": urlpath,
      "fileName": newfolder,
      "token": uploadToken,
      "file": '',
    });

    BaseOptions baseoptions = BaseOptions(
      sendTimeout: 30000,
      receiveTimeout: 30000,
      connectTimeout: 30000,
    );
    Dio dio = Dio(baseoptions);

    try {
      var response = await dio.post(
        host,
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'UpToken $uploadToken',
          },
        ),
      );

      if (response.statusCode == 200) {
        return [
          'success',
        ];
      } else {
        return ['failed'];
      }
    } catch (e) {
      if (e is DioError) {
        FLog.error(
            className: "QiniuManageAPI",
            methodName: "createFolder",
            text: formatErrorMessage({
              'element': element,
              'prefix': prefix,
              'newfolder': newfolder
            }, e.toString(), isDioError: true, dioErrorMessage: e),
            dataLogType: DataLogType.ERRORS.toString());
      } else {
        FLog.error(
            className: "QiniuManageAPI",
            methodName: "createFolder",
            text: formatErrorMessage(
                {'element': element, 'prefix': prefix, 'newfolder': newfolder},
                e.toString()),
            dataLogType: DataLogType.ERRORS.toString());
      }
      return [e.toString()];
    }
  }

  //删除文件
  static deleteFile(Map element, String key) async {
    Map configMap = await getConfigMap();
    String bucket = element['name'];

    String method = 'DELETE';
    String urlpath = '/delete';
    String encodeEntryURI = urlSafeBase64Encode(utf8.encode('$bucket:$key'));
    urlpath = '$urlpath/$encodeEntryURI';
    String accessKey = configMap['accessKey'];
    String secretKey = configMap['secretKey'];
    String host = 'rs.qiniuapi.com';
    String authorization = await qiniuAuthorization(method, urlpath, null, host,
        'application/x-www-form-urlencoded', null, '', accessKey, secretKey);

    BaseOptions baseoptions = BaseOptions(
      sendTimeout: 30000,
      receiveTimeout: 30000,
      connectTimeout: 30000,
    );
    Dio dio = Dio(baseoptions);

    try {
      var response = await dio.delete(
        'https://$host$urlpath',
        options: Options(
          headers: {
            'Authorization': 'Qiniu $authorization',
            'Host': host,
            'Content-Type': 'application/x-www-form-urlencoded',
          },
        ),
      );

      if (response.statusCode == 200) {
        return [
          'success',
        ];
      } else {
        return ['failed'];
      }
    } catch (e) {
      if (e is DioError) {
        FLog.error(
            className: "QiniuManageAPI",
            methodName: "deleteFile",
            text: formatErrorMessage(
                {'element': element, 'key': key}, e.toString(),
                isDioError: true, dioErrorMessage: e),
            dataLogType: DataLogType.ERRORS.toString());
      } else {
        FLog.error(
            className: "QiniuManageAPI",
            methodName: "deleteFile",
            text: formatErrorMessage(
                {'element': element, 'key': key}, e.toString()),
            dataLogType: DataLogType.ERRORS.toString());
      }
      return [e.toString()];
    }
  }

  //删除文件夹
  static deleteFolder(Map element, String key) async {
    var queryResult = await queryBucketFiles(element, {
      'prefix': key,
      'bucket': element['name'],
      'limit': 1000,
      'delimiter': '/',
    });
    if (queryResult[0] == 'success') {
      if (queryResult[1]['items'] != null) {
        var contents = queryResult[1]['items'];
        if (contents is List) {
          for (var i = 0; i < contents.length; i++) {
            var deleteResult = await deleteFile(element, contents[i]['key']);
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
      if (queryResult[1]['commonPrefixes'] != null) {
        var commonPrefixes = queryResult[1]['commonPrefixes'];
        if (commonPrefixes is List) {
          for (var i = 0; i < commonPrefixes.length; i++) {
            var deleteResult = await deleteFolder(element, commonPrefixes[i]);
            if (deleteResult[0] != 'success') {
              return ['failed'];
            }
          }
        } else {
          var deleteResult = await deleteFolder(element, commonPrefixes);
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

  //复制/移动/重命名文件
  static copyFile(String operateType, Map element, String key, String newKey,
      bool isCover) async {
    Map configMap = await getConfigMap();
    String bucket = element['name'];

    String method = 'POST';
    String entryURISrc = '$bucket:$key';
    String entryURIDest = '$bucket:$newKey';
    String encodeEntryURI = urlSafeBase64Encode(utf8.encode(entryURISrc));
    String encodeEntryURIDest = urlSafeBase64Encode(utf8.encode(entryURIDest));
    String urlpath =
        '/$operateType/$encodeEntryURI/$encodeEntryURIDest/force/$isCover';
    String accessKey = configMap['accessKey'];
    String secretKey = configMap['secretKey'];
    String host = 'rs.qiniuapi.com';
    String authorization = await qiniuAuthorization(method, urlpath, null, host,
        'application/x-www-form-urlencoded', null, '', accessKey, secretKey);

    BaseOptions baseoptions = BaseOptions(
      sendTimeout: 30000,
      receiveTimeout: 30000,
      connectTimeout: 30000,
    );
    Dio dio = Dio(baseoptions);

    try {
      var response = await dio.post(
        'https://$host$urlpath',
        options: Options(
          headers: {
            'Authorization': 'Qiniu $authorization',
            'Host': host,
            'Content-Type': 'application/x-www-form-urlencoded',
          },
        ),
      );

      if (response.statusCode == 200) {
        return [
          'success',
        ];
      } else if (response.statusCode == 614) {
        return ['existed'];
      } else {
        return ['failed'];
      }
    } catch (e) {
      if (e is DioError) {
        FLog.error(
            className: "QiniuManageAPI",
            methodName: "copyFile",
            text: formatErrorMessage({
              'element': element,
              'key': key,
              'newKey': newKey
            }, e.toString(), isDioError: true, dioErrorMessage: e),
            dataLogType: DataLogType.ERRORS.toString());
      } else {
        FLog.error(
            className: "QiniuManageAPI",
            methodName: "copyFile",
            text: formatErrorMessage(
                {'element': element, 'key': key, 'newKey': newKey},
                e.toString()),
            dataLogType: DataLogType.ERRORS.toString());
      }
      if (e.toString().contains('614')) {
        return ['existed'];
      } else {
        return [e.toString()];
      }
    }
  }

  //异步第三方资源抓取
  static sisyphusFetch(Map element, String bucketPrefix, String link) async {
    Map configMap = await getConfigMap();
    String bucket = element['name'];
    String region = element['area'];
    String host = 'api-$region.qiniuapi.com';
    String contentType = 'application/json';
    String method = 'POST';
    String urlpath = '/sisyphus/fetch';
    String accessKey = configMap['accessKey'];
    String secretKey = configMap['secretKey'];
    String fileNames = link.split('/').last;
    if (fileNames.contains('?')) {
      fileNames = fileNames.split('?').first;
    }
    Map<String, dynamic> body = {
      'url': link,
      'bucket': bucket,
      'key': bucketPrefix + fileNames,
    };
    String bodyString = json.encode(body);
    String authorization = await qiniuAuthorization(method, urlpath, null, host,
        contentType, null, bodyString, accessKey, secretKey);

    BaseOptions baseoptions = BaseOptions(
      sendTimeout: 30000,
      receiveTimeout: 30000,
      connectTimeout: 30000,
    );
    Dio dio = Dio(baseoptions);
    try {
      var response = await dio.post(
        'https://$host$urlpath',
        data: body,
        options: Options(
          headers: {
            'Authorization': 'Qiniu $authorization',
            'Host': host,
            'Content-Type': 'application/json',
          },
        ),
      );
      if (response.statusCode == 200) {
        return [
          'success',
        ];
      } else {
        return ['failed'];
      }
    } catch (e) {
      if (e is DioError) {
        FLog.error(
            className: "QiniuManageAPI",
            methodName: "sisyphusFetch",
            text: formatErrorMessage({
              'element': element,
              'bucketPrefix': bucketPrefix,
              'link': link
            }, e.toString(), isDioError: true, dioErrorMessage: e),
            dataLogType: DataLogType.ERRORS.toString());
      } else {
        FLog.error(
            className: "QiniuManageAPI",
            methodName: "sisyphusFetch",
            text: formatErrorMessage({
              'element': element,
              'bucketPrefix': bucketPrefix,
              'link': link
            }, e.toString()),
            dataLogType: DataLogType.ERRORS.toString());
      }
      return [e.toString()];
    }
  }
}
