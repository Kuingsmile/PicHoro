import 'package:flutter/material.dart';
import 'package:horopic/utils/sql_utils.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/utils/global.dart';

class ImgurTokenManage extends StatefulWidget {
  const ImgurTokenManage({Key? key}) : super(key: key);

  @override
  ImgurTokenManageState createState() => ImgurTokenManageState();
}

class ImgurTokenManageState extends State<ImgurTokenManage> {
  String clientID = '';
  String imgurUser = '';
  String clientSecret = '';
  String accessToken = '';
  String proxy = '';
  @override
  initState() {
    super.initState();
    _getTokens();
  }

  _getTokens() async {
    var result =
        await MySqlUtils.queryImgurManage(username: Global.defaultUser);
    if (result == 'Empty' || result == 'Error') {
      clientID = 'Error';
      imgurUser = 'Error';
      clientSecret = 'Error';
      accessToken = 'Error';
      proxy = 'Error';
    } else {
      imgurUser = result['imguruser'];
      clientID = result['clientid'];
      clientSecret = result['clientsecret'];
      accessToken = result['accesstoken'];
      proxy = result['proxy'];
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: const Text('Imgur账户管理'),
      ),
      body: Center(
        child: ListView(
          children: [
            const ListTile(
              dense: true,
              title:
                  Center(child: Text('imgur用户名', style: TextStyle(fontSize: 20))),
            ),
            ListTile(
              title: Center(
                child: SelectableText(imgurUser,
                    style: const TextStyle(color: Colors.blue)),
              ),
            ),
            const ListTile(
              dense: true,
              title: Center(
                  child: Text('Client ID', style: TextStyle(fontSize: 20))),
            ),
            ListTile(
              title: Center(
                child: SelectableText(clientID,
                    style: const TextStyle(color: Colors.blue)),
              ),
            ),
            const ListTile(
              dense: true,
              title: Center(
                  child: Text('Client Secret', style: TextStyle(fontSize: 20))),
            ),
            ListTile(
              title: Center(
                child: SelectableText(clientSecret,
                    style: const TextStyle(color: Colors.blue)),
              ),
            ),
            const ListTile(
              dense: true,
              title: Center(
                  child: Text('Access Token', style: TextStyle(fontSize: 20))),
            ),
            ListTile(
              title: Center(
                child: SelectableText(accessToken,
                    style: const TextStyle(color: Colors.blue)),
              ),
            ),
            const ListTile(
              dense: true,
              title: Center(
                  child: Text('代理', style: TextStyle(fontSize: 20))),
            ),
            ListTile(
              title: Center(
                child: SelectableText(proxy,
                    style: const TextStyle(color: Colors.blue)),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                showCupertinoAlertDialogWithConfirmFunc(
                  content: '是否注销用户?',
                  title: '注销',
                  context: context,
                  onConfirm: () async {
                    Navigator.pop(context);
                      var queryResult = await MySqlUtils.queryImgurManage(
                          username: Global.defaultUser);
                      if (queryResult != 'Empty' && queryResult != 'Error') {
                        String imgurUser = queryResult['imguruser'];
                        String clientID = queryResult['clientid'];
                        String clientSecret = queryResult['clientsecret'];
                        String accessToken = 'None';
                        String proxy = 'None';
                        await MySqlUtils.updateImgurManage(content: [
                          imgurUser,
                          clientID,
                          clientSecret,
                          accessToken,
                          proxy,
                          Global.defaultUser
                        ]);
                        showToast('注销成功');
                        if (mounted) {
                          Navigator.pop(context);
                          Navigator.pop(context);
                        
                      }
                    } else {
                      showToast('注销失败');
                    }
                  },
                );
              },
              child: const Text('注销'),
            ),
          ],
        ),
      ),
    );
  }
}
