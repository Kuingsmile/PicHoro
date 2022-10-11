import 'package:flutter/material.dart';
import 'package:horopic/hostconfigure/lskyproconfig.dart';
import 'package:horopic/hostconfigure/smmsconfig.dart';
import 'package:horopic/hostconfigure/PShostSelect.dart';
import 'package:horopic/hostconfigure/githubconfig.dart';
import 'package:horopic/utils/common_func.dart';
import 'package:horopic/utils/global.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';
import 'dart:io';
import 'package:horopic/utils/sqlUtils.dart';
import 'package:dio/dio.dart';
import 'package:horopic/pages/loading.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:path_provider/path_provider.dart';

//a configure page for user to show configure entry
class AllPShost extends StatefulWidget {
  const AllPShost({Key? key}) : super(key: key);

  @override
  _AllPShostState createState() => _AllPShostState();
}

class _AllPShostState extends State<AllPShost> {
  _scan() async {
    try {
      final result = await BarcodeScanner.scan(
          options: const ScanOptions(
        strings: {
          "cancel": "取消",
          "flash_on": "打开闪光灯",
          "flash_off": "关闭闪光灯",
        },
        restrictFormat: [BarcodeFormat.qr],
        android: AndroidOptions(
          aspectTolerance: 0.00,
          useAutoFocus: true,
        ),
        autoEnableFlash: false,
      ));
      setState(() {
        Global.qrScanResult = result.rawContent.toString();
      });
    } catch (e) {
      setState(() {
        Global.qrScanResult = ScanResult(
          type: ResultType.Error,
          format: BarcodeFormat.unknown,
          rawContent: e.toString(),
        ).rawContent;
      });
    }
  }

  //smms配置
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get smmsFile async {
    final path = await _localPath;
    String defaultUser = await Global.getUser();
    return File('$path/${defaultUser}_smms_config.txt');
  }

//lskypro配置
  Future<File> get lskyFile async {
    final path = await _localPath;
    String defaultUser = await Global.getUser();
    return File('$path/${defaultUser}_host_config.txt');
  }

//github配置
  Future<File> get githubFile async {
    final path = await _localPath;
    String defaultUser = await Global.getUser();
    return File('$path/${defaultUser}_github_config.txt');
  }

