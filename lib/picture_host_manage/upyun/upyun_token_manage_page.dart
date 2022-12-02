import 'package:flutter/material.dart';
import 'package:horopic/utils/sql_utils.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/utils/global.dart';
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
    var result =
        await MySqlUtils.queryUpyunManage(username: Global.defaultUser);
    if (result == 'Empty' || result == 'Error') {
      token = 'Error';
    } else {
      token = result['token'];
      tokenName = result['tokenname'];
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
              title:
                  Center(child: Text('Token', style: TextStyle(fontSize: 20))),
            ),
            ListTile(
              subtitle: Center(
                child: SelectableText(token,
                    style: const TextStyle(color: Colors.blue)),
              ),
            ),
            const ListTile(
              dense: true,
              title: Center(
                  child: Text('Token备注名', style: TextStyle(fontSize: 20))),
            ),
            ListTile(
              title: Center(
                child: SelectableText(tokenName,
                    style: const TextStyle(color: Colors.blue)),
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
                    var result =
                        await UpyunManageAPI.deleteToken(token, tokenName);
                    if (result[0] == 'success') {
                      var queryResult = await MySqlUtils.queryUpyunManage(
                          username: Global.defaultUser);
                      if (queryResult != 'Empty' && queryResult != 'Error') {
                        String email = queryResult['email'];
                        String password = queryResult['password'];
                        String token = 'None';
                        String tokenName = 'None';
                        await MySqlUtils.updateUpyunManage(content: [
                          email,
                          password,
                          token,
                          tokenName,
                          Global.defaultUser
                        ]);
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
