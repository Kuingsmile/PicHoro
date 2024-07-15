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

class AwsConfig extends StatefulWidget {
  const AwsConfig({Key? key}) : super(key: key);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: titleText('S3兼容平台配置'),
        actions: [
          IconButton(
            onPressed: () async {
              await Application.router
                  .navigateTo(context, '/configureStorePage?psHost=aws', transition: TransitionType.cupertino);
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
              controller: _accessKeyIDController,
              decoration: const InputDecoration(
                label: Center(child: Text('Access Key ID')),
                hintText: '设定Access Key ID',
              ),
              textAlign: TextAlign.center,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Access Key ID不能为空';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _secretAccessKeyController,
              decoration: const InputDecoration(
                label: Center(child: Text('Secret Access Key')),
                hintText: '设定Secret Access Key',
              ),
              textAlign: TextAlign.center,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Secret Access Key不能为空';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _bucketController,
              decoration: const InputDecoration(
                label: Center(child: Text('bucket')),
                hintText: '设定bucket',
              ),
              textAlign: TextAlign.center,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入bucket';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _endpointController,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.zero,
                label: Center(child: Text('endpoint')),
                hintText: '例如s3.us-west-2.amazonaws.com',
              ),
              textAlign: TextAlign.center,
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
            TextFormField(
              controller: _regionController,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.zero,
                label: Center(child: Text('可选：存储区域')),
                hintText: '例如us-west-2',
              ),
              textAlign: TextAlign.center,
            ),
            TextFormField(
              controller: _uploadPathController,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.zero,
                label: Center(child: Text('可选:存储路径')),
                hintText: '例如test/',
                hintStyle: TextStyle(fontSize: 13),
              ),
              textAlign: TextAlign.center,
            ),
            TextFormField(
              controller: _customUrlController,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.zero,
                label: Center(child: Text('可选:自定义域名')),
                hintText: '例如https://test.com',
                hintStyle: TextStyle(fontSize: 13),
              ),
              textAlign: TextAlign.center,
            ),
            ListTile(
              title: const Text('是否使用S3路径风格'),
              trailing: Switch(
                value: isS3PathStyle,
                onChanged: (value) {
                  setState(() {
                    isS3PathStyle = value;
                  });
                },
              ),
            ),
            ListTile(
              title: const Text('是否启用SSL连接'),
              trailing: Switch(
                value: isEnableSSL,
                onChanged: (value) {
                  setState(() {
                    isEnableSSL = value;
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
                          requestCallBack: _saveAwsConfig(),
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
                        requestCallBack: checkAwsConfig(),
                      );
                    });
              },
              child: titleText('检查当前配置', fontsize: null),
            )),
            ListTile(
                title: ElevatedButton(
              onPressed: () async {
                await Application.router
                    .navigateTo(context, '/configureStorePage?psHost=aws', transition: TransitionType.cupertino);
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

  _setdefault() async {
    await Global.setPShost('aws');
    await Global.setShowedPBhost('PBhostExtend2');
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
