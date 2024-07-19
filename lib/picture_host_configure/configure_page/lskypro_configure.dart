import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:f_logs/f_logs.dart';
import 'package:fluro/fluro.dart';

import 'package:horopic/router/application.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/pages/loading.dart';
import 'package:horopic/utils/global.dart';
import 'package:horopic/utils/event_bus_utils.dart';
import 'package:horopic/picture_host_manage/manage_api/lskypro_manage_api.dart';

const Map<String, String> statusMsgMap = {
  '403': '管理员关闭了接口功能',
  '401': '授权失败',
  '500': '服务器异常',
  '404': '接口不存在',
};

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
      _hostController.text = configMap['host'] ?? '';
      _strategyIdController.text = configMap['strategy_id'] ?? '';
      _tokenController = configMap['token'] ?? '';
      setControllerText(_albumIdController, configMap['album_id']);
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
        title: titleText('兰空图床参数配置'),
        actions: [
          IconButton(
            onPressed: () async {
              await Application.router
                  .navigateTo(context, '/configureStorePage?psHost=lsky.pro', transition: TransitionType.cupertino);
              await _initConfig();
              setState(() {});
            },
            icon: const Icon(Icons.save_as_outlined, color: Color.fromARGB(255, 255, 255, 255), size: 35),
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
                label: Center(child: Text('域名')),
                hintText: '例如: https://lsky.test.com',
              ),
              textAlign: TextAlign.center,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入域名';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(
                label: Center(child: Text('用户名')),
                hintText: '设定用户名',
              ),
              textAlign: TextAlign.center,
            ),
            TextFormField(
              controller: _passwdController,
              decoration: const InputDecoration(
                label: Center(child: Text('密码')),
                hintText: '输入密码',
              ),
              textAlign: TextAlign.center,
            ),
            TextFormField(
              controller: _strategyIdController,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.zero,
                label: Center(child: Text('储存策略ID')),
                hintText: '输入用户名和密码获取列表,一般是1',
              ),
              textAlign: TextAlign.center,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入储存策略Id';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _albumIdController,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.zero,
                label: Center(child: Text('可选:相册ID')),
                hintText: '仅对付费版和修改了代码的免费版有效',
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
                          loadingText: "配置中...",
                          requestCallBack: _saveHostConfig(),
                        );
                      });
                }
              },
              child: titleText('提交表单', fontsize: null),
            )),
            ListTile(
                title: ElevatedButton(
              onPressed: () {
                _getStrategyId();
              },
              child: titleText('获取储存策略Id列表', fontsize: null),
            )),
            ListTile(
              title: ElevatedButton(
                onPressed: () {
                  _getAlbumId();
                },
                child: titleText('获取相册Id列表', fontsize: null),
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
                        loadingText: "检查中...",
                        requestCallBack: checkHostConfig(),
                      );
                    });
              },
              child: titleText('检查当前配置', fontsize: null),
            )),
            ListTile(
                title: ElevatedButton(
              onPressed: () async {
                await Application.router
                    .navigateTo(context, '/configureStorePage?psHost=lsky.pro', transition: TransitionType.cupertino);
                await _initConfig();
                setState(() {});
              },
              child: titleText('设置备用配置', fontsize: null),
            )),
            ListTile(
                title: ElevatedButton(
              onPressed: () {
                _setdefault();
              },
              child: titleText('设为默认图床', fontsize: null),
            )),
            ListTile(
              title: const Center(
                child: Text(
                  '当前token',
                  style: TextStyle(color: Colors.black),
                ),
              ),
              subtitle: Center(
                child: SelectableText(
                  _tokenController == '' ? '未配置' : _tokenController,
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
    String username = _usernameController.text.trim();
    String passwd = _passwdController.text.trim();
    String host = _hostController.text.trim();
    if (_tokenController.isEmpty && (username.isEmpty || passwd.isEmpty)) {
      showDialog(
          context: context,
          builder: (context) {
            return const AlertDialog(
              title: Text('用户名或密码为空'),
              content: Text('请先输入用户名和密码'),
            );
          });
      return;
    }
    if (username.isNotEmpty && passwd.isNotEmpty) {
      String token = 'Bearer ';
      BaseOptions options = setBaseOptions();
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
          BaseOptions strategiesOptions = setBaseOptions();
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
              strategyId = '${strategyId}id : ${strategies[i]['id']}  :  ${strategies[i]['name']}\n';
            }
            if (context.mounted) {
              showCupertinoAlertDialog(
                  barrierDismissible: false, context: context, title: '储存策略Id列表', content: strategyId);
            }
          } else {
            showToast('获取储存策略Id列表失败');
          }
        } else {
          String statusCode = response.statusCode.toString();
          if (statusCode == '403' || statusCode == '401' || statusCode == '500' || statusCode == '404') {
            if (context.mounted) {
              showCupertinoAlertDialog(context: context, title: '错误', content: statusMsgMap[statusCode]!);
            }
            return;
          }
          if (response.data['status'] == false) {
            if (context.mounted) {
              showCupertinoAlertDialog(context: context, title: '错误', content: response.data['message']);
            }
            return;
          }
        }
      } catch (e) {
        FLog.error(
            className: 'HostConfigPage',
            methodName: '_getStrategyId',
            text: formatErrorMessage({}, e.toString()),
            dataLogType: DataLogType.ERRORS.toString());
        if (context.mounted) {
          showCupertinoAlertDialog(context: context, title: '错误', content: e.toString());
        }
      }
    } else {
      try {
        String strategiesUrl = '$host/api/v1/strategies';
        BaseOptions strategiesOptions = setBaseOptions();
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
            strategyId = '${strategyId}id : ${strategies[i]['id']}  :  ${strategies[i]['name']}\n';
          }

          if (context.mounted) {
            showCupertinoAlertDialog(
                barrierDismissible: false, context: context, title: '储存策略Id列表', content: strategyId);
          }
        } else {
          showToast('获取储存策略Id列表失败');
        }
      } catch (e) {
        FLog.error(
            className: 'HostConfigPage',
            methodName: '_getStrategyId',
            text: formatErrorMessage({}, e.toString()),
            dataLogType: DataLogType.ERRORS.toString());
        if (context.mounted) {
          showCupertinoAlertDialog(context: context, title: '错误', content: e.toString());
        }
      }
    }
  }

  void _getAlbumId() async {
    if (_tokenController.isEmpty && (_usernameController.text.isEmpty || _passwdController.text.isEmpty)) {
      showDialog(
          context: context,
          builder: (context) {
            return const AlertDialog(
              title: Text('用户名或密码为空'),
              content: Text('请先输入用户名和密码'),
            );
          });
      return;
    }
    if (_usernameController.text.isNotEmpty && _passwdController.text.isNotEmpty) {
      String host = _hostController.text.trim();
      String token = 'Bearer ';
      String username = _usernameController.text.trim();
      String passwd = _passwdController.text.trim();
      BaseOptions options = setBaseOptions();
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
          BaseOptions strategiesOptions = setBaseOptions();
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
              albumID = '${albumID}id : ${albumIDs[i]['id']}  :  ${albumIDs[i]['name']}\n';
            }

            if (context.mounted) {
              showCupertinoAlertDialog(barrierDismissible: false, context: context, title: '相册Id列表', content: albumID);
            }
          } else {
            showToast('获取相册Id列表失败');
          }
        } else {
          String statusCode = response.statusCode.toString();
          if (statusCode == '403' || statusCode == '401' || statusCode == '500' || statusCode == '404') {
            if (context.mounted) {
              showCupertinoAlertDialog(context: context, title: '错误', content: statusMsgMap[statusCode]!);
            }
            return;
          }
          if (response.data['status'] == false) {
            if (context.mounted) {
              showCupertinoAlertDialog(context: context, title: '错误', content: response.data['message']);
            }
            return;
          }
        }
      } catch (e) {
        FLog.error(
            className: 'HostConfigPage',
            methodName: '_getAlbumId',
            text: formatErrorMessage({}, e.toString()),
            dataLogType: DataLogType.ERRORS.toString());
        if (context.mounted) {
          showCupertinoAlertDialog(context: context, title: '错误', content: e.toString());
        }
      }
    } else {
      try {
        String host = _hostController.text;
        String strategiesUrl = '$host/api/v1/albums';
        BaseOptions strategiesOptions = setBaseOptions();
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
            albumID = '${albumID}id : ${albumIDs[i]['id']}  :  ${albumIDs[i]['name']}\n';
          }

          if (context.mounted) {
            showCupertinoAlertDialog(barrierDismissible: false, context: context, title: '相册Id列表', content: albumID);
          }
        } else {
          showToast('获取相册Id列表失败');
        }
      } catch (e) {
        FLog.error(
            className: 'HostConfigPage',
            methodName: '_getAlbumId',
            text: formatErrorMessage({}, e.toString()),
            dataLogType: DataLogType.ERRORS.toString());
        if (context.mounted) {
          showCupertinoAlertDialog(context: context, title: '错误', content: e.toString());
        }
      }
    }
  }

  Future _saveHostConfig() async {
    String host = _hostController.text.trim();
    String username = _usernameController.text.trim();
    String passwd = _passwdController.text.trim();
    String albumID = _albumIdController.text.trim();
    if (albumID.isEmpty) {
      albumID = 'None';
    }
    String strategyId = _strategyIdController.text.trim();
    String token = 'Bearer ';
    if (_tokenController.isEmpty && (username.isEmpty || passwd.isEmpty)) {
      showToast('用户名或密码为空');
      return;
    }
    if (username.isNotEmpty && passwd.isNotEmpty) {
      BaseOptions options = setBaseOptions();
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
          _tokenController = token;
          final hostConfig = HostConfigModel(host, token, strategyId.toString(), albumID.toString());
          final hostConfigJson = jsonEncode(hostConfig);
          final hostConfigFile = await LskyproManageAPI.localFile;
          hostConfigFile.writeAsString(hostConfigJson);
          setState(() {});
          if (context.mounted) {
            return showCupertinoAlertDialog(
                context: context, barrierDismissible: false, title: '配置成功', content: '您的密钥为：\n$token,\n请妥善保管，不要泄露给他人');
          }
        } else {
          String statusCode = response.statusCode.toString();
          if (statusCode == '403' || statusCode == '401' || statusCode == '500' || statusCode == '404') {
            if (context.mounted) {
              return showCupertinoAlertDialog(context: context, title: '错误', content: statusMsgMap[statusCode]!);
            }
            return;
          }
          if (response.data['status'] == false) {
            if (context.mounted) {
              return showCupertinoAlertDialog(context: context, title: '错误', content: response.data['message']);
            }
            return;
          }
        }
      } catch (e) {
        FLog.error(
            className: 'HostConfigPage',
            methodName: '_saveHostConfig',
            text: formatErrorMessage({}, e.toString()),
            dataLogType: DataLogType.ERRORS.toString());
        if (context.mounted) {
          return showCupertinoAlertDialog(context: context, title: '错误', content: e.toString());
        }
        return;
      }
    } else {
      BaseOptions options = setBaseOptions();
      options.headers = {
        "Accept": "application/json",
        "Authorization": _tokenController,
      };
      Dio dio = Dio(options);
      try {
        var response = await dio.get('$host/api/v1/profile');
        if (response.statusCode == 200 && response.data['status'] == true) {
          final hostConfig = HostConfigModel(host, _tokenController, strategyId.toString(), albumID.toString());
          final hostConfigJson = jsonEncode(hostConfig);
          final hostConfigFile = await LskyproManageAPI.localFile;
          hostConfigFile.writeAsString(hostConfigJson);
          if (context.mounted) {
            return showCupertinoAlertDialog(
                context: context,
                barrierDismissible: false,
                title: '配置成功',
                content: '您的密钥为：\n$_tokenController,\n请妥善保管，不要泄露给他人');
          }
        } else {
          showToast('配置失败');
        }
      } catch (e) {
        FLog.error(
            className: 'HostConfigPage',
            methodName: '_saveHostConfig',
            text: formatErrorMessage({}, e.toString()),
            dataLogType: DataLogType.ERRORS.toString());
        if (context.mounted) {
          return showCupertinoAlertDialog(context: context, title: '错误', content: e.toString());
        }
      }
    }
  }

  checkHostConfig() async {
    try {
      Map configMap = await LskyproManageAPI.getConfigMap();
      if (configMap.isEmpty) {
        if (context.mounted) {
          return showCupertinoAlertDialog(context: context, title: "检查失败!", content: "请先配置上传参数.");
        }
        return;
      }
      BaseOptions options = setBaseOptions();
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
        if (context.mounted) {
          return showCupertinoAlertDialog(
              context: context,
              title: '通知',
              content:
                  '检测通过，您的配置信息为：\nhost:\n${configMap["host"]}\nstrategyId:\n${configMap["strategy_id"]}\nalbumId:\n${configMap["album_id"]}\ntoken:\n${configMap["token"]}');
        }
      } else {
        String statusCode = response.statusCode.toString();
        if (statusCode == '403' || statusCode == '401' || statusCode == '500' || statusCode == '404') {
          if (context.mounted) {
            return showCupertinoAlertDialog(context: context, title: '错误', content: statusMsgMap[statusCode]!);
          }
          return;
        }
        if (response.data['status'] == false) {
          if (context.mounted) {
            return showCupertinoAlertDialog(context: context, title: '错误', content: response.data['message']);
          }
        }
      }
    } catch (e) {
      FLog.error(
          className: 'ConfigPage',
          methodName: 'checkHostConfig',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      if (context.mounted) {
        return showCupertinoAlertDialog(context: context, title: "检查失败!", content: e.toString());
      }
    }
  }

  _setdefault() async {
    await Global.setPShost('lsky.pro');
    await Global.setShowedPBhost('lskypro');
    eventBus.fire(AlbumRefreshEvent(albumKeepAlive: false));
    eventBus.fire(HomePhotoRefreshEvent(homePhotoKeepAlive: false));
    showToast('已设置兰空图床为默认图床');
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
