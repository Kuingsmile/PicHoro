import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:f_logs/f_logs.dart';
import 'package:ftpconnect/ftpconnect.dart';
import 'package:dartssh2/dartssh2.dart';
import 'package:fluro/fluro.dart';
import 'package:horopic/utils/event_bus_utils.dart';

import 'package:horopic/pages/loading.dart';
import 'package:horopic/router/routers.dart';
import 'package:horopic/router/application.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/utils/sql_utils.dart';
import 'package:horopic/utils/global.dart';
import 'package:horopic/picture_host_manage/manage_api/ftp_manage_api.dart';

class FTPConfig extends StatefulWidget {
  const FTPConfig({Key? key}) : super(key: key);

  @override
  FTPConfigState createState() => FTPConfigState();
}

class FTPConfigState extends State<FTPConfig> {
  final _formKey = GlobalKey<FormState>();

  final _ftpHostController = TextEditingController();
  final _ftpPortController = TextEditingController();
  final _ftpUserController = TextEditingController(); //匿名登录时不需要
  final _ftpPasswordController = TextEditingController(); //匿名登录时不需要
  final _ftpHomeDirController = TextEditingController();
  final _ftpUploadPathController = TextEditingController(); //可选

  Map _ftpConfigMap = {
    'ftpType': 'SFTP',
    'isAnonymous': 'false',
  };

  resetFtpConfigMap() {
    setState(() {
      _ftpConfigMap = {
        'ftpType': 'SFTP',
        'isAnonymous': 'false',
      };
    });
  }

  @override
  void initState() {
    super.initState();
    _initConfig();
  }

