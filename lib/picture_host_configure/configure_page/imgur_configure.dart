import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:dio/dio.dart';
import 'package:fluro/fluro.dart';

import 'package:horopic/router/application.dart';
import 'package:horopic/widgets/net_loading_dialog.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/utils/dio_proxy_adapter.dart';
import 'package:horopic/utils/global.dart';
import 'package:horopic/picture_host_manage/manage_api/imgur_manage_api.dart';
import 'package:horopic/utils/event_bus_utils.dart';
import 'package:horopic/widgets/configure_widgets.dart';

class ImgurConfig extends StatefulWidget {
  const ImgurConfig({super.key});

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
      Map configMap = await ImgurManageAPI().getConfigMap();
      _clientIdController.text = configMap['clientId'] ?? '';
      setControllerText(_proxyController, configMap['proxy']);
      setState(() {});
    } catch (e) {
      flogErr(e, {}, 'ImgurConfigState', '_initConfig');
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
      appBar: ConfigureWidgets.buildConfigAppBar(title: 'Imgur参数配置', context: context),
      body: Form(
        key: _formKey,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            ConfigureWidgets.buildSettingCard(
              title: '基本配置',
              children: [
                ConfigureWidgets.buildFormField(
                  controller: _clientIdController,
                  labelText: 'Client ID',
                  hintText: '请输入Imgur的Client ID',
                  prefixIcon: Icons.key,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入clientID';
                    }
                    return null;
                  },
                ),
                ConfigureWidgets.buildFormField(
                  controller: _proxyController,
                  labelText: '代理设置',
                  hintText: '可选:例如127.0.0.1:7890',
                  prefixIcon: Icons.public,
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
                              requestCallBack: _saveImgurConfig(),
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
                            requestCallBack: checkImgurConfig(),
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
                        .navigateTo(context, '/configureStorePage?psHost=imgur', transition: TransitionType.cupertino);
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
      final imgurConfigFile = await ImgurManageAPI().localFile();
      await imgurConfigFile.writeAsString(imgurConfigJson);
      showToast('保存成功');
      return;
    } catch (e) {
      flogErr(e, {}, 'ImgurConfigState', '_saveImgurConfig');
      if (context.mounted) {
        return showCupertinoAlertDialog(context: context, title: '错误', content: e.toString());
      }
    }
  }

  checkImgurConfig() async {
    try {
      Map configMap = await ImgurManageAPI().getConfigMap();
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
      flogErr(e, {}, 'ImgurConfigState', 'checkImgurConfig');
      if (context.mounted) {
        return showCupertinoAlertDialog(context: context, title: "检查失败!", content: e.toString());
      }
    }
  }

  _setdefault() {
    Global.setPShost('imgur');
    Global.setShowedPBhost('imgur');
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
