import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/picture_host_manage/manage_api/upyun_manage_api.dart';

class UpyunTokenManage extends StatefulWidget {
  const UpyunTokenManage({Key? key}) : super(key: key);

  @override
  UpyunTokenManageState createState() => UpyunTokenManageState();
}

class UpyunTokenManageState extends State<UpyunTokenManage> {
  String token = '';
  String tokenName = '';
  @override
  initState() {
    super.initState();
    _getTokens();
  }

  _getTokens() async {
    var result = await UpyunManageAPI.readUpyunManageConfig();
    if (result == 'Error') {
      token = 'Error';
    } else {
      var jsonResult = jsonDecode(result);
      token = jsonResult['token'];
      tokenName = jsonResult['tokenname'];
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: titleText('又拍云Token管理'),
      ),
      body: Center(
        child: Column(
          children: [
            const ListTile(
              dense: true,
              title: Center(child: Text('Token', style: TextStyle(fontSize: 20))),
            ),
            ListTile(
              subtitle: Center(
                child: SelectableText(token, style: const TextStyle(color: Colors.blue)),
              ),
            ),
            const ListTile(
              dense: true,
              title: Center(child: Text('Token备注名', style: TextStyle(fontSize: 20))),
            ),
            ListTile(
              title: Center(
                child: SelectableText(tokenName, style: const TextStyle(color: Colors.blue)),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                showCupertinoAlertDialogWithConfirmFunc(
                  content: '是否删除Token:$token?',
                  title: '删除Token',
                  context: context,
                  onConfirm: () async {
                    Navigator.pop(context);
                    var result = await UpyunManageAPI.deleteToken(token, tokenName);
                    if (result[0] == 'success') {
                      var queryResult = await UpyunManageAPI.readUpyunManageConfig();
                      if (queryResult != 'Error') {
                        var jsonResult = jsonDecode(queryResult);
                        String email = jsonResult['email'];
                        String password = jsonResult['password'];
                        String token = 'None';
                        String tokenName = 'None';
                        await UpyunManageAPI.saveUpyunManageConfig(email, password, token, tokenName);
                        showToast('Token已删除');
                        if (mounted) {
                          Navigator.pop(context);
                          Navigator.pop(context);
                        }
                      }
                    } else {
                      showToast('Token删除失败');
                    }
                  },
                );
              },
              child: const Text('注销Token'),
            ),
          ],
        ),
      ),
    );
  }
}
