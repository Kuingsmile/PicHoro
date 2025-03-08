import 'package:flutter/material.dart';
import 'package:f_logs/f_logs.dart';

import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/picture_host_configure/configure_store/configure_store_file.dart';
import 'package:horopic/picture_host_configure/configure_store/configure_template.dart';
import 'package:horopic/picture_host_manage/manage_api/imgur_manage_api.dart';
import 'package:horopic/picture_host_configure/widgets/configure_widgets.dart';

class ImgurConfigureStoreEdit extends StatefulWidget {
  final String storeKey;
  final Map psInfo;
  const ImgurConfigureStoreEdit({
    super.key,
    required this.storeKey,
    required this.psInfo,
  });

  @override
  ImgurConfigureStoreEditState createState() => ImgurConfigureStoreEditState();
}

class ImgurConfigureStoreEditState extends State<ImgurConfigureStoreEdit> {
  final _formKey = GlobalKey<FormState>();

  final _remarkNameController = TextEditingController();
  final _clientIdController = TextEditingController();
  final _proxyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initConfig();
  }

  _initConfig() {
    List keys = [
      'remarkName',
      'clientId',
      'proxy',
    ];
    for (String element in keys) {
      if (widget.psInfo[element] != ConfigureTemplate.placeholder) {
        switch (element) {
          case 'remarkName':
            _remarkNameController.text = widget.psInfo[element];
          case 'clientId':
            _clientIdController.text = widget.psInfo[element];
          case 'proxy':
            _proxyController.text = widget.psInfo[element];
        }
      }
    }
  }

  @override
  void dispose() {
    _remarkNameController.dispose();
    _clientIdController.dispose();
    _proxyController.dispose();
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
                  controller: _clientIdController,
                  labelText: 'Client ID',
                  hintText: '请输入clientID',
                  prefixIcon: Icons.vpn_key,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入clientID';
                    }
                    return null;
                  },
                ),
              ],
            ),
            ConfigureWidgets.buildSettingCard(
              title: '代理设置',
              children: [
                ConfigureWidgets.buildFormField(
                  controller: _proxyController,
                  labelText: '代理设置',
                  hintText: '例如127.0.0.1:7890（可选）',
                  prefixIcon: Icons.wifi,
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
      Map configMap = await ImgurManageAPI.getConfigMap();
      _clientIdController.text = configMap['clientId'];
      if (configMap['proxy'] != 'None') {
        _proxyController.text = configMap['proxy'];
      }
      showToast('导入成功');
    } catch (e) {
      showToast('导入失败');
    }
  }

  _saveConfig() async {
    if (_formKey.currentState!.validate()) {
      String remarkName = _remarkNameController.text;
      String clientId = _clientIdController.text;
      String proxy = _proxyController.text;

      if (clientId.startsWith('Client-ID ')) {
        clientId = clientId.substring(10);
      }

      if (remarkName.isEmpty || remarkName.trim().isEmpty) {
        remarkName = ConfigureTemplate.placeholder;
      }

      if (proxy.isEmpty || proxy.trim().isEmpty) {
        proxy = ConfigureTemplate.placeholder;
      }

      Map psInfo = {
        'remarkName': remarkName,
        'clientId': clientId,
        'proxy': proxy,
      };

      try {
        await ConfigureStoreFile().updateConfigureFileKey(
          'imgur',
          widget.storeKey,
          psInfo,
        );
        showToast('保存成功');
        return true;
      } catch (e) {
        FLog.error(
            className: 'ImgurConfigStoreEditPage',
            methodName: '_saveConfig',
            text: formatErrorMessage({}, e.toString()),
            dataLogType: DataLogType.ERRORS.toString());
      }
      showToast('保存失败');
      return false;
    }
  }
}
