import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:ftpconnect/ftpconnect.dart';
import 'package:dartssh2/dartssh2.dart';
import 'package:fluro/fluro.dart';
import 'package:horopic/utils/event_bus_utils.dart';

import 'package:horopic/widgets/net_loading_dialog.dart';
import 'package:horopic/router/application.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/utils/global.dart';
import 'package:horopic/picture_host_manage/manage_api/ftp_manage_api.dart';
import 'package:horopic/widgets/configure_widgets.dart';

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
      flogErr(e, {}, 'FTPConfigState' 'FTPConfigState', '_initConfig');
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
      appBar: ConfigureWidgets.buildConfigAppBar(
        title: 'FTP参数配置',
        context: context,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            ConfigureWidgets.buildSettingCard(
              title: '基本配置',
              children: [
                ConfigureWidgets.buildFormField(
                  controller: _ftpHostController,
                  labelText: 'FTP主机地址',
                  hintText: '请输入FTP主机地址',
                  prefixIcon: Icons.computer,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入FTP主机地址';
                    }
                    return null;
                  },
                ),
                ConfigureWidgets.buildFormField(
                  controller: _ftpPortController,
                  labelText: 'FTP端口',
                  hintText: '如：21或者22',
                  prefixIcon: Icons.sports_score,
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
                ConfigureWidgets.buildFormField(
                  controller: _ftpUserController,
                  labelText: '可选：FTP用户名',
                  hintText: '勾选匿名时无需填写',
                  prefixIcon: Icons.person,
                ),
                ConfigureWidgets.buildFormField(
                  controller: _ftpPasswordController,
                  labelText: '可选: FTP密码',
                  hintText: '匿名或无密码时无需填写',
                  prefixIcon: Icons.vpn_key,
                  obscureText: true,
                ),
              ],
            ),
            ConfigureWidgets.buildSettingCard(
              title: '路径配置',
              children: [
                ConfigureWidgets.buildFormField(
                  controller: _ftpUploadPathController,
                  labelText: '可选: FTP上传路径',
                  hintText: '例如：test/',
                  prefixIcon: Icons.upload_file,
                ),
                ConfigureWidgets.buildFormField(
                  controller: _ftpHomeDirController,
                  labelText: '可选: 管理功能起始路径',
                  hintText: '例如：/home/testuser/',
                  prefixIcon: Icons.folder,
                ),
                ConfigureWidgets.buildFormField(
                  controller: _ftpCustomUrlController,
                  labelText: '可选:自定义域名',
                  hintText: '例如https://test.com',
                  prefixIcon: Icons.link,
                ),
                ConfigureWidgets.buildFormField(
                  controller: _ftpWebPathController,
                  labelText: '可选:拼接用web路径',
                  hintText: '例如：/test/',
                  prefixIcon: Icons.web,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: ListTile(
                          title: const Text('FTP类型'),
                          subtitle: Text(_ftpConfigMap['ftpType']),
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
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: SwitchListTile(
                          title: const Text('匿名登录'),
                          value: _ftpConfigMap['isAnonymous'] == 'true',
                          onChanged: (value) {
                            setState(() {
                              _ftpConfigMap['isAnonymous'] = value.toString();
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            ConfigureWidgets.buildSettingCard(
              title: '操作',
              children: [
                ConfigureWidgets.buildSettingItem(
                  context: context,
                  title: '保存设置',
                  icon: Icons.save,
                  onTap: () {
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
                ),
                ConfigureWidgets.buildDivider(),
                ConfigureWidgets.buildSettingItem(
                  context: context,
                  title: '检查当前配置',
                  icon: Icons.check_circle,
                  onTap: () {
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
                ),
                ConfigureWidgets.buildDivider(),
                ConfigureWidgets.buildSettingItem(
                  context: context,
                  title: '设置备用配置',
                  icon: Icons.settings_backup_restore,
                  onTap: () async {
                    await Application.router
                        .navigateTo(context, '/configureStorePage?psHost=ftp', transition: TransitionType.cupertino);
                    await _initConfig();
                    setState(() {});
                  },
                ),
                ConfigureWidgets.buildDivider(),
                ConfigureWidgets.buildSettingItem(
                  context: context,
                  title: '设为默认图床',
                  icon: Icons.favorite,
                  onTap: () {
                    _setdefault();
                  },
                ),
              ],
            ),
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
      flogErr(e, {}, 'FTPConfigPage', '_saveFTPConfig_2');
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
      flogErr(e, {}, 'FTPConfigPage', 'checkFTPConfig');
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
