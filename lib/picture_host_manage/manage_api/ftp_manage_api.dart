import 'dart:io';
import 'dart:convert';

import 'package:dartssh2/dartssh2.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

import 'package:horopic/picture_host_configure/configure_page/ftp_configure.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/picture_host_manage/common/base_manage_api.dart';

class FTPManageAPI extends BaseManageApi {
  static final FTPManageAPI _instance = FTPManageAPI._internal();

  factory FTPManageAPI() {
    return _instance;
  }

  FTPManageAPI._internal();

  @override
  String configFileName() => 'ftp_config.txt';

  Future<SSHClient?> getSFTPClient() async {
    try {
      Map configMap = await getConfigMap();
      final socket = await SSHSocket.connect(configMap['ftpHost'], int.parse(configMap['ftpPort']));
      final SSHClient client = SSHClient(
        socket,
        username: configMap['ftpUser'],
        onPasswordRequest: () {
          return configMap['ftpPassword'];
        },
      );
      return client;
    } catch (e) {
      flogErr(e, {}, "FTPManageAPI", "getSFTPClient");
      return null;
    }
  }

  getDirectoryContentSFTP(String folder) async {
    try {
      SSHClient? client = await getSFTPClient();
      if (client == null) {
        return ['failed'];
      }
      final SftpClient sftp = await client.sftp();
      final List<SftpName> items = await sftp.listdir(folder);
      List itemAttrs = [];
      for (var item in items) {
        if (item.longname.startsWith('d') || item.longname.startsWith('-')) {
          List itemAttr = item.longname.split(RegExp(r'\s+'));
          if (itemAttr[8] != '.' && itemAttr[8] != '..') {
            itemAttrs.add({
              'type': itemAttr[0].toString().startsWith('d') ? 'folder' : 'file',
              'permissions': itemAttr[0],
              'numberOflinks': itemAttr[1],
              'owner': itemAttr[2],
              'group': itemAttr[3],
              'size': int.parse(itemAttr[4].toString()),
              'mtime': item.attr.modifyTime,
              'atime': item.attr.accessTime,
              'name': itemAttr[8],
            });
          }
        }
      }
      client.close();
      return ['success', itemAttrs];
    } catch (e) {
      flogErr(
          e,
          {
            'folder': folder,
          },
          "FTPManageAPI",
          "getDirectoryContentSFTP");
      return ["failed"];
    }
  }

  executeCommandSFTP(String command) async {
    try {
      SSHClient? client = await getSFTPClient();
      if (client == null) {
        return ['failed'];
      }
      final result = await client.run(command);
      client.close();
      return ['success', utf8.decode(result)];
    } catch (e) {
      flogErr(
          e,
          {
            'command': command,
          },
          "FTPManageAPI",
          "executeCommandSFTP");
      return ["failed"];
    }
  }

  renameFileSFTP(String oldName, String newName) async {
    try {
      SSHClient? client = await getSFTPClient();
      if (client == null) {
        return ['failed'];
      }
      final SftpClient sftp = await client.sftp();
      await sftp.rename(oldName, newName);
      client.close();
      return ['success', ''];
    } catch (e) {
      flogErr(
          e,
          {
            'oldName': oldName,
            'newName': newName,
          },
          "FTPManageAPI",
          "renameFileSFTP");
      return ["failed"];
    }
  }

  //新建文件夹
  createFolderSFTP(String folderName) async {
    try {
      SSHClient? client = await getSFTPClient();
      if (client == null) {
        return ['failed'];
      }
      await client.run('mkdir -p $folderName');
      client.close();
      return ['success', ''];
    } catch (e) {
      flogErr(
          e,
          {
            'folderName': folderName,
          },
          "FTPManageAPI",
          "createFolderSFTP");
      return ["failed"];
    }
  }

