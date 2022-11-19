import 'dart:io';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/services.dart';
import 'package:f_logs/f_logs.dart';
import 'package:path_provider/path_provider.dart';

import 'package:horopic/utils/global.dart';
import 'package:horopic/utils/sql_utils.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/picture_host_configure/configure_page/github_configure.dart';

class GithubManageAPI {
  static Future<File> get _localFile async {
    final path = await _localPath;
    String defaultUser = await Global.getUser();
    return File('$path/${defaultUser}_github_config.txt');
  }

  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<String> readGithubConfig() async {
    try {
      final file = await _localFile;
      String contents = await file.readAsString();
      return contents;
    } catch (e) {
      FLog.error(
          className: 'GithubManageAPI',
          methodName: 'readGithubConfig',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      return "Error";
    }
  }

  static Future<Map> getConfigMap() async {
    String configStr = await readGithubConfig();
    Map configMap = json.decode(configStr);
    return configMap;
  }

  static isString(var variable) {
    return variable is String;
  }

  static isFile(var variable) {
    return variable is File;
  }

  static getUserInfo() async {
    Map configMap = await getConfigMap();
    String githubusername = configMap['githubusername'];
    String token = configMap['token'];
    String host = 'https://api.github.com/users/$githubusername';

    BaseOptions baseoptions = BaseOptions(
      sendTimeout: 30000,
      receiveTimeout: 30000,
      connectTimeout: 30000,
    );
    baseoptions.headers = {
      'Authorization': token,
      'Accept': 'application/vnd.github+json',
    };

    Dio dio = Dio(baseoptions);
    try {
      var response = await dio.get(host);
      if (response.statusCode == 200) {
        return ['success', response.data];
      } else {
        return ['failed'];
      }
    } catch (e) {
      if (e is DioError) {
        FLog.error(
            className: "GithubManageAPI",
            methodName: "getUserInfo",
            text: formatErrorMessage({}, e.toString(),
                isDioError: true, dioErrorMessage: e),
            dataLogType: DataLogType.ERRORS.toString());
      } else {
        FLog.error(
            className: "GithubManageAPI",
            methodName: "getUserInfo",
            text: formatErrorMessage({}, e.toString()),
            dataLogType: DataLogType.ERRORS.toString());
      }
      return [e.toString()];
    }
  }

  // 获取仓库列表
  static getReposList() async {
    List reposList = [];
    Map configMap = await getConfigMap();
    String token = configMap['token'];
    String host = 'https://api.github.com/user/repos';
    int page = 1;
    int perPage = 10;

    BaseOptions baseoptions = BaseOptions(
      sendTimeout: 30000,
      receiveTimeout: 30000,
      connectTimeout: 30000,
    );
    baseoptions.headers = {
      'Authorization': token,
      'Accept': 'application/vnd.github+json',
    };

    Dio dio = Dio(baseoptions);
    try {
      var response = await dio
          .get(host, queryParameters: {'page': page, 'per_page': perPage});
      if (response.statusCode == 200) {
        if (response.data.length > 0) {
          reposList.addAll(response.data);
        } else {
          return ['success', reposList];
        }
        while (true) {
          page += 1;
          response = await dio
              .get(host, queryParameters: {'page': page, 'per_page': perPage});
          if (response.statusCode == 200) {
            if (response.data.length > 0) {
              reposList.addAll(response.data);
            } else {
              return ['success', reposList];
            }
          } else {
            return ['failed'];
          }
        }
      } else {
        return ['failed'];
      }
    } catch (e) {
      if (e is DioError) {
        FLog.error(
            className: "GithubManageAPI",
            methodName: "getReposList",
            text: formatErrorMessage({}, e.toString(),
                isDioError: true, dioErrorMessage: e),
            dataLogType: DataLogType.ERRORS.toString());
      } else {
        FLog.error(
            className: "GithubManageAPI",
            methodName: "getReposList",
            text: formatErrorMessage({}, e.toString()),
            dataLogType: DataLogType.ERRORS.toString());
      }
      return [e.toString()];
    }
  }

  // 获取仓库列表
  static getOtherReposList(String username) async {
    List reposList = [];
    Map configMap = await getConfigMap();
    String token = configMap['token'];

    String host = 'https://api.github.com/users/$username/repos';
    int page = 1;
    int perPage = 10;

    BaseOptions baseoptions = BaseOptions(
      sendTimeout: 30000,
      receiveTimeout: 30000,
      connectTimeout: 30000,
    );
    baseoptions.headers = {
      'Authorization': token,
      'Accept': 'application/vnd.github+json',
    };

    Dio dio = Dio(baseoptions);
    try {
      var response = await dio
          .get(host, queryParameters: {'page': page, 'per_page': perPage});
      if (response.statusCode == 200) {
        if (response.data.length > 0) {
          reposList.addAll(response.data);
        } else {
          return ['success', reposList];
        }
        while (true) {
          page += 1;
          response = await dio
              .get(host, queryParameters: {'page': page, 'per_page': perPage});
          if (response.statusCode == 200) {
            if (response.data.length > 0) {
              reposList.addAll(response.data);
            } else {
              return ['success', reposList];
            }
          } else {
            return ['failed'];
          }
        }
      } else {
        return ['failed'];
      }
    } catch (e) {
      if (e is DioError) {
        FLog.error(
            className: "GithubManageAPI",
            methodName: "getOtherReposList",
            text: formatErrorMessage({}, e.toString(),
                isDioError: true, dioErrorMessage: e),
            dataLogType: DataLogType.ERRORS.toString());
      } else {
        FLog.error(
            className: "GithubManageAPI",
            methodName: "getOtherReposList",
            text: formatErrorMessage({}, e.toString()),
            dataLogType: DataLogType.ERRORS.toString());
      }
      return [e.toString()];
    }
  }

  //创建仓库
  static createRepo(Map newRepoInfo) async {
    Map configMap = await getConfigMap();
    String token = configMap['token'];
    String host = 'https://api.github.com/user/repos';

    BaseOptions baseoptions = BaseOptions(
      sendTimeout: 30000,
      receiveTimeout: 30000,
      connectTimeout: 30000,
    );
    baseoptions.headers = {
      'Authorization': token,
      'Accept': 'application/vnd.github+json',
    };

    Dio dio = Dio(baseoptions);
    try {
      var response = await dio.post(host, data: newRepoInfo);
      if (response.statusCode == 201) {
        return showToast('创建成功');
      } else {
        return showToast('创建失败');
      }
    } catch (e) {
      if (e is DioError) {
        FLog.error(
            className: "GithubManageAPI",
            methodName: "createRepo",
            text: formatErrorMessage({
              'newRepoInfo': newRepoInfo,
            }, e.toString(), isDioError: true, dioErrorMessage: e),
            dataLogType: DataLogType.ERRORS.toString());
      } else {
        FLog.error(
            className: "GithubManageAPI",
            methodName: "createRepo",
            text: formatErrorMessage({
              'newRepoInfo': newRepoInfo,
            }, e.toString()),
            dataLogType: DataLogType.ERRORS.toString());
      }
      return showToast('创建失败');
    }
  }

  //获取仓库根目录sha
  static getRootDirSha(String username, String repoName, String branch) async {
    Map configMap = await getConfigMap();
    String token = configMap['token'];
    String host =
        'https://api.github.com/repos/$username/$repoName/branches/$branch';

    BaseOptions baseoptions = BaseOptions(
      sendTimeout: 30000,
      receiveTimeout: 30000,
      connectTimeout: 30000,
    );
    baseoptions.headers = {
      'Authorization': token,
      'Accept': 'application/vnd.github+json',
    };

    Dio dio = Dio(baseoptions);
    try {
      var response = await dio.get(host);
      if (response.statusCode == 200) {
        String sha = response.data['commit']['commit']['tree']['sha'];

        return ['success', sha];
      } else {
        return ['failed'];
      }
    } catch (e) {
      if (e is DioError) {
        FLog.error(
            className: "GithubManageAPI",
            methodName: "getRootDirSha",
            text: formatErrorMessage({
              'username': username,
              'repoName': repoName,
            }, e.toString(), isDioError: true, dioErrorMessage: e),
            dataLogType: DataLogType.ERRORS.toString());
      } else {
        FLog.error(
            className: "GithubManageAPI",
            methodName: "getRootDirSha",
            text: formatErrorMessage({
              'username': username,
              'repoName': repoName,
            }, e.toString()),
            dataLogType: DataLogType.ERRORS.toString());
      }
      return [e.toString()];
    }
  }

  //获取仓库目录文件列表
  static getRepoDirList(String username, String repoName, String sha) async {
    Map configMap = await getConfigMap();
    String token = configMap['token'];
    String host =
        'https://api.github.com/repos/$username/$repoName/git/trees/$sha';

    BaseOptions baseoptions = BaseOptions(
      sendTimeout: 30000,
      receiveTimeout: 30000,
      connectTimeout: 30000,
    );
    baseoptions.headers = {
      'Authorization': token,
      'Accept': 'application/vnd.github+json',
    };

    Dio dio = Dio(baseoptions);
    try {
      var response = await dio.get(host);
      if (response.statusCode == 200) {
        List fileList = response.data['tree'];
        return ['success', fileList];
      } else {
        return ['failed'];
      }
    } catch (e) {
      if (e is DioError) {
        FLog.error(
            className: "GithubManageAPI",
            methodName: "getRepoDirList",
            text: formatErrorMessage({
              'username': username,
              'repoName': repoName,
            }, e.toString(), isDioError: true, dioErrorMessage: e),
            dataLogType: DataLogType.ERRORS.toString());
      } else {
        FLog.error(
            className: "GithubManageAPI",
            methodName: "getRepoDirList",
            text: formatErrorMessage({
              'username': username,
              'repoName': repoName,
            }, e.toString()),
            dataLogType: DataLogType.ERRORS.toString());
      }
      return [e.toString()];
    }
  }

  //判断是否是空目录
  static isDirEmpty(
      String username, String repoName, String bucketPrefix) async {
    Map configMap = await getConfigMap();
    String token = configMap['token'];
    String host =
        'https://api.github.com/repos/$username/$repoName/contents/$bucketPrefix';

    BaseOptions baseoptions = BaseOptions(
      sendTimeout: 30000,
      receiveTimeout: 30000,
      connectTimeout: 30000,
    );
    baseoptions.headers = {
      'Authorization': token,
      'Accept': 'application/vnd.github+json',
    };

    Dio dio = Dio(baseoptions);
    try {
      var response = await dio.get(host);
      if (response.statusCode == 200) {
        List fileList = response.data;
        if (fileList.isEmpty) {
          return ['empty'];
        } else {
          return ['not empty'];
        }
      }
    } catch (e) {
      if (e is DioError) {
        if (e.toString().contains('This repository is empty')) {
          return ['empty'];
        } else {
          FLog.error(
              className: "GithubManageAPI",
              methodName: "isDirEmpty",
              text: formatErrorMessage({
                'username': username,
                'repoName': repoName,
              }, e.toString(), isDioError: true, dioErrorMessage: e),
              dataLogType: DataLogType.ERRORS.toString());
        }
      } else {
        FLog.error(
            className: "GithubManageAPI",
            methodName: "isDirEmpty",
            text: formatErrorMessage({
              'username': username,
              'repoName': repoName,
            }, e.toString()),
            dataLogType: DataLogType.ERRORS.toString());
      }
      return ['error'];
    }
  }

  //获取仓库文件内容
  static getRepoFileContent(
      String username, String repoName, String filePath) async {
    Map configMap = await getConfigMap();
    String token = configMap['token'];
    String host =
        'https://api.github.com/repos/$username/$repoName/contents/$filePath';

    BaseOptions baseoptions = BaseOptions(
      sendTimeout: 30000,
      receiveTimeout: 30000,
      connectTimeout: 30000,
    );
    baseoptions.headers = {
      'Authorization': token,
      'Accept': 'application/vnd.github+json',
    };

    Dio dio = Dio(baseoptions);
    try {
      var response = await dio.get(host);
      if (response.statusCode == 200) {
        var content = response.data;
        return ['success', content];
      } else {
        return ['failed'];
      }
    } catch (e) {
      if (e is DioError) {
        FLog.error(
            className: "GithubManageAPI",
            methodName: "getRepoFileContent",
            text: formatErrorMessage({
              'username': username,
              'repoName': repoName,
            }, e.toString(), isDioError: true, dioErrorMessage: e),
            dataLogType: DataLogType.ERRORS.toString());
      } else {
        FLog.error(
            className: "GithubManageAPI",
            methodName: "getRepoFileContent",
            text: formatErrorMessage({
              'username': username,
              'repoName': repoName,
            }, e.toString()),
            dataLogType: DataLogType.ERRORS.toString());
      }
      return [e.toString()];
    }
  }

  //删除仓库文件
  static deleteRepoFile(String username, String repoName, String path,
      String sha, String branch) async {
    Map configMap = await getConfigMap();
    String token = configMap['token'];
    String host =
        'https://api.github.com/repos/$username/$repoName/contents/$path';

    BaseOptions baseoptions = BaseOptions(
      sendTimeout: 30000,
      receiveTimeout: 30000,
      connectTimeout: 30000,
    );
    baseoptions.headers = {
      'Authorization': token,
      'Accept': 'application/vnd.github+json',
    };

    Map<String, dynamic> data = {
      'message': 'deleted by PicHoro app',
      'sha': sha,
      'branch': branch,
    };

    Dio dio = Dio(baseoptions);
    try {
      var response = await dio.delete(host, data: data);
      if (response.statusCode == 200) {
        return ['success'];
      } else {
        return ['failed'];
      }
    } catch (e) {
      if (e is DioError) {
        FLog.error(
            className: "GithubManageAPI",
            methodName: "deleteRepoFile",
            text: formatErrorMessage({
              'username': username,
              'repoName': repoName,
              'path': path,
              'branch': branch,
            }, e.toString(), isDioError: true, dioErrorMessage: e),
            dataLogType: DataLogType.ERRORS.toString());
      } else {
        FLog.error(
            className: "GithubManageAPI",
            methodName: "deleteRepoFile",
            text: formatErrorMessage({
              'username': username,
              'repoName': repoName,
              'path': path,
              'branch': branch,
            }, e.toString()),
            dataLogType: DataLogType.ERRORS.toString());
      }
      return [e.toString()];
    }
  }

  //删除仓库目录
  static deleteFolder(
    String username,
    String repoName,
    String path,
    String branch,
    String sha,
  ) async {
    try {
      var res = await getRepoDirList(username, repoName, sha);
      if (res[0] != 'success') {
        return showToast('获取目录列表失败');
      }
      List files = [];
      List dirs = [];
      for (var i = 0; i < res[1].length; i++) {
        if (res[1][i]['type'] == 'blob') {
          files.add(res[1][i]);
        } else if (res[1][i]['type'] == 'tree') {
          dirs.add(res[1][i]);
        }
      }
      for (var i = 0; i < files.length; i++) {
        var res = await deleteRepoFile(username, repoName,
            path + files[i]['path'], files[i]['sha'], branch);
        if (res[0] != 'success') {
          return showToast('删除文件失败');
        }
      }
      for (var i = 0; i < dirs.length; i++) {
        await deleteFolder(username, repoName, '${path + dirs[i]['path']}/',
            branch, dirs[i]['sha']);
      }
    } catch (e) {
      if (e is DioError) {
        FLog.error(
            className: "GithubManageAPI",
            methodName: "deleteFolder",
            text: formatErrorMessage({
              'username': username,
              'repoName': repoName,
              'path': path,
            }, e.toString(), isDioError: true, dioErrorMessage: e),
            dataLogType: DataLogType.ERRORS.toString());
      } else {
        FLog.error(
            className: "GithubManageAPI",
            methodName: "deleteFolder",
            text: formatErrorMessage({
              'username': username,
              'repoName': repoName,
              'path': path,
            }, e.toString()),
            dataLogType: DataLogType.ERRORS.toString());
      }
      return [e.toString()];
    }
  }

  //仓库设为默认图床
  static setDefaultRepo(Map element, String? folder) async {
    try {
      Map configMap = await getConfigMap();
      String githubusername = configMap['githubusername'];
      String repo = element['name'];
      String token = configMap['token'];
      String branch = element['default_branch'];
      String customDomain = 'None';
      String storePath = '';

      if (folder == null) {
        storePath = configMap['storePath'];
      } else {
        storePath = folder;
      }
      List sqlconfig = [];
      sqlconfig.add(githubusername);
      sqlconfig.add(repo);
      sqlconfig.add(token);
      sqlconfig.add(storePath);
      sqlconfig.add(branch);
      sqlconfig.add(customDomain);

      String defaultUser = await Global.getUser();
      sqlconfig.add(defaultUser);
      var queryTencent = await MySqlUtils.queryGithub(username: defaultUser);
      var queryuser = await MySqlUtils.queryUser(username: defaultUser);

      if (queryuser == 'Empty') {
        return ['failed'];
      }
      var sqlResult = '';

      if (queryTencent == 'Empty') {
        sqlResult = await MySqlUtils.insertGithub(content: sqlconfig);
      } else {
        sqlResult = await MySqlUtils.updateGithub(content: sqlconfig);
      }

      if (sqlResult == "Success") {
        final githubConfig = GithubConfigModel(
            githubusername, repo, token, storePath, branch, customDomain);
        final githubConfigJson = jsonEncode(githubConfig);
        final githubConfigFile = await _localFile;
        await githubConfigFile.writeAsString(githubConfigJson);
        return ['success'];
      } else {
        return ['failed'];
      }
    } catch (e) {
      FLog.error(
          className: "GithubManageAPI",
          methodName: "setDefaultRepo",
          text: formatErrorMessage({'folder': folder}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      return ['failed'];
    }
  }

  //新建文件夹
  static createFolder(Map element, String newPrefix) async {
    Map configMap = await getConfigMap();
    String token = configMap['token'];

    String assetPath = 'assets/validateImage/PicHoroValidate.jpeg';
    String appDir = await getApplicationDocumentsDirectory().then((value) {
      return value.path;
    });
    String assetFilePath = '$appDir/PicHoroValidate.jpeg';
    File assetFile = File(assetFilePath);

    if (!assetFile.existsSync()) {
      ByteData data = await rootBundle.load(assetPath);
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await assetFile.writeAsBytes(bytes);
    }
    String base64Image = base64Encode(File(assetFilePath).readAsBytesSync());

    Map<String, dynamic> queryBody = {
      'message': 'uploaded by PicHoro app',
      'content': base64Image,
      'branch': element['default_branch'],
    };

    BaseOptions baseoptions = BaseOptions(
      connectTimeout: 30000,
      receiveTimeout: 30000,
      sendTimeout: 30000,
    );

    baseoptions.headers = {
      'Authorization': token,
      'Accept': 'application/vnd.github+json',
    };

    String trimedPath = newPrefix.toString().trim();

    if (trimedPath.startsWith('/')) {
      trimedPath = trimedPath.substring(1);
    }
    if (trimedPath.endsWith('/')) {
      trimedPath = trimedPath.substring(0, trimedPath.length - 1);
    }
    Dio dio = Dio(baseoptions);
    String uploadUrl = '';
    uploadUrl =
        "https://api.github.com/repos/${configMap["githubusername"]}/${element["name"]}/contents/$trimedPath/PicHoroValidate.jpeg";
    try {
      var response = await dio.put(uploadUrl, data: queryBody);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return [
          'success',
        ];
      } else {
        return ['failed'];
      }
    } catch (e) {
      if (e is DioError) {
        FLog.error(
            className: "GithubManageAPI",
            methodName: "createFolder",
            text: formatErrorMessage({
              'newPrefix': newPrefix,
            }, e.toString(), isDioError: true, dioErrorMessage: e),
            dataLogType: DataLogType.ERRORS.toString());
      } else {
        FLog.error(
            className: "GithubManageAPI",
            methodName: "createFolder",
            text: formatErrorMessage({
              'newPrefix': newPrefix,
            }, e.toString()),
            dataLogType: DataLogType.ERRORS.toString());
      }
      return [e.toString()];
    }
  }

  //上传文件
  static uploadFile(
      Map element, String filename, String filePath, String newPrefix) async {
    Map configMap = await getConfigMap();
    String token = configMap['token'];
    String base64Image = base64Encode(File(filePath).readAsBytesSync());

    Map<String, dynamic> queryBody = {
      'message': 'uploaded by PicHoro app',
      'content': base64Image,
      'branch': element['default_branch'],
    };

    BaseOptions baseoptions = BaseOptions(
      connectTimeout: 30000,
      receiveTimeout: 30000,
      sendTimeout: 30000,
    );

    baseoptions.headers = {
      'Authorization': token,
      'Accept': 'application/vnd.github+json',
    };

    String trimedPath = newPrefix.toString().trim();

    if (trimedPath.startsWith('/')) {
      trimedPath = trimedPath.substring(1);
    }
    if (trimedPath.endsWith('/')) {
      trimedPath = trimedPath.substring(0, trimedPath.length - 1);
    }
    Dio dio = Dio(baseoptions);
    String uploadUrl = '';
    if (trimedPath == '') {
      uploadUrl =
          "https://api.github.com/repos/${configMap["githubusername"]}/${element["name"]}/contents/$filename";
    } else {
      uploadUrl =
          "https://api.github.com/repos/${configMap["githubusername"]}/${element["name"]}/contents/$trimedPath/$filename";
    }

    try {
      var response = await dio.put(uploadUrl, data: queryBody);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return [
          'success',
        ];
      } else {
        return ['failed'];
      }
    } catch (e) {
      if (e is DioError) {
        FLog.error(
            className: "GithubManageAPI",
            methodName: "uploadFile",
            text: formatErrorMessage({
              'filePath': filePath,
              'newPrefix': newPrefix,
            }, e.toString(), isDioError: true, dioErrorMessage: e),
            dataLogType: DataLogType.ERRORS.toString());
      } else {
        FLog.error(
            className: "GithubManageAPI",
            methodName: "uploadFile",
            text: formatErrorMessage({
              'filePath': filePath,
              'newPrefix': newPrefix,
            }, e.toString()),
            dataLogType: DataLogType.ERRORS.toString());
      }
      return [e.toString()];
    }
  }

  //从网络链接下载文件后上传
  static uploadNetworkFile(String fileLink, Map element, String prefix) async {
    try {
      String filename =
          fileLink.substring(fileLink.lastIndexOf("/") + 1, fileLink.length);
      filename = filename.substring(
          0, !filename.contains("?") ? filename.length : filename.indexOf("?"));
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
      if (e is DioError) {
        FLog.error(
            className: "GithubManageAPI",
            methodName: "uploadNetworkFile",
            text: formatErrorMessage(
                {'fileLink': fileLink, 'prefix': prefix}, e.toString(),
                isDioError: true, dioErrorMessage: e),
            dataLogType: DataLogType.ERRORS.toString());
      } else {
        FLog.error(
            className: "GithubManageAPI",
            methodName: "uploadNetworkFile",
            text: formatErrorMessage(
                {'fileLink': fileLink, 'prefix': prefix}, e.toString()),
            dataLogType: DataLogType.ERRORS.toString());
      }
      return ['failed'];
    }
  }

  static uploadNetworkFileEntry(
      List fileList, Map element, String prefix) async {
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
      return Fluttertoast.showToast(
          msg: '上传失败',
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 2,
          fontSize: 16.0);
    } else if (failCount == 0) {
      return Fluttertoast.showToast(
          msg: '上传成功',
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 2,
          fontSize: 16.0);
    } else {
      return Fluttertoast.showToast(
          msg: '成功$successCount,失败$failCount',
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 2,
          fontSize: 16.0);
    }
  }
}
