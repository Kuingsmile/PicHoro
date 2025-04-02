import 'dart:io';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:horopic/picture_host_manage/common/base_manage_api.dart';
import 'package:path_provider/path_provider.dart';

import 'package:horopic/utils/global.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/picture_host_configure/configure_page/upyun_configure.dart';

class UpyunManageAPI extends BaseManageApi {
  static final UpyunManageAPI _instance = UpyunManageAPI._internal();

  UpyunManageAPI._internal();

  factory UpyunManageAPI() {
    return _instance;
  }

  static Map<String?, String> tagConvert = {
    'download': '文件下载',
    'picture': '网页图片',
    'vod': '音视频点播',
    null: '未知',
  };

  static String upyunBaseURL = 'v0.api.upyun.com';
  static String upyunManageURL = 'https://api.upyun.com/';

  @override
  String configFileName() => 'upyun_config.txt';

  Future<File> _getLocalFile(String fileName) async {
    final path = await localPath();
    return File('$path/$fileName');
  }

  Future<File> manageLocalFile() async => await _getLocalFile('upyun_manage.txt');
  Future<File> operatorLocalFile() async => await _getLocalFile('upyun_operator.txt');

  Future<String> _readConfigFile(Future<File> Function() fileGetter) async {
    try {
      final file = await fileGetter();
      return await file.readAsString();
    } catch (e) {
      flogErr(e, {}, 'UpyunManageAPI', '_readConfigFile');
      return "Error";
    }
  }

  Future<bool> _writeConfigFile(Future<File> Function() fileGetter, String content) async {
    try {
      final file = await fileGetter();
      await file.writeAsString(content);
      return true;
    } catch (e) {
      flogErr(e, {'content': content}, 'UpyunManageAPI', '_writeConfigFile');
      return false;
    }
  }

  Future<String> readUpyunManageConfig() async => _readConfigFile(manageLocalFile);
  Future<String> readUpyunOperatorConfig() async => _readConfigFile(operatorLocalFile);

  Future<bool> saveUpyunManageConfig(String email, String password, String token, String tokenname) async {
    try {
      Map<String, String> data = {'email': email, 'password': password, 'token': token, 'tokenname': tokenname};
      return await _writeConfigFile(manageLocalFile, jsonEncode(data));
    } catch (e) {
      flogErr(e, {'email': email, 'token': token}, 'UpyunManageAPI', 'saveUpyunManageConfig');
      return false;
    }
  }

  Future<bool> saveUpyunOperatorConfig(String bucket, String email, String operator, String password) async {
    try {
      final file = await operatorLocalFile();
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
      flogErr(
          e,
          {
            'bucket': bucket,
            'email': email,
            'operator': operator,
            'password': password,
          },
          'UpyunManageAPI',
          'saveUpyunOperatorConfig');
      return false;
    }
  }

  Future<bool> deleteUpyunOperatorConfig(String bucket) async {
    try {
      final file = await operatorLocalFile();
      String contents = await file.readAsString();
      Map oldContent = jsonDecode(contents);
      oldContent.remove(bucket);
      await file.writeAsString(jsonEncode(oldContent));
      return true;
    } catch (e) {
      flogErr(e, {'bucket': bucket}, 'UpyunManageAPI', 'deleteUpyunOperatorConfig');
      return false;
    }
  }

  getUpyunManageConfigMap() async {
    var queryUpyunManage = await readUpyunManageConfig();
    if (queryUpyunManage == 'Error' || queryUpyunManage == '') {
      return 'Error';
    }
    var jsonResult = jsonDecode(queryUpyunManage);
    return {
      'email': jsonResult['email'],
      'password': jsonResult['password'],
      'token': jsonResult['token'],
    };
  }

