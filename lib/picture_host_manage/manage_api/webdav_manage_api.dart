import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:horopic/picture_host_manage/common/base_manage_api.dart';
import 'package:path_provider/path_provider.dart';

import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/picture_host_configure/configure_page/webdav_configure.dart';
import 'package:webdav_client/webdav_client.dart' as webdav;

class WebdavManageAPI extends BaseManageApi {
  static final WebdavManageAPI _instance = WebdavManageAPI._internal();

  factory WebdavManageAPI() {
    return _instance;
  }
  WebdavManageAPI._internal();

  @override
  String configFileName() => 'webdav_config.txt';

  getWebdavClient() async {
    Map configMap = await getConfigMap();
    return webdav.newClient(
      configMap['host'],
      user: configMap['webdavusername'],
      password: configMap['password'],
    )
      ..setHeaders({'accept-charset': 'utf-8'})
      ..setConnectTimeout(8000)
      ..setSendTimeout(8000)
      ..setReceiveTimeout(8000);
  }

  getFileList(String path) async {
    try {
      webdav.Client client = await getWebdavClient();
      var response = await client.readDir(path);
      List fileList = [];
      for (var item in response) {
        fileList.add({
          'path': item.path,
          'isDir': item.isDir,
          'name': item.name,
          'mimeType': item.mimeType,
          'size': item.size,
          'eTag': item.eTag,
          'cTime': item.cTime,
          'mTime': item.mTime,
        });
      }
      return ['success', fileList];
    } catch (e) {
      flogErr(
          e,
          {
            'path': path,
          },
          "WebdavManageAPI",
          "getFileList");
      return [e.toString()];
    }
  }

  createDir(String path) async {
    try {
      webdav.Client client = await getWebdavClient();
      await client.mkdirAll(path);
      return ['success'];
    } catch (e) {
      flogErr(
          e,
          {
            'path': path,
          },
          "WebdavManageAPI",
          "createDir");
      return [e.toString()];
    }
  }

  deleteFile(String path) async {
    try {
      webdav.Client client = await getWebdavClient();
      await client.remove(path);
      return ['success'];
    } catch (e) {
      flogErr(
          e,
          {
            'path': path,
          },
          "WebdavManageAPI",
          "deleteFile");
      return [e.toString()];
    }
  }

  renameFile(
    String path,
    String newName,
  ) async {
    try {
      webdav.Client client = await getWebdavClient();
      await client.rename(path, newName, true);
      return ['success'];
    } catch (e) {
      flogErr(
          e,
          {
            'path': path,
            'newName': newName,
          },
          "WebdavManageAPI",
          "renameFile");
      return [e.toString()];
    }
  }

  setDefaultBucket(String folder) async {
    try {
      Map configMap = await getConfigMap();
      String host = configMap['host'];
      String webdavusername = configMap['webdavusername'];
      String password = configMap['password'];
      String? customUrl = configMap['customUrl'];
      String? webPath = configMap['webPath'];
      String uploadPath = folder;

      customUrl ??= 'None';
      webPath ??= 'None';

      final webdavConfig = WebdavConfigModel(host, webdavusername, password, uploadPath, customUrl, webPath);
      final webdavConfigJson = jsonEncode(webdavConfig);
      final webdavConfigFile = await localFile();
      await webdavConfigFile.writeAsString(webdavConfigJson);
      return ['success'];
    } catch (e) {
      flogErr(
          e,
          {
            'folder': folder,
          },
          "WebdavManageAPI",
          "setDefaultBucket");
      return ['failed'];
    }
  }

  //上传文件
  uploadFile(
    String filename,
    String filepath,
    String prefix,
  ) async {
    try {
      webdav.Client client = await getWebdavClient();
      await client.writeFromFile(filepath, prefix + filename);
      return ['success'];
    } catch (e) {
      flogErr(e, {'filename': filename, 'filepath': filepath, 'prefix': prefix}, "WebdavManageAPI", "uploadFile");
      return ['error'];
    }
  }

  //从网络链接下载文件后上传
  uploadNetworkFile(String fileLink, String prefix) async {
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
      var uploadResult = await uploadFile(
        filename,
        saveFilePath,
        prefix,
      );
      if (uploadResult[0] == "success") {
        return ['success'];
      }
      return ['failed'];
    } catch (e) {
      flogErr(e, {'fileLink': fileLink, 'prefix': prefix}, "WebdavManageAPI", "uploadNetworkFile");
      return ['failed'];
    }
  }

  uploadNetworkFileEntry(List fileList, String prefix) async {
    int successCount = 0;
    int failCount = 0;

    for (String fileLink in fileList) {
      if (fileLink.isEmpty) {
        continue;
      }
      var uploadResult = await uploadNetworkFile(fileLink, prefix);
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
