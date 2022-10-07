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
class HostConfig extends StatefulWidget {
  const HostConfig({Key? key}) : super(key: key);

  @override
  _HostConfigState createState() => _HostConfigState();
}

class _HostConfigState extends State<HostConfig> {
  final _formKey = GlobalKey<FormState>();
  final _hostController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwdController = TextEditingController();
  final _strategyIdController = TextEditingController();

  @override
  void dispose() {
    _hostController.dispose();
    _usernameController.dispose();
    _passwdController.dispose();
    _strategyIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('图床参数配置'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          children: [
            TextFormField(
              controller: _hostController,
              decoration: const InputDecoration(
                hintText: '域名(eg:https://imgx.horosama.com )',
              ),
              textAlign: TextAlign.center,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入域名';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(
                hintText: '用户名',
              ),
              textAlign: TextAlign.center,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入用户名';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _passwdController,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: '密码',
              ),
              textAlign: TextAlign.center,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入密码';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _strategyIdController,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.zero,
                hintText: '储存策略Id,可先输入前三项获取完整列表',
              ),
              textAlign: TextAlign.center,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入储存策略Id';
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
                          requestCallBack: _saveHostConfig(),
                        );
                      });
                }
              },
              child: const Text('提交完整表单'),
            ),
            ElevatedButton(
              onPressed: () {
                _getStrategyId();
              },
              child: const Text('获取储存策略Id列表'),
            ),
            ElevatedButton(
              onPressed: () {
                checkHostConfig();
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

  void _getStrategyId() async {
    final host = _hostController.text;
    String token = 'Bearer ';
    final username = _usernameController.text;
    final passwd = _passwdController.text;
    BaseOptions options = BaseOptions();
    options.headers = {
      "Accept": "application/json",
    };
    Dio dio = Dio(options);
    String fullUrl = '$host/api/v1/tokens';
    FormData formData = FormData.fromMap({
      'email': username,
      'password': passwd,
    });
    try {
      var response = await dio.post(
        fullUrl,
        data: formData,
      );
      if (response.statusCode == 200 && response.data['status'] == true) {
        token = token + response.data['data']['token'].toString();
        String strategiesUrl = '$host/api/v1/strategies';
        BaseOptions strategiesOptions = BaseOptions();
        strategiesOptions.headers = {
          "Accept": "application/json",
          "Authorization": token,
        };
        dio = Dio(strategiesOptions);
        response = await dio.get(strategiesUrl);

        showAlertDialog(
            barrierDismissible: false,
            context: context,
            title: '储存策略Id列表',
            content: response.data['data']['strategies'].toString());
      } else {
        if (response.statusCode == 403) {
          showAlertDialog(context: context, title: '错误', content: '管理员关闭了接口功能');
          return;
        } else if (response.statusCode == 401) {
          showAlertDialog(context: context, title: '错误', content: '授权失败');
          return;
        } else if (response.statusCode == 500) {
          showAlertDialog(context: context, title: '错误', content: '服务器异常');
          return;
        } else if (response.statusCode == 404) {
          showAlertDialog(context: context, title: '错误', content: '接口不存在');
          return;
        }
        if (response.data['status'] == false) {
          showAlertDialog(
              context: context, title: '错误', content: response.data['message']);
          return;
        }
      }
    } catch (e) {
      showAlertDialog(context: context, title: '错误', content: e.toString());
    }
  }

  Future _saveHostConfig() async {
    final host = _hostController.text;
    String token = 'Bearer ';
    final username = _usernameController.text;
    final passwd = _passwdController.text;
    final strategyId = _strategyIdController.text;
    BaseOptions options = BaseOptions();
    options.headers = {
      "Accept": "application/json",
    };
    Dio dio = Dio(options);
    String fullUrl = '$host/api/v1/tokens';
    FormData formData = FormData.fromMap({
      'email': username,
      'password': passwd,
    });
    try {
      var response = await dio.post(
        fullUrl,
        data: formData,
      );
      if (response.statusCode == 200 && response.data['status'] == true) {
        token = token + response.data['data']['token'].toString();
        try {
          List sqlconfig = [];
          sqlconfig.add(host);
          sqlconfig.add(strategyId.toString());
          sqlconfig.add(token);
          String defaultUser = await Global.getUser();
          sqlconfig.add(defaultUser);
          var querylankong =
              await MySqlUtils.queryLankong(username: defaultUser);
          var queryuser = await MySqlUtils.queryUser(username: defaultUser);
          if (queryuser == 'Empty') {
            return showAlertDialog(
                context: context, title: '错误', content: '用户不存在,请先登录');
          } else if (querylankong == 'Empty') {
            await MySqlUtils.insertLankong(content: sqlconfig);
          } else {
            await MySqlUtils.updateLankong(content: sqlconfig);
          }
        } catch (e) {
          return showAlertDialog(
              context: context, title: '错误', content: e.toString());
        }
        final hostConfig = HostConfigModel(host, token, strategyId.toString());
        final hostConfigJson = jsonEncode(hostConfig);
        final hostConfigFile = await _localFile;
        hostConfigFile.writeAsString(hostConfigJson);

        return showAlertDialog(
            context: context,
            barrierDismissible: false,
            title: '配置成功',
            content: '您的密钥为：$token,\n请妥善保管，不要泄露给他人');
      } else {
        if (response.statusCode == 403) {
          return showAlertDialog(
              context: context, title: '错误', content: '管理员关闭了接口功能');
        } else if (response.statusCode == 401) {
          return showAlertDialog(
              context: context, title: '错误', content: '授权失败');
        } else if (response.statusCode == 500) {
          return showAlertDialog(
              context: context, title: '错误', content: '服务器异常');
        } else if (response.statusCode == 404) {
          return showAlertDialog(
              context: context, title: '错误', content: '接口不存在');
        }
        if (response.data['status'] == false) {
          return showAlertDialog(
              context: context, title: '错误', content: response.data['message']);
        }
      }
    } catch (e) {
      return showAlertDialog(
          context: context, title: '错误', content: e.toString());
    }
  }

  void checkHostConfig() async {
    try {
      final hostConfigFile = await _localFile;
      String configData = await hostConfigFile.readAsString();
      if (configData == "Error") {
        showAlertDialog(context: context, title: "检查失败!", content: "请先配置上传参数.");
        return;
      }
      Map configMap = jsonDecode(configData);
      BaseOptions options = BaseOptions();
      options.headers = {
        "Authorization": configMap["token"],
        "Accept": "application/json",
        "Content-Type": "multipart/form-data",
      };
      String profileUrl = configMap["host"] + "/api/v1/profile";
      Dio dio = Dio(options);
      var response = await dio.get(
        profileUrl,
      );
      if (response.statusCode == 200 && response.data['status'] == true) {
        showAlertDialog(
            context: context,
            title: '通知',
            content:
                '检测通过，您的配置信息为：\nhost:\n${configMap["host"]}\nstrategyId:\n${configMap["strategy_id"]}\ntoken:\n${configMap["token"]}');
      } else {
        if (response.statusCode == 403) {
          showAlertDialog(context: context, title: '错误', content: '管理员关闭了接口功能');
          return;
        } else if (response.statusCode == 401) {
          showAlertDialog(context: context, title: '错误', content: '授权失败');
          return;
        } else if (response.statusCode == 500) {
          showAlertDialog(context: context, title: '错误', content: '服务器异常');
          return;
        } else if (response.statusCode == 404) {
          showAlertDialog(context: context, title: '错误', content: '接口不存在');
          return;
        }
        if (response.data['status'] == false) {
          showAlertDialog(
              context: context, title: '错误', content: response.data['message']);
          return;
        }
      }
    } catch (e) {
      showAlertDialog(context: context, title: "检查失败!", content: e.toString());
    }
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    String defaultUser = await Global.getUser();
    return File('$path/${defaultUser}_host_config.txt');
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
      var querylankong = await MySqlUtils.queryLankong(username: defaultUser);
      if (querylankong == 'Empty') {
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
      if (querylankong == 'Error') {
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
      if (queryuser['defaultPShost'] == 'lsky.pro') {
        await Global.setPShost('lsky.pro');
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
        sqlconfig.add('lsky.pro');
        var updateResult = await MySqlUtils.updateUser(content: sqlconfig);
        if (updateResult == 'Success') {
          await Global.setPShost('lsky.pro');
          Fluttertoast.showToast(
              msg: "已设置兰空图床为默认图床",
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

class HostConfigModel {
  final String host;
  final String token;
  final String strategyId;

  HostConfigModel(this.host, this.token, this.strategyId);

  Map<String, dynamic> toJson() => {
        'host': host,
        'token': token,
        'strategy_id': strategyId,
      };
}
