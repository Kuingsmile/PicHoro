import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:f_logs/f_logs.dart';
import 'package:fluro/fluro.dart';
import 'package:path_provider/path_provider.dart';
import 'package:minio_new/minio.dart';

import 'package:horopic/router/application.dart';
import 'package:horopic/pages/loading.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/utils/sql_utils.dart';
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

  @override
  void initState() {
    super.initState();
    _initConfig();
  }

  _initConfig() async {
    try {
      Map configMap = await AwsManageAPI.getConfigMap();
      _accessKeyIDController.text = configMap['accessKeyId'];
      _secretAccessKeyController.text = configMap['secretAccessKey'];
      _bucketController.text = configMap['bucket'];
      _endpointController.text = configMap['endpoint'];

      if (configMap['region'] != 'None') {
        _regionController.text = configMap['region'];
      } else {
        _regionController.clear();
      }

      if (configMap['uploadPath'] != 'None') {
        _uploadPathController.text = configMap['uploadPath'];
      } else {
        _uploadPathController.clear();
      }

      if (configMap['customUrl'] != 'None') {
        _customUrlController.text = configMap['customUrl'];
      } else {
        _customUrlController.clear();
      }
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
              await Application.router.navigateTo(
                  context, '/configureStorePage?psHost=aws',
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
                if (value.startsWith('http://') ||
                    value.startsWith('https://')) {
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
                await Application.router.navigateTo(
                    context, '/configureStorePage?psHost=aws',
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
          ],
        ),
      ),
    );
  }

  Future _saveAwsConfig() async {
    try {
      String accessKeyID = _accessKeyIDController.text;
      String secretAccessKey = _secretAccessKeyController.text;
      String bucket = _bucketController.text;
      String endpoint = _endpointController.text;
      String region = _regionController.text;
      String uploadPath = _uploadPathController.text;
      String customUrl = _customUrlController.text;
      //格式化路径为以/结尾，不以/开头
      if (uploadPath.isEmpty || uploadPath.trim().isEmpty) {
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
      } else if (!customUrl.startsWith('http') &&
          !customUrl.startsWith('https')) {
        customUrl = 'http://$customUrl';
      }

      if (customUrl.endsWith('/')) {
        customUrl = customUrl.substring(0, customUrl.length - 1);
      }

      if (region.isEmpty || region.trim().isEmpty) {
        region = 'None';
      }

      List sqlconfig = [];
      sqlconfig.add(accessKeyID);
      sqlconfig.add(secretAccessKey);
      sqlconfig.add(bucket);
      sqlconfig.add(endpoint);
      sqlconfig.add(region);
      sqlconfig.add(uploadPath);
      sqlconfig.add(customUrl);
      //添加默认用户
      String defaultUser = await Global.getUser();
      sqlconfig.add(defaultUser);

      var queryAws = await MySqlUtils.queryAws(username: defaultUser);
      var queryuser = await MySqlUtils.queryUser(username: defaultUser);

      if (queryuser == 'Empty') {
        return showCupertinoAlertDialog(
            context: context, title: '错误', content: '用户不存在,请先登录');
      }

      var sqlResult = '';

      if (queryAws == 'Empty') {
        sqlResult = await MySqlUtils.insertAws(content: sqlconfig);
      } else {
        sqlResult = await MySqlUtils.updateAws(content: sqlconfig);
      }

      if (sqlResult == "Success") {
        final awsConfig = AwsConfigModel(
          accessKeyID,
          secretAccessKey,
          bucket,
          endpoint,
          region,
          uploadPath,
          customUrl,
        );
        final awsConfigJson = jsonEncode(awsConfig);
        final awsConfigFile = await localFile;
        await awsConfigFile.writeAsString(awsConfigJson);
        return showCupertinoAlertDialog(
            context: context, title: '成功', content: '配置成功');
      } else {
        return showCupertinoAlertDialog(
            context: context, title: '错误', content: '数据库错误');
      }
    } catch (e) {
      FLog.error(
          className: 'AwsConfigPage',
          methodName: 'saveConfig',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      return showCupertinoAlertDialog(
          context: context, title: '错误', content: e.toString());
    }
  }

  checkAwsConfig() async {
    try {
      final awsConfigFile = await localFile;
      String configData = await awsConfigFile.readAsString();

      if (configData == "Error") {
        return showCupertinoAlertDialog(
            context: context, title: "检查失败!", content: "请先配置上传参数.");
      }

      Map configMap = jsonDecode(configData);
      String accessKeyID = configMap['accessKeyId'];
      String secretAccessKey = configMap['secretAccessKey'];
      String bucket = configMap['bucket'];
      String endpoint = configMap['endpoint'];
      String region = configMap['region'];
      Minio minio;
      if (region == 'None') {
        minio = Minio(
          endPoint: endpoint,
          accessKey: accessKeyID,
          secretKey: secretAccessKey,
        );
      } else {
        minio = Minio(
          endPoint: endpoint,
          accessKey: accessKeyID,
          secretKey: secretAccessKey,
          region: region,
        );
      }

      await minio.bucketExists(bucket);
      return showCupertinoAlertDialog(
          context: context,
          title: '通知',
          content:
              '检测通过，您的配置信息为:\nAccessKeyID:\n$accessKeyID\nSecretAccessKey:\n$secretAccessKey\nBucket:\n$bucket\nEndpoint:\n$endpoint\nRegion:\n$region\nUploadPath:\n${configMap['uploadPath']}\nCustomUrl:\n${configMap['customUrl']}');
    } catch (e) {
      FLog.error(
          className: 'AwsConfigPage',
          methodName: 'checkAwsConfig',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      return showCupertinoAlertDialog(
          context: context, title: "检查失败!", content: e.toString());
    }
  }

  Future<File> get localFile async {
    final path = await _localPath;
    String defaultUser = await Global.getUser();
    return File('$path/${defaultUser}_aws_config.txt');
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<String> readAwsConfig() async {
    try {
      final file = await localFile;
      String contents = await file.readAsString();
      return contents;
    } catch (e) {
      FLog.error(
          className: 'AwsConfigPage',
          methodName: 'readAwsConfig',
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

      var queryAws = await MySqlUtils.queryAws(username: defaultUser);
      if (queryAws == 'Empty') {
        return Fluttertoast.showToast(
            msg: "请先配置上传参数",
            toastLength: Toast.LENGTH_SHORT,
            timeInSecForIosWeb: 2,
            fontSize: 16.0);
      }
      if (queryAws == 'Error') {
        return Fluttertoast.showToast(
            msg: "Error",
            toastLength: Toast.LENGTH_SHORT,
            timeInSecForIosWeb: 2,
            fontSize: 16.0);
      }
      if (queryuser['defaultPShost'] == 'aws') {
        await Global.setPShost('aws');
        await Global.setShowedPBhost('PBhostExtend2');
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
        sqlconfig.add('aws');
        var updateResult = await MySqlUtils.updateUser(content: sqlconfig);
        if (updateResult == 'Success') {
          await Global.setPShost('aws');
          await Global.setShowedPBhost('PBhostExtend2');
          eventBus.fire(AlbumRefreshEvent(albumKeepAlive: false));
          eventBus.fire(HomePhotoRefreshEvent(homePhotoKeepAlive: false));
          showToast('已设置S3兼容平台为默认图床');
        } else {
          showToast('写入数据库失败');
        }
      }
    } catch (e) {
      FLog.error(
          className: 'AwsConfigPage',
          methodName: '_setdefault',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      showToastWithContext(context, '错误');
    }
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

  AwsConfigModel(this.accessKeyId, this.secretAccessKey, this.bucket,
      this.endpoint, this.region, this.uploadPath, this.customUrl);

  Map<String, dynamic> toJson() => {
        'accessKeyId': accessKeyId,
        'secretAccessKey': secretAccessKey,
        'bucket': bucket,
        'endpoint': endpoint,
        'region': region,
        'uploadPath': uploadPath,
        'customUrl': customUrl,
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
  ];
}
