import 'dart:io';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:f_logs/f_logs.dart';
import 'package:fluro/fluro.dart';
import 'package:path_provider/path_provider.dart';

import 'package:horopic/router/application.dart';
import 'package:horopic/api/tencent_api.dart';
import 'package:horopic/pages/loading.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/utils/global.dart';
import 'package:horopic/utils/event_bus_utils.dart';
import 'package:horopic/picture_host_manage/manage_api/tencent_manage_api.dart';
import 'package:horopic/picture_host_configure/widgets/configure_widgets.dart';

class TencentConfig extends StatefulWidget {
  const TencentConfig({super.key});

  @override
  TencentConfigState createState() => TencentConfigState();
}

class TencentConfigState extends State<TencentConfig> {
  final _formKey = GlobalKey<FormState>();

  final _secretIdController = TextEditingController();
  final _secretKeyController = TextEditingController();
  final _bucketController = TextEditingController();
  final _appIdController = TextEditingController();
  final _areaController = TextEditingController();
  final _pathController = TextEditingController();
  final _customUrlController = TextEditingController();
  final _optionsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initConfig();
  }

  _initConfig() async {
    try {
      Map configMap = await TencentManageAPI.getConfigMap();
      _secretIdController.text = configMap['secretId'] ?? '';
      _secretKeyController.text = configMap['secretKey'] ?? '';
      _bucketController.text = configMap['bucket'] ?? '';
      _appIdController.text = configMap['appId'] ?? '';
      _areaController.text = configMap['area'] ?? '';
      setControllerText(_pathController, configMap['path']);
      setControllerText(_customUrlController, configMap['customUrl']);
      setControllerText(_optionsController, configMap['options']);
      setState(() {});
    } catch (e) {
      FLog.error(
          className: 'TencentConfigState',
          methodName: 'initConfig',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
    }
  }

  @override
  void dispose() {
    _secretIdController.dispose();
    _secretKeyController.dispose();
    _bucketController.dispose();
    _appIdController.dispose();
    _areaController.dispose();
    _pathController.dispose();
    _customUrlController.dispose();
    _optionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ConfigureWidgets.buildConfigAppBar(title: '腾讯云参数配置', context: context),
      body: Form(
        key: _formKey,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            ConfigureWidgets.buildSettingCard(
              title: '基本配置',
              children: [
                ConfigureWidgets.buildFormField(
                  controller: _secretIdController,
                  labelText: 'secretId',
                  hintText: '请输入secretId',
                  prefixIcon: Icons.vpn_key,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入secretId';
                    }
                    return null;
                  },
                ),
                ConfigureWidgets.buildFormField(
                  controller: _secretKeyController,
                  labelText: 'secretKey',
                  hintText: '请输入secretKey',
                  prefixIcon: Icons.lock,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入secretKey';
                    }
                    return null;
                  },
                ),
                ConfigureWidgets.buildFormField(
                  controller: _bucketController,
                  labelText: 'bucket',
                  hintText: '如test-12345678',
                  prefixIcon: Icons.storage,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入bucket';
                    }
                    return null;
                  },
                ),
                ConfigureWidgets.buildFormField(
                  controller: _appIdController,
                  labelText: 'appId',
                  hintText: '例如1234567890',
                  prefixIcon: Icons.app_registration,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入appId';
                    }
                    return null;
                  },
                ),
                ConfigureWidgets.buildFormField(
                  controller: _areaController,
                  labelText: '存储区域',
                  hintText: '例如ap-nanjing',
                  prefixIcon: Icons.location_on,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入存储区域';
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
                  controller: _pathController,
                  labelText: '存储路径',
                  hintText: '例如test/',
                  prefixIcon: Icons.folder,
                ),
                ConfigureWidgets.buildFormField(
                  controller: _customUrlController,
                  labelText: '自定义域名',
                  hintText: '例如https://test.com',
                  prefixIcon: Icons.link,
                ),
                ConfigureWidgets.buildFormField(
                  controller: _optionsController,
                  labelText: '网站后缀',
                  hintText: '例如?imageMogr2',
                  prefixIcon: Icons.settings,
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
                              requestCallBack: _saveTencentConfig(),
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
                            requestCallBack: checkTencentConfig(),
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
                    await Application.router.navigateTo(context, '/configureStorePage?psHost=tencent',
                        transition: TransitionType.cupertino);
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

  Future _saveTencentConfig() async {
    try {
      String secretId = _secretIdController.text.trim();
      String secretKey = _secretKeyController.text.trim();
      String bucket = _bucketController.text.trim();
      String appId = _appIdController.text.trim();
      String area = _areaController.text.trim();
      String path = _pathController.text.trim();
      String customUrl = _customUrlController.text.trim();
      String options = _optionsController.text.trim();
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
      if (customUrl.isEmpty) {
        customUrl = 'None';
      } else if (!customUrl.startsWith('http') && !customUrl.startsWith('https')) {
        customUrl = 'http://$customUrl';
      }

      if (customUrl.endsWith('/')) {
        customUrl = customUrl.substring(0, customUrl.length - 1);
      }
      //格式化网站后缀，以?开头
      if (_optionsController.text.isNotEmpty) {
        options = _optionsController.text;
        if (!options.startsWith('?')) {
          options = '?$options';
        }
      } else {
        options = 'None';
      }

      final tencentConfig = TencentConfigModel(secretId, secretKey, bucket, appId, area, path, customUrl, options);
      final tencentConfigJson = jsonEncode(tencentConfig);
      final tencentConfigFile = await TencentManageAPI.localFile;
      await tencentConfigFile.writeAsString(tencentConfigJson);
      showToast('保存成功');
    } catch (e) {
      FLog.error(
          className: 'TencentConfigPage',
          methodName: 'saveConfig',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      if (context.mounted) {
        return showCupertinoAlertDialog(context: context, title: '错误', content: e.toString());
      }
    }
  }

  checkTencentConfig() async {
    try {
      Map configMap = await TencentManageAPI.getConfigMap();

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
      String host = '${configMap['bucket']}.cos.${configMap['area']}.myqcloud.com';
      String urlpath = '';
      if (configMap['path'] != 'None') {
        urlpath = '${configMap['path']}$key';
      } else {
        urlpath = key;
      }

      int startTimestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      int endTimestamp = startTimestamp + 86400;
      String keyTime = '$startTimestamp;$endTimestamp';
      Map<String, dynamic> uploadPolicy = {
        "expiration": "2033-03-03T09:38:12.414Z",
        "conditions": [
          {"acl": "default"},
          {"bucket": configMap['bucket']},
          {"key": urlpath},
          {"q-sign-algorithm": "sha1"},
          {"q-ak": configMap['secretId']},
          {"q-sign-time": keyTime}
        ]
      };
      String uploadPolicyStr = jsonEncode(uploadPolicy);
      String singature =
          TencentImageUploadUtils.getUploadAuthorization(configMap['secretKey'], keyTime, uploadPolicyStr);
      //policy中的字段，除了bucket，其它的都要在formdata中添加
      FormData formData = FormData.fromMap({
        'key': urlpath,
        'policy': base64Encode(utf8.encode(uploadPolicyStr)),
        'acl': 'default',
        'q-sign-algorithm': 'sha1',
        'q-ak': configMap['secretId'],
        'q-key-time': keyTime,
        'q-sign-time': keyTime,
        'q-signature': singature,
        'file': await MultipartFile.fromFile(assetFilePath, filename: key),
      });

      BaseOptions baseoptions = setBaseOptions();
      String contentLength = await assetFile.length().then((value) {
        return value.toString();
      });
      baseoptions.headers = {
        'Host': host,
        'Content-Type': Global.multipartString,
        'Content-Length': contentLength,
      };
      Dio dio = Dio(baseoptions);
      var response = await dio.post(
        'http://$host',
        data: formData,
      );

      if (response.statusCode == 204) {
        if (context.mounted) {
          return showCupertinoAlertDialog(context: context, title: '通知', content: """检测通过，您的配置信息为:
secretId:
${configMap['secretId']}
secretKey:
${configMap['secretKey']}
bucket:
${configMap['bucket']}
appId:
${configMap['appId']}
area:
${configMap['area']}
path:
${configMap['path']}
customUrl:
${configMap['customUrl']}
options:
${configMap['options']}
""");
        }
      } else {
        if (context.mounted) {
          return showCupertinoAlertDialog(context: context, title: '错误', content: '检查失败，请检查配置信息');
        }
      }
    } catch (e) {
      FLog.error(
          className: 'TencentConfigPage',
          methodName: 'checkTencentConfig',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      if (context.mounted) {
        return showCupertinoAlertDialog(context: context, title: "检查失败!", content: e.toString());
      }
    }
  }

  _setdefault() {
    Global.setPShost('tencent');
    Global.setShowedPBhost('tencent');
    eventBus.fire(AlbumRefreshEvent(albumKeepAlive: false));
    eventBus.fire(HomePhotoRefreshEvent(homePhotoKeepAlive: false));
    showToast('已设置腾讯云为默认图床');
  }
}

class TencentConfigModel {
  final String secretId;
  final String secretKey;
  final String bucket;
  final String appId;
  final String area;
  final String path;
  final String customUrl;
  final String options;

  TencentConfigModel(
      this.secretId, this.secretKey, this.bucket, this.appId, this.area, this.path, this.customUrl, this.options);

  Map<String, dynamic> toJson() => {
        'secretId': secretId,
        'secretKey': secretKey,
        'bucket': bucket,
        'appId': appId,
        'area': area,
        'path': path,
        'customUrl': customUrl,
        'options': options,
      };

  static List keysList = [
    'remarkName',
    'secretId',
    'secretKey',
    'bucket',
    'appId',
    'area',
    'path',
    'customUrl',
    'options',
  ];
}
