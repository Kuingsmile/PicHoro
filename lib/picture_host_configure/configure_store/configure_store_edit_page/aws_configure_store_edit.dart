import 'package:flutter/material.dart';

import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/picture_host_configure/configure_store/configure_store_file.dart';
import 'package:horopic/picture_host_manage/manage_api/aws_manage_api.dart';
import 'package:horopic/picture_host_configure/configure_store/configure_template.dart';
import 'package:horopic/widgets/configure_widgets.dart';

class AwsConfigureStoreEdit extends StatefulWidget {
  final String storeKey;
  final Map psInfo;
  const AwsConfigureStoreEdit({
    super.key,
    required this.storeKey,
    required this.psInfo,
  });

  @override
  AwsConfigureStoreEditState createState() => AwsConfigureStoreEditState();
}

class AwsConfigureStoreEditState extends State<AwsConfigureStoreEdit> {
  final _formKey = GlobalKey<FormState>();

  final _remarkNameController = TextEditingController();
  final _accessKeyIDController = TextEditingController();
  final _secretAccessKeyController = TextEditingController();
  final _bucketController = TextEditingController();
  final _endpointController = TextEditingController();
  final _regionController = TextEditingController();
  final _uploadPathController = TextEditingController();
  final _customUrlController = TextEditingController();
  bool isS3PathStyle = false;
  bool isEnableSSL = true;

  @override
  void initState() {
    super.initState();
    _initConfig();
  }

  _initConfig() {
    List keys = [
      'remarkName',
      'accessKeyId',
      'secretAccessKey',
      'bucket',
      'endpoint',
      'region',
      'uploadPath',
      'customUrl',
      'isS3PathStyle',
      'isEnableSSL',
    ];
    for (String element in keys) {
      if (widget.psInfo[element] != ConfigureTemplate.placeholder && widget.psInfo[element] != null) {
        switch (element) {
          case 'remarkName':
            _remarkNameController.text = widget.psInfo[element];
          case 'accessKeyId':
            _accessKeyIDController.text = widget.psInfo[element];
          case 'secretAccessKey':
            _secretAccessKeyController.text = widget.psInfo[element];
          case 'bucket':
            _bucketController.text = widget.psInfo[element];
          case 'endpoint':
            _endpointController.text = widget.psInfo[element];
          case 'region':
            _regionController.text = widget.psInfo[element];
          case 'uploadPath':
            _uploadPathController.text = widget.psInfo[element];
          case 'customUrl':
            _customUrlController.text = widget.psInfo[element];
          case 'isS3PathStyle':
            isS3PathStyle = widget.psInfo[element];
          case 'isEnableSSL':
            isEnableSSL = widget.psInfo[element];
        }
      }
    }
  }

  @override
  void dispose() {
    _remarkNameController.dispose();
    _accessKeyIDController.dispose();
    _secretAccessKeyController.dispose();
    _bucketController.dispose();
    _endpointController.dispose();
    _regionController.dispose();
    _uploadPathController.dispose();
    _customUrlController.dispose();
    super.dispose();
  }

