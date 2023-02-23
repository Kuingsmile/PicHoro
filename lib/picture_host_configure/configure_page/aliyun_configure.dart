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
        title: titleText(
          '阿里云参数配置',
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
                hintText: '设定KeyId',
              ),
              textAlign: TextAlign.center,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入accessKeyId';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _keySecretController,
              decoration: const InputDecoration(
                label: Center(child: Text('accessKeySecret')),
                hintText: '设定KeySecret',
              ),
              textAlign: TextAlign.center,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入accessKeySecret';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _bucketController,
              decoration: const InputDecoration(
                label: Center(child: Text('bucket')),
                hintText: '设定bucket',
              ),
              textAlign: TextAlign.center,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入bucket';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _areaController,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.zero,
                label: Center(child: Text('存储区域')),
                hintText: '例如oss-cn-beijing',
              ),
              textAlign: TextAlign.center,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入存储区域';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _pathController,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.zero,
                label: Center(child: Text('可选:存储路径')),
                hintText: '例如test/',
                hintStyle: TextStyle(fontSize: 13),
              ),
              textAlign: TextAlign.center,
            ),
            TextFormField(
              controller: _customUrlController,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.zero,
                label: Center(child: Text('可选:自定义域名')),
                hintText: '例如https://test.com',
                hintStyle: TextStyle(fontSize: 13),
              ),
              textAlign: TextAlign.center,
            ),
            TextFormField(
              controller: _optionsController,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.zero,
                label: Center(child: Text('可选:网站后缀')),
                hintText: '例如?x-oss-process=xxx',
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
                          loadingText: "配置中...",
                          requestCallBack: _saveAliyunConfig(),
                        );
                      });
                }
              },
              child: titleText('提交表单', fontsize: null),
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
                        loadingText: "检查中...",
                        requestCallBack: checkAliyunConfig(),
                      );
                    });
              },
              child: titleText('检查当前配置', fontsize: null),
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
              child: titleText('设置备用配置', fontsize: null),
            )),
            ListTile(
                title: ElevatedButton(
              onPressed: () {
                _setdefault();
              },
              child: titleText('设为默认图床', fontsize: null),
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
      //格式化路径为以/结尾，不以/开头
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
      //格式化自定义域名，不以/结尾，以http(s)://开头
      if (customUrl.isEmpty) {
        customUrl = 'None';
      } else if (!customUrl.startsWith('http') &&
          !customUrl.startsWith('https')) {
        customUrl = 'http://$customUrl';
      }
      if (customUrl.endsWith('/')) {
        customUrl = customUrl.substring(0, customUrl.length - 1);
      }
      //格式化网站后缀，以?开头
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
      //添加默认用户
      String defaultUser = await Global.getUser();
      sqlconfig.add(defaultUser);

      var queryAliyun = await MySqlUtils.queryAliyun(username: defaultUser);
      var queryuser = await MySqlUtils.queryUser(username: defaultUser);

      if (queryuser == 'Empty') {
        return showCupertinoAlertDialog(
            context: context, title: '错误', content: '用户不存在,请先登录');
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
        //阿里默认的content-type是application/octet-stream，这里改成image/xxx
        'x-oss-content-type':
            'image/${my_path.extension(assetFilePath).replaceFirst('.', '')}',
        'file': await MultipartFile.fromFile(assetFilePath, filename: key),
      });

      BaseOptions baseoptions = setBaseOptions();
      String contentLength = await assetFile.length().then((value) {
        return value.toString();
      });
      baseoptions.headers = {
        'Host': host,
        'Content-Type': Global.multipartString,
        'Content-Length': contentLength,
      };
      Dio dio = Dio(baseoptions);
      var response = await dio.post(
        'https://$host',
        data: formData,
      );
      //阿里默认返回204
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
              context: context, title: '成功', content: '配置成功');
        } else {
          return showCupertinoAlertDialog(
              context: context, title: '错误', content: '数据库错误');
        }
      } else {
        return showCupertinoAlertDialog(
            context: context, title: '错误', content: '验证失败');
      }
    } catch (e) {
      FLog.error(
          className: 'AliyunConfigPage',
          methodName: 'saveAliyunConfig',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      return showCupertinoAlertDialog(
          context: context, title: '错误', content: e.toString());
    }
  }

  checkAliyunConfig() async {
    try {
      final aliyunConfigFile = await localFile;
      String configData = await aliyunConfigFile.readAsString();

      if (configData == "Error") {
        showCupertinoAlertDialog(
            context: context, title: "检查失败!", content: "请先配置上传参数.");
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
        //阿里默认的content-type是application/octet-stream，这里改成image/xxx
        'x-oss-content-type':
            'image/${my_path.extension(assetFilePath).replaceFirst('.', '')}',
        'file': await MultipartFile.fromFile(assetFilePath, filename: key),
      });
      BaseOptions baseoptions = setBaseOptions();
      String contentLength = await assetFile.length().then((value) {
        return value.toString();
      });
      baseoptions.headers = {
        'Host': host,
        'Content-Type': Global.multipartString,
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
            title: '通知',
            content:
                '检测通过，您的配置信息为:\n\nAccessKeyId:\n${configMap['keyId']}\nAccessKeySecret:\n${configMap['keySecret']}\nBucket:\n${configMap['bucket']}\nArea:\n${configMap['area']}\nPath:\n${configMap['path']}\nCustomUrl:\n${configMap['customUrl']}\nOptions:\n${configMap['options']}');
      } else {
        return showCupertinoAlertDialog(
            context: context, title: '错误', content: '检查失败，请检查配置信息');
      }
    } catch (e) {
      FLog.error(
          className: 'AliyunConfigPage',
          methodName: 'checkAliyunConfig',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      return showCupertinoAlertDialog(
          context: context, title: "检查失败!", content: e.toString());
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
            msg: "请先注册用户",
            toastLength: Toast.LENGTH_SHORT,
            timeInSecForIosWeb: 2,
            fontSize: 16.0);
      } else if (queryuser['password'] != defaultPassword) {
        return Fluttertoast.showToast(
            msg: "请先登录",
            toastLength: Toast.LENGTH_SHORT,
            timeInSecForIosWeb: 2,
            fontSize: 16.0);
      }

      var queryAliyun = await MySqlUtils.queryAliyun(username: defaultUser);
      if (queryAliyun == 'Empty') {
        return Fluttertoast.showToast(
            msg: "请先配置上传参数",
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
            msg: "已经是默认配置",
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
          showToast('已设置阿里云为默认图床');
          eventBus.fire(HomePhotoRefreshEvent(homePhotoKeepAlive: false));
          eventBus.fire(AlbumRefreshEvent(albumKeepAlive: false));
        } else {
          showToast('写入数据库失败');
        }
      }
    } catch (e) {
      FLog.error(
          className: 'AliyunConfigPage',
          methodName: '_setdefault',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      showToastWithContext(context, '错误');
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
