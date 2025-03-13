import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluro/fluro.dart';
import 'package:webdav_client/webdav_client.dart' as webdav;

import 'package:horopic/router/application.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/widgets/net_loading_dialog.dart';
import 'package:horopic/utils/global.dart';
import 'package:horopic/utils/event_bus_utils.dart';
import 'package:horopic/picture_host_manage/manage_api/webdav_manage_api.dart';
import 'package:horopic/widgets/configure_widgets.dart';

class WebdavConfig extends StatefulWidget {
  const WebdavConfig({super.key});

  @override
  WebdavConfigState createState() => WebdavConfigState();
}

class WebdavConfigState extends State<WebdavConfig> {
  final _formKey = GlobalKey<FormState>();
  final _hostController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwdController = TextEditingController();
  final _uploadPathController = TextEditingController();
  final _customUrlController = TextEditingController();
  final _webPathController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initConfig();
  }

  _initConfig() async {
    try {
      Map configMap = await WebdavManageAPI.getConfigMap();
      _hostController.text = configMap['host'] ?? '';
      _usernameController.text = configMap['webdavusername'] ?? '';
      _passwdController.text = configMap['password'] ?? '';
      setControllerText(_uploadPathController, configMap['uploadPath']);
      setControllerText(_customUrlController, configMap['customUrl']);
      setControllerText(_webPathController, configMap['webPath']);
      setState(() {});
    } catch (e) {
      flogErr(e, {}, 'webdavConfigState', '_initConfig');
    }
  }

  @override
  void dispose() {
    _hostController.dispose();
    _usernameController.dispose();
    _passwdController.dispose();
    _uploadPathController.dispose();
    _customUrlController.dispose();
    _webPathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ConfigureWidgets.buildConfigAppBar(title: 'Webdav参数配置', context: context),
      body: Form(
        key: _formKey,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            ConfigureWidgets.buildSettingCard(
              title: '基本配置',
              children: [
                ConfigureWidgets.buildFormField(
                  controller: _hostController,
                  labelText: '域名',
                  hintText: '例如: https://test.com/dav',
                  prefixIcon: Icons.language,
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
                ConfigureWidgets.buildFormField(
                  controller: _usernameController,
                  labelText: '用户名',
                  hintText: '设定用户名',
                  prefixIcon: Icons.person,
                  validator: (value) {
                    if (value == null || value.isEmpty || value.toString().trim().isEmpty) {
                      return '请输入用户名';
                    }
                    return null;
                  },
                ),
                ConfigureWidgets.buildFormField(
                  controller: _passwdController,
                  labelText: '密码',
                  hintText: '输入密码',
                  prefixIcon: Icons.lock,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty || value.toString().trim().isEmpty) {
                      return '请输入密码';
                    }
                    return null;
                  },
                ),
              ],
            ),
            ConfigureWidgets.buildSettingCard(
              title: '可选配置',
              children: [
                ConfigureWidgets.buildFormField(
                  controller: _uploadPathController,
                  labelText: '储存路径',
                  hintText: '例如: /百度网盘/图床',
                  prefixIcon: Icons.folder,
                ),
                ConfigureWidgets.buildFormField(
                  controller: _customUrlController,
                  labelText: '自定义域名',
                  hintText: '例如: https://test.com',
                  prefixIcon: Icons.link,
                ),
                ConfigureWidgets.buildFormField(
                  controller: _webPathController,
                  labelText: '拼接路径',
                  hintText: '例如: /pic',
                  prefixIcon: Icons.route,
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
                              requestCallBack: _saveWebdavConfig(),
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
                            requestCallBack: checkWebdavConfig(),
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
                        .navigateTo(context, '/configureStorePage?psHost=webdav', transition: TransitionType.cupertino);
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

  Future _saveWebdavConfig() async {
    String host = _hostController.text.trim();
    String username = _usernameController.text.trim();
    String password = _passwdController.text.trim();
    String uploadPath = _uploadPathController.text.trim();
    String customUrl = _customUrlController.text.trim();
    String webPath = _webPathController.text.trim();
    if (host.endsWith('/')) {
      host = host.substring(0, host.length - 1);
    }
    if (!host.startsWith('http://') && !host.startsWith('https://')) {
      host = 'http://$host';
    }

    if (uploadPath.isEmpty || uploadPath == '/') {
      uploadPath = 'None';
    } else {
      if (!uploadPath.startsWith('/')) {
        uploadPath = '/$uploadPath';
      }
      if (!uploadPath.endsWith('/')) {
        uploadPath = '$uploadPath/';
      }
    }

    if (customUrl.isEmpty) {
      customUrl = 'None';
    }

    if (webPath.isEmpty) {
      webPath = 'None';
    } else if (!webPath.endsWith('/')) {
      webPath = '$webPath/';
    }

    try {
      final webdavConfig = WebdavConfigModel(host, username, password, uploadPath, customUrl, webPath);
      final webdavConfigJson = jsonEncode(webdavConfig);
      final webdavConfigFile = await WebdavManageAPI.localFile;
      webdavConfigFile.writeAsString(webdavConfigJson);
      setState(() {});
      showToast('保存成功');
    } catch (e) {
      flogErr(e, {}, 'WebdavConfigState', '_saveWebdavConfig');
      if (context.mounted) {
        return showCupertinoAlertDialog(context: context, title: '错误', content: e.toString());
      }
    }
  }

  checkWebdavConfig() async {
    try {
      Map configMap = await WebdavManageAPI.getConfigMap();
      if (configMap.isEmpty) {
        if (context.mounted) {
          return showCupertinoAlertDialog(context: context, title: "检查失败!", content: "请先配置上传参数.");
        }
        return;
      }

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
      if (context.mounted) {
        return showCupertinoAlertDialog(context: context, title: '通知', content: """检测通过，您的配置信息为：
host:
${configMap["host"]}
webdav用户名:
${configMap["webdavusername"]}
密码:
${configMap["password"]}
uploadPath:
${configMap["uploadPath"]}
自定义域名:
${configMap["customUrl"]}
webPath:
${configMap["webPath"]}
""");
      }
    } catch (e) {
      flogErr(e, {}, 'WebdavConfigState', 'checkWebdavConfig');
      if (context.mounted) {
        return showCupertinoAlertDialog(context: context, title: "检查失败!", content: e.toString());
      }
    }
  }

  _setdefault() {
    Global.setPShost('webdav');
    Global.setShowedPBhost('PBhostExtend4');
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
  final String customUrl;
  final String webPath;

  WebdavConfigModel(this.host, this.webdavusername, this.password, this.uploadPath, this.customUrl, this.webPath);

  Map<String, dynamic> toJson() => {
        'host': host,
        'webdavusername': webdavusername,
        'password': password,
        'uploadPath': uploadPath,
        'customUrl': customUrl,
        'webPath': webPath,
      };

  static List keysList = [
    'remarkName',
    'host',
    'webdavusername',
    'password',
    'uploadPath',
    'customUrl',
    'webPath',
  ];
}
