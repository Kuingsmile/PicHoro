import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:f_logs/f_logs.dart';
import 'package:fluro/fluro.dart';

import 'package:horopic/router/application.dart';
import 'package:horopic/router/routers.dart';
import 'package:horopic/utils/global.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/utils/sql_utils.dart';
import 'package:horopic/pages/loading.dart';
import 'package:horopic/configure_page/user_manage/user_information_page.dart';
import 'package:horopic/picture_host_configure/configure_store/configure_store_file.dart';

class APPPassword extends StatefulWidget {
  const APPPassword({Key? key}) : super(key: key);

  @override
  APPPasswordState createState() => APPPasswordState();
}

class APPPasswordState extends State<APPPassword> {
  final _userNametext = TextEditingController();
  final _passwordcontroller = TextEditingController();
  bool loginStatus = false;

  _saveuserpasswd() async {
    try {
      await Global.setPassword(_passwordcontroller.text);
      var usernamecheck =
          await MySqlUtils.queryUser(username: _userNametext.text);

      if (usernamecheck == 'Empty') {
        //如果没有这个用户，就创建一个，设置初始选项
        await Global.setUser(_userNametext.text);
        await Global.setPassword(_passwordcontroller.text);
        //设定默认的图床
        await Global.setPShost('lsky.pro');
        await Global.setShowedPBhost('lskypro');
        await Global.setLKformat('rawurl');
        await ConfigureStoreFile().generateConfigureFile();
        //创建相册数据库
        Database db = await Global.getDatabase();
        await Global.setDatabase(db);
        Database dbExtend = await Global.getDatabaseExtend();
        await Global.setDatabaseExtend(dbExtend);
        //在数据库中创建用户
        var result = await MySqlUtils.insertUser(content: [
          _userNametext.text,
          _passwordcontroller.text,
          Global.defaultPShost,
        ]);
        if (result == 'Success') {
          await ConfigureStoreFile().generateConfigureFile();
          return showToast('创建用户成功');
        } else {
          return showToast('创建用户失败');
        }
      } else if (usernamecheck == 'Error') {
        return showToast('数据库错误');
      } else {
        if (usernamecheck['password'] == _passwordcontroller.text) {
          if (Global.defaultUser != _userNametext.text) {
            await Global.setUser(_userNametext.text);
            await Global.setPassword(_passwordcontroller.text);
            await Global.setPShost(usernamecheck['defaultPShost']);
            // ignore: use_build_context_synchronously
            await fetchconfig(context, _userNametext.text.toString(),
                _passwordcontroller.text.toString());
            Database db = await Global.getDatabase();
            await Global.setDatabase(db);
            Database dbExtend = await Global.getDatabaseExtend();
            await Global.setDatabaseExtend(dbExtend);
            await ConfigureStoreFile().generateConfigureFile();
            loginStatus = true;
            return showToast('登录成功');
          } else {
            await ConfigureStoreFile().generateConfigureFile();
            return showToast('已经登录');
          }
        } else {
          return showToast('密码错误');
        }
      }
    } catch (e) {
      FLog.error(
          className: 'APPPasswordState',
          methodName: '_saveuserpasswd',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      return showToast('未知错误');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: titleText('登录'),
      ),
      body: signUpPage(),
    );
  }

  Widget signUpPage() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 60),
            child: Container(
              width: 200,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Image.asset('assets/app_icon.png'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: TextFormField(
              controller: _userNametext,
              decoration: const InputDecoration(
                hintText: '请输入用户名',
                hintStyle: TextStyle(color: Colors.grey, fontSize: 14.0),
              ),
              textAlign: TextAlign.center,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "用户名不能为空";
                }
                return null;
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15, right: 15, top: 15),
            child: TextFormField(
              controller: _passwordcontroller,
              obscureText: true,
              obscuringCharacter: '*',
              decoration: const InputDecoration(
                hintText: '请输入密码',
                hintStyle: TextStyle(color: Colors.grey, fontSize: 14.0),
              ),
              textAlign: TextAlign.center,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '密码不能为空';
                }
                return null;
              },
            ),
          ),
          const Divider(
            height: 20,
            color: Colors.transparent,
          ),
          Container(
            height: 50,
            width: 250,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF17ead9),
                  Color.fromARGB(255, 144, 161, 245),
                ],
              ),
            ),
            child: TextButton(
                onPressed: () async {
                  if (_userNametext.text.isEmpty) {
                    return showToastWithContext(context, '用户名不能为空');
                  }
                  if (_passwordcontroller.text.isEmpty) {
                    return showToastWithContext(context, '密码不能为空');
                  }
                  RegExp blank = RegExp(r"\s");
                  if (blank.hasMatch(_userNametext.text)) {
                    return showToastWithContext(context, '用户名不能包含空白字符');
                  }
                  if (blank.hasMatch(_passwordcontroller.text)) {
                    return showToastWithContext(context, '密码不能包含空白字符');
                  }
                  await showDialog(
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
                  if (mounted) {
                    if (loginStatus == false) {
                      Navigator.pop(context);
                    } else {
                      Navigator.pop(context);
                      Application.router.navigateTo(
                          context, Routes.userInformationPage,
                          transition: TransitionType.inFromRight);
                    }
                  }
                },
                child: const Text(
                  '注册或登录',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                )),
          ),
        ],
      ),
    );
  }
}
