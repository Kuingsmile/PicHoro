import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluro/fluro.dart';
import 'package:f_logs/f_logs.dart';

import 'package:horopic/router/application.dart';
import 'package:horopic/pages/loading.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/utils/global.dart';
import 'package:horopic/utils/event_bus_utils.dart';
import 'package:horopic/picture_host_manage/manage_api/smms_manage_api.dart';
import 'package:horopic/picture_host_configure/widgets/configure_widgets.dart';

class SmmsConfig extends StatefulWidget {
  const SmmsConfig({super.key});

  @override
  SmmsConfigState createState() => SmmsConfigState();
}

class SmmsConfigState extends State<SmmsConfig> {
  final _formKey = GlobalKey<FormState>();
  final _tokenController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initConfig();
  }

  _initConfig() async {
    try {
      Map configMap = await SmmsManageAPI.getConfigMap();
      _tokenController.text = configMap['token'] ?? '';
    } catch (e) {
      FLog.error(
          className: 'SmmsConfigState',
          methodName: '_initConfig',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
    }
  }

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ConfigureWidgets.buildConfigAppBar(title: 'SM.MS参数配置', context: context),
      body: Form(
        key: _formKey,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            ConfigureWidgets.buildSettingCard(
              title: '基本配置',
              children: [
                ConfigureWidgets.buildFormField(
                  controller: _tokenController,
                  labelText: 'Token',
                  hintText: '请输入SM.MS的Token',
                  prefixIcon: Icons.vpn_key,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '请输入token';
                    }
                    return null;
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
                              requestCallBack: _saveSmmsConfig(),
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
                            requestCallBack: checkSmmsConfig(),
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
                        .navigateTo(context, '/configureStorePage?psHost=sm.ms', transition: TransitionType.cupertino);
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

  Future _saveSmmsConfig() async {
    try {
      final token = _tokenController.text.trim();

      final smmsConfig = SmmsConfigModel(token);
      final smmsConfigJson = jsonEncode(smmsConfig);
      final smmsConfigFile = await SmmsManageAPI.localFile;
      await smmsConfigFile.writeAsString(smmsConfigJson);
      showToast('保存成功');
    } catch (e) {
      FLog.error(
          className: 'SmmsConfigState',
          methodName: '_saveSmmsConfig',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      if (context.mounted) {
        return showCupertinoAlertDialog(context: context, title: '错误', content: e.toString());
      }
    }
  }

  checkSmmsConfig() async {
    try {
      Map configMap = await SmmsManageAPI.getConfigMap();
      if (configMap.isEmpty) {
        if (context.mounted) {
          return showCupertinoAlertDialog(context: context, title: "检查失败!", content: "请先配置上传参数.");
        }
        return;
      }

      BaseOptions options = setBaseOptions();
      options.headers = {
        "Authorization": configMap["token"],
      };
      String validateURL = "https://smms.app/api/v2/profile";
      Dio dio = Dio(options);
      var response = await dio.post(
        validateURL,
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        if (context.mounted) {
          return showCupertinoAlertDialog(
              context: context, title: '通知', content: '检测通过，您的配置信息为:\ntoken:\n${configMap["token"]}');
        }
      } else if (response.data['status'] == false) {
        if (context.mounted) {
          return showCupertinoAlertDialog(context: context, title: '错误', content: response.data['message']);
        }
      } else {
        if (context.mounted) {
          return showCupertinoAlertDialog(context: context, title: '错误', content: '未知错误');
        }
      }
    } catch (e) {
      FLog.error(
          className: 'SmmsConfigState',
          methodName: 'checkSmmsConfig',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      if (context.mounted) {
        return showCupertinoAlertDialog(context: context, title: "检查失败!", content: e.toString());
      }
    }
  }

  _setdefault() {
    Global.setPShost('sm.ms');
    Global.setShowedPBhost('smms');
    eventBus.fire(AlbumRefreshEvent(albumKeepAlive: false));
    eventBus.fire(HomePhotoRefreshEvent(homePhotoKeepAlive: false));
    showToast("已设置sm.ms为默认图床");
  }
}

class SmmsConfigModel {
  final String token;

  SmmsConfigModel(this.token);

  Map<String, dynamic> toJson() => {
        'token': token,
      };

  static List keysList = [
    'remarkName',
    'token',
  ];
}