  //get authorization
  Future<String> upyunAuthorization(
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
      String codedUri = Uri.encodeFull(uri);
      String stringToSing = contentMd5.isEmpty ? '$method&$codedUri&$date' : '$method&$codedUri&$date&$contentMd5';
      String signature = base64.encode(Hmac(sha1, utf8.encode(passwordMd5)).convert(utf8.encode(stringToSing)).bytes);
      return 'UPYUN $operatorName:$signature';
    } catch (e) {
      flogErr(
          e,
          {
            'method': method,
            'uri': uri,
            'contentMd5': contentMd5,
            'operatorName': operatorName,
            'operatorPassword': operatorPassword,
          },
          'UpyunManageAPI',
          'upyunAuthorization');
      return "";
    }
  }

  Future<List<dynamic>> _makeRequest(
      {required String url,
      required String method,
      Map<String, dynamic>? headers,
      Map<String, dynamic>? params,
      dynamic data,
      required Function(Response) onSuccess,
      String callFunction = '_makeRequest',
      required Function checkSuccess}) async {
    BaseOptions baseoptions = setBaseOptions();
    if (headers != null) {
      baseoptions.headers = headers;
    }

    Dio dio = Dio(baseoptions);
    try {
      Response response;
      if (method == 'GET') {
        response = await dio.get(url, queryParameters: params);
      } else if (method == 'POST') {
        response = await dio.post(url, data: data, queryParameters: params);
      } else if (method == 'DELETE') {
        response = await dio.delete(url, data: data, queryParameters: params);
      } else if (method == 'PUT') {
        response = await dio.put(url, data: data, queryParameters: params);
      } else {
        throw Exception('Unsupported HTTP method: $method');
      }

      if (checkSuccess(response)) {
        return onSuccess(response);
      }
      flogErr(
          response, {'url': url, 'data': data, 'params': params, 'headers': headers}, "UpyunManageAPI", callFunction);
      return ['failed'];
    } catch (e) {
      flogErr(
          e,
          {
            'url': url,
            'data': data,
            'params': params,
            'headers': headers,
          },
          "UpyunManageAPI",
          callFunction);
      return [e.toString()];
    }
  }

  getToken(String email, String password) async {
    String randomString = randomStringGenerator(32);
    String randomStringForName = randomStringGenerator(20);

    return _makeRequest(
      url: 'https://api.upyun.com/oauth/tokens',
      method: 'POST',
      data: jsonEncode({
        'username': email,
        'password': password,
        'code': randomString,
        'name': randomStringForName,
        'scope': 'global',
      }),
      onSuccess: (response) => ['success', response.data],
      checkSuccess: (response) => response.statusCode == 200,
      callFunction: 'getToken',
    );
  }

  checkToken(String token) async {
    return _makeRequest(
      url: 'https://api.upyun.com/oauth/tokens',
      method: 'GET',
      headers: {'Authorization': 'Bearer $token'},
      onSuccess: (_) => ['success'],
      checkSuccess: (response) => response.statusCode == 200,
      callFunction: 'checkToken',
    );
  }

  deleteToken(String token, String tokenname) async {
    return _makeRequest(
      url: 'https://api.upyun.com/oauth/tokens',
      method: 'DELETE',
      headers: {'Authorization': 'Bearer $token'},
      params: {'name': tokenname},
      onSuccess: (_) => ['success'],
      checkSuccess: (response) => response.statusCode == 200,
      callFunction: 'deleteToken',
    );
  }

  getBucketList() async {
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
      if (response.statusCode != 200) {
        flogErr(
            response,
            {
              'host': host,
              'queryParameters': queryParameters,
            },
            'UpyunManageAPI',
            'getBucketList');
        return ['failed'];
      }

      if (responseMap['pager']['max'] == null) {
        return ['success', responseMap['buckets']];
      }
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
        if (response.statusCode != 200 || tempMap['buckets'] == null) {
          return ['failed'];
        }
        responseMap['buckets'].addAll(tempMap['buckets']);
      }
      return ['success', responseMap['buckets']];
    } catch (e) {
      flogErr(e, {}, 'UpyunManageAPI', 'getBucketList');
      return [e.toString()];
    }
  }

  getBucketInfo(String bucketName) async {
    var configMap = await getUpyunManageConfigMap();
    if (configMap == 'Error') {
      return ['failed'];
    }
    return _makeRequest(
      url: 'https://api.upyun.com/buckets/info',
      method: 'GET',
      headers: {'Authorization': 'Bearer ${configMap['token']}'},
      params: {'bucket_name': bucketName},
      onSuccess: (response) => ['success', response.data],
      checkSuccess: (response) => response.statusCode == 200,
      callFunction: 'getBucketInfo',
    );
  }

  deleteBucket(String bucketName) async {
    var configMap = await getUpyunManageConfigMap();
    if (configMap == 'Error') {
      return ['failed'];
    }
    return _makeRequest(
      url: 'https://api.upyun.com/buckets/delete',
      method: 'POST',
      headers: {'Authorization': 'Bearer ${configMap['token']}'},
      data: {
        'bucket_name': bucketName,
        'password': configMap['password'],
      },
      onSuccess: (_) => ['success'],
      checkSuccess: (response) => response.statusCode == 200,
      callFunction: 'deleteBucket',
    );
  }

  putBucket(String bucketName) async {
    var configMap = await getUpyunManageConfigMap();
    if (configMap == 'Error') {
      return ['failed'];
    }
    return _makeRequest(
      url: 'https://api.upyun.com/buckets',
      method: 'PUT',
      headers: {'Authorization': 'Bearer ${configMap['token']}'},
      data: {
        'bucket_name': bucketName,
        'type': 'file',
      },
      onSuccess: (_) => ['success'],
      checkSuccess: (response) => response.statusCode == 201,
      callFunction: 'putBucket',
    );
  }

  getOperator(String bucketName) async {
    var configMap = await getUpyunManageConfigMap();
    if (configMap == 'Error') {
      return ['failed'];
    }
    return _makeRequest(
      url: 'https://api.upyun.com/buckets/operators',
      method: 'GET',
      headers: {'Authorization': 'Bearer ${configMap['token']}'},
      params: {'bucket_name': bucketName},
      onSuccess: (response) => ['success', response.data['operators']],
      checkSuccess: (response) => response.statusCode == 200,
      callFunction: 'getOperator',
    );
  }

  addOperator(String bucketName, String operatorName) async {
    var configMap = await getUpyunManageConfigMap();
    if (configMap == 'Error') {
      return ['failed'];
    }
    return _makeRequest(
      url: 'https://api.upyun.com/buckets/operators',
      method: 'PUT',
      headers: {'Authorization': 'Bearer ${configMap['token']}'},
      data: {
        'bucket_name': bucketName,
        'operator_name': operatorName,
      },
      onSuccess: (_) => ['success'],
      checkSuccess: (response) => response.statusCode == 201,
      callFunction: 'addOperator',
    );
  }

  deleteOperator(String bucketName, String operatorName) async {
    var configMap = await getUpyunManageConfigMap();
    if (configMap == 'Error') {
      return ['failed'];
    }
    return _makeRequest(
      url: 'https://api.upyun.com/buckets/operators',
      method: 'DELETE',
      headers: {'Authorization': 'Bearer ${configMap['token']}'},
      params: {
        'bucket_name': bucketName,
        'operator_name': operatorName,
      },
      onSuccess: (_) => ['success'],
      checkSuccess: (response) => response.statusCode == 200,
      callFunction: 'deleteOperator',
    );
  }

  //存储桶设为默认图床
  setDefaultBucketFromListPage(Map element, Map upyunManageConfigMap, Map textMap) async {
    try {
      String bucket = element['bucket_name'];
      var queryOperator = await readUpyunOperatorConfig();
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
      final upyunConfigFile = await localFile();
      await upyunConfigFile.writeAsString(upyunConfigJson);
      return ['success'];
    } catch (e) {
      flogErr(
          e,
          {
            'element': element,
            'upyunManageConfigMap': upyunManageConfigMap,
            'textMap': textMap,
          },
          'UpyunManageAPI',
          'setDefaultBucketFromListPage');
      return ['failed'];
    }
  }

  queryBucketFiles(Map element, String prefix) async {
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
      if (response.statusCode != 200) {
        flogErr(
            response,
            {
              'url': url,
              'headers': baseoptions.headers,
            },
            'UpyunManageAPI',
            'queryBucketFiles');
        return ['failed'];
      }

      if (responseMap['iter'] == null || responseMap['iter'].toString().isEmpty) {
        return ['success', responseMap['files']];
      }
      Map tempMap = Map.from(responseMap);
      while (tempMap['iter'] != null &&
          tempMap['iter'].toString().isNotEmpty &&
          tempMap['iter'].toString() != 'g2gCZAAEbmV4dGQAA2VvZg') {
        marker = tempMap['iter'];
        baseoptions.headers['x-list-iter'] = marker;
        dio = Dio(baseoptions);
        response = await dio.get(url);
        tempMap = response.data;
        if (response.statusCode != 200 || tempMap['files'] == null) {
          return ['failed'];
        }
        responseMap['files'].addAll(tempMap['files']);
      }

      return ['success', responseMap['files']];
    } catch (e) {
      flogErr(e, {'prefix': prefix}, 'UpyunManageAPI', 'queryBucketFiles');
      return [e.toString()];
    }
  }

  //判断是否为空存储桶
  isEmptyBucket(Map element) async {
    var queryResult = await queryBucketFiles(element, '/');
    if (queryResult[0] != 'success') {
      return ['error'];
    }
    return queryResult[1].length == 0 ? ['empty'] : ['notempty'];
  }

  //新建文件夹
  createFolder(Map element, String prefix, String newfolder) async {
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
      }
      flogErr(
          response,
          {
            'url': url,
            'headers': baseoptions.headers,
          },
          'UpyunManageAPI',
          'createFolder');
      return ['failed'];
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
  deleteFile(Map element, String prefix, String key) async {
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
        flogErr(
            response,
            {
              'url': url,
              'headers': baseoptions.headers,
            },
            'UpyunManageAPI',
            'deleteFile');
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
  deleteFolder(Map element, String prefix) async {
    var queryResult = await queryBucketFiles(element, prefix);
    try {
      if (queryResult[0] != 'success') {
        return ['failed'];
      }

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
    } catch (e) {
      flogErr(e, {'prefix': prefix}, 'UpyunManageAPI', 'deleteFolder');
      return ['failed'];
    }
  }

  //目录设为默认图床
  setDefaultBucket(Map element, String? folder) async {
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
      final upyunConfigFile = await localFile();
      await upyunConfigFile.writeAsString(upyunConfigJson);
      return ['success'];
    } catch (e) {
      flogErr(e, {'folder': folder}, 'UpyunManageAPI', 'setDefaultBucket');
      return ['failed'];
    }
  }

  //重命名文件
  renameFile(Map element, String prefix, String key, String newKey) async {
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
  queryDuplicateName(Map element, String prefix, String key) async {
    var queryResult = await queryBucketFiles(element, prefix);
    if (queryResult[0] == 'success') {
      for (var i = 0; i < queryResult[1].length; i++) {
        if (queryResult[1][i]['name'] == key) {
          return ['duplicate'];
        }
      }
      return ['notduplicate'];
    }
    return ['error'];
  }

  //上传文件
  uploadFile(
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
      }
      return ['failed'];
    } catch (e) {
      flogErr(e, {'filename': filename, 'filepath': filepath, 'prefix': prefix}, 'UpyunManageAPI', 'uploadFile');
      return ['error'];
    }
  }

  //从网络链接下载文件后上传
  uploadNetworkFile(String fileLink, Map element, String prefix) async {
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
        }
      }
      return ['failed'];
    } catch (e) {
      flogErr(e, {'fileLink': fileLink, 'prefix': prefix}, 'UpyunManageAPI', 'uploadNetworkFile');
      return ['failed'];
    }
  }

  uploadNetworkFileEntry(List fileList, Map element, String prefix) async {
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
      return showToast('上传失败');
    } else if (failCount == 0) {
      return showToast('上传成功');
    }
    return showToast('成功$successCount,失败$failCount');
  }
}
