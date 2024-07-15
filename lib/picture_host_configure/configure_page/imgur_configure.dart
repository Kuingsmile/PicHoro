import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:dio/dio.dart';
import 'package:f_logs/f_logs.dart';
import 'package:fluro/fluro.dart';

import 'package:horopic/router/application.dart';
import 'package:horopic/pages/loading.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/utils/dio_proxy_adapter.dart';
import 'package:horopic/utils/global.dart';
import 'package:horopic/picture_host_manage/manage_api/imgur_manage_api.dart';
import 'package:horopic/utils/event_bus_utils.dart';

class ImgurConfig extends StatefulWidget {
  const ImgurConfig({Key? key}) : super(key: key);

  @override
  ImgurConfigState createState() => ImgurConfigState();
}

class ImgurConfigState extends State<ImgurConfig> {
  final _formKey = GlobalKey<FormState>();
  final _clientIdController = TextEditingController();
  final _proxyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initConfig();
  }

  _initConfig() async {
    try {
      Map configMap = await ImgurManageAPI.getConfigMap();
      _clientIdController.text = configMap['clientId'] ?? '';
      setControllerText(_proxyController, configMap['proxy']);
      setState(() {});
    } catch (e) {
      FLog.error(
          className: 'ImgurConfigState',
          methodName: '_initConfig',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
    }
  }

  @override
  void dispose() {
    _clientIdController.dispose();
    _proxyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: titleText('Imgur参数配置'),
        actions: [
          IconButton(
            onPressed: () async {
              await Application.router
                  .navigateTo(context, '/configureStorePage?psHost=imgur', transition: TransitionType.cupertino);
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
              controller: _clientIdController,
              decoration: const InputDecoration(
                label: Center(child: Text('设定clientID')),
                hintText: 'clientID',
              ),
              textAlign: TextAlign.center,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入clientID';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _proxyController,
              decoration: const InputDecoration(
                label: Center(child: Text('可选:设定代理,需要配合手机FQ软件使用')),
                hintText: '例如127.0.0.1:7890',
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
                          requestCallBack: _saveImgurConfig(),
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
                        requestCallBack: checkImgurConfig(),
                      );
                    });
              },
              child: titleText('检查当前配置', fontsize: null),
            )),
            ListTile(
                title: ElevatedButton(
              onPressed: () async {
                await Application.router
                    .navigateTo(context, '/configureStorePage?psHost=imgur', transition: TransitionType.cupertino);
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

  Future _saveImgurConfig() async {
    try {
      String clientId = _clientIdController.text.trim();
      String proxy = _proxyController.text.trim();
      if (clientId.startsWith('Client-ID ')) {
        clientId = clientId.substring(10);
      }
      if (proxy.isEmpty) {
        proxy = 'None';
      }

      final imgurConfig = ImgurConfigModel(clientId, proxy);
      final imgurConfigJson = jsonEncode(imgurConfig);
      final imgurConfigFile = await ImgurManageAPI.localFile;
      await imgurConfigFile.writeAsString(imgurConfigJson);
      showToast('保存成功');
      return;
    } catch (e) {
      FLog.error(
          className: 'ImgurConfigPage',
          methodName: '_saveImgurConfig',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      if (context.mounted) {
        return showCupertinoAlertDialog(context: context, title: '错误', content: e.toString());
      }
    }
  }

  checkImgurConfig() async {
    try {
      Map configMap = await ImgurManageAPI.getConfigMap();
      if (configMap.isEmpty) {
        if (context.mounted) {
          return showCupertinoAlertDialog(context: context, title: "检查失败!", content: "请先配置上传参数.");
        }
        return;
      }

      BaseOptions options = setBaseOptions();
      options.headers = {
        "Authorization": "Client-ID ${configMap['clientId']}",
      };
      String baiduPicUrl =
          "https://dss0.bdstatic.com/5aV1bjqh_Q23odCf/static/superman/img/logo/logo_white-d0c9fe2af5.png";
      String validateURL = "https://api.imgur.com/3/image";
      FormData formData = FormData.fromMap({
        "image": baiduPicUrl,
      });
      Dio dio = Dio(options);
      String proxyClean = '';

      if (configMap["proxy"] != 'None') {
        if (configMap["proxy"].startsWith('http://') || configMap["proxy"].startsWith('https://')) {
          proxyClean = configMap["proxy"].split('://')[1];
        } else {
          proxyClean = configMap["proxy"];
        }
        dio.httpClientAdapter = useProxy(proxyClean);
      }
      var response = await dio.post(validateURL, data: formData);
      if (response.statusCode == 200 && response.data['success'] == true) {
        if (context.mounted) {
          return showCupertinoAlertDialog(
              context: context,
              title: '通知',
              content: '检测通过，您的配置信息为:\nclientId:\n${configMap["clientId"]}\n代理:\n${configMap["proxy"]}');
        }
        return;
      }
      if (context.mounted) {
        return showCupertinoAlertDialog(context: context, title: '错误', content: '配置有误，请检查网络或重新配置');
      }
      return;
    } catch (e) {
      FLog.error(
          className: 'ImgurConfigPage',
          methodName: 'checkImgurConfig',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      if (context.mounted) {
        return showCupertinoAlertDialog(context: context, title: "检查失败!", content: e.toString());
      }
    }
  }

  _setdefault() async {
    await Global.setPShost('imgur');
    await Global.setShowedPBhost('imgur');
    eventBus.fire(AlbumRefreshEvent(albumKeepAlive: false));
    eventBus.fire(HomePhotoRefreshEvent(homePhotoKeepAlive: false));
    showToast('已设置Imgur为默认图床');
  }
}

class ImgurConfigModel {
  final String clientId;
  final String proxy;

  ImgurConfigModel(this.clientId, this.proxy);

  Map<String, dynamic> toJson() => {
        'clientId': clientId,
        'proxy': proxy,
      };

  static List keysList = [
    'remarkName',
    'clientId',
    'proxy',
  ];
}
