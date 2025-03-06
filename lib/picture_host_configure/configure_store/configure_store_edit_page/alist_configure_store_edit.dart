import 'package:flutter/material.dart';
import 'package:f_logs/f_logs.dart';
import 'package:horopic/picture_host_configure/configure_page/alist_configure.dart';

import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/picture_host_configure/configure_store/configure_store_file.dart';
import 'package:horopic/picture_host_manage/manage_api/alist_manage_api.dart';
import 'package:horopic/picture_host_configure/configure_store/configure_template.dart';

class AlistConfigureStoreEdit extends StatefulWidget {
  final String storeKey;
  final Map psInfo;
  const AlistConfigureStoreEdit({
    super.key,
    required this.storeKey,
    required this.psInfo,
  });

  @override
  AlistConfigureStoreEditState createState() => AlistConfigureStoreEditState();
}

class AlistConfigureStoreEditState extends State<AlistConfigureStoreEdit> {
  final _formKey = GlobalKey<FormState>();

  final _remarkNameController = TextEditingController();
  final _hostController = TextEditingController();
  final _adminTokenController = TextEditingController();
  final _alistusernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _tokenController = TextEditingController();
  final _uploadPathController = TextEditingController();
  final _webPathController = TextEditingController();
  final _customUrlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initConfig();
  }

  _initConfig() {
    for (String element in AlistConfigModel.keysList) {
      if (widget.psInfo[element] != ConfigureTemplate.placeholder && widget.psInfo[element] != null) {
        switch (element) {
          case 'remarkName':
            _remarkNameController.text = widget.psInfo[element];
          case 'host':
            _hostController.text = widget.psInfo[element];
          case 'adminToken':
            _adminTokenController.text = widget.psInfo[element];
          case 'alistusername':
            _alistusernameController.text = widget.psInfo[element];
          case 'password':
            _passwordController.text = widget.psInfo[element];
          case 'token':
            _tokenController.text = widget.psInfo[element];
          case 'uploadPath':
            _uploadPathController.text = widget.psInfo[element];
          case 'webPath':
            _webPathController.text = widget.psInfo[element];
          case 'customUrl':
            _customUrlController.text = widget.psInfo[element];
        }
      }
    }
  }

  @override
  void dispose() {
    _remarkNameController.dispose();
    _hostController.dispose();
    _adminTokenController.dispose();
    _alistusernameController.dispose();
    _passwordController.dispose();
    _tokenController.dispose();
    _uploadPathController.dispose();
    _webPathController.dispose();
    _customUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: titleText('备用配置设置'),
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
              controller: _hostController,
              decoration: const InputDecoration(
                label: Center(child: Text('域名')),
                hintText: '例如: https://alist.test.com',
              ),
              textAlign: TextAlign.center,
              validator: (value) {
                if (value == null || value.isEmpty || value.toString().trim().isEmpty) {
                  return '请输入域名';
                }
                if (!value.startsWith('http://') && !value.startsWith('https://')) {
                  return '以http://或https://开头';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _adminTokenController,
              decoration: const InputDecoration(
                label: Center(child: Text('可选：管理员Token')),
                hintText: '请输入管理员Token',
              ),
              textAlign: TextAlign.center,
            ),
            TextFormField(
              controller: _alistusernameController,
              decoration: const InputDecoration(
                label: Center(child: Text('可选：用户名')),
                hintText: '设定用户名',
              ),
              textAlign: TextAlign.center,
            ),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(
                label: Center(child: Text('可选：密码')),
                hintText: '输入密码',
              ),
              textAlign: TextAlign.center,
            ),
            TextFormField(
              controller: _tokenController,
              decoration: const InputDecoration(
                label: Center(child: Text('可选：Token')),
                hintText: '请输入Token',
              ),
              textAlign: TextAlign.center,
            ),
            TextFormField(
              controller: _uploadPathController,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.zero,
                label: Center(child: Text('可选：储存路径')),
                hintText: '例如: /百度网盘/图床',
              ),
              textAlign: TextAlign.center,
            ),
            TextFormField(
              controller: _webPathController,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.zero,
                label: Center(child: Text('可选：拼接路径')),
                hintText: '例如: /pic',
              ),
              textAlign: TextAlign.center,
            ),
            TextFormField(
              controller: _customUrlController,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.zero,
                label: Center(child: Text('可选：自定义URL')),
                hintText: '例如: https://cdn.test.com',
              ),
              textAlign: TextAlign.center,
            ),
            ListTile(
                title: ElevatedButton(
              onPressed: () {
                _importConfig();
                setState(() {});
              },
              child: titleText('导入当前图床配置', fontsize: null),
            )),
            ListTile(
                title: ElevatedButton(
              onPressed: () async {
                var result = await _saveConfig();
                if (result == true && mounted) {
                  Navigator.pop(context, true);
                }
              },
              child: titleText('保存配置', fontsize: null),
            )),
          ],
        ),
      ),
    );
  }

  _importConfig() async {
    try {
      Map configMap = await AlistManageAPI.getConfigMap();
      _hostController.text = configMap['host'];
      _tokenController.text = configMap['token'];
      if (configMap['adminToken'] != 'None' && configMap['adminToken'] != null) {
        _adminTokenController.text = configMap['adminToken'];
      }
      if (configMap['alistusername'] != 'None') {
        _alistusernameController.text = configMap['alistusername'];
      }
      if (configMap['password'] != 'None') {
        _passwordController.text = configMap['password'];
      }
      if (configMap['uploadPath'] != 'None') {
        _uploadPathController.text = configMap['uploadPath'];
      }
      if (configMap['webPath'] != 'None' && configMap['webPath'] != null) {
        _webPathController.text = configMap['webPath'];
      }
      if (configMap['customUrl'] != 'None' && configMap['customUrl'] != null) {
        _customUrlController.text = configMap['customUrl'];
      }
      showToast('导入成功');
    } catch (e) {
      showToast('导入失败');
    }
  }

  _saveConfig() async {
    if (_formKey.currentState!.validate()) {
      String remarkName = _remarkNameController.text;
      String host = _hostController.text;
      String adminToken = _adminTokenController.text;
      String alistusername = _alistusernameController.text;
      String password = _passwordController.text;
      String token = _tokenController.text;
      String uploadPath = _uploadPathController.text;
      String webPath = _webPathController.text;
      String customUrl = _customUrlController.text;

      if (host.endsWith('/')) {
        host = host.substring(0, host.length - 1);
      }
      if (!host.startsWith('http://') && !host.startsWith('https://')) {
        host = 'https://$host';
      }

      if (remarkName.trim().isEmpty) {
        remarkName = ConfigureTemplate.placeholder;
      }
      if (adminToken.trim().isEmpty) {
        adminToken = ConfigureTemplate.placeholder;
      }
      if (alistusername.trim().isEmpty) {
        alistusername = ConfigureTemplate.placeholder;
      }
      if (password.trim().isEmpty) {
        password = ConfigureTemplate.placeholder;
      }
      if (uploadPath.isEmpty || uploadPath == '/' || uploadPath.trim() == '') {
        uploadPath = ConfigureTemplate.placeholder;
      } else {
        if (!uploadPath.startsWith('/')) {
          uploadPath = '/$uploadPath';
        }
        if (!uploadPath.endsWith('/')) {
          uploadPath = '$uploadPath/';
        }
      }
      if (webPath.trim().isEmpty) {
        webPath = ConfigureTemplate.placeholder;
      } else {
        if (!webPath.endsWith('/')) {
          webPath = '$webPath/';
        }
      }
      if (customUrl.trim().isEmpty) {
        customUrl = ConfigureTemplate.placeholder;
      }

      Map psInfo = {
        'remarkName': remarkName,
        'host': host,
        'adminToken': adminToken,
        'alistusername': alistusername,
        'password': password,
        'token': token,
        'uploadPath': uploadPath,
        'webPath': webPath,
        'customUrl': customUrl,
      };

      try {
        await ConfigureStoreFile().updateConfigureFileKey(
          'alist',
          widget.storeKey,
          psInfo,
        );
        showToast('保存成功');
        return true;
      } catch (e) {
        FLog.error(
            className: 'AlistConfigStoreEditPage',
            methodName: '_saveConfig',
            text: formatErrorMessage({}, e.toString()),
            dataLogType: DataLogType.ERRORS.toString());
      }
      showToast('保存失败');
      return false;
    }
  }
}
