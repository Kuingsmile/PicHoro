import 'dart:io';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:f_logs/f_logs.dart';
import 'package:fluro/fluro.dart';
import 'package:path_provider/path_provider.dart';

import 'package:horopic/router/application.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/pages/loading.dart';
import 'package:horopic/utils/sql_utils.dart';
import 'package:horopic/utils/global.dart';
import 'package:horopic/utils/event_bus_utils.dart';
import 'package:horopic/picture_host_manage/manage_api/lskypro_manage_api.dart';

class HostConfig extends StatefulWidget {
  const HostConfig({Key? key}) : super(key: key);

  @override
  HostConfigState createState() => HostConfigState();
}

class HostConfigState extends State<HostConfig> {
  final _formKey = GlobalKey<FormState>();
  final _hostController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwdController = TextEditingController();
  final _strategyIdController = TextEditingController();
  final _albumIdController = TextEditingController();
  String _tokenController = '';

  @override
  void initState() {
    super.initState();
    _initConfig();
  }

  _initConfig() async {
    try {
      Map configMap = await LskyproManageAPI.getConfigMap();
      _hostController.text = configMap['host'];
      _strategyIdController.text = configMap['strategy_id'];
      if (configMap['album_id'] != 'None' && configMap['album_id'] != null) {
        _albumIdController.text = configMap['album_id'];
      } else {
        _albumIdController.clear();
      }
      _tokenController = configMap['token'];
      setState(() {});
    } catch (e) {
      FLog.error(
          className: 'LskyproConfigState',
          methodName: '_initConfig',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
    }
  }

  @override
  void dispose() {
    _hostController.dispose();
    _usernameController.dispose();
    _passwdController.dispose();
    _strategyIdController.dispose();
    _albumIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: titleText('????????????????????????'),
        actions: [
          IconButton(
            onPressed: () async {
              await Application.router.navigateTo(
                  context, '/configureStorePage?psHost=lsky.pro',
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
              controller: _hostController,
              decoration: const InputDecoration(
                label: Center(child: Text('??????')),
                hintText: '??????: https://imgx.horosama.com',
              ),
              textAlign: TextAlign.center,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '???????????????';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(
                label: Center(child: Text('?????????')),
                hintText: '???????????????',
              ),
              textAlign: TextAlign.center,
            ),
            TextFormField(
              controller: _passwdController,
              obscureText: true,
              decoration: const InputDecoration(
                label: Center(child: Text('??????')),
                hintText: '????????????',
              ),
              textAlign: TextAlign.center,
            ),
            TextFormField(
              controller: _strategyIdController,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.zero,
                label: Center(child: Text('????????????ID')),
                hintText: '????????????????????????????????????,?????????1',
              ),
              textAlign: TextAlign.center,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '?????????????????????Id';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _albumIdController,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.zero,
                label: Center(child: Text('??????:??????ID')),
                hintText: '???????????????????????????????????????????????????',
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
                          requestCallBack: _saveHostConfig(),
                        );
                      });
                }
              },
              child: titleText('????????????',fontsize: null),
            )),
            ListTile(
                title: ElevatedButton(
              onPressed: () {
                _getStrategyId();
              },
              child: titleText('??????????????????Id??????',fontsize: null),
            )),
            ListTile(
              title: ElevatedButton(
                onPressed: () {
                  _getAlbumId();
                },
                child: titleText('????????????Id??????',fontsize: null),
              ),
            ),
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
                        requestCallBack: checkHostConfig(),
                      );
                    });
              },
              child: titleText('??????????????????',fontsize: null),
            )),
              ListTile(
                title: ElevatedButton(
              onPressed: () async {
                await Application.router.navigateTo(
                    context, '/configureStorePage?psHost=lsky.pro',
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
            ListTile(
              title: const Center(
                child: Text(
                  '??????token',
                  style: TextStyle(color: Colors.black),
                ),
              ),
              subtitle: Center(
                child: SelectableText(
                  _tokenController == '' ? '?????????' : _tokenController,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.blue),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _getStrategyId() async {
    if (_tokenController.isEmpty &&
        (_usernameController.text.isEmpty || _passwdController.text.isEmpty)) {
      showDialog(
          context: context,
          builder: (context) {
            return const AlertDialog(
              title: Text('????????????????????????'),
              content: Text('??????????????????????????????'),
            );
          });
      return;
    }
    if (_usernameController.text.isNotEmpty &&
        _passwdController.text.isNotEmpty) {
      final host = _hostController.text;
      String token = 'Bearer ';
      final username = _usernameController.text;
      final passwd = _passwdController.text;
      BaseOptions options = BaseOptions(
        connectTimeout: 30000,
        receiveTimeout: 30000,
        sendTimeout: 30000,
      );
      options.headers = {
        "Accept": "application/json",
      };
      Dio dio = Dio(options);
      String fullUrl = '$host/api/v1/tokens';
      FormData formData = FormData.fromMap({
        'email': username,
        'password': passwd,
      });
      try {
        var response = await dio.post(
          fullUrl,
          data: formData,
        );
        if (response.statusCode == 200 && response.data['status'] == true) {
          token = token + response.data['data']['token'].toString();
          String strategiesUrl = '$host/api/v1/strategies';
          BaseOptions strategiesOptions = BaseOptions(
            connectTimeout: 30000,
            receiveTimeout: 30000,
            sendTimeout: 30000,
          );
          strategiesOptions.headers = {
            "Accept": "application/json",
            "Authorization": token,
          };
          dio = Dio(strategiesOptions);
          response = await dio.get(strategiesUrl);
          if (response.statusCode == 200 && response.data['status'] == true) {
            String strategyId = '';
            List strategies = response.data['data']['strategies'];
            for (int i = 0; i < strategies.length; i++) {
              strategyId =
                  '${strategyId}id : ${strategies[i]['id']}  :  ${strategies[i]['name']}\n';
            }

            showCupertinoAlertDialog(
                barrierDismissible: false,
                context: context,
                title: '????????????Id??????',
                content: strategyId);
          } else {
            showToast('??????????????????Id????????????');
          }
        } else {
          if (response.statusCode == 403) {
            showCupertinoAlertDialog(
                context: context, title: '??????', content: '??????????????????????????????');
            return;
          } else if (response.statusCode == 401) {
            showCupertinoAlertDialog(
                context: context, title: '??????', content: '????????????');
            return;
          } else if (response.statusCode == 500) {
            showCupertinoAlertDialog(
                context: context, title: '??????', content: '???????????????');
            return;
          } else if (response.statusCode == 404) {
            showCupertinoAlertDialog(
                context: context, title: '??????', content: '???????????????');
            return;
          }
          if (response.data['status'] == false) {
            showCupertinoAlertDialog(
                context: context,
                title: '??????',
                content: response.data['message']);
            return;
          }
        }
      } catch (e) {
        FLog.error(
            className: 'HostConfigPage',
            methodName: '_getStrategyId',
            text: formatErrorMessage({}, e.toString()),
            dataLogType: DataLogType.ERRORS.toString());
        showCupertinoAlertDialog(
            context: context, title: '??????', content: e.toString());
      }
    } else {
      try {
        String host = _hostController.text;
        String strategiesUrl = '$host/api/v1/strategies';
        BaseOptions strategiesOptions = BaseOptions(
          connectTimeout: 30000,
          receiveTimeout: 30000,
          sendTimeout: 30000,
        );
        strategiesOptions.headers = {
          "Accept": "application/json",
          "Authorization": _tokenController,
        };
        Dio dio = Dio(strategiesOptions);
        var response = await dio.get(strategiesUrl);

        if (response.statusCode == 200 && response.data['status'] == true) {
          String strategyId = '';
          List strategies = response.data['data']['strategies'];
          for (int i = 0; i < strategies.length; i++) {
            strategyId =
                '${strategyId}id : ${strategies[i]['id']}  :  ${strategies[i]['name']}\n';
          }

          showCupertinoAlertDialog(
              barrierDismissible: false,
              context: context,
              title: '????????????Id??????',
              content: strategyId);
        } else {
          showToast('??????????????????Id????????????');
        }
      } catch (e) {
        FLog.error(
            className: 'HostConfigPage',
            methodName: '_getStrategyId',
            text: formatErrorMessage({}, e.toString()),
            dataLogType: DataLogType.ERRORS.toString());
        showCupertinoAlertDialog(
            context: context, title: '??????', content: e.toString());
      }
    }
  }

  void _getAlbumId() async {
    if (_tokenController.isEmpty &&
        (_usernameController.text.isEmpty || _passwdController.text.isEmpty)) {
      showDialog(
          context: context,
          builder: (context) {
            return const AlertDialog(
              title: Text('????????????????????????'),
              content: Text('??????????????????????????????'),
            );
          });
      return;
    }
    if (_usernameController.text.isNotEmpty &&
        _passwdController.text.isNotEmpty) {
      final host = _hostController.text;
      String token = 'Bearer ';
      final username = _usernameController.text;
      final passwd = _passwdController.text;
      BaseOptions options = BaseOptions(
        connectTimeout: 30000,
        receiveTimeout: 30000,
        sendTimeout: 30000,
      );
      options.headers = {
        "Accept": "application/json",
      };
      Dio dio = Dio(options);
      String fullUrl = '$host/api/v1/tokens';
      FormData formData = FormData.fromMap({
        'email': username,
        'password': passwd,
      });
      try {
        var response = await dio.post(
          fullUrl,
          data: formData,
        );
        if (response.statusCode == 200 && response.data['status'] == true) {
          token = token + response.data['data']['token'].toString();
          String strategiesUrl = '$host/api/v1/albums';
          BaseOptions strategiesOptions = BaseOptions(
            connectTimeout: 30000,
            receiveTimeout: 30000,
            sendTimeout: 30000,
          );
          strategiesOptions.headers = {
            "Accept": "application/json",
            "Authorization": token,
          };
          dio = Dio(strategiesOptions);
          response = await dio.get(strategiesUrl);

          if (response.statusCode == 200 && response.data['status'] == true) {
            String albumID = '';
            List albumIDs = response.data['data']['data'];
            for (int i = 0; i < albumIDs.length; i++) {
              albumID =
                  '${albumID}id : ${albumIDs[i]['id']}  :  ${albumIDs[i]['name']}\n';
            }

            showCupertinoAlertDialog(
                barrierDismissible: false,
                context: context,
                title: '??????Id??????',
                content: albumID);
          } else {
            showToast('????????????Id????????????');
          }
        } else {
          if (response.statusCode == 403) {
            showCupertinoAlertDialog(
                context: context, title: '??????', content: '??????????????????????????????');
            return;
          } else if (response.statusCode == 401) {
            showCupertinoAlertDialog(
                context: context, title: '??????', content: '????????????');
            return;
          } else if (response.statusCode == 500) {
            showCupertinoAlertDialog(
                context: context, title: '??????', content: '???????????????');
            return;
          } else if (response.statusCode == 404) {
            showCupertinoAlertDialog(
                context: context, title: '??????', content: '???????????????');
            return;
          }
          if (response.data['status'] == false) {
            showCupertinoAlertDialog(
                context: context,
                title: '??????',
                content: response.data['message']);
            return;
          }
        }
      } catch (e) {
        FLog.error(
            className: 'HostConfigPage',
            methodName: '_getAlbumId',
            text: formatErrorMessage({}, e.toString()),
            dataLogType: DataLogType.ERRORS.toString());
        showCupertinoAlertDialog(
            context: context, title: '??????', content: e.toString());
      }
    } else {
      try {
        String host = _hostController.text;
        String strategiesUrl = '$host/api/v1/albums';
        BaseOptions strategiesOptions = BaseOptions(
          connectTimeout: 30000,
          receiveTimeout: 30000,
          sendTimeout: 30000,
        );
        strategiesOptions.headers = {
          "Accept": "application/json",
          "Authorization": _tokenController,
        };
        Dio dio = Dio(strategiesOptions);
        var response = await dio.get(strategiesUrl);

        if (response.statusCode == 200 && response.data['status'] == true) {
          String albumID = '';
          List albumIDs = response.data['data']['data'];
          for (int i = 0; i < albumIDs.length; i++) {
            albumID =
                '${albumID}id : ${albumIDs[i]['id']}  :  ${albumIDs[i]['name']}\n';
          }

          showCupertinoAlertDialog(
              barrierDismissible: false,
              context: context,
              title: '??????Id??????',
              content: albumID);
        } else {
          showToast('????????????Id????????????');
        }
      } catch (e) {
        FLog.error(
            className: 'HostConfigPage',
            methodName: '_getAlbumId',
            text: formatErrorMessage({}, e.toString()),
            dataLogType: DataLogType.ERRORS.toString());
        showCupertinoAlertDialog(
            context: context, title: '??????', content: e.toString());
      }
    }
  }

  Future _saveHostConfig() async {
    final host = _hostController.text;
    String token = 'Bearer ';
    if (_tokenController.isEmpty &&
        (_usernameController.text.isEmpty || _passwdController.text.isEmpty)) {
      showToast('????????????????????????');
      return;
    }
    if (_usernameController.text.isNotEmpty &&
        _passwdController.text.isNotEmpty) {
      String albumID = 'None';
      if (_albumIdController.text.isNotEmpty) {
        albumID = _albumIdController.text;
      }
      final username = _usernameController.text;
      final passwd = _passwdController.text;

      final strategyId = _strategyIdController.text;
      BaseOptions options = BaseOptions(
        connectTimeout: 30000,
        receiveTimeout: 30000,
        sendTimeout: 30000,
      );
      options.headers = {
        "Accept": "application/json",
      };
      Dio dio = Dio(options);
      String fullUrl = '$host/api/v1/tokens';
      FormData formData = FormData.fromMap({
        'email': username,
        'password': passwd,
      });
      String sqlResult = '';
      try {
        var response = await dio.post(
          fullUrl,
          data: formData,
        );
        if (response.statusCode == 200 && response.data['status'] == true) {
          token = token + response.data['data']['token'].toString();
          try {
            List sqlconfig = [];
            sqlconfig.add(host);
            sqlconfig.add(strategyId.toString());
            sqlconfig.add(albumID.toString());
            sqlconfig.add(token);
            String defaultUser = await Global.getUser();
            sqlconfig.add(defaultUser);
            var querylankong =
                await MySqlUtils.queryLankong(username: defaultUser);
            var queryuser = await MySqlUtils.queryUser(username: defaultUser);
            if (queryuser == 'Empty') {
              return showCupertinoAlertDialog(
                  context: context, title: '??????', content: '???????????????,????????????');
            } else if (querylankong == 'Empty') {
              sqlResult = await MySqlUtils.insertLankong(content: sqlconfig);
            } else {
              sqlResult = await MySqlUtils.updateLankong(content: sqlconfig);
            }
          } catch (e) {
            FLog.error(
                className: 'LankongConfigPage',
                methodName: '_saveHostConfig',
                text: formatErrorMessage({}, e.toString()),
                dataLogType: DataLogType.ERRORS.toString());
            return showCupertinoAlertDialog(
                context: context, title: '??????', content: e.toString());
          }
          if (sqlResult == "Success") {
            _tokenController = token;
            final hostConfig = HostConfigModel(
                host, token, strategyId.toString(), albumID.toString());
            final hostConfigJson = jsonEncode(hostConfig);
            final hostConfigFile = await localFile;
            hostConfigFile.writeAsString(hostConfigJson);
            setState(() {});
            return showCupertinoAlertDialog(
                context: context,
                barrierDismissible: false,
                title: '????????????',
                content: '??????????????????\n$token,\n???????????????????????????????????????');
          } else {
            return showCupertinoAlertDialog(
                context: context,
                barrierDismissible: false,
                title: '????????????',
                content: '???????????????');
          }
        } else {
          if (response.statusCode == 403) {
            return showCupertinoAlertDialog(
                context: context, title: '??????', content: '??????????????????????????????');
          } else if (response.statusCode == 401) {
            return showCupertinoAlertDialog(
                context: context, title: '??????', content: '????????????');
          } else if (response.statusCode == 500) {
            return showCupertinoAlertDialog(
                context: context, title: '??????', content: '???????????????');
          } else if (response.statusCode == 404) {
            return showCupertinoAlertDialog(
                context: context, title: '??????', content: '???????????????');
          }
          if (response.data['status'] == false) {
            return showCupertinoAlertDialog(
                context: context,
                title: '??????',
                content: response.data['message']);
          }
        }
      } catch (e) {
        FLog.error(
            className: 'HostConfigPage',
            methodName: '_saveHostConfig',
            text: formatErrorMessage({}, e.toString()),
            dataLogType: DataLogType.ERRORS.toString());
        return showCupertinoAlertDialog(
            context: context, title: '??????', content: e.toString());
      }
    } else {
      String albumID = 'None';
      if (_albumIdController.text.isNotEmpty) {
        albumID = _albumIdController.text;
      }
      final strategyId = _strategyIdController.text;
      BaseOptions options = BaseOptions(
        connectTimeout: 30000,
        receiveTimeout: 30000,
        sendTimeout: 30000,
      );
      options.headers = {
        "Accept": "application/json",
        "Authorization": _tokenController,
      };
      Dio dio = Dio(options);
      String sqlResult = '';
      try {
        var response = await dio.get('$host/api/v1/profile');
        if (response.statusCode == 200 && response.data['status'] == true) {
          List sqlconfig = [];
          sqlconfig.add(host);
          sqlconfig.add(strategyId.toString());
          sqlconfig.add(albumID.toString());
          sqlconfig.add(_tokenController);
          String defaultUser = await Global.getUser();
          sqlconfig.add(defaultUser);
          var querylankong =
              await MySqlUtils.queryLankong(username: defaultUser);
          var queryuser = await MySqlUtils.queryUser(username: defaultUser);
          if (queryuser == 'Empty') {
            return showCupertinoAlertDialog(
                context: context, title: '??????', content: '???????????????,????????????');
          } else if (querylankong == 'Empty') {
            sqlResult = await MySqlUtils.insertLankong(content: sqlconfig);
          } else {
            sqlResult = await MySqlUtils.updateLankong(content: sqlconfig);
          }
          if (sqlResult == "Success") {
            final hostConfig = HostConfigModel(host, _tokenController,
                strategyId.toString(), albumID.toString());
            final hostConfigJson = jsonEncode(hostConfig);
            final hostConfigFile = await localFile;
            hostConfigFile.writeAsString(hostConfigJson);

            return showCupertinoAlertDialog(
                context: context,
                barrierDismissible: false,
                title: '????????????',
                content: '??????????????????\n$_tokenController,\n???????????????????????????????????????');
          } else {
            return showCupertinoAlertDialog(
                context: context,
                barrierDismissible: false,
                title: '????????????',
                content: '???????????????');
          }
        } else {
          showToast('????????????');
        }
      } catch (e) {
        FLog.error(
            className: 'HostConfigPage',
            methodName: '_saveHostConfig',
            text: formatErrorMessage({}, e.toString()),
            dataLogType: DataLogType.ERRORS.toString());
        return showCupertinoAlertDialog(
            context: context, title: '??????', content: e.toString());
      }
    }
  }

  checkHostConfig() async {
    try {
      final hostConfigFile = await localFile;
      String configData = await hostConfigFile.readAsString();
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
        "Accept": "application/json",
      };
      String profileUrl = configMap["host"] + "/api/v1/profile";
      Dio dio = Dio(options);
      var response = await dio.get(
        profileUrl,
      );
      if (response.statusCode == 200 && response.data['status'] == true) {
        return showCupertinoAlertDialog(
            context: context,
            title: '??????',
            content:
                '???????????????????????????????????????\nhost:\n${configMap["host"]}\nstrategyId:\n${configMap["strategy_id"]}\nalbumId:\n${configMap["album_id"]}\ntoken:\n${configMap["token"]}');
      } else {
        if (response.statusCode == 403) {
          return showCupertinoAlertDialog(
              context: context, title: '??????', content: '??????????????????????????????');
        } else if (response.statusCode == 401) {
          return showCupertinoAlertDialog(
              context: context, title: '??????', content: '????????????');
        } else if (response.statusCode == 500) {
          return showCupertinoAlertDialog(
              context: context, title: '??????', content: '???????????????');
        } else if (response.statusCode == 404) {
          return showCupertinoAlertDialog(
              context: context, title: '??????', content: '???????????????');
        }
        if (response.data['status'] == false) {
          return showCupertinoAlertDialog(
              context: context, title: '??????', content: response.data['message']);
        }
      }
    } catch (e) {
      FLog.error(
          className: 'ConfigPage',
          methodName: 'checkHostConfig',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      return showCupertinoAlertDialog(
          context: context, title: "????????????!", content: e.toString());
    }
  }

  Future<File> get localFile async {
    final path = await _localPath;
    String defaultUser = await Global.getUser();
    return File('$path/${defaultUser}_host_config.txt');
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<String> readHostConfig() async {
    try {
      final file = await localFile;
      String contents = await file.readAsString();
      return contents;
    } catch (e) {
      FLog.error(
          className: 'HostConfigPage',
          methodName: 'readHostConfig',
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
      var querylankong = await MySqlUtils.queryLankong(username: defaultUser);
      if (querylankong == 'Empty') {
        return Fluttertoast.showToast(
            msg: "????????????????????????",
            toastLength: Toast.LENGTH_SHORT,
            timeInSecForIosWeb: 2,
            fontSize: 16.0);
      }
      if (querylankong == 'Error') {
        return Fluttertoast.showToast(
            msg: "Error",
            toastLength: Toast.LENGTH_SHORT,
            timeInSecForIosWeb: 2,
            fontSize: 16.0);
      }
      if (queryuser['defaultPShost'] == 'lsky.pro') {
        await Global.setPShost('lsky.pro');
        await Global.setShowedPBhost('lskypro');
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
        sqlconfig.add('lsky.pro');
        var updateResult = await MySqlUtils.updateUser(content: sqlconfig);
        if (updateResult == 'Success') {
          await Global.setPShost('lsky.pro');
          await Global.setShowedPBhost('lskypro');
          eventBus.fire(AlbumRefreshEvent(albumKeepAlive: false));
          eventBus.fire(HomePhotoRefreshEvent(homePhotoKeepAlive: false));
          showToast('????????????????????????????????????');
        } else {
          showToast('?????????????????????');
        }
      }
    } catch (e) {
      FLog.error(
          className: 'LskyproPage',
          methodName: '_setdefault',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      showToastWithContext(context, '??????');
    }
  }
}

class HostConfigModel {
  final String host;
  final String token;
  final String strategyId;
  final String albumId;

  HostConfigModel(this.host, this.token, this.strategyId, this.albumId);

  Map<String, dynamic> toJson() => {
        'host': host,
        'token': token,
        'strategy_id': strategyId,
        'album_id': albumId,
      };

  static List keysList = [
    'remarkName',
    'host',
    'token',
    'strategy_id',
    'album_id',
  ];
}
