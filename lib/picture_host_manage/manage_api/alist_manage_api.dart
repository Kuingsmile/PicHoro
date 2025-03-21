import 'dart:io';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

import 'package:horopic/utils/global.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/picture_host_configure/configure_page/alist_configure.dart';
import 'package:horopic/picture_host_manage/common/base_manage_api.dart';

class AlistManageAPI extends BaseManageApi {
  static final AlistManageAPI _instance = AlistManageAPI._internal();
  AlistManageAPI._internal();
  factory AlistManageAPI() {
    return _instance;
  }
  Map driverTranslate = {
    '115 Cloud': '115网盘',
    '115 Share': '115网盘分享',
    '123Pan': '123网盘',
    '123PanLink': '123网盘直链',
    '123PanShare': '123网盘分享',
    '139Yun': '中国移动云盘',
    '189Cloud': '天翼云盘',
    '189CloudPC': '天翼云盘客户端',
    'AList V2': 'Alist V2',
    'AList V3': 'Alist V3',
    'Alias': '别名',
    'Aliyundrive': '阿里云盘',
    'AliyundriveOpen': '阿里云盘Open',
    'AliyundriveShare': '阿里云盘分享',
    'BaiduNetdisk': '百度网盘',
    'BaiduPhoto': '一刻相册',
    'BaiduShare': '百度网盘分享',
    'ChaoXingGroupDrive': '超星小组盘',
    'Cloudreve': 'Cloudreve',
    'Crypt': 'Crypt',
    'Doge': '多吉云',
    'Dropbox': 'Dropbox',
    'FTP': 'FTP',
    'FeijiPan': '飞机盘',
    'GoogleDrive': '谷歌云盘',
    'GooglePhoto': '谷歌相册',
    'ILanZou': '蓝奏云优享版',
    'IPFS API': 'IPFS API',
    'Lanzou': '蓝奏云',
    "Lark": "Lark(飞书)",
    'Local': '本机存储',
    'MediaTrack': '分秒帧',
    'Mega_nz': 'MEGA网盘',
    'MoPan': '魔盘',
    'NeteaseMusic': '网易云音乐',
    'Onedrive': 'OneDrive',
    'OnedriveAPP': 'OneDrive APP',
    'PikPak': 'PikPak',
    'PikPakShare': 'PikPak分享',
    'Quark': '夸克',
    'Quqi': '曲奇云盘',
    'S3': '对象存储',
    'SFTP': 'SFTP',
    'SMB': 'SMB',
    'Seafile': 'Seafile',
    'Teambition': 'Teambition网盘',
    'Terabox': 'Terabox',
    'Thunder': '迅雷',
    'ThunderExpert': '迅雷专家版',
    'ThunderX': '迅雷X',
    'ThunderXExpert': '迅雷X专家版',
    'Trainbit': 'Trainbit',
    'UC': 'UC',
    'USS': '又拍云存储',
    'UrlTree': 'UrlTree',
    'VTencent': '腾讯智能创作平台',
    'Virtual': '虚拟存储',
    'WebDav': 'WebDav',
    'Weiyun': '腾讯微云',
    'WoPan': '联通云盘',
    'YandexDisk': 'Yandex网盘',
  };

  @override
  String configFileName() => 'alist_config.txt';

  Future<List> getToken(String host, String username, String password) async {
    try {
      String url = '$host/api/auth/login';
      Map<String, dynamic> queryParameters = {
        'Password': password,
        'Username': username,
      };

      BaseOptions baseoptions = setBaseOptions();
      baseoptions.headers = {
        "Content-Type": "application/json",
      };
      Dio dio = Dio(baseoptions);

      var response = await dio.post(url, data: queryParameters);
      if (response.statusCode == 200 && response.data['message'] == 'success') {
        return ['success', response.data['data']['token']];
      }
    } catch (e) {
      flogErr(
          e,
          {
            'host': host,
          },
          "AlistManageAPI",
          "getToken");
    }
    return ['failed'];
  }

  refreshToken() async {
    Map configMap = await getConfigMap();
    String uploadPath = configMap['uploadPath'];
    String token = configMap['token'];
    var res = await getToken(configMap['host'], configMap['alistusername'], configMap['password']);
    if (res[0] != 'success') {
      return ['failed'];
    }
    token = res[1];
    final alistConfig = AlistConfigModel(
      configMap['host'],
      'None',
      configMap['alistusername'],
      configMap['password'],
      token,
      uploadPath,
      configMap['webPath'] ?? 'None',
      configMap['customUrl'] ?? 'None',
    );
    final alistConfigJson = jsonEncode(alistConfig);
    final alistConfigFile = await localFile();
    alistConfigFile.writeAsString(alistConfigJson);

    return ['success', token];
  }

