import 'dart:io';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';

import 'package:horopic/pages/loading.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/utils/global.dart';
import 'package:horopic/utils/sql_utils.dart';

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
        title: const Text('又拍云参数配置'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          children: [
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
              controller: _operatorController,
              decoration: const InputDecoration(
                label: Center(child: Text('操作员')),
                hintText: '设定操作员',
              ),
              textAlign: TextAlign.center,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入操作员';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(
                label: Center(child: Text('密码')),
                hintText: '设定密码',
              ),
              textAlign: TextAlign.center,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入密码';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _urlController,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.zero,
                label: Center(child: Text('加速域名')),
                hintText: '例如http://xxx.test.upcdn.net',
              ),
              textAlign: TextAlign.center,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入加速域名';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _optionsController,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.zero,
                label: Center(child: Text('网站后缀')),
                hintText: '例如!/fwfh/500x500',
                hintStyle: TextStyle(fontSize: 13),
              ),
              textAlign: TextAlign.center,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入网站后缀';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _pathController,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.zero,
                label: Center(child: Text('可选: 存储路径')),
                hintText: '例如test/',
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
                          requestCallBack: _saveUpyunConfig(),
                        );
                      });
                }
              },
              child: const Text('提交表单'),
            ),
            ElevatedButton(
              onPressed: () {
                checkUpyunConfig();
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

  Future _saveUpyunConfig() async {
    try {
      String bucket = _bucketController.text;
      String upyunOperator = _operatorController.text;
      String password = _passwordController.text;
      String url = _urlController.text;
      String options = _optionsController.text;
      String path = _pathController.text;

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
      //添加默认用户
      String defaultUser = await Global.getUser();
      sqlconfig.add(defaultUser);

      var queryUpyun = await MySqlUtils.queryUpyun(username: defaultUser);
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
          final upyunConfigFile = await _localFile;
          await upyunConfigFile.writeAsString(upyunConfigJson);
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
      return showCupertinoAlertDialog(
          context: context, title: '错误', content: e.toString());
    }
  }

  void checkUpyunConfig() async {
    try {
      final upyunConfigFile = await _localFile;
      String configData = await upyunConfigFile.readAsString();

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
        showCupertinoAlertDialog(
            context: context,
            title: '通知',
            content:
                '检测通过，您的配置信息为:\nBucket:\n${configMap['bucket']}\nOperator:\n${configMap['operator']}\nPassword:\n${configMap['password']}\nUrl:\n${configMap['url']}\nOptions:\n${configMap['options']}\nPath:\n${configMap['path']}');
      } else {
        showCupertinoAlertDialog(
            context: context, title: '错误', content: '检查失败，请检查配置信息');
        return;
      }
    } catch (e) {
      showCupertinoAlertDialog(
          context: context, title: "检查失败!", content: e.toString());
    }
  }

  Future<File> get _localFile async {
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
            fontSize: 16.0);
      } else if (queryuser['password'] != defaultPassword) {
        return Fluttertoast.showToast(
            msg: "请先登录",
            toastLength: Toast.LENGTH_SHORT,
            timeInSecForIosWeb: 2,
            fontSize: 16.0);
      }

      var queryUpyun = await MySqlUtils.queryUpyun(username: defaultUser);
      if (queryUpyun == 'Empty') {
        return Fluttertoast.showToast(
            msg: "请先配置上传参数",
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
        return Fluttertoast.showToast(
            msg: "已经是默认配置",
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
          showToast('已设置又拍云为默认图床');
        } else {
          showToast('写入数据库失败');
        }
      }
    } catch (e) {
      showToastWithContext(context, '错误');
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
}
