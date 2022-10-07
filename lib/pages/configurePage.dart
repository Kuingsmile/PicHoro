import 'package:flutter/material.dart';
import "package:horopic/pages/allPShost.dart";
import 'package:horopic/utils/common_func.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:horopic/pages/author.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:horopic/main.dart';
import 'package:horopic/pages/commonConfig.dart';
import 'package:horopic/pages/APPpassword.dart';
import 'package:horopic/pages/autoupdate.dart';
import 'package:horopic/pages/autoUpgrade.dart';
import 'package:horopic/utils/permission.dart';
import 'package:r_upgrade/r_upgrade.dart';
import 'package:horopic/utils/sqlUtils.dart';
import 'package:horopic/pages/UpdateLog.dart';
import 'package:fluttertoast/fluttertoast.dart';

//a configure page for user to show configure entry
class ConfigurePage extends StatefulWidget {
  const ConfigurePage({Key? key}) : super(key: key);

  @override
  _ConfigurePageState createState() => _ConfigurePageState();
}

class _ConfigurePageState extends State<ConfigurePage> {
  String version = ' ';
  final Uri uri = Uri.parse('https://github.com/Kuingsmile/PicHoro');

  @override
  void initState() {
    super.initState();
    _getVersion();
  }

  void _getVersion() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    setState(() {
      version = info.version;
    });
  }

  _checkUpdate() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version = packageInfo.version;
    String buildNumber = packageInfo.buildNumber;

    String remoteVersion = await MySqlUtils.getCurrentVersion();
    if (version != remoteVersion) {
      _showUpdateDialog(version, remoteVersion);
    } else {
      return Fluttertoast.showToast(
          msg: "已是最新版本",
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 2,
          backgroundColor: Theme.of(context).brightness == Brightness.light
              ? Colors.black
              : Colors.white,
          textColor: Theme.of(context).brightness == Brightness.light
              ? Colors.white
              : Colors.black,
          fontSize: 16.0);
    }
  }

  _showUpdateDialog(String version, String remoteVersion) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('发现新版本$remoteVersion'),
            content: Text('当前版本$version'),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('取消')),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _update(remoteVersion);
                  },
                  child: Text('更新')),
            ],
          );
        });
  }

  _update(String remoteVersion) async {
    String url =
        'https://www.horosama.com/self_apk/PicHoro_V$remoteVersion.apk';
    int? id = await RUpgrade.upgrade(url,
        fileName: 'PicHoro_V$remoteVersion.apk',
        isAutoRequestInstall: true,
        notificationStyle: NotificationStyle.speechAndPlanTime);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          '设置页面',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(3.0),
              child: Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      child: CircleAvatar(
                        radius: MediaQuery.of(context).size.width / 10,
                        backgroundColor: Colors.grey,
                        backgroundImage: const Image(
                                image: AssetImage('assets/app_icon.png'))
                            .image,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Text('v$version'),
                    )
                  ],
                ),
              ),
            ),
          ),
          ListTile(
            title: const Text('用户登录'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const APPPassword()));
            },
          ),
          ListTile(
            title: const Text('图床参数设置'),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const AllPShost()));
            },
            trailing: const Icon(Icons.arrow_forward_ios),
          ),
          ListTile(
            title: const Text('常规设置'),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CommonConfig()));
            },
            trailing: const Icon(Icons.arrow_forward_ios),
          ),
          ListTile(
            title: const Text('联系作者'),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AuthorInformation()));
            },
            trailing: const Icon(Icons.arrow_forward_ios),
          ),
          ListTile(
            title: const Text('立即更新'),
            onTap: () async {
              Permissionutils.askPermissionRequestInstallPackage();
              _checkUpdate();
            },
            trailing: const Icon(Icons.arrow_forward_ios),
          ),
          ListTile(
            title: const Text('更新日志'),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const UpdateLog()));
            },
            trailing: const Icon(Icons.arrow_forward_ios),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.file_upload),
            label: '上传',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: '设置',
          ),
        ],
        currentIndex: 1,
        onTap: (int index) {
          if (index == 0) {
            Navigator.pop(context);
          }
        },
      ),
    );
  }
}
