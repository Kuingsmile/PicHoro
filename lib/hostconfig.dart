import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:horopic/AlertDialog.dart';

//import 'package:permission_handler/permission_handler.dart';
//a textfield to get hosts,username,passwd,token and strategy_id
class HostConfig extends StatefulWidget {
  const HostConfig({Key? key}) : super(key: key);

  @override
  _HostConfigState createState() => _HostConfigState();
}

class _HostConfigState extends State<HostConfig> {
  final _formKey = GlobalKey<FormState>();
  final _hostController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwdController = TextEditingController();
  final _strategyIdController = TextEditingController();

  @override
  void dispose() {
    _hostController.dispose();
    _usernameController.dispose();
    _passwdController.dispose();
    _strategyIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('图床参数配置'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          children: [
            TextFormField(
              controller: _hostController,
              decoration: const InputDecoration(
                hintText: '域名(eg:https://imgx.horosama.com )',
              ),
              textAlign: TextAlign.center,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入域名';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(
                hintText: '用户名',
              ),
              textAlign: TextAlign.center,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入用户名';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _passwdController,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: '密码',
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
              controller: _strategyIdController,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.zero,
                hintText: '储存策略Id,可先输入前三项获取完整列表',
              ),
              textAlign: TextAlign.center,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入储存策略Id';
                }
                return null;
              },
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _saveHostConfig();
                }
              },
              child: const Text('提交完整表单'),
            ),
            ElevatedButton(
              onPressed: () {
                _getStrategyId();
              },
              child: const Text('获取储存策略Id列表'),
            ),
            ElevatedButton(
              onPressed: () {
                checkHostConfig();
              },
              child: const Text('检查当前配置'),
            ),
          ],
        ),
      ),
    );
  }

  void _getStrategyId() async {
    final host = _hostController.text;
    String token = 'Bearer ';
    final username = _usernameController.text;
    final passwd = _passwdController.text;
    BaseOptions options = BaseOptions();
    options.headers = {
      "Accept": "application/json",
    };
    Dio dio = Dio(options);
    String fullUrl = '$host/api/v1/tokens';
    FormData formData = FormData.fromMap({
      'email': username,
      'password': passwd,
    });
    try {
      var response = await dio.post(
        fullUrl,
        data: formData,
      );
      if (response.statusCode == 200 && response.data['status'] == true) {
        token = token + response.data['data']['token'].toString();
        String strategiesUrl = '$host/api/v1/strategies';
        BaseOptions strategiesOptions = BaseOptions();
        strategiesOptions.headers = {
          "Accept": "application/json",
          "Authorization": token,
        };
        dio = Dio(strategiesOptions);
        response = await dio.get(strategiesUrl);

        showAlertDialog(
            context: context,
            title: '储存策略Id列表',
            content: response.data['data']['strategies'].toString());
      } else {
        if (response.statusCode == 403) {
          showAlertDialog(context: context, title: '错误', content: '管理员关闭了接口功能');
          return;
        } else if (response.statusCode == 401) {
          showAlertDialog(context: context, title: '错误', content: '授权失败');
          return;
        } else if (response.statusCode == 500) {
          showAlertDialog(context: context, title: '错误', content: '服务器异常');
          return;
        } else if (response.statusCode == 404) {
          showAlertDialog(context: context, title: '错误', content: '接口不存在');
          return;
        }
        if (response.data['status'] == false) {
          showAlertDialog(
              context: context, title: '错误', content: response.data['message']);
          return;
        }
      }
    } catch (e) {
      showAlertDialog(context: context, title: '错误', content: e.toString());
    }
  }

  void _saveHostConfig() async {
    final host = _hostController.text;
    String token = 'Bearer ';
    final username = _usernameController.text;
    final passwd = _passwdController.text;
    final strategyId = _strategyIdController.text;
    BaseOptions options = BaseOptions();
    options.headers = {
      "Accept": "application/json",
    };
    Dio dio = Dio(options);
    String fullUrl = '$host/api/v1/tokens';
    FormData formData = FormData.fromMap({
      'email': username,
      'password': passwd,
    });
    try {
      var response = await dio.post(
        fullUrl,
        data: formData,
      );
      if (response.statusCode == 200 && response.data['status'] == true) {
        token = token + response.data['data']['token'].toString();
        final hostConfig = HostConfigModel(host, token, strategyId);
        final hostConfigJson = jsonEncode(hostConfig);

        final hostConfigFile = await _localFile;
        hostConfigFile.writeAsString(hostConfigJson);
        Navigator.pop(context);
      } else {
        if (response.statusCode == 403) {
          showAlertDialog(context: context, title: '错误', content: '管理员关闭了接口功能');
          return;
        } else if (response.statusCode == 401) {
          showAlertDialog(context: context, title: '错误', content: '授权失败');
          return;
        } else if (response.statusCode == 500) {
          showAlertDialog(context: context, title: '错误', content: '服务器异常');
          return;
        } else if (response.statusCode == 404) {
          showAlertDialog(context: context, title: '错误', content: '接口不存在');
          return;
        }
        if (response.data['status'] == false) {
          showAlertDialog(
              context: context, title: '错误', content: response.data['message']);
          return;
        }
      }
    } catch (e) {
      showAlertDialog(context: context, title: '错误', content: e.toString());
    }
  }

  void checkHostConfig() async {
    try {
    final hostConfigFile = await _localFile;
    
    String configData = await hostConfigFile.readAsString();
    if (configData == "Error") {
      showAlertDialog(context: context, title: "检查失败!", content: "请先配置上传参数.");
      return;
    }
    Map configMap = jsonDecode(configData);
    BaseOptions options = BaseOptions();
    options.headers = {
      "Authorization": configMap["token"],
      "Accept": "application/json",
      "Content-Type": "multipart/form-data",
    };
    String profileUrl = configMap["host"] + "/api/v1/profile";
    Dio dio = Dio(options);
    var response = await dio.get(profileUrl,);
    if (response.statusCode == 200 && response.data['status'] == true) {
      showAlertDialog(context: context, title: "检查成功!", content: "配置正确.");
    } else {
      if (response.statusCode == 403) {
        showAlertDialog(context: context, title: '错误', content: '管理员关闭了接口功能');
        return;
      } else if (response.statusCode == 401) {
        showAlertDialog(context: context, title: '错误', content: '授权失败');
        return;
      } else if (response.statusCode == 500) {
        showAlertDialog(context: context, title: '错误', content: '服务器异常');
        return;
      } else if (response.statusCode == 404) {
        showAlertDialog(context: context, title: '错误', content: '接口不存在');
        return;
      }
      if (response.data['status'] == false) {
        showAlertDialog(
            context: context, title: '错误', content: response.data['message']);
        return;
      }
    }
  }
  catch (e) {
    showAlertDialog(context: context, title: "检查失败!", content: e.toString());
  }
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/host_config.txt');
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

    Future<String> readHostConfig() async {
    try {
      final file = await _localFile;
      String contents = await file.readAsString();
      return contents;
    } catch (e) {
      return "Error";
    }
  }
}

class HostConfigModel {
  final String host;
  final String token;
  final String strategyId;

  HostConfigModel(this.host, this.token, this.strategyId);

  Map<String, dynamic> toJson() => {
        'host': host,
        'token': token,
        'strategy_id': strategyId,
      };
}
