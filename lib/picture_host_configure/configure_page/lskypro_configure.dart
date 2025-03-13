import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluro/fluro.dart';

import 'package:horopic/router/application.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/widgets/net_loading_dialog.dart';
import 'package:horopic/utils/global.dart';
import 'package:horopic/utils/event_bus_utils.dart';
import 'package:horopic/picture_host_manage/manage_api/lskypro_manage_api.dart';
import 'package:horopic/widgets/configure_widgets.dart';

const Map<String, String> statusMsgMap = {
  '403': '管理员关闭了接口功能',
  '401': '授权失败',
  '500': '服务器异常',
  '404': '接口不存在',
};

class HostConfig extends StatefulWidget {
  const HostConfig({super.key});

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
      flogErr(e, {}, 'LskyproConfigState', '_initConfig');
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
      appBar: ConfigureWidgets.buildConfigAppBar(title: '兰空图床参数配置', context: context),
      body: Form(
        key: _formKey,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            ConfigureWidgets.buildSettingCard(
              title: '基本配置',
              children: [
                ConfigureWidgets.buildFormField(
                  controller: _hostController,
                  labelText: '域名',
                  hintText: '例如: https://lsky.test.com',
                  prefixIcon: Icons.link,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入域名';
                    }
                    return null;
                  },
                ),
                ConfigureWidgets.buildFormField(
                  controller: _usernameController,
                  labelText: '用户名',
                  hintText: '设定用户名',
                  prefixIcon: Icons.person,
                ),
                ConfigureWidgets.buildFormField(
                  controller: _passwdController,
                  labelText: '密码',
                  hintText: '输入密码',
                  prefixIcon: Icons.lock,
                  obscureText: true,
                ),
                ConfigureWidgets.buildFormField(
                  controller: _strategyIdController,
                  labelText: '储存策略ID',
                  hintText: '输入用户名和密码获取列表,一般是1',
                  prefixIcon: Icons.storage,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入储存策略Id';
                    }
                    return null;
                  },
                ),
                ConfigureWidgets.buildFormField(
                  controller: _albumIdController,
                  labelText: '相册ID (可选)',
                  hintText: '仅对付费版和修改了代码的免费版有效',
                  prefixIcon: Icons.photo_album,
                ),
              ],
            ),
            ConfigureWidgets.buildSettingCard(
              title: '当前Token',
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: SelectableText(
                    _tokenController.isEmpty ? '未配置' : _tokenController,
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            ConfigureWidgets.buildSettingCard(
              title: '操作',
              children: [
                ConfigureWidgets.buildSettingItem(
                  context: context,
                  title: '保存设置',
                  icon: Icons.save,
                  onTap: () {
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
                ),
                ConfigureWidgets.buildDivider(),
                ConfigureWidgets.buildSettingItem(
                  context: context,
                  title: '获取储存策略ID列表',
                  icon: Icons.list_alt,
                  onTap: () {
                    _getStrategyId();
                  },
                ),
                ConfigureWidgets.buildDivider(),
                ConfigureWidgets.buildSettingItem(
                  context: context,
                  title: '获取相册ID列表',
                  icon: Icons.photo_library,
                  onTap: () {
                    _getAlbumId();
                  },
                ),
                ConfigureWidgets.buildDivider(),
                ConfigureWidgets.buildSettingItem(
                  context: context,
                  title: '检查当前配置',
                  icon: Icons.check_circle,
                  onTap: () {
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
                ),
                ConfigureWidgets.buildDivider(),
                ConfigureWidgets.buildSettingItem(
                  context: context,
                  title: '设置备用配置',
                  icon: Icons.settings_backup_restore,
                  onTap: () async {
                    await Application.router.navigateTo(context, '/configureStorePage?psHost=lsky.pro',
                        transition: TransitionType.cupertino);
                    await _initConfig();
                    setState(() {});
                  },
                ),
                ConfigureWidgets.buildDivider(),
                ConfigureWidgets.buildSettingItem(
                  context: context,
                  title: '设为默认图床',
                  icon: Icons.favorite,
                  onTap: () {
                    _setdefault();
                  },
                ),
              ],
            ),
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
        flogErr(e, {}, 'HostConfigPage', '_getStrategyId');
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
        flogErr(e, {}, 'HostConfigPage', '_getStrategyId');
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
        flogErr(e, {}, 'HostConfigPage', '_getAlbumId');
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
        flogErr(e, {}, 'HostConfigPage', '_getAlbumId');
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
        flogErr(e, {}, 'HostConfigPage', '_saveHostConfig');
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
        flogErr(e, {}, 'HostConfigPage', '_saveHostConfig');
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
      flogErr(e, {}, 'ConfigPage', 'checkHostConfig');
      if (context.mounted) {
        return showCupertinoAlertDialog(context: context, title: "检查失败!", content: e.toString());
      }
    }
  }

  _setdefault() {
    Global.setPShost('lsky.pro');
    Global.setShowedPBhost('lskypro');
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
