import 'dart:io';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:fluro/fluro.dart';
import 'package:f_logs/f_logs.dart';

import 'package:horopic/router/application.dart';
import 'package:horopic/pages/loading.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/utils/global.dart';
import 'package:horopic/utils/event_bus_utils.dart';
import 'package:horopic/picture_host_manage/manage_api/smms_manage_api.dart';

class SmmsConfig extends StatefulWidget {
  const SmmsConfig({Key? key}) : super(key: key);

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
      _tokenController.text = configMap['token'];
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
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: titleText('SM.MS参数配置'),
        actions: [
          IconButton(
            onPressed: () async {
              await Application.router
                  .navigateTo(context, '/configureStorePage?psHost=sm.ms', transition: TransitionType.cupertino);
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
              controller: _tokenController,
              decoration: const InputDecoration(
                label: Center(child: Text('Token')),
                hintText: 'token',
              ),
              textAlign: TextAlign.center,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入token';
                }
                return null;
              },
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
                          requestCallBack: _saveSmmsConfig(),
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
                        requestCallBack: checkSmmsConfig(),
                      );
                    });
              },
              child: titleText('检查当前配置', fontsize: null),
            )),
            ListTile(
                title: ElevatedButton(
              onPressed: () async {
                await Application.router
                    .navigateTo(context, '/configureStorePage?psHost=sm.ms', transition: TransitionType.cupertino);
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

  Future _saveSmmsConfig() async {
    try {
      final token = _tokenController.text;

      String validateURL = "https://smms.app/api/v2/profile";
      BaseOptions options = setBaseOptions();
      options.headers = {
        "Content-Type": 'multipart/form-data',
        "Authorization": token,
      };
      //需要加一个空的formdata，不然会报错
      FormData formData = FormData.fromMap({});
      Dio dio = Dio(options);

      var validateResponse = await dio.post(validateURL, data: formData);
      if (validateResponse.statusCode == 200 && validateResponse.data['success'] == true) {
        final smmsConfig = SmmsConfigModel(token);
        final smmsConfigJson = jsonEncode(smmsConfig);
        final smmsConfigFile = await localFile;
        await smmsConfigFile.writeAsString(smmsConfigJson);
        return showCupertinoAlertDialog(context: context, title: '成功', content: '配置成功');
      } else {
        return showCupertinoAlertDialog(context: context, title: '错误', content: '配置失败');
      }
    } catch (e) {
      FLog.error(
          className: 'SmmsConfigState',
          methodName: '_saveSmmsConfig_2',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      return showCupertinoAlertDialog(context: context, title: '错误', content: e.toString());
    }
  }

  checkSmmsConfig() async {
    try {
      final smmsConfigFile = await localFile;
      String configData = await smmsConfigFile.readAsString();
      if (configData == "Error") {
        return showCupertinoAlertDialog(context: context, title: "检查失败!", content: "请先配置上传参数.");
      }
      Map configMap = jsonDecode(configData);
      BaseOptions options = setBaseOptions();
      options.headers = {
        "Authorization": configMap["token"],
        "Content-Type": "multipart/form-data",
      };
      String validateURL = "https://smms.app/api/v2/profile";
      FormData formData = FormData.fromMap({});
      Dio dio = Dio(options);
      var response = await dio.post(validateURL, data: formData);
      if (response.statusCode == 200 && response.data['success'] == true) {
        return showCupertinoAlertDialog(
            context: context, title: '通知', content: '检测通过，您的配置信息为:\ntoken:\n${configMap["token"]}');
      } else if (response.data['status'] == false) {
        return showCupertinoAlertDialog(context: context, title: '错误', content: response.data['message']);
      } else {
        return showCupertinoAlertDialog(context: context, title: '错误', content: '未知错误');
      }
    } catch (e) {
      FLog.error(
          className: 'SmmsConfigState',
          methodName: 'checkSmmsConfig',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      return showCupertinoAlertDialog(context: context, title: "检查失败!", content: e.toString());
    }
  }

  Future<File> get localFile async {
    final path = await _localPath;
    String defaultUser = await Global.getUser();
    return File('$path/${defaultUser}_smms_config.txt');
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<String> readHostConfig() async {
    try {
      final file = await localFile;
      String contents = await file.readAsString();
      return contents;
    } catch (e) {
      FLog.error(
          className: 'SmmsConfigState',
          methodName: 'readHostConfig',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      return "Error";
    }
  }

  _setdefault() async {
    await Global.setPShost('sm.ms');
    await Global.setShowedPBhost('smms');
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
