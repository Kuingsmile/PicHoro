import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:horopic/utils/common_func.dart';
import 'package:horopic/pages/loading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:horopic/utils/sqlUtils.dart';
import 'package:horopic/utils/global.dart';
import 'package:horopic/api/tencent.dart';

import 'package:crypto/crypto.dart';

class TencentConfig extends StatefulWidget {
  const TencentConfig({Key? key}) : super(key: key);

  @override
  _TencentConfigState createState() => _TencentConfigState();
}

class _TencentConfigState extends State<TencentConfig> {
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
        title: const Text('腾讯云参数配置'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          children: [
            TextFormField(
              controller: _secretIdController,
              decoration: const InputDecoration(
                label: Center(child: Text('secretId')),
                hintText: '设定secretId',
              ),
              textAlign: TextAlign.center,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入secretId';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _secretKeyController,
              decoration: const InputDecoration(
                label: Center(child: Text('secretKey')),
                hintText: '设定secretKey',
              ),
              textAlign: TextAlign.center,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入secretKey';
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
              controller: _appIdController,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.zero,
                label: Center(child: Text('appId')),
                hintText: '例如1234567890',
              ),
              textAlign: TextAlign.center,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入appId';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _areaController,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.zero,
                label: Center(child: Text('存储区域')),
                hintText: '例如ap-nanjing',
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
                hintText: '例如?imageMogr2',
                hintStyle: TextStyle(fontSize: 13),
              ),
              textAlign: TextAlign.center,
            ),
            ElevatedButton(
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
                          requestCallBack: _saveTencentConfig(),
                        );
                      });
                }
              },
              child: const Text('提交表单'),
            ),
            ElevatedButton(
              onPressed: () {
                checkTencentConfig();
              },
              child: const Text('检查当前配置'),
            ),
            ElevatedButton(
              onPressed: () {
                _setdefault();
              },
              child: const Text('设为默认图床'),
            ),
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
      //格式化路径为以/结尾，不以/开头
      if (path.isEmpty) {
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
      sqlconfig.add(secretId);
      sqlconfig.add(secretKey);
      sqlconfig.add(bucket);
      sqlconfig.add(appId);
      sqlconfig.add(area);
      sqlconfig.add(path);
      sqlconfig.add(customUrl);
      sqlconfig.add(options);
      //添加默认用户
      String defaultUser = await Global.getUser();
      sqlconfig.add(defaultUser);

      var queryTencent = await MySqlUtils.queryTencent(username: defaultUser);
      var queryuser = await MySqlUtils.queryUser(username: defaultUser);

      if (queryuser == 'Empty') {
        return showAlertDialog(
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
      //policy中的字段，除了bucket，其它的都要在formdata中添加
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
        //连接服务器超时时间，单位是毫秒.
        connectTimeout: 30000,
        //响应超时时间。
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
      //腾讯默认返回204
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
          final tencentConfigFile = await _localFile;
          await tencentConfigFile.writeAsString(tencentConfigJson);
          return showAlertDialog(
              context: context, title: '成功', content: '配置成功');
        } else {
          return showAlertDialog(
              context: context, title: '错误', content: '数据库错误');
        }
      } else {
        return showAlertDialog(context: context, title: '错误', content: '验证失败');
      }
    } catch (e) {
      return showAlertDialog(
          context: context, title: '错误', content: e.toString());
    }
  }

  void checkTencentConfig() async {
    try {
      final tencentConfigFile = await _localFile;
      String configData = await tencentConfigFile.readAsString();

      if (configData == "Error") {
        showAlertDialog(context: context, title: "检查失败!", content: "请先配置上传参数.");
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
      //policy中的字段，除了bucket，其它的都要在formdata中添加
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
        //连接服务器超时时间，单位是毫秒.
        connectTimeout: 30000,
        //响应超时时间。
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
        showAlertDialog(
            context: context,
            title: '通知',
            content:
                '检测通过，您的配置信息为:\nsecretId:\n${configMap['secretId']}\nsecretKey:\n${configMap['secretKey']}\nbucket:\n${configMap['bucket']}\nappId:\n${configMap['appId']}\narea:\n${configMap['area']}\npath:\n${configMap['path']}\ncustomUrl:\n${configMap['customUrl']}\noptions:\n${configMap['options']}');
      } else {
        showAlertDialog(context: context, title: '错误', content: '检查失败，请检查配置信息');
        return;
      }
    } catch (e) {
      showAlertDialog(context: context, title: "检查失败!", content: e.toString());
    }
  }

  Future<File> get _localFile async {
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
      final file = await _localFile;
      String contents = await file.readAsString();
      return contents;
    } catch (e) {
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
            backgroundColor: Theme.of(context).brightness == Brightness.light
                ? Colors.black
                : Colors.white,
            textColor: Theme.of(context).brightness == Brightness.light
                ? Colors.white
                : Colors.black,
            fontSize: 16.0);
      } else if (queryuser['password'] != defaultPassword) {
        return Fluttertoast.showToast(
            msg: "请先登录",
            toastLength: Toast.LENGTH_SHORT,
            timeInSecForIosWeb: 2,
            backgroundColor: Theme.of(context).brightness == Brightness.light
                ? Colors.black
                : Colors.white,
            textColor: Theme.of(context).brightness == Brightness.light
                ? Colors.white
                : Colors.black,
            fontSize: 16.0);
      }

      var queryTencent = await MySqlUtils.queryTencent(username: defaultUser);
      if (queryTencent == 'Empty') {
        return Fluttertoast.showToast(
            msg: "请先配置上传参数",
            toastLength: Toast.LENGTH_SHORT,
            timeInSecForIosWeb: 2,
            backgroundColor: Theme.of(context).brightness == Brightness.light
                ? Colors.black
                : Colors.white,
            textColor: Theme.of(context).brightness == Brightness.light
                ? Colors.white
                : Colors.black,
            fontSize: 16.0);
      }
      if (queryTencent == 'Error') {
        return Fluttertoast.showToast(
            msg: "Error",
            toastLength: Toast.LENGTH_SHORT,
            timeInSecForIosWeb: 2,
            backgroundColor: Theme.of(context).brightness == Brightness.light
                ? Colors.black
                : Colors.white,
            textColor: Theme.of(context).brightness == Brightness.light
                ? Colors.white
                : Colors.black,
            fontSize: 16.0);
      }
      if (queryuser['defaultPShost'] == 'tencent') {
        await Global.setPShost('tencent');
        await Global.setShowedPBhost('tencent');
        return Fluttertoast.showToast(
            msg: "已经是默认配置",
            toastLength: Toast.LENGTH_SHORT,
            timeInSecForIosWeb: 2,
            backgroundColor: Theme.of(context).brightness == Brightness.light
                ? Colors.black
                : Colors.white,
            textColor: Theme.of(context).brightness == Brightness.light
                ? Colors.white
                : Colors.black,
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
          Fluttertoast.showToast(
              msg: "已设置腾讯云为默认图床",
              toastLength: Toast.LENGTH_SHORT,
              timeInSecForIosWeb: 2,
              backgroundColor: Theme.of(context).brightness == Brightness.light
                  ? Colors.black
                  : Colors.white,
              textColor: Theme.of(context).brightness == Brightness.light
                  ? Colors.white
                  : Colors.black,
              fontSize: 16.0);
        } else {
          Fluttertoast.showToast(
              msg: "写入数据库失败",
              toastLength: Toast.LENGTH_SHORT,
              timeInSecForIosWeb: 2,
              backgroundColor: Theme.of(context).brightness == Brightness.light
                  ? Colors.black
                  : Colors.white,
              textColor: Theme.of(context).brightness == Brightness.light
                  ? Colors.white
                  : Colors.black,
              fontSize: 16.0);
        }
      }
    } catch (e) {
      Fluttertoast.showToast(
          msg: "Error",
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 2,
          backgroundColor: Theme.of(context).brightness == Brightness.light
              ? Colors.black
              : Colors.white,
          textColor: Theme.of(context).brightness == Brightness.light
              ? Colors.white
              : Colors.black,
          fontSize: 16.0);
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
}
