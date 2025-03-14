import 'dart:io';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/utils/utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:minio/minio.dart';

import 'package:horopic/utils/global.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/picture_host_configure/configure_page/aws_configure.dart';

class AwsManageAPI {
  static Future<File> get localFile async {
    final path = await _localPath;
    String defaultUser = Global.getUser();
    return ensureFileExists(File('$path/${defaultUser}_aws_config.txt'));
  }

  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<String> readAwsConfig() async {
    try {
      final file = await localFile;
      String contents = await file.readAsString();
      return contents;
    } catch (e) {
      flogErr(e, {}, 'AwsManageAPI', 'readAwsConfig');
      return "Error";
    }
  }

  static Future<Map> getConfigMap() async {
    String configStr = await readAwsConfig();
    if (configStr == '') {
      return {};
    }
    Map configMap = json.decode(configStr);
    return configMap;
  }

  static getDate(String type) {
    var now = DateTime.now();
    String iso8601 = now.toUtc().toIso8601String();
    if (type == 'long') {
      return '${iso8601.substring(0, 4)}${iso8601.substring(5, 7)}${iso8601.substring(8, 13)}${iso8601.substring(14, 16)}${iso8601.substring(17, 19)}Z';
    } else if (type == 'short') {
      return '${iso8601.substring(0, 4)}${iso8601.substring(5, 7)}${iso8601.substring(8, 10)}';
    }
  }

  static String encodeCanonicalURI(String path) {
    var result = StringBuffer();
    for (var char in path.codeUnits) {
      if ('A'.codeUnitAt(0) <= char && char <= 'Z'.codeUnitAt(0) ||
          'a'.codeUnitAt(0) <= char && char <= 'z'.codeUnitAt(0) ||
          '0'.codeUnitAt(0) <= char && char <= '9'.codeUnitAt(0)) {
        result.writeCharCode(char);
        continue;
      }

      if (char == '-'.codeUnitAt(0) ||
          char == '_'.codeUnitAt(0) ||
          char == '.'.codeUnitAt(0) ||
          char == '~'.codeUnitAt(0) ||
          char == '/'.codeUnitAt(0) ||
          char == '%'.codeUnitAt(0)) {
        result.writeCharCode(char);
        continue;
      }

      result.write('%');
      result.write(hex([char]).toUpperCase());
    }
    return result.toString();
  }

  //获取存储桶列表
  static getBucketList() async {
    try {
      Map configMap = await getConfigMap();
      String accessKeyId = configMap['accessKeyId'];
      String secretAccessKey = configMap['secretAccessKey'];
      String endpoint = configMap['endpoint'];
      int? port;
      if (endpoint.contains(':')) {
        List<String> endpointList = endpoint.split(':');
        endpoint = endpointList[0];
        port = int.parse(endpointList[1]);
      }
      String region = configMap['region'];
      bool isEnableSSL = configMap['isEnableSSL'] ?? true;

      Minio minio;
      if (region == 'None') {
        minio = Minio(
          endPoint: endpoint,
          port: port,
          accessKey: accessKeyId,
          secretKey: secretAccessKey,
          useSSL: isEnableSSL,
        );
      } else {
        minio = Minio(
          endPoint: endpoint,
          port: port,
          accessKey: accessKeyId,
          secretKey: secretAccessKey,
          useSSL: isEnableSSL,
          region: region,
        );
      }

      var response = await minio.listBuckets();
      return ['success', response];
    } catch (e) {
      flogErr(e, {}, 'AwsManageAPI', 'getBucketList');
      return [e.toString()];
    }
  }

