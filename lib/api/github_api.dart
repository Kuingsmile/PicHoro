import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:horopic/utils/common_functions.dart';

class GithubImageUploadUtils {
  static Dio _getDio(Map configMap) {
    BaseOptions options = setBaseOptions();
    options.headers = {
      "Authorization": configMap["token"],
      "Accept": "application/vnd.github+json",
    };
    return Dio(options);
  }

  static String _getTrimmedPath(String path) => path.trim().replaceAll(RegExp(r'^/+|/+$'), '');

  static String _getUrl(String username, String repo, String path, String name) {
    String trimmedPath = _getTrimmedPath(path);
    return "https://api.github.com/repos/$username/$repo/contents/${trimmedPath == 'None' ? name : '$trimmedPath/$name'}";
  }

  //上传接口
  static Future<List<String>> uploadApi({
    required String path,
    required String name,
    required Map configMap,
    Function(int, int)? onSendProgress,
  }) async {
    try {
      String formatedURL = '';
      String base64Image = base64Encode(File(path).readAsBytesSync());

      Map<String, dynamic> queryBody = {
        'message': 'uploaded by PicHoro app',
        'content': base64Image,
        'branch': configMap["branch"], //分支
      };

      Dio dio = _getDio(configMap);
      String trimedPath = _getTrimmedPath(configMap['storePath'].toString());
      String uploadUrl =
          _getUrl(configMap["githubusername"], configMap["repo"], configMap['storePath'].toString(), name);
      var response =
          await dio.put<Map<String, dynamic>>(uploadUrl, data: jsonEncode(queryBody), onSendProgress: onSendProgress);
      if (response.statusCode != 200 && response.statusCode != 201) {
        return ["failed"];
      }

      Map pictureKeyMap = Map.from(configMap);
      String returnUrl = response.data!['content']['html_url'];
      pictureKeyMap['sha'] = response.data!['content']['sha'];
      String pictureKey = jsonEncode(pictureKeyMap);
      String downloadUrl = '';
      if (configMap['customDomain'] != 'None') {
        String customDomain = configMap['customDomain'].toString();
        if (customDomain.endsWith('/')) {
          customDomain = customDomain.substring(0, customDomain.length - 1);
        }
        downloadUrl = trimedPath == 'None' ? '$customDomain/$name' : '$customDomain/$trimedPath/$name';
      } else {
        downloadUrl = response.data!['content']['download_url'];
      }
      if (!downloadUrl.startsWith('http')) {
        downloadUrl = 'http://$downloadUrl';
      }
      //复制的链接地址应该是downloadUrl
      formatedURL = getFormatedUrl(downloadUrl, name);
      return ["success", formatedURL, returnUrl, pictureKey, downloadUrl];
    } catch (e) {
      flogError(
          e,
          {
            'path': path,
            'name': name,
          },
          "GithubImageUploadUtils",
          "uploadApi");
      return ["failed"];
    }
  }

  static Future<List<String>> deleteApi({required Map deleteMap, required Map configMap}) async {
    Map configMapFromPictureKey = jsonDecode(deleteMap['pictureKey']);
    Map<String, dynamic> formdata = {
      "message": "deleted by PicHoro app",
      "sha": configMapFromPictureKey['sha'],
      "branch": configMapFromPictureKey["branch"],
    };

    Dio dio = _getDio(configMapFromPictureKey);
    String deleteUrl = _getUrl(configMapFromPictureKey["githubusername"], configMapFromPictureKey["repo"],
        configMapFromPictureKey['storePath'].toString(), deleteMap["name"]);
    try {
      var response = await dio.delete(deleteUrl, data: jsonEncode(formdata));
      if (response.statusCode != 200) {
        return ["failed"];
      }
      return ["success"];
    } catch (e) {
      flogError(
          e,
          {
            'path': deleteMap['path'],
            'name': deleteMap['name'],
          },
          "GithubImageUploadUtils",
          "deleteApi");
      return ["failed"];
    }
  }
}
