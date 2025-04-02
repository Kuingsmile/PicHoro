import 'dart:io';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:horopic/picture_host_manage/common/base_manage_api.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as my_path;
import 'package:xml2json/xml2json.dart';

import 'package:horopic/utils/global.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/picture_host_configure/configure_page/aliyun_configure.dart';

class AliyunManageAPI extends BaseManageApi {
  static final AliyunManageAPI _instance = AliyunManageAPI._internal();

  factory AliyunManageAPI() {
    return _instance;
  }

  AliyunManageAPI._internal();
  Map<String, String> areaCodeName = {
    'oss-cn-hangzhou': '华东1(杭州)',
    'oss-cn-shanghai': '华东2(上海)',
    'oss-cn-nanjing': '华东5(南京本地地域)',
    'oss-cn-fuzhou': '华东6(福州本地地域)',
    'oss-cn-wuhan-lr': '华中1(武汉本地地域)',
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

  @override
  String configFileName() => 'aliyun_config.txt';

  //get CanonicalizedOSSHeaders
  getCanonicalizedOSSHeaders(Map headers) {
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
  Future<String> aliyunAuthorization(
      String method, String canonicalizedResource, Map headers, String contentMd5, String contentType) async {
    try {
      Map configMap = await getConfigMap();
      String accessKeyId = configMap['keyId'];
      String accessKeySecret = configMap['keySecret'];
      String gmtDate = headers['Date'] ?? HttpDate.format(DateTime.now());
      String uperCaseMethod = method.toUpperCase();
      String canonicalizedOSSHeaders = getCanonicalizedOSSHeaders(headers);
      String stringToSign =
          "$uperCaseMethod\n$contentMd5\n$contentType\n$gmtDate\n$canonicalizedOSSHeaders$canonicalizedResource";
      String signature =
          base64.encode(Hmac(sha1, utf8.encode(accessKeySecret)).convert(utf8.encode(stringToSign)).bytes);
      return "OSS $accessKeyId:$signature";
    } catch (e) {
      flogErr(
          e,
          {
            'method': method,
            'canonicalizedResource': canonicalizedResource,
            'headers': headers,
            'contentMd5': contentMd5,
            'contentType': contentType,
          },
          'AliyunManageAPI',
          'aliyunAuthorization');
      rethrow;
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
          response,
          {
            'url': url,
            'data': data,
            'method': method,
            'params': params,
            'headers': headers,
          },
          "AliyunManageAPI",
          callFunction);
      return ['failed'];
    } catch (e) {
      flogErr(e, {'url': url, 'data': data, 'method': method, 'params': params, 'headers': headers}, "AliyunManageAPI",
          callFunction);
      return [e.toString()];
    }
  }

  //获取bucket列表
  getBucketList() async {
    String authorization = await aliyunAuthorization('GET', '/', {}, '', '');
    return await _makeRequest(
      url: 'https://oss-cn-hangzhou.aliyuncs.com',
      method: 'GET',
      headers: {
        'Authorization': authorization,
        'Date': HttpDate.format(DateTime.now()),
      },
      params: {'max-keys': 1000},
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
  }

  final List<String> _multiAZSupportedRegions = [
    'oss-cn-shenzhen',
    'oss-cn-beijing',
    'oss-cn-hangzhou',
    'oss-cn-shanghai',
    'oss-cn-hongkong',
    'oss-ap-southeast-1',
    'oss-ap-southeast-5'
  ];

  //新建存储桶
  createBucket(Map newBucketConfigMap) async {
    bool multiAZ = newBucketConfigMap['multiAZ'];
    String region = newBucketConfigMap['region'];
    if (multiAZ == true && !_multiAZSupportedRegions.contains(region)) {
      return [
        'multiAZ error',
      ];
    }
    String body = '<CreateBucketConfiguration><DataRedundancyType>ZRS</DataRedundancyType></CreateBucketConfiguration>';
    String contentMd5 = await getContentMd5(body);
    Map<String, dynamic> headers = {
      'Date': HttpDate.format(DateTime.now()),
      'x-oss-acl': newBucketConfigMap['xCosACL'],
      if (multiAZ == true) 'content-type': 'application/xml' else 'content-type': 'application/json',
      if (multiAZ == true) 'content-length': body.length.toString(),
      if (multiAZ == true) 'content-md5': contentMd5,
    };
    String authorization = await aliyunAuthorization(
      'PUT',
      '/${newBucketConfigMap['bucketName']}/',
      headers,
      contentMd5,
      multiAZ == true ? 'application/xml' : 'application/json',
    );
    headers['Authorization'] = authorization;
    return await _makeRequest(
      url: 'https://${newBucketConfigMap['bucketName']}.$region.aliyuncs.com',
      method: 'PUT',
      headers: headers,
      data: multiAZ == true ? body : null,
      onSuccess: (response) => ['success'],
      checkSuccess: (response) => response.statusCode == 200,
      callFunction: 'createBucket',
    );
  }

  //查询存储桶权限
  queryACLPolicy(Map element) async {
    Map<String, dynamic> headers = {
      'Date': HttpDate.format(DateTime.now()),
    };
    String authorization = await aliyunAuthorization('GET', '/${element['name']}/?acl', headers, '', '');
    headers['Authorization'] = authorization;
    return await _makeRequest(
      url: 'https://${element['name']}.${element['location']}.aliyuncs.com/?acl',
      method: 'GET',
      headers: headers,
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
  }

  /// 删除存储桶
  deleteBucket(Map element) async {
    Map<String, dynamic> headers = {
      'Date': HttpDate.format(DateTime.now()),
      'content-type': 'application/json',
    };
    String authorization = await aliyunAuthorization('DELETE', '/${element['name']}/', headers, '', 'application/json');
    headers['Authorization'] = authorization;
    return await _makeRequest(
      url: 'https://${element['name']}.${element['location']}.aliyuncs.com',
      method: 'DELETE',
      headers: headers,
      onSuccess: (response) => ['success'],
      checkSuccess: (response) => response.statusCode == 204,
      callFunction: 'deleteBucket',
    );
  }

  /// 更改存储桶权限
  changeACLPolicy(Map element, String newACL) async {
    Map<String, dynamic> headers = {
      'Date': HttpDate.format(DateTime.now()),
      'x-oss-acl': newACL,
      'content-type': 'application/json',
    };
    String authorization =
        await aliyunAuthorization('PUT', '/${element['name']}/?acl', headers, '', 'application/json');
    headers['Authorization'] = authorization;
    return await _makeRequest(
      url: 'https://${element['name']}.${element['location']}.aliyuncs.com/?acl',
      method: 'PUT',
      headers: headers,
      onSuccess: (response) => ['success'],
      checkSuccess: (response) => response.statusCode == 200,
      callFunction: 'changeACLPolicy',
    );
  }

  //存储桶设为默认图床
  setDefaultBucket(Map element, String? folder) async {
    try {
      Map configMap = await getConfigMap();
      final aliyunConfig = AliyunConfigModel(configMap['keyId'], configMap['keySecret'], element['name'],
          element['location'], folder ?? configMap['path'], configMap['customUrl'], configMap['options']);
      final aliyunConfigJson = jsonEncode(aliyunConfig);
      final aliyunConfigFile = await localFile();
      await aliyunConfigFile.writeAsString(aliyunConfigJson);
      return ['success'];
    } catch (e) {
      flogErr(
          e,
          {
            'element': element,
            'folder': folder,
          },
          "AliyunManageAPI",
          "setDefaultBucket");
      return ['failed'];
    }
  }

  //查询存储桶文件列表
  queryBucketFiles(Map element, Map<String, dynamic> query) async {
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
      if (response.statusCode != 200) {
        flogErr(
            response,
            {
              'url': 'https://$host/',
              'query': query,
              'responseBody': responseBody,
            },
            "AliyunManageAPI",
            "queryBucketFiles");
        return ['failed'];
      }
      if (responseMap['ListBucketResult']['IsTruncated'] == null ||
          responseMap['ListBucketResult']['IsTruncated'] == 'false') {
        return ['success', responseMap];
      }
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
      flogErr(
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

  copyFile(Map element, String key, String newKey) async {
    String newName =
        key.substring(0, key.lastIndexOf('/') + 1) == '' ? newKey : key.substring(0, key.lastIndexOf('/') + 1) + newKey;
    String host = '${element['name']}.${element['location']}.aliyuncs.com';
    Map<String, dynamic> headers = {
      'Date': HttpDate.format(DateTime.now()),
      'x-oss-copy-source': '/${element['name']}/${Uri.encodeComponent(key)}',
      'x-oss-forbid-overwrite': 'false',
      'Host': host,
      'content-type': 'application/json',
    };
    String authorization = await aliyunAuthorization(
      'PUT',
      '/${element['name']}/$newName',
      headers,
      '',
      'application/json',
    );
    headers['Authorization'] = authorization;
    return await _makeRequest(
      url: 'https://$host/$newName',
      method: 'PUT',
      headers: headers,
      onSuccess: (response) => ['success'],
      checkSuccess: (response) => response.statusCode == 200,
      callFunction: 'copyFile',
    );
  }

  //删除文件
  deleteFile(Map element, String key) async {
    Map<String, dynamic> headers = {
      'Date': HttpDate.format(DateTime.now()),
      'content-type': 'application/json',
    };
    String authorization =
        await aliyunAuthorization('DELETE', '/${element['name']}/$key', headers, '', 'application/json');
    headers['Authorization'] = authorization;
    return await _makeRequest(
      url: 'https://${element['name']}.${element['location']}.aliyuncs.com/$key',
      method: 'DELETE',
      headers: headers,
      onSuccess: (response) => ['success'],
      checkSuccess: (response) => response.statusCode == HttpStatus.noContent,
      callFunction: 'deleteFile',
    );
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
    String host = '${element['name']}.${element['location']}.aliyuncs.com';
    String urlpath = '/${element['name']}/$prefix$newfolder/';
    if (urlpath.substring(urlpath.length - 1) != '/') {
      urlpath = '$urlpath/';
    }
    Map<String, dynamic> headers = {
      'Date': HttpDate.format(DateTime.now()),
      'content-type': 'application/json',
      'content-length': '0',
      'Host': host,
    };
    String authorization = await aliyunAuthorization('PUT', urlpath, headers, '', 'application/json');
    headers['Authorization'] = authorization;
    String url = 'https://$host/$prefix$newfolder';
    if (url.substring(url.length - 1) != '/') {
      url = '$url/';
    }
    return await _makeRequest(
      url: url,
      method: 'PUT',
      headers: headers,
      onSuccess: (response) => ['success'],
      checkSuccess: (response) => response.statusCode == 200,
      callFunction: 'createFolder',
    );
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
      }
      flogErr(
          response,
          {
            'url': 'https://$host',
            'formData': formData.fields,
            'filename': filename,
            'filepath': filepath,
            'prefix': prefix,
          },
          "AliyunManageAPI",
          "uploadFile");
      return ['failed'];
    } catch (e) {
      flogErr(
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
        }
      }
      return ['failed'];
    } catch (e) {
      flogErr(e, {'fileLink': fileLink, 'element': element, 'prefix': prefix}, "AliyunManageAPI", "uploadNetworkFile");
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
