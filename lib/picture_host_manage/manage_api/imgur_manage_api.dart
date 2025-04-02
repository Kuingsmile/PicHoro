import 'dart:io';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:horopic/picture_host_manage/common/base_manage_api.dart';
import 'package:path_provider/path_provider.dart';

import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/utils/dio_proxy_adapter.dart';

class ImgurManageAPI extends BaseManageApi {
  static final ImgurManageAPI _instance = ImgurManageAPI._internal();
  factory ImgurManageAPI() {
    return _instance;
  }
  ImgurManageAPI._internal();

  @override
  String configFileName() => 'imgur_config.txt';

  Future<File> manageLocalFile() async {
    final path = await localPath();
    return File('$path/imgur_manage.txt');
  }

  Future<String> readImgurManageConfig() async {
    try {
      final file = await manageLocalFile();
      String contents = await file.readAsString();
      return contents;
    } catch (e) {
      flogErr(e, {}, 'ImgurManageAPI', 'readImgurManageConfig');
      return "Error";
    }
  }

  Future<bool> saveImgurManageConfig(String imgurUsername, String clientid, String accesstoken, String proxy) async {
    try {
      final file = await manageLocalFile();
      await file.writeAsString(
          jsonEncode({'imguruser': imgurUsername, 'clientid': clientid, 'accesstoken': accesstoken, 'proxy': proxy}));
      return true;
    } catch (e) {
      flogErr(e, {'imguruser': imgurUsername, 'clientid': clientid, 'accesstoken': accesstoken, 'proxy': proxy},
          'ImgurManageAPI', 'saveImgurManageConfig');
      return false;
    }
  }

  _makeRequest(String endpoint, String proxy,
      {dynamic data,
      Map<String, dynamic>? queryParameters,
      Map<String, dynamic>? headers,
      required Function onSuccess,
      String method = 'POST',
      String callFunction = '_makeRequest',
      required Function checkSuccess}) async {
    try {
      BaseOptions baseoptions = setBaseOptions();
      baseoptions.headers = {
        ...?headers,
      };
      Dio dio = Dio(baseoptions);
      //判断是否有代理
      if (proxy != 'None') {
        String proxyClean = proxy.startsWith('http://') || proxy.startsWith('https://') ? proxy.split('://')[1] : proxy;
        dio.httpClientAdapter = useProxy(proxyClean);
      }
      Response response;
      if (method == 'GET') {
        response = await dio.get(endpoint, queryParameters: queryParameters);
      } else if (method == 'POST') {
        response = await dio.post(endpoint, data: data, queryParameters: queryParameters);
      } else if (method == 'DELETE') {
        response = await dio.delete(endpoint, data: data, queryParameters: queryParameters);
      } else if (method == 'PUT') {
        response = await dio.put(endpoint, data: data, queryParameters: queryParameters);
      } else {
        throw Exception('Unsupported HTTP method: $method');
      }

      if (checkSuccess(response)) {
        return onSuccess(response);
      }
      flogErr(
        response,
        {
          'endpoint': endpoint,
          'proxy': proxy,
          'data': data,
          'queryParameters': queryParameters,
          'headers': headers,
        },
        "ImgurManageAPI",
        callFunction,
      );
      return ['failed'];
    } catch (e) {
      flogErr(e, {}, "ImgurManageAPI", callFunction);
      return [e.toString()];
    }
  }

  checkToken(String username, String accesstoken, String proxy) async {
    return await _makeRequest(
      "https://api.imgur.com/3/account/me/settings",
      proxy,
      headers: {
        "Authorization": "Bearer $accesstoken",
      },
      onSuccess: (Response response) => ["success"],
      method: 'GET',
      callFunction: 'checkToken',
      checkSuccess: (Response response) => response.statusCode == 200 && response.data?['success'] == true,
    );
  }

