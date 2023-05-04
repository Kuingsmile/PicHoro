import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:f_logs/f_logs.dart';
import 'package:fluro/fluro.dart';
import 'package:path_provider/path_provider.dart';

import 'package:horopic/router/application.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/pages/loading.dart';
import 'package:horopic/utils/global.dart';
import 'package:horopic/utils/event_bus_utils.dart';
import 'package:horopic/picture_host_manage/manage_api/webdav_manage_api.dart';
import 'package:webdav_client/webdav_client.dart' as webdav;

class WebdavConfig extends StatefulWidget {
  const WebdavConfig({Key? key}) : super(key: key);

  @override
  WebdavConfigState createState() => WebdavConfigState();
}

class WebdavConfigState extends State<WebdavConfig> {
  final _formKey = GlobalKey<FormState>();
  final _hostController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwdController = TextEditingController();
  final _uploadPathController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initConfig();
  }

  _initConfig() async {
    try {
      Map configMap = await WebdavManageAPI.getConfigMap();
      _hostController.text = configMap['host'];
      _usernameController.text = configMap['webdavusername'];
      _passwdController.text = configMap['password'];
      if (configMap['uploadPath'] != 'None' && configMap['uploadPath'] != null) {
        _uploadPathController.text = configMap['uploadPath'];
      } else {
        _uploadPathController.clear();
      }
      setState(() {});
    } catch (e) {
      FLog.error(
          className: 'webdavConfigState',
          methodName: '_initConfig',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
    }
  }

  @override
  void dispose() {
    _hostController.dispose();
    _usernameController.dispose();
    _passwdController.dispose();
    _uploadPathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: titleText('Webdav参数配置'),
        actions: [
          IconButton(
            onPressed: () async {
              await Application.router
                  .navigateTo(context, '/configureStorePage?psHost=webdav', transition: TransitionType.cupertino);
              await _initConfig();
              setState(() {});
            },
            icon: const Icon(Icons.save_as_outlined, color: Color.fromARGB(255, 255, 255, 255), size: 35),
          )
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          children: [
            TextFormField(
              controller: _hostController,
              decoration: const InputDecoration(
                label: Center(child: Text('域名')),
                hintText: '例如: https://test.com/dav',
              ),
              textAlign: TextAlign.center,
              validator: (value) {
                if (value == null || value.isEmpty || value.toString().trim().isEmpty) {
                  return '请输入域名';
                }
                if (!value.startsWith('http://') && !value.startsWith('https://')) {
                  return '以http://或https://开头';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(
                label: Center(child: Text('用户名')),
                hintText: '设定用户名',
              ),
              textAlign: TextAlign.center,
              validator: (value) {
                if (value == null || value.isEmpty || value.toString().trim().isEmpty) {
                  return '请输入用户名';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _passwdController,
              obscureText: true,
              decoration: const InputDecoration(
                label: Center(child: Text('密码')),
                hintText: '输入密码',
              ),
              textAlign: TextAlign.center,
              validator: (value) {
                if (value == null || value.isEmpty || value.toString().trim().isEmpty) {
                  return '请输入密码';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _uploadPathController,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.zero,
                label: Center(child: Text('可选：储存路径')),
                hintText: '例如: /百度网盘/图床',
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
                          requestCallBack: _saveWebdavConfig(),
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
                        requestCallBack: checkWebdavConfig(),
                      );
                    });
              },
              child: titleText('检查当前配置', fontsize: null),
            )),
            ListTile(
                title: ElevatedButton(
              onPressed: () async {
                await Application.router
                    .navigateTo(context, '/configureStorePage?psHost=webdav', transition: TransitionType.cupertino);
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

  Future _saveWebdavConfig() async {
    String host = _hostController.text;
    if (host.endsWith('/')) {
      host = host.substring(0, host.length - 1);
    }
    if (!host.startsWith('http://') && !host.startsWith('https://')) {
      host = 'http://$host';
    }

    final username = _usernameController.text;
    final password = _passwdController.text;
    String uploadPath = _uploadPathController.text;

    if (uploadPath.isEmpty || uploadPath == '/' || uploadPath.trim() == '') {
      uploadPath = 'None';
    } else {
      if (!uploadPath.startsWith('/')) {
        uploadPath = '/$uploadPath';
      }
      if (!uploadPath.endsWith('/')) {
        uploadPath = '$uploadPath/';
      }
    }

    try {
      var client = webdav.newClient(
        host,
        user: username,
        password: password,
      );
      client.setHeaders({'accept-charset': 'utf-8'});
      client.setConnectTimeout(30000);
      client.setSendTimeout(30000);
      client.setReceiveTimeout(30000);
      await client.ping();

      final webdavConfig = WebdavConfigModel(host, username, password, uploadPath);
      final webdavConfigJson = jsonEncode(webdavConfig);
      final webdavConfigFile = await localFile;
      webdavConfigFile.writeAsString(webdavConfigJson);
      setState(() {});
      return showCupertinoAlertDialog(
        context: context,
        barrierDismissible: false,
        title: '配置成功',
        content: '配置成功！',
      );
    } catch (e) {
      FLog.error(
          className: 'WebdavConfigPage',
          methodName: '_saveWebdavConfig',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      return showCupertinoAlertDialog(context: context, title: '连接webdav服务失败', content: e.toString());
    }
  }

  checkWebdavConfig() async {
    try {
      final webdavConfigFile = await localFile;
      String configData = await webdavConfigFile.readAsString();
      if (configData == "Error") {
        return showCupertinoAlertDialog(context: context, title: "检查失败!", content: "请先配置上传参数.");
      }
      Map configMap = jsonDecode(configData);
      var client = webdav.newClient(
        configMap['host'],
        user: configMap['webdavusername'],
        password: configMap['password'],
      );
      client.setHeaders({'accept-charset': 'utf-8'});
      client.setConnectTimeout(30000);
      client.setSendTimeout(30000);
      client.setReceiveTimeout(30000);
      await client.ping();
      return showCupertinoAlertDialog(
          context: context,
          title: '通知',
          content:
              '检测通过，您的配置信息为：\nhost:\n${configMap["host"]}\nwebdav用户名:\n${configMap["webdavusername"]}\n密码:\n${configMap["password"]}\nuploadPath:\n${configMap["uploadPath"]}');
    } catch (e) {
      FLog.error(
          className: 'ConfigPage',
          methodName: 'checkWebdavConfig',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      return showCupertinoAlertDialog(context: context, title: "检查失败!", content: e.toString());
    }
  }

  Future<File> get localFile async {
    final path = await _localPath;
    String defaultUser = await Global.getUser();
    return File('$path/${defaultUser}_webdav_config.txt');
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<String> readWebdavConfig() async {
    try {
      final file = await localFile;
      String contents = await file.readAsString();
      return contents;
    } catch (e) {
      FLog.error(
          className: 'WebdavConfigPage',
          methodName: 'readWebdavConfig',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      return "Error";
    }
  }

  _setdefault() async {
    await Global.setPShost('webdav');
    await Global.setShowedPBhost('PBhostExtend4');
    eventBus.fire(AlbumRefreshEvent(albumKeepAlive: false));
    eventBus.fire(HomePhotoRefreshEvent(homePhotoKeepAlive: false));
    showToast('已设置Webdav为默认图床');
  }
}

class WebdavConfigModel {
  final String host;
  final String webdavusername;
  final String password;
  final String uploadPath;

  WebdavConfigModel(this.host, this.webdavusername, this.password, this.uploadPath);

  Map<String, dynamic> toJson() => {
        'host': host,
        'webdavusername': webdavusername,
        'password': password,
        'uploadPath': uploadPath,
      };

  static List keysList = [
    'remarkName',
    'host',
    'webdavusername',
    'password',
    'uploadPath',
  ];
}
