import 'package:dio/dio.dart';
import 'package:horopic/utils/common_func.dart';
import 'package:horopic/utils/global.dart';

class SmmsImageUploadUtils {
  //上传接口
  uploadApi(
      {required String path,
      required String name,
      required Map configMap}) async {
    String formatedURL = '';
    FormData formdata = FormData.fromMap({
      "smfile": await MultipartFile.fromFile(path, filename: name),
      "format": "json",
    });

    BaseOptions options = BaseOptions();
    options.headers = {
      "Authorization": configMap["token"],
      "Content-Type": "multipart/form-data",
    };
    Dio dio = Dio(options);
    String uploadUrl = "https://smms.app/api/v2/upload";
    //String uploadUrl = "https://sm.ms/api/v2/upload"; //主要接口,国内访问不了

    try {
      var response = await dio.post(uploadUrl, data: formdata);
      if (response.statusCode == 200 && response.data!['success'] == true) {
        String returnUrl = response.data!['data']['url'];
        if (Global.isCopyLink == true) {
          formatedURL =
              linkGenerateDict[Global.defaultLKformat]!(returnUrl, name);
        } else {
          formatedURL = returnUrl;
        }
        return ["success", formatedURL];
      } else {
        return ["failed"];
      }
    } catch (e) {
      return [e.toString()];
    }
  }
}
