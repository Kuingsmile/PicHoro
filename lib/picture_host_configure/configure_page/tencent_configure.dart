import 'dart:io';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:f_logs/f_logs.dart';
import 'package:fluro/fluro.dart';
import 'package:path_provider/path_provider.dart';

import 'package:horopic/router/application.dart';
import 'package:horopic/api/tencent_api.dart';
import 'package:horopic/pages/loading.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/utils/sql_utils.dart';
import 'package:horopic/utils/global.dart';
import 'package:horopic/utils/event_bus_utils.dart';
import 'package:horopic/picture_host_manage/manage_api/tencent_manage_api.dart';

class TencentConfig extends StatefulWidget {
  const TencentConfig({Key? key}) : super(key: key);

  @override
  TencentConfigState createState() => TencentConfigState();
}

class TencentConfigState extends State<TencentConfig> {
  final _formKey = GlobalKey<FormState>();

  final _secretIdController = TextEditingController();
  final _secretKeyController = TextEditingController();
  final _bucketController = TextEditingController();
  final _appIdController = TextEditingController();
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
      Map configMap = await TencentManageAPI.getConfigMap();
      _secretIdController.text = configMap['secretId'];
      _secretKeyController.text = configMap['secretKey'];
      _bucketController.text = configMap['bucket'];
      _appIdController.text = configMap['appId'];
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
    } catch (e) {
      FLog.error(
          className: 'TencentConfigState',
          methodName: 'initConfig',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
    }
  }

  @override
  void dispose() {
    _secretIdController.dispose();
    _secretKeyController.dispose();
    _bucketController.dispose();
    _appIdController.dispose();
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
        title: titleText('?????????????????????'),
        actions: [
          IconButton(
            onPressed: () async {
              await Application.router.navigateTo(
                  context, '/configureStorePage?psHost=tencent',
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
              controller: _secretIdController,
              decoration: const InputDecoration(
                label: Center(child: Text('secretId')),
                hintText: '??????secretId',
              ),
              textAlign: TextAlign.center,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '?????????secretId';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _secretKeyController,
              decoration: const InputDecoration(
                label: Center(child: Text('secretKey')),
                hintText: '??????secretKey',
              ),
              textAlign: TextAlign.center,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '?????????secretKey';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _bucketController,
              decoration: const InputDecoration(
                label: Center(child: Text('bucket')),
                hintText: '???test-12345678',
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
              controller: _appIdController,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.zero,
                label: Center(child: Text('appId')),
                hintText: '??????1234567890',
              ),
              textAlign: TextAlign.center,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '?????????appId';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _areaController,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.zero,
                label: Center(child: Text('????????????')),
                hintText: '??????ap-nanjing',
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
                hintText: '???????imageMogr2',
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
                          requestCallBack: _saveTencentConfig(),
                        );
                      });
                }
              },
              child: titleText('????????????',fontsize: null),
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
                        requestCallBack: checkTencentConfig(),
                      );
                    });
              },
              child: titleText('??????????????????',fontsize: null),
            )),
            ListTile(
                title: ElevatedButton(
              onPressed: () async {
                await Application.router.navigateTo(
                    context, '/configureStorePage?psHost=tencent',
                    transition: TransitionType.cupertino);
                await _initConfig();
                setState(() {});
              },
              child: titleText('??????????????????',fontsize: null),
            )),
            ListTile(
                title: ElevatedButton(
              onPressed: () {
                _setdefault();
              },
              child: titleText('??????????????????',fontsize: null),
            )),
          ],
        ),
      ),
    );
  }

  Future _saveTencentConfig() async {
    try {
      String secretId = _secretIdController.text;
      String secretKey = _secretKeyController.text;
      String bucket = _bucketController.text;
      String appId = _appIdController.text;
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
      sqlconfig.add(secretId);
      sqlconfig.add(secretKey);
      sqlconfig.add(bucket);
      sqlconfig.add(appId);
      sqlconfig.add(area);
      sqlconfig.add(path);
      sqlconfig.add(customUrl);
      sqlconfig.add(options);
      //??????????????????
      String defaultUser = await Global.getUser();
      sqlconfig.add(defaultUser);

      var queryTencent = await MySqlUtils.queryTencent(username: defaultUser);
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
      String host = '$bucket.cos.$area.myqcloud.com';
      String urlpath = '';
      if (path != 'None') {
        urlpath = '$path$key';
      } else {
        urlpath = key;
      }
      int startTimestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      int endTimestamp = startTimestamp + 86400;
      String keyTime = '$startTimestamp;$endTimestamp';
      Map<String, dynamic> uploadPolicy = {
        "expiration": "2033-03-03T09:38:12.414Z",
        "conditions": [
          {"acl": "default"},
          {"bucket": bucket},
          {"key": urlpath},
          {"q-sign-algorithm": "sha1"},
          {"q-ak": secretId},
          {"q-sign-time": keyTime}
        ]
      };
      String uploadPolicyStr = jsonEncode(uploadPolicy);
      String singature = TencentImageUploadUtils.getUploadAuthorization(
          secretKey, keyTime, uploadPolicyStr);
      //policy?????????????????????bucket?????????????????????formdata?????????
      FormData formData = FormData.fromMap({
        'key': urlpath,
        'policy': base64Encode(utf8.encode(uploadPolicyStr)),
        'acl': 'default',
        'q-sign-algorithm': 'sha1',
        'q-ak': secretId,
        'q-key-time': keyTime,
        'q-sign-time': keyTime,
        'q-signature': singature,
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
        'http://$host',
        data: formData,
      );
      //??????????????????204
      if (response.statusCode == 204) {
        var sqlResult = '';

        if (queryTencent == 'Empty') {
          sqlResult = await MySqlUtils.insertTencent(content: sqlconfig);
        } else {
          sqlResult = await MySqlUtils.updateTencent(content: sqlconfig);
        }

        if (sqlResult == "Success") {
          final tencentConfig = TencentConfigModel(secretId, secretKey, bucket,
              appId, area, path, customUrl, options);
          final tencentConfigJson = jsonEncode(tencentConfig);
          final tencentConfigFile = await localFile;
          await tencentConfigFile.writeAsString(tencentConfigJson);
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
          className: 'TencentConfigPage',
          methodName: 'saveConfig',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      return showCupertinoAlertDialog(
          context: context, title: '??????', content: e.toString());
    }
  }

  checkTencentConfig() async {
    try {
      final tencentConfigFile = await localFile;
      String configData = await tencentConfigFile.readAsString();

      if (configData == "Error") {
        return showCupertinoAlertDialog(
            context: context, title: "????????????!", content: "????????????????????????.");
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
      String host =
          '${configMap['bucket']}.cos.${configMap['area']}.myqcloud.com';
      String urlpath = '';
      if (configMap['path'] != 'None') {
        urlpath = '${configMap['path']}$key';
      } else {
        urlpath = key;
      }

      int startTimestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      int endTimestamp = startTimestamp + 86400;
      String keyTime = '$startTimestamp;$endTimestamp';
      Map<String, dynamic> uploadPolicy = {
        "expiration": "2033-03-03T09:38:12.414Z",
        "conditions": [
          {"acl": "default"},
          {"bucket": configMap['bucket']},
          {"key": urlpath},
          {"q-sign-algorithm": "sha1"},
          {"q-ak": configMap['secretId']},
          {"q-sign-time": keyTime}
        ]
      };
      String uploadPolicyStr = jsonEncode(uploadPolicy);
      String singature = TencentImageUploadUtils.getUploadAuthorization(
          configMap['secretKey'], keyTime, uploadPolicyStr);
      //policy?????????????????????bucket?????????????????????formdata?????????
      FormData formData = FormData.fromMap({
        'key': urlpath,
        'policy': base64Encode(utf8.encode(uploadPolicyStr)),
        'acl': 'default',
        'q-sign-algorithm': 'sha1',
        'q-ak': configMap['secretId'],
        'q-key-time': keyTime,
        'q-sign-time': keyTime,
        'q-signature': singature,
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
        'http://$host',
        data: formData,
      );

      if (response.statusCode == 204) {
        return showCupertinoAlertDialog(
            context: context,
            title: '??????',
            content:
                '????????????????????????????????????:\nsecretId:\n${configMap['secretId']}\nsecretKey:\n${configMap['secretKey']}\nbucket:\n${configMap['bucket']}\nappId:\n${configMap['appId']}\narea:\n${configMap['area']}\npath:\n${configMap['path']}\ncustomUrl:\n${configMap['customUrl']}\noptions:\n${configMap['options']}');
      } else {
        return showCupertinoAlertDialog(
            context: context, title: '??????', content: '????????????????????????????????????');
      }
    } catch (e) {
      FLog.error(
          className: 'TencentConfigPage',
          methodName: 'checkTencentConfig',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      return showCupertinoAlertDialog(
          context: context, title: "????????????!", content: e.toString());
    }
  }

  Future<File> get localFile async {
    final path = await _localPath;
    String defaultUser = await Global.getUser();
    return File('$path/${defaultUser}_tencent_config.txt');
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<String> readTencentConfig() async {
    try {
      final file = await localFile;
      String contents = await file.readAsString();
      return contents;
    } catch (e) {
      FLog.error(
          className: 'TencentConfigPage',
          methodName: 'readTencentConfig',
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

      var queryTencent = await MySqlUtils.queryTencent(username: defaultUser);
      if (queryTencent == 'Empty') {
        return Fluttertoast.showToast(
            msg: "????????????????????????",
            toastLength: Toast.LENGTH_SHORT,
            timeInSecForIosWeb: 2,
            fontSize: 16.0);
      }
      if (queryTencent == 'Error') {
        return Fluttertoast.showToast(
            msg: "Error",
            toastLength: Toast.LENGTH_SHORT,
            timeInSecForIosWeb: 2,
            fontSize: 16.0);
      }
      if (queryuser['defaultPShost'] == 'tencent') {
        await Global.setPShost('tencent');
        await Global.setShowedPBhost('tencent');
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
        sqlconfig.add('tencent');
        var updateResult = await MySqlUtils.updateUser(content: sqlconfig);
        if (updateResult == 'Success') {
          await Global.setPShost('tencent');
          await Global.setShowedPBhost('tencent');
          eventBus.fire(AlbumRefreshEvent(albumKeepAlive: false));
          eventBus.fire(HomePhotoRefreshEvent(homePhotoKeepAlive: false));
          showToast('?????????????????????????????????');
        } else {
          showToast('?????????????????????');
        }
      }
    } catch (e) {
      FLog.error(
          className: 'TencentConfigPage',
          methodName: '_setdefault',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      showToastWithContext(context, '??????');
    }
  }
}

class TencentConfigModel {
  final String secretId;
  final String secretKey;
  final String bucket;
  final String appId;
  final String area;
  final String path;
  final String customUrl;
  final String options;

  TencentConfigModel(this.secretId, this.secretKey, this.bucket, this.appId,
      this.area, this.path, this.customUrl, this.options);

  Map<String, dynamic> toJson() => {
        'secretId': secretId,
        'secretKey': secretKey,
        'bucket': bucket,
        'appId': appId,
        'area': area,
        'path': path,
        'customUrl': customUrl,
        'options': options,
      };

  static List keysList = [
    'remarkName',
    'secretId',
    'secretKey',
    'bucket',
    'appId',
    'area',
    'path',
    'customUrl',
    'options',
  ];
}
