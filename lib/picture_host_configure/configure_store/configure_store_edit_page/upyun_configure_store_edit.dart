import 'package:flutter/material.dart';
import 'package:f_logs/f_logs.dart';

import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/picture_host_configure/configure_store/configure_store_file.dart';
import 'package:horopic/picture_host_manage/manage_api/upyun_manage_api.dart';
import 'package:horopic/picture_host_configure/configure_store/configure_template.dart';

class UpyunConfigureStoreEdit extends StatefulWidget {
  final String storeKey;
  final Map psInfo;
  const UpyunConfigureStoreEdit({
    Key? key,
    required this.storeKey,
    required this.psInfo,
  }) : super(key: key);

  @override
  UpyunConfigureStoreEditState createState() => UpyunConfigureStoreEditState();
}

class UpyunConfigureStoreEditState extends State<UpyunConfigureStoreEdit> {
  final _formKey = GlobalKey<FormState>();

  final _remarkNameController = TextEditingController();
  final _bucketController = TextEditingController();
  final _operatorController = TextEditingController();
  final _passwordController = TextEditingController();
  final _urlController = TextEditingController();
  final _optionsController = TextEditingController();
  final _pathController = TextEditingController();
  final _antiLeechTokenController = TextEditingController();
  final _antiLeechExpirationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initConfig();
  }

  _initConfig() {
    List keys = [
      'remarkName',
      'bucket',
      'operator',
      'password',
      'url',
      'options',
      'path',
      'antiLeechToken',
      'antiLeechExpiration',
    ];
    for (String element in keys) {
      if (widget.psInfo[element] != ConfigureTemplate.placeholder) {
        switch (element) {
          case 'remarkName':
            _remarkNameController.text = widget.psInfo[element];
            break;
          case 'bucket':
            _bucketController.text = widget.psInfo[element];
            break;
          case 'operator':
            _operatorController.text = widget.psInfo[element];
            break;
          case 'password':
            _passwordController.text = widget.psInfo[element];
            break;
          case 'url':
            _urlController.text = widget.psInfo[element];
            break;
          case 'options':
            _optionsController.text = widget.psInfo[element];
            break;
          case 'path':
            _pathController.text = widget.psInfo[element];
            break;
          case 'antiLeechToken':
            _antiLeechTokenController.text = widget.psInfo[element];
            break;
          case 'antiLeechExpiration':
            _antiLeechExpirationController.text = widget.psInfo[element];
            break;
        }
      }
    }
  }

  @override
  void dispose() {
    _remarkNameController.dispose();
    _bucketController.dispose();
    _operatorController.dispose();
    _passwordController.dispose();
    _urlController.dispose();
    _optionsController.dispose();
    _pathController.dispose();
    _antiLeechTokenController.dispose();
    _antiLeechExpirationController.dispose();
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
              controller: _bucketController,
              decoration: const InputDecoration(
                label: Center(child: Text('bucket')),
                hintText: '设定bucket',
              ),
              textAlign: TextAlign.center,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入bucket';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _operatorController,
              decoration: const InputDecoration(
                label: Center(child: Text('操作员')),
                hintText: '设定操作员',
              ),
              textAlign: TextAlign.center,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入操作员';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(
                label: Center(child: Text('密码')),
                hintText: '设定密码',
              ),
              textAlign: TextAlign.center,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入密码';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _urlController,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.zero,
                label: Center(child: Text('加速域名')),
                hintText: '例如http://xxx.test.upcdn.net',
              ),
              textAlign: TextAlign.center,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入加速域名';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _optionsController,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.zero,
                label: Center(child: Text('可选：网站后缀')),
                hintText: '例如!/fwfh/500x500',
                hintStyle: TextStyle(fontSize: 13),
              ),
              textAlign: TextAlign.center,
            ),
            TextFormField(
              controller: _pathController,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.zero,
                label: Center(child: Text('可选: 存储路径')),
                hintText: '例如test/',
                hintStyle: TextStyle(fontSize: 13),
              ),
              textAlign: TextAlign.center,
            ),
            TextFormField(
              controller: _antiLeechTokenController,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.zero,
                label: Center(child: Text('可选: 防盗链Token')),
                hintText: '例如abc',
                hintStyle: TextStyle(fontSize: 13),
              ),
              textAlign: TextAlign.center,
            ),
            TextFormField(
              controller: _antiLeechExpirationController,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.zero,
                label: Center(child: Text('可选: 防盗链过期时间')),
                hintText: '例如3600,单位秒',
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
      Map configMap = await UpyunManageAPI.getConfigMap();
      _bucketController.text = configMap['bucket'] ?? '';
      _operatorController.text = configMap['operator'] ?? '';
      _passwordController.text = configMap['password'] ?? '';
      _urlController.text = configMap['url'] ?? '';
      if (configMap['path'] != 'None' && configMap['path'] != null && configMap['path'] != '/') {
        _pathController.text = configMap['path'];
      }

      if (configMap['options'] != 'None' || configMap['options'].toString().trim() != '') {
        _optionsController.text = configMap['options'];
      }

      if (configMap['antiLeechToken'] != 'None' || configMap['antiLeechToken'].toString().trim() != '') {
        _antiLeechTokenController.text = configMap['antiLeechToken'];
      }

      if (configMap['antiLeechExpiration'] != 'None' || configMap['antiLeechExpiration'].toString().trim() != '') {
        _antiLeechExpirationController.text = configMap['antiLeechExpiration'];
      }
      showToast('导入成功');
    } catch (e) {
      showToast('导入失败');
    }
  }

  _saveConfig() async {
    if (_formKey.currentState!.validate()) {
      String remarkName = _remarkNameController.text;
      String bucket = _bucketController.text;
      String operator = _operatorController.text;
      String password = _passwordController.text;
      String url = _urlController.text;
      String options = _optionsController.text;
      String path = _pathController.text;
      String antiLeechToken = _antiLeechTokenController.text;
      String antiLeechExpiration = _antiLeechExpirationController.text;

      if (remarkName.isEmpty || remarkName.trim().isEmpty) {
        remarkName = ConfigureTemplate.placeholder;
      }

      if (path.isEmpty || path.trim().isEmpty) {
        path = ConfigureTemplate.placeholder;
      } else {
        if (!path.endsWith('/')) {
          path = '$path/';
        }
        if (path.startsWith('/')) {
          path = path.substring(1);
        }
      }

      if (!url.startsWith('http') && !url.startsWith('https')) {
        url = 'http://$url';
      }
      if (url.endsWith('/')) {
        url = url.substring(0, url.length - 1);
      }

      Map psInfo = {
        'remarkName': remarkName,
        'bucket': bucket,
        'operator': operator,
        'password': password,
        'url': url,
        'options': options,
        'path': path,
        'antiLeechToken': antiLeechToken,
        'antiLeechExpiration': antiLeechExpiration,
      };

      try {
        await ConfigureStoreFile().updateConfigureFileKey(
          'upyun',
          widget.storeKey,
          psInfo,
        );
        showToast('保存成功');
        return true;
      } catch (e) {
        FLog.error(
            className: 'UpyunConfigStoreEditPage',
            methodName: '_saveConfig',
            text: formatErrorMessage({}, e.toString()),
            dataLogType: DataLogType.ERRORS.toString());
      }
      showToast('保存失败');
      return false;
    }
  }
}
