import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluro/fluro.dart';

import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/widgets/common_widgets.dart';
import 'package:horopic/widgets/net_loading_dialog.dart';
import 'package:horopic/picture_host_manage/manage_api/upyun_manage_api.dart';
import 'package:horopic/router/application.dart';
import 'package:horopic/router/routers.dart';

class UpyunLogIn extends StatefulWidget {
  const UpyunLogIn({super.key});

  @override
  UpyunLogInState createState() => UpyunLogInState();
}

class UpyunLogInState extends State<UpyunLogIn> {
  final _userNametext = TextEditingController();
  final _passwordcontroller = TextEditingController();
  bool loginStatus = false;
  bool _obscurePassword = true;
  final _formKey = GlobalKey<FormState>();

  @override
  initState() {
    super.initState();
    loginStatus = false;
  }

  _saveuserpasswd() async {
    try {
      var queryUpyunManage = await UpyunManageAPI().readUpyunManageConfig();
      if (queryUpyunManage != 'Error' && queryUpyunManage != '') {
        var jsonResult = jsonDecode(queryUpyunManage);
        if ((await UpyunManageAPI().checkToken(jsonResult['token']))[0] == 'success') {
          loginStatus = true;
          return showToast('登录成功');
        }
      }

      var getTokenResult = await UpyunManageAPI().getToken(_userNametext.text, _passwordcontroller.text);
      if (getTokenResult[0] != 'success') {
        return showToast('登录失败');
      }
      String token = getTokenResult[1]['access_token'];
      String tokenName = getTokenResult[1]['name'];
      var saveResult =
          await UpyunManageAPI().saveUpyunManageConfig(_userNametext.text, _passwordcontroller.text, token, tokenName);
      loginStatus = saveResult;
      return showToast(saveResult ? '登录成功' : '登录失败');
    } catch (e) {
      flogErr(
        e,
        {
          'userName': _userNametext.text,
          'password': _passwordcontroller.text,
        },
        'UpyunLogInState',
        '_saveuserpasswd',
      );
      return showToast('未知错误');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: getLeadingIcon(context),
        centerTitle: true,
        elevation: 0,
        title: titleText('登录又拍云'),
        flexibleSpace: getFlexibleSpace(context),
      ),
      body: signUpPage(),
    );
  }

  Widget signUpPage() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).scaffoldBackgroundColor,
            Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.8),
          ],
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Logo
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 20,
                          spreadRadius: 5,
                        )
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        'assets/icons/upyun.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Welcome text
                  Text(
                    '欢迎使用又拍云',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    '请登录您的又拍云账号',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Username field
                  TextFormField(
                    controller: _userNametext,
                    decoration: InputDecoration(
                      labelText: '用户名',
                      hintText: '请输入又拍云用户名',
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "用户名不能为空";
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // Password field
                  TextFormField(
                    controller: _passwordcontroller,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: '密码',
                      hintText: '请输入又拍云密码',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '密码不能为空';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 40),

                  // Login button
                  SizedBox(
                    height: 55,
                    width: double.infinity,
                    child: ElevatedButton(
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
                            if (loginStatus) {
                              Navigator.pop(context);
                              Application.router
                                  .navigateTo(context, Routes.upyunBucketList, transition: TransitionType.inFromRight);
                            }
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF17ead9),
                        foregroundColor: Colors.white,
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.login, size: 24),
                          SizedBox(width: 10),
                          Text(
                            '登录',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Footer text
                  Text(
                    '又拍云提供高性能、高可靠的云服务',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
