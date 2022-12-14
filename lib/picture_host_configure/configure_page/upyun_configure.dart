import 'dart:io';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:f_logs/f_logs.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fluro/fluro.dart';
import 'package:path_provider/path_provider.dart';

import 'package:horopic/router/application.dart';
import 'package:horopic/pages/loading.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/utils/global.dart';
import 'package:horopic/utils/sql_utils.dart';
import 'package:horopic/utils/event_bus_utils.dart';
import 'package:horopic/picture_host_manage/manage_api/upyun_manage_api.dart';

class UpyunConfig extends StatefulWidget {
  const UpyunConfig({Key? key}) : super(key: key);

  @override
  UpyunConfigState createState() => UpyunConfigState();
}

class UpyunConfigState extends State<UpyunConfig> {
  final _formKey = GlobalKey<FormState>();

  final _bucketController = TextEditingController();
  final _operatorController = TextEditingController();
  final _passwordController = TextEditingController();
  final _urlController = TextEditingController();
  final _optionsController = TextEditingController();
  final _pathController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initConfig();
  }

  _initConfig() async {
    try {
      Map configMap = await UpyunManageAPI.getConfigMap();
      _bucketController.text = configMap['bucket'];
      _operatorController.text = configMap['operator'];
      _passwordController.text = configMap['password'];
      _urlController.text = configMap['url'];
      if (configMap['options'] != 'None' || 
          configMap['options'].trim() != '') {
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
          className: 'UpyunConfigState',
          methodName: '_initCongfig',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
    }
  }

  @override
  void dispose() {
    _bucketController.dispose();
    _operatorController.dispose();
    _passwordController.dispose();
    _urlController.dispose();
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
                  context, '/configureStorePage?psHost=upyun',
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
              controller: _operatorController,
              decoration: const InputDecoration(
                label: Center(child: Text('?????????')),
                hintText: '???????????????',
              ),
              textAlign: TextAlign.center,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '??????????????????';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(
                label: Center(child: Text('??????')),
                hintText: '????????????',
              ),
              textAlign: TextAlign.center,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '???????????????';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _urlController,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.zero,
                label: Center(child: Text('????????????')),
                hintText: '??????http://xxx.test.upcdn.net',
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
                label: Center(child: Text('?????????????????????')),
                hintText: '??????!/fwfh/500x500',
                hintStyle: TextStyle(fontSize: 13),
              ),
              textAlign: TextAlign.center,
            ),
            TextFormField(
              controller: _pathController,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.zero,
                label: Center(child: Text('??????: ????????????')),
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
                          requestCallBack: _saveUpyunConfig(),
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
                        requestCallBack: checkUpyunConfig(),
                      );
                    });
              },
              child: titleText('??????????????????',fontsize: null),
            )),
            ListTile(
                title: ElevatedButton(
              onPressed: () async {
                await Application.router.navigateTo(
                    context, '/configureStorePage?psHost=upyun',
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

  Future _saveUpyunConfig() async {
    try {
      String bucket = _bucketController.text;
      String upyunOperator = _operatorController.text;
      String password = _passwordController.text;
      String url = _urlController.text;
      String options = _optionsController.text;
      String path = _pathController.text;

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
      if (!url.startsWith('http') && !url.startsWith('https')) {
        url = 'http://$url';
      }
      if (url.endsWith('/')) {
        url = url.substring(0, url.length - 1);
      }

      List sqlconfig = [];
      sqlconfig.add(bucket);
      sqlconfig.add(upyunOperator);
      sqlconfig.add(password);
      sqlconfig.add(url);
      sqlconfig.add(options);
      sqlconfig.add(path);
      //??????????????????
      String defaultUser = await Global.getUser();
      sqlconfig.add(defaultUser);

      var queryUpyun = await MySqlUtils.queryUpyun(username: defaultUser);
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
      String host = 'http://v0.api.upyun.com';
      String urlpath = '';

      if (path != 'None') {
        urlpath = '/$path$key';
      } else {
        urlpath = '/$key';
      }
      String date = HttpDate.format(DateTime.now());
      String assetFileMd5 = await assetFile.readAsBytes().then((value) {
        return md5.convert(value).toString();
      });
      Map<String, dynamic> uploadPolicy = {
        'bucket': bucket,
        'save-key': urlpath,
        'expiration': DateTime.now().millisecondsSinceEpoch + 1800000,
        'date': date,
        'content-md5': assetFileMd5,
      };
      String base64Policy =
          base64.encode(utf8.encode(json.encode(uploadPolicy)));
      String stringToSign = 'POST&/$bucket&$date&$base64Policy&$assetFileMd5';
      String passwordMd5 = md5.convert(utf8.encode(password)).toString();
      String signature = base64.encode(Hmac(sha1, utf8.encode(passwordMd5))
          .convert(utf8.encode(stringToSign))
          .bytes);
      String authorization = 'UPYUN $upyunOperator:$signature';
      FormData formData = FormData.fromMap({
        'authorization': authorization,
        'policy': base64Policy,
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
        'Host': 'v0.api.upyun.com',
        'Content-Type':
            'multipart/form-data; boundary=----WebKitFormBoundary7MA4YWxkTrZu0gW',
        'Content-Length': contentLength,
        'Date': date,
        'Authorization': authorization,
        'Content-MD5': assetFileMd5,
      };
      Dio dio = Dio(baseoptions);
      var response = await dio.post(
        '$host/$bucket',
        data: formData,
      );

      if (response.statusCode == 200) {
        var sqlResult = '';

        if (queryUpyun == 'Empty') {
          sqlResult = await MySqlUtils.insertUpyun(content: sqlconfig);
        } else {
          sqlResult = await MySqlUtils.updateUpyun(content: sqlconfig);
        }

        if (sqlResult == "Success") {
          final upyunConfig = UpyunConfigModel(
              bucket, upyunOperator, password, url, options, path);
          final upyunConfigJson = jsonEncode(upyunConfig);
          final upyunConfigFile = await localFile;
          await upyunConfigFile.writeAsString(upyunConfigJson);
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
          className: 'UpyunConfigPageState',
          methodName: 'saveConfig',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      return showCupertinoAlertDialog(
          context: context, title: '??????', content: e.toString());
    }
  }

  checkUpyunConfig() async {
    try {
      final upyunConfigFile = await localFile;
      String configData = await upyunConfigFile.readAsString();

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
      String host = 'http://v0.api.upyun.com';
      String urlpath = '';
      if (configMap['path'] != 'None') {
        urlpath = '${configMap['path']}$key';
      } else {
        urlpath = key;
      }
      String date = HttpDate.format(DateTime.now());
      String assetFileMd5 = await assetFile.readAsBytes().then((value) {
        return md5.convert(value).toString();
      });
      Map<String, dynamic> uploadPolicy = {
        'bucket': configMap['bucket'],
        'save-key': urlpath,
        'expiration': DateTime.now().millisecondsSinceEpoch + 1800000,
        'date': date,
        'content-md5': assetFileMd5,
      };
      String base64Policy =
          base64.encode(utf8.encode(json.encode(uploadPolicy)));
      String stringToSign =
          "POST&/${configMap['bucket']}&$date&$base64Policy&$assetFileMd5";
      String passwordMd5 =
          md5.convert(utf8.encode(configMap['password'])).toString();
      String signature = base64.encode(Hmac(sha1, utf8.encode(passwordMd5))
          .convert(utf8.encode(stringToSign))
          .bytes);
      String authorization = 'UPYUN ${configMap['operator']}:$signature';
      FormData formData = FormData.fromMap({
        'authorization': authorization,
        'policy': base64Policy,
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
        'Host': 'v0.api.upyun.com',
        'Content-Type':
            'multipart/form-data; boundary=----WebKitFormBoundary7MA4YWxkTrZu0gW',
        'Content-Length': contentLength,
        'Date': date,
        'Authorization': authorization,
        'Content-MD5': assetFileMd5,
      };
      Dio dio = Dio(baseoptions);
      var response = await dio.post(
        '$host/${configMap['bucket']}',
        data: formData,
      );

      if (response.statusCode == 200) {
        return showCupertinoAlertDialog(
            context: context,
            title: '??????',
            content:
                '????????????????????????????????????:\nBucket:\n${configMap['bucket']}\nOperator:\n${configMap['operator']}\nPassword:\n${configMap['password']}\nUrl:\n${configMap['url']}\nOptions:\n${configMap['options']}\nPath:\n${configMap['path']}');
      } else {
        return showCupertinoAlertDialog(
            context: context, title: '??????', content: '????????????????????????????????????');
      }
    } catch (e) {
      FLog.error(
          className: 'UpyunConfigPageState',
          methodName: 'checkUpyunConfig',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      return showCupertinoAlertDialog(
          context: context, title: "????????????!", content: e.toString());
    }
  }

  Future<File> get localFile async {
    final path = await _localPath;
    String defaultUser = await Global.getUser();
    return File('$path/${defaultUser}_upyun_config.txt');
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<String> readUpyunConfig() async {
    try {
      final file = await localFile;
      String contents = await file.readAsString();
      return contents;
    } catch (e) {
      FLog.error(
          className: 'UpyunConfigPageState',
          methodName: 'readUpyunConfig',
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

      var queryUpyun = await MySqlUtils.queryUpyun(username: defaultUser);
      if (queryUpyun == 'Empty') {
        return Fluttertoast.showToast(
            msg: "????????????????????????",
            toastLength: Toast.LENGTH_SHORT,
            timeInSecForIosWeb: 2,
            fontSize: 16.0);
      }
      if (queryUpyun == 'Error') {
        return Fluttertoast.showToast(
            msg: "Error",
            toastLength: Toast.LENGTH_SHORT,
            timeInSecForIosWeb: 2,
            fontSize: 16.0);
      }
      if (queryuser['defaultPShost'] == 'upyun') {
        await Global.setPShost('upyun');
        await Global.setShowedPBhost('upyun');
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
        sqlconfig.add('upyun');

        var updateResult = await MySqlUtils.updateUser(content: sqlconfig);
        if (updateResult == 'Success') {
          await Global.setPShost('upyun');
          await Global.setShowedPBhost('upyun');
          eventBus.fire(AlbumRefreshEvent(albumKeepAlive: false));
          eventBus.fire(HomePhotoRefreshEvent(homePhotoKeepAlive: false));
          showToast('?????????????????????????????????');
        } else {
          showToast('?????????????????????');
        }
      }
    } catch (e) {
      FLog.error(
          className: 'UpyunConfigPageState',
          methodName: '_setdefault',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      showToastWithContext(context, '??????');
    }
  }
}

class UpyunConfigModel {
  final String bucket;
  final String upyunoperator;
  final String password;
  final String url;
  final String options;
  final String path;

  UpyunConfigModel(this.bucket, this.upyunoperator, this.password, this.url,
      this.options, this.path);

  Map<String, dynamic> toJson() => {
        'bucket': bucket,
        'operator': upyunoperator,
        'password': password,
        'url': url,
        'options': options,
        'path': path,
      };

  static List keysList = [
    'remarkName',
    'bucket',
    'operator',
    'password',
    'url',
    'options',
    'path',
  ];
}
