import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sqflite/sqflite.dart';
import 'package:f_logs/f_logs.dart';
import 'package:fluro/fluro.dart';


import 'package:horopic/router/application.dart';
import 'package:horopic/router/routers.dart';
import 'package:horopic/utils/global.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/utils/sql_utils.dart';
import 'package:horopic/pages/loading.dart';
import 'package:horopic/picture_host_configure/configure_page/lskypro_configure.dart'
    as lskyhost;
import 'package:horopic/picture_host_configure/configure_page/smms_configure.dart'
    as smmshostclass;
import 'package:horopic/picture_host_configure/configure_page/github_configure.dart'
    as githubhostclass;
import 'package:horopic/picture_host_configure/configure_page/imgur_configure.dart'
    as imgurhostclass;
import 'package:horopic/picture_host_configure/configure_page/qiniu_configure.dart'
    as qiniuhostclass;
import 'package:horopic/picture_host_configure/configure_page/tencent_configure.dart'
    as tencenthostclass;
import 'package:horopic/picture_host_configure/configure_page/aliyun_configure.dart'
    as aliyunhostclass;
import 'package:horopic/picture_host_configure/configure_page/upyun_configure.dart'
    as upyunhostclass;
import 'package:horopic/picture_host_configure/configure_page/ftp_configure.dart'
    as ftphostclass;
import 'package:horopic/picture_host_configure/configure_page/aws_configure.dart'
    as awshostclass;
