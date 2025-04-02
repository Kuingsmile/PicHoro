import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/picture_host_manage/manage_api/imgur_manage_api.dart';
import 'package:horopic/widgets/common_widgets.dart';

class ImgurTokenManage extends StatefulWidget {
  const ImgurTokenManage({super.key});

  @override
  ImgurTokenManageState createState() => ImgurTokenManageState();
}

class ImgurTokenManageState extends State<ImgurTokenManage> {
  String clientID = '';
  String imgurUser = '';
  String accessToken = '';
  String proxy = '';
  bool isLoading = true;

  @override
  initState() {
    super.initState();
    _getTokens();
  }

  _getTokens() async {
    setState(() {
      isLoading = true;
    });

    var result = await ImgurManageAPI().readImgurManageConfig();
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

    setState(() {
      isLoading = false;
    });
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).primaryColor),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            SelectableText(
              value,
              style: TextStyle(
                color: Colors.blue.shade700,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        leading: getLeadingIcon(context),
        title: titleText('Imgur账户管理'),
        flexibleSpace: getFlexibleSpace(context),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).primaryColor.withValues(alpha: 0.7),
                            Theme.of(context).primaryColor.withValues(alpha: 0.3),
                          ],
                        ),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 30,
                            child: Icon(
                              Icons.account_circle,
                              size: 40,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Imgur账户信息",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  imgurUser != 'Error' ? "用户名: $imgurUser" : "未登录或加载失败",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildInfoCard('Client ID', clientID, Icons.vpn_key),
                    _buildInfoCard('Access Token', accessToken, Icons.token),
                    _buildInfoCard('代理设置', proxy, Icons.settings_ethernet),
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: ElevatedButton(
                        onPressed: () async {
                          showCupertinoAlertDialogWithConfirmFunc(
                            content: '是否注销用户?',
                            title: '注销',
                            context: context,
                            onConfirm: () async {
                              var queryResult = await ImgurManageAPI().readImgurManageConfig();
                              if (queryResult != 'Error') {
                                var jsonResult = jsonDecode(queryResult);
                                String imgurUser = jsonResult['imguruser'];
                                String clientID = jsonResult['clientid'];
                                String accessToken = 'None';
                                String proxy = 'None';
                                await ImgurManageAPI().saveImgurManageConfig(imgurUser, clientID, accessToken, proxy);
                                showToast('注销成功');
                                if (mounted) {
                                  Navigator.pop(context);
                                  _getTokens(); // Refresh the data
                                }
                              } else {
                                showToast('注销失败');
                              }
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: Colors.redAccent,
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.logout),
                            SizedBox(width: 8),
                            Text(
                              '注销',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
