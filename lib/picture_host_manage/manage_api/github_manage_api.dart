import 'dart:io';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import 'package:horopic/utils/global.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/picture_host_configure/configure_page/github_configure.dart';

class GithubManageAPI {
  static Future<File> get localFile async {
    final path = await _localPath;
    String defaultUser = Global.getUser();
    return ensureFileExists(File('$path/${defaultUser}_github_config.txt'));
  }

  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<String> readGithubConfig() async {
    try {
      final file = await localFile;
      String contents = await file.readAsString();
      return contents;
    } catch (e) {
      flogErr(e, {}, 'GithubManageAPI', 'readGithubConfig');
      return "Error";
    }
  }

  static Future<Map> getConfigMap() async {
    String configStr = await readGithubConfig();
    if (configStr == '') {
      return {};
    }
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
    try {
      Map configMap = await getConfigMap();
      String githubusername = configMap['githubusername'];
      String token = configMap['token'];
      String host = 'https://api.github.com/users/$githubusername';

      BaseOptions baseoptions = setBaseOptions();
      baseoptions.headers = {
        'Authorization': token,
        'Accept': 'application/vnd.github+json',
      };

      Dio dio = Dio(baseoptions);

      var response = await dio.get(host);
      if (response.statusCode == 200) {
        return ['success', response.data];
      } else {
        return ['failed'];
      }
    } catch (e) {
      flogErr(e, {}, "GithubManageAPI", "getUserInfo");
      return [e.toString()];
    }
  }

  // 获取仓库列表
  static getReposList() async {
    try {
      List reposList = [];
      Map configMap = await getConfigMap();
      String token = configMap['token'];
      String host = 'https://api.github.com/user/repos';
      int page = 1;
      int perPage = 10;

      BaseOptions baseoptions = setBaseOptions();
      baseoptions.headers = {
        'Authorization': token,
        'Accept': 'application/vnd.github+json',
      };

      Dio dio = Dio(baseoptions);

      var response = await dio.get(host, queryParameters: {'page': page, 'per_page': perPage});
      if (response.statusCode == 200) {
        if (response.data.length > 0) {
          reposList.addAll(response.data);
        } else {
          return ['success', reposList];
        }
        while (true) {
          page += 1;
          response = await dio.get(host, queryParameters: {'page': page, 'per_page': perPage});
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
      flogErr(e, {}, "GithubManageAPI", "getReposList");
      return [e.toString()];
    }
  }

  // 获取仓库列表
  static getOtherReposList(String username) async {
    try {
      List reposList = [];
      Map configMap = await getConfigMap();
      String token = configMap['token'];

      String host = 'https://api.github.com/users/$username/repos';
      int page = 1;
      int perPage = 10;

      BaseOptions baseoptions = setBaseOptions();
      baseoptions.headers = {
        'Authorization': token,
        'Accept': 'application/vnd.github+json',
      };

      Dio dio = Dio(baseoptions);

      var response = await dio.get(host, queryParameters: {'page': page, 'per_page': perPage});
      if (response.statusCode == 200) {
        if (response.data.length > 0) {
          reposList.addAll(response.data);
        } else {
          return ['success', reposList];
        }
        while (true) {
          page += 1;
          response = await dio.get(host, queryParameters: {'page': page, 'per_page': perPage});
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
  static createRepo(Map newRepoInfo) async {
    try {
      Map configMap = await getConfigMap();
      String token = configMap['token'];
      String host = 'https://api.github.com/user/repos';

      BaseOptions baseoptions = setBaseOptions();
      baseoptions.headers = {
        'Authorization': token,
        'Accept': 'application/vnd.github+json',
      };

      Dio dio = Dio(baseoptions);

      var response = await dio.post(host, data: newRepoInfo);
      if (response.statusCode == 201) {
        return showToast('创建成功');
      } else {
        return showToast('创建失败');
      }
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
  static getRootDirSha(String username, String repoName, String branch) async {
    try {
      Map configMap = await getConfigMap();
      String token = configMap['token'];
      String host = 'https://api.github.com/repos/$username/$repoName/branches/$branch';

      BaseOptions baseoptions = setBaseOptions();
      baseoptions.headers = {
        'Authorization': token,
        'Accept': 'application/vnd.github+json',
      };

      Dio dio = Dio(baseoptions);

      var response = await dio.get(host);
      if (response.statusCode == 200) {
        String sha = response.data['commit']['commit']['tree']['sha'];

        return ['success', sha];
      } else {
        return ['failed'];
      }
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

  //获取仓库目录文件列表
  static getRepoDirList(String username, String repoName, String sha) async {
    try {
      Map configMap = await getConfigMap();
      String token = configMap['token'];
      String host = 'https://api.github.com/repos/$username/$repoName/git/trees/$sha';

      BaseOptions baseoptions = setBaseOptions();
      baseoptions.headers = {
        'Authorization': token,
        'Accept': 'application/vnd.github+json',
      };

      Dio dio = Dio(baseoptions);

      var response = await dio.get(host);
      if (response.statusCode == 200) {
        List fileList = response.data['tree'];
        return ['success', fileList];
      } else {
        return ['failed'];
      }
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

  //判断是否是空目录
  static isDirEmpty(String username, String repoName, String bucketPrefix) async {
    try {
      Map configMap = await getConfigMap();
      String token = configMap['token'];
      String host = 'https://api.github.com/repos/$username/$repoName/contents/$bucketPrefix';

      BaseOptions baseoptions = setBaseOptions();
      baseoptions.headers = {
        'Authorization': token,
        'Accept': 'application/vnd.github+json',
      };

      Dio dio = Dio(baseoptions);

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
  static getRepoFileContent(String username, String repoName, String filePath) async {
    try {
      Map configMap = await getConfigMap();
      String token = configMap['token'];
      String host = 'https://api.github.com/repos/$username/$repoName/contents/$filePath';

      BaseOptions baseoptions = setBaseOptions();
      baseoptions.headers = {
        'Authorization': token,
        'Accept': 'application/vnd.github+json',
      };

      Dio dio = Dio(baseoptions);

      var response = await dio.get(host);
      if (response.statusCode == 200) {
        var content = response.data;
        return ['success', content];
      } else {
        return ['failed'];
      }
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

  //删除仓库文件
  static deleteRepoFile(String username, String repoName, String path, String sha, String branch) async {
    try {
      Map configMap = await getConfigMap();
      String token = configMap['token'];
      String host = 'https://api.github.com/repos/$username/$repoName/contents/$path';

      BaseOptions baseoptions = setBaseOptions();
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

      var response = await dio.delete(host, data: data);
      if (response.statusCode == 200) {
        return ['success'];
      } else {
        return ['failed'];
      }
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

      final githubConfig = GithubConfigModel(githubusername, repo, token, storePath, branch, customDomain);
      final githubConfigJson = jsonEncode(githubConfig);
      final githubConfigFile = await localFile;
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

  //新建文件夹
  static createFolder(Map element, String newPrefix) async {
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
      } else {
        return ['failed'];
      }
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

  //上传文件
  static uploadFile(Map element, String filename, String filePath, String newPrefix) async {
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
      } else {
        return ['failed'];
      }
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
