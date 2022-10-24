import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:horopic/utils/common_func.dart';
import 'package:horopic/pages/loading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:horopic/utils/sqlUtils.dart';
import 'package:horopic/utils/global.dart';
import 'package:dio_proxy_adapter/dio_proxy_adapter.dart';

class ImgurConfig extends StatefulWidget {
  const ImgurConfig({Key? key}) : super(key: key);

  @override
  _ImgurConfigState createState() => _ImgurConfigState();
}

class _ImgurConfigState extends State<ImgurConfig> {
  final _formKey = GlobalKey<FormState>();
  final _clientIdController = TextEditingController();
  final _proxyController = TextEditingController();

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
        title: const Text('Imgur参数配置'),
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
            ElevatedButton(
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
              child: const Text('提交'),
            ),
            ElevatedButton(
              onPressed: () {
                checkImgurConfig();
              },
              child: const Text('检查当前配置'),
            ),
            ElevatedButton(
              onPressed: () {
                _setdefault();
              },
              child: const Text('设为默认图床'),
            ),
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
    if (_proxyController.text == '' ||
        _proxyController.text == null ||
        _proxyController.text.isEmpty) {
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
        return showAlertDialog(
            context: context, title: '错误', content: '用户不存在,请先登录');
      }
      //拿百度的logo来测试

      String baiduPicUrl =
          "https://dss0.bdstatic.com/5aV1bjqh_Q23odCf/static/superman/img/logo/logo_white-d0c9fe2af5.png";
      String validateURL = "https://api.imgur.com/3/image";

      BaseOptions options = BaseOptions(
        //连接服务器超时时间，单位是毫秒.
        connectTimeout: 30000,
        //响应超时时间。
        receiveTimeout: 30000,
        sendTimeout: 30000,
      );
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
            final ImgurConfig = ImgurConfigModel(clientId, proxy);
            final ImgurConfigJson = jsonEncode(ImgurConfig);
            final ImgurConfigFile = await _localFile;
            await ImgurConfigFile.writeAsString(ImgurConfigJson);
            return showAlertDialog(
                context: context, title: '成功', content: '配置成功');
          } else {
            return showAlertDialog(
                context: context, title: '错误', content: '数据库错误');
          }
        } else {
          return showAlertDialog(
              context: context, title: '错误', content: 'clientId错误');
        }
      } catch (e) {
        return showAlertDialog(
            context: context, title: '错误', content: e.toString());
      }
    } catch (e) {
      return showAlertDialog(
          context: context, title: '错误', content: e.toString());
    }
  }

  void checkImgurConfig() async {
    try {
      final ImgurConfigFile = await _localFile;
      String configData = await ImgurConfigFile.readAsString();
      if (configData == "Error") {
        showAlertDialog(context: context, title: "检查失败!", content: "请先配置上传参数.");
        return;
      }
      Map configMap = jsonDecode(configData);

      BaseOptions options = BaseOptions(
        //连接服务器超时时间，单位是毫秒.
        connectTimeout: 30000,
        //响应超时时间。
        receiveTimeout: 30000,
        sendTimeout: 30000,
      );
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
        showAlertDialog(
            context: context,
            title: '通知',
            content:
                '检测通过，您的配置信息为:\nclientId:\n${configMap["clientId"]}\n代理:\n${configMap["proxy"]}');
      } else {
        showAlertDialog(
            context: context, title: '错误', content: '配置有误，请检查网络或重新配置');
        return;
      }
    } catch (e) {
      showAlertDialog(context: context, title: "检查失败!", content: e.toString());
    }
  }

  Future<File> get _localFile async {
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
      final file = await _localFile;
      String contents = await file.readAsString();
      return contents;
    } catch (e) {
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
            backgroundColor: Theme.of(context).brightness == Brightness.light
                ? Colors.black
                : Colors.white,
            textColor: Theme.of(context).brightness == Brightness.light
                ? Colors.white
                : Colors.black,
            fontSize: 16.0);
      } else if (queryuser['password'] != defaultPassword) {
        return Fluttertoast.showToast(
            msg: "请先登录",
            toastLength: Toast.LENGTH_SHORT,
            timeInSecForIosWeb: 2,
            backgroundColor: Theme.of(context).brightness == Brightness.light
                ? Colors.black
                : Colors.white,
            textColor: Theme.of(context).brightness == Brightness.light
                ? Colors.white
                : Colors.black,
            fontSize: 16.0);
      }
      var queryImgur = await MySqlUtils.queryImgur(username: defaultUser);
      if (queryImgur == 'Empty') {
        return Fluttertoast.showToast(
            msg: "请先配置上传参数",
            toastLength: Toast.LENGTH_SHORT,
            timeInSecForIosWeb: 2,
            backgroundColor: Theme.of(context).brightness == Brightness.light
                ? Colors.black
                : Colors.white,
            textColor: Theme.of(context).brightness == Brightness.light
                ? Colors.white
                : Colors.black,
            fontSize: 16.0);
      }
      if (queryImgur == 'Error') {
        return Fluttertoast.showToast(
            msg: "Error",
            toastLength: Toast.LENGTH_SHORT,
            timeInSecForIosWeb: 2,
            backgroundColor: Theme.of(context).brightness == Brightness.light
                ? Colors.black
                : Colors.white,
            textColor: Theme.of(context).brightness == Brightness.light
                ? Colors.white
                : Colors.black,
            fontSize: 16.0);
      }
      if (queryuser['defaultPShost'] == 'imgur') {
        await Global.setPShost('imgur');
        await Global.setShowedPBhost('imgur');

        return Fluttertoast.showToast(
            msg: "已经是默认配置",
            toastLength: Toast.LENGTH_SHORT,
            timeInSecForIosWeb: 2,
            backgroundColor: Theme.of(context).brightness == Brightness.light
                ? Colors.black
                : Colors.white,
            textColor: Theme.of(context).brightness == Brightness.light
                ? Colors.white
                : Colors.black,
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
          Fluttertoast.showToast(
              msg: "已设置Imgur为默认图床",
              toastLength: Toast.LENGTH_SHORT,
              timeInSecForIosWeb: 2,
              backgroundColor: Theme.of(context).brightness == Brightness.light
                  ? Colors.black
                  : Colors.white,
              textColor: Theme.of(context).brightness == Brightness.light
                  ? Colors.white
                  : Colors.black,
              fontSize: 16.0);
        } else {
          Fluttertoast.showToast(
              msg: "写入数据库失败",
              toastLength: Toast.LENGTH_SHORT,
              timeInSecForIosWeb: 2,
              backgroundColor: Theme.of(context).brightness == Brightness.light
                  ? Colors.black
                  : Colors.white,
              textColor: Theme.of(context).brightness == Brightness.light
                  ? Colors.white
                  : Colors.black,
              fontSize: 16.0);
        }
      }
    } catch (e) {
      Fluttertoast.showToast(
          msg: "Error",
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 2,
          backgroundColor: Theme.of(context).brightness == Brightness.light
              ? Colors.black
              : Colors.white,
          textColor: Theme.of(context).brightness == Brightness.light
              ? Colors.white
              : Colors.black,
          fontSize: 16.0);
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
}
