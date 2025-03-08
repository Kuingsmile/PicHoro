import 'package:flutter/material.dart';
import 'package:f_logs/f_logs.dart';

import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/picture_host_configure/configure_store/configure_store_file.dart';
import 'package:horopic/picture_host_manage/manage_api/tencent_manage_api.dart';
import 'package:horopic/picture_host_configure/configure_store/configure_template.dart';
import 'package:horopic/picture_host_configure/widgets/configure_widgets.dart';

class TencentConfigureStoreEdit extends StatefulWidget {
  final String storeKey;
  final Map psInfo;
  const TencentConfigureStoreEdit({
    super.key,
    required this.storeKey,
    required this.psInfo,
  });

  @override
  TencentConfigureStoreEditState createState() => TencentConfigureStoreEditState();
}

class TencentConfigureStoreEditState extends State<TencentConfigureStoreEdit> {
  final _formKey = GlobalKey<FormState>();

  final _remarkNameController = TextEditingController();
  final _secretIdController = TextEditingController();
  final _secretKeyController = TextEditingController();
  final _bucketController = TextEditingController();
  final _appIdController = TextEditingController();
  final _areaController = TextEditingController();
  final _pathController = TextEditingController();
  final _customUrlController = TextEditingController();
  final _optionsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initConfig();
  }

  _initConfig() {
    List keys = [
      'remarkName',
      'secretId',
      'secretKey',
      'bucket',
      'appId',
      'area',
      'path',
      'customUrl',
      'options',
    ];
    for (String element in keys) {
      if (widget.psInfo[element] != ConfigureTemplate.placeholder) {
        switch (element) {
          case 'remarkName':
            _remarkNameController.text = widget.psInfo[element];
          case 'secretId':
            _secretIdController.text = widget.psInfo[element];
          case 'secretKey':
            _secretKeyController.text = widget.psInfo[element];
          case 'bucket':
            _bucketController.text = widget.psInfo[element];
          case 'appId':
            _appIdController.text = widget.psInfo[element];
          case 'area':
            _areaController.text = widget.psInfo[element];
          case 'path':
            _pathController.text = widget.psInfo[element];
          case 'customUrl':
            _customUrlController.text = widget.psInfo[element];
          case 'options':
            _optionsController.text = widget.psInfo[element];
        }
      }
    }
  }

  @override
  void dispose() {
    _remarkNameController.dispose();
    _secretIdController.dispose();
    _secretKeyController.dispose();
    _bucketController.dispose();
    _appIdController.dispose();
    _areaController.dispose();
    _pathController.dispose();
    _customUrlController.dispose();
    _optionsController.dispose();
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
              title: '认证配置',
              children: [
                ConfigureWidgets.buildFormField(
                  controller: _secretIdController,
                  labelText: 'secretId',
                  hintText: '设定secretId',
                  prefixIcon: Icons.vpn_key,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入secretId';
                    }
                    return null;
                  },
                ),
                ConfigureWidgets.buildFormField(
                  controller: _secretKeyController,
                  labelText: 'secretKey',
                  hintText: '设定secretKey',
                  prefixIcon: Icons.password,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入secretKey';
                    }
                    return null;
                  },
                ),
              ],
            ),
            ConfigureWidgets.buildSettingCard(
              title: '存储配置',
              children: [
                ConfigureWidgets.buildFormField(
                  controller: _bucketController,
                  labelText: 'bucket',
                  hintText: '设定bucket',
                  prefixIcon: Icons.storage,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入bucket';
                    }
                    return null;
                  },
                ),
                ConfigureWidgets.buildFormField(
                  controller: _appIdController,
                  labelText: 'appId',
                  hintText: '例如1234567890',
                  prefixIcon: Icons.app_registration,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入appId';
                    }
                    return null;
                  },
                ),
                ConfigureWidgets.buildFormField(
                  controller: _areaController,
                  labelText: '存储区域',
                  hintText: '例如ap-nanjing',
                  prefixIcon: Icons.map,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入存储区域';
                    }
                    return null;
                  },
                ),
              ],
            ),
            ConfigureWidgets.buildSettingCard(
              title: '路径和自定义选项',
              children: [
                ConfigureWidgets.buildFormField(
                  controller: _pathController,
                  labelText: '存储路径',
                  hintText: '例如test/（可选）',
                  prefixIcon: Icons.folder,
                ),
                ConfigureWidgets.buildFormField(
                  controller: _customUrlController,
                  labelText: '自定义域名',
                  hintText: '例如https://test.com（可选）',
                  prefixIcon: Icons.link,
                ),
                ConfigureWidgets.buildFormField(
                  controller: _optionsController,
                  labelText: '网站后缀',
                  hintText: '例如?imageMogr2（可选）',
                  prefixIcon: Icons.settings,
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
      Map configMap = await TencentManageAPI.getConfigMap();
      _secretIdController.text = configMap['secretId'];
      _secretKeyController.text = configMap['secretKey'];
      _bucketController.text = configMap['bucket'];
      _appIdController.text = configMap['appId'];
      _areaController.text = configMap['area'];
      if (configMap['path'] != 'None') {
        _pathController.text = configMap['path'];
      }
      if (configMap['customUrl'] != 'None') {
        _customUrlController.text = configMap['customUrl'];
      }
      if (configMap['options'] != 'None') {
        _optionsController.text = configMap['options'];
      }
      showToast('导入成功');
    } catch (e) {
      showToast('导入失败');
    }
  }

  _saveConfig() async {
    if (_formKey.currentState!.validate()) {
      String remarkName = _remarkNameController.text;
      String secretId = _secretIdController.text;
      String secretKey = _secretKeyController.text;
      String bucket = _bucketController.text;
      String appId = _appIdController.text;
      String area = _areaController.text;
      String path = _pathController.text;
      String customUrl = _customUrlController.text;
      String options = _optionsController.text;

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

      if (customUrl.isEmpty || customUrl.trim().isEmpty) {
        customUrl = ConfigureTemplate.placeholder;
      } else if (!customUrl.startsWith('http') && !customUrl.startsWith('https')) {
        customUrl = 'http://$customUrl';
      }

      if (customUrl.endsWith('/')) {
        customUrl = customUrl.substring(0, customUrl.length - 1);
      }

      if (options.isNotEmpty) {
        if (!options.startsWith('?')) {
          options = '?$options';
        }
      } else {
        options = ConfigureTemplate.placeholder;
      }

      Map psInfo = {
        'remarkName': remarkName,
        'secretId': secretId,
        'secretKey': secretKey,
        'bucket': bucket,
        'appId': appId,
        'area': area,
        'path': path,
        'customUrl': customUrl,
        'options': options,
      };

      try {
        await ConfigureStoreFile().updateConfigureFileKey(
          'tencent',
          widget.storeKey,
          psInfo,
        );
        showToast('保存成功');
        return true;
      } catch (e) {
        FLog.error(
            className: 'TencentConfigStoreEditPage',
            methodName: '_saveConfig',
            text: formatErrorMessage({}, e.toString()),
            dataLogType: DataLogType.ERRORS.toString());
      }
      showToast('保存失败');
      return false;
    }
  }
}
