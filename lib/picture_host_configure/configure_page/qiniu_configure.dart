import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:f_logs/f_logs.dart';
import 'package:fluro/fluro.dart';
import 'package:qiniu_flutter_sdk/qiniu_flutter_sdk.dart';
import 'package:path_provider/path_provider.dart';

import 'package:horopic/router/application.dart';
import 'package:horopic/pages/loading.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/utils/sql_utils.dart';
import 'package:horopic/utils/global.dart';
import 'package:horopic/utils/event_bus_utils.dart';
import 'package:horopic/api/qiniu_api.dart';
import 'package:horopic/picture_host_manage/manage_api/qiniu_manage_api.dart';

class QiniuConfig extends StatefulWidget {
  const QiniuConfig({Key? key}) : super(key: key);

  @override
  QiniuConfigState createState() => QiniuConfigState();
}

class QiniuConfigState extends State<QiniuConfig> {
  final _formKey = GlobalKey<FormState>();

  final _accessKeyController = TextEditingController();
  final _secretKeyController = TextEditingController();
  final _bucketController = TextEditingController();
  final _urlController = TextEditingController();
  final _areaController = TextEditingController();
  final _optionsController = TextEditingController();
  final _pathController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initConfig();
  }

  _initConfig() async {
    try {
      Map configMap = await QiniuManageAPI.getConfigMap();
      _accessKeyController.text = configMap['accessKey'];
      _secretKeyController.text = configMap['secretKey'];
      _bucketController.text = configMap['bucket'];
      _urlController.text = configMap['url'];
      _areaController.text = configMap['area'];
      if (configMap['options'] != 'None') {
        _optionsController.text = configMap['options'];
      } else {
        _optionsController.clear();
      }
      if (configMap['path'] != 'None') {
        _pathController.text = configMap['path'];
      } else {
        _pathController.clear();
      }
    } catch (e) {
      FLog.error(
          className: 'QiniuConfigState',
          methodName: '_initConfig',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
    }
  }

  @override
  void dispose() {
    _accessKeyController.dispose();
    _secretKeyController.dispose();
    _bucketController.dispose();
    _urlController.dispose();
    _areaController.dispose();
    _optionsController.dispose();
    _pathController.dispose();

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
                  context, '/configureStorePage?psHost=qiniu',
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
              controller: _accessKeyController,
              decoration: const InputDecoration(
                label: Center(child: Text('accessKey')),
                hintText: '??????accessKey',
              ),
              textAlign: TextAlign.center,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '?????????accessKey';
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
              controller: _urlController,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.zero,
                label: Center(child: Text('????????????')),
                hintText: '??????:https://xxx.yyy.gld.clouddn.com',
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
              controller: _areaController,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.zero,
                label: Center(child: Text('????????????')),
                hintText: '??????????????????',
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
              controller: _optionsController,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.zero,
                label: Center(child: Text('??????:????????????')),
                hintText: '???????imageslim',
                hintStyle: TextStyle(fontSize: 13),
              ),
              textAlign: TextAlign.center,
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
                          requestCallBack: _saveQiniuConfig(),
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
                        requestCallBack: checkQiniuConfig(),
                      );
                    });
              },
              child: titleText('??????????????????',fontsize: null),
            )),
            ListTile(
                title: ElevatedButton(
              onPressed: () async {
                await Application.router.navigateTo(
                    context, '/configureStorePage?psHost=qiniu',
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

  Future _saveQiniuConfig() async {
    try {
      String accessKey = _accessKeyController.text;
      String secretKey = _secretKeyController.text;
      String bucket = _bucketController.text;
      String url = _urlController.text;
      String area = _areaController.text;
      String options = '';

      if (_optionsController.text.isNotEmpty) {
        options = _optionsController.text;
        if (!options.startsWith('?')) {
          options = '?$options';
        }
      } else {
        options = 'None';
      }

      if (!url.startsWith('http') && !url.startsWith('https')) {
        url = 'http://$url';
      }
      if (url.endsWith('/')) {
        url = url.substring(0, url.length - 1);
      }

      String path = '';
      if (_pathController.text.isNotEmpty &&
          _pathController.text.replaceAll(' ', '').isNotEmpty) {
        path = _pathController.text;
        if (path.startsWith('/')) {
          path = path.substring(1);
        }
        if (!path.endsWith('/')) {
          path = '$path/';
        }
      } else {
        path = 'None';
      }
      List sqlconfig = [];
      sqlconfig.add(accessKey);
      sqlconfig.add(secretKey);
      sqlconfig.add(bucket);
      sqlconfig.add(url);
      sqlconfig.add(area);
      sqlconfig.add(options);
      sqlconfig.add(path);
      //??????????????????
      String defaultUser = await Global.getUser();
      sqlconfig.add(defaultUser);
      var queryQiniu = await MySqlUtils.queryQiniu(username: defaultUser);
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

      String urlSafeBase64EncodePutPolicy =
          QiniuImageUploadUtils.geturlSafeBase64EncodePutPolicy(
              bucket, key, path);
      String uploadToken = QiniuImageUploadUtils.getUploadToken(
          accessKey, secretKey, urlSafeBase64EncodePutPolicy);
      Storage storage = Storage(
          config: Config(
        retryLimit: 5,
      ));
      PutResponse putresult =
          await storage.putFile(File(assetFilePath), uploadToken);

      if (putresult.key == key || putresult.key == '$path$key') {
        var sqlResult = '';

        if (queryQiniu == 'Empty') {
          sqlResult = await MySqlUtils.insertQiniu(content: sqlconfig);
        } else {
          sqlResult = await MySqlUtils.updateQiniu(content: sqlconfig);
        }

        if (sqlResult == "Success") {
          final qiniuConfig = QiniuConfigModel(
              accessKey, secretKey, bucket, url, area, options, path);
          final qiniuConfigJson = jsonEncode(qiniuConfig);
          final qiniuConfigFile = await localFile;
          await qiniuConfigFile.writeAsString(qiniuConfigJson);
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
          className: 'QiniuConfigPage',
          methodName: '_saveQiniuConfig',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      return showCupertinoAlertDialog(
          context: context, title: '??????', content: e.toString());
    }
  }

  checkQiniuConfig() async {
    try {
      final qiniuConfigFile = await localFile;
      String configData = await qiniuConfigFile.readAsString();

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
      String qiniupath = configMap['path'];

      if (qiniupath != 'None') {
        if (qiniupath.startsWith('/')) {
          qiniupath = qiniupath.substring(1);
        }
        if (!qiniupath.endsWith('/')) {
          qiniupath = '$qiniupath/';
        }
      }
      String urlSafeBase64EncodePutPolicy =
          QiniuImageUploadUtils.geturlSafeBase64EncodePutPolicy(
              configMap['bucket'], key, qiniupath);
      String uploadToken = QiniuImageUploadUtils.getUploadToken(
          configMap['accessKey'],
          configMap['secretKey'],
          urlSafeBase64EncodePutPolicy);
      Storage storage = Storage(
          config: Config(
        retryLimit: 5,
      ));
      PutResponse putresult =
          await storage.putFile(File(assetFilePath), uploadToken);

      if (putresult.key == key || putresult.key == '${configMap['path']}$key') {
        return showCupertinoAlertDialog(
            context: context,
            title: '??????',
            content:
                '????????????????????????????????????:\naccessKey:\n${configMap['accessKey']}\nsecretKey:\n${configMap['secretKey']}\nbucket:\n${configMap['bucket']}\nurl:\n${configMap['url']}\narea:\n${configMap['area']}\noptions:\n${configMap['options']}\npath:\n${configMap['path']}');
      } else {
        return showCupertinoAlertDialog(
            context: context, title: '??????', content: '????????????????????????????????????');
      }
    } catch (e) {
      FLog.error(
          className: 'QiniuConfigPage',
          methodName: 'checkQiniuConfig',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      return showCupertinoAlertDialog(
          context: context, title: "????????????!", content: e.toString());
    }
  }

  Future<File> get localFile async {
    final path = await _localPath;
    String defaultUser = await Global.getUser();
    return File('$path/${defaultUser}_qiniu_config.txt');
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<String> readQiniuConfig() async {
    try {
      final file = await localFile;
      String contents = await file.readAsString();
      return contents;
    } catch (e) {
      FLog.error(
          className: 'QiniuConfigPage',
          methodName: 'readQiniuConfig',
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

      var queryQiniu = await MySqlUtils.queryQiniu(username: defaultUser);
      if (queryQiniu == 'Empty') {
        return Fluttertoast.showToast(
            msg: "????????????????????????",
            toastLength: Toast.LENGTH_SHORT,
            timeInSecForIosWeb: 2,
            fontSize: 16.0);
      }
      if (queryQiniu == 'Error') {
        return Fluttertoast.showToast(
            msg: "Error",
            toastLength: Toast.LENGTH_SHORT,
            timeInSecForIosWeb: 2,
            fontSize: 16.0);
      }
      if (queryuser['defaultPShost'] == 'qiniu') {
        await Global.setPShost('qiniu');
        await Global.setShowedPBhost('qiniu');
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
        sqlconfig.add('qiniu');

        var updateResult = await MySqlUtils.updateUser(content: sqlconfig);
        if (updateResult == 'Success') {
          await Global.setPShost('qiniu');
          await Global.setShowedPBhost('qiniu');
          eventBus.fire(AlbumRefreshEvent(albumKeepAlive: false));
          eventBus.fire(HomePhotoRefreshEvent(homePhotoKeepAlive: false));
          showToast('?????????????????????????????????');
        } else {
          showToast('?????????????????????');
        }
      }
    } catch (e) {
      FLog.error(
          className: 'QiniuConfigPage',
          methodName: '_setdefault',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      showToastWithContext(context, '??????');
    }
  }
}

class QiniuConfigModel {
  final String accessKey;
  final String secretKey;
  final String bucket;
  final String url;
  final String area;
  final String options;
  final String path;

  QiniuConfigModel(this.accessKey, this.secretKey, this.bucket, this.url,
      this.area, this.options, this.path);

  Map<String, dynamic> toJson() => {
        'accessKey': accessKey,
        'secretKey': secretKey,
        'bucket': bucket,
        'url': url,
        'area': area,
        'options': options,
        'path': path,
      };

  static List keysList = [
    'remarkName',
    'accessKey',
    'secretKey',
    'bucket',
    'url',
    'area',
    'options',
    'path',
  ];
}
