import 'package:flutter/material.dart';
import 'package:horopic/utils/common_func.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:horopic/utils/sqlUtils.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AutoUpdate extends StatefulWidget {
  const AutoUpdate({Key? key}) : super(key: key);

  @override
  _AutoUpdateState createState() => _AutoUpdateState();
}

class _AutoUpdateState extends State<AutoUpdate> {
  final String _uri = 'https://www.horosama.com/self_apk/PicHoro.apk';
  String _currentVersion = '';
  String _newVersion = '';

  @override
  void initState() {
    super.initState();
  }

  _getLocalVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    _currentVersion = packageInfo.version;
    return packageInfo.version;
  }

  _getRemoteVersion() async {
    String remoteVersion = await MySqlUtils.getCurrentVersion();
    _newVersion = remoteVersion;
    return remoteVersion;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('软件更新'),
        ),
        body: ListView(
          padding: const EdgeInsets.all(10),
          children: [
            ListTile(
              leading: const Icon(Icons.update),
              trailing: const Icon(Icons.update),
              title: const Center(
                child: Text('点击检查更新',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    )),
              ),
              onTap: () async {
                await _getLocalVersion();
                await _getRemoteVersion();
                showAlertDialog(
                    context: context,
                    title: '版本信息',
                    content: '当前版本：$_currentVersion,\n最新版本：$_newVersion');
              },
            ),
            Center(
                child: ElevatedButton(
              child: Text('点击复制下载链接'),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: _uri));
                Fluttertoast.showToast(
                    msg: "复制成功",
                    toastLength: Toast.LENGTH_SHORT,
                    timeInSecForIosWeb: 2,
                    backgroundColor:
                        Theme.of(context).brightness == Brightness.light
                            ? Colors.black
                            : Colors.white,
                    textColor: Theme.of(context).brightness == Brightness.light
                        ? Colors.white
                        : Colors.black,
                    fontSize: 16.0);
              },
            )),
            SizedBox(height: 20),
            Center(
              child: Text('下载地址二维码'),
            ),
            Center(
              child: Image.asset(
                'assets/app_download.png',
                width: 400,
                height: 300,
              ),
            ),
          ],
        ));
  }
}
