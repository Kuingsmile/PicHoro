import 'dart:io';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:f_logs/f_logs.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';

import 'package:horopic/utils/global.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/picture_host_configure/configure_page/upyun_configure.dart';

class UpyunManageAPI {
  static Map<String?, String> tagConvert = {
    'download': '文件下载',
    'picture': '网页图片',
    'vod': '音视频点播',
    null: '未知',
  };

  static String upyunBaseURL = 'v0.api.upyun.com';
  static String upyunManageURL = 'https://api.upyun.com/';

  static Future<File> get localFile async {
    final path = await _localPath;
    String defaultUser = Global.getUser();
    return ensureFileExists(File('$path/${defaultUser}_upyun_config.txt'));
  }

  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<String> readUpyunConfig() async {
    try {
      final file = await localFile;
      String contents = await file.readAsString();
      return contents;
    } catch (e) {
      FLog.error(
          className: 'UpyunManageAPI',
          methodName: 'readUpyunConfig',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      return "Error";
    }
  }

  static Future<Map> getConfigMap() async {
    String configStr = await readUpyunConfig();
    if (configStr == '') {
      return {};
    }
    Map configMap = json.decode(configStr);
    return configMap;
  }

  static Future<File> get _manageLocalFile async {
    final path = await _localPath;
    return File('$path/upyun_manage.txt');
  }

  static Future<String> readUpyunManageConfig() async {
    try {
      final file = await _manageLocalFile;
      String contents = await file.readAsString();
      return contents;
    } catch (e) {
      FLog.error(
          className: 'UpyunManageAPI',
          methodName: 'readUpyunManageConfig',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      return "Error";
    }
  }

  static Future<bool> saveUpyunManageConfig(String email, String password, String token, String tokenname) async {
    try {
      final file = await _manageLocalFile;
      await file
          .writeAsString(jsonEncode({'email': email, 'password': password, 'token': token, 'tokenname': tokenname}));
      return true;
    } catch (e) {
      FLog.error(
          className: 'UpyunManageAPI',
          methodName: 'saveUpyunManageConfig',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      return false;
    }
  }

  static Future<File> get _operatorLocalFile async {
    final path = await _localPath;
    return File('$path/upyun_operator.txt');
  }

  static Future<String> readUpyunOperatorConfig() async {
    try {
      final file = await _operatorLocalFile;
      String contents = await file.readAsString();
      return contents;
    } catch (e) {
      FLog.error(
          className: 'UpyunManageAPI',
          methodName: 'readUpyunOperatorConfig',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      return "Error";
    }
  }

  static Future<bool> saveUpyunOperatorConfig(String bucket, String email, String operator, String password) async {
    try {
      final file = await _operatorLocalFile;
      var oldContent = {};
      if (!await file.exists()) {
        await file.create();
      } else {
        String contents = await file.readAsString();
        oldContent = jsonDecode(contents);
      }
      oldContent[bucket] = {'email': email, 'operator': operator, 'password': password};
      await file.writeAsString(jsonEncode(oldContent));
      return true;
    } catch (e) {
      FLog.error(
          className: 'UpyunManageAPI',
          methodName: 'saveUpyunOperatorConfig',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      return false;
    }
  }

  static Future<bool> deleteUpyunOperatorConfig(String bucket) async {
    try {
      final file = await _operatorLocalFile;
      String contents = await file.readAsString();
      Map oldContent = jsonDecode(contents);
      oldContent.remove(bucket);
      await file.writeAsString(jsonEncode(oldContent));
      return true;
    } catch (e) {
      FLog.error(
          className: 'UpyunManageAPI',
          methodName: 'deleteUpyunOperatorConfig',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      return false;
    }
  }

  static getUpyunManageConfigMap() async {
    var queryUpyunManage = await UpyunManageAPI.readUpyunManageConfig();
    if (queryUpyunManage == 'Error' || queryUpyunManage == '') {
      return 'Error';
    } else {
      var jsonResult = jsonDecode(queryUpyunManage);
      Map upyunManageConfigMap = {
        'email': jsonResult['email'],
        'password': jsonResult['password'],
        'token': jsonResult['token'],
      };
      return upyunManageConfigMap;
    }
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

  //get authorization
  static Future<String> upyunAuthorization(
    String method,
    String uri,
    String contentMd5,
    String operatorName,
    String operatorPassword,
  ) async {
    try {
      String passwordMd5 = md5.convert(utf8.encode(operatorPassword)).toString();
      method = method.toUpperCase();
      String date = HttpDate.format(DateTime.now());
      String stringToSing = '';
      String codedUri = Uri.encodeFull(uri);
      if (contentMd5 == '') {
        stringToSing = '$method&$codedUri&$date';
      } else {
        stringToSing = '$method&$codedUri&$date&$contentMd5';
      }
      String signature = base64.encode(Hmac(sha1, utf8.encode(passwordMd5)).convert(utf8.encode(stringToSing)).bytes);

      String authorization = 'UPYUN $operatorName:$signature';
      return authorization;
    } catch (e) {
      FLog.error(
          className: 'UpyunManageAPI',
          methodName: 'upyunAuthorization',
          text: formatErrorMessage({
            'method': method,
            'uri': uri,
            'contentMd5': contentMd5,
          }, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      return "";
    }
  }

  static getToken(String email, String password) async {
    BaseOptions baseoptions = setBaseOptions();
    String randomString = randomStringGenerator(32);
    String randomStringForName = randomStringGenerator(20);
    Dio dio = Dio(baseoptions);
    Map<String, dynamic> params = {
      'username': email,
      'password': password,
      'code': randomString,
      'name': randomStringForName,
      'scope': 'global',
    };
    try {
      var response = await dio.post(
        'https://api.upyun.com/oauth/tokens',
        data: jsonEncode(params),
      );
      if (response.statusCode != 200) {
        return ['failed'];
      }
      return ['success', response.data];
    } catch (e) {
      flogErr(e, {}, 'UpyunManageAPI', 'getToken');
      return ['failed'];
    }
  }

  static checkToken(String token) async {
    BaseOptions baseoptions = setBaseOptions();
    baseoptions.headers = {
      'Authorization': 'Bearer $token',
    };
    Dio dio = Dio(baseoptions);
    try {
      var response = await dio.get(
        'https://api.upyun.com/oauth/tokens',
      );
      if (response.statusCode != 200) {
        return ['failed'];
      }
      return ['success'];
    } catch (e) {
      flogErr(e, {}, 'UpyunManageAPI', 'checkToken');
      return ['failed'];
    }
  }

  static deleteToken(String token, String tokenname) async {
    BaseOptions baseoptions = setBaseOptions();
    baseoptions.headers = {
      'Authorization': 'Bearer $token',
    };
    Map<String, dynamic> params = {
      'name': tokenname,
    };
    Dio dio = Dio(baseoptions);
    try {
      var response = await dio.delete(
        'https://api.upyun.com/oauth/tokens',
        queryParameters: params,
      );

      if (response.statusCode != 200) {
        return ['failed'];
      }
      return ['success'];
    } catch (e) {
      flogErr(e, {}, 'UpyunManageAPI', 'deleteToken');
      return ['failed'];
    }
  }

  static getBucketList() async {
    try {
      var configMap = await getUpyunManageConfigMap();
      if (configMap == 'Error') {
        return ['failed'];
      }
      String token = configMap['token'];
      String host = 'https://api.upyun.com/buckets';
      BaseOptions baseoptions = setBaseOptions();
      baseoptions.headers = {
        'Authorization': 'Bearer $token',
      };
      Map<String, dynamic> queryParameters = {
        'limit': 100,
        'bucket_type': 'file',
      };
      Dio dio = Dio(baseoptions);

      String max = '';
      var response = await dio.get(
        host,
        queryParameters: queryParameters,
      );
      Map responseMap = response.data;
      if (response.statusCode == 200) {
        if (responseMap['pager']['max'] == null) {
          return ['success', responseMap['buckets']];
        } else {
          Map tempMap = Map.from(responseMap);
          while (tempMap['pager']['max'] != null) {
            max = tempMap['pager']['max'].toString();
            queryParameters['max'] = max;
            response = await dio.get(
              host,
              queryParameters: queryParameters,
            );
            tempMap.clear();
            tempMap = response.data;
            if (response.statusCode == 200) {
              if (tempMap['buckets'] != null) {
                responseMap['buckets'].addAll(tempMap['buckets']);
              }
            } else {
              return ['failed'];
            }
          }
        }
        return ['success', responseMap['buckets']];
      } else {
        return ['failed'];
      }
    } catch (e) {
      flogErr(e, {}, 'UpyunManageAPI', 'getBucketList');
      return [e.toString()];
    }
  }

  static getBucketInfo(String bucketName) async {
    var configMap = await getUpyunManageConfigMap();
    if (configMap == 'Error') {
      return ['failed'];
    }
    String token = configMap['token'];

    String host = 'https://api.upyun.com/buckets/info';

    BaseOptions baseoptions = setBaseOptions();
    baseoptions.headers = {
      'Authorization': 'Bearer $token',
    };
    Map<String, dynamic> params = {
      'bucket_name': bucketName,
    };
    Dio dio = Dio(baseoptions);
    try {
      var response = await dio.get(
        host,
        queryParameters: params,
      );
      if (response.statusCode != 200) {
        return ['failed'];
      }
      return ['success', response.data];
    } catch (e) {
      flogErr(e, {}, 'UpyunManageAPI', 'getBucketInfo');
      return [e.toString()];
    }
  }

  static deleteBucket(String bucketName) async {
    var configMap = await getUpyunManageConfigMap();
    if (configMap == 'Error') {
      return ['failed'];
    }
    String token = configMap['token'];
    String password = configMap['password'];
    String host = 'https://api.upyun.com/buckets/delete';

    BaseOptions baseoptions = setBaseOptions();
    baseoptions.headers = {
      'Authorization': 'Bearer $token',
    };
    Map<String, dynamic> params = {
      'bucket_name': bucketName,
      'password': password,
    };
    Dio dio = Dio(baseoptions);
    try {
      var response = await dio.post(
        host,
        data: params,
      );
      if (response.statusCode != 200) {
        return ['failed'];
      }
      return ['success'];
    } catch (e) {
      flogErr(e, {}, 'UpyunManageAPI', 'deleteBucket');
      return [e.toString()];
    }
  }

  static putBucket(String bucketName) async {
    var configMap = await getUpyunManageConfigMap();
    if (configMap == 'Error') {
      return ['failed'];
    }
    String token = configMap['token'];
    String host = 'https://api.upyun.com/buckets';

    BaseOptions baseoptions = setBaseOptions();
    baseoptions.headers = {
      'Authorization': 'Bearer $token',
    };
    Map<String, dynamic> params = {
      'bucket_name': bucketName,
      'type': 'file',
    };
    Dio dio = Dio(baseoptions);
    try {
      var response = await dio.put(
        host,
        data: params,
      );
      if (response.statusCode != 201) {
        return ['failed'];
      }
      return ['success'];
    } catch (e) {
      flogErr(e, {}, 'UpyunManageAPI', 'putBucket');
      return [e.toString()];
    }
  }

  static getOperator(String bucketName) async {
    var configMap = await getUpyunManageConfigMap();
    if (configMap == 'Error') {
      return ['failed'];
    }
    String token = configMap['token'];
    String host = 'https://api.upyun.com/buckets/operators';

    BaseOptions baseoptions = setBaseOptions();
    baseoptions.headers = {
      'Authorization': 'Bearer $token',
    };
    Map<String, dynamic> params = {
      'bucket_name': bucketName,
    };
    Dio dio = Dio(baseoptions);
    try {
      var response = await dio.get(
        host,
        queryParameters: params,
      );
      if (response.statusCode != 200) {
        return ['failed'];
      }
      return ['success', response.data['operators']];
    } catch (e) {
      flogErr(e, {}, 'UpyunManageAPI', 'getOperator');
      return [e.toString()];
    }
  }

  static addOperator(String bucketName, String operatorName) async {
    var configMap = await getUpyunManageConfigMap();
    if (configMap == 'Error') {
      return ['failed'];
    }
    String token = configMap['token'];
    String host = 'https://api.upyun.com/buckets/operators';

    BaseOptions baseoptions = setBaseOptions();
    baseoptions.headers = {
      'Authorization': 'Bearer $token',
    };
    Map<String, dynamic> params = {
      'bucket_name': bucketName,
      'operator_name': operatorName,
    };
    Dio dio = Dio(baseoptions);
    try {
      var response = await dio.put(
        host,
        data: params,
      );
      if (response.statusCode != 201) {
        return ['failed'];
      }
      return ['success'];
    } catch (e) {
      flogErr(e, {}, 'UpyunManageAPI', 'addOperator');
      return [e.toString()];
    }
  }

  static deleteOperator(String bucketName, String operatorName) async {
    var configMap = await getUpyunManageConfigMap();
    if (configMap == 'Error') {
      return ['failed'];
    }
    String token = configMap['token'];
    String host = 'https://api.upyun.com/buckets/operators';

    BaseOptions baseoptions = setBaseOptions();
    baseoptions.headers = {
      'Authorization': 'Bearer $token',
    };
    Map<String, dynamic> params = {
      'bucket_name': bucketName,
      'operator_name': operatorName,
    };
    Dio dio = Dio(baseoptions);
    try {
      var response = await dio.delete(
        host,
        queryParameters: params,
      );
      if (response.statusCode != 200) {
        return ['failed'];
      }
      return ['success'];
    } catch (e) {
      flogErr(e, {}, 'UpyunManageAPI', 'deleteOperator');
      return [e.toString()];
    }
  }

  //存储桶设为默认图床
  static setDefaultBucketFromListPage(Map element, Map upyunManageConfigMap, Map textMap) async {
    try {
      String bucket = element['bucket_name'];
      var queryOperator = await UpyunManageAPI.readUpyunOperatorConfig();
      if (queryOperator == 'Error') {
        return ['failed'];
      }
      var jsonResult = jsonDecode(queryOperator);
      String operatorName = jsonResult['operator'];
      String operatorPassword = jsonResult['password'];
      String httpPrefix = 'http://';
      String url = '';
      if (element['https'] == true) {
        httpPrefix = 'https://';
      }
      if (element['domains'] == null || element['domains'].length == 0) {
        return ['failed'];
      }
      if (element['domains'].toString().startsWith('https//') || element['domains'].toString().startsWith('http//')) {
        url = element['domains'];
      } else {
        url = httpPrefix + element['domains'];
      }

      String options = textMap['option'];
      String path = textMap['path'];
      String antiLeechToken = textMap['antiLeechToken'];
      String antiLeechExpire = textMap['antiLeechExpire'];
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

      final upyunConfig =
          UpyunConfigModel(bucket, operatorName, operatorPassword, url, options, path, antiLeechToken, antiLeechExpire);
      final upyunConfigJson = jsonEncode(upyunConfig);
      final upyunConfigFile = await localFile;
      await upyunConfigFile.writeAsString(upyunConfigJson);
      return ['success'];
    } catch (e) {
      FLog.error(
          className: "UpyunManageAPI",
          methodName: "setDefaultBucketFromListPage",
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      return ['failed'];
    }
  }

  static queryBucketFiles(Map element, String prefix) async {
    String method = 'GET';
    String bucket = element['bucket'];
    String uri = '/$bucket$prefix';
    String operator = element['operator'];
    String password = element['password'];
    String authorization = await upyunAuthorization(method, uri, '', operator, password);
    BaseOptions baseoptions = setBaseOptions();
    baseoptions.headers = {
      'Authorization': authorization,
      'accept': 'application/json',
      'x-list-limit': '10000',
      'Date': HttpDate.format(DateTime.now()),
    };
    String url = 'http://$upyunBaseURL$uri';
    Dio dio = Dio(baseoptions);
    try {
      String marker = '';
      var response = await dio.get(url);
      Map responseMap = response.data;
      if (response.statusCode == 200) {
        if (responseMap['iter'] == null || responseMap['iter'].toString().isEmpty) {
          return ['success', responseMap['files']];
        } else {
          Map tempMap = Map.from(responseMap);
          while (tempMap['iter'] != null &&
              tempMap['iter'].toString().isNotEmpty &&
              tempMap['iter'].toString() != 'g2gCZAAEbmV4dGQAA2VvZg') {
            marker = tempMap['iter'];
            baseoptions.headers['x-list-iter'] = marker;
            dio = Dio(baseoptions);
            response = await dio.get(url);
            tempMap = response.data;
            if (response.statusCode == 200) {
              if (tempMap['files'] != null) {
                responseMap['files'].addAll(tempMap['files']);
              }
            } else {
              return ['failed'];
            }
          }
        }
        return ['success', responseMap['files']];
      } else {
        return ['failed'];
      }
    } catch (e) {
      flogErr(e, {'prefix': prefix}, 'UpyunManageAPI', 'queryBucketFiles');
      return [e.toString()];
    }
  }

  //判断是否为空存储桶
  static isEmptyBucket(Map element) async {
    var queryResult = await queryBucketFiles(element, '/');
    if (queryResult[0] == 'success') {
      if (queryResult[1].length == 0) {
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
    String method = 'POST';
    String bucket = element['bucket'];
    String operator = element['operator'];
    String password = element['password'];
    if (newfolder.startsWith('/')) {
      newfolder = newfolder.substring(1);
    }
    if (newfolder.endsWith('/')) {
      newfolder = newfolder.substring(0, newfolder.length - 1);
    }
    String uri = '/$bucket$prefix$newfolder/';
    String authorization = await upyunAuthorization(method, uri, '', operator, password);
    BaseOptions baseoptions = setBaseOptions();
    baseoptions.headers = {
      'Authorization': authorization,
      'folder': 'true',
      'Date': HttpDate.format(DateTime.now()),
    };
    String url = 'http://$upyunBaseURL$uri';
    Dio dio = Dio(baseoptions);
    try {
      var response = await dio.post(url);
      if (response.statusCode == 200) {
        return [
          'success',
        ];
      } else {
        return ['failed'];
      }
    } catch (e) {
      flogErr(
          e,
          {
            'prefix': prefix,
            'newfolder': newfolder,
          },
          'UpyunManageAPI',
          'createFolder');
      return [e.toString()];
    }
  }

  //删除文件
  static deleteFile(Map element, String prefix, String key) async {
    String method = 'DELETE';
    String bucket = element['bucket'];
    String operator = element['operator'];
    String password = element['password'];
    if (!prefix.startsWith('/')) {
      prefix = '/$prefix';
    }
    if (!prefix.endsWith('/')) {
      prefix = '$prefix/';
    }
    String uri = '/$bucket$prefix$key';
    String authorization = await upyunAuthorization(method, uri, '', operator, password);
    BaseOptions baseoptions = setBaseOptions();
    baseoptions.headers = {
      'Authorization': authorization,
      'Date': HttpDate.format(DateTime.now()),
    };

    String url = 'http://$upyunBaseURL$uri';
    Dio dio = Dio(baseoptions);
    try {
      var response = await dio.delete(url);
      if (response.statusCode != 200) {
        return ['failed'];
      }
      return ['success'];
    } catch (e) {
      flogErr(
          e,
          {
            'prefix': prefix,
            'key': key,
          },
          'UpyunManageAPI',
          'deleteFile');

      return [e.toString()];
    }
  }

  //删除文件夹
  static deleteFolder(Map element, String prefix) async {
    var queryResult = await queryBucketFiles(element, prefix);
    try {
      if (queryResult[0] == 'success') {
        List files = [];
        List folders = [];
        for (var item in queryResult[1]) {
          if (item['type'] == 'folder') {
            folders.add(item['name']);
          } else {
            files.add(item['name']);
          }
        }
        if (files.isNotEmpty) {
          for (var item in files) {
            var deleteResult = await deleteFile(element, prefix, item);
            if (deleteResult[0] != 'success') {
              return ['failed'];
            }
          }
        }
        if (folders.isNotEmpty) {
          for (var item in folders) {
            var deleteResult = await deleteFolder(element, '$prefix/$item');
            if (deleteResult[0] != 'success') {
              return ['failed'];
            }
          }
        }
        var deleteSelfResult = await deleteFile(
            element, prefix.substring(0, prefix.length - prefix.split('/').last.length - 1), prefix.split('/').last);
        if (deleteSelfResult[0] != 'success') {
          return ['failed'];
        }
        return ['success'];
      } else {
        return ['failed'];
      }
    } catch (e) {
      flogErr(e, {'prefix': prefix}, 'UpyunManageAPI', 'deleteFolder');
      return ['failed'];
    }
  }

  //目录设为默认图床
  static setDefaultBucket(Map element, String? folder) async {
    try {
      Map configMap = await getConfigMap();
      String bucket = element['bucket'];
      String operatorName = element['operator'];
      String operatorPassword = element['password'];
      String url = element['url'];
      String options = configMap['options'];
      String antiLeechToken = configMap['antiLeechToken'];
      String antiLeechExpire = configMap['antiLeechExpire'];
      String path = '';
      if (folder == null) {
        path = configMap['path'];
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

      final upyunConfig =
          UpyunConfigModel(bucket, operatorName, operatorPassword, url, options, path, antiLeechToken, antiLeechExpire);
      final upyunConfigJson = jsonEncode(upyunConfig);
      final upyunConfigFile = await localFile;
      await upyunConfigFile.writeAsString(upyunConfigJson);
      return ['success'];
    } catch (e) {
      FLog.error(
          className: "UpyunManageAPI",
          methodName: "setDefaultBucket",
          text: formatErrorMessage({'folder': folder}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      return ['failed'];
    }
  }

  //重命名文件
  static renameFile(Map element, String prefix, String key, String newKey) async {
    String method = 'PUT';

    String bucket = element['bucket'];
    String operatorName = element['operator'];
    String operatorPassword = element['password'];
    if (newKey.startsWith('/')) {
      newKey = newKey.substring(1);
    }
    if (newKey.endsWith('/')) {
      newKey = newKey.substring(0, newKey.length - 1);
    }
    String xUpyunMoveSource = '/$bucket$prefix$key';
    String uri = '/$bucket$prefix$newKey';
    String authorization = await upyunAuthorization(method, uri, '', operatorName, operatorPassword);
    BaseOptions baseoptions = setBaseOptions();
    baseoptions.headers = {
      'Authorization': authorization,
      'Date': HttpDate.format(DateTime.now()),
      'X-Upyun-Move-Source': xUpyunMoveSource,
      'Content-Length': '0',
    };
    String url = 'http://$upyunBaseURL$uri';
    Dio dio = Dio(baseoptions);
    try {
      var response = await dio.put(url);
      if (response.statusCode == 200) {
        return [
          'success',
        ];
      } else {
        return ['failed'];
      }
    } catch (e) {
      flogErr(e, {'prefix': prefix, 'key': key, 'newKey': newKey}, 'UpyunManageAPI', 'renameFile');
      return [e.toString()];
    }
  }

  //查询是否有重名文件
  static queryDuplicateName(Map element, String prefix, String key) async {
    var queryResult = await queryBucketFiles(element, prefix);
    if (queryResult[0] == 'success') {
      for (var i = 0; i < queryResult[1].length; i++) {
        if (queryResult[1][i]['name'] == key) {
          return ['duplicate'];
        }
      }
      return ['notduplicate'];
    } else {
      return ['error'];
    }
  }

  //上传文件
  static uploadFile(
    Map element,
    String filename,
    String filepath,
    String prefix,
  ) async {
    String bucket = element['bucket'];
    String upyunOperator = element['operator'];
    String password = element['password'];
    String url = element['url'];

    if (url != "None") {
      if (!url.startsWith('http') && !url.startsWith('https')) {
        url = 'http://$url';
      }
    }
    String host = 'http://v0.api.upyun.com';
    //云存储的路径
    String urlpath = '';
    if (prefix != 'None') {
      urlpath = '/$prefix$filename';
    } else {
      urlpath = '/$filename';
    }
    String date = HttpDate.format(DateTime.now());
    File uploadFile = File(filepath);
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
    String signature = base64.encode(Hmac(sha1, utf8.encode(passwordMd5)).convert(utf8.encode(stringToSign)).bytes);
    String authorization = 'UPYUN $upyunOperator:$signature';
    FormData formData = FormData.fromMap({
      'authorization': authorization,
      'policy': base64Policy,
      'file': await MultipartFile.fromFile(filepath, filename: filename),
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
    try {
      var response = await dio.post(
        '$host/$bucket',
        data: formData,
      );
      if (response.statusCode == 200) {
        return ['success'];
      } else {
        return ['failed'];
      }
    } catch (e) {
      flogErr(e, {'filename': filename, 'filepath': filepath, 'prefix': prefix}, 'UpyunManageAPI', 'uploadFile');
      return ['error'];
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
      flogErr(e, {'fileLink': fileLink, 'prefix': prefix}, 'UpyunManageAPI', 'uploadNetworkFile');
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
