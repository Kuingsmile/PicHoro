import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:minio/minio.dart';
import 'package:path/path.dart' as my_path;

import 'package:horopic/utils/common_functions.dart';

class AwsImageUploadUtils {
  //上传接口
  static uploadApi({required String path, required String name, required Map configMap}) async {
    try {
      String accessKeyId = configMap['accessKeyId'] ?? '';
      String secretAccessKey = configMap['secretAccessKey'] ?? '';
      String bucket = configMap['bucket'] ?? '';
      String endpoint = configMap['endpoint'] ?? '';
      int? port;
      if (endpoint.contains(':')) {
        List<String> endpointList = endpoint.split(':');
        endpoint = endpointList[0];
        port = int.parse(endpointList[1]);
      }
      String region = configMap['region'] ?? 'None';
      String uploadPath = configMap['uploadPath'] ?? 'None';
      String customUrl = configMap['customUrl'] ?? 'None';
      bool isS3PathStyle = configMap['isS3PathStyle'] ?? false;
      bool isEnableSSL = configMap['isEnableSSL'] ?? true;

      if (customUrl != "None" && !customUrl.startsWith(RegExp(r'http(s)?://'))) {
        customUrl = 'http://$customUrl';
      }

      if (uploadPath != 'None') {
        uploadPath = '${uploadPath.replaceAll(RegExp(r'^/*|/*$'), '')}/';
      }
      //云存储的路径
      String urlpath = uploadPath != 'None' ? '$uploadPath$name' : name;

      Minio minio = Minio(
          endPoint: endpoint,
          port: port,
          accessKey: accessKeyId,
          secretKey: secretAccessKey,
          useSSL: isEnableSSL,
          region: region == 'None' ? null : region);
      Stream<Uint8List> stream = File(path).openRead().cast();
      String contentType = getContentType(my_path.extension(path).substring(1));
      await minio.putObject(
        bucket,
        urlpath,
        stream,
        metadata: {"Content-Type": contentType},
      );
      String returnUrl = '';
      String displayUrl = '';

      if (customUrl != 'None') {
        if (customUrl.endsWith('/')) {
          customUrl = customUrl.substring(0, customUrl.length - 1);
        }
        returnUrl = '$customUrl/$urlpath';
        displayUrl = returnUrl;
      } else {
        if (endpoint.contains('amazonaws.com')) {
          returnUrl = isS3PathStyle
              ? 'https://s3.$region.amazonaws.com/$bucket/$urlpath'
              : 'https://$bucket.s3.$region.amazonaws.com/$urlpath';
          displayUrl = returnUrl;
        } else {
          String httpPrefix = isEnableSSL ? 'https' : 'http';
          String fullEndpoint = '$endpoint${port == null ? '' : ':${port.toString()}'}';
          returnUrl = isS3PathStyle
              ? '$httpPrefix://$fullEndpoint/$bucket/$urlpath'
              : '$httpPrefix://$bucket.$fullEndpoint/$urlpath';
          displayUrl = returnUrl;
        }
      }
      String formatedURL = getFormatedUrl(returnUrl, name);
      Map pictureKeyMap = Map.from(configMap);
      String pictureKey = jsonEncode(pictureKeyMap);
      return ["success", formatedURL, returnUrl, pictureKey, displayUrl];
    } catch (e) {
      flogErr(
          e,
          {
            'path': path,
            'name': name,
          },
          "AwsImageUploadUtils",
          "uploadApi");
      return ['failed'];
    }
  }

  static deleteApi({required Map deleteMap, required Map configMap}) async {
    try {
      Map configMapFromPictureKey = jsonDecode(deleteMap['pictureKey']);
      String fileName = deleteMap['name'];
      String accessKeyId = configMapFromPictureKey['accessKeyId'];
      String secretAccessKey = configMapFromPictureKey['secretAccessKey'];
      String bucket = configMapFromPictureKey['bucket'];
      String endpoint = configMapFromPictureKey['endpoint'];
      int? port;
      if (endpoint.contains(':')) {
        List<String> endpointList = endpoint.split(':');
        endpoint = endpointList[0];
        port = int.parse(endpointList[1]);
      }
      String region = configMapFromPictureKey['region'];
      String uploadPath = configMapFromPictureKey['uploadPath'];
      bool isEnableSSL = configMapFromPictureKey['isEnableSSL'] ?? true;
      if (uploadPath != 'None') {
        if (uploadPath.startsWith('/')) {
          uploadPath = uploadPath.substring(1);
        }
        if (!uploadPath.endsWith('/')) {
          uploadPath = '$uploadPath/';
        }
      }
      String urlpath = uploadPath != 'None' ? '$uploadPath$fileName' : fileName;
      Minio minio = Minio(
          endPoint: endpoint,
          port: port,
          accessKey: accessKeyId,
          secretKey: secretAccessKey,
          useSSL: isEnableSSL,
          region: region == 'None' ? null : region);
      await minio.removeObject(bucket, urlpath);
      return ['success'];
    } catch (e) {
      flogErr(
          e,
          {
            'deleteMap': deleteMap,
            'configMap': configMap,
          },
          "AwsImageUploadUtils",
          "deleteApi");
      return ['failed'];
    }
  }
}
