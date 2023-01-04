import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';

import 'package:horopic/picture_host_manage/manage_api/alist_manage_api.dart';
import 'package:horopic/picture_host_configure/configure_page/alist_configure.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/utils/global.dart';
import 'package:horopic/utils/sql_utils.dart';

class AlistImageUploadUtils {
  static String currentClassName = "AlistImageUploadUtils";
  //上传接口
  static uploadApi(
      {required String path,
      required String name,
      required Map configMap}) async {
    String formatedURL = '';
    FormData formdata = FormData.fromMap({
      "file": await MultipartFile.fromFile(path, filename: name),
    });
    String uploadPath = configMap['uploadPath'];
    String token = configMap['token'];
    String today = getToday('yyyyMMdd');
    String alistToday = await Global.getTodayAlistUpdate();
    if (alistToday != today && token != '') {
      var res = await AlistManageAPI.getToken(
          configMap['host'], configMap['alistusername'], configMap['password']);
      if (res[0] == 'success') {
        token = res[1];
        String sqlResult = '';
        try {
          List sqlconfig = [];
          sqlconfig.add(configMap['host']);
          sqlconfig.add(configMap['alistusername']);
          sqlconfig.add(configMap['password']);
          sqlconfig.add(token);
          sqlconfig.add(uploadPath);
          String defaultUser = await Global.getUser();
          sqlconfig.add(defaultUser);
          var queryalist = await MySqlUtils.queryAlist(username: defaultUser);
          var queryuser = await MySqlUtils.queryUser(username: defaultUser);
          if (queryuser == 'Empty') {
            return ['failed'];
          } else if (queryalist == 'Empty') {
            sqlResult = await MySqlUtils.insertAlist(content: sqlconfig);
          } else {
            sqlResult = await MySqlUtils.updateAlist(content: sqlconfig);
          }
        } catch (e) {
          return ['failed'];
        }
        if (sqlResult == "Success") {
          final alistConfig = AlistConfigModel(
            configMap['host'],
            configMap['alistusername'],
            configMap['password'],
            token,
            uploadPath,
          );
          final alistConfigJson = jsonEncode(alistConfig);
          final alistConfigFile = await AlistConfigState().localFile;
          alistConfigFile.writeAsString(alistConfigJson);
          await Global.setTodayAlistUpdate(today);
        } else {
          return ['failed'];
        }
      } else {
        return ['failed'];
      }
    }
    if (uploadPath == 'None') {
      uploadPath = '/';
    } else {
      if (!uploadPath.startsWith('/')) {
        uploadPath = '/$uploadPath';
      }
      if (!uploadPath.endsWith('/')) {
        uploadPath = '$uploadPath/';
      }
    }
    String filePath = uploadPath + name;

    BaseOptions options = setBaseOptions();
    File uploadFile = File(path);
    int contentLength = await uploadFile.length().then((value) {
      return value;
    });
    options.headers = {
      "Authorization": token,
      "Content-Type": Global.multipartString,
      "file-path": Uri.encodeComponent(filePath),
      "Content-Length": contentLength,
    };
    Dio dio = Dio(options);
    String uploadUrl = configMap["host"] + "/api/fs/form";

    try {
      var response = await dio.put(uploadUrl, data: formdata);
      if (response.statusCode == 200 &&
          response.data!['message'] == 'success') {
        String infoGetUrl = configMap["host"] + "/api/fs/get";
        String refreshUrl = configMap["host"] + "/api/fs/list";
        BaseOptions getOptions = setBaseOptions();
        getOptions.headers = {
          "Authorization": configMap["token"],
          "Content-Type": "application/json",
        };
        Dio dioGet = Dio(getOptions);
        Dio dioRefresh = Dio(getOptions);
        Map getformData = {
          "path": filePath,
        };
        Map refreshListFormData = {
          "password": "",
          "page": 1,
          "per_page": 1,
          "path": uploadPath,
          "refresh": true
        };
        var refreshResponse =
            await dioRefresh.post(refreshUrl, data: refreshListFormData);
        if (refreshResponse.statusCode == 200 &&
            refreshResponse.data!['message'] == 'success') {
          var responseGet = await dioGet.post(infoGetUrl, data: getformData);
          if (responseGet.statusCode == 200 &&
              responseGet.data['message'] == 'success') {
            String returnUrl = responseGet.data!['data']['raw_url'];
            //返回缩略图地址用来在相册显示
            String displayUrl = responseGet.data!['data']['thumb'] == "" ||
                    responseGet.data!['data']['thumb'] == null
                ? returnUrl
                : responseGet.data!['data']['thumb'];
            Map pictureKeyMap = Map.from(configMap);
            pictureKeyMap['sign'] = responseGet.data!['data']['sign'];
            pictureKeyMap['uploadPath'] = uploadPath;
            pictureKeyMap['filenames'] = name;
            String pictureKey = jsonEncode(pictureKeyMap);
            String hostPicUrl = responseGet.data!['data']['sign'] == "" ||
                    responseGet.data!['data']['sign'] == null
                ? returnUrl
                : configMap['host'] +
                    '/d' +
                    filePath +
                    '?sign=' +
                    responseGet.data!['data']['sign'];

            if (Global.isCopyLink == true) {
              formatedURL =
                  linkGenerateDict[Global.defaultLKformat]!(hostPicUrl, name);
            } else {
              formatedURL = hostPicUrl;
            }
            return [
              "success",
              formatedURL,
              returnUrl,
              pictureKey,
              displayUrl,
              hostPicUrl
            ];
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
          'path': path,
          'name': name,
        },
        currentClassName,
        "deleteApi",
      );
      return ['failed'];
    }
  }

  static deleteApi({required Map deleteMap, required Map configMap}) async {
    Map configMapFromPictureKey = jsonDecode(deleteMap['pictureKey']);
    Map<String, dynamic> formdata = {
      "dir": configMapFromPictureKey['uploadPath'],
      "names": [configMapFromPictureKey['filenames']]
    };
    String uploadPath = configMap['uploadPath'];
    String token = configMap['token'];
    String today = getToday('yyyyMMdd');
    String alistToday = await Global.getTodayAlistUpdate();
    if (alistToday != today && token != '') {
      var res = await AlistManageAPI.getToken(
          configMap['host'], configMap['alistusername'], configMap['password']);
      if (res[0] == 'success') {
        token = res[1];
        String sqlResult = '';
        try {
          List sqlconfig = [];
          sqlconfig.add(configMap['host']);
          sqlconfig.add(configMap['alistusername']);
          sqlconfig.add(configMap['password']);
          sqlconfig.add(token);
          sqlconfig.add(uploadPath);
          String defaultUser = await Global.getUser();
          sqlconfig.add(defaultUser);
          var queryalist = await MySqlUtils.queryAlist(username: defaultUser);
          var queryuser = await MySqlUtils.queryUser(username: defaultUser);
          if (queryuser == 'Empty') {
            return ['failed'];
          } else if (queryalist == 'Empty') {
            sqlResult = await MySqlUtils.insertAlist(content: sqlconfig);
          } else {
            sqlResult = await MySqlUtils.updateAlist(content: sqlconfig);
          }
        } catch (e) {
          return ['failed'];
        }
        if (sqlResult == "Success") {
          final alistConfig = AlistConfigModel(
            configMap['host'],
            configMap['alistusername'],
            configMap['password'],
            token,
            uploadPath,
          );
          final alistConfigJson = jsonEncode(alistConfig);
          final alistConfigFile = await AlistConfigState().localFile;
          alistConfigFile.writeAsString(alistConfigJson);
          await Global.setTodayAlistUpdate(today);
        } else {
          return ['failed'];
        }
      } else {
        return ['failed'];
      }
    }
    BaseOptions options = setBaseOptions();
    options.headers = {
      "Authorization": configMap["token"],
      "Content-Type": "application/json",
    };
    Dio dio = Dio(options);
    String deleteUrl = configMapFromPictureKey["host"] + "/api/fs/remove";
    try {
      var response = await dio.post(deleteUrl, data: formdata);
      if (response.statusCode == 200 &&
          response.data!['message'] == "success") {
        return [
          "success",
        ];
      } else {
        return ['failed'];
      }
    } catch (e) {
      flogErr(
        e,
        {},
        currentClassName,
        "deleteApi",
      );
      return ['failed'];
    }
  }
}
