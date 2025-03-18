import 'package:flutter/material.dart';

import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/picture_host_configure/configure_store/configure_store_file.dart';
import 'package:horopic/picture_host_manage/manage_api/smms_manage_api.dart';
import 'package:horopic/picture_host_configure/configure_store/configure_template.dart';
import 'package:horopic/widgets/configure_widgets.dart';

class SmmsConfigureStoreEdit extends StatefulWidget {
  final String storeKey;
  final Map psInfo;
  const SmmsConfigureStoreEdit({
    super.key,
    required this.storeKey,
    required this.psInfo,
  });

  @override
  SmmsConfigureStoreEditState createState() => SmmsConfigureStoreEditState();
}

class SmmsConfigureStoreEditState extends State<SmmsConfigureStoreEdit> {
  final _formKey = GlobalKey<FormState>();

  final _remarkNameController = TextEditingController();
  final _tokenController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initConfig();
  }

  _initConfig() {
    List keys = [
      'remarkName',
      'token',
    ];
    for (String element in keys) {
      if (widget.psInfo[element] != ConfigureTemplate.placeholder) {
        switch (element) {
          case 'remarkName':
            _remarkNameController.text = widget.psInfo[element];
          case 'token':
            _tokenController.text = widget.psInfo[element];
        }
      }
    }
  }

  @override
  void dispose() {
    _remarkNameController.dispose();
    _tokenController.dispose();
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
                  controller: _tokenController,
                  labelText: 'Token',
                  hintText: '请输入token',
                  prefixIcon: Icons.vpn_key,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入token';
                    }
                    return null;
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
      Map configMap = await SmmsManageAPI().getConfigMap();
      _tokenController.text = configMap['token'];
      showToast('导入成功');
    } catch (e) {
      showToast('导入失败');
    }
  }

  _saveConfig() async {
    if (_formKey.currentState!.validate()) {
      String remarkName = _remarkNameController.text;
      String token = _tokenController.text;

      if (remarkName.isEmpty || remarkName.trim().isEmpty) {
        remarkName = ConfigureTemplate.placeholder;
      }

      Map psInfo = {
        'remarkName': remarkName,
        'token': token,
      };

      try {
        await ConfigureStoreFile().updateConfigureFileKey(
          'sm.ms',
          widget.storeKey,
          psInfo,
        );
        showToast('保存成功');
        return true;
      } catch (e) {
        flogErr(e, {}, 'SmmsConfigStoreEditPage', '_saveConfig');
      }
      showToast('保存失败');
      return false;
    }
  }
}
