import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/picture_host_manage/manage_api/upyun_manage_api.dart';
import 'package:horopic/widgets/common_widgets.dart';

class UpyunTokenManage extends StatefulWidget {
  const UpyunTokenManage({super.key});

  @override
  UpyunTokenManageState createState() => UpyunTokenManageState();
}

class UpyunTokenManageState extends State<UpyunTokenManage> {
  String token = '';
  String tokenName = '';
  bool isLoading = true;

  @override
  initState() {
    super.initState();
    _getTokens();
  }

  Future<void> _getTokens() async {
    setState(() {
      isLoading = true;
    });

    var result = await UpyunManageAPI().readUpyunManageConfig();
    if (result == 'Error') {
      token = 'Error';
    } else {
      var jsonResult = jsonDecode(result);
      token = jsonResult['token'];
      tokenName = jsonResult['tokenname'];
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    showToast('已复制到剪贴板');
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;
    final Color accentColor = Theme.of(context).colorScheme.secondary;
    final Color backgroundColor = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        leading: getLeadingIcon(context),
        title: titleText('又拍云Token管理'),
        flexibleSpace: getFlexibleSpace(context),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    backgroundColor,
                    primaryColor.withValues(alpha: 0.08),
                  ],
                ),
              ),
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Card(
                        elevation: 3,
                        shadowColor: primaryColor.withValues(alpha: 0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            children: [
                              Icon(Icons.security, size: 48, color: accentColor),
                              const SizedBox(height: 16),
                              Text(
                                'Token信息',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: primaryColor,
                                    ),
                              ),
                              Divider(height: 30, color: primaryColor.withValues(alpha: 0.2)),
                              _buildInfoSection('Token', token, primaryColor, accentColor),
                              const SizedBox(height: 24),
                              _buildInfoSection('Token备注名', tokenName, primaryColor, accentColor),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton.icon(
                        onPressed: token == 'None' || token == 'Error'
                            ? null
                            : () async {
                                Navigator.pop(context);
                                showCupertinoAlertDialogWithConfirmFunc(
                                  content: '是否删除Token:$token?',
                                  title: '删除Token',
                                  context: context,
                                  onConfirm: () async {
                                    var result = await UpyunManageAPI().deleteToken(token, tokenName);
                                    if (result[0] != 'success') {
                                      showToast('Token删除失败');
                                      return;
                                    }
                                    var queryResult = await UpyunManageAPI().readUpyunManageConfig();
                                    if (queryResult != 'Error') {
                                      var jsonResult = jsonDecode(queryResult);
                                      String email = jsonResult['email'];
                                      String password = jsonResult['password'];
                                      await UpyunManageAPI().saveUpyunManageConfig(email, password, 'None', 'None');
                                      showToast('Token已删除');
                                      if (mounted) {
                                        Navigator.pop(context);
                                        Navigator.pop(context);
                                      }
                                    }
                                  },
                                );
                              },
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('注销Token'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildInfoSection(String title, String value, Color primaryColor, Color accentColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: primaryColor.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: primaryColor.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Expanded(
                child: SelectableText(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    color: accentColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.copy, color: accentColor),
                tooltip: '复制到剪贴板',
                onPressed: () => _copyToClipboard(value),
                splashRadius: 20,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
