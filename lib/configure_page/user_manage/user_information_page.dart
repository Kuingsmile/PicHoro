import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluro/fluro.dart';
import 'package:f_logs/f_logs.dart';
import 'package:path_provider/path_provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:horopic/pages/loading.dart';
import 'package:horopic/router/application.dart';
import 'package:horopic/router/routers.dart';
import 'package:horopic/utils/global.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/utils/sql_utils.dart';

import 'package:horopic/picture_host_manage/common_page/loading_state.dart'
    as loading_state;
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
import 'package:sqflite/sqflite.dart';

class UserInformationPage extends StatefulWidget {
  const UserInformationPage({Key? key}) : super(key: key);

  @override
  UserInformationPageState createState() => UserInformationPageState();
}

class UserInformationPageState
    extends loading_state.BaseLoadingPageState<UserInformationPage> {
  Map userProfile = {};
  Map psHostTranlate = {
    'sm.ms': 'SM.MS',
    'tencent': '腾讯云',
    'aliyun': '阿里云',
    'qiniu': '七牛云',
    'upyun': '又拍云',
    'github': 'GitHub',
    'imgur': 'Imgur',
    'lsky.pro': '兰空图床',
    'ftp': 'FTP',
  };

  @override
  void initState() {
    super.initState();
    initProfile();
  }

  initProfile() async {
    String defaultUser = await Global.getUser();
    userProfile['username'] = defaultUser;
    String defaultPictureHost = await Global.getPShost();
    userProfile['pictureHost'] = psHostTranlate[defaultPictureHost];
    setState(() {
      state = loading_state.LoadState.SUCCESS;
    });
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
                  className: 'UserInformationPageState',
                  methodName: '_fetchconfig_lskyhost',
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
                  className: 'UserInformationPageState',
                  methodName: '_fetchconfig_smmshost',
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
                  className: 'UserInformationPageState',
                  methodName: '_fetchconfig_githubhost',
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
                  className: 'UserInformationPageState',
                  methodName: '_fetchconfig_imgurhost',
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
                  className: 'UserInformationPageState',
                  methodName: '_fetchconfig_qiniuhost',
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
                  className: 'UserInformationPageState',
                  methodName: '_fetchconfig_tencenthost',
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
                  className: 'UserInformationPageState',
                  methodName: '_fetchconfig_aliyunhost',
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
                  className: 'UserInformationPageState',
                  methodName: '_fetchconfig_upyunhost',
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
          className: 'UserInformationPageState',
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
  AppBar get appBar => AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text('用户信息'),
      );

  @override
  Widget buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/empty.png',
            width: 100,
            height: 100,
          ),
          const Text('暂无数据',
              style: TextStyle(
                  fontSize: 20, color: Color.fromARGB(136, 121, 118, 118)))
        ],
      ),
    );
  }

  @override
  Widget buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('加载失败',
              style: TextStyle(
                  fontSize: 20, color: Color.fromARGB(136, 121, 118, 118))),
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.blue),
            ),
            onPressed: () {
              setState(() {
                state = loading_state.LoadState.LOADING;
              });
            },
            child: const Text('重新加载'),
          )
        ],
      ),
    );
  }

  @override
  Widget buildLoading() {
    return const Center(
      child: SizedBox(
        width: 30,
        height: 30,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          backgroundColor: Colors.transparent,
          valueColor: AlwaysStoppedAnimation(Colors.blue),
        ),
      ),
    );
  }

  @override
  Widget buildSuccess() {
    return ListView(children: [
      Center(
        child: Padding(
          padding: const EdgeInsets.all(3.0),
          child: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: MediaQuery.of(context).size.width / 10,
                  backgroundColor: Colors.transparent,
                  backgroundImage:
                      const Image(image: AssetImage('assets/app_icon.png'))
                          .image,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
      Column(
        children: [
          ListTile(
            leading: const Icon(Icons.person, color: Colors.blue),
            minLeadingWidth: 0,
            title: const Text('用户名'),
            trailing: Text(userProfile['username'].toString(),
                style: const TextStyle(fontSize: 16)),
          ),
          ListTile(
            leading: const Icon(Icons.image_outlined, color: Colors.blue),
            minLeadingWidth: 0,
            title: const Text('当前图床'),
            trailing: Text(userProfile['pictureHost'].toString(),
                style: const TextStyle(fontSize: 16)),
          ),
          Container(
            color: const Color.fromARGB(255, 250, 245, 231),
            child: ListTile(
              leading:
                  const Icon(Icons.folder_open_outlined, color: Colors.blue),
              minLeadingWidth: 0,
              title: const Text('图床管理'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Application.router.navigateTo(
                    context, Routes.pictureHostInfoPage,
                    transition: TransitionType.inFromRight);
              },
            ),
          ),
          const SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            CupertinoButton(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              color: const Color.fromARGB(255, 11, 148, 240),
              child: const Text('云端拉取'),
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
                  FLog.error(
                      className: 'UserInformationPageState',
                      methodName: '云端拉取',
                      text: formatErrorMessage({
                        'username': currentusername,
                      }, e.toString()),
                      dataLogType: DataLogType.ERRORS.toString());
                  return showCupertinoAlertDialog(
                      context: context, title: "错误", content: "拉取失败,请重试!");
                }
              },
            ),
            const SizedBox(width: 20),
            CupertinoButton(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              color: const Color.fromARGB(255, 187, 197, 202),
              child: const Text('注销登录'),
              onPressed: () async {
                await Global.setUser(' ');
                await Global.setPassword(' ');
                await Global.setPShost('lsky.pro');
                await Global.setLKformat('rawurl');
                await Global.setTimeStamp(false);
                await Global.setRandomName(false);
                await Global.setCustomeRename(false);
                await Global.setCopyLink(true);
                Database db = await Global.getDatabase();
                await Global.setDatabase(db);
                Database dbExtend = await Global.getDatabaseExtend();
                await Global.setDatabaseExtend(dbExtend);
                await Global.setShowedPBhost('lskypro');
                await Global.setDeleteLocal(false);
                await Global.setCustomLinkFormat(r'[$fileName]($url)');
                await Global.setCustomeRenameFormat(r'{filename}');
                await Global.setDeleteCloud(false);
                await Global.setOperateDone(false);
                await Global.setpsHostHomePageOrder([
                  '0',
                  '1',
                  '2',
                  '3',
                  '4',
                  '5',
                  '6',
                  '7',
                  '8'
                      '9',
                  '10',
                  '11',
                  '12',
                  '13',
                  '14',
                  '15',
                  '16',
                  '17',
                  '18',
                  '19',
                  '20',
                  '21',
                ]);
                await Global.setTencentUploadList([]);
                await Global.setTencentDownloadList([]);
                await Global.setAliyunUploadList([]);
                await Global.setAliyunDownloadList([]);
                await Global.setQiniuUploadList([]);
                await Global.setQiniuDownloadList([]);
                await Global.setLskyproUploadList([]);
                await Global.setLskyproDownloadList([]);
                await Global.setUpyunUploadList([]);
                await Global.setUpyunDownloadList([]);
                await Global.setImgurUploadList([]);
                await Global.setImgurDownloadList([]);
                await Global.setSmmsUploadList([]);
                await Global.setSmmsDownloadList([]);
                await Global.setSmmsSavedNameList([]);
                await Global.setGithubUploadList([]);
                await Global.setGithubDownloadList([]);
                await Global.setFtpUploadList([]);
                await Global.setFtpDownloadList([]);
                showToast('注销成功');
                if (mounted) {
                  Navigator.pop(context);
                }
              },
            ),
          ]),
        ],
      ),
    ]);
  }
}
