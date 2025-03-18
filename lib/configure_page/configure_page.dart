import 'package:flutter/material.dart';

import 'package:dio/dio.dart';
import 'package:horopic/widgets/common_widgets.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:r_upgrade/r_upgrade.dart';
import 'package:fluro/fluro.dart';
import 'package:provider/provider.dart';

import 'package:horopic/router/application.dart';
import 'package:horopic/router/routers.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/utils/theme_provider.dart';

class ConfigurePage extends StatefulWidget {
  const ConfigurePage({super.key});

  @override
  ConfigurePageState createState() => ConfigurePageState();
}

class ConfigurePageState extends State<ConfigurePage> with AutomaticKeepAliveClientMixin<ConfigurePage> {
  String version = ' ';
  String latestVersion = ' ';
  bool _isLoading = false;
  bool _updateAvailable = false;
  DateTime? _lastVersionCheck;
  static const versionCheckInterval = Duration(minutes: 10);

  @override
  bool get wantKeepAlive => false;

  @override
  void initState() {
    super.initState();
    _initPageData();
  }

  void _initPageData() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        version = info.version;
      });
    }

    _checkVersionInBackground();
  }

  void _checkVersionInBackground() async {
    final now = DateTime.now();
    if (_lastVersionCheck != null && now.difference(_lastVersionCheck!) < versionCheckInterval) {
      return;
    }

    _lastVersionCheck = now;

    String remoteVersion = await getRemoteVersion();
    if (mounted) {
      setState(() {
        latestVersion = remoteVersion;
        _updateAvailable = _isUpdateAvailable(version, remoteVersion);
      });
    }
    // No dialog shown for background checks
  }

  Future<String> getRemoteVersion() async {
    const url = 'https://pichoro.msq.pub/version.json';
    try {
      Response response = await Dio().get(url);
      return response.data['version'];
    } catch (e) {
      return ' ';
    }
  }

  bool _isUpdateAvailable(String currentVersion, String remoteVersion) {
    if (remoteVersion == ' ') return false;

    try {
      List<int> currentParts = currentVersion.split('.').map((part) => int.parse(part)).toList();

      List<int> remoteParts = remoteVersion.split('.').map((part) => int.parse(part)).toList();

      // Compare version segments
      for (int i = 0; i < currentParts.length && i < remoteParts.length; i++) {
        if (remoteParts[i] > currentParts[i]) {
          return true;
        } else if (remoteParts[i] < currentParts[i]) {
          return false;
        }
      }

      // If all compared segments are equal, check if remote has more segments
      return remoteParts.length > currentParts.length;
    } catch (e) {
      // In case of parsing errors, fall back to string comparison
      return remoteVersion != currentVersion;
    }
  }

  _checkUpdate() async {
    if (_isLoading) {
      return showToast("正在获取版本信息");
    }

    if (latestVersion == ' ') {
      setState(() => _isLoading = true);
      String remoteVersion = await getRemoteVersion();
      setState(() {
        latestVersion = remoteVersion;
        _updateAvailable = _isUpdateAvailable(version, remoteVersion);
        _isLoading = false;
      });
    }

    if (_updateAvailable) {
      showCupertinoAlertDialogWithConfirmFunc(
        title: '通知',
        content: '发现新版本$latestVersion,当前版本$version,是否更新?',
        context: context,
        onConfirm: () async {
          String url = 'https://pichoro.msq.pub/PicHoro_V$latestVersion.apk';
          RUpgrade.upgrade(url,
              fileName: 'PicHoro_V$latestVersion.apk',
              installType: RUpgradeInstallType.normal,
              notificationStyle: NotificationStyle.speechAndPlanTime);
          setState(() {});
        },
      );
    } else {
      return showToast(
        "已是最新版本",
      );
    }
  }

  Widget _buildSettingCard({required String title, required List<Widget> children}) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    Widget? trailing,
    Color? iconColor,
    Widget? subtitle,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor ??
              Theme.of(context).primaryColor.withValues(
                    alpha: 0.2,
                  ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor ?? Theme.of(context).primaryColor),
      ),
      title: Text(title),
      subtitle: subtitle,
      onTap: onTap,
      trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final themeProvider = Provider.of<AppInfoProvider>(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: titleText('设置页面'),
        flexibleSpace: getFlexibleSpace(context),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          AnimatedOpacity(
            opacity: 1.0,
            duration: const Duration(milliseconds: 500),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 32.0),
              decoration: BoxDecoration(
                color: themeProvider.isDarkMode()
                    ? Colors.black12
                    : Theme.of(context).primaryColor.withValues(alpha: 0.05),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Hero(
                    tag: 'app_logo',
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width / 8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width / 8),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width / 4,
                          height: MediaQuery.of(context).size.width / 4,
                          child: const Image(
                            image: AssetImage('assets/app_icon.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  latestVersion == ' ' || latestVersion == version
                      ? Text(
                          'v$version',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        )
                      : Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.amber),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.new_releases, color: Colors.amber, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                '当前: v$version   最新: v$latestVersion',
                                style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          _buildSettingCard(
            title: '基础配置',
            children: [
              _buildSettingItem(
                title: '图床参数设置',
                icon: Icons.cloud_upload,
                onTap: () =>
                    Application.router.navigateTo(context, Routes.allPShost, transition: TransitionType.cupertino),
              ),
              const Divider(height: 1, indent: 56),
              _buildSettingItem(
                title: '常规设置',
                icon: Icons.settings,
                onTap: () =>
                    Application.router.navigateTo(context, Routes.commonConfig, transition: TransitionType.cupertino),
              ),
            ],
          ),
          _buildSettingCard(
            title: '应用信息',
            children: [
              _buildSettingItem(
                title: '交流群',
                icon: Icons.people,
                onTap: () => Application.router
                    .navigateTo(context, Routes.authorInformation, transition: TransitionType.cupertino),
              ),
              const Divider(height: 1, indent: 56),
              _buildSettingItem(
                title: '软件日志',
                icon: Icons.description,
                onTap: () => Application.router
                    .navigateTo(context, Routes.configurePageLogger, transition: TransitionType.cupertino),
              ),
              const Divider(height: 1, indent: 56),
              _buildSettingItem(
                title: _updateAvailable ? '有新版本！' : '检查更新',
                icon: Icons.system_update,
                onTap: _checkUpdate,
                trailing: _updateAvailable
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.upload, color: Colors.white, size: 14),
                            SizedBox(width: 4),
                            Text('更新', style: TextStyle(color: Colors.white, fontSize: 12)),
                          ],
                        ),
                      )
                    : const Icon(Icons.arrow_forward_ios, size: 16),
              ),
              const Divider(height: 1, indent: 56),
              _buildSettingItem(
                title: '更新日志',
                icon: Icons.history,
                onTap: () =>
                    Application.router.navigateTo(context, Routes.updateLog, transition: TransitionType.cupertino),
              ),
            ],
          ),
          _buildSettingCard(
            title: '帮助',
            children: [
              _buildSettingItem(
                title: '使用手册',
                icon: Icons.menu_book,
                onTap: () async {
                  Application.router.navigateTo(
                    context,
                    '${Routes.webviewPage}?url=${Uri.encodeComponent('https://pichoro.horosama.com')}&title=${Uri.encodeComponent('使用手册')}&enableJs=${Uri.encodeComponent('true')}',
                    transition: TransitionType.inFromRight,
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
