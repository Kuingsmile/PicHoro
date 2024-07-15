import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:f_logs/f_logs.dart';
import 'package:fluro/fluro.dart';
import 'package:qiniu_flutter_sdk/qiniu_flutter_sdk.dart';
import 'package:path_provider/path_provider.dart';

import 'package:horopic/router/application.dart';
import 'package:horopic/pages/loading.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/utils/global.dart';
import 'package:horopic/utils/event_bus_utils.dart';
import 'package:horopic/api/qiniu_api.dart';
import 'package:horopic/picture_host_manage/manage_api/qiniu_manage_api.dart';

class QiniuConfig extends StatefulWidget {
  const QiniuConfig({Key? key}) : super(key: key);

  @override
  QiniuConfigState createState() => QiniuConfigState();
}

class QiniuConfigState extends State<QiniuConfig> {
  final _formKey = GlobalKey<FormState>();

  final _accessKeyController = TextEditingController();
  final _secretKeyController = TextEditingController();
  final _bucketController = TextEditingController();
  final _urlController = TextEditingController();
  final _areaController = TextEditingController();
  final _optionsController = TextEditingController();
  final _pathController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initConfig();
  }

  _initConfig() async {
    try {
      Map configMap = await QiniuManageAPI.getConfigMap();
      _accessKeyController.text = configMap['accessKey'] ?? '';
      _secretKeyController.text = configMap['secretKey'] ?? '';
      _bucketController.text = configMap['bucket'] ?? '';
      _urlController.text = configMap['url'] ?? '';
      _areaController.text = configMap['area'] ?? '';
      setControllerText(_optionsController, configMap['options']);
      setControllerText(_pathController, configMap['path']);
    } catch (e) {
      FLog.error(
          className: 'QiniuConfigState',
          methodName: '_initConfig',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
    }
  }

  @override
  void dispose() {
    _accessKeyController.dispose();
    _secretKeyController.dispose();
    _bucketController.dispose();
    _urlController.dispose();
    _areaController.dispose();
    _optionsController.dispose();
    _pathController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: titleText('七牛云参数配置'),
        actions: [
          IconButton(
            onPressed: () async {
              await Application.router
                  .navigateTo(context, '/configureStorePage?psHost=qiniu', transition: TransitionType.cupertino);
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
              controller: _accessKeyController,
              decoration: const InputDecoration(
                label: Center(child: Text('accessKey')),
                hintText: '设定accessKey',
              ),
              textAlign: TextAlign.center,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入accessKey';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _secretKeyController,
              decoration: const InputDecoration(
                label: Center(child: Text('secretKey')),
                hintText: '设定secretKey',
              ),
              textAlign: TextAlign.center,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入secretKey';
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
              controller: _urlController,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.zero,
                label: Center(child: Text('访问网址')),
                hintText: '例如:https://xxx.yyy.gld.clouddn.com',
              ),
              textAlign: TextAlign.center,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入访问网址';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _areaController,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.zero,
                label: Center(child: Text('存储区域')),
                hintText: '设定存储区域',
              ),
              textAlign: TextAlign.center,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入存储区域';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _optionsController,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.zero,
                label: Center(child: Text('可选:网站后缀')),
                hintText: '例如?imageslim',
                hintStyle: TextStyle(fontSize: 13),
              ),
              textAlign: TextAlign.center,
            ),
            TextFormField(
              controller: _pathController,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.zero,
                label: Center(child: Text('可选:存储路径')),
                hintText: '例如test/',
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
                          requestCallBack: _saveQiniuConfig(),
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
                        requestCallBack: checkQiniuConfig(),
                      );
                    });
              },
              child: titleText('检查当前配置', fontsize: null),
            )),
            ListTile(
                title: ElevatedButton(
              onPressed: () async {
                await Application.router
                    .navigateTo(context, '/configureStorePage?psHost=qiniu', transition: TransitionType.cupertino);
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

  Future _saveQiniuConfig() async {
    try {
      String accessKey = _accessKeyController.text.trim();
      String secretKey = _secretKeyController.text.trim();
      String bucket = _bucketController.text.trim();
      String url = _urlController.text.trim();
      String area = _areaController.text.trim();
      String options = _optionsController.text.trim();
      String path = _pathController.text.trim();

      if (options.isNotEmpty && !options.startsWith('?')) {
        options = '?$options';
      }
      if (options.isEmpty) {
        options = 'None';
      }

      if (!url.startsWith('http') && !url.startsWith('https')) {
        url = 'http://$url';
      }
      if (url.endsWith('/')) {
        url = url.substring(0, url.length - 1);
      }

      if (path.isEmpty) {
        path = 'None';
      } else if (path.isNotEmpty && path != '/') {
        if (path.startsWith('/')) {
          path = path.substring(1);
        }
        if (!path.endsWith('/')) {
          path = '$path/';
        }
      }

      final qiniuConfig = QiniuConfigModel(accessKey, secretKey, bucket, url, area, options, path);
      final qiniuConfigJson = jsonEncode(qiniuConfig);
      final qiniuConfigFile = await QiniuManageAPI.localFile;
      await qiniuConfigFile.writeAsString(qiniuConfigJson);
      showToast('保存成功');
    } catch (e) {
      FLog.error(
          className: 'QiniuConfigPage',
          methodName: '_saveQiniuConfig',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      if (context.mounted) {
        return showCupertinoAlertDialog(context: context, title: '错误', content: e.toString());
      }
    }
  }

  checkQiniuConfig() async {
    try {
      Map configMap = await QiniuManageAPI.getConfigMap();

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
      String qiniupath = configMap['path'];

      if (qiniupath != 'None') {
        if (qiniupath.startsWith('/')) {
          qiniupath = qiniupath.substring(1);
        }
        if (!qiniupath.endsWith('/')) {
          qiniupath = '$qiniupath/';
        }
      }
      String urlPath = '';
      if (qiniupath == 'None') {
        urlPath = key;
      } else {
        urlPath = '$qiniupath$key';
      }
      String urlSafeBase64EncodePutPolicy =
          QiniuImageUploadUtils.geturlSafeBase64EncodePutPolicy(configMap['bucket'], key, qiniupath);
      String uploadToken = QiniuImageUploadUtils.getUploadToken(
          configMap['accessKey'], configMap['secretKey'], urlSafeBase64EncodePutPolicy);
      Storage storage = Storage(
          config: Config(
        retryLimit: 5,
      ));
      PutResponse putresult =
          await storage.putFile(File(assetFilePath), uploadToken, options: PutOptions(key: urlPath));
      if (putresult.key == key || putresult.key == '${configMap['path']}$key') {
        if (context.mounted) {
          return showCupertinoAlertDialog(
              context: context,
              title: '通知',
              content:
                  '检测通过，您的配置信息为:\naccessKey:\n${configMap['accessKey']}\nsecretKey:\n${configMap['secretKey']}\nbucket:\n${configMap['bucket']}\nurl:\n${configMap['url']}\narea:\n${configMap['area']}\noptions:\n${configMap['options']}\npath:\n${configMap['path']}');
        }
      } else {
        if (context.mounted) {
          return showCupertinoAlertDialog(context: context, title: '错误', content: '检查失败，请检查配置信息');
        }
      }
    } catch (e) {
      FLog.error(
          className: 'QiniuConfigPage',
          methodName: 'checkQiniuConfig',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      if (context.mounted) {
        return showCupertinoAlertDialog(context: context, title: "检查失败!", content: e.toString());
      }
    }
  }

  _setdefault() async {
    await Global.setPShost('qiniu');
    await Global.setShowedPBhost('qiniu');
    eventBus.fire(AlbumRefreshEvent(albumKeepAlive: false));
    eventBus.fire(HomePhotoRefreshEvent(homePhotoKeepAlive: false));
    showToast('已设置七牛云为默认图床');
  }
}

class QiniuConfigModel {
  final String accessKey;
  final String secretKey;
  final String bucket;
  final String url;
  final String area;
  final String options;
  final String path;

  QiniuConfigModel(this.accessKey, this.secretKey, this.bucket, this.url, this.area, this.options, this.path);

  Map<String, dynamic> toJson() => {
        'accessKey': accessKey,
        'secretKey': secretKey,
        'bucket': bucket,
        'url': url,
        'area': area,
        'options': options,
        'path': path,
      };

  static List keysList = [
    'remarkName',
    'accessKey',
    'secretKey',
    'bucket',
    'url',
    'area',
    'options',
    'path',
  ];
}
