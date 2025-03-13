import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluro/fluro.dart';
import 'package:horopic/api/upyun_api.dart';
import 'package:path_provider/path_provider.dart';

import 'package:horopic/router/application.dart';
import 'package:horopic/widgets/net_loading_dialog.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/utils/global.dart';
import 'package:horopic/utils/event_bus_utils.dart';
import 'package:horopic/picture_host_manage/manage_api/upyun_manage_api.dart';
import 'package:horopic/widgets/configure_widgets.dart';

class UpyunConfig extends StatefulWidget {
  const UpyunConfig({super.key});

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
  final _antiLeechTokenController = TextEditingController();
  final _antiLeechExpirationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initConfig();
  }

  _initConfig() async {
    try {
      Map configMap = await UpyunManageAPI.getConfigMap();
      _bucketController.text = configMap['bucket'] ?? '';
      _operatorController.text = configMap['operator'] ?? '';
      _passwordController.text = configMap['password'] ?? '';
      _urlController.text = configMap['url'] ?? '';
      setControllerText(_optionsController, configMap['options']);
      setControllerText(_pathController, configMap['path']);
      setControllerText(_antiLeechTokenController, configMap['antiLeechToken']);
      setControllerText(_antiLeechExpirationController, configMap['antiLeechExpiration']);
    } catch (e) {
      flogErr(e, {}, 'UpyunConfigState', '_initCongfig');
    }
  }

  @override
  void dispose() {
    _bucketController.dispose();
    _operatorController.dispose();
    _passwordController.dispose();
    _urlController.dispose();
    _optionsController.dispose();
    _pathController.dispose();
    _antiLeechTokenController.dispose();
    _antiLeechExpirationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ConfigureWidgets.buildConfigAppBar(title: '又拍云参数配置', context: context),
      body: Form(
        key: _formKey,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            ConfigureWidgets.buildSettingCard(
              title: '基本配置',
              children: [
                ConfigureWidgets.buildFormField(
                  controller: _bucketController,
                  labelText: 'bucket',
                  hintText: '请输入bucket',
                  prefixIcon: Icons.storage,
                  validator: (value) {
                    if (value == null || value.isEmpty || value.trim() == '') {
                      return '请输入bucket';
                    }
                    return null;
                  },
                ),
                ConfigureWidgets.buildFormField(
                  controller: _operatorController,
                  labelText: '操作员',
                  hintText: '请输入操作员',
                  prefixIcon: Icons.person,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入操作员';
                    }
                    return null;
                  },
                ),
                ConfigureWidgets.buildFormField(
                  controller: _passwordController,
                  labelText: '密码',
                  hintText: '请输入密码',
                  prefixIcon: Icons.lock,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入密码';
                    }
                    return null;
                  },
                ),
                ConfigureWidgets.buildFormField(
                  controller: _urlController,
                  labelText: '加速域名',
                  hintText: '例如http://xxx.test.upcdn.net',
                  prefixIcon: Icons.link,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入加速域名';
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
                  controller: _optionsController,
                  labelText: '网站后缀',
                  hintText: '例如!/fwfh/500x500',
                  prefixIcon: Icons.settings,
                ),
                ConfigureWidgets.buildFormField(
                  controller: _pathController,
                  labelText: '存储路径',
                  hintText: '例如test/',
                  prefixIcon: Icons.folder,
                ),
                ConfigureWidgets.buildFormField(
                  controller: _antiLeechTokenController,
                  labelText: '防盗链Token',
                  hintText: '例如abc',
                  prefixIcon: Icons.security,
                ),
                ConfigureWidgets.buildFormField(
                  controller: _antiLeechExpirationController,
                  labelText: '防盗链过期时间',
                  hintText: '例如3600,单位秒',
                  prefixIcon: Icons.timer,
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
                              requestCallBack: _saveUpyunConfig(),
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
                            requestCallBack: checkUpyunConfig(),
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
                        .navigateTo(context, '/configureStorePage?psHost=upyun', transition: TransitionType.cupertino);
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

  Future _saveUpyunConfig() async {
    try {
      String bucket = _bucketController.text.trim();
      String upyunOperator = _operatorController.text.trim();
      String password = _passwordController.text.trim();
      String url = _urlController.text.trim();
      String options = _optionsController.text.trim();
      String path = _pathController.text.trim();
      String antiLeechToken = _antiLeechTokenController.text.trim();
      String antiLeechExpiration = _antiLeechExpirationController.text.trim();

      //格式化路径为以/结尾，不以/开头
      if (path.isEmpty || path == '/') {
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

      final upyunConfig =
          UpyunConfigModel(bucket, upyunOperator, password, url, options, path, antiLeechToken, antiLeechExpiration);
      final upyunConfigJson = jsonEncode(upyunConfig);
      final upyunConfigFile = await UpyunManageAPI.localFile;
      await upyunConfigFile.writeAsString(upyunConfigJson);
      showToast('保存成功');
    } catch (e) {
      flogErr(e, {}, 'UpyunConfigPageState', 'saveConfig');
      if (context.mounted) {
        return showCupertinoAlertDialog(context: context, title: '错误', content: e.toString());
      }
    }
  }

  checkUpyunConfig() async {
    try {
      Map configMap = await UpyunManageAPI.getConfigMap();

      if (configMap.isEmpty) {
        if (context.mounted) {
          return showCupertinoAlertDialog(context: context, title: "检查失败!", content: "请先配置上传参数.");
        }
        return;
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
        List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
        await assetFile.writeAsBytes(bytes);
      }
      String key = 'PicHoroValidate.jpeg';
      var checkResult = await UpyunImageUploadUtils.uploadApi(path: assetFilePath, name: key, configMap: configMap);
      if (checkResult[0] == 'success') {
        if (context.mounted) {
          return showCupertinoAlertDialog(context: context, title: '通知', content: """检测通过，您的配置信息为:
Bucket:
${configMap['bucket']}
Operator:
${configMap['operator']}
Password:
${configMap['password']}
Url:
${configMap['url']}
Options:
${configMap['options']}
Path:
${configMap['path']}
AntiLeechToken:
${configMap['antiLeechToken']}
AntiLeechExpiration:
${configMap['antiLeechExpiration']}
""");
        }
      } else {
        if (context.mounted) {
          return showCupertinoAlertDialog(context: context, title: '错误', content: '检查失败，请检查配置信息');
        }
      }
    } catch (e) {
      flogErr(e, {}, 'UpyunConfigPageState', 'checkUpyunConfig');
      if (context.mounted) {
        return showCupertinoAlertDialog(context: context, title: "检查失败!", content: e.toString());
      }
    }
  }

  _setdefault() {
    Global.setPShost('upyun');
    Global.setShowedPBhost('upyun');
    eventBus.fire(AlbumRefreshEvent(albumKeepAlive: false));
    eventBus.fire(HomePhotoRefreshEvent(homePhotoKeepAlive: false));
    showToast('已设置又拍云为默认图床');
  }
}

class UpyunConfigModel {
  final String bucket;
  final String upyunoperator;
  final String password;
  final String url;
  final String options;
  final String path;
  final String antiLeechToken;
  final String antiLeechExpiration;

  UpyunConfigModel(this.bucket, this.upyunoperator, this.password, this.url, this.options, this.path,
      this.antiLeechToken, this.antiLeechExpiration);

  Map<String, dynamic> toJson() => {
        'bucket': bucket,
        'operator': upyunoperator,
        'password': password,
        'url': url,
        'options': options,
        'path': path,
        'antiLeechToken': antiLeechToken,
        'antiLeechExpiration': antiLeechExpiration,
      };

  static List keysList = [
    'remarkName',
    'bucket',
    'operator',
    'password',
    'url',
    'options',
    'path',
    'antiLeechToken',
    'antiLeechExpiration',
  ];
}
