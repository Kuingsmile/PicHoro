import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluro/fluro.dart';

import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/widgets/common_widgets.dart';
import 'package:horopic/widgets/net_loading_dialog.dart';
import 'package:horopic/picture_host_manage/manage_api/imgur_manage_api.dart';
import 'package:horopic/router/application.dart';
import 'package:horopic/router/routers.dart';

class ImgurLogIn extends StatefulWidget {
  const ImgurLogIn({super.key});

  @override
  ImgurLogInState createState() => ImgurLogInState();
}

class ImgurLogInState extends State<ImgurLogIn> {
  final _imgurUserController = TextEditingController();
  final _clientIDcontroller = TextEditingController();
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

      var checkTokenResult =
          await ImgurManageAPI.checkToken(_imgurUserController.text, _accessTokencontroller.text, proxy);
      if (checkTokenResult[0] == 'success') {
        var saveResult = await ImgurManageAPI.saveImgurManageConfig(
            _imgurUserController.text, _clientIDcontroller.text, _accessTokencontroller.text, proxy);
        if (saveResult) {
          loginStatus = true;
          return showToast('保存成功');
        } else {
          return showToast('保存失败');
        }
      } else {
        return showToast('登录失败');
      }
    } catch (e) {
      flogErr(e, {}, 'ImgurLogInState', '_saveuserpasswd');
      return showToast('未知错误');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: titleText('登录Imgur'),
        flexibleSpace: getFlexibleSpace(context),
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
                        'accesstoken': _accessTokencontroller.text,
                        'proxy': _proxyController.text.isEmpty ? "None" : _proxyController.text,
                      };
                      Application.router.navigateTo(context,
                          '${Routes.imgurFileExplorer}?userProfile=${Uri.encodeComponent(jsonEncode(userInfo))}&albumInfo=${Uri.encodeComponent(jsonEncode({}))}&allImages=${Uri.encodeComponent(jsonEncode([]))}',
                          transition: TransitionType.inFromRight);
                    }
                  }
                },
                child: const Text(
                  '登录Imgur',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                )),
          ),
        ],
      ),
    );
  }
}
