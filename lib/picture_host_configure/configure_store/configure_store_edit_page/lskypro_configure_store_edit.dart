import 'package:flutter/material.dart';

import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/picture_host_configure/configure_store/configure_store_file.dart';
import 'package:horopic/picture_host_manage/manage_api/lskypro_manage_api.dart';
import 'package:horopic/picture_host_configure/configure_store/configure_template.dart';
import 'package:horopic/widgets/configure_widgets.dart';

class LskyproConfigureStoreEdit extends StatefulWidget {
  final String storeKey;
  final Map psInfo;
  const LskyproConfigureStoreEdit({
    super.key,
    required this.storeKey,
    required this.psInfo,
  });

  @override
  LskyproConfigureStoreEditState createState() => LskyproConfigureStoreEditState();
}

class LskyproConfigureStoreEditState extends State<LskyproConfigureStoreEdit> {
  final _formKey = GlobalKey<FormState>();

  final _remarkNameController = TextEditingController();
  final _hostController = TextEditingController();
  final _tokenController = TextEditingController();
  final _strategyIdController = TextEditingController();
  final _albumIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initConfig();
  }

  _initConfig() {
    List keys = [
      'remarkName',
      'host',
      'token',
      'strategy_id',
      'album_id',
    ];
    for (String element in keys) {
      if (widget.psInfo[element] != ConfigureTemplate.placeholder) {
        switch (element) {
          case 'remarkName':
            _remarkNameController.text = widget.psInfo[element];
          case 'host':
            _hostController.text = widget.psInfo[element];
          case 'token':
            _tokenController.text = widget.psInfo[element];
          case 'strategy_id':
            _strategyIdController.text = widget.psInfo[element].toString();
          case 'album_id':
            _albumIdController.text = widget.psInfo[element].toString();
        }
      }
    }
  }

  @override
  void dispose() {
    _remarkNameController.dispose();
    _hostController.dispose();
    _tokenController.dispose();
    _strategyIdController.dispose();
    _albumIdController.dispose();
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
                  controller: _hostController,
                  labelText: '域名',
                  hintText: '例如: https://imgx.horosama.com',
                  prefixIcon: Icons.language,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入域名';
                    }
                    return null;
                  },
                ),
                ConfigureWidgets.buildFormField(
                  controller: _tokenController,
                  labelText: 'Token',
                  hintText: '请输入Token',
                  prefixIcon: Icons.vpn_key,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入Token';
                    }
                    return null;
                  },
                ),
              ],
            ),
            ConfigureWidgets.buildSettingCard(
              title: '高级设置',
              children: [
                ConfigureWidgets.buildFormField(
                  controller: _strategyIdController,
                  labelText: '储存策略ID',
                  hintText: '输入用户名和密码获取列表,一般是1',
                  prefixIcon: Icons.storage,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入储存策略Id';
                    }
                    return null;
                  },
                ),
                ConfigureWidgets.buildFormField(
                  controller: _albumIdController,
                  labelText: '相册ID',
                  hintText: '仅对付费版和修改了代码的免费版有效（可选）',
                  prefixIcon: Icons.photo_album,
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
      Map configMap = await LskyproManageAPI().getConfigMap();
      _hostController.text = configMap['host'];
      _tokenController.text = configMap['token'];
      _strategyIdController.text = configMap['strategy_id'].toString();

      if (configMap['album_id'] != 'None') {
        _albumIdController.text = configMap['album_id'].toString();
      }
      showToast('导入成功');
    } catch (e) {
      showToast('导入失败');
    }
  }

  _saveConfig() async {
    if (_formKey.currentState!.validate()) {
      String tokenPrefix = 'Bearer ';
      String remarkName = _remarkNameController.text;
      String host = _hostController.text;
      String token = _tokenController.text;
      String strategyId = _strategyIdController.text.toString();
      String albumId = _albumIdController.text.toString();

      if (remarkName.isEmpty || remarkName.trim().isEmpty) {
        remarkName = ConfigureTemplate.placeholder;
      }
      if (!token.startsWith(tokenPrefix)) {
        token = tokenPrefix + token;
      }

      if (albumId.isEmpty || albumId.trim().isEmpty) {
        albumId = ConfigureTemplate.placeholder;
      }

      Map psInfo = {
        'remarkName': remarkName,
        'host': host,
        'token': token,
        'strategy_id': strategyId,
        'album_id': albumId,
      };

      try {
        await ConfigureStoreFile().updateConfigureFileKey(
          'lsky.pro',
          widget.storeKey,
          psInfo,
        );
        showToast('保存成功');
        return true;
      } catch (e) {
        flogErr(e, {}, 'LskyproConfigStoreEditPage', '_saveConfig');
      }
      showToast('保存失败');
      return false;
    }
  }
}
