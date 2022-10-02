import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as f_path;
import 'dart:convert';

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
        child: Column(
          children: [
            TextFormField(
              controller: _hostController,
              decoration: const InputDecoration(
                hintText: '域名(eg:https://imgx.horosama.com )',
              ),
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
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入用户名';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _passwdController,
              decoration: const InputDecoration(
                hintText: '密码',
              ),
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
                hintText: 'Strategy Id',
              ),
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
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
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
    var response = await dio.post(
      fullUrl,
      data: formData,
    );
    token = token + response.data['data']['token'].toString();
    print(token);
    print(response.data);
    print(response.data['data']);
    final hostConfig = HostConfigModel(host, token, strategyId);
    final hostConfigJson = jsonEncode(hostConfig);
    
    final hostConfigFile = await _localFile;
    hostConfigFile.writeAsString(hostConfigJson);
    Navigator.pop(context);
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/host_config.txt');
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
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
