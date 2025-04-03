import 'package:dio/dio.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:path/path.dart' as my_path;

class SmmsImageUploadUtils {
  static const _baseUrl = "https://smms.app/api/v2";
  static const _uploadEndpoint = "/upload";
  static const _deleteEndpoint = "/delete";

  static Dio _getDio(Map configMap) {
    return Dio(setBaseOptions()
      ..headers = {
        "Authorization": configMap["token"],
        "Content-Type": "multipart/form-data",
      });
  }

  static Future<List<String>> uploadApi({
    required String path,
    required String name,
    required Map configMap,
    Function(int, int)? onSendProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      FormData formdata = FormData.fromMap({
        "smfile": await MultipartFile.fromFile(path, filename: my_path.basename(name)),
        "format": "json",
      });

      Dio dio = _getDio(configMap);
      var response = await dio.post<Map>(
        "$_baseUrl$_uploadEndpoint",
        data: formdata,
        onSendProgress: onSendProgress,
        cancelToken: cancelToken,
      );
      if (response.statusCode == 200 && response.data?['success'] == true) {
        var {'url': returnUrl as String, 'hash': pictureKey as String} = response.data?['data'];
        String formatedURL = getFormatedUrl(returnUrl, name);
        return ["success", formatedURL, returnUrl, pictureKey];
      } else if (response.data?['code'] == 'image_repeated' && response.data?['images'] is String) {
        String returnUrl = response.data?['images'];
        var uploadHistory = await dio.get(
          '$_baseUrl/upload_history',
        );
        if (uploadHistory.statusCode == 200 && uploadHistory.data['success'] == true) {
          var pictureKey = uploadHistory.data['data'].firstWhere(
            (item) => item['url'] == returnUrl,
            orElse: () => null,
          )?['hash'];
          if (pictureKey != null) {
            String formatedURL = getFormatedUrl(returnUrl, name);
            return ["success", formatedURL, returnUrl, pictureKey];
          }
        }
      }
      return ["failed"];
    } catch (e) {
      flogErr(
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

  static Future<List<String>> deleteApi({required Map deleteMap, required Map configMap}) async {
    try {
      Map<String, String> formdata = {
        "hash": deleteMap["pictureKey"],
        "format": "json",
      };

      BaseOptions options = setBaseOptions();
      options.headers = {
        "Authorization": configMap["token"],
      };
      Dio dio = Dio(options);
      String deleteUrl = '$_baseUrl$_deleteEndpoint/${deleteMap["pictureKey"]}';

      var response = await dio.get(deleteUrl, queryParameters: formdata);
      if (response.statusCode == 200) {
        return ["success"];
      }
      flogErr(
          response,
          {
            'deleteMap': deleteMap,
            'configMap': configMap,
          },
          "SmmsImageUploadUtils",
          "deleteApi");
      return ["failed"];
    } catch (e) {
      flogErr(
          e,
          {
            'deleteMap': deleteMap,
            'configMap': configMap,
          },
          "SmmsImageUploadUtils",
          "deleteApi");
      return ["failed"];
    }
  }
}
