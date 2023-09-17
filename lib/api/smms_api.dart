import 'package:dio/dio.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/utils/global.dart';
import 'package:path/path.dart' as my_path;

class SmmsImageUploadUtils {
  //上传接口
  static uploadApi({
    required String path,
    required String name,
    required Map configMap,
    Function(int, int)? onSendProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      String formatedURL = '';
      FormData formdata = FormData.fromMap({
        "smfile": await MultipartFile.fromFile(path, filename: my_path.basename(name)),
        "format": "json",
      });

      BaseOptions options = setBaseOptions();
      options.headers = {
        "Authorization": configMap["token"],
        "Content-Type": "multipart/form-data",
      };
      Dio dio = Dio(options);
      String uploadUrl = "https://smms.app/api/v2/upload";
      var response = await dio.post(
        uploadUrl,
        data: formdata,
        onSendProgress: onSendProgress,
        cancelToken: cancelToken,
      );
      if (response.statusCode == 200 && response.data!['success'] == true) {
        String returnUrl = response.data!['data']['url'];
        String pictureKey = response.data!['data']['hash'];
        if (Global.isCopyLink == true) {
          formatedURL = linkGenerateDict[Global.defaultLKformat]!(returnUrl, name);
        } else {
          formatedURL = returnUrl;
        }
        return ["success", formatedURL, returnUrl, pictureKey];
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
          "SmmsImageUploadUtils",
          "uploadApi");
      return ["failed"];
    }
  }

  static deleteApi({required Map deleteMap, required Map configMap}) async {
    Map<String, dynamic> formdata = {
      "hash": deleteMap["pictureKey"],
      "format": "json",
    };

    BaseOptions options = setBaseOptions();
    options.headers = {
      "Authorization": configMap["token"],
    };
    Dio dio = Dio(options);
    String deleteUrl = "https://smms.app/api/v2/delete/${deleteMap["pictureKey"]}";

    try {
      var response = await dio.get(deleteUrl, queryParameters: formdata);
      if (response.statusCode == 200 && response.data!['success'] == true) {
        return ["success"];
      }
      return ["failed"];
    } catch (e) {
      flogError(e, {}, "SmmsImageUploadUtils", "deleteApi");
      return ["failed"];
    }
  }
}
