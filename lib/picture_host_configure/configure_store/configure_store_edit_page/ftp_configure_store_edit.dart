import 'package:flutter/material.dart';

import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/picture_host_configure/configure_store/configure_store_file.dart';
import 'package:horopic/picture_host_manage/manage_api/ftp_manage_api.dart';
import 'package:horopic/picture_host_configure/configure_store/configure_template.dart';
import 'package:horopic/widgets/configure_widgets.dart';

class FtpConfigureStoreEdit extends StatefulWidget {
  final String storeKey;
  final Map psInfo;
  const FtpConfigureStoreEdit({
    super.key,
    required this.storeKey,
    required this.psInfo,
  });

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
  final _ftpCustomUrlController = TextEditingController(); //可选
  final _ftpWebPathController = TextEditingController(); //可选

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
      'ftpHomeDir',
      'ftpCustomUrl',
      'ftpWebPath',
    ];
    for (String element in keys) {
      if (widget.psInfo[element] != ConfigureTemplate.placeholder) {
        switch (element) {
          case 'remarkName':
            _remarkNameController.text = widget.psInfo[element];
          case 'ftpHost':
            _ftpHostController.text = widget.psInfo[element];
          case 'ftpPort':
            _ftpPortController.text = widget.psInfo[element];
          case 'ftpUser':
            _ftpUserController.text = widget.psInfo[element];
          case 'ftpPassword':
            _ftpPasswordController.text = widget.psInfo[element];
          case 'ftpHomeDir':
            _ftpHomeDirController.text = widget.psInfo[element];
          case 'uploadPath':
            _ftpUploadPathController.text = widget.psInfo[element];
          case 'ftpType':
            _ftpConfigMap['ftpType'] = widget.psInfo[element];
          case 'isAnonymous':
            _ftpConfigMap['isAnonymous'] = widget.psInfo[element].toString();
          case 'ftpCustomUrl':
            _ftpCustomUrlController.text = widget.psInfo[element];
          case 'ftpWebPath':
            _ftpWebPathController.text = widget.psInfo[element];
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
    _ftpCustomUrlController.dispose();
    _ftpWebPathController.dispose();
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
              title: '基本配置',
              children: [
                ConfigureWidgets.buildFormField(
                  controller: _ftpHostController,
                  labelText: 'FTP主机地址',
                  hintText: '请输入FTP主机地址',
                  prefixIcon: Icons.computer,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入FTP主机地址';
                    }
                    return null;
                  },
                ),
                ConfigureWidgets.buildFormField(
                  controller: _ftpPortController,
                  labelText: 'FTP端口',
                  hintText: '如：21或者22',
                  prefixIcon: Icons.settings_ethernet,
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
                ConfigureWidgets.buildFormField(
                  controller: _ftpUserController,
                  labelText: 'FTP用户名',
                  hintText: '勾选匿名时无需填写',
                  prefixIcon: Icons.person,
                ),
                ConfigureWidgets.buildFormField(
                  controller: _ftpPasswordController,
                  labelText: 'FTP密码',
                  hintText: '匿名或无密码时无需填写',
                  prefixIcon: Icons.lock,
                  obscureText: true,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade400),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor.withAlpha(51),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.category,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  const Text('FTP类型'),
                                ],
                              ),
                              DropdownButton<String>(
                                value: _ftpConfigMap['ftpType'],
                                underline: Container(),
                                icon: const Icon(Icons.arrow_drop_down),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _ftpConfigMap['ftpType'] = newValue!;
                                  });
                                },
                                items: <String>['FTP', 'SFTP'].map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade400),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor.withAlpha(51),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.person_outline,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  const Text('匿名登录'),
                                ],
                              ),
                              Switch(
                                value: _ftpConfigMap['isAnonymous'] == 'true',
                                activeColor: Theme.of(context).primaryColor,
                                onChanged: (value) {
                                  setState(() {
                                    _ftpConfigMap['isAnonymous'] = value.toString();
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            ConfigureWidgets.buildSettingCard(
              title: '路径设置',
              children: [
                ConfigureWidgets.buildFormField(
                  controller: _ftpUploadPathController,
                  labelText: 'FTP上传路径',
                  hintText: '例如：test/',
                  prefixIcon: Icons.upload_file,
                ),
                ConfigureWidgets.buildFormField(
                  controller: _ftpHomeDirController,
                  labelText: '管理功能起始路径',
                  hintText: '例如：/home/testuser/',
                  prefixIcon: Icons.folder,
                ),
                ConfigureWidgets.buildFormField(
                  controller: _ftpCustomUrlController,
                  labelText: '自定义URL',
                  hintText: '例如：https://www.test.com',
                  prefixIcon: Icons.language,
                ),
                ConfigureWidgets.buildFormField(
                  controller: _ftpWebPathController,
                  labelText: '拼接用web路径',
                  hintText: '例如：/test/',
                  prefixIcon: Icons.link,
                ),
              ],
            ),
            ConfigureWidgets.buildSettingCard(
              title: '操作',
              children: [
                ConfigureWidgets.buildSettingItem(
                  context: context,
                  title: '导入当前图床配置',
                  icon: Icons.download,
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
      if (configMap['ftpCustomUrl'] != 'None' && configMap['ftpCustomUrl'] != null) {
        _ftpCustomUrlController.text = configMap['ftpCustomUrl'];
      }
      if (configMap['ftpWebPath'] != 'None' && configMap['ftpWebPath'] != null) {
        _ftpWebPathController.text = configMap['ftpWebPath'];
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
      String ftpCustomUrl = _ftpCustomUrlController.text;
      String ftpWebPath = _ftpWebPathController.text;

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

      if (ftpCustomUrl.isEmpty || ftpCustomUrl.trim().isEmpty) {
        ftpCustomUrl = ConfigureTemplate.placeholder;
      }

      if (ftpWebPath.isEmpty || ftpWebPath.trim().isEmpty) {
        ftpWebPath = ConfigureTemplate.placeholder;
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
        'ftpCustomUrl': ftpCustomUrl,
        'ftpWebPath': ftpWebPath,
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
        flogErr(e, {}, 'FtpConfigStoreEditPage', '_saveConfig');
      }
      showToast('保存失败');
      return false;
    }
  }
}