import 'package:horopic/picture_host_configure/configure_page/alist_configure.dart'
    as alisthostclass;
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
            await _fetchconfig(_userNametext.text.toString(),
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

  _fetchconfig(String username, String password) async {
    try {
      var usernamecheck = await MySqlUtils.queryUser(username: username);
      if (usernamecheck == 'Empty') {
        return showCupertinoAlertDialog(
            context: context, title: '通知', content: '用户不存在，请重试');
      } else if (usernamecheck == 'Error') {
        return showCupertinoAlertDialog(
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
            return showCupertinoAlertDialog(
                context: context, title: "错误", content: "获取兰空云端信息失败,请重试!");
          } else if (lskyhostresult != 'Empty') {
            try {
              final hostConfig = lskyhost.HostConfigModel(
                lskyhostresult['host'],
                lskyhostresult['token'],
                lskyhostresult['strategy_id'],
                lskyhostresult['album_id'],
              );
              final hostConfigJson = jsonEncode(hostConfig);
              final directory = await getApplicationDocumentsDirectory();
              File lskyLocalFile =
                  File('${directory.path}/${username}_host_config.txt');
              lskyLocalFile.writeAsString(hostConfigJson);
            } catch (e) {
              FLog.error(
                  className: 'APPPasswordState',
                  methodName: '_fetchconfig_lsky',
                  text: formatErrorMessage({
                    'username': username,
                  }, e.toString()),
                  dataLogType: DataLogType.ERRORS.toString());
              return showCupertinoAlertDialog(
                  context: context, title: "错误", content: "拉取兰空图床配置失败,请重试!");
            }
          }
          //拉取SM.MS图床配置
          var smmshostresult = await MySqlUtils.querySmms(username: username);
          if (smmshostresult == 'Error') {
            return showCupertinoAlertDialog(
                context: context, title: "错误", content: "获取SM.MS云端信息失败,请重试!");
          } else if (smmshostresult != 'Empty') {
            try {
              final smmshostConfig = smmshostclass.SmmsConfigModel(
                smmshostresult['token'],
              );
              final smmsConfigJson = jsonEncode(smmshostConfig);
              final directory = await getApplicationDocumentsDirectory();
              File smmsLocalFile =
                  File('${directory.path}/${username}_smms_config.txt');
              smmsLocalFile.writeAsString(smmsConfigJson);
            } catch (e) {
              FLog.error(
                  className: 'APPPasswordState',
                  methodName: '_fetchconfig_smms',
                  text: formatErrorMessage({
                    'username': username,
                  }, e.toString()),
                  dataLogType: DataLogType.ERRORS.toString());
              return showCupertinoAlertDialog(
                  context: context, title: "错误", content: "拉取SM.MS图床配置失败,请重试!");
            }
          }
          //拉取Github图床配置
          var githubresult = await MySqlUtils.queryGithub(username: username);
          if (githubresult == 'Error') {
            return showCupertinoAlertDialog(
                context: context, title: "错误", content: "获取Github云端信息失败,请重试!");
          } else if (githubresult != 'Empty') {
            try {
              final githubhostConfig = githubhostclass.GithubConfigModel(
                  githubresult['githubusername'],
                  githubresult['repo'],
                  githubresult['token'],
                  githubresult['storePath'],
                  githubresult['branch'],
                  githubresult['customDomain']);
              final githubConfigJson = jsonEncode(githubhostConfig);
              final directory = await getApplicationDocumentsDirectory();
              File githubLocalFile =
                  File('${directory.path}/${username}_github_config.txt');
              githubLocalFile.writeAsString(githubConfigJson);
            } catch (e) {
              FLog.error(
                  className: 'APPPasswordState',
                  methodName: '_fetchconfig_github',
                  text: formatErrorMessage({
                    'username': username,
                  }, e.toString()),
                  dataLogType: DataLogType.ERRORS.toString());
              return showCupertinoAlertDialog(
                  context: context,
                  title: "错误",
                  content: "拉取github图床配置失败,请重试!");
            }
          }
          //拉取Imgur图床配置
          var imgurresult = await MySqlUtils.queryImgur(username: username);
          if (imgurresult == 'Error') {
            return showCupertinoAlertDialog(
                context: context, title: "错误", content: "获取Imgur云端信息失败,请重试!");
          } else if (imgurresult != 'Empty') {
            try {
              final imgurhostConfig = imgurhostclass.ImgurConfigModel(
                imgurresult['clientId'],
                imgurresult['proxy'],
              );
              final imgurConfigJson = jsonEncode(imgurhostConfig);
              final directory = await getApplicationDocumentsDirectory();
              File imgurLocalFile =
                  File('${directory.path}/${username}_imgur_config.txt');
              imgurLocalFile.writeAsString(imgurConfigJson);
            } catch (e) {
              FLog.error(
                  className: 'APPPasswordState',
                  methodName: '_fetchconfig_imgur',
                  text: formatErrorMessage({
                    'username': username,
                  }, e.toString()),
                  dataLogType: DataLogType.ERRORS.toString());
              return showCupertinoAlertDialog(
                  context: context, title: "错误", content: "拉取Imgur图床配置失败,请重试!");
            }
          }
          //拉取七牛图床配置
          var qiniuresult = await MySqlUtils.queryQiniu(username: username);
          if (qiniuresult == 'Error') {
            return showCupertinoAlertDialog(
                context: context, title: "错误", content: "获取七牛云端信息失败,请重试!");
          } else if (qiniuresult != 'Empty') {
            try {
              final qiniuhostConfig = qiniuhostclass.QiniuConfigModel(
                qiniuresult['accessKey'],
                qiniuresult['secretKey'],
                qiniuresult['bucket'],
                qiniuresult['url'],
                qiniuresult['area'],
                qiniuresult['options'],
                qiniuresult['path'],
              );
              final qiniuConfigJson = jsonEncode(qiniuhostConfig);
              final directory = await getApplicationDocumentsDirectory();
              File qiniuLocalFile =
                  File('${directory.path}/${username}_qiniu_config.txt');
              qiniuLocalFile.writeAsString(qiniuConfigJson);
            } catch (e) {
              FLog.error(
                  className: 'APPPasswordState',
                  methodName: '_fetchconfig_qiniu',
                  text: formatErrorMessage({
                    'username': username,
                  }, e.toString()),
                  dataLogType: DataLogType.ERRORS.toString());
              return showCupertinoAlertDialog(
                  context: context, title: "错误", content: "拉取七牛云配置失败,请重试!");
            }
          }
          //拉取腾讯云COS图床配置
          var tencentresult = await MySqlUtils.queryTencent(username: username);
          if (tencentresult == 'Error') {
            return showCupertinoAlertDialog(
                context: context, title: "错误", content: "获取腾讯云端信息失败,请重试!");
          } else if (tencentresult != 'Empty') {
            try {
              final tencenthostConfig = tencenthostclass.TencentConfigModel(
                tencentresult['secretId'],
                tencentresult['secretKey'],
                tencentresult['bucket'],
                tencentresult['appId'],
                tencentresult['area'],
                tencentresult['path'],
                tencentresult['customUrl'],
                tencentresult['options'],
              );
              final tencentConfigJson = jsonEncode(tencenthostConfig);
              final directory = await getApplicationDocumentsDirectory();
              File tencentLocalFile =
                  File('${directory.path}/${username}_tencent_config.txt');
              tencentLocalFile.writeAsString(tencentConfigJson);
            } catch (e) {
              FLog.error(
                  className: 'APPPasswordState',
                  methodName: '_fetchconfig_tencent',
                  text: formatErrorMessage({
                    'username': username,
                  }, e.toString()),
                  dataLogType: DataLogType.ERRORS.toString());
              return showCupertinoAlertDialog(
                  context: context, title: "错误", content: "拉取腾讯云配置失败,请重试!");
            }
          }
          //拉取阿里云OSS图床配置
          var aliyunresult = await MySqlUtils.queryAliyun(username: username);
          if (aliyunresult == 'Error') {
            return showCupertinoAlertDialog(
                context: context, title: "错误", content: "获取阿里云端信息失败,请重试!");
          } else if (aliyunresult != 'Empty') {
            try {
              final aliyunhostConfig = aliyunhostclass.AliyunConfigModel(
                aliyunresult['keyId'],
                aliyunresult['keySecret'],
                aliyunresult['bucket'],
                aliyunresult['area'],
                aliyunresult['path'],
                aliyunresult['customUrl'],
                aliyunresult['options'],
              );
              final aliyunConfigJson = jsonEncode(aliyunhostConfig);
              final directory = await getApplicationDocumentsDirectory();
              File aliyunLocalFile =
                  File('${directory.path}/${username}_aliyun_config.txt');
              aliyunLocalFile.writeAsString(aliyunConfigJson);
            } catch (e) {
              FLog.error(
                  className: 'APPPasswordState',
                  methodName: '_fetchconfig_aliyun',
                  text: formatErrorMessage({
                    'username': username,
                  }, e.toString()),
                  dataLogType: DataLogType.ERRORS.toString());
              return showCupertinoAlertDialog(
                  context: context, title: "错误", content: "拉取阿里云配置失败,请重试!");
            }
          }
          //拉取又拍云图床配置
          var upyunresult = await MySqlUtils.queryUpyun(username: username);
          if (upyunresult == 'Error') {
            return showCupertinoAlertDialog(
                context: context, title: "错误", content: "获取又拍云端信息失败,请重试!");
          } else if (upyunresult != 'Empty') {
            try {
              final upyunhostConfig = upyunhostclass.UpyunConfigModel(
                upyunresult['bucket'],
                upyunresult['operator'],
                upyunresult['password'],
                upyunresult['url'],
                upyunresult['options'],
                upyunresult['path'],
              );
              final upyunConfigJson = jsonEncode(upyunhostConfig);
              final directory = await getApplicationDocumentsDirectory();
              File upyunLocalFile =
                  File('${directory.path}/${username}_upyun_config.txt');
              upyunLocalFile.writeAsString(upyunConfigJson);
            } catch (e) {
              FLog.error(
                  className: 'APPPasswordState',
                  methodName: '_fetchconfig_upyun',
                  text: formatErrorMessage({
                    'username': username,
                  }, e.toString()),
                  dataLogType: DataLogType.ERRORS.toString());
              return showCupertinoAlertDialog(
                  context: context, title: "错误", content: "拉取又拍云配置失败,请重试!");
            }
          }
          //拉取FTP配置
          var ftpresult = await MySqlUtils.queryFTP(username: username);
          if (ftpresult == 'Error') {
            return showCupertinoAlertDialog(
                context: context, title: "错误", content: "获取FTP云端信息失败,请重试!");
          } else if (ftpresult != 'Empty') {
            try {
              final ftphostConfig = ftphostclass.FTPConfigModel(
                ftpresult['ftpHost'],
                ftpresult['ftpPort'],
                ftpresult['ftpUser'],
                ftpresult['ftpPassword'],
                ftpresult['ftpType'],
                ftpresult['isAnonymous'],
                ftpresult['uploadPath'],
                ftpresult['ftpHomeDir'],
              );
              final ftpConfigJson = jsonEncode(ftphostConfig);
              final directory = await getApplicationDocumentsDirectory();
              File ftpLocalFile =
                  File('${directory.path}/${username}_ftp_config.txt');
              ftpLocalFile.writeAsString(ftpConfigJson);
            } catch (e) {
              FLog.error(
                  className: 'UserInformationPageState',
                  methodName: '_fetchconfig_ftphost',
                  text: formatErrorMessage({
                    'username': username,
                  }, e.toString()),
                  dataLogType: DataLogType.ERRORS.toString());
              return showCupertinoAlertDialog(
                  context: context, title: "错误", content: "拉取FTP配置失败,请重试!");
            }
          }
          //拉取AWS S3配置
          var awsresult = await MySqlUtils.queryAws(username: username);
          if (awsresult == 'Error') {
            return showCupertinoAlertDialog(
                context: context, title: "错误", content: "获取S3云端信息失败,请重试!");
          } else if (awsresult != 'Empty') {
            try {
              final awshostConfig = awshostclass.AwsConfigModel(
                awsresult['accessKeyId'],
                awsresult['secretAccessKey'],
                awsresult['bucket'],
                awsresult['endpoint'],
                awsresult['region'],
                awsresult['uploadPath'],
                awsresult['customUrl'],
              );
              final awsConfigJson = jsonEncode(awshostConfig);
              final directory = await getApplicationDocumentsDirectory();
              File awsLocalFile =
                  File('${directory.path}/${username}_aws_config.txt');
              awsLocalFile.writeAsString(awsConfigJson);
            } catch (e) {
              FLog.error(
                  className: 'UserInformationPageState',
                  methodName: '_fetchconfig_awshost',
                  text: formatErrorMessage({
                    'username': username,
                  }, e.toString()),
                  dataLogType: DataLogType.ERRORS.toString());
              return showCupertinoAlertDialog(
                  context: context, title: "错误", content: "拉取S3配置失败,请重试!");
            }
          }
          //拉取alist配置
          var alistresult =
              await MySqlUtils.queryAlist(username: username);
          if (alistresult == 'Error') {
            return showCupertinoAlertDialog(
                context: context, title: "错误", content: "获取Alist云端信息失败,请重试!");
          } else if (alistresult != 'Empty') {
            try {
              final alistConfig = alisthostclass.AlistConfigModel(
                alistresult['host'],
                alistresult['alistusername'],
                alistresult['password'],
                alistresult['token'],
                alistresult['uploadPath'],
              );
              final alistConfigJson = jsonEncode(alistConfig);
              final directory = await getApplicationDocumentsDirectory();
              File alistLocalFile =
                  File('${directory.path}/${username}_alist_config.txt');
              alistLocalFile.writeAsString(alistConfigJson);
            } catch (e) {
              FLog.error(
                  className: 'APPPasswordState',
                  methodName: '_fetchconfig_alist',
                  text: formatErrorMessage({
                    'username': username,
                  }, e.toString()),
                  dataLogType: DataLogType.ERRORS.toString());
              return showCupertinoAlertDialog(
                  context: context, title: "错误", content: "拉取Alist图床配置失败,请重试!");
            }
          }
          //全部拉取完成后，提示用户
          return Fluttertoast.showToast(
              msg: "已拉取云端配置",
              toastLength: Toast.LENGTH_SHORT,
              timeInSecForIosWeb: 2,
              fontSize: 16.0);
        } else {
          return showCupertinoAlertDialog(
              context: context, title: '通知', content: '密码错误，请重试');
        }
      }
    } catch (e) {
      FLog.error(
          className: 'APPPasswordState',
          methodName: '_fetchconfig_all',
          text: formatErrorMessage({
            'username': username,
          }, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      return showCupertinoAlertDialog(
          context: context, title: "错误", content: "拉取失败,请重试!");
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
