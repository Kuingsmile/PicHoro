import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:f_logs/f_logs.dart';
import 'package:fluro/fluro.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as my_path;

import 'package:horopic/router/application.dart';
import 'package:horopic/utils/event_bus_utils.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/utils/sql_utils.dart';
import 'package:horopic/utils/global.dart';
import 'package:horopic/picture_host_manage/manage_api/aliyun_manage_api.dart';
import 'package:horopic/pages/loading.dart';

class AliyunConfig extends StatefulWidget {
  const AliyunConfig({Key? key}) : super(key: key);

  @override
  AliyunConfigState createState() => AliyunConfigState();
}

class AliyunConfigState extends State<AliyunConfig> {
  final _formKey = GlobalKey<FormState>();

  final _keyIdController = TextEditingController();
  final _keySecretController = TextEditingController();
  final _bucketController = TextEditingController();
  final _areaController = TextEditingController();
  final _pathController = TextEditingController();
  final _customUrlController = TextEditingController();
  final _optionsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initConfig();
  }

  _initConfig() async {
    try {
      Map configMap = await AliyunManageAPI.getConfigMap();
      _keyIdController.text = configMap['keyId'];
      _keySecretController.text = configMap['keySecret'];
      _bucketController.text = configMap['bucket'];
      _areaController.text = configMap['area'];
      if (configMap['path'] != 'None') {
        _pathController.text = configMap['path'];
      } else {
        _pathController.clear();
      }
      if (configMap['customUrl'] != 'None') {
        _customUrlController.text = configMap['customUrl'];
      } else {
        _customUrlController.clear();
      }
      if (configMap['options'] != 'None') {
        _optionsController.text = configMap['options'];
      } else {
        _optionsController.clear();
      }
      setState(() {});
    } catch (e) {
      FLog.error(
          className: 'AliyunConfigState',
          methodName: '_initConfig',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
    }
  }

  @override
  void dispose() {
    _keyIdController.dispose();
    _keySecretController.dispose();
    _bucketController.dispose();
    _areaController.dispose();
    _pathController.dispose();
    _customUrlController.dispose();
    _optionsController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: titleText('?????????????????????',
            ),
        actions: [
          IconButton(
            onPressed: () async {
              await Application.router.navigateTo(
                  context, '/configureStorePage?psHost=aliyun',
                  transition: TransitionType.cupertino);
              await _initConfig();
              setState(() {});
            },
            icon: const Icon(Icons.save_as_outlined,
                color: Color.fromARGB(255, 255, 255, 255), size: 35),
          )
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          children: [
            TextFormField(
              controller: _keyIdController,
              decoration: const InputDecoration(
                label: Center(child: Text('accessKeyId')),
                hintText: '??????KeyId',
              ),
              textAlign: TextAlign.center,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '?????????accessKeyId';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _keySecretController,
              decoration: const InputDecoration(
                label: Center(child: Text('accessKeySecret')),
                hintText: '??????KeySecret',
              ),
              textAlign: TextAlign.center,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '?????????accessKeySecret';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _bucketController,
              decoration: const InputDecoration(
                label: Center(child: Text('bucket')),
                hintText: '??????bucket',
              ),
              textAlign: TextAlign.center,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '?????????bucket';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _areaController,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.zero,
                label: Center(child: Text('????????????')),
                hintText: '??????oss-cn-beijing',
              ),
              textAlign: TextAlign.center,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '?????????????????????';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _pathController,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.zero,
                label: Center(child: Text('??????:????????????')),
                hintText: '??????test/',
                hintStyle: TextStyle(fontSize: 13),
              ),
              textAlign: TextAlign.center,
            ),
            TextFormField(
              controller: _customUrlController,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.zero,
                label: Center(child: Text('??????:???????????????')),
                hintText: '??????https://test.com',
                hintStyle: TextStyle(fontSize: 13),
              ),
              textAlign: TextAlign.center,
            ),
            TextFormField(
              controller: _optionsController,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.zero,
                label: Center(child: Text('??????:????????????')),
                hintText: '???????x-oss-process=xxx',
                hintStyle: TextStyle(fontSize: 13),
              ),
              textAlign: TextAlign.center,
            ),
            ListTile(
                title: ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) {
                        return NetLoadingDialog(
                          outsideDismiss: false,
                          loading: true,
                          loadingText: "?????????...",
                          requestCallBack: _saveAliyunConfig(),
                        );
                      });
                }
              },
              child: titleText('????????????',fontsize: null
                  ),
            )),
            ListTile(
                title: ElevatedButton(
              onPressed: () {
                showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) {
                      return NetLoadingDialog(
                        outsideDismiss: false,
                        loading: true,
                        loadingText: "?????????...",
                        requestCallBack: checkAliyunConfig(),
                      );
                    });
              },
              child: titleText('??????????????????',fontsize: null),
            )),
            ListTile(
                title: ElevatedButton(
              onPressed: () async {
                await Application.router.navigateTo(
                    context, '/configureStorePage?psHost=aliyun',
                    transition: TransitionType.cupertino);
                await _initConfig();
                setState(() {});
              },
              child: titleText('??????????????????',
                  fontsize: null
                  ),
            )),
            ListTile(
                title: ElevatedButton(
              onPressed: () {
                _setdefault();
              },
              child: titleText('??????????????????',
                  fontsize: null
                  
                  ),
            )),
          ],
        ),
      ),
    );
  }

  Future _saveAliyunConfig() async {
    try {
      String keyId = _keyIdController.text;
      String keySecret = _keySecretController.text;
      String bucket = _bucketController.text;
      String area = _areaController.text;
      String path = _pathController.text;
      String customUrl = _customUrlController.text;
      String options = _optionsController.text;
      //?????????????????????/???????????????/??????
      if (path.isEmpty || path.replaceAll(' ', '').isEmpty) {
        path = 'None';
      } else {
        if (!path.endsWith('/')) {
          path = '$path/';
        }
        if (path.startsWith('/')) {
          path = path.substring(1);
        }
      }
      //?????????????????????????????????/????????????http(s)://??????
      if (customUrl.isEmpty) {
        customUrl = 'None';
      } else if (!customUrl.startsWith('http') &&
          !customUrl.startsWith('https')) {
        customUrl = 'http://$customUrl';
      }
      if (customUrl.endsWith('/')) {
        customUrl = customUrl.substring(0, customUrl.length - 1);
      }
      //??????????????????????????????????
      if (_optionsController.text.isNotEmpty) {
        options = _optionsController.text;
        if (!options.startsWith('?')) {
          options = '?$options';
        }
      } else {
        options = 'None';
      }

      List sqlconfig = [];
      sqlconfig.add(keyId);
      sqlconfig.add(keySecret);
      sqlconfig.add(bucket);
      sqlconfig.add(area);
      sqlconfig.add(path);
      sqlconfig.add(customUrl);
      sqlconfig.add(options);
      //??????????????????
      String defaultUser = await Global.getUser();
      sqlconfig.add(defaultUser);

      var queryAliyun = await MySqlUtils.queryAliyun(username: defaultUser);
      var queryuser = await MySqlUtils.queryUser(username: defaultUser);

      if (queryuser == 'Empty') {
        return showCupertinoAlertDialog(
            context: context, title: '??????', content: '???????????????,????????????');
      }

      //save asset image to app dir
      String assetPath = 'assets/validateImage/PicHoroValidate.jpeg';
      String appDir = await getApplicationDocumentsDirectory().then((value) {
        return value.path;
      });
      String assetFilePath = '$appDir/PicHoroValidate.jpeg';
      File assetFile = File(assetFilePath);

      if (!assetFile.existsSync()) {
        ByteData data = await rootBundle.load(assetPath);
        List<int> bytes =
            data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
        await assetFile.writeAsBytes(bytes);
      }
      String key = 'PicHoroValidate.jpeg';
      String host = '$bucket.$area.aliyuncs.com';
      String urlpath = '';
      if (path != 'None') {
        urlpath = '$path$key';
      } else {
        urlpath = key;
      }

      Map<String, dynamic> uploadPolicy = {
        "expiration": "2034-12-01T12:00:00.000Z",
        "conditions": [
          {"bucket": bucket},
          ["content-length-range", 0, 104857600],
          {"key": urlpath}
        ]
      };
      String base64Policy =
          base64.encode(utf8.encode(json.encode(uploadPolicy)));
      String singature = base64.encode(Hmac(sha1, utf8.encode(keySecret))
          .convert(utf8.encode(base64Policy))
          .bytes);
      FormData formData = FormData.fromMap({
        'key': urlpath,
        'OSSAccessKeyId': keyId,
        'policy': base64Policy,
        'Signature': singature,
        //???????????????content-type???application/octet-stream???????????????image/xxx
        'x-oss-content-type':
            'image/${my_path.extension(assetFilePath).replaceFirst('.', '')}',
        'file': await MultipartFile.fromFile(assetFilePath, filename: key),
      });

      BaseOptions baseoptions = BaseOptions(
        //?????????????????????????????????????????????.
        connectTimeout: 30000,
        //?????????????????????
        receiveTimeout: 30000,
        sendTimeout: 30000,
      );
      String contentLength = await assetFile.length().then((value) {
        return value.toString();
      });
      baseoptions.headers = {
        'Host': host,
        'Content-Type':
            'multipart/form-data; boundary=----WebKitFormBoundary7MA4YWxkTrZu0gW',
        'Content-Length': contentLength,
      };
      Dio dio = Dio(baseoptions);
      var response = await dio.post(
        'https://$host',
        data: formData,
      );
      //??????????????????204
      if (response.statusCode == 204) {
        var sqlResult = '';

        if (queryAliyun == 'Empty') {
          sqlResult = await MySqlUtils.insertAliyun(content: sqlconfig);
        } else {
          sqlResult = await MySqlUtils.updateAliyun(content: sqlconfig);
        }

        if (sqlResult == "Success") {
          final aliyunConfig = AliyunConfigModel(
              keyId, keySecret, bucket, area, path, customUrl, options);
          final aliyunConfigJson = jsonEncode(aliyunConfig);
          final aliyunConfigFile = await localFile;
          await aliyunConfigFile.writeAsString(aliyunConfigJson);
          return showCupertinoAlertDialog(
              context: context, title: '??????', content: '????????????');
        } else {
          return showCupertinoAlertDialog(
              context: context, title: '??????', content: '???????????????');
        }
      } else {
        return showCupertinoAlertDialog(
            context: context, title: '??????', content: '????????????');
      }
    } catch (e) {
      FLog.error(
          className: 'AliyunConfigPage',
          methodName: 'saveAliyunConfig',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      return showCupertinoAlertDialog(
          context: context, title: '??????', content: e.toString());
    }
  }

  checkAliyunConfig() async {
    try {
      final aliyunConfigFile = await localFile;
      String configData = await aliyunConfigFile.readAsString();

      if (configData == "Error") {
        showCupertinoAlertDialog(
            context: context, title: "????????????!", content: "????????????????????????.");
        return;
      }

      Map configMap = jsonDecode(configData);

      //save asset image to app dir
      String assetPath = 'assets/validateImage/PicHoroValidate.jpeg';
      String appDir = await getApplicationDocumentsDirectory().then((value) {
        return value.path;
      });
      String assetFilePath = '$appDir/PicHoroValidate.jpeg';
      File assetFile = File(assetFilePath);

      if (!assetFile.existsSync()) {
        ByteData data = await rootBundle.load(assetPath);
        List<int> bytes =
            data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
        await assetFile.writeAsBytes(bytes);
      }
      String key = 'PicHoroValidate.jpeg';
      String host = '${configMap['bucket']}.${configMap['area']}.aliyuncs.com';
      String urlpath = '';
      if (configMap['path'] != 'None') {
        urlpath = '${configMap['path']}$key';
      } else {
        urlpath = key;
      }

      Map<String, dynamic> uploadPolicy = {
        "expiration": "2034-12-01T12:00:00.000Z",
        "conditions": [
          {"bucket": configMap['bucket']},
          ["content-length-range", 0, 104857600],
          {"key": urlpath}
        ]
      };
      String base64Policy =
          base64.encode(utf8.encode(json.encode(uploadPolicy)));
      String singature = base64.encode(
          Hmac(sha1, utf8.encode(configMap['keySecret']))
              .convert(utf8.encode(base64Policy))
              .bytes);
      FormData formData = FormData.fromMap({
        'key': urlpath,
        'OSSAccessKeyId': configMap['keyId'],
        'policy': base64Policy,
        'Signature': singature,
        //???????????????content-type???application/octet-stream???????????????image/xxx
        'x-oss-content-type':
            'image/${my_path.extension(assetFilePath).replaceFirst('.', '')}',
        'file': await MultipartFile.fromFile(assetFilePath, filename: key),
      });
      BaseOptions baseoptions = BaseOptions(
        connectTimeout: 30000,
        receiveTimeout: 30000,
        sendTimeout: 30000,
      );
      String contentLength = await assetFile.length().then((value) {
        return value.toString();
      });
      baseoptions.headers = {
        'Host': host,
        'Content-Type':
            'multipart/form-data; boundary=----WebKitFormBoundary7MA4YWxkTrZu0gW',
        'Content-Length': contentLength,
      };
      Dio dio = Dio(baseoptions);
      var response = await dio.post(
        'https://$host',
        data: formData,
      );

      if (response.statusCode == 204) {
        return showCupertinoAlertDialog(
            context: context,
            title: '??????',
            content:
                '????????????????????????????????????:\n\nAccessKeyId:\n${configMap['keyId']}\nAccessKeySecret:\n${configMap['keySecret']}\nBucket:\n${configMap['bucket']}\nArea:\n${configMap['area']}\nPath:\n${configMap['path']}\nCustomUrl:\n${configMap['customUrl']}\nOptions:\n${configMap['options']}');
      } else {
        return showCupertinoAlertDialog(
            context: context, title: '??????', content: '????????????????????????????????????');
      }
    } catch (e) {
      FLog.error(
          className: 'AliyunConfigPage',
          methodName: 'checkAliyunConfig',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      return showCupertinoAlertDialog(
          context: context, title: "????????????!", content: e.toString());
    }
  }

  Future<File> get localFile async {
    final path = await _localPath;
    String defaultUser = await Global.getUser();
    return File('$path/${defaultUser}_aliyun_config.txt');
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<String> readAliyunConfig() async {
    try {
      final file = await localFile;
      String contents = await file.readAsString();
      return contents;
    } catch (e) {
      FLog.error(
          className: 'AliyunConfigPage',
          methodName: 'readAliyunConfig',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      return "Error";
    }
  }

  _setdefault() async {
    try {
      String defaultUser = await Global.getUser();
      String defaultPassword = await Global.getPassword();

      var queryuser = await MySqlUtils.queryUser(username: defaultUser);
      if (queryuser == 'Empty') {
        return Fluttertoast.showToast(
            msg: "??????????????????",
            toastLength: Toast.LENGTH_SHORT,
            timeInSecForIosWeb: 2,
            fontSize: 16.0);
      } else if (queryuser['password'] != defaultPassword) {
        return Fluttertoast.showToast(
            msg: "????????????",
            toastLength: Toast.LENGTH_SHORT,
            timeInSecForIosWeb: 2,
            fontSize: 16.0);
      }

      var queryAliyun = await MySqlUtils.queryAliyun(username: defaultUser);
      if (queryAliyun == 'Empty') {
        return Fluttertoast.showToast(
            msg: "????????????????????????",
            toastLength: Toast.LENGTH_SHORT,
            timeInSecForIosWeb: 2,
            fontSize: 16.0);
      }
      if (queryAliyun == 'Error') {
        return Fluttertoast.showToast(
            msg: "Error",
            toastLength: Toast.LENGTH_SHORT,
            timeInSecForIosWeb: 2,
            fontSize: 16.0);
      }
      if (queryuser['defaultPShost'] == 'aliyun') {
        await Global.setPShost('aliyun');
        await Global.setShowedPBhost('aliyun');
        eventBus.fire(AlbumRefreshEvent(albumKeepAlive: false));
        eventBus.fire(HomePhotoRefreshEvent(homePhotoKeepAlive: false));
        return Fluttertoast.showToast(
            msg: "?????????????????????",
            toastLength: Toast.LENGTH_SHORT,
            timeInSecForIosWeb: 2,
            fontSize: 16.0);
      } else {
        List sqlconfig = [];
        sqlconfig.add(defaultUser);
        sqlconfig.add(defaultPassword);
        sqlconfig.add('aliyun');

        var updateResult = await MySqlUtils.updateUser(content: sqlconfig);
        if (updateResult == 'Success') {
          await Global.setPShost('aliyun');
          await Global.setShowedPBhost('aliyun');
          showToast('?????????????????????????????????');
          eventBus.fire(HomePhotoRefreshEvent(homePhotoKeepAlive: false));
          eventBus.fire(AlbumRefreshEvent(albumKeepAlive: false));
        } else {
          showToast('?????????????????????');
        }
      }
    } catch (e) {
      FLog.error(
          className: 'AliyunConfigPage',
          methodName: '_setdefault',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      showToastWithContext(context, '??????');
    }
  }
}

class AliyunConfigModel {
  final String keyId;
  final String keySecret;
  final String bucket;
  final String area;
  final String path;
  final String customUrl;
  final String options;

  AliyunConfigModel(this.keyId, this.keySecret, this.bucket, this.area,
      this.path, this.customUrl, this.options);

  Map<String, dynamic> toJson() => {
        'keyId': keyId,
        'keySecret': keySecret,
        'bucket': bucket,
        'area': area,
        'path': path,
        'customUrl': customUrl,
        'options': options,
      };

  static List keysList = [
    'remarkName',
    'keyId',
    'keySecret',
    'bucket',
    'area',
    'path',
    'customUrl',
    'options',
  ];
}
