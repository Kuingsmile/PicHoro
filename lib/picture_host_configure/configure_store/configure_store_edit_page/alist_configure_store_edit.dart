import 'package:flutter/material.dart';
import 'package:f_logs/f_logs.dart';

import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/picture_host_configure/configure_store/configure_store_file.dart';
import 'package:horopic/picture_host_manage/manage_api/alist_manage_api.dart';
import 'package:horopic/picture_host_configure/configure_store/configure_template.dart';

class AlistConfigureStoreEdit extends StatefulWidget {
  final String storeKey;
  final Map psInfo;
  const AlistConfigureStoreEdit({
    Key? key,
    required this.storeKey,
    required this.psInfo,
  }) : super(key: key);

  @override
  AlistConfigureStoreEditState createState() => AlistConfigureStoreEditState();
}

class AlistConfigureStoreEditState extends State<AlistConfigureStoreEdit> {
  final _formKey = GlobalKey<FormState>();

  final _remarkNameController = TextEditingController();
  final _hostController = TextEditingController();
  final _alistusernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _tokenController = TextEditingController();
  final _uploadPathController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initConfig();
  }

  _initConfig() {
    List keys = [
      'remarkName',
      'host',
      'alistusername',
      'password',
      'token',
      'uploadPath',
    ];
    for (String element in keys) {
      if (widget.psInfo[element] != ConfigureTemplate.placeholder) {
        switch (element) {
          case 'remarkName':
            _remarkNameController.text = widget.psInfo[element];
            break;
          case 'host':
            _hostController.text = widget.psInfo[element];
            break;
          case 'alistusername':
            _alistusernameController.text = widget.psInfo[element];
            break;
          case 'password':
            _passwordController.text = widget.psInfo[element];
            break;
          case 'token':
            _tokenController.text = widget.psInfo[element];
            break;
          case 'uploadPath':
            _uploadPathController.text = widget.psInfo[element];
            break;
        }
      }
    }
  }

  @override
  void dispose() {
    _remarkNameController.dispose();
    _hostController.dispose();
    _alistusernameController.dispose();
    _passwordController.dispose();
    _tokenController.dispose();
    _uploadPathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: titleText('??????????????????'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          children: [
            TextFormField(
              controller: _remarkNameController,
              decoration: const InputDecoration(
                label: Center(child: Text('?????????????????????')),
                hintText: '?????????????????????',
              ),
              textAlign: TextAlign.center,
            ),
            TextFormField(
              controller: _hostController,
              decoration: const InputDecoration(
                label: Center(child: Text('??????')),
                hintText: '??????: https://alist.test.com',
              ),
              textAlign: TextAlign.center,
              validator: (value) {
                if (value == null ||
                    value.isEmpty ||
                    value.toString().trim().isEmpty) {
                  return '???????????????';
                }
                if (!value.startsWith('http://') &&
                    !value.startsWith('https://')) {
                  return '???http://???https://??????';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _alistusernameController,
              decoration: const InputDecoration(
                label: Center(child: Text('?????????')),
                hintText: '???????????????',
              ),
              textAlign: TextAlign.center,
            ),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                label: Center(child: Text('??????')),
                hintText: '????????????',
              ),
              textAlign: TextAlign.center,
            ),
            TextFormField(
              controller: _tokenController,
              decoration: const InputDecoration(
                label: Center(child: Text('Token')),
                hintText: '?????????Token',
              ),
              textAlign: TextAlign.center,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '?????????Token';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _uploadPathController,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.zero,
                label: Center(child: Text('????????????')),
                hintText: '??????: /????????????/??????',
              ),
              textAlign: TextAlign.center,
            ),
            ListTile(
                title: ElevatedButton(
              onPressed: () {
                _importConfig();
                setState(() {});
              },
              child: titleText('????????????????????????', fontsize: null),
            )),
            ListTile(
                title: ElevatedButton(
              onPressed: () async {
                var result = await _saveConfig();
                if (result == true && mounted) {
                  Navigator.pop(context, true);
                }
              },
              child: titleText('????????????', fontsize: null),
            )),
          ],
        ),
      ),
    );
  }

  _importConfig() async {
    try {
      Map configMap = await AlistManageAPI.getConfigMap();
      _hostController.text = configMap['host'];
      _alistusernameController.text = configMap['alistusername'];
      _passwordController.text = configMap['password'];
      _tokenController.text = configMap['token'];

      if (configMap['uploadPath'] != 'None') {
        _uploadPathController.text = configMap['uploadPath'];
      }
      showToast('????????????');
    } catch (e) {
      showToast('????????????');
    }
  }

  _saveConfig() async {
    if (_formKey.currentState!.validate()) {
      String remarkName = _remarkNameController.text;
      String host = _hostController.text;
      String alistusername = _alistusernameController.text;
      String password = _passwordController.text;
      String token = _tokenController.text;
      String uploadPath = _uploadPathController.text;

      if (host.endsWith('/')) {
        host = host.substring(0, host.length - 1);
      }
      if (!host.startsWith('http://') && !host.startsWith('https://')) {
        host = 'https://$host';
      }

      if (remarkName.isEmpty || remarkName.trim().isEmpty) {
        remarkName = ConfigureTemplate.placeholder;
      }
      if (uploadPath.isEmpty || uploadPath == '/' || uploadPath.trim() == '') {
        uploadPath = ConfigureTemplate.placeholder;
      }

      Map psInfo = {
        'remarkName': remarkName,
        'host': host,
        'alistusername': alistusername,
        'password': password,
        'token': token,
        'uploadPath': uploadPath,
      };

      try {
        await ConfigureStoreFile().updateConfigureFileKey(
          'alist',
          widget.storeKey,
          psInfo,
        );
        showToast('????????????');
        return true;
      } catch (e) {
        FLog.error(
            className: 'AlistConfigStoreEditPage',
            methodName: '_saveConfig',
            text: formatErrorMessage({}, e.toString()),
            dataLogType: DataLogType.ERRORS.toString());
      }
      showToast('????????????');
      return false;
    }
  }
}
