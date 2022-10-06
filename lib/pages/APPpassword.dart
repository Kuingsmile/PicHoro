import 'package:flutter/material.dart';
import 'package:horopic/utils/global.dart';
import 'package:horopic/utils/common_func.dart';
import 'package:horopic/utils/sqlUtils.dart';
import 'package:horopic/pages/loading.dart';
import 'package:horopic/hostconfigure/hostconfig.dart' as lskyhost;
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

class APPPassword extends StatefulWidget {
  const APPPassword({Key? key}) : super(key: key);

  @override
  _APPPasswordState createState() => _APPPasswordState();
}

class _APPPasswordState extends State<APPPassword> {
  final _formKey = GlobalKey<FormState>();
  final _userNametext = TextEditingController();
  final _passwordcontroller = TextEditingController();

  _saveuserpasswd() async {
    try {
      await Global.setPassword(_passwordcontroller.text);
      var usernamecheck =
          await MySqlUtils.queryUser(username: _userNametext.text);

      if (usernamecheck == 'Empty') {
        await Global.setUser(_userNametext.text);
        await Global.setPassword(_passwordcontroller.text);
        var result = await MySqlUtils.insertUser(content: [
          _userNametext.text,
          _passwordcontroller.text,
          Global.defaultPShost
        ]);
        if (result == 'Success') {
          return showAlertDialog(
              context: context, title: '通知', content: '已成功注册，请妥善保管您的密码');
        } else {
          return showAlertDialog(
              context: context, title: '通知', content: '注册失败，请重试');
        }
      } else if (usernamecheck == 'Error') {
        return showAlertDialog(
            context: context, title: "错误", content: "设置失败,请重试!");
      } else {
        if (usernamecheck['password'] == _passwordcontroller.text) {
          if (Global.defaultUser != _userNametext.text) {
            await Global.setUser(_userNametext.text);
            await Global.setPassword(_passwordcontroller.text);
            await Global.setPShost(usernamecheck['defaultPShost']);
            await _fetchconfig(_userNametext.text.toString(),
                _passwordcontroller.text.toString());

            return showAlertDialog(
                context: context, title: '通知', content: '已成功切换用户');
          } else {
            return showAlertDialog(
                context: context, title: '通知', content: '您已登录，请勿重复登录');
          }
        } else {
          return showAlertDialog(
              context: context, title: '通知', content: '密码错误，请重试');
        }
      }
    } catch (e) {
      return showAlertDialog(
          context: context, title: "错误", content: "设置失败,请重试!");
    }
  }

  _fetchconfig(String username, String password) async {
    try {
      var usernamecheck = await MySqlUtils.queryUser(username: username);
      if (usernamecheck == 'Empty') {
        return showAlertDialog(
            context: context, title: '通知', content: '用户不存在，请重试');
      } else if (usernamecheck == 'Error') {
        return showAlertDialog(
            context: context, title: "错误", content: "获取登录信息失败,请重试!");
      } else {
        if (usernamecheck['password'] == password) {
          await Global.setUser(username);
          await Global.setPassword(password);
          await Global.setPShost(usernamecheck['defaultPShost']);
          //拉取兰空图床配置
          var lskyhostresult =
              await MySqlUtils.queryLankong(username: username);
          if (lskyhostresult == 'Error') {
            return showAlertDialog(
                context: context, title: "错误", content: "获取登录信息失败,请重试!");
          } else if (lskyhostresult != 'Empty') {
            try {
              final hostConfig = lskyhost.HostConfigModel(
                lskyhostresult['host'],
                lskyhostresult['token'],
                lskyhostresult['strategy_id'],
              );
              final hostConfigJson = jsonEncode(hostConfig);
              final directory = await getApplicationDocumentsDirectory();
              File lskyLocalFile = File('${directory.path}/host_config.txt');
              lskyLocalFile.writeAsString(hostConfigJson);
            } catch (e) {
              return showAlertDialog(
                  context: context, title: "错误", content: "拉取兰空图床配置失败,请重试!");
            }
          }
          //全部拉取完成后，提示用户
          return Fluttertoast.showToast(
              msg: "已拉取云端配置",
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
          return showAlertDialog(
              context: context, title: '通知', content: '密码错误，请重试');
        }
      }
    } catch (e) {
      return showAlertDialog(
          context: context, title: "错误", content: "拉取失败,请重试!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('APP密码设置'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          children: [
            TextFormField(
              controller: _userNametext,
              decoration: const InputDecoration(
                hintText: '请输入用户名',
              ),
              textAlign: TextAlign.center,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "用户名不能为空";
                }
                return null;
              },
            ),
            TextFormField(
              obscureText: true,
              controller: _passwordcontroller,
              decoration: const InputDecoration(
                hintText: '请输入8位数字密码,用于数据库加密',
              ),
              textAlign: TextAlign.center,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '密码不能为空';
                }
                if (value.length != 8) {
                  return '密码长度必须为8位';
                }
                try {
                  int.parse(value);
                } catch (e) {
                  return '密码必须为数字';
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
                          requestCallBack: _saveuserpasswd(),
                        );
                      });
                }
              },
              child: const Text('注册和登录'),
            ),
            ElevatedButton(
              onPressed: () async {
                String currentusername = await Global.getUser();
                var usernamecheck =
                    await MySqlUtils.queryUser(username: currentusername);
                String currentpassword = await Global.getPassword();
                try {
                  if (usernamecheck['password'] == currentpassword) {
                    showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) {
                          return NetLoadingDialog(
                            outsideDismiss: false,
                            loading: true,
                            loadingText: "配置中...",
                            requestCallBack:
                                _fetchconfig(currentusername, currentpassword),
                          );
                        });
                  }
                } catch (e) {
                  if (_formKey.currentState!.validate()) {
                    showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) {
                          return NetLoadingDialog(
                            outsideDismiss: false,
                            loading: true,
                            loadingText: "配置中...",
                            requestCallBack: _fetchconfig(
                                _userNametext.text.toString(),
                                _passwordcontroller.text.toString()),
                          );
                        });
                  }
                }
              },
              child: const Text('拉取云端配置'),
            ),
          ],
        ),
      ),
    );
  }
}