  //get album list
  getAlbumList(String username, String accesstoken, String proxy) async {
    BaseOptions options = setBaseOptions();
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
      dio.httpClientAdapter = useProxy(proxyClean);
    }
    int page = 0;
    List albumList = [];
    String accountUrl = "https://api.imgur.com/3/account/$username/albums/ids/$page";
    while (true) {
      try {
        Response response = await dio.get(
          accountUrl,
        );
        if (response.statusCode == 200 && response.data?['success'] == true) {
          if (response.data?['data'].length == 0) {
            break;
          } else {
            albumList.addAll(response.data?['data']);
            page++;
            accountUrl = "https://api.imgur.com/3/account/$username/albums/ids/$page";
          }
        } else {
          return ["failed"];
        }
      } catch (e) {
        flogErr(
          e,
          {
            'username': username,
            'accesstoken': accesstoken,
            'proxy': proxy,
          },
          'ImgurManageAPI',
          'getAlbumList',
        );
        return [e.toString()];
      }
    }
    return ['success', albumList];
  }

  //get album info
  getAlbumInfo(String clienID, String albumhash, String proxy) async {
    return await _makeRequest(
      "https://api.imgur.com/3/album/$albumhash",
      proxy,
      headers: {
        "Authorization": "Client-ID $clienID",
      },
      onSuccess: (response) => ["success", response.data?['data']],
      method: 'GET',
      callFunction: 'getAlbumInfo',
      checkSuccess: (response) => response.statusCode == 200 && response.data?['success'] == true,
    );
  }

  //get all images
  getImagesList(String username, String accesstoken, String proxy) async {
    BaseOptions options = setBaseOptions();
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
      dio.httpClientAdapter = useProxy(proxyClean);
    }
    int page = 0;
    List imageList = [];
    String accountUrl = "https://api.imgur.com/3/account/$username/images/$page";
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
            accountUrl = "https://api.imgur.com/3/account/$username/images/$page";
          }
        } else {
          return ["failed"];
        }
      } catch (e) {
        flogErr(
          e,
          {
            'username': username,
            'accesstoken': accesstoken,
            'proxy': proxy,
          },
          'ImgurManageAPI',
          'getImagesList',
        );
        return [e.toString()];
      }
    }
    return ['success', imageList];
  }

  //is no image
  isEmptyAccount(String username, String accesstoken, String proxy) async {
    var queryResult = await getImagesList(username, accesstoken, proxy);
    if (queryResult[0] != 'success') {
      return ['error'];
    }
    if (queryResult[1].length == 0) {
      return ['empty'];
    }
    return ['notempty'];
  }

  //get images of album
  getAlbumImages(String clientID, String albumHash, String proxy) async {
    return await _makeRequest(
      "https://api.imgur.com/3/album/$albumHash/images",
      proxy,
      headers: {
        "Authorization": "Client-ID $clientID",
      },
      onSuccess: (response) => ["success", response.data?['data']],
      method: 'GET',
      callFunction: 'getAlbumImages',
      checkSuccess: (response) => response.statusCode == 200 && response.data?['success'] == true,
    );
  }

  //get not in album images
  getNotInAlbumImages(String username, String accesstoken, String clientID, String proxy) async {
    var getImagesListResult = await getImagesList(username, accesstoken, proxy);
    if (getImagesListResult[0] != 'success') {
      return ['failed'];
    }

    List allImages = getImagesListResult[1];
    if (allImages.isEmpty) {
      return ['success', [], []];
    }
    var getAlbumListResult = await getAlbumList(username, accesstoken, proxy);
    if (getAlbumListResult[0] != 'success') {
      return ['failed'];
    }

    List allAlbums = getAlbumListResult[1];
    if (allAlbums.isEmpty) {
      return ['success', allImages, allImages];
    }
    List imagesInAlbum = [];
    for (var album in allAlbums) {
      var getAlbumImagesResult = await getAlbumImages(clientID, album, proxy);
      if (getAlbumImagesResult[0] != 'success') {
        return ['failed'];
      }
      imagesInAlbum.addAll(getAlbumImagesResult[1]);
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

  //create album
  createAlbum(String accesstoken, String title, String proxy) async {
    return await _makeRequest(
      "https://api.imgur.com/3/album",
      proxy,
      data: jsonEncode({
        "title": title,
        "description": "Created by PicHoro",
      }),
      headers: {
        "Authorization": "Bearer $accesstoken",
        "Content-Type": "application/json",
      },
      onSuccess: (response) => ["success", response.data?['data']],
      method: 'POST',
      callFunction: 'createAlbum',
      checkSuccess: (response) => response.statusCode == 200 && response.data?['success'] == true,
    );
  }

  //delete album
  deleteAlbum(String accesstoken, String albumHash, String proxy) async {
    return await _makeRequest(
      "https://api.imgur.com/3/album/$albumHash",
      proxy,
      headers: {
        "Authorization": "Bearer $accesstoken",
      },
      onSuccess: (response) => ["success"],
      method: 'DELETE',
      callFunction: 'deleteAlbum',
      checkSuccess: (response) => response.statusCode == 200 && response.data?['success'] == true,
    );
  }

  //delete image
  deleteImage(String accesstoken, String imageHash, String proxy) async {
    return await _makeRequest(
      "https://api.imgur.com/3/image/$imageHash",
      proxy,
      headers: {
        "Authorization": "Bearer $accesstoken",
      },
      onSuccess: (response) => ["success"],
      method: 'DELETE',
      callFunction: 'deleteImage',
      checkSuccess: (response) => response.statusCode == 200 && response.data?['success'] == true,
    );
  }

  //add image to album
  uploadFile(String accesstoken, String albumHash, String filename, String filepath, String proxy) async {
    FormData formdata = FormData.fromMap({
      "image": await MultipartFile.fromFile(filepath, filename: filename),
      "type": "file",
      "name": filename,
      if (albumHash != 'None') "album": albumHash,
      "description": "Uploaded by PicHoro",
    });
    return await _makeRequest(
      "https://api.imgur.com/3/image",
      proxy,
      data: formdata,
      headers: {
        "Authorization": "Bearer $accesstoken",
      },
      onSuccess: (response) => ["success"],
      method: 'POST',
      callFunction: 'uploadFile',
      checkSuccess: (response) => response.statusCode == 200 && response.data?['success'] == true,
    );
  }

  uploadNetworkFile(String fileLink, String accesstoken, String albumHash, String proxy) async {
    try {
      String filename = fileLink.substring(fileLink.lastIndexOf("/") + 1, fileLink.length);
      filename = filename.substring(0, !filename.contains("?") ? filename.length : filename.indexOf("?"));
      String savePath = await getTemporaryDirectory().then((value) {
        return value.path;
      });
      String saveFilePath = '$savePath/$filename';
      Dio dio = Dio();
      Response response = await dio.download(fileLink, saveFilePath);
      if (response.statusCode != 200) {
        return ['failed'];
      }
      var uploadResult = await uploadFile(accesstoken, albumHash, filename, saveFilePath, proxy);
      if (uploadResult[0] != "success") {
        return ['failed'];
      }
      return ['success'];
    } catch (e) {
      flogErr(
        e,
        {
          'fileLink': fileLink,
          'accesstoken': accesstoken,
          'albumHash': albumHash,
          'proxy': proxy,
        },
        'ImgurManageAPI',
        'uploadNetworkFile',
      );
      return ['failed'];
    }
  }

  uploadNetworkFileEntry(List fileList, String accesstoken, String albumHash, String proxy) async {
    int successCount = 0;
    int failCount = 0;
    for (String fileLink in fileList) {
      if (fileLink.isEmpty) {
        continue;
      }
      var uploadResult = await uploadNetworkFile(fileLink, accesstoken, albumHash, proxy);
      if (uploadResult[0] == "success") {
        successCount++;
      } else {
        failCount++;
      }
    }

    if (successCount == 0) {
      return showToast('上传失败');
    } else if (failCount == 0) {
      return showToast('上传成功');
    }
    return showToast('成功$successCount,失败$failCount');
  }
}