  static getUsedToken(Map configMap) {
    String token = configMap['token'];
    String? adminToken = configMap['adminToken'];
    if (adminToken != null && adminToken != 'None' && adminToken.trim().isNotEmpty) {
      token = adminToken;
    }
    return token;
  }

  setDefaultBucket(String path) async {
    try {
      Map configMap = await getConfigMap();
      String uploadPath = path;
      if (uploadPath == '/' || uploadPath == '') {
        uploadPath = 'None';
      }

      final alistConfig = AlistConfigModel(
        configMap['host'],
        configMap['adminToken'] ?? 'None',
        configMap['alistusername'],
        configMap['password'],
        configMap['token'],
        uploadPath,
        configMap['webPath'] ?? 'None',
        configMap['customUrl'] ?? 'None',
      );
      final alistConfigJson = jsonEncode(alistConfig);
      final alistConfigFile = await localFile();
      await alistConfigFile.writeAsString(alistConfigJson);
      return ['success'];
    } catch (e) {
      flogErr(
          e,
          {
            'path': path,
          },
          "AlistManageAPI",
          "setDefaultBucket");
      return ['failed'];
    }
  }

  _makeRequest(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    required Function onSuccess,
    String method = 'POST',
    String callFunction = 'makeRequest',
  }) async {
    try {
      Map configMap = await getConfigMap();
      String host = configMap['host'];
      String token = getUsedToken(configMap);
      String url = '$host$endpoint';

      BaseOptions baseoptions = setBaseOptions();
      baseoptions.headers = {
        "Authorization": token,
        ...?headers,
      };
      Dio dio = Dio(baseoptions);

      Response response;
      if (method == 'GET') {
        response = await dio.get(url, queryParameters: queryParameters);
      } else if (method == 'POST') {
        response = await dio.post(url, data: data, queryParameters: queryParameters);
      } else {
        response = await dio.put(url, data: data, queryParameters: queryParameters);
      }

      if (response.statusCode == 200 && response.data['message'] == 'success') {
        return onSuccess(response);
      }
      flogErr(
        response,
        {
          'url': url,
          'data': data,
          'queryParameters': queryParameters,
          'headers': headers,
        },
        "AlistManageAPI",
        callFunction,
      );
      return [response.toString()];
    } catch (e) {
      flogErr(e, {}, "AlistManageAPI", callFunction);
      return [e.toString()];
    }
  }

  Future<List> getBucketList() async {
    return await _makeRequest(
      '/api/admin/storage/list',
      method: 'GET',
      onSuccess: (response) => ['success', response.data['data']],
      callFunction: 'getBucketList',
    );
  }

  Future<List<String>> changeBucketState(Map element, bool enable) async {
    return await _makeRequest(
      '/api/admin/storage/${enable ? 'enable' : 'disable'}',
      queryParameters: {
        'id': element['id'],
      },
      onSuccess: (response) => ['success'],
      callFunction: 'changeBucketState',
    );
  }

  Future<List<String>> deleteBucket(Map element) async {
    return await _makeRequest(
      '/api/admin/storage/delete',
      queryParameters: {
        'id': element['id'],
      },
      onSuccess: (response) => ['success'],
      callFunction: 'deleteBucket',
    );
  }

  listFolder(String folder, String refresh) async {
    try {
      Map configMap = await getConfigMap();
      String host = configMap['host'];
      String token = getUsedToken(configMap);
      String url = '$host/api/fs/list';

      BaseOptions baseoptions = setBaseOptions();
      baseoptions.headers = {
        "Authorization": token,
        "Content-Type": "application/json",
      };
      int startPage = 1;
      Map<String, dynamic> dataMap = {
        "page": startPage,
        "path": folder,
        "per_page": 1000,
        "refresh": refresh == 'Refresh' ? true : false,
      };
      Dio dio = Dio(baseoptions);
      List fileList = [];

      var response = await dio.post(
        url,
        data: dataMap,
      );
      if (response.statusCode == 200 && response.data['message'] == 'success') {
        if (response.data['data']['total'] == 0) {
          return ['success', fileList];
        }
        fileList = response.data['data']['content'];
        if (response.data['data']['total'] > 1000) {
          showToast('${response.data['data']['total']}文件 可能需要较长时间');
          int totalPage = (response.data['data']['total'] / 1000).ceil();
          for (int i = 2; i <= totalPage; i++) {
            dataMap['page'] = i;
            response = await dio.post(
              url,
              data: dataMap,
            );
            if (response.statusCode == 200 && response.data['message'] == 'success') {
              if (response.data['data']['total'] == 0) {
                return ['success', fileList];
              }
              fileList.addAll(response.data['data']['content']);
            } else {
              flogErr(
                response,
                {
                  'url': url,
                  'data': dataMap,
                },
                "AlistManageAPI",
                "listFolder",
              );
              return [response.toString()];
            }
          }
        }
        return ['success', fileList];
      }
      flogErr(
        response,
        {
          'url': url,
          'data': dataMap,
        },
        "AlistManageAPI",
        "listFolder",
      );
      return [response.toString()];
    } catch (e) {
      flogErr(e, {}, "AlistManageAPI", "listFolder");
      return [e.toString()];
    }
  }

  getFileInfo(String path) async {
    return await _makeRequest(
      '/api/fs/get',
      data: {
        "path": path,
      },
      headers: {
        "Content-Type": "application/json",
      },
      onSuccess: (response) => ['success', response.data['data']],
      callFunction: 'getFileInfo',
    );
  }

  mkDir(String path) async {
    return await _makeRequest(
      '/api/fs/mkdir',
      data: {
        "path": path,
      },
      headers: {
        "Content-Type": "application/json",
      },
      onSuccess: (response) => ['success'],
      callFunction: 'mkDir',
    );
  }

  rename(String source, String target) async {
    return await _makeRequest(
      '/api/fs/rename',
      data: {
        "path": source,
        "name": target,
      },
      headers: {
        "Content-Type": "application/json",
      },
      onSuccess: (response) => ['success'],
      callFunction: 'rename',
    );
  }

  remove(String dir, List names) async {
    return await _makeRequest(
      '/api/fs/remove',
      data: {
        "dir": dir,
        "names": names,
      },
      headers: {
        "Content-Type": "application/json",
      },
      onSuccess: (response) => ['success'],
      callFunction: 'remove',
    );
  }

  uploadFile(String filename, String filepath, String uploadPath) async {
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
    String filePath = uploadPath + filename;
    FormData formdata = FormData.fromMap({
      "file": await MultipartFile.fromFile(filepath, filename: filename),
    });
    File uploadFile = File(filepath);
    int contentLength = await uploadFile.length().then((value) {
      return value;
    });
    Map<String, dynamic> headers = {
      "Content-Type": Global.multipartString,
      "file-path": Uri.encodeComponent(filePath),
      "Content-Length": contentLength,
    };
    return await _makeRequest(
      '/api/fs/form',
      data: formdata,
      headers: headers,
      method: 'PUT',
      onSuccess: (response) => ['success'],
      callFunction: 'uploadFile',
    );
  }

  //从网络链接下载文件后上传
  uploadNetworkFile(String fileLink, String uploadPath) async {
    try {
      String filename = fileLink.substring(fileLink.lastIndexOf("/") + 1, fileLink.length);
      filename = filename.substring(0, !filename.contains("?") ? filename.length : filename.indexOf("?"));
      String savePath = await getTemporaryDirectory().then((value) {
        return value.path;
      });
      String saveFilePath = '$savePath/$filename';
      Dio dio = Dio();
      Response response = await dio.download(fileLink, saveFilePath);
      if (response.statusCode == 200) {
        var uploadResult = await uploadFile(
          filename,
          saveFilePath,
          uploadPath,
        );
        if (uploadResult[0] == "success") {
          return ['success'];
        }
      }
    } catch (e) {
      flogErr(e, {'fileLink': fileLink, 'uploadPath': uploadPath}, "AlistManageAPI", "uploadNetworkFile");
    }
    return ['failed'];
  }

  uploadNetworkFileEntry(List fileList, String uploadPath) async {
    int successCount = 0;
    int failCount = 0;

    for (String fileLink in fileList) {
      if (fileLink.isEmpty) {
        continue;
      }
      var uploadResult = await uploadNetworkFile(fileLink, uploadPath);
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
