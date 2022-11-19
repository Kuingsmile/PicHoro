import 'package:flutter/material.dart';
import 'package:f_logs/f_logs.dart';

import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/picture_host_configure/configure_store/configure_store_file.dart';
import 'package:horopic/picture_host_manage/manage_api/ftp_manage_api.dart';
import 'package:horopic/picture_host_configure/configure_store/configure_template.dart';

class FtpConfigureStoreEdit extends StatefulWidget {
  final String storeKey;
  final Map psInfo;
  const FtpConfigureStoreEdit({
    Key? key,
    required this.storeKey,
    required this.psInfo,
  }) : super(key: key);

  @override
  FtpConfigureStoreEditState createState() => FtpConfigureStoreEditState();
}

class FtpConfigureStoreEditState extends State<FtpConfigureStoreEdit> {
  final _formKey = GlobalKey<FormState>();

  final _remarkNameController = TextEditingController();
  final _ftpHostController = TextEditingController();
  final _ftpPortController = TextEditingController();
  final _ftpUserController = TextEditingController(); //匿名登录时不需要
  final _ftpPasswordController = TextEditingController(); //匿名登录时不需要
  final _ftpHomeDirController = TextEditingController();
  final _ftpUploadPathController = TextEditingController(); //可选

  Map _ftpConfigMap = {
    'ftpType': 'SFTP',
    'isAnonymous': 'false',
  };

  resetFtpConfigMap() {
    setState(() {
      _ftpConfigMap = {
        'ftpType': 'SFTP',
        'isAnonymous': 'false',
      };
    });
  }

  @override
  void initState() {
    super.initState();
    _initConfig();
  }

  _initConfig() {
    resetFtpConfigMap();
    List keys = [
      'remarkName',
      'ftpHost',
      'ftpPort',
      'ftpUser',
      'ftpPassword',
      'ftpType',
      'isAnonymous',
      'uploadPath',
      'ftpHomeDir'
    ];
    for (String element in keys) {
      if (widget.psInfo[element] != ConfigureTemplate.placeholder) {
        switch (element) {
          case 'remarkName':
            _remarkNameController.text = widget.psInfo[element];
            break;
          case 'ftpHost':
            _ftpHostController.text = widget.psInfo[element];
            break;
          case 'ftpPort':
            _ftpPortController.text = widget.psInfo[element];
            break;
          case 'ftpUser':
            _ftpUserController.text = widget.psInfo[element];
            break;
          case 'ftpPassword':
            _ftpPasswordController.text = widget.psInfo[element];
            break;
          case 'ftpHomeDir':
            _ftpHomeDirController.text = widget.psInfo[element];
            break;
          case 'uploadPath':
            _ftpUploadPathController.text = widget.psInfo[element];
            break;
          case 'ftpType':
            _ftpConfigMap['ftpType'] = widget.psInfo[element];
            break;
          case 'isAnonymous':
            _ftpConfigMap['isAnonymous'] = widget.psInfo[element].toString();
            break;
        }
      }
    }
  }

