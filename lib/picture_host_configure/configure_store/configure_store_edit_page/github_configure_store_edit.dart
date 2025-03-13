import 'package:flutter/material.dart';

import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/picture_host_configure/configure_store/configure_store_file.dart';
import 'package:horopic/picture_host_manage/manage_api/github_manage_api.dart';
import 'package:horopic/picture_host_configure/configure_store/configure_template.dart';
import 'package:horopic/widgets/configure_widgets.dart';

class GithubConfigureStoreEdit extends StatefulWidget {
  final String storeKey;
  final Map psInfo;
  const GithubConfigureStoreEdit({
    super.key,
    required this.storeKey,
    required this.psInfo,
  });

  @override
  GithubConfigureStoreEditState createState() => GithubConfigureStoreEditState();
}

class GithubConfigureStoreEditState extends State<GithubConfigureStoreEdit> {
  final _formKey = GlobalKey<FormState>();

  final _remarkNameController = TextEditingController();

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

  _initConfig() {
    List keys = [
      'remarkName',
      'githubusername',
      'repo',
      'token',
      'storePath',
      'branch',
      'customDomain',
    ];
    for (String element in keys) {
      if (widget.psInfo[element] != ConfigureTemplate.placeholder) {
        switch (element) {
          case 'remarkName':
            _remarkNameController.text = widget.psInfo[element];
          case 'githubusername':
            _githubusernameController.text = widget.psInfo[element];
          case 'repo':
            _repoController.text = widget.psInfo[element];
          case 'token':
            _tokenController.text = widget.psInfo[element];
          case 'storePath':
            _storePathController.text = widget.psInfo[element];
          case 'branch':
            _branchController.text = widget.psInfo[element];
          case 'customDomain':
            _customDomainController.text = widget.psInfo[element];
        }
      }
    }
  }

  @override
  void dispose() {
    _remarkNameController.dispose();
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
      appBar: ConfigureWidgets.buildConfigAppBar(title: '备用配置设置', context: context),
      body: Form(
        key: _formKey,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            ConfigureWidgets.buildSettingCard(
              title: '备注信息',
              children: [
                ConfigureWidgets.buildFormField(
                  controller: _remarkNameController,
                  labelText: '备注名称',
                  hintText: '请输入备注名称（可选）',
                  prefixIcon: Icons.bookmark,
                ),
              ],
            ),
            ConfigureWidgets.buildSettingCard(
              title: 'GitHub 基本配置',
              children: [
                ConfigureWidgets.buildFormField(
                  controller: _githubusernameController,
                  labelText: 'GitHub 用户名',
                  hintText: '设定用户名',
                  prefixIcon: Icons.person,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入GitHub用户名';
                    }
                    return null;
                  },
                ),
                ConfigureWidgets.buildFormField(
                  controller: _repoController,
                  labelText: '仓库名',
                  hintText: '设定仓库名',
                  prefixIcon: Icons.folder_shared,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
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
                    if (value == null || value.isEmpty) {
                      return '请输入token';
                    }
                    return null;
                  },
                ),
              ],
            ),
            ConfigureWidgets.buildSettingCard(
              title: '路径与域名设置',
              children: [
                ConfigureWidgets.buildFormField(
                  controller: _storePathController,
                  labelText: '存储路径',
                  hintText: '例如: test/（可选）',
                  prefixIcon: Icons.folder,
                ),
                ConfigureWidgets.buildFormField(
                  controller: _branchController,
                  labelText: '分支',
                  hintText: '例如: main（默认为main，可选）',
                  prefixIcon: Icons.call_split,
                ),
                ConfigureWidgets.buildFormField(
                  controller: _customDomainController,
                  labelText: '自定义域名',
                  hintText: '例如: https://cdn.jsdelivr.net/gh/用户名/仓库名@分支名（可选）',
                  prefixIcon: Icons.language,
                ),
              ],
            ),
            ConfigureWidgets.buildSettingCard(
              title: '操作',
              children: [
                ConfigureWidgets.buildSettingItem(
                  context: context,
                  title: '导入当前图床配置',
                  icon: Icons.cloud_download,
                  onTap: () {
                    _importConfig();
                    setState(() {});
                  },
                ),
                ConfigureWidgets.buildDivider(),
                ConfigureWidgets.buildSettingItem(
                  context: context,
                  title: '保存配置',
                  icon: Icons.save,
                  onTap: () async {
                    var result = await _saveConfig();
                    if (result == true && mounted) {
                      Navigator.pop(context, true);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _importConfig() async {
    try {
      Map configMap = await GithubManageAPI.getConfigMap();
      _githubusernameController.text = configMap['githubusername'];
      _repoController.text = configMap['repo'];
      _tokenController.text = configMap['token'];
      _branchController.text = configMap['branch'];
      if (configMap['storePath'] != 'None') {
        _storePathController.text = configMap['storePath'];
      }

      if (configMap['customDomain'] != 'None') {
        _customDomainController.text = configMap['customDomain'];
      }
      showToast('导入成功');
    } catch (e) {
      showToast('导入失败');
    }
  }

  _saveConfig() async {
    if (_formKey.currentState!.validate()) {
      String tokenPrefix = 'Bearer ';
      String remarkName = _remarkNameController.text;
      String githubusername = _githubusernameController.text;
      String repo = _repoController.text;
      String token = _tokenController.text;
      String storePath = _storePathController.text;
      String branch = _branchController.text;
      String customDomain = _customDomainController.text;

      if (remarkName.isEmpty || remarkName.trim().isEmpty) {
        remarkName = ConfigureTemplate.placeholder;
      }

      if (!token.startsWith(tokenPrefix)) {
        token = tokenPrefix + token;
      }

      if (storePath.isEmpty || storePath.trim().isEmpty) {
        storePath = ConfigureTemplate.placeholder;
      } else {
        if (!storePath.endsWith('/')) {
          storePath = '$storePath/';
        }
      }

      if (branch.isEmpty || branch.trim().isEmpty) {
        branch = 'main';
      }

      if (customDomain.isEmpty || customDomain.trim().isEmpty) {
        customDomain = ConfigureTemplate.placeholder;
      } else {
        if (!customDomain.startsWith('http') && !customDomain.startsWith('https')) {
          customDomain = 'http://$customDomain';
        }
        if (customDomain.endsWith('/')) {
          customDomain = customDomain.substring(0, customDomain.length - 1);
        }
      }

      Map psInfo = {
        'remarkName': remarkName,
        'githubusername': githubusername,
        'repo': repo,
        'token': token,
        'storePath': storePath,
        'branch': branch,
        'customDomain': customDomain,
      };

      try {
        await ConfigureStoreFile().updateConfigureFileKey(
          'github',
          widget.storeKey,
          psInfo,
        );
        showToast('保存成功');
        return true;
      } catch (e) {
        flogErr(e, {}, 'GithubConfigStoreEditPage', '_saveConfig');
      }
      showToast('保存失败');
      return false;
    }
  }
}
