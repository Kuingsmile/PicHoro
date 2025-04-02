import 'dart:io';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:horopic/picture_host_manage/common/base_manage_api.dart';
import 'package:path_provider/path_provider.dart';

import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/picture_host_configure/configure_page/github_configure.dart';

class GithubManageAPI extends BaseManageApi {
  static final GithubManageAPI _instance = GithubManageAPI._internal();

  factory GithubManageAPI() {
    return _instance;
  }

  GithubManageAPI._internal();

  @override
  String configFileName() => 'github_config.txt';

  Future<List<dynamic>> _makeRequest(
      {required String url,
      required String method,
      Map<String, dynamic>? headers,
      Map<String, dynamic>? params,
      dynamic data,
      required Function(Response) onSuccess,
      dynamic onFailure,
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
          "GithubManageAPI",
          callFunction);
      return onFailure ?? ['failed'];
    } catch (e) {
      flogErr(e, {'url': url, 'data': data, 'method': method, 'params': params, 'headers': headers}, "GithubManageAPI",
          callFunction);
      return [e.toString()];
    }
  }

  getUserInfo() async {
    try {
      Map configMap = await getConfigMap();
      String host = 'https://api.github.com/users/${configMap['githubusername']}';
      return await _makeRequest(
        url: host,
        method: 'GET',
        headers: {
          'Authorization': configMap['token'],
          'Accept': 'application/vnd.github+json',
        },
        onSuccess: (response) => ['success', response.data],
        checkSuccess: (response) => response.statusCode == 200,
        callFunction: 'getUserInfo',
      );
    } catch (e) {
      flogErr(e, {}, "GithubManageAPI", "getUserInfo");
      return [e.toString()];
    }
  }

  getReposList() async {
    try {
      Map configMap = await getConfigMap();
      List reposList = [];
      String host = 'https://api.github.com/user/repos';
      int page = 0;
      BaseOptions baseoptions = setBaseOptions()
        ..headers = {
          'Authorization': configMap['token'],
          'Accept': 'application/vnd.github+json',
        };
      Dio dio = Dio(baseoptions);
      while (true) {
        page = page + 1;
        var response = await dio.get(host, queryParameters: {'page': page, 'per_page': 10});
        if (response.statusCode != 200) {
          return ['failed'];
        }
        if (response.data.length <= 0) {
          return ['success', reposList];
        }
        reposList.addAll(response.data);
      }
    } catch (e) {
      flogErr(e, {}, "GithubManageAPI", "getReposList");
      return [e.toString()];
    }
  }

  getOtherReposList(String username) async {
    try {
      Map configMap = await getConfigMap();
      List reposList = [];
      String host = 'https://api.github.com/users/$username/repos';
      int page = 0;
      BaseOptions baseoptions = setBaseOptions();
      baseoptions.headers = {
        'Authorization': configMap['token'],
        'Accept': 'application/vnd.github+json',
      };
      Dio dio = Dio(baseoptions);

      while (true) {
        page = page + 1;
        var response = await dio.get(host, queryParameters: {'page': page, 'per_page': 10});
        if (response.statusCode != 200) {
          return ['failed'];
        }
        if (response.data.length > 0) {
          reposList.addAll(response.data);
        } else {
          return ['success', reposList];
        }
      }
    } catch (e) {
      flogErr(
          e,
          {
            'username': username,
          },
          "GithubManageAPI",
          "getOtherReposList");
      return [e.toString()];
    }
  }

  //创建仓库
  createRepo(Map newRepoInfo) async {
    try {
      Map configMap = await getConfigMap();
      String host = 'https://api.github.com/user/repos';
      return await _makeRequest(
        url: host,
        method: 'POST',
        headers: {
          'Authorization': configMap['token'],
          'Accept': 'application/vnd.github+json',
        },
        data: newRepoInfo,
        onSuccess: (response) => showToast('创建成功'),
        checkSuccess: (response) => response.statusCode == 201,
        callFunction: 'createRepo',
      );
    } catch (e) {
      flogErr(
          e,
          {
            'newRepoInfo': newRepoInfo,
          },
          "GithubManageAPI",
          "createRepo");
      return showToast('创建失败');
    }
  }

  //获取仓库根目录sha
  getRootDirSha(String username, String repoName, String branch) async {
    try {
      Map configMap = await getConfigMap();
      String host = 'https://api.github.com/repos/$username/$repoName/branches/$branch';
      return await _makeRequest(
        url: host,
        method: 'GET',
        headers: {
          'Authorization': configMap['token'],
          'Accept': 'application/vnd.github+json',
        },
        onSuccess: (response) => ['success', response.data['commit']['commit']['tree']['sha']],
        checkSuccess: (response) => response.statusCode == 200,
        callFunction: 'getRootDirSha',
      );
    } catch (e) {
      flogErr(
          e,
          {
            'username': username,
            'repoName': repoName,
            'branch': branch,
          },
          "GithubManageAPI",
          "getRootDirSha");
      return [e.toString()];
    }
  }

  getRepoDirList(String username, String repoName, String sha) async {
    try {
      Map configMap = await getConfigMap();
      String host = 'https://api.github.com/repos/$username/$repoName/git/trees/$sha';
      return await _makeRequest(
        url: host,
        method: 'GET',
        headers: {
          'Authorization': configMap['token'],
          'Accept': 'application/vnd.github+json',
        },
        onSuccess: (response) => ['success', response.data['tree']],
        checkSuccess: (response) => response.statusCode == 200,
        callFunction: 'getRepoDirList',
      );
    } catch (e) {
      flogErr(
          e,
          {
            'username': username,
            'repoName': repoName,
            'sha': sha,
          },
          "GithubManageAPI",
          "getRepoDirList");
      return [e.toString()];
    }
  }

  isDirEmpty(String username, String repoName, String bucketPrefix) async {
    try {
      Map configMap = await getConfigMap();
      String host = 'https://api.github.com/repos/$username/$repoName/contents/$bucketPrefix';
      BaseOptions baseoptions = setBaseOptions();
      baseoptions.headers = {
        'Authorization': configMap['token'],
        'Accept': 'application/vnd.github+json',
      };
      Dio dio = Dio(baseoptions);
      var response = await dio.get(host);
      if (response.statusCode == 200) {
        return response.data.isEmpty ? ['empty'] : ['not empty'];
      }
    } catch (e) {
      if (e is DioException && e.toString().contains('This repository is empty')) {
        return ['empty'];
      }
      flogErr(
          e,
          {
            'username': username,
            'repoName': repoName,
            'bucketPrefix': bucketPrefix,
          },
          'GithubManageAPI',
          'isDirEmpty');
      return ['error'];
    }
  }

  //获取仓库文件内容
  getRepoFileContent(String username, String repoName, String filePath) async {
    try {
      Map configMap = await getConfigMap();
      String host = 'https://api.github.com/repos/$username/$repoName/contents/$filePath';
      return await _makeRequest(
        url: host,
        method: 'GET',
        headers: {
          'Authorization': configMap['token'],
          'Accept': 'application/vnd.github+json',
        },
        onSuccess: (response) => ['success', response.data],
        checkSuccess: (response) => response.statusCode == 200,
        callFunction: 'getRepoFileContent',
      );
    } catch (e) {
      flogErr(
          e,
          {
            'username': username,
            'repoName': repoName,
            'filePath': filePath,
          },
          'GithubManageAPI',
          'getRepoFileContent');
      return [e.toString()];
    }
  }

  deleteRepoFile(String username, String repoName, String path, String sha, String branch) async {
    try {
      Map configMap = await getConfigMap();
      String host = 'https://api.github.com/repos/$username/$repoName/contents/$path';
      return await _makeRequest(
        url: host,
        method: 'DELETE',
        headers: {
          'Authorization': configMap['token'],
          'Accept': 'application/vnd.github+json',
        },
        data: {
          'message': 'deleted by PicHoro app',
          'sha': sha,
          'branch': branch,
        },
        onSuccess: (response) => ['success'],
        checkSuccess: (response) => response.statusCode == 200,
        callFunction: 'deleteRepoFile',
      );
    } catch (e) {
      flogErr(
          e,
          {
            'username': username,
            'repoName': repoName,
            'path': path,
            'sha': sha,
            'branch': branch,
          },
          "GithubManageAPI",
          "deleteRepoFile");
      return [e.toString()];
    }
  }

  //删除仓库目录
  deleteFolder(
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
        var res = await deleteRepoFile(username, repoName, path + files[i]['path'], files[i]['sha'], branch);
        if (res[0] != 'success') {
          return showToast('删除文件失败');
        }
      }
      for (var i = 0; i < dirs.length; i++) {
        await deleteFolder(username, repoName, '${path + dirs[i]['path']}/', branch, dirs[i]['sha']);
      }
    } catch (e) {
      flogErr(
          e,
          {
            'username': username,
            'repoName': repoName,
            'path': path,
            'branch': branch,
            'sha': sha,
          },
          "GithubManageAPI",
          "deleteFolder");
      return [e.toString()];
    }
  }

  setDefaultRepo(Map element, String? folder) async {
    try {
      Map configMap = await getConfigMap();
      final githubConfig = GithubConfigModel(configMap['githubusername'], element['name'], configMap['token'],
          folder ?? configMap['storePath'], element['default_branch'], 'None');
      final githubConfigJson = jsonEncode(githubConfig);
      final githubConfigFile = await localFile();
      await githubConfigFile.writeAsString(githubConfigJson);
      return ['success'];
    } catch (e) {
      flogErr(
          e,
          {
            'element': element,
            'folder': folder,
          },
          "GithubManageAPI",
          "setDefaultRepo");
      return ['failed'];
    }
  }

  createFolder(Map element, String newPrefix) async {
    try {
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
        List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
        await assetFile.writeAsBytes(bytes);
      }
      String base64Image = base64Encode(File(assetFilePath).readAsBytesSync());

      Map<String, dynamic> queryBody = {
        'message': 'uploaded by PicHoro app',
        'content': base64Image,
        'branch': element['default_branch'],
      };

      BaseOptions baseoptions = setBaseOptions();

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

      var response = await dio.put(uploadUrl, data: queryBody);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return [
          'success',
        ];
      }
      return ['failed'];
    } catch (e) {
      flogErr(
          e,
          {
            'element': element,
            'newPrefix': newPrefix,
          },
          "GithubManageAPI",
          "createFolder");
      return [e.toString()];
    }
  }

  uploadFile(Map element, String filename, String filePath, String newPrefix) async {
    try {
      Map configMap = await getConfigMap();
      String token = configMap['token'];
      String base64Image = base64Encode(File(filePath).readAsBytesSync());

      Map<String, dynamic> queryBody = {
        'message': 'uploaded by PicHoro app',
        'content': base64Image,
        'branch': element['default_branch'],
      };

      BaseOptions baseoptions = setBaseOptions();

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
        uploadUrl = "https://api.github.com/repos/${configMap["githubusername"]}/${element["name"]}/contents/$filename";
      } else {
        uploadUrl =
            "https://api.github.com/repos/${configMap["githubusername"]}/${element["name"]}/contents/$trimedPath/$filename";
      }

      var response = await dio.put(uploadUrl, data: queryBody);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return [
          'success',
        ];
      }
      return ['failed'];
    } catch (e) {
      flogErr(
          e,
          {
            'element': element,
            'filename': filename,
            'filePath': filePath,
            'newPrefix': newPrefix,
          },
          "GithubManageAPI",
          "uploadFile");
      return [e.toString()];
    }
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
      flogErr(
          e,
          {
            'fileLink': fileLink,
            'element': element,
            'prefix': prefix,
          },
          "GithubManageAPI",
          "uploadNetworkFile");
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
