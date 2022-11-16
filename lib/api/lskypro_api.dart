import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:f_logs/f_logs.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/utils/global.dart';

//兰空V2
class LskyproImageUploadUtils {
  //上传接口
  static uploadApi(
      {required String path,
      required String name,
      required Map configMap}) async {
    String formatedURL = '';
    FormData formdata = FormData.fromMap({
      "file": await MultipartFile.fromFile(path, filename: name),
    });
    String albumId = configMap['album_id'];
    if (configMap["strategy_id"] == "None") {
      formdata = FormData.fromMap({});
    } else if (albumId == 'None') {
      formdata = FormData.fromMap({
        "file": await MultipartFile.fromFile(path, filename: name),
        "strategy_id": configMap["strategy_id"],
      });
    } else {
      formdata = FormData.fromMap({
        "file": await MultipartFile.fromFile(path, filename: name),
        "strategy_id": configMap["strategy_id"],
        "album_id": albumId,
      });
    }

    BaseOptions options = BaseOptions(
      connectTimeout: 30000,
      receiveTimeout: 30000,
      sendTimeout: 30000,
    );
    options.headers = {
      "Authorization": configMap["token"],
      "Accept": "application/json",
      "Content-Type": "multipart/form-data",
    };
    Dio dio = Dio(options);
    String uploadUrl = configMap["host"] + "/api/v1/upload";

    try {
      var response = await dio.post(uploadUrl, data: formdata);
      if (response.statusCode == 200 && response.data!['status'] == true) {
        String returnUrl = response.data!['data']['links']['url'];
        //返回缩略图地址用来在相册显示
        String displayUrl = response.data!['data']['links']['thumbnail_url'];
        Map pictureKeyMap = Map.from(configMap);
        pictureKeyMap['deletekey'] = response.data!['data']['key'];
        String pictureKey = jsonEncode(pictureKeyMap);

        if (Global.isCopyLink == true) {
          formatedURL =
              linkGenerateDict[Global.defaultLKformat]!(returnUrl, name);
        } else {
          formatedURL = returnUrl;
        }
        return ["success", formatedURL, returnUrl, pictureKey, displayUrl];
      } else {
        return ["failed"];
      }
    } catch (e) {
      if (e is DioError) {
        FLog.error(
            className: "LskyproImageUploadUtils",
            methodName: "uploadApi",
            text: formatErrorMessage({
              'path': path,
              'name': name,
            }, e.toString(), isDioError: true, dioErrorMessage: e),
            dataLogType: DataLogType.ERRORS.toString());
      } else {
        FLog.error(
            className: "LskyproImageUploadUtils",
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
      "key": configMapFromPictureKey["deletekey"],
    };
    BaseOptions options = BaseOptions(
      connectTimeout: 30000,
      receiveTimeout: 30000,
      sendTimeout: 30000,
    );
    options.headers = {
      "Authorization": configMapFromPictureKey["token"],
      "Accept": "application/json",
    };
    Dio dio = Dio(options);
    String deleteUrl = configMapFromPictureKey["host"] +
        "/api/v1/images/${configMapFromPictureKey["deletekey"]}";
    try {
      var response = await dio.delete(deleteUrl, data: formdata);
      if (response.statusCode == 200 && response.data!['status'] == true) {
        return [
          "success",
        ];
      } else {
        return ["failed"];
      }
    } catch (e) {
      if (e is DioError) {
        FLog.error(
            className: "LskyproImageUploadUtils",
            methodName: "deleteApi",
            text: formatErrorMessage({}, e.toString(),
                isDioError: true, dioErrorMessage: e),
            dataLogType: DataLogType.ERRORS.toString());
      } else {
        FLog.error(
            className: "LskyproImageUploadUtils",
            methodName: "deleteApi",
            text: formatErrorMessage({}, e.toString()),
            dataLogType: DataLogType.ERRORS.toString());
      }
      return [e.toString()];
    }
  }
}
