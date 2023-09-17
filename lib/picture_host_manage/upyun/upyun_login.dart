import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:f_logs/f_logs.dart';
import 'package:fluro/fluro.dart';

import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/pages/loading.dart';
import 'package:horopic/picture_host_manage/manage_api/upyun_manage_api.dart';
import 'package:horopic/router/application.dart';
import 'package:horopic/router/routers.dart';

class UpyunLogIn extends StatefulWidget {
  const UpyunLogIn({Key? key}) : super(key: key);

  @override
  UpyunLogInState createState() => UpyunLogInState();
}

class UpyunLogInState extends State<UpyunLogIn> {
  final _userNametext = TextEditingController();
  final _passwordcontroller = TextEditingController();
  bool loginStatus = false;

  @override
  initState() {
    super.initState();
    loginStatus = false;
  }

  _saveuserpasswd() async {
    try {
      var queryUpyunManage = await UpyunManageAPI.readUpyunManageConfig();
      if (queryUpyunManage == 'Error' || queryUpyunManage == '') {
        var getTokenResult = await UpyunManageAPI.getToken(_userNametext.text, _passwordcontroller.text);
        if (getTokenResult[0] == 'success') {
          String token = getTokenResult[1]['access_token'];
          String tokenName = getTokenResult[1]['name'];
          var saveResult = await UpyunManageAPI.saveUpyunManageConfig(
              _userNametext.text, _passwordcontroller.text, token, tokenName);
          if (saveResult) {
            loginStatus = true;
            return showToast('保存成功');
          } else {
            return showToast('保存失败');
          }
        } else {
          return showToast('登录失败');
        }
      } else {
        var jsonResult = jsonDecode(queryUpyunManage);
        String token = jsonResult['token'];
        var checkTokenResult = await UpyunManageAPI.checkToken(token);
        if (checkTokenResult[0] == 'success') {
          loginStatus = true;
          return showToast('保存成功');
        } else {
          var getTokenResult = await UpyunManageAPI.getToken(_userNametext.text, _passwordcontroller.text);
          if (getTokenResult[0] == 'success') {
            String token = getTokenResult[1]['access_token'];
            String tokenName = getTokenResult[1]['name'];
            var saveResult = await UpyunManageAPI.saveUpyunManageConfig(
              _userNametext.text,
              _passwordcontroller.text,
              token,
              tokenName,
            );
            if (saveResult) {
              loginStatus = true;
              return showToast('保存成功');
            } else {
              return showToast('保存失败');
            }
          } else {
            return showToast('登录失败');
          }
        }
      }
    } catch (e) {
      FLog.error(
          className: 'UpyunLogInState',
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
        title: titleText('登录又拍云'),
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
              child: Image.asset('assets/icons/upyun.png'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: TextFormField(
              controller: _userNametext,
              decoration: const InputDecoration(
                hintText: '请输入又拍云用户名',
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
              obscuringCharacter: '*',
              decoration: const InputDecoration(
                hintText: '请输入又拍云密码',
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
                      Application.router
                          .navigateTo(context, Routes.upyunBucketList, transition: TransitionType.inFromRight);
                    }
                  }
                },
                child: const Text(
                  '登录又拍云',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                )),
          ),
        ],
      ),
    );
  }
}