  static getBucketRegion(String bucket) async {
    try {
      Map configMap = await getConfigMap();
      String accessKeyId = configMap['accessKeyId'];
      String secretAccessKey = configMap['secretAccessKey'];
      String endpoint = configMap['endpoint'];
      int? port;
      if (endpoint.contains(':')) {
        List<String> endpointList = endpoint.split(':');
        endpoint = endpointList[0];
        port = int.parse(endpointList[1]);
      }
      bool isEnableSSL = configMap['isEnableSSL'] ?? true;

      if (endpoint.contains('amazonaws.com')) {
        endpoint = 's3.us-east-1.amazonaws.com';
      }
      Minio minio;

      minio = Minio(
        endPoint: endpoint,
        port: port,
        accessKey: accessKeyId,
        secretKey: secretAccessKey,
        useSSL: isEnableSSL,
      );

      var response = await minio.getBucketRegion(bucket);

      return ['success', response];
    } catch (e) {
      flogErr(
          e,
          {
            'bucket': bucket,
          },
          'AwsManageAPI',
          'getBucketRegion');
      return [e.toString()];
    }
  }

  //新建存储桶
  static createBucket(Map newBucketConfigMap) async {
    try {
      Map configMap = await getConfigMap();
      String accessKeyId = configMap['accessKeyId'];
      String secretAccessKey = configMap['secretAccessKey'];
      String bucket = newBucketConfigMap['bucketName'];
      String endpoint = configMap['endpoint'];
      int? port;
      if (endpoint.contains(':')) {
        List<String> endpointList = endpoint.split(':');
        endpoint = endpointList[0];
        port = int.parse(endpointList[1]);
      }
      String region = newBucketConfigMap['region'];
      bool isEnableSSL = configMap['isEnableSSL'] ?? true;

      if (endpoint.contains('amazonaws.com')) {
        if (!endpoint.contains(region)) {
          endpoint = 's3.$region.amazonaws.com';
        }
      }

      Minio minio;
      if (region == 'None') {
        minio = Minio(
          endPoint: endpoint,
          port: port,
          accessKey: accessKeyId,
          secretKey: secretAccessKey,
          useSSL: isEnableSSL,
        );
      } else {
        minio = Minio(
          endPoint: endpoint,
          port: port,
          accessKey: accessKeyId,
          secretKey: secretAccessKey,
          useSSL: isEnableSSL,
          region: region,
        );
      }

      if (region == 'None') {
        await minio.makeBucket(bucket);
      } else {
        await minio.makeBucket(bucket, region);
      }
      return ['success'];
    } catch (e) {
      flogErr(
          e,
          {
            'newBucketConfigMap': newBucketConfigMap,
          },
          'AwsManageAPI',
          'createBucket');
      return [e.toString()];
    }
  }

  //删除存储桶
  static deleteBucket(Map element) async {
    try {
      Map configMap = await getConfigMap();
      String accessKeyId = configMap['accessKeyId'];
      String secretAccessKey = configMap['secretAccessKey'];
      String bucket = element['name'];
      String endpoint = configMap['endpoint'];
      int? port;
      if (endpoint.contains(':')) {
        List<String> endpointList = endpoint.split(':');
        endpoint = endpointList[0];
        port = int.parse(endpointList[1]);
      }
      String region = element['region'];
      bool isEnableSSL = configMap['isEnableSSL'] ?? true;

      if (endpoint.contains('amazonaws.com')) {
        if (!endpoint.contains(region)) {
          endpoint = 's3.$region.amazonaws.com';
        }
      }
      Minio minio;
      if (region == 'None') {
        minio = Minio(
          endPoint: endpoint,
          port: port,
          accessKey: accessKeyId,
          secretKey: secretAccessKey,
          useSSL: isEnableSSL,
        );
      } else {
        minio = Minio(
          endPoint: endpoint,
          port: port,
          accessKey: accessKeyId,
          secretKey: secretAccessKey,
          useSSL: isEnableSSL,
          region: region,
        );
      }

      var response = await minio.removeBucket(bucket);

      return ['success', response];
    } catch (e) {
      flogErr(
          e,
          {
            'element': element,
          },
          'AwsManageAPI',
          'deleteBucket');
      return [e.toString()];
    }
  }

