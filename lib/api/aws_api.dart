import 'dart:convert';
import 'dart:io';
import 'package:f_logs/f_logs.dart';
import 'package:flutter/foundation.dart';
import 'package:minio_new/minio.dart';

import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/utils/global.dart';

class AwsImageUploadUtils {
  //上传接口
  static uploadApi(
      {required String path,
      required String name,
      required Map configMap}) async {
    String accessKeyId = configMap['accessKeyId'];
    String secretAccessKey = configMap['secretAccessKey'];
    String bucket = configMap['bucket'];
    String endpoint = configMap['endpoint'];
    String region = configMap['region'];
    String uploadPath = configMap['uploadPath'];
    String customUrl = configMap['customUrl'];

    if (customUrl != "None") {
      if (!customUrl.startsWith('http') && !customUrl.startsWith('https')) {
        customUrl = 'http://$customUrl';
      }
    }

    if (uploadPath != 'None') {
      if (uploadPath.startsWith('/')) {
        uploadPath = uploadPath.substring(1);
      }
      if (!uploadPath.endsWith('/')) {
        uploadPath = '$uploadPath/';
      }
    }
    //云存储的路径
    String urlpath = '';
    if (uploadPath != 'None') {
      urlpath = '$uploadPath$name';
    } else {
      urlpath = name;
    }

    Minio minio;
    if (region == 'None') {
      minio = Minio(
        endPoint: endpoint,
        accessKey: accessKeyId,
        secretKey: secretAccessKey,
      );
    } else {
      minio = Minio(
        endPoint: endpoint,
        accessKey: accessKeyId,
        secretKey: secretAccessKey,
        region: region,
      );
    }

    try {
      Stream<Uint8List> stream = File(path).openRead().cast();
      await minio.putObject(
        bucket,
        urlpath,
        stream,
      );
      String returnUrl = '';
      String displayUrl = '';

      if (customUrl != 'None') {
        if (!customUrl.endsWith('/')) {
          returnUrl = '$customUrl/$urlpath';
          displayUrl = '$customUrl/$urlpath';
        } else {
          returnUrl = '$customUrl$urlpath';
          displayUrl = '$customUrl$urlpath';
        }
      } else {
        if (endpoint.contains('amazonaws.com')) {
          returnUrl = 'https://$bucket.s3.$region.amazonaws.com/$urlpath';
          displayUrl = 'https://$bucket.s3.$region.amazonaws.com/$urlpath';
        } else {
          returnUrl = 'https://$bucket.$endpoint/$urlpath';
          displayUrl = 'https://$bucket.$endpoint/$urlpath';
        }
      }

      String formatedURL = '';
      if (Global.isCopyLink == true) {
        formatedURL =
            linkGenerateDict[Global.defaultLKformat]!(returnUrl, name);
      } else {
        formatedURL = returnUrl;
      }
      Map pictureKeyMap = Map.from(configMap);
      String pictureKey = jsonEncode(pictureKeyMap);
      return ["success", formatedURL, returnUrl, pictureKey, displayUrl];
    } catch (e) {
      FLog.error(
          className: "AwsImageUploadUtils",
          methodName: "uploadApi",
          text: formatErrorMessage({
            'path': path,
            'name': name,
          }, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      return [e.toString()];
    }
  }

  static deleteApi({required Map deleteMap, required Map configMap}) async {
    Map configMapFromPictureKey = jsonDecode(deleteMap['pictureKey']);
    String fileName = deleteMap['name'];
    String accessKeyId = configMapFromPictureKey['accessKeyId'];
    String secretAccessKey = configMapFromPictureKey['secretAccessKey'];
    String bucket = configMapFromPictureKey['bucket'];
    String endpoint = configMapFromPictureKey['endpoint'];
    String region = configMapFromPictureKey['region'];
    String uploadPath = configMapFromPictureKey['uploadPath'];
    if (uploadPath != 'None') {
      if (uploadPath.startsWith('/')) {
        uploadPath = uploadPath.substring(1);
      }
      if (!uploadPath.endsWith('/')) {
        uploadPath = '$uploadPath/';
      }
    }

    String urlpath = '';
    if (uploadPath != 'None') {
      urlpath = '$uploadPath$fileName';
    } else {
      urlpath = fileName;
    }

    Minio minio;
    if (region == 'None') {
      minio = Minio(
        endPoint: endpoint,
        accessKey: accessKeyId,
        secretKey: secretAccessKey,
      );
    } else {
      minio = Minio(
        endPoint: endpoint,
        accessKey: accessKeyId,
        secretKey: secretAccessKey,
        region: region,
      );
    }

    try {
      await minio.removeObject(bucket, urlpath);

      return ['success'];
    } catch (e) {
      FLog.error(
          className: "AwsImageUploadUtils",
          methodName: "deleteApi",
          text: formatErrorMessage({
            'fileName': fileName,
          }, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());

      return [e.toString()];
    }
  }
}