  processingQRCodeResult() async {
    String result = Global.qrScanResult;
    Global.qrScanResult = "";
    if (!(result.contains('smms')) &&
        !(result.contains('github')) &&
        !(result.contains('lankong'))) {
      return Fluttertoast.showToast(
          msg: "不包含支持的图床配置信息",
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 2,
          fontSize: 16.0);
    }
    Map<String, dynamic> jsonResult = jsonDecode(result);

    if (jsonResult['smms'] != null) {
      final smmsToken = jsonResult['smms']['token'];
      try {
        List sqlconfig = [];
        sqlconfig.add(smmsToken);
        String defaultUser = await Global.getUser();
        sqlconfig.add(defaultUser);
        var querysmms = await MySqlUtils.querySmms(username: defaultUser);
        var queryuser = await MySqlUtils.queryUser(username: defaultUser);
        if (queryuser == 'Empty') {
          Fluttertoast.showToast(
              msg: "请先登录",
              toastLength: Toast.LENGTH_SHORT,
              timeInSecForIosWeb: 2,
              fontSize: 16.0);
        }
        String validateURL = "https://smms.app/api/v2/profile";
        // String validateURL = "https://sm.ms/api/v2/profile";被墙了
        BaseOptions options = BaseOptions();
        options.headers = {
          "Content-Type": 'multipart/form-data',
          "Authorization": smmsToken,
        };
        //需要加一个空的formdata，不然会报错
        FormData formData = FormData.fromMap({});
        Dio dio = Dio(options);
        String sqlResult = '';
        try {
          var validateResponse = await dio.post(validateURL, data: formData);
          if (validateResponse.statusCode == 200 &&
              validateResponse.data['success'] == true) {
            if (querysmms == 'Empty') {
              sqlResult = await MySqlUtils.insertSmms(content: sqlconfig);
            } else {
              sqlResult = await MySqlUtils.updateSmms(content: sqlconfig);
            }
            if (sqlResult == "Success") {
              final smmsConfig = SmmsConfigModel(smmsToken);
              final smmsConfigJson = jsonEncode(smmsConfig);
              final smmsConfigFile = await smmsFile;
              await smmsConfigFile.writeAsString(smmsConfigJson);
              Fluttertoast.showToast(
                  msg: "smms配置成功",
                  toastLength: Toast.LENGTH_SHORT,
                  timeInSecForIosWeb: 2,
                  fontSize: 16.0);
            } else {
              Fluttertoast.showToast(
                  msg: "smms数据库错误",
                  toastLength: Toast.LENGTH_SHORT,
                  timeInSecForIosWeb: 2,
                  fontSize: 16.0);
            }
          } else {
            Fluttertoast.showToast(
                msg: "Smms验证失败",
                toastLength: Toast.LENGTH_SHORT,
                timeInSecForIosWeb: 2,
                fontSize: 16.0);
          }
        } catch (e) {
          rethrow;
        }
      } catch (e) {
        Fluttertoast.showToast(
            msg: "SM.MS配置错误",
            toastLength: Toast.LENGTH_SHORT,
            timeInSecForIosWeb: 2,
            fontSize: 16.0);
      }
    }
    if (jsonResult['github'] != null) {
      try {
        String token = jsonResult['github']['token'];
        String githubUserApi = 'https://api.github.com/user';
        String usernameRepo = jsonResult['github']['repo'];
        String githubusername =
            usernameRepo.substring(0, usernameRepo.indexOf('/'));
        String repo = usernameRepo.substring(usernameRepo.indexOf('/') + 1);
        String storePath = jsonResult['github']['path'];
        if (storePath == null || storePath == '' || storePath.isEmpty) {
          storePath = 'None';
        }
        String branch = jsonResult['github']['branch'];
        if (branch == '' || branch == null || branch.isEmpty) {
          branch = 'main';
        }
        String customDomain = jsonResult['github']['customUrl'];
        if (customDomain == '' ||
            customDomain == null ||
            customDomain.isEmpty) {
          customDomain = 'None';
        }

        if (token.startsWith('Bearer ')) {
        } else {
          token = 'Bearer $token';
        }

        try {
          List sqlconfig = [];
          sqlconfig.add(githubusername);
          sqlconfig.add(repo);
          sqlconfig.add(token);
          sqlconfig.add(storePath);
          sqlconfig.add(branch);
          sqlconfig.add(customDomain);
          //添加默认用户
          String defaultUser = await Global.getUser();
          sqlconfig.add(defaultUser);

          var queryGithub = await MySqlUtils.queryGithub(username: defaultUser);
          var queryuser = await MySqlUtils.queryUser(username: defaultUser);

          if (queryuser == 'Empty') {
            Fluttertoast.showToast(
                msg: "请先登录",
                toastLength: Toast.LENGTH_SHORT,
                timeInSecForIosWeb: 2,
                fontSize: 16.0);
          }
          BaseOptions options = BaseOptions();
          options.headers = {
            "Accept": 'application/vnd.github+json',
            "Authorization": token,
          };
          //需要加一个空的formdata，不然会报错
          Map<String, dynamic> queryData = {};
          Dio dio = Dio(options);
          String sqlResult = '';
          try {
            var validateResponse =
                await dio.get(githubUserApi, queryParameters: queryData);
            if (validateResponse.statusCode == 200 &&
                validateResponse.data.toString().contains("email")) {
              //验证成功
              if (queryGithub == 'Empty') {
                sqlResult = await MySqlUtils.insertGithub(content: sqlconfig);
              } else {
                sqlResult = await MySqlUtils.updateGithub(content: sqlconfig);
              }
              if (sqlResult == "Success") {
                final githubConfig = GithubConfigModel(githubusername, repo,
                    token, storePath, branch, customDomain);
                final githubConfigJson = jsonEncode(githubConfig);
                final githubConfigFile = await githubFile;
                await githubConfigFile.writeAsString(githubConfigJson);
                Fluttertoast.showToast(
                    msg: "Github配置成功",
                    toastLength: Toast.LENGTH_SHORT,
                    timeInSecForIosWeb: 2,
                    fontSize: 16.0);
              } else {
                Fluttertoast.showToast(
                    msg: "github数据库错误",
                    toastLength: Toast.LENGTH_SHORT,
                    timeInSecForIosWeb: 2,
                    fontSize: 16.0);
              }
            } else {
              Fluttertoast.showToast(
                  msg: "Github验证失败",
                  toastLength: Toast.LENGTH_SHORT,
                  timeInSecForIosWeb: 2,
                  fontSize: 16.0);
            }
          } catch (e) {
            Fluttertoast.showToast(
                msg: "Github验证失败",
                toastLength: Toast.LENGTH_SHORT,
                timeInSecForIosWeb: 2,
                fontSize: 16.0);
          }
        } catch (e) {
          Fluttertoast.showToast(
              msg: "Github配置错误",
              toastLength: Toast.LENGTH_SHORT,
              timeInSecForIosWeb: 2,
              fontSize: 16.0);
        }
      } catch (e) {
        Fluttertoast.showToast(
            msg: "Github配置错误",
            toastLength: Toast.LENGTH_SHORT,
            timeInSecForIosWeb: 2,
            fontSize: 16.0);
      }

      if (jsonResult['lankong'] != null) {
        try {
          String lankongVersion = jsonResult['lankong']['lskyProVersion'];
          if (lankongVersion == 'V2') {
            String lankongVtwoHost = jsonResult['lankong']['server'];
            if (lankongVtwoHost.endsWith('/')) {
              lankongVtwoHost =
                  lankongVtwoHost.substring(0, lankongVtwoHost.length - 1);
            }
            String lankongToken = jsonResult['lankong']['token'];
            if (lankongToken.startsWith('Bearer ')) {
            } else {
              lankongToken = 'Bearer $lankongToken';
            }
            String lanKongstrategyId = jsonResult['lankong']['strategyId'];
            if (lanKongstrategyId == '' ||
                lanKongstrategyId == null ||
                lanKongstrategyId.isEmpty) {
              lanKongstrategyId = 'None';
            }

            BaseOptions options = BaseOptions();
            options.headers = {
              "Accept": "application/json",
              "Authorization": lankongToken,
            };
            String profileUrl = "$lankongVtwoHost/api/v1/profile";
            Dio dio = Dio(options);

            String sqlResult = '';
            try {
              var response = await dio.get(
                profileUrl,
              );
              if (response.statusCode == 200 &&
                  response.data['status'] == true) {
                try {
                  List sqlconfig = [];
                  sqlconfig.add(lankongVtwoHost);
                  sqlconfig.add(lanKongstrategyId.toString());
                  sqlconfig.add(lankongToken);
                  String defaultUser = await Global.getUser();
                  sqlconfig.add(defaultUser);

                  var querylankong =
                      await MySqlUtils.queryLankong(username: defaultUser);
                  var queryuser =
                      await MySqlUtils.queryUser(username: defaultUser);

                  if (queryuser == 'Empty') {
                    Fluttertoast.showToast(
                        msg: "请先登录",
                        toastLength: Toast.LENGTH_SHORT,
                        timeInSecForIosWeb: 2,
                        fontSize: 16.0);
                  } else if (querylankong == 'Empty') {
                    sqlResult =
                        await MySqlUtils.insertLankong(content: sqlconfig);
                  } else {
                    sqlResult =
                        await MySqlUtils.updateLankong(content: sqlconfig);
                  }
                } catch (e) {
                  Fluttertoast.showToast(
                      msg: "LanKong数据库错误",
                      toastLength: Toast.LENGTH_SHORT,
                      timeInSecForIosWeb: 2,
                      fontSize: 16.0);
                }
                if (sqlResult == "Success") {
                  HostConfigModel hostConfig = HostConfigModel(
                      lankongVtwoHost, lankongToken, lanKongstrategyId);
                  final hostConfigJson = jsonEncode(hostConfig);
                  final hostConfigFile = await lskyFile;
                  hostConfigFile.writeAsString(hostConfigJson);

                  Fluttertoast.showToast(
                      msg: "LanKong配置成功",
                      toastLength: Toast.LENGTH_SHORT,
                      timeInSecForIosWeb: 2,
                      fontSize: 16.0);
                } else {
                  Fluttertoast.showToast(
                      msg: "LanKong数据库错误",
                      toastLength: Toast.LENGTH_SHORT,
                      timeInSecForIosWeb: 2,
                      fontSize: 16.0);
                }
              } else {
                Fluttertoast.showToast(
                    msg: "LanKong验证失败",
                    toastLength: Toast.LENGTH_SHORT,
                    timeInSecForIosWeb: 2,
                    fontSize: 16.0);
              }
            } catch (e) {
              Fluttertoast.showToast(
                  msg: "LanKong配置错误",
                  toastLength: Toast.LENGTH_SHORT,
                  timeInSecForIosWeb: 2,
                  fontSize: 16.0);
            }
          } else {
            Fluttertoast.showToast(
                msg: "不支持兰空V1",
                toastLength: Toast.LENGTH_SHORT,
                timeInSecForIosWeb: 2,
                fontSize: 16.0);
          }
        } catch (e) {
          Fluttertoast.showToast(
              msg: "兰空配置错误",
              toastLength: Toast.LENGTH_SHORT,
              timeInSecForIosWeb: 2,
              fontSize: 16.0);
        }
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
            '图床设置',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: ListView(children: [
          ListTile(
            tileColor: const Color.fromARGB(255, 188, 187, 238),
            textColor: const Color.fromARGB(255, 11, 173, 19),
            title: const Text('二维码扫描导入PicGo配置'),
            onTap: () async {
              await _scan();

              showDialog(
                  context: this.context,
                  barrierDismissible: false,
                  builder: (context) {
                    return NetLoadingDialog(
                      outsideDismiss: false,
                      loading: true,
                      loadingText: "配置中...",
                      requestCallBack: processingQRCodeResult(),
                    );
                  });
            },
            trailing: const Icon(Icons.arrow_forward_ios),
          ),
          const Divider(
            height: 1,
            color: Colors.grey,
          ),
          ListTile(
            title: const Text('默认图床选择'),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const defaultPShostSelect()));
            },
            trailing: const Icon(Icons.arrow_forward_ios),
          ),
          ListTile(
            title: const Text('兰空图床'),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const HostConfig()));
            },
            trailing: const Icon(Icons.arrow_forward_ios),
          ),
          ListTile(
            title: const Text('SM.MS图床'),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const SmmsConfig()));
            },
            trailing: const Icon(Icons.arrow_forward_ios),
          ),
          ListTile(
            title: const Text('Github图床'),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const GithubConfig()));
            },
            trailing: const Icon(Icons.arrow_forward_ios),
          ),
        ]));
  }
}