  //存储桶设为默认图床
  static setDefaultBucket(Map element, String? folder) async {
    try {
      Map configMap = await getConfigMap();
      String accessKeyId = configMap['accessKeyId'];
      String secretAccessKey = configMap['secretAccessKey'];
      String bucket = element['name'];
      String endpoint = configMap['endpoint'];
      String region = element['region'];
      String uploadPath = '';
      String customUrl = configMap['customUrl'];
      bool isS3PathStyle = configMap['isS3PathStyle'] ?? false;
      bool isEnableSSL = configMap['isEnableSSL'] ?? true;

      if (endpoint.contains('amazonaws.com')) {
        if (!endpoint.contains(region)) {
          endpoint = 's3.$region.amazonaws.com';
        }
      }

      if (folder == null) {
        uploadPath = configMap['uploadPath'];
      } else {
        uploadPath = folder;
      }

      final awsConfig = AwsConfigModel(
          accessKeyId, secretAccessKey, bucket, endpoint, region, uploadPath, customUrl, isS3PathStyle, isEnableSSL);
      final awsConfigJson = jsonEncode(awsConfig);
      final awsConfigFile = await localFile;
      await awsConfigFile.writeAsString(awsConfigJson);
      return ['success'];
    } catch (e) {
      flogErr(e, {'element': element, 'folder': folder}, 'AwsManageAPI', 'setDefaultBucket');
      return ['failed'];
    }
  }

  //查询存储桶文件列表
  static queryBucketFiles(Map element, Map<String, dynamic> query) async {
    try {
      Map configMap = await getConfigMap();
      String accessKeyId = configMap['accessKeyId'];
      String secretAccessKey = configMap['secretAccessKey'];
      String bucket = element['name'];
      String endpoint = configMap['endpoint'];
      int? port;
      if (endpoint.contains(':')) {
        List<String> endpointList = endpoint.split(':');
        endpoint = endpointList[0];
        port = int.parse(endpointList[1]);
      }
      String region = element['region'];
      bool isEnableSSL = configMap['isEnableSSL'] ?? true;

      if (endpoint.contains('amazonaws.com')) {
        if (!endpoint.contains(region)) {
          endpoint = 's3.$region.amazonaws.com';
        }
      }

      Minio minio;
      if (region == 'None') {
        minio = Minio(
          endPoint: endpoint,
          port: port,
          accessKey: accessKeyId,
          secretKey: secretAccessKey,
          useSSL: isEnableSSL,
        );
      } else {
        minio = Minio(
          endPoint: endpoint,
          port: port,
          accessKey: accessKeyId,
          secretKey: secretAccessKey,
          useSSL: isEnableSSL,
          region: region,
        );
      }

      Map objects = {
        'contents': [],
        'commonPrefixes': [],
      };
      var result = await minio.listAllObjectsV2(
        bucket,
        prefix: '${query['prefix']}',
        recursive: false,
      );
      objects['Contents'] = result.objects;
      objects['CommonPrefixes'] = result.prefixes;
      return ['success', objects];
    } catch (e) {
      flogErr(e, {'element': element, 'query': query}, 'AwsManageAPI', 'queryBucketFiles');
      return [e.toString()];
    }
  }

  //删除文件
  static deleteFile(Map element, String key) async {
    try {
      Map configMap = await getConfigMap();
      String accessKeyId = configMap['accessKeyId'];
      String secretAccessKey = configMap['secretAccessKey'];
      String bucket = element['name'];
      String endpoint = configMap['endpoint'];
      int? port;
      if (endpoint.contains(':')) {
        List<String> endpointList = endpoint.split(':');
        endpoint = endpointList[0];
        port = int.parse(endpointList[1]);
      }
      String region = element['region'];
      bool isEnableSSL = configMap['isEnableSSL'] ?? true;

      if (endpoint.contains('amazonaws.com')) {
        if (!endpoint.contains(region)) {
          endpoint = 's3.$region.amazonaws.com';
        }
      }

      Minio minio;
      if (region == 'None') {
        minio = Minio(
          endPoint: endpoint,
          port: port,
          accessKey: accessKeyId,
          secretKey: secretAccessKey,
          useSSL: isEnableSSL,
        );
      } else {
        minio = Minio(
          endPoint: endpoint,
          port: port,
          accessKey: accessKeyId,
          secretKey: secretAccessKey,
          useSSL: isEnableSSL,
          region: region,
        );
      }

      var response = await minio.removeObject(bucket, key);

      return ['success', response];
    } catch (e) {
      flogErr(e, {'element': element, 'key': key}, 'AwsManageAPI', 'deleteFile');
      return [e.toString()];
    }
  }

