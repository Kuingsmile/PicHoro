import 'package:dio/dio.dart';

class LskyproImageUploadUtils {
  //上传接口
  uploadApi(
      {required String path,
      required String name,
      required Map configMap}) async {
    FormData formdata = FormData.fromMap({
      "file": await MultipartFile.fromFile(path, filename: name),
      "strategy_id": configMap["strategy_id"],
    });
    BaseOptions options = BaseOptions();
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
        return "sucess";
      } else {
        return "failed";
      }
    } catch (e) {
      return e.toString();
    }
  }
}
