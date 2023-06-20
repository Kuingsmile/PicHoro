import 'package:flutter/material.dart';
import 'package:f_logs/f_logs.dart';

import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/picture_host_configure/configure_store/configure_store_file.dart';
import 'package:horopic/picture_host_manage/manage_api/webdav_manage_api.dart';
import 'package:horopic/picture_host_configure/configure_store/configure_template.dart';

class WebdavConfigureStoreEdit extends StatefulWidget {
  final String storeKey;
  final Map psInfo;
  const WebdavConfigureStoreEdit({
    Key? key,
    required this.storeKey,
    required this.psInfo,
  }) : super(key: key);

  @override
  WebdavConfigureStoreEditState createState() => WebdavConfigureStoreEditState();
}

class WebdavConfigureStoreEditState extends State<WebdavConfigureStoreEdit> {
  final _formKey = GlobalKey<FormState>();

  final _remarkNameController = TextEditingController();
  final _hostController = TextEditingController();
  final _webdavusernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _uploadPathController = TextEditingController();
  final _customUrlController = TextEditingController();
  final _webPathController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initConfig();
  }

  _initConfig() {
    List keys = [
      'remarkName',
      'host',
      'webdavusername',
      'password',
      'uploadPath',
      'customUrl',
      'webPath',
    ];
    for (String element in keys) {
      if (widget.psInfo[element] != ConfigureTemplate.placeholder) {
        switch (element) {
          case 'remarkName':
            _remarkNameController.text = widget.psInfo[element];
            break;
          case 'host':
            _hostController.text = widget.psInfo[element];
            break;
          case 'webdavusername':
            _webdavusernameController.text = widget.psInfo[element];
            break;
          case 'password':
            _passwordController.text = widget.psInfo[element];
            break;
          case 'uploadPath':
            _uploadPathController.text = widget.psInfo[element];
            break;
          case 'customUrl':
            _customUrlController.text = widget.psInfo[element];
            break;
          case 'webPath':
            _webPathController.text = widget.psInfo[element];
            break;
        }
      }
    }
  }

  @override
  void dispose() {
    _remarkNameController.dispose();
    _hostController.dispose();
    _webdavusernameController.dispose();
    _passwordController.dispose();
    _uploadPathController.dispose();
    _customUrlController.dispose();
    _webPathController.dispose();
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
                hintText: '例如: https://test.com/dav',
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
              controller: _webdavusernameController,
              decoration: const InputDecoration(
                label: Center(child: Text('用户名')),
                hintText: '设定用户名',
              ),
              textAlign: TextAlign.center,
              validator: (value) {
                if (value == null || value.isEmpty || value.toString().trim().isEmpty) {
                  return '请输入用户名';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                label: Center(child: Text('密码')),
                hintText: '输入密码',
              ),
              textAlign: TextAlign.center,
              validator: (value) {
                if (value == null || value.isEmpty || value.toString().trim().isEmpty) {
                  return '请输入密码';
                }
                return null;
              },
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
              controller: _customUrlController,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.zero,
                label: Center(child: Text('可选：自定义域名')),
                hintText: '例如: https://test.com',
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
      Map configMap = await WebdavManageAPI.getConfigMap();
      _hostController.text = configMap['host'];
      _webdavusernameController.text = configMap['webdavusername'];
      _passwordController.text = configMap['password'];

      if (configMap['uploadPath'] != 'None') {
        _uploadPathController.text = configMap['uploadPath'];
      }

      if (configMap['customUrl'] != 'None' && configMap['customUrl'] != null) {
        _customUrlController.text = configMap['customUrl'];
      }
      if (configMap['webPath'] != 'None' && configMap['webPath'] != null) {
        _webPathController.text = configMap['webPath'];
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
      String webdavusername = _webdavusernameController.text;
      String password = _passwordController.text;
      String uploadPath = _uploadPathController.text;
      String customUrl = _customUrlController.text;
      String webPath = _webPathController.text;

      if (host.endsWith('/')) {
        host = host.substring(0, host.length - 1);
      }
      if (!host.startsWith('http://') && !host.startsWith('https://')) {
        host = 'http://$host';
      }

      if (remarkName.isEmpty || remarkName.trim().isEmpty) {
        remarkName = ConfigureTemplate.placeholder;
      }

      if (uploadPath.isEmpty || uploadPath == '/' || uploadPath.trim() == '') {
        uploadPath = ConfigureTemplate.placeholder;
      }

      if (customUrl.isEmpty || customUrl.trim().isEmpty) {
        customUrl = ConfigureTemplate.placeholder;
      }

      if (webPath.isEmpty || webPath.trim().isEmpty) {
        webPath = ConfigureTemplate.placeholder;
      }

      Map psInfo = {
        'remarkName': remarkName,
        'host': host,
        'webdavusername': webdavusername,
        'password': password,
        'uploadPath': uploadPath,
        'customUrl': customUrl,
        'webPath': webPath,
      };

      try {
        await ConfigureStoreFile().updateConfigureFileKey(
          'webdav',
          widget.storeKey,
          psInfo,
        );
        showToast('保存成功');
        return true;
      } catch (e) {
        FLog.error(
            className: 'WebdavConfigStoreEditPage',
            methodName: '_saveConfig',
            text: formatErrorMessage({}, e.toString()),
            dataLogType: DataLogType.ERRORS.toString());
      }
      showToast('保存失败');
      return false;
    }
  }
}
