import 'package:flutter/material.dart';
import 'package:f_logs/f_logs.dart';

import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/picture_host_configure/configure_store/configure_store_file.dart';
import 'package:horopic/picture_host_manage/manage_api/qiniu_manage_api.dart';
import 'package:horopic/picture_host_configure/configure_store/configure_template.dart';

class QiniuConfigureStoreEdit extends StatefulWidget {
  final String storeKey;
  final Map psInfo;
  const QiniuConfigureStoreEdit({
    super.key,
    required this.storeKey,
    required this.psInfo,
  });

  @override
  QiniuConfigureStoreEditState createState() => QiniuConfigureStoreEditState();
}

class QiniuConfigureStoreEditState extends State<QiniuConfigureStoreEdit> {
  final _formKey = GlobalKey<FormState>();

  final _remarkNameController = TextEditingController();
  final _accessKeyController = TextEditingController();
  final _secretKeyController = TextEditingController();
  final _bucketController = TextEditingController();
  final _urlController = TextEditingController();
  final _areaController = TextEditingController();
  final _optionsController = TextEditingController();
  final _pathController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initConfig();
  }

  _initConfig() {
    List keys = [
      'remarkName',
      'accessKey',
      'secretKey',
      'bucket',
      'url',
      'area',
      'options',
      'path',
    ];
    for (String element in keys) {
      if (widget.psInfo[element] != ConfigureTemplate.placeholder) {
        switch (element) {
          case 'remarkName':
            _remarkNameController.text = widget.psInfo[element];
            break;
          case 'accessKey':
            _accessKeyController.text = widget.psInfo[element];
            break;
          case 'secretKey':
            _secretKeyController.text = widget.psInfo[element];
            break;
          case 'bucket':
            _bucketController.text = widget.psInfo[element];
            break;
          case 'url':
            _urlController.text = widget.psInfo[element];
            break;
          case 'area':
            _areaController.text = widget.psInfo[element];
            break;
          case 'options':
            _optionsController.text = widget.psInfo[element];
            break;
          case 'path':
            _pathController.text = widget.psInfo[element];
            break;
        }
      }
    }
  }

  @override
  void dispose() {
    _remarkNameController.dispose();
    _accessKeyController.dispose();
    _secretKeyController.dispose();
    _bucketController.dispose();
    _urlController.dispose();
    _areaController.dispose();
    _optionsController.dispose();
    _pathController.dispose();
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
              controller: _accessKeyController,
              decoration: const InputDecoration(
                label: Center(child: Text('accessKey')),
                hintText: '设定accessKey',
              ),
              textAlign: TextAlign.center,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入accessKey';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _secretKeyController,
              decoration: const InputDecoration(
                label: Center(child: Text('secretKey')),
                hintText: '设定secretKey',
              ),
              textAlign: TextAlign.center,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入secretKey';
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
              controller: _urlController,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.zero,
                label: Center(child: Text('访问网址')),
                hintText: '例如:https://xxx.yyy.gld.clouddn.com',
              ),
              textAlign: TextAlign.center,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入访问网址';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _areaController,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.zero,
                label: Center(child: Text('存储区域')),
                hintText: '设定存储区域',
              ),
              textAlign: TextAlign.center,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入存储区域';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _optionsController,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.zero,
                label: Center(child: Text('可选:网站后缀')),
                hintText: '例如?imageslim',
                hintStyle: TextStyle(fontSize: 13),
              ),
              textAlign: TextAlign.center,
            ),
            TextFormField(
              controller: _pathController,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.zero,
                label: Center(child: Text('可选:存储路径')),
                hintText: '例如test/',
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
      Map configMap = await QiniuManageAPI.getConfigMap();
      _accessKeyController.text = configMap['accessKey'];
      _secretKeyController.text = configMap['secretKey'];
      _bucketController.text = configMap['bucket'];
      _urlController.text = configMap['url'];
      _areaController.text = configMap['area'];
      if (configMap['options'] != 'None') {
        _pathController.text = configMap['options'];
      }
      if (configMap['path'] != 'None') {
        _pathController.text = configMap['path'];
      }
      showToast('导入成功');
    } catch (e) {
      showToast('导入失败');
    }
  }

  _saveConfig() async {
    if (_formKey.currentState!.validate()) {
      String remarkName = _remarkNameController.text;
      String accessKey = _accessKeyController.text;
      String secretKey = _secretKeyController.text;
      String bucket = _bucketController.text;
      String url = _urlController.text;
      String area = _areaController.text;
      String options = _optionsController.text;
      String path = _pathController.text;

      if (remarkName.isEmpty || remarkName.trim().isEmpty) {
        remarkName = ConfigureTemplate.placeholder;
      }

      if (path.isNotEmpty && path.trim().isNotEmpty) {
        if (path.startsWith('/')) {
          path = path.substring(1);
        }
        if (!path.endsWith('/')) {
          path = '$path/';
        }
      } else {
        path = ConfigureTemplate.placeholder;
      }

      if (!url.startsWith('http') && !url.startsWith('https')) {
        url = 'http://$url';
      }
      if (url.endsWith('/')) {
        url = url.substring(0, url.length - 1);
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
        'accessKey': accessKey,
        'secretKey': secretKey,
        'bucket': bucket,
        'url': url,
        'area': area,
        'options': options,
        'path': path,
      };

      try {
        await ConfigureStoreFile().updateConfigureFileKey(
          'qiniu',
          widget.storeKey,
          psInfo,
        );
        showToast('保存成功');
        return true;
      } catch (e) {
        FLog.error(
            className: ' QiniuConfigStoreEditPage',
            methodName: '_saveConfig',
            text: formatErrorMessage({}, e.toString()),
            dataLogType: DataLogType.ERRORS.toString());
      }
      showToast('保存失败');
      return false;
    }
  }
}