  //删除文件夹
  static deleteFolder(Map element, String prefix) async {
    try {
      var queryResult = await queryBucketFiles(element, {
        'prefix': prefix,
      });

      if (queryResult[0] == 'success') {
        List files = [];
        List folders = [];
        files = queryResult[1]['Contents'];
        folders = queryResult[1]['CommonPrefixes'];
        if (files.isNotEmpty) {
          for (var item in files) {
            var deleteResult = await deleteFile(element, item.key);
            if (deleteResult[0] != 'success') {
              return ['failed'];
            }
          }
        }
        if (folders.isNotEmpty) {
          for (var item in folders) {
            var deleteResult = await deleteFolder(element, item);
            if (deleteResult[0] != 'success') {
              return ['failed'];
            }
          }
        }
        return ['success'];
      } else {
        return ['failed'];
      }
    } catch (e) {
      flogErr(e, {'element': element, 'prefix': prefix}, 'AwsManageAPI', 'deleteFolder');
      return ['failed'];
    }
  }

  //重命名文件
  static copyFile(Map element, String key, String newKey) async {
    try {
      Map configMap = await getConfigMap();
      String accessKeyId = configMap['accessKeyId'];
      String secretAccessKey = configMap['secretAccessKey'];
      String bucket = element['name'];
      String endpoint = configMap['endpoint'];
      int? port;
      if (endpoint.contains(':')) {
        List<String> endpointList = endpoint.split(':');
        endpoint = endpointList[0];
        port = int.parse(endpointList[1]);
      }
      String region = element['region'];
      bool isEnableSSL = configMap['isEnableSSL'] ?? true;
      if (endpoint.contains('amazonaws.com')) {
        if (!endpoint.contains(region)) {
          endpoint = 's3.$region.amazonaws.com';
        }
      }
      Minio minio;
      if (region == 'None') {
        minio = Minio(
          endPoint: endpoint,
          port: port,
          accessKey: accessKeyId,
          secretKey: secretAccessKey,
          useSSL: isEnableSSL,
        );
      } else {
        minio = Minio(
          endPoint: endpoint,
          port: port,
          accessKey: accessKeyId,
          secretKey: secretAccessKey,
          useSSL: isEnableSSL,
          region: region,
        );
      }

      var response = await minio.copyObject(
        bucket,
        newKey,
        '$bucket/$key',
      );

      return ['success', response];
    } catch (e) {
      flogErr(e, {'element': element, 'key': key, 'newKey': newKey}, 'AwsManageAPI', 'copyFile');
      return [e.toString()];
    }
  }

