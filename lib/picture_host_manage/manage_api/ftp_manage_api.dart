import 'dart:io';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:f_logs/f_logs.dart';
import 'package:path_provider/path_provider.dart';

import 'package:dartssh2/dartssh2.dart';

import 'package:horopic/utils/global.dart';
import 'package:horopic/picture_host_configure/configure_page/ftp_configure.dart';
import 'package:horopic/utils/common_functions.dart';

class FTPManageAPI {
  static Future<File> get localFile async {
    final path = await _localPath;
    String defaultUser = await Global.getUser();
    return File('$path/${defaultUser}_ftp_config.txt');
  }

  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<String> readFTPConfig() async {
    try {
      final file = await localFile;
      String contents = await file.readAsString();
      return contents;
    } catch (e) {
      FLog.error(
          className: 'FTPManageAPI',
          methodName: 'readFTPConfig',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      return "Error";
    }
  }

  static Future<Map> getConfigMap() async {
    String configStr = await readFTPConfig();
    Map configMap = json.decode(configStr);
    return configMap;
  }

  static isString(var variable) {
    return variable is String;
  }

  static isFile(var variable) {
    return variable is File;
  }

  static getDirectoryContentSFTP(String folder) async {
    Map configMap = await getConfigMap();
    String ftpHost = configMap['ftpHost'];
    String ftpPort = configMap['ftpPort'];
    String ftpUser = configMap['ftpUser'];
    String ftpPassword = configMap['ftpPassword'];
    try {
      final socket = await SSHSocket.connect(ftpHost, int.parse(ftpPort));
      final client = SSHClient(
        socket,
        username: ftpUser,
        onPasswordRequest: () {
          return ftpPassword;
        },
      );
      final sftp = await client.sftp();
      final items = await sftp.listdir(folder);
      List itemAttrs = [];
      for (var item in items) {
        if (item.longname.startsWith('d') || item.longname.startsWith('-')) {
          List itemAttr = item.longname.split(RegExp(r'\s+'));
          if (itemAttr[8] != '.' && itemAttr[8] != '..') {
            Map temp = {
              'type': itemAttr[0].toString().startsWith('d') ? 'folder' : 'file',
              'permissions': itemAttr[0],
              'numberOflinks': itemAttr[1],
              'owner': itemAttr[2],
              'group': itemAttr[3],
              'size': int.parse(itemAttr[4].toString()),
              'mtime': item.attr.modifyTime,
              'atime': item.attr.accessTime,
              'name': itemAttr[8],
            };
            itemAttrs.add(temp);
          }
        }
      }
      client.close();
      return ['success', itemAttrs];
    } catch (e) {
      FLog.error(
          className: 'FTPManageAPI',
          methodName: 'getDirectoryContentSFTP',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      return ["failed"];
    }
  }

  static executeCommandSFTP(String command) async {
    Map configMap = await getConfigMap();
    String ftpHost = configMap['ftpHost'];
    String ftpPort = configMap['ftpPort'];
    String ftpUser = configMap['ftpUser'];
    String ftpPassword = configMap['ftpPassword'];
    try {
      final socket = await SSHSocket.connect(ftpHost, int.parse(ftpPort));
      final client = SSHClient(
        socket,
        username: ftpUser,
        onPasswordRequest: () {
          return ftpPassword;
        },
      );
      final result = await client.run(command);
      client.close();
      return ['success', utf8.decode(result)];
    } catch (e) {
      FLog.error(
          className: 'FTPManageAPI',
          methodName: 'executeCommandSFTP',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      return ["failed"];
    }
  }

  static renameFileSFTP(String oldName, String newName) async {
    Map configMap = await getConfigMap();
    String ftpHost = configMap['ftpHost'];
    String ftpPort = configMap['ftpPort'];
    String ftpUser = configMap['ftpUser'];
    String ftpPassword = configMap['ftpPassword'];
    try {
      final socket = await SSHSocket.connect(ftpHost, int.parse(ftpPort));
      final client = SSHClient(
        socket,
        username: ftpUser,
        onPasswordRequest: () {
          return ftpPassword;
        },
      );
      final sftp = await client.sftp();
      await sftp.rename(oldName, newName);
      client.close();
      return ['success', ''];
    } catch (e) {
      FLog.error(
          className: 'FTPManageAPI',
          methodName: 'renameFileSFTP',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      return ["failed"];
    }
  }

  //新建文件夹
  static createFolderSFTP(String folderName) async {
    Map configMap = await getConfigMap();
    String ftpHost = configMap['ftpHost'];
    String ftpPort = configMap['ftpPort'];
    String ftpUser = configMap['ftpUser'];
    String ftpPassword = configMap['ftpPassword'];
    try {
      final socket = await SSHSocket.connect(ftpHost, int.parse(ftpPort));
      final client = SSHClient(
        socket,
        username: ftpUser,
        onPasswordRequest: () {
          return ftpPassword;
        },
      );
      await client.run('mkdir -p $folderName');
      client.close();
      return ['success', ''];
    } catch (e) {
      FLog.error(
          className: 'FTPManageAPI',
          methodName: 'createFolderSFTP',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      return ["failed"];
    }
  }

  //删除文件夹
  static deleteFolderSFTP(String folderName) async {
    Map configMap = await getConfigMap();
    String ftpHost = configMap['ftpHost'];
    String ftpPort = configMap['ftpPort'];
    String ftpUser = configMap['ftpUser'];
    String ftpPassword = configMap['ftpPassword'];
    try {
      final socket = await SSHSocket.connect(ftpHost, int.parse(ftpPort));
      final client = SSHClient(
        socket,
        username: ftpUser,
        onPasswordRequest: () {
          return ftpPassword;
        },
      );
      //no * in folderName
      if (folderName.contains('*')) {
        return ["failed"];
      }
      if (folderName.contains('?')) {
        return ["failed"];
      }

      await client.run('rm -rf $folderName');
      client.close();
      return ['success', ''];
    } catch (e) {
      FLog.error(
          className: 'FTPManageAPI',
          methodName: 'deleteFolderSFTP',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      return ["failed"];
    }
  }

  //删除文件
  static deleteFileSFTP(String fileName) async {
    Map configMap = await getConfigMap();
    String ftpHost = configMap['ftpHost'];
    String ftpPort = configMap['ftpPort'];
    String ftpUser = configMap['ftpUser'];
    String ftpPassword = configMap['ftpPassword'];
    try {
      final socket = await SSHSocket.connect(ftpHost, int.parse(ftpPort));
      final client = SSHClient(
        socket,
        username: ftpUser,
        onPasswordRequest: () {
          return ftpPassword;
        },
      );
      if (fileName.contains('*')) {
        return ["failed"];
      }
      if (fileName.contains('?')) {
        return ["failed"];
      }
      await client.run('rm -f $fileName');
      client.close();
      return ['success', ''];
    } catch (e) {
      FLog.error(
          className: 'FTPManageAPI',
          methodName: 'deleteFileSFTP',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      return ["failed"];
    }
  }

  static setDefaultBucketSFTP(String folder) async {
    try {
      Map configMap = await getConfigMap();
      String ftpHost = configMap['ftpHost'];
      String ftpPort = configMap['ftpPort'];
      String ftpUser = configMap['ftpUser'];
      String ftpPassword = configMap['ftpPassword'];
      String ftpType = configMap['ftpType'];
      String isAnonymous = configMap['isAnonymous'];
      String uploadPath = folder;
      String ftpHomeDir = configMap['ftpHomeDir'];
      String? ftpCustomUrl = configMap['ftpCustomUrl'];
      String? ftpWebPath = configMap['ftpWebPath'];
      ftpCustomUrl ??= 'None';
      ftpWebPath ??= 'None';
      final ftpConfig = FTPConfigModel(ftpHost, ftpPort, ftpUser, ftpPassword, ftpType, isAnonymous, uploadPath,
          ftpHomeDir, ftpCustomUrl, ftpWebPath);
      final ftpConfigJson = jsonEncode(ftpConfig);
      final ftpConfigFile = await localFile;
      await ftpConfigFile.writeAsString(ftpConfigJson);
      return ['success'];
    } catch (e) {
      FLog.error(
          className: "FTPManageAPI",
          methodName: "setDefaultBucketSFTP",
          text: formatErrorMessage({'folder': folder}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      return ['failed'];
    }
  }

  static uploadFileSFTP(String uploadPath, String filePath, String fileName) async {
    Map configMap = await getConfigMap();
    String ftpHost = configMap['ftpHost'];
    String ftpPort = configMap['ftpPort'];
    String ftpUser = configMap['ftpUser'];
    String ftpPassword = configMap['ftpPassword'];
    try {
      final socket = await SSHSocket.connect(ftpHost, int.parse(ftpPort));
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
      String urlPath = uploadPath + fileName;
      var file = await sftp.open(urlPath, mode: SftpFileOpenMode.create | SftpFileOpenMode.write);
      int fileSize = File(filePath).lengthSync();
      bool operateDone = false;
      file.write(File(filePath).openRead().cast(), onProgress: (int sent) {
        if (sent == fileSize) {
          operateDone = true;
        }
      });
      while (!operateDone) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      client.close();
      return ['success', ''];
    } catch (e) {
      FLog.error(
          className: 'FTPManageAPI',
          methodName: 'uploadFileSFTP',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      return ["failed"];
    }
  }

  //从网络链接下载文件后上传
  static uploadNetworkFileSFTP(String fileLink, String uploadPath) async {
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
        var uploadResult = await uploadFileSFTP(
          uploadPath,
          saveFilePath,
          filename,
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
      if (e is DioException) {
        FLog.error(
            className: "FTPManageAPI",
            methodName: "uploadNetworkFileSFTP",
            text: formatErrorMessage({
              'fileLink': fileLink,
            }, e.toString(), isDioError: true, dioErrorMessage: e),
            dataLogType: DataLogType.ERRORS.toString());
      } else {
        FLog.error(
            className: "FTPManageAPI",
            methodName: "uploadNetworkFileSFTP",
            text: formatErrorMessage({
              'fileLink': fileLink,
            }, e.toString()),
            dataLogType: DataLogType.ERRORS.toString());
      }
      return ['failed'];
    }
  }

  static uploadNetworkFileEntrySFTP(List fileList, String uploadPath) async {
    int successCount = 0;
    int failCount = 0;

    for (String fileLink in fileList) {
      if (fileLink.isEmpty) {
        continue;
      }
      var uploadResult = await uploadNetworkFileSFTP(fileLink, uploadPath);
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
