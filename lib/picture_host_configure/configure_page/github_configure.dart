import 'dart:io';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:f_logs/f_logs.dart';
import 'package:fluro/fluro.dart';

import 'package:horopic/router/application.dart';
import 'package:horopic/pages/loading.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/utils/sql_utils.dart';
import 'package:horopic/utils/global.dart';
import 'package:horopic/picture_host_manage/manage_api/github_manage_api.dart';
import 'package:horopic/utils/event_bus_utils.dart';

class GithubConfig extends StatefulWidget {
  const GithubConfig({Key? key}) : super(key: key);

  @override
  GithubConfigState createState() => GithubConfigState();
}

class GithubConfigState extends State<GithubConfig> {
  final _formKey = GlobalKey<FormState>();

  final _githubusernameController = TextEditingController();
  final _repoController = TextEditingController();
  final _tokenController = TextEditingController();
  final _storePathController = TextEditingController();
  final _branchController = TextEditingController();
  final _customDomainController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initConfig();
  }

  _initConfig() async {
    try {
      Map configMap = await GithubManageAPI.getConfigMap();
      _githubusernameController.text = configMap['githubusername'];
      _repoController.text = configMap['repo'];
      _tokenController.text = configMap['token'];
      if (configMap['storePath'] != 'None') {
        _storePathController.text = configMap['storePath'];
      } else {
        _storePathController.clear();
      }
      _branchController.text = configMap['branch'];
      if (configMap['customDomain'] != 'None') {
        _customDomainController.text = configMap['customDomain'];
      } else {
        _customDomainController.clear();
      }
      setState(() {});
    } catch (e) {
      FLog.error(
          className: 'GithubConfigState',
          methodName: '_initConfig',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
    }
  }

  @override
  void dispose() {
    _githubusernameController.dispose();
    _repoController.dispose();
    _tokenController.dispose();
    _storePathController.dispose();
    _branchController.dispose();
    _customDomainController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: titleText('Github????????????'),
        actions: [
          IconButton(
            onPressed: () async {
              await Application.router.navigateTo(
                  context, '/configureStorePage?psHost=github',
                  transition: TransitionType.cupertino);
              await _initConfig();
              setState(() {});
            },
            icon: const Icon(Icons.save_as_outlined,
                color: Color.fromARGB(255, 255, 255, 255), size: 35),
          )
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          children: [
            TextFormField(
              controller: _githubusernameController,
              decoration: const InputDecoration(
                label: Center(child: Text('Github?????????')),
                hintText: '???????????????',
              ),
              textAlign: TextAlign.center,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '?????????Github?????????';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _repoController,
              decoration: const InputDecoration(
                label: Center(child: Text('?????????')),
                hintText: '???????????????',
              ),
              textAlign: TextAlign.center,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '??????????????????';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _tokenController,
              decoration: const InputDecoration(
                label: Center(child: Text('token')),
                hintText: '??????Token',
              ),
              textAlign: TextAlign.center,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '?????????token';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _storePathController,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.zero,
                label: Center(child: Text('??????:????????????')),
                hintText: '??????: test/',
              ),
              textAlign: TextAlign.center,
            ),
            TextFormField(
              controller: _branchController,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.zero,
                label: Center(child: Text('???????????????')),
                hintText: '??????: main(?????????main)',
              ),
              textAlign: TextAlign.center,
            ),
            TextFormField(
              controller: _customDomainController,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.zero,
                label: Center(child: Text('????????????????????????')),
                hintText: 'eg: https://cdn.jsdelivr.net/gh/?????????/?????????@?????????',
                hintStyle: TextStyle(fontSize: 13),
              ),
              textAlign: TextAlign.center,
            ),
            ListTile(
                title: ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) {
                        return NetLoadingDialog(
                          outsideDismiss: false,
                          loading: true,
                          loadingText: "?????????...",
                          requestCallBack: _saveGithubConfig(),
                        );
                      });
                }
              },
              child: titleText('????????????',fontsize: null),
            )),
            ListTile(
                title: ElevatedButton(
              onPressed: () {
                showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) {
                      return NetLoadingDialog(
                        outsideDismiss: false,
                        loading: true,
                        loadingText: "?????????...",
                        requestCallBack: checkGithubConfig(),
                      );
                    });
              },
              child: titleText('??????????????????',fontsize: null),
            )),
            ListTile(
                title: ElevatedButton(
              onPressed: () async {
                await Application.router.navigateTo(
                    context, '/configureStorePage?psHost=github',
                    transition: TransitionType.cupertino);
                await _initConfig();
                setState(() {});
              },
              child: titleText('??????????????????',fontsize: null),
            )),
            ListTile(
                title: ElevatedButton(
              onPressed: () {
                _setdefault();
              },
              child: titleText('??????????????????',fontsize: null),
            )),
          ],
        ),
      ),
    );
  }

  Future _saveGithubConfig() async {
    String token = 'Bearer ';
    String githubUserApi = 'https://api.github.com/user';
    final String githubusername = _githubusernameController.text;
    final String repo = _repoController.text;
    String storePath = '';
    if (_storePathController.text.isEmpty ||
        _storePathController.text.trim().isEmpty) {
      storePath = 'None';
    } else {
      storePath = _storePathController.text;
      if (!storePath.endsWith('/')) {
        storePath = '$storePath/';
      }
    }

    String branch = '';
    if (_branchController.text.isEmpty ||
        _branchController.text.trim().isEmpty) {
      branch = 'main';
    } else {
      branch = _branchController.text;
    }
    String customDomain = '';
    if (_customDomainController.text.isEmpty ||
        _customDomainController.text.trim().isEmpty) {
      customDomain = 'None';
    } else {
      customDomain = _customDomainController.text;
      if (!customDomain.startsWith('http') &&
          !customDomain.startsWith('https')) {
        customDomain = 'http://$customDomain';
      }
      if (customDomain.endsWith('/')) {
        customDomain = customDomain.substring(0, customDomain.length - 1);
      }
    }

    if (_tokenController.text.startsWith('Bearer ')) {
      token = _tokenController.text;
    } else {
      token = token + _tokenController.text;
    }

    try {
      List sqlconfig = [];
      sqlconfig.add(githubusername);
      sqlconfig.add(repo);
      sqlconfig.add(token);
      sqlconfig.add(storePath);
      sqlconfig.add(branch);
      sqlconfig.add(customDomain);
      //??????????????????
      String defaultUser = await Global.getUser();
      sqlconfig.add(defaultUser);

      var queryGithub = await MySqlUtils.queryGithub(username: defaultUser);
      var queryuser = await MySqlUtils.queryUser(username: defaultUser);

      if (queryuser == 'Empty') {
        return showCupertinoAlertDialog(
            context: context, title: '??????', content: '???????????????,????????????');
      }
      BaseOptions options = BaseOptions(
        connectTimeout: 30000,
        receiveTimeout: 30000,
        sendTimeout: 30000,
      );
      options.headers = {
        "Accept": 'application/vnd.github+json',
        "Authorization": token,
      };
      //?????????????????????formdata??????????????????
      Map<String, dynamic> queryData = {};
      Dio dio = Dio(options);
      String sqlResult = '';
      try {
        var validateResponse =
            await dio.get(githubUserApi, queryParameters: queryData);
        if (validateResponse.statusCode == 200 &&
            validateResponse.data.toString().contains("email")) {
          //????????????
          if (queryGithub == 'Empty') {
            sqlResult = await MySqlUtils.insertGithub(content: sqlconfig);
          } else {
            sqlResult = await MySqlUtils.updateGithub(content: sqlconfig);
          }
          if (sqlResult == "Success") {
            final githubConfig = GithubConfigModel(
                githubusername, repo, token, storePath, branch, customDomain);
            final githubConfigJson = jsonEncode(githubConfig);
            final githubConfigFile = await localFile;
            await githubConfigFile.writeAsString(githubConfigJson);
            return showCupertinoAlertDialog(
                context: context, title: '??????', content: '????????????');
          } else {
            return showCupertinoAlertDialog(
                context: context, title: '??????', content: '???????????????');
          }
        } else {
          return showCupertinoAlertDialog(
              context: context, title: '??????', content: 'token??????');
        }
      } catch (e) {
        FLog.error(
            className: 'GithubConfigPage',
            methodName: '_saveGithubConfig_1',
            text: formatErrorMessage({}, e.toString()),
            dataLogType: DataLogType.ERRORS.toString());
        return showCupertinoAlertDialog(
            context: context, title: '??????', content: e.toString());
      }
    } catch (e) {
      FLog.error(
          className: 'GithubConfigPage',
          methodName: '_saveGithubConfig_2',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      return showCupertinoAlertDialog(
          context: context, title: '??????', content: e.toString());
    }
  }

  checkGithubConfig() async {
    try {
      final githubConfigFile = await localFile;
      String configData = await githubConfigFile.readAsString();

      if (configData == "Error") {
        return showCupertinoAlertDialog(
            context: context, title: "????????????!", content: "????????????????????????.");
      }

      Map configMap = jsonDecode(configData);
      BaseOptions options = BaseOptions(
        connectTimeout: 30000,
        receiveTimeout: 30000,
        sendTimeout: 30000,
      );
      options.headers = {
        "Authorization": configMap["token"],
        "Accept": 'application/vnd.github+json',
      };
      String validateURL = "https://api.github.com/user";
      Map<String, dynamic> queryData = {};
      Dio dio = Dio(options);
      var response = await dio.get(validateURL, queryParameters: queryData);

      if (response.statusCode == 200 &&
          response.data.toString().contains("email")) {
        return showCupertinoAlertDialog(
          context: context,
          title: '??????',
          content:
              '????????????????????????????????????:\n?????????:\n${configMap["githubusername"]}\n?????????:\n${configMap["repo"]}\n????????????:\n${configMap["storePath"]}\n??????:\n${configMap["branch"]}\n???????????????:\n${configMap["customDomain"]}',
        );
      } else {
        return showCupertinoAlertDialog(
            context: context, title: '??????', content: '????????????????????????????????????');
      }
    } catch (e) {
      FLog.error(
          className: 'GithubConfigPage',
          methodName: 'checkGithubConfig',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      return showCupertinoAlertDialog(
          context: context, title: "????????????!", content: e.toString());
    }
  }

  Future<File> get localFile async {
    final path = await _localPath;
    String defaultUser = await Global.getUser();
    return File('$path/${defaultUser}_github_config.txt');
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<String> readGithubConfig() async {
    try {
      final file = await localFile;
      String contents = await file.readAsString();
      return contents;
    } catch (e) {
      FLog.error(
          className: 'GithubConfigPage',
          methodName: 'readGithubConfig',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      return "Error";
    }
  }

  _setdefault() async {
    try {
      String defaultUser = await Global.getUser();
      String defaultPassword = await Global.getPassword();

      var queryuser = await MySqlUtils.queryUser(username: defaultUser);
      if (queryuser == 'Empty') {
        return Fluttertoast.showToast(
            msg: "??????????????????",
            toastLength: Toast.LENGTH_SHORT,
            timeInSecForIosWeb: 2,
            fontSize: 16.0);
      } else if (queryuser['password'] != defaultPassword) {
        return Fluttertoast.showToast(
            msg: "????????????",
            toastLength: Toast.LENGTH_SHORT,
            timeInSecForIosWeb: 2,
            fontSize: 16.0);
      }

      var queryGithub = await MySqlUtils.queryGithub(username: defaultUser);
      if (queryGithub == 'Empty') {
        return Fluttertoast.showToast(
            msg: "????????????????????????",
            toastLength: Toast.LENGTH_SHORT,
            timeInSecForIosWeb: 2,
            fontSize: 16.0);
      }
      if (queryGithub == 'Error') {
        return Fluttertoast.showToast(
            msg: "Error",
            toastLength: Toast.LENGTH_SHORT,
            timeInSecForIosWeb: 2,
            fontSize: 16.0);
      }
      if (queryuser['defaultPShost'] == 'github') {
        await Global.setPShost('github');
        await Global.setShowedPBhost('github');
        eventBus.fire(AlbumRefreshEvent(albumKeepAlive: false));
        eventBus.fire(HomePhotoRefreshEvent(homePhotoKeepAlive: false));
        return Fluttertoast.showToast(
            msg: "?????????????????????",
            toastLength: Toast.LENGTH_SHORT,
            timeInSecForIosWeb: 2,
            fontSize: 16.0);
      } else {
        List sqlconfig = [];
        sqlconfig.add(defaultUser);
        sqlconfig.add(defaultPassword);
        sqlconfig.add('github');

        var updateResult = await MySqlUtils.updateUser(content: sqlconfig);
        if (updateResult == 'Success') {
          await Global.setPShost('github');
          await Global.setShowedPBhost('github');
          eventBus.fire(AlbumRefreshEvent(albumKeepAlive: false));
          eventBus.fire(HomePhotoRefreshEvent(homePhotoKeepAlive: false));
          showToast('?????????Github???????????????');
        } else {
          showToast('?????????????????????');
        }
      }
    } catch (e) {
      FLog.error(
          className: 'GithubConfigPage',
          methodName: '_setdefault',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      showToastWithContext(context, '??????');
    }
  }
}

class GithubConfigModel {
  final String githubusername;
  final String repo;
  final String token;
  final String storePath;
  final String branch;
  final String customDomain;

  GithubConfigModel(this.githubusername, this.repo, this.token, this.storePath,
      this.branch, this.customDomain);

  Map<String, dynamic> toJson() => {
        'githubusername': githubusername,
        'repo': repo,
        'token': token,
        'storePath': storePath,
        'branch': branch,
        'customDomain': customDomain,
      };

  static List keysList = [
    'remarkName',
    'githubusername',
    'repo',
    'token',
    'storePath',
    'branch',
    'customDomain',
  ];
}
