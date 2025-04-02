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
  final _formKey = GlobalKey<FormState>();

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
          await ImgurManageAPI().checkToken(_imgurUserController.text, _accessTokencontroller.text, proxy);
      if (checkTokenResult[0] == 'success') {
        var saveResult = await ImgurManageAPI().saveImgurManageConfig(
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor.withValues(alpha: 0.1),
              Theme.of(context).scaffoldBackgroundColor,
            ],
          ),
        ),
        child: signUpPage(),
      ),
    );
  }

  Widget signUpPage() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Logo with animation
              TweenAnimationBuilder(
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(milliseconds: 800),
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.scale(
                      scale: value,
                      child: child,
                    ),
                  );
                },
                child: Hero(
                  tag: 'imgur_logo',
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(60),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(15),
                    child: Image.asset('assets/icons/fakesmms.png', fit: BoxFit.contain),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Form card
              Card(
                elevation: 4,
                shadowColor: Colors.black26,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      // Username field
                      buildInputField(
                        controller: _imgurUserController,
                        hintText: '请输入Imgur用户名',
                        icon: Icons.person_outline,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "用户名不能为空";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // Client ID field
                      buildInputField(
                        controller: _clientIDcontroller,
                        hintText: '请输入Client ID',
                        icon: Icons.vpn_key_outlined,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Client ID不能为空";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // Access Token field
                      buildInputField(
                        controller: _accessTokencontroller,
                        hintText: '请输入Access Token',
                        icon: Icons.lock_outline,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Access Token不能为空';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // Proxy field (optional)
                      buildInputField(
                        controller: _proxyController,
                        hintText: '可选：请输入代理地址',
                        icon: Icons.settings_ethernet,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Login button
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
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
                  } else {
                    showToastWithContext(context, '请填写完整信息');
                  }
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.transparent,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 5,
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF17ead9),
                        Color.fromARGB(255, 90, 120, 250),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.7,
                    height: 55,
                    alignment: Alignment.center,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.login_rounded, size: 24),
                        SizedBox(width: 10),
                        Text(
                          '登录 Imgur',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14.0),
        prefixIcon: Icon(icon, color: Theme.of(context).primaryColor),
        filled: true,
        fillColor: Colors.grey.withValues(alpha: 0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
      ),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: validator,
    );
  }
}