  @override
  void dispose() {
    _remarkNameController.dispose();
    _ftpHostController.dispose();
    _ftpPortController.dispose();
    _ftpUserController.dispose();
    _ftpPasswordController.dispose();
    _ftpHomeDirController.dispose();
    _ftpUploadPathController.dispose();
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
              controller: _ftpHostController,
              decoration: const InputDecoration(
                label: Center(child: Text('FTP主机地址')),
                hintText: '请输入FTP主机地址',
              ),
              textAlign: TextAlign.center,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入FTP主机地址';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _ftpPortController,
              decoration: const InputDecoration(
                label: Center(child: Text('FTP端口')),
                hintText: '如：21或者22',
              ),
              textAlign: TextAlign.center,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入FTP端口';
                }
                RegExp pattern = RegExp(r'^[0-9]{1,5}$');
                if (!pattern.hasMatch(value)) {
                  return '请输入正确的FTP端口';
                }
                if (int.parse(value) > 65535) {
                  return '请输入正确的FTP端口';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _ftpUserController,
              decoration: const InputDecoration(
                label: Center(child: Text('可选：FTP用户名')),
                hintText: '勾选匿名时无需填写',
              ),
              textAlign: TextAlign.center,
            ),
            TextFormField(
              controller: _ftpPasswordController,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.zero,
                label: Center(child: Text('可选: FTP密码')),
                hintText: '匿名或无密码时无需填写',
              ),
              textAlign: TextAlign.center,
            ),
            TextFormField(
              controller: _ftpUploadPathController,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.zero,
                label: Center(child: Text('可选: FTP上传路径')),
                hintText: '例如：test/',
              ),
              textAlign: TextAlign.center,
            ),
            TextFormField(
              controller: _ftpHomeDirController,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.zero,
                label: Center(child: Text('可选: 管理功能起始路径')),
                hintText: '例如：/home/testuser/',
              ),
              textAlign: TextAlign.center,
            ),
            ListTile(
              title: const Text('FTP类型'),
              trailing: DropdownButton<String>(
                value: _ftpConfigMap['ftpType'],
                onChanged: (String? newValue) {
                  setState(() {
                    _ftpConfigMap['ftpType'] = newValue!;
                  });
                },
                items: <String>['FTP', 'SFTP']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
            ListTile(
              title: const Text('匿名登录'),
              trailing: Switch(
                value: _ftpConfigMap['isAnonymous'] == 'true',
                onChanged: (value) {
                  setState(() {
                    _ftpConfigMap['isAnonymous'] = value.toString();
                  });
                },
              ),
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
      Map configMap = await FTPManageAPI.getConfigMap();
      _ftpHostController.text = configMap['ftpHost'];
      _ftpPortController.text = configMap['ftpPort'];
      if (configMap['ftpUser'] != 'None') {
        _ftpUserController.text = configMap['ftpUser'];
      }
      if (configMap['ftpPassword'] != 'None') {
        _ftpPasswordController.text = configMap['ftpPassword'];
      }
      if (configMap['uploadPath'] != 'None') {
        _ftpUploadPathController.text = configMap['uploadPath'];
      }
      if (configMap['ftpHomeDir'] != 'None') {
        _ftpHomeDirController.text = configMap['ftpHomeDir'];
      }
      _ftpConfigMap['ftpType'] = configMap['ftpType'];
      _ftpConfigMap['isAnonymous'] = configMap['isAnonymous'].toString();

      showToast('导入成功');
    } catch (e) {
      showToast('导入失败');
    }
  }

  _saveConfig() async {
    if (_formKey.currentState!.validate()) {
      String remarkName = _remarkNameController.text;
      String ftpHost = _ftpHostController.text;
      String ftpPort = _ftpPortController.text;
      String ftpUser = _ftpUserController.text;
      String ftpPassword = _ftpPasswordController.text;
      String ftpUploadPath = _ftpUploadPathController.text;
      String ftpHomeDir = _ftpHomeDirController.text;
      String ftpType = _ftpConfigMap['ftpType'];
      String isAnonymous = _ftpConfigMap['isAnonymous'].toString();

      if (remarkName.isEmpty || remarkName.trim().isEmpty) {
        remarkName = ConfigureTemplate.placeholder;
      }

      if (ftpUser.isEmpty || ftpUser.trim().isEmpty) {
        ftpUser = ConfigureTemplate.placeholder;
      }

      if (ftpPassword.isEmpty || ftpPassword.trim().isEmpty) {
        ftpPassword = ConfigureTemplate.placeholder;
      }

      if (ftpUploadPath.isEmpty || ftpUploadPath.trim().isEmpty) {
        ftpUploadPath = ConfigureTemplate.placeholder;
      } else {
        if (!ftpUploadPath.endsWith('/')) {
          ftpUploadPath = '$ftpUploadPath/';
        }
      }

      if (ftpHomeDir.isEmpty || ftpHomeDir == "" || ftpHomeDir == '/') {
        ftpHomeDir = ConfigureTemplate.placeholder;
      } else {
        if (!ftpHomeDir.endsWith('/')) {
          ftpHomeDir = '$ftpHomeDir/';
        }
      }

      Map psInfo = {
        'remarkName': remarkName,
        'ftpHost': ftpHost,
        'ftpPort': ftpPort,
        'ftpUser': ftpUser,
        'ftpPassword': ftpPassword,
        'ftpType': ftpType,
        'isAnonymous': isAnonymous,
        'uploadPath': ftpUploadPath,
        'ftpHomeDir': ftpHomeDir,
      };

      try {
        await ConfigureStoreFile().updateConfigureFileKey(
          'ftp',
          widget.storeKey,
          psInfo,
        );
        showToast('保存成功');
        return true;
      } catch (e) {
        FLog.error(
            className: 'FtpConfigStoreEditPage',
            methodName: '_saveConfig',
            text: formatErrorMessage({}, e.toString()),
            dataLogType: DataLogType.ERRORS.toString());
      }
      showToast('保存失败');
      return false;
    }
  }
}
