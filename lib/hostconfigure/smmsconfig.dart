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

//a textfield to get hosts,username,passwd,token and strategy_id
class SmmsConfig extends StatefulWidget {
  const SmmsConfig({Key? key}) : super(key: key);

  @override
  _SmmsConfigState createState() => _SmmsConfigState();
}

class _SmmsConfigState extends State<SmmsConfig> {
  final _formKey = GlobalKey<FormState>();
  final _tokenController = TextEditingController();

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SM.MS参数配置'),
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
                          requestCallBack: _saveSmmsConfig(),
                        );
                      });
                }
              },
              child: const Text('提交'),
            ),
            ElevatedButton(
              onPressed: () {
                checkSmmsConfig();
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

  Future _saveSmmsConfig() async {
    final token = _tokenController.text;

    try {
      List sqlconfig = [];
      sqlconfig.add(token);
      String defaultUser = await Global.getUser();
      sqlconfig.add(defaultUser);

      var querysmms = await MySqlUtils.querySmms(username: defaultUser);
      var queryuser = await MySqlUtils.queryUser(username: defaultUser);

      if (queryuser == 'Empty') {
        return showAlertDialog(
            context: context, title: '错误', content: '用户不存在,请先登录');
      }
      String validateURL = "https://smms.app/api/v2/profile";
      // String validateURL = "https://sm.ms/api/v2/profile";被墙了
      BaseOptions options = BaseOptions(
        //连接服务器超时时间，单位是毫秒.
        connectTimeout: 10000,
        //响应超时时间。
        receiveTimeout: 10000,
      );
      options.headers = {
        "Content-Type": 'multipart/form-data',
        "Authorization": token,
      };
      //需要加一个空的formdata，不然会报错
      FormData formData = FormData.fromMap({});
      Dio dio = Dio(options);
      String sqlResult = '';
      try {
        var validateResponse = await dio.post(validateURL, data: formData);
        if (validateResponse.statusCode == 200 &&
            validateResponse.data['success'] == true) {
          if (querysmms == 'Empty') {
            sqlResult = await MySqlUtils.insertSmms(content: sqlconfig);
          } else {
            sqlResult = await MySqlUtils.updateSmms(content: sqlconfig);
          }
          if (sqlResult == "Success") {
            final smmsConfig = SmmsConfigModel(token);
            final smmsConfigJson = jsonEncode(smmsConfig);
            final smmsConfigFile = await _localFile;
            await smmsConfigFile.writeAsString(smmsConfigJson);
            return showAlertDialog(
                context: context, title: '成功', content: '配置成功');
          } else {
            return showAlertDialog(
                context: context, title: '错误', content: '数据库错误');
          }
        } else {
          return showAlertDialog(
              context: context, title: '错误', content: 'token错误');
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

  void checkSmmsConfig() async {
    try {
      final smmsConfigFile = await _localFile;
      String configData = await smmsConfigFile.readAsString();
      if (configData == "Error") {
        showAlertDialog(context: context, title: "检查失败!", content: "请先配置上传参数.");
        return;
      }
      Map configMap = jsonDecode(configData);
      BaseOptions options = BaseOptions(
        //连接服务器超时时间，单位是毫秒.
        connectTimeout: 10000,
        //响应超时时间。
        receiveTimeout: 10000,
      );
      options.headers = {
        "Authorization": configMap["token"],
        "Content-Type": "multipart/form-data",
      };
      String validateURL = "https://smms.app/api/v2/profile";
      FormData formData = FormData.fromMap({});
      Dio dio = Dio(options);
      var response = await dio.post(validateURL, data: formData);
      if (response.statusCode == 200 && response.data['success'] == true) {
        showAlertDialog(
            context: context,
            title: '通知',
            content: '检测通过，您的配置信息为:\ntoken:\n${configMap["token"]}');
      } else if (response.data['status'] == false) {
        showAlertDialog(
            context: context, title: '错误', content: response.data['message']);
        return;
      } else {
        showAlertDialog(context: context, title: '错误', content: '未知错误');
        return;
      }
    } catch (e) {
      showAlertDialog(context: context, title: "检查失败!", content: e.toString());
    }
  }

  Future<File> get _localFile async {
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
      var querysmms = await MySqlUtils.querySmms(username: defaultUser);
      if (querysmms == 'Empty') {
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
      if (querysmms == 'Error') {
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
      if (queryuser['defaultPShost'] == 'sm.ms') {
        await Global.setPShost('sm.ms');
        await Global.setShowedPBhost('smms');
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
        sqlconfig.add('sm.ms');
        var updateResult = await MySqlUtils.updateUser(content: sqlconfig);
        if (updateResult == 'Success') {
          await Global.setPShost('sm.ms');
          await Global.setShowedPBhost('smms');
          Fluttertoast.showToast(
              msg: "已设置sm.ms为默认图床",
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

class SmmsConfigModel {
  final String token;

  SmmsConfigModel(this.token);

  Map<String, dynamic> toJson() => {
        'token': token,
      };
}
