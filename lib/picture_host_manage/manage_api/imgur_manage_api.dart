import 'dart:io';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:f_logs/f_logs.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio_proxy_adapter/dio_proxy_adapter.dart';

import 'package:horopic/utils/global.dart';
import 'package:horopic/utils/common_functions.dart';

class ImgurManageAPI {
  static Future<File> get _localFile async {
    final path = await _localPath;
    String defaultUser = await Global.getUser();
    return File('$path/${defaultUser}_imgur_config.txt');
  }

  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<String> readImgurConfig() async {
    try {
      final file = await _localFile;
      String contents = await file.readAsString();
      return contents;
    } catch (e) {
      FLog.error(
          className: 'ImgurManageAPI',
          methodName: 'readImgurConfig',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      return "Error";
    }
  }

  static Future<Map> getConfigMap() async {
    String configStr = await readImgurConfig();
    Map configMap = json.decode(configStr);
    return configMap;
  }

  static isString(var variable) {
    return variable is String;
  }

  static isFile(var variable) {
    return variable is File;
  }

  static checkToken(String username, String accesstoken, String proxy) async {
    BaseOptions options = BaseOptions(
      connectTimeout: 30000,
      receiveTimeout: 30000,
      sendTimeout: 30000,
    );
    options.headers = {
      "Authorization": "Bearer $accesstoken",
    };
    Dio dio = Dio(options);
    String proxyClean = '';
    //判断是否有代理
    if (proxy != 'None') {
      if (proxy.startsWith('http://') || proxy.startsWith('https://')) {
        proxyClean = proxy.split('://')[1];
      } else {
        proxyClean = proxy;
      }
      dio.useProxy(proxyClean);
    }
    String accountUrl = "https://api.imgur.com/3/account/me/settings";
    try {
      var response = await dio.get(
        accountUrl,
      );
      if (response.statusCode == 200 && response.data!['success'] == true) {
        return ["success"];
      } else {
        return ["failed"];
      }
    } catch (e) {
      if (e is DioError) {
        FLog.error(
            className: "ImgurManageAPI",
            methodName: "checkToken",
            text: formatErrorMessage({}, e.toString(),
                isDioError: true, dioErrorMessage: e),
            dataLogType: DataLogType.ERRORS.toString());
      } else {
        FLog.error(
            className: "ImgurManageAPI",
            methodName: "checkToken",
            text: formatErrorMessage({}, e.toString()),
            dataLogType: DataLogType.ERRORS.toString());
      }
      return [e.toString()];
    }
  }

  //get album list
  static getAlbumList(String username, String accesstoken, String proxy) async {
    BaseOptions options = BaseOptions(
      connectTimeout: 30000,
      receiveTimeout: 30000,
      sendTimeout: 30000,
    );
    
    options.headers = {
      "Authorization": "Bearer $accesstoken",
    };
    Dio dio = Dio(options);
    String proxyClean = '';
    //判断是否有代理
    if (proxy != 'None') {
      if (proxy.startsWith('http://') || proxy.startsWith('https://')) {
        proxyClean = proxy.split('://')[1];
      } else {
        proxyClean = proxy;
      }
      dio.useProxy(proxyClean);
    }
    int page = 0;
    List albumList = [];
    String accountUrl =
        "https://api.imgur.com/3/account/$username/albums/ids/$page";
    while (true) {
      try {
        var response = await dio.get(
          accountUrl,
        );
        if (response.statusCode == 200 && response.data!['success'] == true) {
          if (response.data!['data'].length == 0) {
            break;
          } else {
            albumList.addAll(response.data!['data']);
            page++;
            accountUrl =
                "https://api.imgur.com/3/account/$username/albums/ids/$page";
          }
        } else {
          return ["failed"];
        }
      } catch (e) {
        if (e is DioError) {
          FLog.error(
              className: "ImgurManageAPI",
              methodName: "getAlbumList",
              text: formatErrorMessage({}, e.toString(),
                  isDioError: true, dioErrorMessage: e),
              dataLogType: DataLogType.ERRORS.toString());
        } else {
          FLog.error(
              className: "ImgurManageAPI",
              methodName: "getAlbumList",
              text: formatErrorMessage({}, e.toString()),
              dataLogType: DataLogType.ERRORS.toString());
        }
        return [e.toString()];
      }
    }
    return ['success', albumList];
  }

  //get album info
  static getAlbumInfo(String clienID, String albumhash, String proxy) async {
    BaseOptions options = BaseOptions(
      connectTimeout: 30000,
      receiveTimeout: 30000,
      sendTimeout: 30000,
    );
    options.headers = {
      "Authorization": "Client-ID $clienID",
    };
    Dio dio = Dio(options);
    String proxyClean = '';
    //判断是否有代理
    if (proxy != 'None') {
      if (proxy.startsWith('http://') || proxy.startsWith('https://')) {
        proxyClean = proxy.split('://')[1];
      } else {
        proxyClean = proxy;
      }
      dio.useProxy(proxyClean);
    }
    String accountUrl = "https://api.imgur.com/3/album/$albumhash";
    try {
      var response = await dio.get(
        accountUrl,
      );
      if (response.statusCode == 200 && response.data!['success'] == true) {
        return ["success", response.data!['data']];
      } else {
        return ["failed"];
      }
    } catch (e) {
      if (e is DioError) {
        FLog.error(
            className: "ImgurManageAPI",
            methodName: "getAlbumInfo",
            text: formatErrorMessage({}, e.toString(),
                isDioError: true, dioErrorMessage: e),
            dataLogType: DataLogType.ERRORS.toString());
      } else {
        FLog.error(
            className: "ImgurManageAPI",
            methodName: "getAlbumInfo",
            text: formatErrorMessage({}, e.toString()),
            dataLogType: DataLogType.ERRORS.toString());
      }
      return [e.toString()];
    }
  }

  //get all images
  static getImagesList(
      String username, String accesstoken, String proxy) async {
    BaseOptions options = BaseOptions(
      connectTimeout: 30000,
      receiveTimeout: 30000,
      sendTimeout: 30000,
    );
    options.headers = {
      "Authorization": "Bearer $accesstoken",
    };
    Dio dio = Dio(options);
    String proxyClean = '';
    //判断是否有代理
    if (proxy != 'None') {
      if (proxy.startsWith('http://') || proxy.startsWith('https://')) {
        proxyClean = proxy.split('://')[1];
      } else {
        proxyClean = proxy;
      }
      dio.useProxy(proxyClean);
    }
    int page = 0;
    List imageList = [];
    String accountUrl =
        "https://api.imgur.com/3/account/$username/images/$page";
    while (true) {
      try {
        var response = await dio.get(
          accountUrl,
        );
        if (response.statusCode == 200 && response.data!['success'] == true) {
          if (response.data!['data'].length == 0) {
            break;
          } else {
            imageList.addAll(response.data!['data']);
            page++;
            accountUrl =
                "https://api.imgur.com/3/account/$username/images/$page";
          }
        } else {
          return ["failed"];
        }
      } catch (e) {
        if (e is DioError) {
          FLog.error(
              className: "ImgurManageAPI",
              methodName: "getImagesList",
              text: formatErrorMessage({}, e.toString(),
                  isDioError: true, dioErrorMessage: e),
              dataLogType: DataLogType.ERRORS.toString());
        } else {
          FLog.error(
              className: "ImgurManageAPI",
              methodName: "getImagesList",
              text: formatErrorMessage({}, e.toString()),
              dataLogType: DataLogType.ERRORS.toString());
        }
        return [e.toString()];
      }
    }
    return ['success', imageList];
  }

  //is no image
  static isEmptyAccount(
      String username, String accesstoken, String proxy) async {
    var queryResult = await getImagesList(username, accesstoken, proxy);
    if (queryResult[0] == 'success') {
      if (queryResult[1].length == 0) {
        return ['empty'];
      } else {
        return ['notempty'];
      }
    } else {
      return ['error'];
    }
  }

  //get images of album
  static getAlbumImages(String clientID, String albumHash, String proxy) async {
    BaseOptions options = BaseOptions(
      connectTimeout: 30000,
      receiveTimeout: 30000,
      sendTimeout: 30000,
    );
    options.headers = {
      "Authorization": "Client-ID $clientID",
    };
    Dio dio = Dio(options);
    String proxyClean = '';
    //判断是否有代理
    if (proxy != 'None') {
      if (proxy.startsWith('http://') || proxy.startsWith('https://')) {
        proxyClean = proxy.split('://')[1];
      } else {
        proxyClean = proxy;
      }
      dio.useProxy(proxyClean);
    }
    String accountUrl = "https://api.imgur.com/3/album/$albumHash/images";
    try {
      var response = await dio.get(
        accountUrl,
      );
      if (response.statusCode == 200 && response.data!['success'] == true) {
        return ["success", response.data['data']];
      } else {
        return ["failed"];
      }
    } catch (e) {
      if (e is DioError) {
        FLog.error(
            className: "ImgurManageAPI",
            methodName: "getAlbumImages",
            text: formatErrorMessage({}, e.toString(),
                isDioError: true, dioErrorMessage: e),
            dataLogType: DataLogType.ERRORS.toString());
      } else {
        FLog.error(
            className: "ImgurManageAPI",
            methodName: "getAlbumImages",
            text: formatErrorMessage({}, e.toString()),
            dataLogType: DataLogType.ERRORS.toString());
      }
      return [e.toString()];
    }
  }

  //get not in album images
  static getNotInAlbumImages(String username, String accesstoken,
      String clientID, String proxy) async {
    var getImagesListResult = await getImagesList(username, accesstoken, proxy);
    if (getImagesListResult[0] == 'success') {
      List allImages = getImagesListResult[1];
      if (allImages.isEmpty) {
        return ['success', [], []];
      } else {
        var getAlbumListResult =
            await getAlbumList(username, accesstoken, proxy);
        if (getAlbumListResult[0] == 'success') {
          List allAlbums = getAlbumListResult[1];
          if (allAlbums.isEmpty) {
            return ['success', allImages, allImages];
          } else {
            List imagesInAlbum = [];
            for (var album in allAlbums) {
              var getAlbumImagesResult =
                  await getAlbumImages(clientID, album, proxy);
              if (getAlbumImagesResult[0] == 'success') {
                imagesInAlbum.addAll(getAlbumImagesResult[1]);
              } else {
                return ['failed'];
              }
            }
            List notInAlbumImages = [];
            List allImagesInAlbumID = [];
            for (var image in imagesInAlbum) {
              allImagesInAlbumID.add(image['id']);
            }
            for (int i = 0; i < allImages.length; i++) {
              if (!allImagesInAlbumID.contains(allImages[i]['id'])) {
                notInAlbumImages.add(allImages[i]);
              }
            }
            return ['success', notInAlbumImages, allImages];
          }
        } else {
          return ['failed'];
        }
      }
    } else {
      return ['failed'];
    }
  }

  //create album
  static createAlbum(String accesstoken, String title, String proxy) async {
    BaseOptions options = BaseOptions(
      connectTimeout: 30000,
      receiveTimeout: 30000,
      sendTimeout: 30000,
    );
    options.headers = {
      "Authorization": "Bearer $accesstoken",
      "Content-Type": "application/json",
    };
    Map data = {
      "title": title,
      "description": "Created by PicHoro",
    };
    Dio dio = Dio(options);
    String proxyClean = '';
    //判断是否有代理
    if (proxy != 'None') {
      if (proxy.startsWith('http://') || proxy.startsWith('https://')) {
        proxyClean = proxy.split('://')[1];
      } else {
        proxyClean = proxy;
      }
      dio.useProxy(proxyClean);
    }
    String accountUrl = "https://api.imgur.com/3/album";
    try {
      var response = await dio.post(
        accountUrl,
        data: jsonEncode(data),
      );
      if (response.statusCode == 200 && response.data!['success'] == true) {
        return ["success", response.data['data']];
      } else {
        return ["failed"];
      }
    } catch (e) {
      if (e is DioError) {
        FLog.error(
            className: "ImgurManageAPI",
            methodName: "createAlbum",
            text: formatErrorMessage({}, e.toString(),
                isDioError: true, dioErrorMessage: e),
            dataLogType: DataLogType.ERRORS.toString());
      } else {
        FLog.error(
            className: "ImgurManageAPI",
            methodName: "createAlbum",
            text: formatErrorMessage({}, e.toString()),
            dataLogType: DataLogType.ERRORS.toString());
      }
      return [e.toString()];
    }
  }

  //delete album
  static deleteAlbum(String accesstoken, String albumHash, String proxy) async {
    BaseOptions options = BaseOptions(
      connectTimeout: 30000,
      receiveTimeout: 30000,
      sendTimeout: 30000,
    );
    options.headers = {
      "Authorization": "Bearer $accesstoken",
    };
    Dio dio = Dio(options);
    String proxyClean = '';
    //判断是否有代理
    if (proxy != 'None') {
      if (proxy.startsWith('http://') || proxy.startsWith('https://')) {
        proxyClean = proxy.split('://')[1];
      } else {
        proxyClean = proxy;
      }
      dio.useProxy(proxyClean);
    }
    String accountUrl = "https://api.imgur.com/3/album/$albumHash";
    try {
      var response = await dio.delete(
        accountUrl,
      );
      if (response.statusCode == 200 && response.data!['success'] == true) {
        return [
          "success",
        ];
      } else {
        return ["failed"];
      }
    } catch (e) {
      if (e is DioError) {
        FLog.error(
            className: "ImgurManageAPI",
            methodName: "deleteAlbum",
            text: formatErrorMessage({}, e.toString(),
                isDioError: true, dioErrorMessage: e),
            dataLogType: DataLogType.ERRORS.toString());
      } else {
        FLog.error(
            className: "ImgurManageAPI",
            methodName: "deleteAlbum",
            text: formatErrorMessage({}, e.toString()),
            dataLogType: DataLogType.ERRORS.toString());
      }
      return [e.toString()];
    }
  }

  //delete image
  static deleteImage(String accesstoken, String imageHash, String proxy) async {
    BaseOptions options = BaseOptions(
      connectTimeout: 30000,
      receiveTimeout: 30000,
      sendTimeout: 30000,
    );
    options.headers = {
      "Authorization": "Bearer $accesstoken",
    };
    Dio dio = Dio(options);
    String proxyClean = '';
    //判断是否有代理
    if (proxy != 'None') {
      if (proxy.startsWith('http://') || proxy.startsWith('https://')) {
        proxyClean = proxy.split('://')[1];
      } else {
        proxyClean = proxy;
      }
      dio.useProxy(proxyClean);
    }
    String accountUrl = "https://api.imgur.com/3/image/$imageHash";
    try {
      var response = await dio.delete(
        accountUrl,
      );
      if (response.statusCode == 200 && response.data!['success'] == true) {
        return [
          "success",
        ];
      } else {
        return ["failed"];
      }
    } catch (e) {
      if (e is DioError) {
        FLog.error(
            className: "ImgurManageAPI",
            methodName: "deleteImage",
            text: formatErrorMessage({}, e.toString(),
                isDioError: true, dioErrorMessage: e),
            dataLogType: DataLogType.ERRORS.toString());
      } else {
        FLog.error(
            className: "ImgurManageAPI",
            methodName: "deleteImage",
            text: formatErrorMessage({}, e.toString()),
            dataLogType: DataLogType.ERRORS.toString());
      }
      return [e.toString()];
    }
  }

  //add image to album
  static uploadFile(String accesstoken, String albumHash, String filename,
      String filepath, String proxy) async {
    FormData formdata;
    if (albumHash == 'None') {
      formdata = FormData.fromMap({
        "image": await MultipartFile.fromFile(filepath, filename: filename),
        "type": "file",
        "name": filename,
        "description": "Uploaded by PicHoro",
      });
    } else {
      formdata = FormData.fromMap({
        "image": await MultipartFile.fromFile(filepath, filename: filename),
        "type": "file",
        "album": albumHash,
        "name": filename,
        "description": "Uploaded by PicHoro",
      });
    }

    BaseOptions options = BaseOptions(
      connectTimeout: 30000,
      receiveTimeout: 30000,
      sendTimeout: 30000,
    );
    options.headers = {
      "Authorization": "Bearer $accesstoken",
    };
    Dio dio = Dio(options);
    String proxyClean = '';
    //判断是否有代理
    if (proxy != 'None') {
      if (proxy.startsWith('http://') || proxy.startsWith('https://')) {
        proxyClean = proxy.split('://')[1];
      } else {
        proxyClean = proxy;
      }
      dio.useProxy(proxyClean);
    }
    String accountUrl = "https://api.imgur.com/3/image";
    try {
      var response = await dio.post(
        accountUrl,
        data: formdata,
      );
      if (response.statusCode == 200 && response.data!['success'] == true) {
        return [
          "success",
        ];
      } else {
        return ["failed"];
      }
    } catch (e) {
      if (e is DioError) {
        FLog.error(
            className: "ImgurManageAPI",
            methodName: "uploadFile",
            text: formatErrorMessage({}, e.toString(),
                isDioError: true, dioErrorMessage: e),
            dataLogType: DataLogType.ERRORS.toString());
      } else {
        FLog.error(
            className: "ImgurManageAPI",
            methodName: "uploadFile",
            text: formatErrorMessage({}, e.toString()),
            dataLogType: DataLogType.ERRORS.toString());
      }
      return [e.toString()];
    }
  }

  static uploadNetworkFile(String fileLink, String accesstoken,
      String albumHash, String proxy) async {
    try {
      String filename =
          fileLink.substring(fileLink.lastIndexOf("/") + 1, fileLink.length);
      filename = filename.substring(
          0, !filename.contains("?") ? filename.length : filename.indexOf("?"));
      String savePath = await getTemporaryDirectory().then((value) {
        return value.path;
      });
      String saveFilePath = '$savePath/$filename';
      Dio dio = Dio();
      Response response = await dio.download(fileLink, saveFilePath);
      if (response.statusCode == 200) {
        var uploadResult = await uploadFile(
            accesstoken, albumHash, filename, saveFilePath, proxy);
        if (uploadResult[0] == "success") {
          return ['success'];
        } else {
          return ['failed'];
        }
      } else {
        return ['failed'];
      }
    } catch (e) {
      if (e is DioError) {
        FLog.error(
            className: "ImgurManageAPI",
            methodName: "uploadNetworkFile",
            text: formatErrorMessage({'fileLink': fileLink}, e.toString(),
                isDioError: true, dioErrorMessage: e),
            dataLogType: DataLogType.ERRORS.toString());
      } else {
        FLog.error(
            className: "ImgurManageAPI",
            methodName: "uploadNetworkFile",
            text: formatErrorMessage({'fileLink': fileLink}, e.toString()),
            dataLogType: DataLogType.ERRORS.toString());
      }
      return ['failed'];
    }
  }

  static uploadNetworkFileEntry(
      List fileList, String accesstoken, String albumHash, String proxy) async {
    int successCount = 0;
    int failCount = 0;
    for (String fileLink in fileList) {
      if (fileLink.isEmpty) {
        continue;
      }
      var uploadResult =
          await uploadNetworkFile(fileLink, accesstoken, albumHash, proxy);
      if (uploadResult[0] == "success") {
        successCount++;
      } else {
        failCount++;
      }
    }

    if (successCount == 0) {
      return Fluttertoast.showToast(
          msg: '上传失败',
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 2,
          fontSize: 16.0);
    } else if (failCount == 0) {
      return Fluttertoast.showToast(
          msg: '上传成功',
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 2,
          fontSize: 16.0);
    } else {
      return Fluttertoast.showToast(
          msg: '成功$successCount,失败$failCount',
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 2,
          fontSize: 16.0);
    }
  }
}