  Widget _buildSwitchItem({
    required String title,
    required IconData icon,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withAlpha(51),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Theme.of(context).primaryColor),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(title)),
          Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
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
              title: '配置信息',
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
                  controller: _accessKeyIDController,
                  labelText: 'Access Key ID',
                  hintText: '设定Access Key ID',
                  prefixIcon: Icons.key,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Access Key ID不能为空';
                    }
                    return null;
                  },
                ),
                ConfigureWidgets.buildFormField(
                  controller: _secretAccessKeyController,
                  labelText: 'Secret Access Key',
                  hintText: '设定Secret Access Key',
                  prefixIcon: Icons.security,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Secret Access Key不能为空';
                    }
                    return null;
                  },
                ),
                ConfigureWidgets.buildFormField(
                  controller: _bucketController,
                  labelText: 'Bucket',
                  hintText: '设定bucket',
                  prefixIcon: Icons.storage,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Bucket不能为空';
                    }
                    return null;
                  },
                ),
                ConfigureWidgets.buildFormField(
                  controller: _endpointController,
                  labelText: 'Endpoint',
                  hintText: '例如s3.us-west-2.amazonaws.com',
                  prefixIcon: Icons.dns,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入endpoint';
                    }
                    if (value.startsWith('http://') || value.startsWith('https://')) {
                      return 'endpoint不包含http://或https://';
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
                  controller: _regionController,
                  labelText: '存储区域',
                  hintText: '例如us-west-2（可选）',
                  prefixIcon: Icons.map,
                ),
                ConfigureWidgets.buildFormField(
                  controller: _uploadPathController,
                  labelText: '存储路径',
                  hintText: '例如test/（可选）',
                  prefixIcon: Icons.folder_outlined,
                ),
                ConfigureWidgets.buildFormField(
                  controller: _customUrlController,
                  labelText: '自定义域名',
                  hintText: '例如https://test.com（可选）',
                  prefixIcon: Icons.link,
                ),
                _buildSwitchItem(
                  title: '是否使用S3路径风格',
                  icon: Icons.style,
                  value: isS3PathStyle,
                  onChanged: (value) {
                    setState(() {
                      isS3PathStyle = value;
                    });
                  },
                ),
                _buildSwitchItem(
                  title: '是否启用SSL连接',
                  icon: Icons.lock_outline,
                  value: isEnableSSL,
                  onChanged: (value) {
                    setState(() {
                      isEnableSSL = value;
                    });
                  },
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
      Map configMap = await AwsManageAPI().getConfigMap();
      _accessKeyIDController.text = configMap['accessKeyId'];
      _secretAccessKeyController.text = configMap['secretAccessKey'];
      _bucketController.text = configMap['bucket'];
      _endpointController.text = configMap['endpoint'];
      if (configMap['region'] != 'None') {
        _regionController.text = configMap['region'];
      }
      if (configMap['uploadPath'] != 'None') {
        _uploadPathController.text = configMap['uploadPath'];
      }
      if (configMap['customUrl'] != 'None') {
        _customUrlController.text = configMap['customUrl'];
      }
      if (configMap['isS3PathStyle'] != null && configMap['isS3PathStyle'] is bool) {
        isS3PathStyle = configMap['isS3PathStyle'];
      }
      if (configMap['isEnableSSL'] != null && configMap['isEnableSSL'] is bool) {
        isEnableSSL = configMap['isEnableSSL'];
      }
      showToast('导入成功');
    } catch (e) {
      showToast('导入失败');
    }
  }

  _saveConfig() async {
    if (_formKey.currentState!.validate()) {
      String remarkName = _remarkNameController.text;
      String accessKeyId = _accessKeyIDController.text;
      String secretAccessKey = _secretAccessKeyController.text;
      String bucket = _bucketController.text;
      String endpoint = _endpointController.text;
      String region = _regionController.text;
      String uploadPath = _uploadPathController.text;
      String customUrl = _customUrlController.text;

      if (remarkName.trim().isEmpty) {
        remarkName = ConfigureTemplate.placeholder;
      }

      if (uploadPath.trim().isEmpty) {
        uploadPath = ConfigureTemplate.placeholder;
      } else {
        if (!uploadPath.endsWith('/')) {
          uploadPath = '$uploadPath/';
        }
        if (uploadPath.startsWith('/')) {
          uploadPath = uploadPath.substring(1);
        }
      }

      if (customUrl.trim().isEmpty) {
        customUrl = ConfigureTemplate.placeholder;
      } else if (!customUrl.startsWith('http') && !customUrl.startsWith('https')) {
        customUrl = 'http://$customUrl';
      }

      if (customUrl.endsWith('/')) {
        customUrl = customUrl.substring(0, customUrl.length - 1);
      }

      if (region.trim().isEmpty) {
        region = ConfigureTemplate.placeholder;
      }

      Map psInfo = {
        'remarkName': remarkName,
        'accessKeyId': accessKeyId,
        'secretAccessKey': secretAccessKey,
        'bucket': bucket,
        'endpoint': endpoint,
        'region': region,
        'uploadPath': uploadPath,
        'customUrl': customUrl,
        'isS3PathStyle': isS3PathStyle,
        'isEnableSSL': isEnableSSL,
      };

      try {
        await ConfigureStoreFile().updateConfigureFileKey(
          'aws',
          widget.storeKey,
          psInfo,
        );
        showToast('保存成功');
        return true;
      } catch (e) {
        flogErr(e, {}, 'AwsConfigStoreEditPage', '_saveConfig');
      }
      showToast('保存失败');
      return false;
    }
  }
}
