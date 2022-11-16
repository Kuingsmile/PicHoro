import 'package:flutter/material.dart';
import 'package:f_logs/f_logs.dart';
import 'package:fluro/fluro.dart';
import 'dart:convert';
import 'package:horopic/utils/global.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/utils/sql_utils.dart';
import 'package:horopic/pages/loading.dart';
import 'package:horopic/picture_host_manage/manage_api/imgur_manage_api.dart';
import 'package:horopic/router/application.dart';
import 'package:horopic/router/routers.dart';

class ImgurLogIn extends StatefulWidget {
  const ImgurLogIn({Key? key}) : super(key: key);

  @override
  ImgurLogInState createState() => ImgurLogInState();
}

class ImgurLogInState extends State<ImgurLogIn> {
  final _imgurUserController = TextEditingController();
  final _clientIDcontroller = TextEditingController();
  final _clientSecretcontroller = TextEditingController();
  final _accessTokencontroller = TextEditingController();
  final _proxyController = TextEditingController();
  bool loginStatus = false;

  @override
  initState() {
    super.initState();
    loginStatus = false;
  }

  _saveuserpasswd() async {
    try {
      String proxy = 'None';
      if (_proxyController.text.isNotEmpty) {
        proxy = _proxyController.text;
      }
      String currentPicHoroUser = await Global.getUser();
      String currentPicHoroPasswd = await Global.getPassword();
      var usernamecheck =
          await MySqlUtils.queryUser(username: currentPicHoroUser);
      if (usernamecheck == 'Empty') {
        return showToast('请先去设置页面注册');
      } else if (currentPicHoroPasswd != usernamecheck['password']) {
        return showToast('请先去设置页面登录');
      }
      var queryImgurManage =
          await MySqlUtils.queryImgurManage(username: currentPicHoroUser);
      if (queryImgurManage == 'Empty') {
        var checkTokenResult = await ImgurManageAPI.checkToken(
            _imgurUserController.text, _accessTokencontroller.text, proxy);
        if (checkTokenResult[0] == 'success') {
          var saveResult = await MySqlUtils.insertImgurManage(content: [
            _imgurUserController.text,
            _clientIDcontroller.text,
            _clientSecretcontroller.text,
            _accessTokencontroller.text,
            proxy,
            currentPicHoroUser
          ]);
          if (saveResult == 'Success') {
            loginStatus = true;
            return showToast('保存成功');
          } else {
            return showToast('保存失败');
          }
        } else {
          return showToast('登录失败');
        }
      } else if (queryImgurManage == 'Error') {
        return showToast('获取数据库错误');
      } else {
        var checkTokenResult = await ImgurManageAPI.checkToken(
            _imgurUserController.text, _accessTokencontroller.text, proxy);
        if (checkTokenResult[0] == 'success') {
          loginStatus = true;
          var updateResult = await MySqlUtils.updateImgurManage(
            content: [
              _imgurUserController.text,
              _clientIDcontroller.text,
              _clientSecretcontroller.text,
              _accessTokencontroller.text,
              proxy,
              currentPicHoroUser
            ],
          );
          if (updateResult == 'Success') {
            return showToast('更新成功');
          } else {
            return showToast('更新失败');
          }
        } else {
          return showToast('登录失败');
        }
      }
    } catch (e) {
      FLog.error(
          className: 'ImgurLogInState',
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
        title: const Text('登录Imgur'),
      ),
      body: signUpPage(),
    );
  }

  Widget signUpPage() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Container(
              width: 100,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Image.asset('assets/icons/fakesmms.png'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: TextFormField(
              controller: _imgurUserController,
              decoration: const InputDecoration(
                hintText: '请输入Imgur用户名',
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
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: TextFormField(
              controller: _clientIDcontroller,
              decoration: const InputDecoration(
                hintText: '请输入Client ID',
                hintStyle: TextStyle(color: Colors.grey, fontSize: 14.0),
              ),
              textAlign: TextAlign.center,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Client ID不能为空";
                }
                return null;
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15, right: 15, top: 15),
            child: TextFormField(
              controller: _clientSecretcontroller,
              decoration: const InputDecoration(
                hintText: '请输入Client Secret',
                hintStyle: TextStyle(color: Colors.grey, fontSize: 14.0),
              ),
              textAlign: TextAlign.center,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Client Secret不能为空';
                }
                return null;
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15, right: 15, top: 15),
            child: TextFormField(
              controller: _accessTokencontroller,
              decoration: const InputDecoration(
                hintText: '请输入Access Token',
                hintStyle: TextStyle(color: Colors.grey, fontSize: 14.0),
              ),
              textAlign: TextAlign.center,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Access Token不能为空';
                }
                return null;
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15, right: 15, top: 15),
            child: TextFormField(
              controller: _proxyController,
              decoration: const InputDecoration(
                hintText: '可选：请输入代理地址',
                hintStyle: TextStyle(color: Colors.grey, fontSize: 14.0),
              ),
              textAlign: TextAlign.center,
              autovalidateMode: AutovalidateMode.onUserInteraction,
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
                  if (_imgurUserController.text.isEmpty ||
                      _clientIDcontroller.text.isEmpty ||
                      _clientSecretcontroller.text.isEmpty ||
                      _accessTokencontroller.text.isEmpty) {
                    return showToastWithContext(context, '请填写完整信息');
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
                      Map userInfo = {
                        'imguruser': _imgurUserController.text,
                        "clientid": _clientIDcontroller.text,
                        'clientsecret': _clientSecretcontroller.text,
                        'accesstoken': _accessTokencontroller.text,
                        'proxy': _proxyController.text.isEmpty
                            ? "None"
                            : _proxyController.text,
                      };
                      Application.router.navigateTo(context,
                          '${Routes.imgurFileExplorer}?userProfile=${Uri.encodeComponent(jsonEncode(userInfo))}&albumInfo=${Uri.encodeComponent(jsonEncode({}))}&allImages=${Uri.encodeComponent(jsonEncode([]))}',
                          transition: TransitionType.inFromRight);
                    }
                  }
                },
                child: const Text(
                  '登录Imgur',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                )),
          ),
        ],
      ),
    );
  }
}
