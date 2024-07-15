import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:horopic/utils/common_functions.dart';
import 'package:path/path.dart' as my_path;

//兰空V2
class LskyproImageUploadUtils {
  //上传接口
  static uploadApi({
    required String path,
    required String name,
    required Map configMap,
    Function(int, int)? onSendProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      FormData formdata;
      String albumId = configMap['album_id'] ?? 'None';
      String strategyId = configMap['strategy_id'] ?? 'None';
      if (albumId == 'None' && strategyId == 'None') {
        formdata = FormData.fromMap({
          "file": await MultipartFile.fromFile(path, filename: my_path.basename(name)),
        });
      } else {
        if (strategyId == 'None') {
          formdata = FormData.fromMap({
            "file": await MultipartFile.fromFile(path, filename: my_path.basename(name)),
            "album_id": albumId,
          });
        } else {
          if (albumId == 'None') {
            formdata = FormData.fromMap({
              "file": await MultipartFile.fromFile(path, filename: my_path.basename(name)),
              "strategy_id": strategyId,
            });
          } else {
            formdata = FormData.fromMap({
              "file": await MultipartFile.fromFile(path, filename: my_path.basename(name)),
              "strategy_id": configMap["strategy_id"],
              "album_id": configMap["album_id"],
            });
          }
        }
      }
      BaseOptions options = setBaseOptions();
      options.headers = {
        "Authorization": configMap["token"],
        "Accept": "application/json",
        "Content-Type": "multipart/form-data",
      };
      Dio dio = Dio(options);
      String uploadUrl = configMap["host"] + "/api/v1/upload";

      var response = await dio.post(uploadUrl, data: formdata);
      if (response.statusCode == 200 && response.data!['status'] == true) {
        String returnUrl = response.data!['data']['links']['url'];
        //返回缩略图地址用来在相册显示
        String displayUrl = response.data!['data']['links']['thumbnail_url'];
        Map pictureKeyMap = Map.from(configMap);
        pictureKeyMap['deletekey'] = response.data!['data']['key'];
        String pictureKey = jsonEncode(pictureKeyMap);
        String formatedURL = getFormatedUrl(returnUrl, name);

        return ["success", formatedURL, returnUrl, pictureKey, displayUrl];
      } else {
        return ["failed"];
      }
    } catch (e) {
      flogError(
          e,
          {
            'path': path,
            'name': name,
          },
          "LskyproImageUploadUtils",
          "uploadApi");
      return ["failed"];
    }
  }

  static deleteApi({required Map deleteMap, required Map configMap}) async {
    Map configMapFromPictureKey = jsonDecode(deleteMap['pictureKey']);
    Map<String, dynamic> formdata = {
      "key": configMapFromPictureKey["deletekey"],
    };
    BaseOptions options = setBaseOptions();
    options.headers = {
      "Authorization": configMapFromPictureKey["token"],
      "Accept": "application/json",
    };
    Dio dio = Dio(options);
    String deleteUrl = configMapFromPictureKey["host"] + "/api/v1/images/${configMapFromPictureKey["deletekey"]}";
    try {
      var response = await dio.delete(deleteUrl, data: formdata);
      if (response.statusCode == 200 && response.data!['status'] == true) {
        return ["success"];
      }
      return ["failed"];
    } catch (e) {
      flogError(e, {}, "LskyproImageUploadUtils", "deleteApi");
      return ["failed"];
    }
  }
}