  removeSFTPDirectory(String folderName) async {
    try {
      SSHClient? client = await getSFTPClient();
      if (client == null) {
        return ['failed'];
      }
      //no * in folderName
      if (folderName.contains('*') || folderName.contains('?') || folderName == '/') {
        return ["failed"];
      }
      await client.run('rm -rf $folderName');
      client.close();
      return ['success', ''];
    } catch (e) {
      flogErr(
          e,
          {
            'folderName': folderName,
          },
          "FTPManageAPI",
          "deleteFolderSFTP");
      return ["failed"];
    }
  }

  deleteSFTPFile(String fileName) async {
    try {
      SSHClient? client = await getSFTPClient();
      if (client == null) {
        return ['failed'];
      }
      if (fileName.contains('*') || fileName == '/' || fileName.contains('?')) {
        return ["failed"];
      }
      await client.run('rm -f $fileName');
      client.close();
      return ['success', ''];
    } catch (e) {
      flogErr(
          e,
          {
            'fileName': fileName,
          },
          "FTPManageAPI",
          "deleteFileSFTP");
      return ["failed"];
    }
  }

  setDefaultBucketSFTP(String folder) async {
    try {
      Map configMap = await getConfigMap();
      String ftpCustomUrl = configMap['ftpCustomUrl'] ?? 'None';
      String ftpWebPath = configMap['ftpWebPath'] ?? 'None';
      final ftpConfig = FTPConfigModel(
          configMap['ftpHost'],
          configMap['ftpPort'],
          configMap['ftpUser'],
          configMap['ftpPassword'],
          configMap['ftpType'],
          configMap['isAnonymous'],
          folder,
          configMap['ftpHomeDir'],
          ftpCustomUrl,
          ftpWebPath);
      final ftpConfigJson = jsonEncode(ftpConfig);
      final ftpConfigFile = await localFile();
      await ftpConfigFile.writeAsString(ftpConfigJson);
      return ['success'];
    } catch (e) {
      flogErr(
          e,
          {
            'folder': folder,
          },
          "FTPManageAPI",
          "setDefaultBucketSFTP");
      return ['failed'];
    }
  }

  uploadFileSFTP(String uploadPath, String filePath, String fileName) async {
    try {
      SSHClient? client = await getSFTPClient();
      if (client == null) {
        return ['failed'];
      }
      final SftpClient sftp = await client.sftp();
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
      SftpFile file = await sftp.open(urlPath, mode: SftpFileOpenMode.create | SftpFileOpenMode.write);
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
      flogErr(
          e,
          {
            'uploadPath': uploadPath,
            'filePath': filePath,
            'fileName': fileName,
          },
          "FTPManageAPI",
          "uploadFileSFTP");
      return ["failed"];
    }
  }

  //从网络链接下载文件后上传
  uploadNetworkFileSFTP(String fileLink, String uploadPath) async {
    try {
      String filename = fileLink.substring(fileLink.lastIndexOf("/") + 1, fileLink.length);
      filename = filename.substring(0, !filename.contains("?") ? filename.length : filename.indexOf("?"));
      String savePath = await getTemporaryDirectory().then((value) {
        return value.path;
      });
      String saveFilePath = '$savePath/$filename';
      Dio dio = Dio();
      Response response = await dio.download(fileLink, saveFilePath);
      if (response.statusCode != 200) {
        return ['failed'];
      }
      var uploadResult = await uploadFileSFTP(
        uploadPath,
        saveFilePath,
        filename,
      );
      if (uploadResult[0] == "success") {
        return ['success'];
      }
      return ['failed'];
    } catch (e) {
      flogErr(
          e,
          {
            'fileLink': fileLink,
            'uploadPath': uploadPath,
          },
          "FTPManageAPI",
          "uploadNetworkFileSFTP");
      return ['failed'];
    }
  }

  uploadNetworkFileEntrySFTP(List fileList, String uploadPath) async {
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
      return showToast('上传失败');
    } else if (failCount == 0) {
      return showToast('上传成功');
    }
    return showToast('成功$successCount,失败$failCount');
  }
}
