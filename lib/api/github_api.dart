import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:f_logs/f_logs.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/utils/global.dart';

class GithubImageUploadUtils {
  //上传接口
  static uploadApi(
      {required String path,
      required String name,
      required Map configMap}) async {
    String formatedURL = '';
    String base64Image = base64Encode(File(path).readAsBytesSync());

    Map<String, dynamic> queryBody = {
      'message': 'uploaded by PicHoro app',
      'content': base64Image,
      'branch': configMap["branch"], //分支
    };

    BaseOptions options = setBaseOptions();

    options.headers = {
      "Authorization": configMap["token"],
      "Accept": "application/vnd.github+json",
    };
    String trimedPath = configMap['storePath'].toString().trim();
    trimedPath = trimedPath
        .replaceAll(RegExp(r'^/+'), '')
        .replaceAll(RegExp(r'/+$'), '');
    Dio dio = Dio(options);
    String uploadUrl = '';
    if (trimedPath == 'None') {
      uploadUrl =
          "https://api.github.com/repos/${configMap["githubusername"]}/${configMap["repo"]}/contents/$name";
    } else {
      uploadUrl =
          "https://api.github.com/repos/${configMap["githubusername"]}/${configMap["repo"]}/contents/$trimedPath/$name";
    }
    try {
      var response = await dio.put(uploadUrl, data: jsonEncode(queryBody));
      if (response.statusCode == 200 || response.statusCode == 201) {
        String returnUrl = response.data!['content']['html_url'];
        Map pictureKeyMap = Map.from(configMap);
        pictureKeyMap['sha'] = response.data!['content']['sha'];
        String pictureKey = jsonEncode(pictureKeyMap);
        String downloadUrl = '';
        if (configMap['customDomain'] != 'None') {
          if (configMap['customDomain'].toString().endsWith('/')) {
            String trimedCustomDomain = configMap['customDomain']
                .toString()
                .substring(0, configMap['customDomain'].toString().length - 1);
            if (trimedPath == 'None') {
              downloadUrl = '$trimedCustomDomain$name';
            } else {
              downloadUrl = '$trimedCustomDomain$trimedPath/$name';
            }
          } else {
            if (trimedPath == 'None') {
              downloadUrl = '${configMap['customDomain']}/$name';
            } else {
              downloadUrl = '${configMap['customDomain']}/$trimedPath/$name';
            }
          }
        } else {
          downloadUrl = response.data!['content']['download_url'];
        }
        if (!downloadUrl.startsWith('http') &&
            !downloadUrl.startsWith('https')) {
          downloadUrl = 'http://$downloadUrl';
        }
        //复制的链接地址应该是downloadUrl
        if (Global.isCopyLink == true) {
          formatedURL =
              linkGenerateDict[Global.defaultLKformat]!(downloadUrl, name);
        } else {
          formatedURL = downloadUrl;
        }
        return ["success", formatedURL, returnUrl, pictureKey, downloadUrl];
      } else {
        return ["failed"];
      }
    } catch (e) {
      if (e is DioError) {
        FLog.error(
            className: "GithubImageUploadUtils",
            methodName: "uploadApi",
            text: formatErrorMessage({
              'path': path,
              'name': name,
            }, e.toString(), isDioError: true, dioErrorMessage: e),
            dataLogType: DataLogType.ERRORS.toString());
      } else {
        FLog.error(
            className: "GithubImageUploadUtils",
            methodName: "uploadApi",
            text: formatErrorMessage({
              'path': path,
              'name': name,
            }, e.toString()),
            dataLogType: DataLogType.ERRORS.toString());
      }
      return [e.toString()];
    }
  }

  static deleteApi({required Map deleteMap, required Map configMap}) async {
    Map configMapFromPictureKey = jsonDecode(deleteMap['pictureKey']);
    Map<String, dynamic> formdata = {
      "message": "deleted by PicHoro app",
      "sha": configMapFromPictureKey['sha'],
      "branch": configMapFromPictureKey["branch"],
    };
    BaseOptions options = setBaseOptions();
    options.headers = {
      "Authorization": configMapFromPictureKey["token"],
      "Accept": "application/vnd.github+json",
    };

    Dio dio = Dio(options);
    String trimedPath = configMapFromPictureKey['storePath'].toString().trim();

    trimedPath = trimedPath
        .replaceAll(RegExp(r'^/+'), '')
        .replaceAll(RegExp(r'/+$'), '');

    String deleteUrl = '';
    if (trimedPath == 'None') {
      deleteUrl =
          "https://api.github.com/repos/${configMapFromPictureKey["githubusername"]}/${configMapFromPictureKey["repo"]}/contents/${deleteMap["name"]}";
    } else {
      deleteUrl =
          "https://api.github.com/repos/${configMapFromPictureKey["githubusername"]}/${configMapFromPictureKey["repo"]}/contents/$trimedPath/${deleteMap["name"]}";
    }
    try {
      var response = await dio.delete(deleteUrl, data: jsonEncode(formdata));
      if (response.statusCode == 200) {
        return [
          "success",
        ];
      } else {
        return ["failed"];
      }
    } catch (e) {
      if (e is DioError) {
        FLog.error(
            className: "GithubImageUploadUtils",
            methodName: "deleteApi",
            text: formatErrorMessage({}, e.toString(),
                isDioError: true, dioErrorMessage: e),
            dataLogType: DataLogType.ERRORS.toString());
      } else {
        FLog.error(
            className: "GithubImageUploadUtils",
            methodName: "deleteApi",
            text: formatErrorMessage({}, e.toString()),
            dataLogType: DataLogType.ERRORS.toString());
      }
      return [e.toString()];
    }
  }
}