  _initConfig() async {
    resetFtpConfigMap();
    try {
      Map configMap = await FTPManageAPI.getConfigMap();
      _ftpHostController.text = configMap['ftpHost'];
      _ftpPortController.text = configMap['ftpPort'];
      _ftpConfigMap['ftpType'] = configMap['ftpType'];
      _ftpConfigMap['isAnonymous'] = configMap['isAnonymous'].toString();

      if (configMap['ftpUser'] != 'None') {
        _ftpUserController.text = configMap['ftpUser'];
      } else {
        _ftpUserController.clear();
      }
      if (configMap['ftpPassword'] != 'None') {
        _ftpPasswordController.text = configMap['ftpPassword'];
      } else {
        _ftpPasswordController.clear();
      }
      if (configMap['uploadPath'] != 'None') {
        _ftpUploadPathController.text = configMap['uploadPath'];
      } else {
        _ftpUploadPathController.clear();
      }
      if (configMap['ftpHomeDir'] != 'None') {
        _ftpHomeDirController.text = configMap['ftpHomeDir'];
      } else {
        _ftpHomeDirController.clear();
      }
      setState(() {});
    } catch (e) {
      FLog.error(
          className: 'FTPConfigState',
          methodName: '_initConfig',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
    }
  }

  @override
  void dispose() {
    _ftpHostController.dispose();
    _ftpPortController.dispose();
    _ftpUserController.dispose();
    _ftpPasswordController.dispose();
    _ftpUploadPathController.dispose();
    _ftpHomeDirController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text('FTP参数配置'),
        actions: [
          IconButton(
            icon: const Icon(Icons.terminal, color: Colors.white, size: 33),
            onPressed: () async {
              Map configMap = {
                'ftpHost': _ftpHostController.text,
                'ftpPort': _ftpPortController.text,
                'ftpUser': _ftpUserController.text,
                'ftpPassword': _ftpPasswordController.text,
              };
              Application.router.navigateTo(context,
                  '${Routes.sshTerminal}?configMap=${Uri.encodeComponent(jsonEncode(configMap))}',
                  transition: TransitionType.cupertino);
            },
          ),
          IconButton(
            onPressed: () async {
              await Application.router.navigateTo(
                  context, '/configureStorePage?psHost=ftp',
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
              controller: _ftpHostController,
              decoration: const InputDecoration(
                label: Center(child: Text('FTP主机地址')),
                hintText: '请输入FTP主机地址',
              ),
              textAlign: TextAlign.center,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入FTP主机地址';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _ftpPortController,
              decoration: const InputDecoration(
                label: Center(child: Text('FTP端口')),
                hintText: '如：21或者22',
              ),
              textAlign: TextAlign.center,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入FTP端口';
                }
                RegExp pattern = RegExp(r'^[0-9]{1,5}$');
                if (!pattern.hasMatch(value)) {
                  return '请输入正确的FTP端口';
                }
                if (int.parse(value) > 65535) {
                  return '请输入正确的FTP端口';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _ftpUserController,
              decoration: const InputDecoration(
                label: Center(child: Text('可选：FTP用户名')),
                hintText: '勾选匿名时无需填写',
              ),
              textAlign: TextAlign.center,
            ),
            TextFormField(
              controller: _ftpPasswordController,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.zero,
                label: Center(child: Text('可选: FTP密码')),
                hintText: '匿名或无密码时无需填写',
              ),
              textAlign: TextAlign.center,
            ),
            TextFormField(
              controller: _ftpUploadPathController,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.zero,
                label: Center(child: Text('可选: FTP上传路径')),
                hintText: '例如：test/',
              ),
              textAlign: TextAlign.center,
            ),
            TextFormField(
              controller: _ftpHomeDirController,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.zero,
                label: Center(child: Text('可选: 管理功能起始路径')),
                hintText: '例如：/home/testuser/',
              ),
              textAlign: TextAlign.center,
            ),
            ListTile(
              title: const Text('FTP类型'),
              trailing: DropdownButton<String>(
                value: _ftpConfigMap['ftpType'],
                onChanged: (String? newValue) {
                  setState(() {
                    _ftpConfigMap['ftpType'] = newValue!;
                  });
                },
                items: <String>['FTP', 'SFTP']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
            ListTile(
              title: const Text('匿名登录'),
              trailing: Switch(
                value: _ftpConfigMap['isAnonymous'] == 'true',
                onChanged: (value) {
                  setState(() {
                    _ftpConfigMap['isAnonymous'] = value.toString();
                  });
                },
              ),
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
                          requestCallBack: _saveFTPConfig(),
                        );
                      });
                }
              },
              child: const Text('提交表单'),
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
                        requestCallBack: checkFTPConfig(),
                      );
                    });
              },
              child: const Text('检查当前配置'),
            )),
            ListTile(
                title: ElevatedButton(
              onPressed: () async {
                await Application.router.navigateTo(
                    context, '/configureStorePage?psHost=ftp',
                    transition: TransitionType.cupertino);
                await _initConfig();
                setState(() {});
              },
              child: const Text('设置备用配置'),
            )),
            ListTile(
                title: ElevatedButton(
              onPressed: () async {
                Map configMap = {
                  'ftpHost': _ftpHostController.text,
                  'ftpPort': _ftpPortController.text,
                  'ftpUser': _ftpUserController.text,
                  'ftpPassword': _ftpPasswordController.text,
                };
                if (_ftpConfigMap['ftpType'] == 'FTP') {
                  showToast('只支持SSH/SFTP类型');
                  return;
                }
                Application.router.navigateTo(context,
                    '${Routes.sshTerminal}?configMap=${Uri.encodeComponent(jsonEncode(configMap))}',
                    transition: TransitionType.cupertino);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.terminal_outlined),
                  SizedBox(width: 10),
                  Text('连接SSH终端'),
                ],
              ),
            )),
            ListTile(
                title: ElevatedButton(
              onPressed: () {
                _setdefault();
              },
              child: const Text('设为默认图床'),
            )),
          ],
        ),
      ),
    );
  }

  Future _saveFTPConfig() async {
    final String ftpHost = _ftpHostController.text;
    final String ftpPort = _ftpPortController.text;
    String ftpUser = '';
    if (_ftpUserController.text.isEmpty || _ftpUserController.text == '') {
      ftpUser = 'None';
    } else {
      ftpUser = _ftpUserController.text;
    }
    String ftpPassword = '';
    if (_ftpPasswordController.text.isEmpty ||
        _ftpPasswordController.text == '') {
      ftpPassword = 'None';
    } else {
      ftpPassword = _ftpPasswordController.text;
    }
    String ftpUploadPath = '';
    if (_ftpUploadPathController.text.isEmpty ||
        _ftpUploadPathController.text == '') {
      ftpUploadPath = 'None';
    } else {
      ftpUploadPath = _ftpUploadPathController.text;
      if (!ftpUploadPath.endsWith('/')) {
        ftpUploadPath = '$ftpUploadPath/';
      }
    }
    String ftpHomeDir = '';
    if (_ftpHomeDirController.text.isEmpty ||
        _ftpHomeDirController.text == '' ||
        _ftpHomeDirController.text == '/') {
      ftpHomeDir = 'None';
    } else {
      ftpHomeDir = _ftpHomeDirController.text;
      if (!ftpHomeDir.endsWith('/')) {
        ftpHomeDir = '$ftpHomeDir/';
      }
    }
    final String isAnonymous = _ftpConfigMap['isAnonymous'].toString();
    final String ftpType = _ftpConfigMap['ftpType'];

    try {
      List sqlconfig = [];
      sqlconfig.add(ftpHost);
      sqlconfig.add(ftpPort);
      sqlconfig.add(ftpUser);
      sqlconfig.add(ftpPassword);
      sqlconfig.add(ftpType);
      sqlconfig.add(isAnonymous);
      sqlconfig.add(ftpUploadPath);
      sqlconfig.add(ftpHomeDir);
      //添加默认用户
      String defaultUser = await Global.getUser();
      sqlconfig.add(defaultUser);

      var queryFTP = await MySqlUtils.queryFTP(username: defaultUser);
      var queryuser = await MySqlUtils.queryUser(username: defaultUser);

      if (queryuser == 'Empty') {
        return showCupertinoAlertDialog(
            context: context, title: '错误', content: '用户不存在,请先登录');
      }

      try {
        if (ftpType == 'FTP') {
          FTPConnect ftpConnect;
          if (isAnonymous == 'true') {
            ftpConnect = FTPConnect(ftpHost,
                port: int.parse(ftpPort), securityType: SecurityType.FTP);
          } else {
            ftpConnect = FTPConnect(ftpHost,
                port: int.parse(ftpPort),
                user: ftpUser,
                pass: ftpPassword,
                securityType: SecurityType.FTP);
          }
          bool connectResult = await ftpConnect.connect();
          await ftpConnect.disconnect();
          var sqlResult;
          if (connectResult == true) {
            if (queryFTP == 'Empty') {
              sqlResult = await MySqlUtils.insertFTP(content: sqlconfig);
            } else {
              sqlResult = await MySqlUtils.updateFTP(content: sqlconfig);
            }
            if (sqlResult == "Success") {
              final ftpConfig = FTPConfigModel(ftpHost, ftpPort, ftpUser,
                  ftpPassword, ftpType, isAnonymous, ftpUploadPath, ftpHomeDir);
              final ftpConfigJson = jsonEncode(ftpConfig);
              final ftpConfigFile = await localFile;
              await ftpConfigFile.writeAsString(ftpConfigJson);
              return showCupertinoAlertDialog(
                  context: context, title: '成功', content: '配置成功');
            } else {
              return showCupertinoAlertDialog(
                  context: context, title: '错误', content: '数据库错误');
            }
          }
        } else {
          final socket =
              await SSHSocket.connect(ftpHost, int.parse(ftpPort.toString()));
          final client = SSHClient(
            socket,
            username: ftpUser,
            onPasswordRequest: () {
              return ftpPassword;
            },
          );
          client.close();
          var sqlResult;

          if (queryFTP == 'Empty') {
            sqlResult = await MySqlUtils.insertFTP(content: sqlconfig);
          } else {
            sqlResult = await MySqlUtils.updateFTP(content: sqlconfig);
          }
          if (sqlResult == "Success") {
            final ftpConfig = FTPConfigModel(ftpHost, ftpPort, ftpUser,
                ftpPassword, ftpType, isAnonymous, ftpUploadPath, ftpHomeDir);
            final ftpConfigJson = jsonEncode(ftpConfig);
            final ftpConfigFile = await localFile;
            await ftpConfigFile.writeAsString(ftpConfigJson);
            return showCupertinoAlertDialog(
                context: context, title: '成功', content: '配置成功');
          } else {
            return showCupertinoAlertDialog(
                context: context, title: '错误', content: '数据库错误');
          }
        }
      } catch (e) {
        FLog.error(
            className: 'FTPConfigPage',
            methodName: '_saveFTPConfig_1',
            text: formatErrorMessage({}, e.toString()),
            dataLogType: DataLogType.ERRORS.toString());
        return showCupertinoAlertDialog(
            context: context, title: '错误', content: e.toString());
      }
    } catch (e) {
      FLog.error(
          className: 'FTPConfigPage',
          methodName: '_saveFTPConfig_2',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      return showCupertinoAlertDialog(
          context: context, title: '错误', content: e.toString());
    }
  }

  checkFTPConfig() async {
    try {
      final ftpConfigFile = await localFile;
      String configData = await ftpConfigFile.readAsString();

      if (configData == "Error") {
        return showCupertinoAlertDialog(
            context: context, title: "检查失败!", content: "请先配置上传参数.");
      }

      Map configMap = jsonDecode(configData);
      String ftpHost = configMap['ftpHost'];
      String ftpPort = configMap['ftpPort'];
      String ftpUser = configMap['ftpUser'];
      String ftpPassword = configMap['ftpPassword'];
      String ftpType = configMap['ftpType'];
      String isAnonymous = configMap['isAnonymous'].toString();

      if (ftpType == 'FTP') {
        FTPConnect ftpConnect;
        if (isAnonymous == 'true') {
          ftpConnect = FTPConnect(ftpHost,
              port: int.parse(ftpPort), securityType: SecurityType.FTP);
        } else {
          ftpConnect = FTPConnect(ftpHost,
              port: int.parse(ftpPort),
              user: ftpUser,
              pass: ftpPassword,
              securityType: SecurityType.FTP);
        }
        bool connectResult = await ftpConnect.connect();
        await ftpConnect.disconnect();
        if (connectResult == true) {
          return showCupertinoAlertDialog(
            context: context,
            title: '通知',
            content:
                '检测通过，您的配置信息为:\n用户名:\n${configMap["ftpHost"]}\n端口:\n${configMap["ftpPort"]}\n用户名:\n${configMap["ftpUser"]}\n密码:\n${configMap["ftpPassword"]}\n上传路径:\n${configMap["uploadPath"]}\n管理功能起始路径:\n${configMap["ftpHomeDir"]}',
          );
        } else {
          return showCupertinoAlertDialog(
              context: context, title: '错误', content: '检查失败，请检查配置信息');
        }
      } else {
        final socket =
            await SSHSocket.connect(ftpHost, int.parse(ftpPort.toString()));
        final client = SSHClient(
          socket,
          username: ftpUser,
          onPasswordRequest: () {
            return ftpPassword;
          },
        );
        client.close();
        return showCupertinoAlertDialog(
          context: context,
          title: '通知',
          content:
              '检测通过，您的配置信息为:\n用户名:\n${configMap["ftpHost"]}\n端口:\n${configMap["ftpPort"]}\n用户名:\n${configMap["ftpUser"]}\n密码:\n${configMap["ftpPassword"]}\n上传路径:\n${configMap["uploadPath"]}\n管理功能起始路径:\n${configMap["ftpHomeDir"]}',
        );
      }
    } catch (e) {
      FLog.error(
          className: 'FTPConfigPage',
          methodName: 'checkFTPConfig',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      return showCupertinoAlertDialog(
          context: context, title: "检查失败!", content: e.toString());
    }
  }

  Future<File> get localFile async {
    final path = await _localPath;
    String defaultUser = await Global.getUser();
    return File('$path/${defaultUser}_ftp_config.txt');
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<String> readFTPConfig() async {
    try {
      final file = await localFile;
      String contents = await file.readAsString();
      return contents;
    } catch (e) {
      FLog.error(
          className: 'FTPConfigPage',
          methodName: 'readFTPConfig',
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

      var queryFTP = await MySqlUtils.queryFTP(username: defaultUser);
      if (queryFTP == 'Empty') {
        return Fluttertoast.showToast(
            msg: "请先配置上传参数",
            toastLength: Toast.LENGTH_SHORT,
            timeInSecForIosWeb: 2,
            fontSize: 16.0);
      }
      if (queryFTP == 'Error') {
        return Fluttertoast.showToast(
            msg: "Error",
            toastLength: Toast.LENGTH_SHORT,
            timeInSecForIosWeb: 2,
            fontSize: 16.0);
      }
      if (queryuser['defaultPShost'] == 'ftp') {
        await Global.setPShost('ftp');
        await Global.setShowedPBhost('PBhostExtend1');
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
        sqlconfig.add('ftp');

        var updateResult = await MySqlUtils.updateUser(content: sqlconfig);
        if (updateResult == 'Success') {
          await Global.setPShost('ftp');
          await Global.setShowedPBhost('PBhostExtend1');
          eventBus.fire(AlbumRefreshEvent(albumKeepAlive: false));
          eventBus.fire(HomePhotoRefreshEvent(homePhotoKeepAlive: false));
          showToast('已设置FTP为默认图床');
        } else {
          showToast('写入数据库失败');
        }
      }
    } catch (e) {
      FLog.error(
          className: 'FTPConfigPage',
          methodName: '_setdefault',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      showToastWithContext(context, '错误');
    }
  }
}

class FTPConfigModel {
  final String ftpHost;
  final String ftpPort;
  final String ftpUser;
  final String ftpPassword;
  final String ftpType;
  final String isAnonymous;
  final String uploadPath;
  final String ftpHomeDir;

  FTPConfigModel(this.ftpHost, this.ftpPort, this.ftpUser, this.ftpPassword,
      this.ftpType, this.isAnonymous, this.uploadPath, this.ftpHomeDir);

  Map<String, dynamic> toJson() => {
        'ftpHost': ftpHost,
        'ftpPort': ftpPort,
        'ftpUser': ftpUser,
        'ftpPassword': ftpPassword,
        'ftpType': ftpType,
        'isAnonymous': isAnonymous,
        'uploadPath': uploadPath,
        'ftpHomeDir': ftpHomeDir,
      };

  static List keysList = [
    'remarkName',
    'ftpHost',
    'ftpPort',
    'ftpUser',
    'ftpPassword',
    'ftpType',
    'isAnonymous',
    'uploadPath',
    'ftpHomeDir',
  ];
}
