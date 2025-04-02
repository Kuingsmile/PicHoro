import 'dart:io';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:crypto/crypto.dart';
import 'package:horopic/picture_host_manage/common/base_manage_api.dart';
import 'package:xml2json/xml2json.dart';
import 'package:path_provider/path_provider.dart';

import 'package:horopic/utils/global.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/picture_host_configure/configure_page/tencent_configure.dart';
import 'package:horopic/api/tencent_api.dart';

class TencentManageAPI extends BaseManageApi {
  static final TencentManageAPI _instance = TencentManageAPI._internal();

  factory TencentManageAPI() {
    return _instance;
  }

  TencentManageAPI._internal();

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
    'eu-frankfurt': '法兰克福'
  };

  @override
  String configFileName() => 'tencent_config.txt';

  //authorization
  String tecentAuthorization(
      String method, String urlpath, Map header, String secretId, String secretKey, Map? urlParam) {
    int startTimestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    int endTimestamp = startTimestamp + 86400;
    String keyTime = '$startTimestamp;$endTimestamp';

    String signKey = Hmac(sha1, utf8.encode(secretKey)).convert(utf8.encode(keyTime)).toString();
    String lowerMethod = method.toLowerCase();

    String urlParamList = '';
    String httpParameters = '';

    if (urlParam != null && urlParam.isNotEmpty) {
      Map uriEncodeUrlParam = {};
      urlParam.forEach((key, value) {
        uriEncodeUrlParam[Uri.encodeComponent(key).toLowerCase()] = Uri.encodeComponent(value.toString());
      });

      List urlParamKeyList = uriEncodeUrlParam.keys.toList();
      urlParamKeyList.sort();

      for (var i = 0; i < urlParamKeyList.length; i++) {
        urlParamList = '${urlParamList + urlParamKeyList[i]};';
        httpParameters = '${httpParameters + urlParamKeyList[i]}=${uriEncodeUrlParam[urlParamKeyList[i]]}&';
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
      uriEncodeHeader[Uri.encodeComponent(key).toLowerCase()] = Uri.encodeComponent(value);
    });
    List headerKeyList = uriEncodeHeader.keys.toList();
    headerKeyList.sort();
    for (var i = 0; i < headerKeyList.length; i++) {
      headerList = '${headerList + headerKeyList[i]};';
      httpHeaders = '${httpHeaders + headerKeyList[i]}=${uriEncodeHeader[headerKeyList[i]]}&';
    }
    if (httpHeaders.isNotEmpty) {
      httpHeaders = httpHeaders.substring(0, httpHeaders.length - 1);
    }
    if (headerList.isNotEmpty) {
      headerList = headerList.substring(0, headerList.length - 1);
    }

    String httpString = '$lowerMethod\n$urlpath\n$httpParameters\n$httpHeaders\n';
    String stringtosign = 'sha1\n$keyTime\n${sha1.convert(utf8.encode(httpString)).toString()}\n';

    String signature = Hmac(sha1, utf8.encode(signKey)).convert(utf8.encode(stringtosign)).toString();
    String authorization =
        'q-sign-algorithm=sha1&q-ak=$secretId&q-sign-time=$keyTime&q-key-time=$keyTime&q-header-list=$headerList&q-url-param-list=$urlParamList&q-signature=$signature';
    return authorization;
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
          response,
          {
            'url': url,
            'data': data,
            'method': method,
            'params': params,
            'headers': headers,
          },
          "TencentManageAPI",
          callFunction);
      return ['failed'];
    } catch (e) {
      flogErr(e, {'url': url, 'data': data, 'method': method, 'params': params, 'headers': headers}, "TencentManageAPI",
          callFunction);
      return [e.toString()];
    }
  }

  //获取存储桶列表
  getBucketList() async {
    try {
      Map configMap = await getConfigMap();
      Map<String, dynamic> header = {
        'Host': 'service.cos.myqcloud.com',
      };
      String authorization = tecentAuthorization('GET', '/', header, configMap['secretId'], configMap['secretKey'], {});
      header['Authorization'] = authorization;
      return await _makeRequest(
        url: 'https://service.cos.myqcloud.com',
        method: 'GET',
        headers: header,
        onSuccess: (response) {
          String responseBody = response.data;
          final myTransformer = Xml2Json();
          myTransformer.parse(responseBody);
          Map responseMap = json.decode(myTransformer.toParker());
          return ['success', responseMap];
        },
        checkSuccess: (response) => response.statusCode == 200,
        callFunction: 'getBucketList',
      );
    } catch (e) {
      flogErr(e, {}, "TencentManageAPI", "getBucketList");
      return ['failed'];
    }
  }

  //新建存储桶
  createBucket(Map newBucketConfigMap) async {
    try {
      Map configMap = await getConfigMap();
      String bucket = newBucketConfigMap['bucketName'];
      String region = newBucketConfigMap['region'];
      if (!bucket.endsWith('-appId')) {
        bucket = '$bucket-${configMap['appId']}';
      }
      bool multiAZ = newBucketConfigMap['multiAZ'];
      List multiAZList = ['ap-beijing', 'ap-guangzhou', 'ap-shanghai', 'ap-singapore'];
      if (multiAZ == true && !multiAZList.contains(region)) {
        return [
          'multiAZ error',
        ];
      }
      String body = '<CreateBucketConfiguration><BucketAZConfig>MAZ</BucketAZConfig></CreateBucketConfiguration>';
      String bodyMd5 = base64.encode(md5.convert(utf8.encode(body)).bytes);
      Map<String, dynamic> header = {
        'Host': '$bucket.cos.$region.myqcloud.com',
        'x-cos-acl': newBucketConfigMap['xCosACL'],
        if (multiAZ == true) ...{
          'content-type': 'application/xml',
          'content-length': body.length.toString(),
          'content-md5': bodyMd5,
        },
      };
      String authorization = tecentAuthorization('PUT', '/', header, configMap['secretId'], configMap['secretKey'], {});
      header['Authorization'] = authorization;
      return await _makeRequest(
        url: 'https://$bucket.cos.$region.myqcloud.com',
        method: 'PUT',
        headers: header,
        data: multiAZ == true ? body : null,
        onSuccess: (response) => ['success'],
        checkSuccess: (response) => response.statusCode == 200,
        callFunction: 'createBucket',
      );
    } catch (e) {
      flogErr(e, {'newBucketConfigMap': newBucketConfigMap}, "TencentManageAPI", "createBucket");
      return ['failed'];
    }
  }

  //删除存储桶
  deleteBucket(Map element) async {
    try {
      Map configMap = await getConfigMap();
      String host = '${element['name']}.cos.${element['location']}.myqcloud.com';
      Map<String, dynamic> header = {
        'Host': host,
      };
      String authorization =
          tecentAuthorization('DELETE', '/', header, configMap['secretId'], configMap['secretKey'], {});
      header['Authorization'] = authorization;
      return await _makeRequest(
        url: 'https://$host',
        method: 'DELETE',
        headers: header,
        onSuccess: (response) => ['success'],
        checkSuccess: (response) => response.statusCode == 204,
        callFunction: 'deleteBucket',
      );
    } catch (e) {
      flogErr(e, {'element': element}, "TencentManageAPI", "deleteBucket");
      return ['failed'];
    }
  }

  //查询存储桶权限
  queryACLPolicy(Map element) async {
    try {
      Map configMap = await getConfigMap();
      Map<String, dynamic> header = {
        'Host': '${element['name']}.cos.${element['location']}.myqcloud.com',
      };
      String authorization =
          tecentAuthorization('GET', '/', header, configMap['secretId'], configMap['secretKey'], {'acl': ''});
      header['Authorization'] = authorization;
      return await _makeRequest(
        url: 'https://${element['name']}.cos.${element['location']}.myqcloud.com/?acl',
        method: 'GET',
        headers: header,
        onSuccess: (response) {
          String responseBody = response.data;
          final myTransformer = Xml2Json();
          myTransformer.parse(responseBody);
          Map responseMap = json.decode(myTransformer.toParker());
          return ['success', responseMap];
        },
        checkSuccess: (response) => response.statusCode == 200,
        callFunction: 'queryACLPolicy',
      );
    } catch (e) {
      flogErr(e, {'element': element}, "TencentManageAPI", "queryACLPolicy");
      return ['failed'];
    }
  }

  //更改存储桶权限
  changeACLPolicy(Map element, String newACL) async {
    try {
      Map configMap = await getConfigMap();
      Map<String, dynamic> header = {
        'Host': '${element['name']}.cos.${element['location']}.myqcloud.com',
        'x-cos-acl': newACL,
      };
      String authorization =
          tecentAuthorization('PUT', '/', header, configMap['secretId'], configMap['secretKey'], {'acl': ''});
      header['Authorization'] = authorization;
      return await _makeRequest(
        url: 'https://${element['name']}.cos.${element['location']}.myqcloud.com/?acl',
        method: 'PUT',
        headers: header,
        onSuccess: (response) => ['success'],
        checkSuccess: (response) => response.statusCode == 200,
        callFunction: 'changeACLPolicy',
      );
    } catch (e) {
      flogErr(e, {'element': element, 'newACL': newACL}, "TencentManageAPI", "changeACLPolicy");
      return ['failed'];
    }
  }

  //存储桶设为默认图床
  setDefaultBucket(Map element, String? folder) async {
    try {
      Map configMap = await getConfigMap();
      final tencentConfig = TencentConfigModel(
          configMap['secretId'],
          configMap['secretKey'],
          element['name'],
          configMap['appId'],
          element['location'],
          folder ?? configMap['path'],
          configMap['customUrl'],
          configMap['options']);
      final tencentConfigJson = jsonEncode(tencentConfig);
      final tencentConfigFile = await localFile();
      await tencentConfigFile.writeAsString(tencentConfigJson);
      return ['success'];
    } catch (e) {
      flogErr(e, {'element': element, 'folder': folder}, "TencentManageAPI", "setDefaultBucket");
      return ['failed'];
    }
  }

  //查询存储桶文件列表
  queryBucketFiles(Map element, Map<String, dynamic> query) async {
    try {
      Map configMap = await getConfigMap();
      String bucket = element['name'];
      String region = element['location'];
      String host = '$bucket.cos.$region.myqcloud.com';
      Map<String, dynamic> header = {
        'Host': host,
      };
      query['max-keys'] = 1000;

      String authorization =
          tecentAuthorization('GET', '/', header, configMap['secretId'], configMap['secretKey'], query);

      BaseOptions baseoptions = setBaseOptions();
      baseoptions.headers = header;
      baseoptions.headers['Authorization'] = authorization;
      Dio dio = Dio(baseoptions);

      String marker = '';
      var response = await dio.get('https://$host', queryParameters: query);
      var responseBody = response.data;
      final myTransformer = Xml2Json();
      myTransformer.parse(responseBody);
      Map responseMap = json.decode(myTransformer.toParker());
      if (response.statusCode != 200) {
        return ['failed'];
      }

      if (responseMap['ListBucketResult']['IsTruncated'] == null ||
          responseMap['ListBucketResult']['IsTruncated'] == 'false') {
        return ['success', responseMap];
      }

      Map tempMap = Map.from(responseMap);
      while (tempMap['ListBucketResult']['IsTruncated'] == 'true') {
        marker = tempMap['ListBucketResult']['NextMarker'];
        query['marker'] = marker;
        response = await dio.get('https://$host', queryParameters: query);
        responseBody = response.data;
        myTransformer.parse(responseBody);
        tempMap.clear();
        tempMap = json.decode(myTransformer.toParker());
        if (response.statusCode != 200) {
          return ['failed'];
        }

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
              responseMap['ListBucketResult']['CommonPrefixes'] = [responseMap['ListBucketResult']['CommonPrefixes']];
            }
            responseMap['ListBucketResult']['CommonPrefixes'].addAll(tempMap['ListBucketResult']['CommonPrefixes']);
          }
        }
      }
      return ['success', responseMap];
    } catch (e) {
      flogErr(e, {'element': element, 'query': query}, "TencentManageAPI", "queryBucketFiles");
      return [e.toString()];
    }
  }

  //判断是否为空存储桶
  isEmptyBucket(Map element) async {
    var queryResult = await queryBucketFiles(element, {});
    if (queryResult[0] != 'success') {
      return ['error'];
    }
    if (queryResult[1]['ListBucketResult']['Contents'] == null &&
        queryResult[1]['ListBucketResult']['CommonPrefixes'] == null) {
      return ['empty'];
    }
    return ['notempty'];
  }

  //删除文件
  deleteFile(Map element, String key) async {
    try {
      Map configMap = await getConfigMap();
      Map<String, dynamic> header = {
        'Host': '${element['name']}.cos.${element['location']}.myqcloud.com',
      };
      String authorization =
          tecentAuthorization('DELETE', '/$key', header, configMap['secretId'], configMap['secretKey'], {});
      header['Authorization'] = authorization;
      return await _makeRequest(
        url: 'https://${element['name']}.cos.${element['location']}.myqcloud.com/$key',
        method: 'DELETE',
        headers: header,
        onSuccess: (response) => ['success'],
        checkSuccess: (response) => response.statusCode == 204,
        callFunction: 'deleteFile',
      );
    } catch (e) {
      flogErr(e, {'element': element, 'key': key}, "TencentManageAPI", "deleteFile");
      return ['failed'];
    }
  }

  //删除文件夹
  deleteFolder(Map element, String key) async {
    var queryResult = await queryBucketFiles(element, {
      'prefix': key,
      'delimiter': '/',
    });
    if (queryResult[0] != 'success') {
      return ['failed'];
    }

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
  }

  //重命名文件
  copyFile(Map element, String key, String newKey) async {
    try {
      Map configMap = await getConfigMap();
      String host = '${element['name']}.cos.${element['location']}.myqcloud.com';
      String newName = key.substring(0, key.lastIndexOf('/') + 1) == ''
          ? newKey
          : key.substring(0, key.lastIndexOf('/') + 1) + newKey;
      Map<String, dynamic> header = {
        'Host': host,
        'x-cos-copy-source': '/$host/${Uri.encodeComponent(key)}',
      };
      String authorization =
          tecentAuthorization('PUT', '/$newName', header, configMap['secretId'], configMap['secretKey'], {});
      header['Authorization'] = authorization;
      return await _makeRequest(
        url: 'https://$host/$newName',
        method: 'PUT',
        headers: header,
        onSuccess: (response) => ['success'],
        checkSuccess: (response) => response.statusCode == 200,
        callFunction: 'copyFile',
      );
    } catch (e) {
      flogErr(e, {'element': element, 'key': key}, "TencentManageAPI", "copyFile");
      return ['failed'];
    }
  }

  //查询是否有重名文件
  queryDuplicateName(Map element, String? prefix, String key) async {
    var queryResult = await queryBucketFiles(element, {
      'prefix': prefix,
      'delimiter': '/',
    });
    if (queryResult[0] != 'success') {
      return ['error'];
    }

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
  }

  //新建文件夹
  createFolder(Map element, String prefix, String newfolder) async {
    try {
      Map configMap = await getConfigMap();
      String urlpath = '/$prefix$newfolder';
      if (urlpath.substring(urlpath.length - 1) != '/') {
        urlpath = '$urlpath/';
      }
      Map<String, dynamic> header = {
        'Host': '${element['name']}.cos.${element['location']}.myqcloud.com',
      };
      String authorization =
          tecentAuthorization('PUT', urlpath, header, configMap['secretId'], configMap['secretKey'], {});
      header['Authorization'] = authorization;
      return await _makeRequest(
        url: 'https://${element['name']}.cos.${element['location']}.myqcloud.com$urlpath',
        method: 'PUT',
        headers: header,
        onSuccess: (response) => ['success'],
        checkSuccess: (response) => response.statusCode == 200,
        callFunction: 'createFolder',
      );
    } catch (e) {
      flogErr(e, {'element': element, 'prefix': prefix, 'newfolder': newfolder}, "TencentManageAPI", "createFolder");
      return ['failed'];
    }
  }

  //上传文件
  uploadFile(
    Map element,
    String filename,
    String filepath,
    String prefix,
  ) async {
    try {
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
      String singature = TencentImageUploadUtils.getUploadAuthorization(secretKey, keyTime, uploadPolicyStr);
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
      flogErr(e, {'element': element, 'filename': filename, 'filepath': filepath, 'prefix': prefix}, "TencentManageAPI",
          "uploadFile");
      return ['error'];
    }
  }

  //上传文件API入口
  upLoadFileEntry(List fileList, Map element, String prefix) async {
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
        return showToast('配置错误');
      } else if (uploadResult[0] == "success") {
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
        } else {
          return ['failed'];
        }
      } else {
        return ['failed'];
      }
    } catch (e) {
      flogErr(e, {'fileLink': fileLink, 'element': element, 'prefix': prefix}, "TencentManageAPI", "uploadNetworkFile");
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
