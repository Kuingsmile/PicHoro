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
import 'package:horopic/hostconfigure/Imgurconfig.dart';
import 'package:dio_proxy_adapter/dio_proxy_adapter.dart';
import 'package:horopic/hostconfigure/qiniuconfig.dart';
import 'package:horopic/api/qiniu.dart';
import 'package:flutter/services.dart';
import 'package:qiniu_flutter_sdk/qiniu_flutter_sdk.dart';

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

  //imgur配置
  Future<File> get imgurFile async {
    final path = await _localPath;
    String defaultUser = await Global.getUser();
    return File('$path/${defaultUser}_imgur_config.txt');
  }

  //qiniu配置
  Future<File> get qiniuFile async {
    final path = await _localPath;
    String defaultUser = await Global.getUser();
    return File('$path/${defaultUser}_qiniu_config.txt');
  }

  processingQRCodeResult() async {
    String result = Global.qrScanResult;
    Global.qrScanResult = "";
    if (!(result.contains('smms')) &&
        !(result.contains('github')) &&
        !(result.contains('lankong')) &&
        !(result.contains('imgur')) &&
        !(result.contains('qiniu'))) {
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
        BaseOptions options = BaseOptions(
          //连接服务器超时时间，单位是毫秒.
          connectTimeout: 30000,
          //响应超时时间。
          receiveTimeout: 30000,
          sendTimeout: 30000,
        );
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
          BaseOptions options = BaseOptions(
            //连接服务器超时时间，单位是毫秒.
            connectTimeout: 30000,
            //响应超时时间。
            receiveTimeout: 30000,
            sendTimeout: 30000,
          );
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
                    msg: "Github数据库错误",
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

            BaseOptions options = BaseOptions(
              //连接服务器超时时间，单位是毫秒.
              connectTimeout: 30000,
              //响应超时时间。
              receiveTimeout: 30000,
              sendTimeout: 30000,
            );
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

    if (jsonResult['imgur'] != null) {
      final imgurclientId = jsonResult['imgur']['clientId'];
      String imgurProxy = jsonResult['imgur']['proxy'];
      try {
        List sqlconfig = [];
        sqlconfig.add(imgurclientId);
        sqlconfig.add(imgurProxy);
        String defaultUser = await Global.getUser();
        sqlconfig.add(defaultUser);

        var queryimgur = await MySqlUtils.queryImgur(username: defaultUser);
        var queryuser = await MySqlUtils.queryUser(username: defaultUser);

        if (queryuser == 'Empty') {
          Fluttertoast.showToast(
              msg: "请先登录",
              toastLength: Toast.LENGTH_SHORT,
              timeInSecForIosWeb: 2,
              fontSize: 16.0);
        }
        String baiduPicUrl =
            "https://dss0.bdstatic.com/5aV1bjqh_Q23odCf/static/superman/img/logo/logo_white-d0c9fe2af5.png";
        String validateURL = "https://api.imgur.com/3/image";

        BaseOptions options = BaseOptions(
          //连接服务器超时时间，单位是毫秒.
          connectTimeout: 30000,
          //响应超时时间。
          receiveTimeout: 30000,
          sendTimeout: 30000,
        );
        options.headers = {
          "Authorization": "Client-ID $imgurclientId",
        };
        //需要加一个空的formdata，不然会报错
        FormData formData = FormData.fromMap({
          "image": baiduPicUrl,
        });
        Dio dio = Dio(options);
        String proxyClean = '';

        if (imgurProxy != 'None') {
          if (imgurProxy.startsWith('http://') ||
              imgurProxy.startsWith('https://')) {
            proxyClean = imgurProxy.split('://')[1];
          } else {
            proxyClean = imgurProxy;
          }
          dio.useProxy(proxyClean);
        }

        String sqlResult = '';
        try {
          var validateResponse = await dio.post(validateURL, data: formData);
          if (validateResponse.statusCode == 200 &&
              validateResponse.data['success'] == true) {
            if (queryimgur == 'Empty') {
              sqlResult = await MySqlUtils.insertImgur(content: sqlconfig);
            } else {
              sqlResult = await MySqlUtils.updateImgur(content: sqlconfig);
            }
            if (sqlResult == "Success") {
              final imgurConfig = ImgurConfigModel(imgurclientId, imgurProxy);
              final imgurConfigJson = jsonEncode(imgurConfig);
              final imgurConfigFile = await smmsFile;
              await imgurConfigFile.writeAsString(imgurConfigJson);
              Fluttertoast.showToast(
                  msg: "Imgur配置成功",
                  toastLength: Toast.LENGTH_SHORT,
                  timeInSecForIosWeb: 2,
                  fontSize: 16.0);
            } else {
              Fluttertoast.showToast(
                  msg: "Imgur数据库错误",
                  toastLength: Toast.LENGTH_SHORT,
                  timeInSecForIosWeb: 2,
                  fontSize: 16.0);
            }
          } else {
            Fluttertoast.showToast(
                msg: "Imgur验证失败",
                toastLength: Toast.LENGTH_SHORT,
                timeInSecForIosWeb: 2,
                fontSize: 16.0);
          }
        } catch (e) {
          rethrow;
        }
      } catch (e) {
        Fluttertoast.showToast(
            msg: "Imgur配置错误",
            toastLength: Toast.LENGTH_SHORT,
            timeInSecForIosWeb: 2,
            fontSize: 16.0);
      }
    }

    if (jsonResult['qiniu'] != null) {
      String qiniuAccessKey = jsonResult['qiniu']['accessKey'];
      String qiniuSecretKey = jsonResult['qiniu']['secretKey'];
      String qiniuBucket = jsonResult['qiniu']['bucket'];
      String qiniuUrl = jsonResult['qiniu']['url'];
      String qiniuArea = jsonResult['qiniu']['area'];
      String qiniuOptions = jsonResult['qiniu']['options'];
      String qiniuPath = jsonResult['qiniu']['path'];

      try {
        List sqlconfig = [];
        sqlconfig.add(qiniuAccessKey);
        sqlconfig.add(qiniuSecretKey);
        sqlconfig.add(qiniuBucket);
        sqlconfig.add(qiniuUrl);
        sqlconfig.add(qiniuArea);
        sqlconfig.add(qiniuOptions);
        sqlconfig.add(qiniuPath);
        String defaultUser = await Global.getUser();
        sqlconfig.add(defaultUser);

        var queryqiniu = await MySqlUtils.queryQiniu(username: defaultUser);
        var queryuser = await MySqlUtils.queryUser(username: defaultUser);

        if (queryuser == 'Empty') {
          Fluttertoast.showToast(
              msg: "请先登录",
              toastLength: Toast.LENGTH_SHORT,
              timeInSecForIosWeb: 2,
              fontSize: 16.0);
        }
        if (!qiniuUrl.startsWith('http') && !qiniuUrl.startsWith('https')) {
          qiniuUrl = 'http://$qiniuUrl';
        }

        if (qiniuPath.startsWith('/')) {
          qiniuPath = qiniuPath.substring(1);
        }
        if (!qiniuPath.endsWith('/')) {
          qiniuPath = '$qiniuPath/';
        }
        //save asset image to app dir
        String assetPath = 'assets/validateImage/PicHoroValidate.jpeg';
        String appDir = await getApplicationDocumentsDirectory().then((value) {
          return value.path;
        });
        String assetFilePath = '$appDir/PicHoroValidate.jpeg';
        File assetFile = File(assetFilePath);

        if (!assetFile.existsSync()) {
          ByteData data = await rootBundle.load(assetPath);
          List<int> bytes =
              data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
          await assetFile.writeAsBytes(bytes);
        }
        String key = 'PicHoroValidate.jpeg';
        String urlSafeBase64EncodePutPolicy =
            QiniuImageUploadUtils.geturlSafeBase64EncodePutPolicy(
                qiniuBucket, key, qiniuPath);
        String uploadToken = QiniuImageUploadUtils.getUploadToken(
            qiniuAccessKey, qiniuSecretKey, urlSafeBase64EncodePutPolicy);
        Storage storage = Storage(
            config: Config(
          retryLimit: 5,
        ));

        String sqlResult = '';
        try {
          PutResponse putresult =
              await storage.putFile(File(assetFilePath), uploadToken);
          if (putresult.key == key || putresult.key == '$qiniuPath$key') {
            if (queryqiniu == 'Empty') {
              sqlResult = await MySqlUtils.insertQiniu(content: sqlconfig);
            } else {
              sqlResult = await MySqlUtils.updateQiniu(content: sqlconfig);
            }
            if (sqlResult == "Success") {
              final qiniuConfig = QiniuConfigModel(
                  qiniuAccessKey,
                  qiniuSecretKey,
                  qiniuBucket,
                  qiniuUrl,
                  qiniuArea,
                  qiniuOptions,
                  qiniuPath);
              final qiniuConfigJson = jsonEncode(qiniuConfig);
              final qiniuConfigFile = await qiniuFile;
              await qiniuConfigFile.writeAsString(qiniuConfigJson);
              Fluttertoast.showToast(
                  msg: "七牛云配置成功",
                  toastLength: Toast.LENGTH_SHORT,
                  timeInSecForIosWeb: 2,
                  fontSize: 16.0);
            } else {
              Fluttertoast.showToast(
                  msg: "七牛云数据库错误",
                  toastLength: Toast.LENGTH_SHORT,
                  timeInSecForIosWeb: 2,
                  fontSize: 16.0);
            }
          } else {
            Fluttertoast.showToast(
                msg: "七牛云验证失败",
                toastLength: Toast.LENGTH_SHORT,
                timeInSecForIosWeb: 2,
                fontSize: 16.0);
          }
        } catch (e) {
          rethrow;
        }
      } catch (e) {
        Fluttertoast.showToast(
            msg: "七牛云配置错误",
            toastLength: Toast.LENGTH_SHORT,
            timeInSecForIosWeb: 2,
            fontSize: 16.0);
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
            title: const Text('兰空图床V2'),
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
          ListTile(
            title: const Text('Imgur图床（需翻墙）'),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const ImgurConfig()));
            },
            trailing: const Icon(Icons.arrow_forward_ios),
          ),
          ListTile(
            title: const Text('七牛云'),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const QiniuConfig()));
            },
            trailing: const Icon(Icons.arrow_forward_ios),
          ),
        ]));
  }
}
