import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:f_logs/f_logs.dart';
import 'package:ftpconnect/ftpconnect.dart';
import 'package:dartssh2/dartssh2.dart';
import 'package:fluro/fluro.dart';
import 'package:horopic/utils/event_bus_utils.dart';

import 'package:horopic/pages/loading.dart';
import 'package:horopic/router/routers.dart';
import 'package:horopic/router/application.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/utils/global.dart';
import 'package:horopic/picture_host_manage/manage_api/ftp_manage_api.dart';

class FTPConfig extends StatefulWidget {
  const FTPConfig({super.key});

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
  final _ftpCustomUrlController = TextEditingController(); //可选
  final _ftpWebPathController = TextEditingController(); //可选

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
      _ftpHostController.text = configMap['ftpHost'] ?? '';
      _ftpPortController.text = configMap['ftpPort'] ?? '';
      _ftpConfigMap['ftpType'] = configMap['ftpType'] ?? 'FTP';
      _ftpConfigMap['isAnonymous'] = configMap['isAnonymous']?.toString() ?? 'false';
      setControllerText(_ftpUserController, configMap['ftpUser']);
      setControllerText(_ftpPasswordController, configMap['ftpPassword']);
      setControllerText(_ftpUploadPathController, configMap['uploadPath']);
      setControllerText(_ftpHomeDirController, configMap['ftpHomeDir']);
      setControllerText(_ftpCustomUrlController, configMap['ftpCustomUrl']);
      setControllerText(_ftpWebPathController, configMap['ftpWebPath']);
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
    _ftpCustomUrlController.dispose();
    _ftpWebPathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: titleText('FTP参数配置'),
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
              Application.router.navigateTo(
                  context, '${Routes.sshTerminal}?configMap=${Uri.encodeComponent(jsonEncode(configMap))}',
                  transition: TransitionType.cupertino);
            },
          ),
          IconButton(
            onPressed: () async {
              await Application.router
                  .navigateTo(context, '/configureStorePage?psHost=ftp', transition: TransitionType.cupertino);
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
            TextFormField(
              controller: _ftpCustomUrlController,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.zero,
                label: Center(child: Text('可选:自定义域名')),
                hintText: '例如https://test.com',
              ),
              textAlign: TextAlign.center,
            ),
            TextFormField(
              controller: _ftpWebPathController,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.zero,
                label: Center(child: Text('可选:拼接用web路径')),
                hintText: '例如：/test/',
              ),
              textAlign: TextAlign.center,
            ),
            ListTile(
              title: const Text('FTP类型'),
              trailing: DropdownButton<String>(
                value: _ftpConfigMap['ftpType'],
                onChanged: (String? newValue) {
                  setState(() {
                    if (newValue != null) {
                      _ftpConfigMap['ftpType'] = newValue;
                    }
                  });
                },
                items: <String>['FTP', 'SFTP'].map<DropdownMenuItem<String>>((String value) {
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
                        requestCallBack: checkFTPConfig(),
                      );
                    });
              },
              child: titleText('检查当前配置', fontsize: null),
            )),
            ListTile(
                title: ElevatedButton(
              onPressed: () async {
                await Application.router
                    .navigateTo(context, '/configureStorePage?psHost=ftp', transition: TransitionType.cupertino);
                await _initConfig();
                setState(() {});
              },
              child: titleText('设置备用配置', fontsize: null),
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
                Application.router.navigateTo(
                    context, '${Routes.sshTerminal}?configMap=${Uri.encodeComponent(jsonEncode(configMap))}',
                    transition: TransitionType.cupertino);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.terminal_outlined,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 10),
                  titleText('连接SSH终端', fontsize: null),
                ],
              ),
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

  Future _saveFTPConfig() async {
    String ftpHost = _ftpHostController.text.trim();
    String ftpPort = _ftpPortController.text.trim();
    String ftpUser = _ftpUserController.text.trim();
    String ftpPassword = _ftpPasswordController.text.trim();
    String ftpUploadPath = _ftpUploadPathController.text.trim();
    String ftpHomeDir = _ftpHomeDirController.text.trim();
    String ftpCustomUrl = _ftpCustomUrlController.text.trim();
    String ftpWebPath = _ftpWebPathController.text.trim();
    if (ftpUser.isEmpty) {
      ftpUser = 'None';
    }
    if (ftpPassword.isEmpty) {
      ftpPassword = 'None';
    }

    if (ftpUploadPath.isEmpty || ftpUploadPath == '/') {
      ftpUploadPath = 'None';
    } else if (!ftpUploadPath.endsWith('/')) {
      ftpUploadPath = '$ftpUploadPath/';
    }
    if (ftpHomeDir.isEmpty || ftpHomeDir == '/') {
      ftpHomeDir = 'None';
    } else if (!ftpHomeDir.endsWith('/')) {
      ftpHomeDir = '$ftpHomeDir/';
    }
    if (ftpCustomUrl.isEmpty) {
      ftpCustomUrl = 'None';
    }
    if (ftpWebPath.isEmpty || ftpWebPath == '/') {
      ftpWebPath = 'None';
    } else if (!ftpWebPath.endsWith('/')) {
      ftpWebPath = '$ftpWebPath/';
    }
    String isAnonymous = _ftpConfigMap['isAnonymous'].toString();
    String ftpType = _ftpConfigMap['ftpType'];

    try {
      final ftpConfig = FTPConfigModel(ftpHost, ftpPort, ftpUser, ftpPassword, ftpType, isAnonymous, ftpUploadPath,
          ftpHomeDir, ftpCustomUrl, ftpWebPath);
      final ftpConfigJson = jsonEncode(ftpConfig);
      final ftpConfigFile = await FTPManageAPI.localFile;
      await ftpConfigFile.writeAsString(ftpConfigJson);
      showToast('保存成功');
    } catch (e) {
      FLog.error(
          className: 'FTPConfigPage',
          methodName: '_saveFTPConfig_2',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      if (context.mounted) {
        return showCupertinoAlertDialog(context: context, title: '错误', content: e.toString());
      }
    }
  }

  checkFTPConfig() async {
    try {
      Map configMap = await FTPManageAPI.getConfigMap();

      if (configMap.isEmpty) {
        if (context.mounted) {
          return showCupertinoAlertDialog(context: context, title: "检查失败!", content: "请先配置上传参数.");
        }
        return;
      }

      String ftpHost = configMap['ftpHost'];
      String ftpPort = configMap['ftpPort'];
      String ftpUser = configMap['ftpUser'];
      String ftpPassword = configMap['ftpPassword'];
      String ftpType = configMap['ftpType'];
      String isAnonymous = configMap['isAnonymous'].toString();

      if (ftpType == 'FTP') {
        FTPConnect ftpConnect;
        if (isAnonymous == 'true') {
          ftpConnect = FTPConnect(ftpHost, port: int.parse(ftpPort), securityType: SecurityType.FTP);
        } else {
          ftpConnect = FTPConnect(ftpHost,
              port: int.parse(ftpPort), user: ftpUser, pass: ftpPassword, securityType: SecurityType.FTP);
        }
        bool connectResult = await ftpConnect.connect();
        await ftpConnect.disconnect();
        if (connectResult == true) {
          if (context.mounted) {
            return showCupertinoAlertDialog(
              context: context,
              title: '通知',
              content:
                  '检测通过，您的配置信息为:\n用户名:\n${configMap["ftpHost"]}\n端口:\n${configMap["ftpPort"]}\n用户名:\n${configMap["ftpUser"]}\n密码:\n${configMap["ftpPassword"]}\n上传路径:\n${configMap["uploadPath"]}\n管理功能起始路径:\n${configMap["ftpHomeDir"]}\n自定义URL:\n${configMap["ftpCustomUrl"]}',
            );
          }
          return;
        } else {
          if (context.mounted) {
            return showCupertinoAlertDialog(context: context, title: '错误', content: '检查失败，请检查配置信息');
          }
          return;
        }
      } else {
        final socket = await SSHSocket.connect(ftpHost, int.parse(ftpPort.toString()));
        final client = SSHClient(
          socket,
          username: ftpUser,
          onPasswordRequest: () {
            return ftpPassword;
          },
        );
        client.close();
        if (context.mounted) {
          return showCupertinoAlertDialog(
            context: context,
            title: '通知',
            content:
                '检测通过，您的配置信息为:\n用户名:\n${configMap["ftpHost"]}\n端口:\n${configMap["ftpPort"]}\n用户名:\n${configMap["ftpUser"]}\n密码:\n${configMap["ftpPassword"]}\n上传路径:\n${configMap["uploadPath"]}\n管理功能起始路径:\n${configMap["ftpHomeDir"]}\n自定义URL:\n${configMap["ftpCustomUrl"]}',
          );
        }
      }
    } catch (e) {
      FLog.error(
          className: 'FTPConfigPage',
          methodName: 'checkFTPConfig',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      if (context.mounted) {
        return showCupertinoAlertDialog(context: context, title: "检查失败!", content: e.toString());
      }
    }
  }

  _setdefault() {
    Global.setPShost('ftp');
    Global.setShowedPBhost('PBhostExtend1');
    eventBus.fire(AlbumRefreshEvent(albumKeepAlive: false));
    eventBus.fire(HomePhotoRefreshEvent(homePhotoKeepAlive: false));
    showToast('已设置FTP为默认图床');
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
  final String ftpCustomUrl;
  final String ftpWebPath;

  FTPConfigModel(this.ftpHost, this.ftpPort, this.ftpUser, this.ftpPassword, this.ftpType, this.isAnonymous,
      this.uploadPath, this.ftpHomeDir, this.ftpCustomUrl, this.ftpWebPath);

  Map<String, dynamic> toJson() => {
        'ftpHost': ftpHost,
        'ftpPort': ftpPort,
        'ftpUser': ftpUser,
        'ftpPassword': ftpPassword,
        'ftpType': ftpType,
        'isAnonymous': isAnonymous,
        'uploadPath': uploadPath,
        'ftpHomeDir': ftpHomeDir,
        'ftpCustomUrl': ftpCustomUrl,
        'ftpWebPath': ftpWebPath
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
    'ftpCustomUrl',
    'ftpWebPath'
  ];
}