  //查询是否有重名文件
  static queryDuplicateName(Map element, String? prefix, String key) async {
    var queryResult = await queryBucketFiles(element, {
      'prefix': prefix,
    });

    if (queryResult[0] == 'success') {
      if (queryResult[1]['Contents'] != null) {
        var contents = queryResult[1]['Contents'];
        if (contents is List) {
          for (var i = 0; i < contents.length; i++) {
            if (contents[i].key == key) {
              return ['duplicate'];
            }
          }
        } else {
          if (contents.key == key) {
            return ['duplicate'];
          }
        }
      }
      if (queryResult[1]['CommonPrefixes'] != null) {
        var commonPrefixes = queryResult[1]['CommonPrefixes'];
        if (commonPrefixes is List) {
          for (var i = 0; i < commonPrefixes.length; i++) {
            if (commonPrefixes[i] == key) {
              return ['duplicate'];
            }
          }
        } else {
          if (commonPrefixes == key) {
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
      Map configMap = await getConfigMap();
      String accessKeyId = configMap['accessKeyId'];
      String secretAccessKey = configMap['secretAccessKey'];
      String bucket = element['name'];
      String endpoint = configMap['endpoint'];
      int? port;
      if (endpoint.contains(':')) {
        List<String> endpointList = endpoint.split(':');
        endpoint = endpointList[0];
        port = int.parse(endpointList[1]);
      }
      String region = element['region'];
      bool isEnableSSL = configMap['isEnableSSL'] ?? true;
      if (endpoint.contains('amazonaws.com')) {
        if (!endpoint.contains(region)) {
          endpoint = 's3.$region.amazonaws.com';
        }
      }
      Minio minio;
      if (region == 'None') {
        minio = Minio(
          endPoint: endpoint,
          port: port,
          accessKey: accessKeyId,
          secretKey: secretAccessKey,
          useSSL: isEnableSSL,
        );
      } else {
        minio = Minio(
          endPoint: endpoint,
          port: port,
          accessKey: accessKeyId,
          secretKey: secretAccessKey,
          useSSL: isEnableSSL,
          region: region,
        );
      }

      var response = await minio.putObject(bucket, '$prefix$newfolder/placeholder.txt', Stream.fromIterable([]));
      return ['success', response];
    } catch (e) {
      flogErr(e, {'element': element, 'prefix': prefix, 'newfolder': newfolder}, 'AwsManageAPI', 'createFolder');
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
      String accessKeyId = configMap['accessKeyId'];
      String secretAccessKey = configMap['secretAccessKey'];
      String bucket = element['name'];
      String endpoint = configMap['endpoint'];
      int? port;
      if (endpoint.contains(':')) {
        List<String> endpointList = endpoint.split(':');
        endpoint = endpointList[0];
        port = int.parse(endpointList[1]);
      }
      String region = element['region'];
      bool isEnableSSL = configMap['isEnableSSL'] ?? true;
      String uploadPath = prefix;
      if (endpoint.contains('amazonaws.com')) {
        if (!endpoint.contains(region)) {
          endpoint = 's3.$region.amazonaws.com';
        }
      }
      //云存储的路径
      String urlpath = '';
      if (uploadPath != '') {
        urlpath = '$uploadPath$filename';
      } else {
        urlpath = filename;
      }

      Minio minio;
      if (region == 'None') {
        minio = Minio(
          endPoint: endpoint,
          port: port,
          accessKey: accessKeyId,
          secretKey: secretAccessKey,
          useSSL: isEnableSSL,
        );
      } else {
        minio = Minio(
          endPoint: endpoint,
          port: port,
          accessKey: accessKeyId,
          secretKey: secretAccessKey,
          useSSL: isEnableSSL,
          region: region,
        );
      }

      Stream<Uint8List> stream = File(filepath).openRead().cast();
      await minio.putObject(
        bucket,
        urlpath,
        stream,
      );
      return ['success'];
    } catch (e) {
      flogErr(
        e,
        {
          'element': element,
          'filename': filename,
          'filepath': filepath,
          'prefix': prefix,
        },
        'AwsManageAPI',
        'uploadFile',
      );
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
    } else {
      return showToast('成功$successCount,失败$failCount');
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
      flogErr(e, {'fileLink': fileLink, 'element': element, 'prefix': prefix}, "AwsManageAPI", "uploadNetworkFile");
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
      return showToast('上传失败');
    } else if (failCount == 0) {
      return showToast('上传成功');
    } else {
      return showToast('成功$successCount,失败$failCount');
    }
  }
}
