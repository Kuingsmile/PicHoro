import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:f_logs/f_logs.dart';
import 'package:fluro/fluro.dart';

import 'package:horopic/router/application.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/pages/loading.dart';
import 'package:horopic/utils/global.dart';
import 'package:horopic/utils/event_bus_utils.dart';
import 'package:horopic/picture_host_manage/manage_api/alist_manage_api.dart';
import 'package:horopic/picture_host_configure/widgets/configure_widgets.dart';

class AlistConfig extends StatefulWidget {
  const AlistConfig({super.key});

  @override
  AlistConfigState createState() => AlistConfigState();
}

class AlistConfigState extends State<AlistConfig> {
  final _formKey = GlobalKey<FormState>();
  final _hostController = TextEditingController();
  final _adminTokenController = TextEditingController();
  final _alistusernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _uploadPathController = TextEditingController();
  final _alistWebpathController = TextEditingController();
  final _customUrlController = TextEditingController();
  String _currentJWT = '';
  bool _isAnonymous = false;

  @override
  void initState() {
    super.initState();
    _initConfig();
  }

  _initConfig() async {
    try {
      Map configMap = await AlistManageAPI.getConfigMap();
      _hostController.text = configMap['host'] ?? '';
      _currentJWT = configMap['token'] ?? '';
      _isAnonymous = configMap['token'] == '' ? true : false;
      setControllerText(_adminTokenController, configMap['adminToken']);
      setControllerText(_alistusernameController, configMap['alistusername']);
      setControllerText(_passwordController, configMap['password']);
      setControllerText(_uploadPathController, configMap['uploadPath']);
      setControllerText(_alistWebpathController, configMap['webPath']);
      setControllerText(_customUrlController, configMap['customUrl']);
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
    _adminTokenController.dispose();
    _alistusernameController.dispose();
    _passwordController.dispose();
    _uploadPathController.dispose();
    _alistWebpathController.dispose();
    _customUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ConfigureWidgets.buildConfigAppBar(title: 'Alist参数配置', context: context),
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
                  hintText: '例如: https://alist.test.com',
                  prefixIcon: Icons.link,
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
                  controller: _adminTokenController,
                  labelText: '管理员token',
                  hintText: '输入管理员token（可选）',
                  prefixIcon: Icons.vpn_key,
                ),
                ConfigureWidgets.buildFormField(
                  controller: _alistusernameController,
                  labelText: '用户名',
                  hintText: '设定用户名（可选）',
                  prefixIcon: Icons.person,
                ),
                ConfigureWidgets.buildFormField(
                  controller: _passwordController,
                  labelText: '密码',
                  hintText: '输入密码（可选）',
                  prefixIcon: Icons.lock,
                  obscureText: true,
                ),
              ],
            ),
            ConfigureWidgets.buildSettingCard(
              title: '路径设置',
              children: [
                ConfigureWidgets.buildFormField(
                  controller: _uploadPathController,
                  labelText: '储存路径',
                  hintText: '例如: /百度网盘/图床（可选）',
                  prefixIcon: Icons.folder,
                ),
                ConfigureWidgets.buildFormField(
                  controller: _alistWebpathController,
                  labelText: '拼接路径',
                  hintText: '例如: /pic（可选）',
                  prefixIcon: Icons.link,
                ),
                ConfigureWidgets.buildFormField(
                  controller: _customUrlController,
                  labelText: '自定义URL',
                  hintText: '例如: https://cdn.test.com（可选）',
                  prefixIcon: Icons.language,
                ),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withAlpha(51),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.public, color: Theme.of(context).primaryColor),
                  ),
                  title: const Text('匿名访问'),
                  trailing: Switch(
                    value: _isAnonymous,
                    onChanged: (value) {
                      setState(() {
                        _isAnonymous = value;
                      });
                    },
                    activeColor: Theme.of(context).primaryColor,
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
                    final isValid = _formKey.currentState!.validate();
                    if (isValid) {
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
                          requestCallBack: checkAlistConfig(),
                        );
                      },
                    );
                  },
                ),
                ConfigureWidgets.buildDivider(),
                ConfigureWidgets.buildSettingItem(
                  context: context,
                  title: '设置备用配置',
                  icon: Icons.settings_backup_restore,
                  onTap: () async {
                    await Application.router
                        .navigateTo(context, '/configureStorePage?psHost=alist', transition: TransitionType.cupertino);
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
            ConfigureWidgets.buildSettingCard(
              title: '当前Token状态',
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: SelectableText(
                    _currentJWT == '' ? '未配置' : _currentJWT,
                    style: TextStyle(
                      color: _currentJWT == '' ? Colors.red : Colors.blue,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> saveConfigHelper(String host, String adminToken, String alistusername, String password, String token,
      String uploadPath, String webPath, String customUrl) async {
    final alistConfig =
        AlistConfigModel(host, adminToken, alistusername, password, token, uploadPath, webPath, customUrl);
    final alistConfigJson = jsonEncode(alistConfig);
    final alistConfigFile = await AlistManageAPI.localFile;
    await alistConfigFile.writeAsString(alistConfigJson);
  }

  Future<void> _saveAlistConfig() async {
    return Future.microtask(() async {
      // Format and validate input fields
      String host = _formatHost(_hostController.text);
      String uploadPath = _formatPath(_uploadPathController.text, 'None');
      String customUrl = _formatPath(_customUrlController.text, 'None');
      String webPath = _formatWebPath(_alistWebpathController.text);
      String adminToken = _formatToken(_adminTokenController.text);
      final alistusername = _alistusernameController.text.trim();
      final password = _passwordController.text.trim();
      String token = '';

      // Handle anonymous mode
      if (_isAnonymous) {
        await saveConfigHelper(host, 'None', 'None', 'None', '', uploadPath, webPath, customUrl);
        if (!mounted) return;
        setState(() {});
        showToast('保存成功');
        return;
      }

      // Try using admin token if available
      if (adminToken != 'None') {
        _currentJWT = adminToken;
        await saveConfigHelper(host, adminToken, alistusername, password, adminToken, uploadPath, webPath, customUrl);
        if (!mounted) return;
        setState(() {});
        if (context.mounted) {
          return showCupertinoAlertDialog(
              context: context,
              barrierDismissible: false,
              title: '配置成功',
              content: '您的密钥为：\n$adminToken,\n请妥善保管，不要泄露给他人');
        }
        return;
      }

      try {
        // Try username/password authentication
        if (alistusername.isNotEmpty && password.isNotEmpty) {
          var res = await AlistManageAPI.getToken(host, alistusername, password);
          if (res[0] == 'success') {
            token = res[1];
            _currentJWT = token;
            await saveConfigHelper(host, 'None', alistusername, password, token, uploadPath, webPath, customUrl);
            if (!mounted) return;
            setState(() {});
            if (context.mounted) {
              return showCupertinoAlertDialog(
                  context: context,
                  barrierDismissible: false,
                  title: '配置成功',
                  content: '您的密钥为：\n$token,\n请妥善保管，不要泄露给他人');
            }
            return;
          }
          showToast('获取token失败');
          return;
        }

        // Try using existing token
        if (_currentJWT.isNotEmpty) {
          await _validateAndSaveExistingToken(host, uploadPath, webPath, customUrl);
          return;
        }

        showToast('请提供有效的身份验证信息');
      } catch (e) {
        FLog.error(
            className: 'AlistConfigPage',
            methodName: '_saveAlistConfig',
            text: formatErrorMessage({}, e.toString()),
            dataLogType: DataLogType.ERRORS.toString());
        if (context.mounted) {
          showCupertinoAlertDialog(context: context, title: '错误', content: e.toString());
        }
      }
    });
  }

  String _formatHost(String value) {
    String host = value.trim().replaceAll(RegExp(r'/+$'), '');
    if (!host.startsWith('http://') && !host.startsWith('https://')) {
      host = 'http://$host';
    }
    return host;
  }

  String _formatPath(String value, String defaultValue) {
    String path = value.trim();
    return (path.isEmpty || path == '/') ? defaultValue : path.replaceAll(RegExp(r'/+$'), '');
  }

  String _formatWebPath(String value) {
    String path = value.trim();
    if (path.isEmpty) {
      return 'None';
    }
    return path.endsWith('/') ? path : '$path/';
  }

  String _formatToken(String value) {
    return value.trim().isEmpty ? 'None' : value.trim();
  }

  Future<void> _validateAndSaveExistingToken(String host, String uploadPath, String webPath, String customUrl) async {
    BaseOptions options = setBaseOptions();
    options.headers = {
      "Content-type": "application/json",
      "Authorization": _currentJWT,
    };

    Dio dio = Dio(options);
    var response = await dio.get('$host/api/admin/setting/list', queryParameters: {'group': 0});

    if (response.statusCode == 200 && response.data['message'] == 'success') {
      Map configMap = await AlistManageAPI.getConfigMap();
      await saveConfigHelper(
          host, 'None', configMap['alistusername'], configMap['password'], _currentJWT, uploadPath, webPath, customUrl);

      if (!mounted) return;
      setState(() {});

      if (context.mounted) {
        showCupertinoAlertDialog(
            context: context,
            barrierDismissible: false,
            title: '配置成功',
            content: '您的密钥为：\n$_currentJWT,\n请妥善保管，不要泄露给他人');
      }
    } else {
      showToast('配置失败');
    }
  }

  checkAlistConfig() async {
    try {
      Map configMap = await AlistManageAPI.getConfigMap();
      if (configMap.isEmpty) {
        if (context.mounted) {
          return showCupertinoAlertDialog(context: context, title: "检查失败!", content: "请先配置上传参数.");
        }
        return;
      }
      String token = configMap['token'];
      String uploadPath = configMap['uploadPath'];

      BaseOptions options = setBaseOptions();

      if (token == '') {
        Map<String, dynamic> dataMap = {
          "page": 1,
          "path": uploadPath == 'None' ? '/' : uploadPath,
          "per_page": 1000,
          "refresh": false,
        };
        options.headers = {
          "Authorization": configMap["token"],
          "Content-type": "application/json",
        };
        String profileUrl = configMap["host"] + "/api/fs/list";
        Dio dio = Dio(options);
        var response = await dio.post(profileUrl, data: dataMap);
        if (response.statusCode == 200 && response.data['message'] == 'success') {
          if (context.mounted) {
            return showCupertinoAlertDialog(
                context: context,
                title: '通知',
                content:
                    '检测通过，您的配置信息为：\nhost:\n${configMap["host"]}\n管理员token:\n${configMap["adminToken"]}\n用户名:\n${configMap["alistusername"]}\n密码:\n${configMap["password"]}\ntoken:\n${configMap["token"]}\nuploadPath:\n${configMap["uploadPath"]}\nwebPath:\n${configMap["webPath"]}\n自定义网址:\n${configMap["customUrl"]}');
          }
          return;
        } else {
          if (context.mounted) {
            return showCupertinoAlertDialog(context: context, title: '通知', content: '检测失败，请检查配置信息');
          }
          return;
        }
      }
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
        if (context.mounted) {
          return showCupertinoAlertDialog(
              context: context,
              title: '通知',
              content:
                  '检测通过，您的配置信息为：\nhost:\n${configMap["host"]}\n管理员token:\n${configMap["adminToken"]}\n用户名:\n${configMap["alistusername"]}\n密码:\n${configMap["password"]}\ntoken:\n${configMap["token"]}\nuploadPath:\n${configMap["uploadPath"]}\nwebPath:\n${configMap["webPath"]}\n自定义网址:\n${configMap["customUrl"]}');
        }
        return;
      } else {
        if (context.mounted) {
          return showCupertinoAlertDialog(context: context, title: '通知', content: '检测失败，请检查配置信息');
        }
        return;
      }
    } catch (e) {
      FLog.error(
          className: 'ConfigPage',
          methodName: 'checkAlistConfig',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      if (context.mounted) {
        return showCupertinoAlertDialog(context: context, title: "检查失败!", content: e.toString());
      }
      return;
    }
  }

  _setdefault() {
    Global.setPShost('alist');
    Global.setShowedPBhost('PBhostExtend3');
    eventBus.fire(AlbumRefreshEvent(albumKeepAlive: false));
    eventBus.fire(HomePhotoRefreshEvent(homePhotoKeepAlive: false));
    showToast('已设置Alist为默认图床');
  }
}

class AlistConfigModel {
  final String host;
  final String adminToken;
  final String alistusername;
  final String password;
  final String token;
  final String uploadPath;
  final String webPath;
  final String customUrl;

  AlistConfigModel(this.host, this.adminToken, this.alistusername, this.password, this.token, this.uploadPath,
      this.webPath, this.customUrl);

  Map<String, dynamic> toJson() => {
        'host': host,
        'adminToken': adminToken,
        'alistusername': alistusername,
        'password': password,
        'token': token,
        'uploadPath': uploadPath,
        'webPath': webPath,
        'customUrl': customUrl,
      };

  static List keysList = [
    'remarkName',
    'host',
    'adminToken',
    'alistusername',
    'password',
    'token',
    'uploadPath',
    'webPath',
    'customUrl'
  ];
}
