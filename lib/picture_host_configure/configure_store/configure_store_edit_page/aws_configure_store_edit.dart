import 'package:flutter/material.dart';
import 'package:f_logs/f_logs.dart';

import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/picture_host_configure/configure_store/configure_store_file.dart';
import 'package:horopic/picture_host_manage/manage_api/aws_manage_api.dart';
import 'package:horopic/picture_host_configure/configure_store/configure_template.dart';

class AwsConfigureStoreEdit extends StatefulWidget {
  final String storeKey;
  final Map psInfo;
  const AwsConfigureStoreEdit({
    Key? key,
    required this.storeKey,
    required this.psInfo,
  }) : super(key: key);

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
              controller: _accessKeyIDController,
              decoration: const InputDecoration(
                label: Center(child: Text('Access Key ID')),
                hintText: '设定Access Key ID',
              ),
              textAlign: TextAlign.center,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Access Key ID不能为空';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _secretAccessKeyController,
              decoration: const InputDecoration(
                label: Center(child: Text('Secret Access Key')),
                hintText: '设定Secret Access Key',
              ),
              textAlign: TextAlign.center,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Secret Access Key不能为空';
                }
                return null;
              },
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
              controller: _endpointController,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.zero,
                label: Center(child: Text('endpoint')),
                hintText: '例如s3.us-west-2.amazonaws.com',
              ),
              textAlign: TextAlign.center,
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
            TextFormField(
              controller: _regionController,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.zero,
                label: Center(child: Text('可选:存储区域')),
                hintText: '例如us-west-2',
              ),
              textAlign: TextAlign.center,
            ),
            TextFormField(
              controller: _uploadPathController,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.zero,
                label: Center(child: Text('可选:存储路径')),
                hintText: '例如test/',
                hintStyle: TextStyle(fontSize: 13),
              ),
              textAlign: TextAlign.center,
            ),
            TextFormField(
              controller: _customUrlController,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.zero,
                label: Center(child: Text('可选:自定义域名')),
                hintText: '例如https://test.com',
                hintStyle: TextStyle(fontSize: 13),
              ),
              textAlign: TextAlign.center,
            ),
            ListTile(
              title: const Text('是否使用S3路径风格'),
              trailing: Switch(
                value: isS3PathStyle,
                onChanged: (value) {
                  setState(() {
                    isS3PathStyle = value;
                  });
                },
              ),
            ),
            ListTile(
              title: const Text('是否启用SSL连接'),
              trailing: Switch(
                value: isEnableSSL,
                onChanged: (value) {
                  setState(() {
                    isEnableSSL = value;
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
      Map configMap = await AwsManageAPI.getConfigMap();
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
        FLog.error(
            className: 'AwsConfigStoreEditPage',
            methodName: '_saveConfig',
            text: formatErrorMessage({}, e.toString()),
            dataLogType: DataLogType.ERRORS.toString());
      }
      showToast('保存失败');
      return false;
    }
  }
}
