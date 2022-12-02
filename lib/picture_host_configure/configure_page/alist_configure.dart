import 'dart:io';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:f_logs/f_logs.dart';
import 'package:fluro/fluro.dart';
import 'package:path_provider/path_provider.dart';

import 'package:horopic/router/application.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/pages/loading.dart';
import 'package:horopic/utils/sql_utils.dart';
import 'package:horopic/utils/global.dart';
import 'package:horopic/utils/event_bus_utils.dart';
import 'package:horopic/picture_host_manage/manage_api/alist_manage_api.dart';

class AlistConfig extends StatefulWidget {
  const AlistConfig({Key? key}) : super(key: key);

  @override
  AlistConfigState createState() => AlistConfigState();
}

class AlistConfigState extends State<AlistConfig> {
  final _formKey = GlobalKey<FormState>();
  final _hostController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwdController = TextEditingController();
  final _uploadPathController = TextEditingController();
  String _tokenController = '';

  @override
  void initState() {
    super.initState();
    _initConfig();
  }

  _initConfig() async {
    try {
      Map configMap = await AlistManageAPI.getConfigMap();
      _hostController.text = configMap['host'];
      _usernameController.text = configMap['alistusername'];
      _passwdController.text = configMap['password'];
      _tokenController = configMap['token'];
      if (configMap['uploadPath'] != 'None' &&
          configMap['uploadPath'] != null) {
        _uploadPathController.text = configMap['uploadPath'];
      } else {
        _uploadPathController.clear();
      }
      setState(() {});
    } catch (e) {
      FLog.error(
          className: 'alistConfigState',
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
        title: titleText('Alist参数配置'),
        actions: [
          IconButton(
            onPressed: () async {
              await Application.router.navigateTo(
                  context, '/configureStorePage?psHost=alist',
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
              controller: _hostController,
              decoration: const InputDecoration(
                label: Center(child: Text('域名')),
                hintText: '例如: https://alist.test.com',
              ),
              textAlign: TextAlign.center,
              validator: (value) {
                if (value == null ||
                    value.isEmpty ||
                    value.toString().trim().isEmpty) {
                  return '请输入域名';
                }
                if (!value.startsWith('http://') &&
                    !value.startsWith('https://')) {
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
            ),
            TextFormField(
              controller: _passwdController,
              obscureText: true,
              decoration: const InputDecoration(
                label: Center(child: Text('密码')),
                hintText: '输入密码',
              ),
              textAlign: TextAlign.center,
            ),
            TextFormField(
              controller: _uploadPathController,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.zero,
                label: Center(child: Text('储存路径')),
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
                          requestCallBack: _saveAlistConfig(),
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
                        requestCallBack: checkAlistConfig(),
                      );
                    });
              },
              child: titleText('检查当前配置', fontsize: null),
            )),
            ListTile(
                title: ElevatedButton(
              onPressed: () async {
                await Application.router.navigateTo(
                    context, '/configureStorePage?psHost=alist',
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
            ListTile(
              title: const Center(
                child: Text(
                  '当前token',
                  style: TextStyle(color: Colors.black),
                ),
              ),
              subtitle: Center(
                child: SelectableText(
                  _tokenController == '' ? '未配置' : _tokenController,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.blue),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future _saveAlistConfig() async {
    String host = _hostController.text;
    if (host.endsWith('/')) {
      host = host.substring(0, host.length - 1);
    }
    if (!host.startsWith('http://') && !host.startsWith('https://')) {
      host = 'https://$host';
    }
    String token = '';
    if (_tokenController.isEmpty &&
        (_usernameController.text.isEmpty || _passwdController.text.isEmpty)) {
      showToast('用户名或密码为空');
      return;
    }
    if (_usernameController.text.isNotEmpty &&
        _passwdController.text.isNotEmpty) {
      final username = _usernameController.text;
      final password = _passwdController.text;
      String uploadPath = _uploadPathController.text;

      if (uploadPath.isEmpty || uploadPath == '/' || uploadPath.trim() == '') {
        uploadPath = 'None';
      }

      String sqlResult = '';
      try {
        var res = await AlistManageAPI.getToken(host, username, password);
        if (res[0] == 'success') {
          token = res[1];
          try {
            List sqlconfig = [];
            sqlconfig.add(host);
            sqlconfig.add(username);
            sqlconfig.add(password);
            sqlconfig.add(token);
            sqlconfig.add(uploadPath);

            String defaultUser = await Global.getUser();
            sqlconfig.add(defaultUser);
            var queryalist = await MySqlUtils.queryAlist(username: defaultUser);
            var queryuser = await MySqlUtils.queryUser(username: defaultUser);
            if (queryuser == 'Empty') {
              return showCupertinoAlertDialog(
                  context: context, title: '错误', content: '用户不存在,请先登录');
            } else if (queryalist == 'Empty') {
              sqlResult = await MySqlUtils.insertAlist(content: sqlconfig);
            } else {
              sqlResult = await MySqlUtils.updateAlist(content: sqlconfig);
            }
          } catch (e) {
            FLog.error(
                className: 'AlistConfigPage',
                methodName: '_saveAlistConfig',
                text: formatErrorMessage({}, e.toString()),
                dataLogType: DataLogType.ERRORS.toString());
            return showCupertinoAlertDialog(
                context: context, title: '错误', content: e.toString());
          }
          if (sqlResult == "Success") {
            _tokenController = token;
            final alistConfig =
                AlistConfigModel(host, username, password, token, uploadPath);
            final alistConfigJson = jsonEncode(alistConfig);
            final alistConfigFile = await localFile;
            alistConfigFile.writeAsString(alistConfigJson);
            setState(() {});
            return showCupertinoAlertDialog(
                context: context,
                barrierDismissible: false,
                title: '配置成功',
                content: '您的密钥为：\n$token,\n请妥善保管，不要泄露给他人');
          } else {
            return showCupertinoAlertDialog(
                context: context,
                barrierDismissible: false,
                title: '配置失败',
                content: '数据库错误');
          }
        } else {
          showToast('获取token失败');
        }
      } catch (e) {
        FLog.error(
            className: 'AlistConfigPage',
            methodName: '_saveAlistConfig',
            text: formatErrorMessage({}, e.toString()),
            dataLogType: DataLogType.ERRORS.toString());
        return showCupertinoAlertDialog(
            context: context, title: '错误', content: e.toString());
      }
    } else {
      String uploadPath = _uploadPathController.text;
      if (uploadPath.isEmpty || uploadPath == '/' || uploadPath.trim() == '') {
        uploadPath = 'None';
      }
      BaseOptions options = BaseOptions(
        connectTimeout: 30000,
        receiveTimeout: 30000,
        sendTimeout: 30000,
      );
      Map<String, dynamic> query = {
        'group': 0,
      };
      options.headers = {
        "Content-type": "application/json",
        "Authorization": _tokenController,
      };
      Dio dio = Dio(options);
      String sqlResult = '';
      try {
        var response = await dio.get('$host/api/admin/setting/list',
            queryParameters: query);
        if (response.statusCode == 200 &&
            response.data['message'] == 'success') {
          List sqlconfig = [];
          Map configMap = await AlistManageAPI.getConfigMap();
          sqlconfig.add(host);
          sqlconfig.add(configMap['alistusername']);
          sqlconfig.add(configMap['password']);
          sqlconfig.add(_tokenController);
          sqlconfig.add(uploadPath);
          String defaultUser = await Global.getUser();
          sqlconfig.add(defaultUser);
          var queryalist = await MySqlUtils.queryAlist(username: defaultUser);
          var queryuser = await MySqlUtils.queryUser(username: defaultUser);
          if (queryuser == 'Empty') {
            return showCupertinoAlertDialog(
                context: context, title: '错误', content: '用户不存在,请先登录');
          } else if (queryalist == 'Empty') {
            sqlResult = await MySqlUtils.insertAlist(content: sqlconfig);
          } else {
            sqlResult = await MySqlUtils.updateAlist(content: sqlconfig);
          }
          if (sqlResult == "Success") {
            final alistConfig = AlistConfigModel(
                host,
                configMap['alistusername'],
                configMap['password'],
                _tokenController,
                uploadPath);
            final alistConfigJson = jsonEncode(alistConfig);
            final alistConfigFile = await localFile;
            alistConfigFile.writeAsString(alistConfigJson);

            return showCupertinoAlertDialog(
                context: context,
                barrierDismissible: false,
                title: '配置成功',
                content: '您的密钥为：\n$_tokenController,\n请妥善保管，不要泄露给他人');
          } else {
            return showCupertinoAlertDialog(
                context: context,
                barrierDismissible: false,
                title: '配置失败',
                content: '数据库错误');
          }
        } else {
          showToast('配置失败');
        }
      } catch (e) {
        FLog.error(
            className: 'AlistConfigPage',
            methodName: '_saveAlistConfig',
            text: formatErrorMessage({}, e.toString()),
            dataLogType: DataLogType.ERRORS.toString());
        return showCupertinoAlertDialog(
            context: context, title: '错误', content: e.toString());
      }
    }
  }

  checkAlistConfig() async {
    try {
      final alistConfigFile = await localFile;
      String configData = await alistConfigFile.readAsString();
      if (configData == "Error") {
        return showCupertinoAlertDialog(
            context: context, title: "检查失败!", content: "请先配置上传参数.");
      }
      Map configMap = jsonDecode(configData);
      BaseOptions options = BaseOptions(
        connectTimeout: 30000,
        receiveTimeout: 30000,
        sendTimeout: 30000,
      );
      Map<String, dynamic> query = {
        'group': 0,
      };
      options.headers = {
        "Authorization": configMap["token"],
        "Content-type": "application/json",
      };
      String profileUrl = configMap["host"] + "/api/admin/setting/list";
      Dio dio = Dio(options);
      var response = await dio.get(
        profileUrl,
        queryParameters: query,
      );
      if (response.statusCode == 200 && response.data['message'] == 'success') {
        return showCupertinoAlertDialog(
            context: context,
            title: '通知',
            content:
                '检测通过，您的配置信息为：\nhost:\n${configMap["host"]}\nalist用户名:\n${configMap["alistusername"]}\n密码:\n${configMap["password"]}\ntoken:\n${configMap["token"]}\nuploadPath:\n${configMap["uploadPath"]}');
      } else {
        return showCupertinoAlertDialog(
            context: context, title: '通知', content: '检测失败，请检查配置信息');
      }
    } catch (e) {
      FLog.error(
          className: 'ConfigPage',
          methodName: 'checkAlistConfig',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      return showCupertinoAlertDialog(
          context: context, title: "检查失败!", content: e.toString());
    }
  }

  Future<File> get localFile async {
    final path = await _localPath;
    String defaultUser = await Global.getUser();
    return File('$path/${defaultUser}_alist_config.txt');
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<String> readAlistConfig() async {
    try {
      final file = await localFile;
      String contents = await file.readAsString();
      return contents;
    } catch (e) {
      FLog.error(
          className: 'AlistConfigPage',
          methodName: 'readAlistConfig',
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
      var queryalist = await MySqlUtils.queryAlist(username: defaultUser);
      if (queryalist == 'Empty') {
        return Fluttertoast.showToast(
            msg: "请先配置上传参数",
            toastLength: Toast.LENGTH_SHORT,
            timeInSecForIosWeb: 2,
            fontSize: 16.0);
      }
      if (queryalist == 'Error') {
        return Fluttertoast.showToast(
            msg: "Error",
            toastLength: Toast.LENGTH_SHORT,
            timeInSecForIosWeb: 2,
            fontSize: 16.0);
      }
      if (queryuser['defaultPShost'] == 'alist') {
        await Global.setPShost('alist');
        await Global.setShowedPBhost('alist');
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
        sqlconfig.add('alist');
        var updateResult = await MySqlUtils.updateUser(content: sqlconfig);
        if (updateResult == 'Success') {
          await Global.setPShost('alist');
          await Global.setShowedPBhost('PBhostExtend3');
          eventBus.fire(AlbumRefreshEvent(albumKeepAlive: false));
          eventBus.fire(HomePhotoRefreshEvent(homePhotoKeepAlive: false));
          showToast('已设置Alist为默认图床');
        } else {
          showToast('写入数据库失败');
        }
      }
    } catch (e) {
      FLog.error(
          className: 'alistPage',
          methodName: '_setdefault',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      showToastWithContext(context, '错误');
    }
  }
}

class AlistConfigModel {
  final String host;
  final String alistusername;
  final String password;
  final String token;
  final String uploadPath;

  AlistConfigModel(this.host, this.alistusername, this.password, this.token,
      this.uploadPath);

  Map<String, dynamic> toJson() => {
        'host': host,
        'alistusername': alistusername,
        'password': password,
        'token': token,
        'uploadPath': uploadPath,
      };

  static List keysList = [
    'remarkName',
    'host',
    'alistusername',
    'password',
    'token',
    'uploadPath',
  ];
}
