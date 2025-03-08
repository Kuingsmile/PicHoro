import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:f_logs/f_logs.dart';
import 'package:fluro/fluro.dart';
import 'package:minio/minio.dart';

import 'package:horopic/router/application.dart';
import 'package:horopic/pages/loading.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/utils/global.dart';
import 'package:horopic/utils/event_bus_utils.dart';
import 'package:horopic/picture_host_manage/manage_api/aws_manage_api.dart';
import 'package:horopic/picture_host_configure/widgets/configure_widgets.dart';

class AwsConfig extends StatefulWidget {
  const AwsConfig({super.key});

  @override
  AwsConfigState createState() => AwsConfigState();
}

class AwsConfigState extends State<AwsConfig> {
  final _formKey = GlobalKey<FormState>();

  final _accessKeyIDController = TextEditingController();
  final _secretAccessKeyController = TextEditingController();
  final _bucketController = TextEditingController();
  final _endpointController = TextEditingController();
  final _regionController = TextEditingController();
  final _uploadPathController = TextEditingController();
  final _customUrlController = TextEditingController();
  bool isS3PathStyle = false;
  bool isEnableSSL = true;

  @override
  void initState() {
    super.initState();
    _initConfig();
  }

  _initConfig() async {
    try {
      Map configMap = await AwsManageAPI.getConfigMap();
      _accessKeyIDController.text = configMap['accessKeyId'] ?? '';
      _secretAccessKeyController.text = configMap['secretAccessKey'] ?? '';
      _bucketController.text = configMap['bucket'] ?? '';
      _endpointController.text = configMap['endpoint'] ?? '';
      setControllerText(_regionController, configMap['region']);
      setControllerText(_uploadPathController, configMap['uploadPath']);
      setControllerText(_customUrlController, configMap['customUrl']);
      isS3PathStyle = configMap['isS3PathStyle'] ?? false;
      isEnableSSL = configMap['isEnableSSL'] ?? true;
      setState(() {});
    } catch (e) {
      FLog.error(
          className: 'AwsConfigState',
          methodName: 'initConfig',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
    }
  }

  @override
  void dispose() {
    _accessKeyIDController.dispose();
    _secretAccessKeyController.dispose();
    _bucketController.dispose();
    _endpointController.dispose();
    _regionController.dispose();
    _uploadPathController.dispose();
    _customUrlController.dispose();
    super.dispose();
  }

  Widget _buildSwitchItem({
    required String title,
    required IconData icon,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withAlpha(51),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Theme.of(context).primaryColor),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(title)),
          Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ConfigureWidgets.buildConfigAppBar(title: 'S3兼容平台配置', context: context),
      body: Form(
        key: _formKey,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            ConfigureWidgets.buildSettingCard(
              title: '基本配置',
              children: [
                ConfigureWidgets.buildFormField(
                  controller: _accessKeyIDController,
                  labelText: 'Access Key ID',
                  prefixIcon: Icons.key,
                  hintText: '设定Access Key ID',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Access Key ID不能为空';
                    }
                    return null;
                  },
                ),
                ConfigureWidgets.buildFormField(
                  controller: _secretAccessKeyController,
                  labelText: 'Secret Access Key',
                  prefixIcon: Icons.security,
                  hintText: '设定Secret Access Key',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Secret Access Key不能为空';
                    }
                    return null;
                  },
                ),
                ConfigureWidgets.buildFormField(
                  controller: _bucketController,
                  labelText: 'Bucket',
                  prefixIcon: Icons.storage,
                  hintText: '设定bucket',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Bucket不能为空';
                    }
                    return null;
                  },
                ),
                ConfigureWidgets.buildFormField(
                  controller: _endpointController,
                  labelText: 'Endpoint',
                  prefixIcon: Icons.dns,
                  hintText: '例如s3.us-west-2.amazonaws.com',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入endpoint';
                    }
                    if (value.startsWith('http://') || value.startsWith('https://')) {
                      return 'endpoint不包含http://或https://';
                    }
                    return null;
                  },
                ),
              ],
            ),
            ConfigureWidgets.buildSettingCard(
              title: '高级配置',
              children: [
                ConfigureWidgets.buildFormField(
                  controller: _regionController,
                  labelText: '存储区域',
                  prefixIcon: Icons.map,
                  hintText: '例如us-west-2（可选）',
                ),
                ConfigureWidgets.buildFormField(
                  controller: _uploadPathController,
                  labelText: '存储路径',
                  prefixIcon: Icons.folder_outlined,
                  hintText: '例如test/（可选）',
                ),
                ConfigureWidgets.buildFormField(
                  controller: _customUrlController,
                  labelText: '自定义域名',
                  prefixIcon: Icons.link,
                  hintText: '例如https://test.com（可选）',
                ),
                _buildSwitchItem(
                  title: '是否使用S3路径风格',
                  icon: Icons.style,
                  value: isS3PathStyle,
                  onChanged: (value) {
                    setState(() {
                      isS3PathStyle = value;
                    });
                  },
                ),
                _buildSwitchItem(
                  title: '是否启用SSL连接',
                  icon: Icons.lock_outline,
                  value: isEnableSSL,
                  onChanged: (value) {
                    setState(() {
                      isEnableSSL = value;
                    });
                  },
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
                              requestCallBack: _saveAwsConfig(),
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
                            requestCallBack: checkAwsConfig(),
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
                        .navigateTo(context, '/configureStorePage?psHost=aws', transition: TransitionType.cupertino);
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

  Future _saveAwsConfig() async {
    try {
      String accessKeyID = _accessKeyIDController.text.trim();
      String secretAccessKey = _secretAccessKeyController.text.trim();
      String bucket = _bucketController.text.trim();
      String endpoint = _endpointController.text.trim();
      String region = _regionController.text.trim();
      String uploadPath = _uploadPathController.text.trim();
      String customUrl = _customUrlController.text.trim();
      //格式化路径为以/结尾，不以/开头
      if (uploadPath.isEmpty || uploadPath == '/') {
        uploadPath = 'None';
      } else {
        if (!uploadPath.endsWith('/')) {
          uploadPath = '$uploadPath/';
        }
        if (uploadPath.startsWith('/')) {
          uploadPath = uploadPath.substring(1);
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

      if (region.isEmpty) {
        region = 'None';
      }
      final awsConfig = AwsConfigModel(
          accessKeyID, secretAccessKey, bucket, endpoint, region, uploadPath, customUrl, isS3PathStyle, isEnableSSL);
      final awsConfigJson = jsonEncode(awsConfig);
      final awsConfigFile = await AwsManageAPI.localFile;
      await awsConfigFile.writeAsString(awsConfigJson);
      showToast('保存成功');
    } catch (e) {
      FLog.error(
          className: 'AwsConfigPage',
          methodName: 'saveConfig',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      if (context.mounted) {
        return showCupertinoAlertDialog(context: context, title: '错误', content: e.toString());
      }
    }
  }

  checkAwsConfig() async {
    try {
      Map configMap = await AwsManageAPI.getConfigMap();

      if (configMap.isEmpty) {
        if (context.mounted) {
          return showCupertinoAlertDialog(context: context, title: "检查失败!", content: "请先配置上传参数.");
        }
        return;
      }

      String accessKeyID = configMap['accessKeyId'];
      String secretAccessKey = configMap['secretAccessKey'];
      String bucket = configMap['bucket'];
      String endpoint = configMap['endpoint'];
      int? port;
      if (endpoint.contains(':')) {
        List<String> endpointList = endpoint.split(':');
        endpoint = endpointList[0];
        port = int.parse(endpointList[1]);
      }
      String region = configMap['region'];
      bool isEnableSSL = configMap['isEnableSSL'] ?? true;
      Minio minio;
      if (region == 'None') {
        minio = Minio(
          endPoint: endpoint,
          port: port,
          accessKey: accessKeyID,
          useSSL: isEnableSSL,
          secretKey: secretAccessKey,
        );
      } else {
        minio = Minio(
          endPoint: endpoint,
          port: port,
          accessKey: accessKeyID,
          secretKey: secretAccessKey,
          useSSL: isEnableSSL,
          region: region,
        );
      }

      await minio.bucketExists(bucket);
      if (context.mounted) {
        return showCupertinoAlertDialog(
            context: context,
            title: '通知',
            content:
                '检测通过，您的配置信息为:\nAccessKeyID:\n$accessKeyID\nSecretAccessKey:\n$secretAccessKey\nBucket:\n$bucket\nEndpoint:\n$endpoint\nRegion:\n$region\nUploadPath:\n${configMap['uploadPath']}\nCustomUrl:\n${configMap['customUrl']}\n是否使用S3路径风格:\n${configMap['isS3PathStyle']}\n是否启用SSL连接:\n$isEnableSSL');
      }
    } catch (e) {
      FLog.error(
          className: 'AwsConfigPage',
          methodName: 'checkAwsConfig',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      if (context.mounted) {
        return showCupertinoAlertDialog(context: context, title: "检查失败!", content: e.toString());
      }
    }
  }

  _setdefault() {
    Global.setPShost('aws');
    Global.setShowedPBhost('PBhostExtend2');
    eventBus.fire(AlbumRefreshEvent(albumKeepAlive: false));
    eventBus.fire(HomePhotoRefreshEvent(homePhotoKeepAlive: false));
    showToast('已设置S3兼容平台为默认图床');
  }
}

class AwsConfigModel {
  final String accessKeyId;
  final String secretAccessKey;
  final String bucket;
  final String endpoint;
  final String region;
  final String uploadPath;
  final String customUrl;
  final bool isS3PathStyle;
  final bool isEnableSSL;

  AwsConfigModel(this.accessKeyId, this.secretAccessKey, this.bucket, this.endpoint, this.region, this.uploadPath,
      this.customUrl, this.isS3PathStyle, this.isEnableSSL);

  Map<String, dynamic> toJson() => {
        'accessKeyId': accessKeyId,
        'secretAccessKey': secretAccessKey,
        'bucket': bucket,
        'endpoint': endpoint,
        'region': region,
        'uploadPath': uploadPath,
        'customUrl': customUrl,
        'isS3PathStyle': isS3PathStyle,
        'isEnableSSL': isEnableSSL,
      };

  static List keysList = [
    'remarkName',
    'accessKeyId',
    'secretAccessKey',
    'bucket',
    'endpoint',
    'region',
    'uploadPath',
    'customUrl',
    'isS3PathStyle',
    'isEnableSSL',
  ];
}
