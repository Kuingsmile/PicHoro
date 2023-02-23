import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:dio/dio.dart';
import 'package:dio_proxy_adapter/dio_proxy_adapter.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:f_logs/f_logs.dart';
import 'package:fluro/fluro.dart';
import 'package:path_provider/path_provider.dart';

import 'package:horopic/router/application.dart';
import 'package:horopic/pages/loading.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/utils/sql_utils.dart';
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
      _clientIdController.text = configMap['clientId'];
      if (configMap['proxy'] != 'None') {
        _proxyController.text = configMap['proxy'];
      } else {
        _proxyController.clear();
      }
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
              await Application.router.navigateTo(
                  context, '/configureStorePage?psHost=imgur',
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
                await Application.router.navigateTo(
                    context, '/configureStorePage?psHost=imgur',
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

  Future _saveImgurConfig() async {
    String clientId = '';
    if (_clientIdController.text.startsWith('Client-ID ')) {
      clientId = _clientIdController.text.substring(10);
    } else {
      clientId = _clientIdController.text;
    }
    String proxy = '';
    if (_proxyController.text == '' || _proxyController.text.isEmpty) {
      proxy = 'None';
    } else {
      proxy = _proxyController.text;
    }

    try {
      List sqlconfig = [];
      sqlconfig.add(clientId);
      sqlconfig.add(proxy);
      String defaultUser = await Global.getUser();
      sqlconfig.add(defaultUser);

      var queryImgur = await MySqlUtils.queryImgur(username: defaultUser);
      var queryuser = await MySqlUtils.queryUser(username: defaultUser);

      if (queryuser == 'Empty') {
        return showCupertinoAlertDialog(
            context: context, title: '错误', content: '用户不存在,请先登录');
      }
      String baiduPicUrl =
          "https://dss0.bdstatic.com/5aV1bjqh_Q23odCf/static/superman/img/logo/logo_white-d0c9fe2af5.png";
      String validateURL = "https://api.imgur.com/3/image";

      BaseOptions options = setBaseOptions();
      options.headers = {
        "Authorization": "Client-ID $clientId",
      };
      //需要加一个空的formdata，不然会报错
      FormData formData = FormData.fromMap({
        "image": baiduPicUrl,
      });
      Dio dio = Dio(options);
      String sqlResult = '';
      String proxyClean = '';
      if (proxy != 'None') {
        if (proxy.startsWith('http://') || proxy.startsWith('https://')) {
          proxyClean = proxy.split('://')[1];
        } else {
          proxyClean = proxy;
        }
        dio.useProxy(proxyClean);
      }
      try {
        var validateResponse = await dio.post(validateURL, data: formData);
        if (validateResponse.statusCode == 200 &&
            validateResponse.data['success'] == true) {
          if (queryImgur == 'Empty') {
            sqlResult = await MySqlUtils.insertImgur(content: sqlconfig);
          } else {
            sqlResult = await MySqlUtils.updateImgur(content: sqlconfig);
          }
          if (sqlResult == "Success") {
            final imgurConfig = ImgurConfigModel(clientId, proxy);
            final imgurConfigJson = jsonEncode(imgurConfig);
            final imgurConfigFile = await localFile;
            await imgurConfigFile.writeAsString(imgurConfigJson);
            return showCupertinoAlertDialog(
                context: context, title: '成功', content: '配置成功');
          } else {
            return showCupertinoAlertDialog(
                context: context, title: '错误', content: '数据库错误');
          }
        } else {
          return showCupertinoAlertDialog(
              context: context, title: '错误', content: 'clientId错误');
        }
      } catch (e) {
        FLog.error(
            className: 'ImgurConfigPage',
            methodName: '_saveImgurConfig_1',
            text: formatErrorMessage({}, e.toString()),
            dataLogType: DataLogType.ERRORS.toString());
        return showCupertinoAlertDialog(
            context: context, title: '错误', content: e.toString());
      }
    } catch (e) {
      FLog.error(
          className: 'ImgurConfigPage',
          methodName: '_saveImgurConfig_2',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      return showCupertinoAlertDialog(
          context: context, title: '错误', content: e.toString());
    }
  }

  checkImgurConfig() async {
    try {
      final imgurConfigFile = await localFile;
      String configData = await imgurConfigFile.readAsString();
      if (configData == "Error") {
        return showCupertinoAlertDialog(
            context: context, title: "检查失败!", content: "请先配置上传参数.");
      }
      Map configMap = jsonDecode(configData);

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
        if (configMap["proxy"].startsWith('http://') ||
            configMap["proxy"].startsWith('https://')) {
          proxyClean = configMap["proxy"].split('://')[1];
        } else {
          proxyClean = configMap["proxy"];
        }
        dio.useProxy(proxyClean);
      }
      var response = await dio.post(validateURL, data: formData);
      if (response.statusCode == 200 && response.data['success'] == true) {
        return showCupertinoAlertDialog(
            context: context,
            title: '通知',
            content:
                '检测通过，您的配置信息为:\nclientId:\n${configMap["clientId"]}\n代理:\n${configMap["proxy"]}');
      } else {
        return showCupertinoAlertDialog(
            context: context, title: '错误', content: '配置有误，请检查网络或重新配置');
      }
    } catch (e) {
      FLog.error(
          className: 'ImgurConfigPage',
          methodName: 'checkImgurConfig',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      return showCupertinoAlertDialog(
          context: context, title: "检查失败!", content: e.toString());
    }
  }

  Future<File> get localFile async {
    final path = await _localPath;
    String defaultUser = await Global.getUser();
    return File('$path/${defaultUser}_imgur_config.txt');
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
          className: 'ImgurConfigPage',
          methodName: 'readHostConfig',
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
      var queryImgur = await MySqlUtils.queryImgur(username: defaultUser);
      if (queryImgur == 'Empty') {
        return Fluttertoast.showToast(
            msg: "请先配置上传参数",
            toastLength: Toast.LENGTH_SHORT,
            timeInSecForIosWeb: 2,
            fontSize: 16.0);
      }
      if (queryImgur == 'Error') {
        return Fluttertoast.showToast(
            msg: "Error",
            toastLength: Toast.LENGTH_SHORT,
            timeInSecForIosWeb: 2,
            fontSize: 16.0);
      }
      if (queryuser['defaultPShost'] == 'imgur') {
        await Global.setPShost('imgur');
        await Global.setShowedPBhost('imgur');
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
        sqlconfig.add('imgur');
        var updateResult = await MySqlUtils.updateUser(content: sqlconfig);
        if (updateResult == 'Success') {
          await Global.setPShost('imgur');
          await Global.setShowedPBhost('imgur');
          eventBus.fire(AlbumRefreshEvent(albumKeepAlive: false));
          eventBus.fire(HomePhotoRefreshEvent(homePhotoKeepAlive: false));
          showToast('已设置Imgur为默认图床');
        } else {
          showToast('写入数据库失败');
        }
      }
    } catch (e) {
      FLog.error(
          className: 'ImgurConfigPage',
          methodName: '_setdefault',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      showToastWithContext(context, '错误');
    }
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
