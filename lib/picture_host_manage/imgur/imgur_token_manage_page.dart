import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/picture_host_manage/manage_api/imgur_manage_api.dart';

class ImgurTokenManage extends StatefulWidget {
  const ImgurTokenManage({Key? key}) : super(key: key);

  @override
  ImgurTokenManageState createState() => ImgurTokenManageState();
}

class ImgurTokenManageState extends State<ImgurTokenManage> {
  String clientID = '';
  String imgurUser = '';
  String accessToken = '';
  String proxy = '';
  @override
  initState() {
    super.initState();
    _getTokens();
  }

  _getTokens() async {
    var result = await ImgurManageAPI.readImgurManageConfig();
    if (result == 'Error') {
      clientID = 'Error';
      imgurUser = 'Error';
      accessToken = 'Error';
      proxy = 'Error';
    } else {
      var jsonResult = jsonDecode(result);
      imgurUser = jsonResult['imguruser'];
      clientID = jsonResult['clientid'];
      accessToken = jsonResult['accesstoken'];
      proxy = jsonResult['proxy'];
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: titleText('Imgur账户管理'),
      ),
      body: Center(
        child: ListView(
          children: [
            const ListTile(
              dense: true,
              title: Center(
                  child: Text('imgur用户名', style: TextStyle(fontSize: 20))),
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
              title: Center(child: Text('代理', style: TextStyle(fontSize: 20))),
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
                    var queryResult =
                        await ImgurManageAPI.readImgurManageConfig();
                    if (queryResult != 'Error') {
                      var jsonResult = jsonDecode(queryResult);
                      String imgurUser = jsonResult['imguruser'];
                      String clientID = jsonResult['clientid'];
                      String accessToken = 'None';
                      String proxy = 'None';
                      await ImgurManageAPI.saveImgurManageConfig(
                          imgurUser, clientID, accessToken, proxy);
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
