import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:f_logs/f_logs.dart';
import 'package:fluro/fluro.dart';

import 'package:horopic/router/application.dart';
import 'package:horopic/pages/loading.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/utils/global.dart';
import 'package:horopic/picture_host_manage/manage_api/github_manage_api.dart';
import 'package:horopic/utils/event_bus_utils.dart';
import 'package:horopic/picture_host_configure/widgets/configure_widgets.dart';

class GithubConfig extends StatefulWidget {
  const GithubConfig({super.key});

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
      _githubusernameController.text = configMap['githubusername'] ?? '';
      _repoController.text = configMap['repo'] ?? '';
      _tokenController.text = configMap['token'] ?? '';
      _branchController.text = configMap['branch'] ?? '';
      setControllerText(_storePathController, configMap['storePath']);
      setControllerText(_customDomainController, configMap['customDomain']);
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
      appBar: ConfigureWidgets.buildConfigAppBar(title: 'Github参数配置', context: context),
      body: Form(
        key: _formKey,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            ConfigureWidgets.buildSettingCard(
              title: '基本配置',
              children: [
                ConfigureWidgets.buildFormField(
                  controller: _githubusernameController,
                  labelText: 'Github用户名',
                  hintText: '设定用户名',
                  prefixIcon: Icons.person,
                  validator: (value) {
                    if (value == null || value.isEmpty || value.toString().trim().isEmpty) {
                      return '请输入用户名';
                    }
                    return null;
                  },
                ),
                ConfigureWidgets.buildFormField(
                  controller: _repoController,
                  labelText: '仓库名',
                  hintText: '设定仓库名',
                  prefixIcon: Icons.folder,
                  validator: (value) {
                    if (value == null || value.isEmpty || value.toString().trim().isEmpty) {
                      return '请输入仓库名';
                    }
                    return null;
                  },
                ),
                ConfigureWidgets.buildFormField(
                  controller: _tokenController,
                  labelText: 'Token',
                  hintText: '设定Token',
                  prefixIcon: Icons.vpn_key,
                  validator: (value) {
                    if (value == null || value.isEmpty || value.toString().trim().isEmpty) {
                      return '请输入Token';
                    }
                    return null;
                  },
                ),
              ],
            ),
            ConfigureWidgets.buildSettingCard(
              title: '高级配置',
              children: [
                ConfigureWidgets.buildFormField(
                  controller: _storePathController,
                  labelText: '存储路径',
                  hintText: '例如: test/',
                  prefixIcon: Icons.folder_open,
                ),
                ConfigureWidgets.buildFormField(
                  controller: _branchController,
                  labelText: '分支',
                  hintText: '默认为main',
                  prefixIcon: Icons.hub,
                ),
                ConfigureWidgets.buildFormField(
                  controller: _customDomainController,
                  labelText: '自定义域名',
                  hintText: 'eg: https://cdn.jsdelivr.net/gh/用户名/仓库名@分支名',
                  prefixIcon: Icons.link,
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
                              requestCallBack: _saveGithubConfig(),
                            );
                          });
                    }
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
                            requestCallBack: checkGithubConfig(),
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
                    await Application.router
                        .navigateTo(context, '/configureStorePage?psHost=github', transition: TransitionType.cupertino);
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

  Future _saveGithubConfig() async {
    try {
      String token = _tokenController.text.trim();
      String githubusername = _githubusernameController.text.trim();
      String repo = _repoController.text.trim();
      String storePath = _storePathController.text.trim();
      String branch = _branchController.text.trim();
      String customDomain = _customDomainController.text.trim();

      if (storePath.isEmpty || _storePathController.text == '/') {
        storePath = 'None';
      } else if (!storePath.endsWith('/')) {
        storePath = '$storePath/';
      }

      if (branch.isEmpty) {
        branch = 'main';
      }
      if (customDomain.isEmpty) {
        customDomain = 'None';
      } else {
        if (!customDomain.startsWith('http') && !customDomain.startsWith('https')) {
          customDomain = 'http://$customDomain';
        }
        if (customDomain.endsWith('/')) {
          customDomain = customDomain.substring(0, customDomain.length - 1);
        }
      }

      if (!token.startsWith('Bearer ')) {
        token = 'Bearer $token';
      }

      final githubConfig = GithubConfigModel(githubusername, repo, token, storePath, branch, customDomain);
      final githubConfigJson = jsonEncode(githubConfig);
      final githubConfigFile = await GithubManageAPI.localFile;
      await githubConfigFile.writeAsString(githubConfigJson);
      showToast('保存成功');
    } catch (e) {
      FLog.error(
          className: 'GithubConfigState',
          methodName: '_saveGithubConfig',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      if (context.mounted) {
        return showCupertinoAlertDialog(context: context, title: '错误', content: e.toString());
      }
    }
  }

  checkGithubConfig() async {
    try {
      Map configMap = await GithubManageAPI.getConfigMap();

      if (configMap.isEmpty) {
        if (context.mounted) {
          return showCupertinoAlertDialog(context: context, title: "检查失败!", content: "请先配置上传参数.");
        }
        return;
      }

      BaseOptions options = setBaseOptions();
      options.headers = {
        "Authorization": configMap["token"],
        "Accept": 'application/vnd.github+json',
      };
      String validateURL = "https://api.github.com/user";
      Map<String, dynamic> queryData = {};
      Dio dio = Dio(options);
      var response = await dio.get(validateURL, queryParameters: queryData);

      if (response.statusCode == 200 && response.data.toString().contains("email")) {
        if (context.mounted) {
          return showCupertinoAlertDialog(
            context: context,
            title: '通知',
            content:
                '检测通过，您的配置信息为:\n用户名:\n${configMap["githubusername"]}\n仓库名:\n${configMap["repo"]}\n存储路径:\n${configMap["storePath"]}\n分支:\n${configMap["branch"]}\n自定义域名:\n${configMap["customDomain"]}',
          );
        }
      } else {
        if (context.mounted) {
          return showCupertinoAlertDialog(context: context, title: '错误', content: '检查失败，请检查配置信息');
        }
      }
    } catch (e) {
      FLog.error(
          className: 'GithubConfigState',
          methodName: 'checkGithubConfig',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      if (context.mounted) {
        return showCupertinoAlertDialog(context: context, title: "检查失败!", content: e.toString());
      }
    }
  }

  _setdefault() {
    Global.setPShost('github');
    Global.setShowedPBhost('github');
    eventBus.fire(AlbumRefreshEvent(albumKeepAlive: false));
    eventBus.fire(HomePhotoRefreshEvent(homePhotoKeepAlive: false));
    showToast('已设置Github为默认图床');
  }
}

class GithubConfigModel {
  final String githubusername;
  final String repo;
  final String token;
  final String storePath;
  final String branch;
  final String customDomain;

  GithubConfigModel(this.githubusername, this.repo, this.token, this.storePath, this.branch, this.customDomain);

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
