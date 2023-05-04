import 'package:dio/dio.dart';
import 'package:f_logs/f_logs.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/utils/global.dart';

class SmmsImageUploadUtils {
  //上传接口
  static uploadApi({required String path, required String name, required Map configMap}) async {
    String formatedURL = '';
    FormData formdata = FormData.fromMap({
      "smfile": await MultipartFile.fromFile(path, filename: name),
      "format": "json",
    });

    BaseOptions options = setBaseOptions();
    options.headers = {
      "Authorization": configMap["token"],
      "Content-Type": "multipart/form-data",
    };
    Dio dio = Dio(options);
    String uploadUrl = "https://smms.app/api/v2/upload";

    try {
      var response = await dio.post(uploadUrl, data: formdata);
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
      if (e is DioError) {
        FLog.error(
            className: "SmmsImageUploadUtils",
            methodName: "uploadApi",
            text: formatErrorMessage({
              'path': path,
              'name': name,
            }, e.toString(), isDioError: true, dioErrorMessage: e),
            dataLogType: DataLogType.ERRORS.toString());
      } else {
        FLog.error(
            className: "SmmsImageUploadUtils",
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
    //String uploadUrl = "https://sm.ms/api/v2/delete/:hash"; //主要接口,国内访问不了

    try {
      var response = await dio.get(deleteUrl, queryParameters: formdata);
      if (response.statusCode == 200 && response.data!['success'] == true) {
        return ["success"];
      } else {
        return ["failed"];
      }
    } catch (e) {
      if (e is DioError) {
        FLog.error(
            className: "SmmsImageUploadUtils",
            methodName: "deleteApi",
            text: formatErrorMessage({}, e.toString(), isDioError: true, dioErrorMessage: e),
            dataLogType: DataLogType.ERRORS.toString());
      } else {
        FLog.error(
            className: "SmmsImageUploadUtils",
            methodName: "deleteApi",
            text: formatErrorMessage({}, e.toString()),
            dataLogType: DataLogType.ERRORS.toString());
      }
      return [e.toString()];
    }
  }
}
