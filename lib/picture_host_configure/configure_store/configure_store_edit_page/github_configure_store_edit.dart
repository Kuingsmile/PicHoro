import 'package:flutter/material.dart';
import 'package:f_logs/f_logs.dart';

import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/picture_host_configure/configure_store/configure_store_file.dart';
import 'package:horopic/picture_host_manage/manage_api/github_manage_api.dart';
import 'package:horopic/picture_host_configure/configure_store/configure_template.dart';

class GithubConfigureStoreEdit extends StatefulWidget {
  final String storeKey;
  final Map psInfo;
  const GithubConfigureStoreEdit({
    Key? key,
    required this.storeKey,
    required this.psInfo,
  }) : super(key: key);

  @override
  GithubConfigureStoreEditState createState() =>
      GithubConfigureStoreEditState();
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
            break;
          case 'githubusername':
            _githubusernameController.text = widget.psInfo[element];
            break;
          case 'repo':
            _repoController.text = widget.psInfo[element];
            break;
          case 'token':
            _tokenController.text = widget.psInfo[element];
            break;
          case 'storePath':
            _storePathController.text = widget.psInfo[element];
            break;
          case 'branch':
            _branchController.text = widget.psInfo[element];
            break;
          case 'customDomain':
            _customDomainController.text = widget.psInfo[element];
            break;
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
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: const Text('备用配置设置'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          children: [
            TextFormField(
              controller: _remarkNameController,
              decoration: const InputDecoration(
                label: Center(child: Text('可选：备注名称')),
                hintText: '请输入备注名称',
              ),
              textAlign: TextAlign.center,
            ),
            TextFormField(
              controller: _githubusernameController,
              decoration: const InputDecoration(
                label: Center(child: Text('Github用户名')),
                hintText: '设定用户名',
              ),
              textAlign: TextAlign.center,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入Github用户名';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _repoController,
              decoration: const InputDecoration(
                label: Center(child: Text('仓库名')),
                hintText: '设定仓库名',
              ),
              textAlign: TextAlign.center,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入仓库名';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _tokenController,
              decoration: const InputDecoration(
                label: Center(child: Text('token')),
                hintText: '设定Token',
              ),
              textAlign: TextAlign.center,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入token';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _storePathController,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.zero,
                label: Center(child: Text('可选:存储路径')),
                hintText: '例如: test/',
              ),
              textAlign: TextAlign.center,
            ),
            TextFormField(
              controller: _branchController,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.zero,
                label: Center(child: Text('可选：分支')),
                hintText: '例如: main(默认为main)',
              ),
              textAlign: TextAlign.center,
            ),
            TextFormField(
              controller: _customDomainController,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.zero,
                label: Center(child: Text('可选：自定义域名')),
                hintText: 'eg: https://cdn.jsdelivr.net/gh/用户名/仓库名@分支名',
                hintStyle: TextStyle(fontSize: 13),
              ),
              textAlign: TextAlign.center,
            ),
            ListTile(
                title: ElevatedButton(
              onPressed: () {
                _importConfig();
                setState(() {});
              },
              child: const Text('导入当前图床配置'),
            )),
            ListTile(
                title: ElevatedButton(
              onPressed: () async {
                var result = await _saveConfig();
                if (result == true && mounted) {
                  Navigator.pop(context, true);
                }
              },
              child: const Text('保存配置'),
            )),
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
        if (!customDomain.startsWith('http') &&
            !customDomain.startsWith('https')) {
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
        FLog.error(
            className: 'GithubConfigStoreEditPage',
            methodName: '_saveConfig',
            text: formatErrorMessage({}, e.toString()),
            dataLogType: DataLogType.ERRORS.toString());
      }
      showToast('保存失败');
      return false;
    }
  }
}
