import 'dart:convert';
import 'dart:io';
import 'package:f_logs/f_logs.dart';
import 'package:ftpconnect/ftpconnect.dart';
import 'package:dartssh2/dartssh2.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/utils/global.dart';

class FTPImageUploadUtils {
  //上传接口
  static uploadApi(
      {required String path,
      required String name,
      required Map configMap}) async {
    String formatedURL = '';
    String ftpHost = configMap["ftpHost"];
    String ftpPort = configMap["ftpPort"];
    String ftpUser = configMap["ftpUser"];
    String ftpPassword = configMap["ftpPassword"];
    String ftpType = configMap["ftpType"];
    String isAnonymous = configMap["isAnonymous"];
    String uploadPath = configMap["uploadPath"];
    if (ftpType == 'SFTP') {
      try {
        final socket =
            await SSHSocket.connect(ftpHost, int.parse(ftpPort.toString()));
        final client = SSHClient(
          socket,
          username: ftpUser,
          onPasswordRequest: () {
            return ftpPassword;
          },
        );
        final sftp = await client.sftp();
        if (uploadPath == 'None') {
          uploadPath = '/';
        }
        uploadPath =
            '/${uploadPath.replaceAll(RegExp(r'^/*'), '').replaceAll(RegExp(r'/*$'), '')}/';
        String urlPath = uploadPath + name;
        var file = await sftp.open(urlPath,
            mode: SftpFileOpenMode.create | SftpFileOpenMode.write);
        int fileSize = File(path).lengthSync();
        bool operateDone = false;
        file.write(File(path).openRead().cast(), onProgress: (int sent) {
          if (sent == fileSize) {
            operateDone = true;
          }
        });
        while (!operateDone) {
          await Future.delayed(const Duration(milliseconds: 100));
        }
        client.close();
        String returnUrl =
            'ftp://$ftpUser:$ftpPassword@$ftpHost:$ftpPort$urlPath';
        returnUrl = returnUrl;
        String pictureKey = jsonEncode(configMap);
        String displayUrl = returnUrl;
        if (Global.isCopyLink == true) {
          formatedURL =
              linkGenerateDict[Global.defaultLKformat]!(displayUrl, name);
        } else {
          formatedURL = displayUrl;
        }
        var externalCacheDir = await getExternalCacheDirectories();
        String cachePath = externalCacheDir![0].path;
        String ftpCachePath = '$cachePath/ftp';
        if (!await Directory(ftpCachePath).exists()) {
          await Directory(ftpCachePath).create(recursive: true);
        }
        String randomString = randomStringGenerator(5);
        String thumbnailFileName = 'FTP_${randomString}_$name';
        var result = await FlutterImageCompress.compressAndGetFile(
          path,
          '$ftpCachePath/$thumbnailFileName',
          quality: 50,
          minWidth: 500,
          minHeight: 500,
        );
        if (result == null) {
          await File(path).copy('$ftpCachePath/$thumbnailFileName');
        }

        return [
          'success',
          formatedURL,
          returnUrl,
          pictureKey,
          displayUrl,
          ftpHost,
          ftpPort,
          ftpUser,
          ftpPassword,
          ftpType,
          isAnonymous,
          uploadPath,
          '$ftpCachePath/$thumbnailFileName'
        ];
      } catch (e) {
        FLog.error(
            className: "FTPImageUploadUtils",
            methodName: "uploadApiSFTP",
            text: formatErrorMessage({
              'path': path,
              'name': name,
            }, e.toString()),
            dataLogType: DataLogType.ERRORS.toString());
        return ['failed'];
      }
    } else if (ftpType == 'FTP') {
      FTPConnect ftpConnect;
      if (isAnonymous == 'true') {
        ftpConnect = FTPConnect(ftpHost,
            port: int.parse(ftpPort), securityType: SecurityType.FTP);
      } else {
        ftpConnect = FTPConnect(ftpHost,
            port: int.parse(ftpPort),
            user: ftpUser,
            pass: ftpPassword,
            securityType: SecurityType.FTP);
      }

      try {
        var connectResult = await ftpConnect.connect();
        if (connectResult == true) {
          if (uploadPath == 'None') {
            uploadPath = '/';
          }
          if (!uploadPath.startsWith('/')) {
            uploadPath = '/$uploadPath';
          }
          if (!uploadPath.endsWith('/')) {
            uploadPath = '$uploadPath/';
          }
          String urlPath = uploadPath + name;
          File fileToUpload = File(path);
          await ftpConnect.sendCustomCommand('TYPE I');
          await ftpConnect.changeDirectory(uploadPath);
          bool res = await ftpConnect.uploadFile(
            fileToUpload,
            sRemoteName: name,
          );
          if (res == true) {
            String returnUrl = '';
            if (isAnonymous == 'true') {
              returnUrl = 'ftp://$ftpHost:$ftpPort$urlPath';
            } else if (ftpPassword == 'None') {
              returnUrl = 'ftp://$ftpUser@$ftpHost:$ftpPort$urlPath';
            } else {
              returnUrl =
                  'ftp://$ftpUser:$ftpPassword@$ftpHost:$ftpPort$urlPath';
            }
            returnUrl = returnUrl;
            String pictureKey = jsonEncode(configMap);
            String displayUrl = returnUrl;
            if (Global.isCopyLink == true) {
              formatedURL =
                  linkGenerateDict[Global.defaultLKformat]!(displayUrl, name);
            } else {
              formatedURL = displayUrl;
            }
            ftpConnect.disconnect();
            var externalCacheDir = await getExternalCacheDirectories();
            String cachePath = externalCacheDir![0].path;
            String ftpCachePath = '$cachePath/ftp';
            if (!await Directory(ftpCachePath).exists()) {
              await Directory(ftpCachePath).create(recursive: true);
            }
            String randomString = randomStringGenerator(5);
            String thumbnailFileName = 'FTP_${randomString}_$name';
            var result = await FlutterImageCompress.compressAndGetFile(
              path,
              '$ftpCachePath/$thumbnailFileName',
              quality: 50,
              minWidth: 500,
              minHeight: 500,
            );
            if (result == null) {
              //copy raw file
              await File(path).copy('$ftpCachePath/$thumbnailFileName');
            }

            return [
              'success',
              formatedURL,
              returnUrl,
              pictureKey,
              displayUrl,
              ftpHost,
              ftpPort,
              ftpUser,
              ftpPassword,
              ftpType,
              isAnonymous,
              uploadPath,
              '$ftpCachePath/$thumbnailFileName'
            ];
          } else {
            FLog.error(
                className: "FTPImageUploadUtils",
                methodName: "uploadApiFTP",
                text: formatErrorMessage({
                  'path': path,
                  'name': name,
                }, 'upload failed'),
                dataLogType: DataLogType.ERRORS.toString());
            return ['failed'];
          }
        } else {
          FLog.error(
              className: "FTPImageUploadUtils",
              methodName: "uploadApiFTP",
              text: formatErrorMessage({
                'path': path,
                'name': name,
              }, 'connect failed'),
              dataLogType: DataLogType.ERRORS.toString());
          return ['failed'];
        }
      } catch (e) {
        FLog.error(
            className: "FTPImageUploadUtils",
            methodName: "uploadApiFTP",
            text: formatErrorMessage({
              'path': path,
              'name': name,
            }, e.toString()),
            dataLogType: DataLogType.ERRORS.toString());
        return ['failed'];
      }
    }
  }

  static deleteApi({required Map deleteMap, required Map configMap}) async {
    Map configMapFromPictureKey = jsonDecode(deleteMap['pictureKey']);
    String ftpHost = configMapFromPictureKey["ftpHost"];
    String ftpPort = configMapFromPictureKey["ftpPort"];
    String ftpUser = configMapFromPictureKey["ftpUser"];
    String ftpPassword = configMapFromPictureKey["ftpPassword"];
    String ftpType = configMapFromPictureKey["ftpType"];
    String isAnonymous = configMapFromPictureKey["isAnonymous"].toString();
    String uploadPath = configMapFromPictureKey["uploadPath"];
    String name = deleteMap['name'];
    try {
      if (ftpType == 'SFTP') {
        try {
          final socket =
              await SSHSocket.connect(ftpHost, int.parse(ftpPort.toString()));
          final client = SSHClient(
            socket,
            username: ftpUser,
            onPasswordRequest: () {
              return ftpPassword;
            },
          );
          final sftp = await client.sftp();
          if (uploadPath == 'None') {
            uploadPath = '/';
          }
          if (!uploadPath.startsWith('/')) {
            uploadPath = '/$uploadPath';
          }
          if (!uploadPath.endsWith('/')) {
            uploadPath = '$uploadPath/';
          }
          String urlPath = uploadPath + name;
          await sftp.remove(urlPath);
          client.close();
          return ['success'];
        } catch (e) {
          FLog.error(
              className: "FTPImageUploadUtils",
              methodName: "deleteApi",
              text: formatErrorMessage({}, e.toString()),
              dataLogType: DataLogType.ERRORS.toString());
          return ['failed'];
        }
      } else if (ftpType == 'FTP') {
        FTPConnect ftpConnect;
        if (isAnonymous == 'true') {
          ftpConnect = FTPConnect(ftpHost,
              port: int.parse(ftpPort), securityType: SecurityType.FTP);
        } else {
          ftpConnect = FTPConnect(ftpHost,
              port: int.parse(ftpPort),
              user: ftpUser,
              pass: ftpPassword,
              securityType: SecurityType.FTP);
        }
        try {
          var connectResult = await ftpConnect.connect();
          if (connectResult == true) {
            await ftpConnect.changeDirectory(uploadPath);
            bool res = await ftpConnect.deleteFile(name);
            if (res == true) {
              return [
                'success',
              ];
            } else {
              FLog.error(
                  className: "FTPImageUploadUtils",
                  methodName: "deleteApi",
                  text: formatErrorMessage({}, 'delete failed'),
                  dataLogType: DataLogType.ERRORS.toString());
              return ['failed'];
            }
          } else {
            FLog.error(
                className: "FTPImageUploadUtils",
                methodName: "deleteApiFTP",
                text: formatErrorMessage({}, 'connect failed'),
                dataLogType: DataLogType.ERRORS.toString());
            return ['failed'];
          }
        } catch (e) {
          FLog.error(
              className: "FTPImageUploadUtils",
              methodName: "deleteApiFTP",
              text: formatErrorMessage({}, e.toString()),
              dataLogType: DataLogType.ERRORS.toString());
          return ['failed'];
        }
      }
    } catch (e) {
      FLog.error(
          className: "FTPImageUploadUtils",
          methodName: "deleteApi",
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      return [e.toString()];
    }
  }
}
