import 'package:flutter/material.dart';
import 'package:horopic/utils/global.dart';
import 'package:horopic/pages/changeTheme.dart';
import 'package:horopic/pages/linkFormatSelect.dart';

class CommonConfig extends StatefulWidget {
  const CommonConfig({Key? key}) : super(key: key);

  @override
  _CommonConfigState createState() => _CommonConfigState();
}

class _CommonConfigState extends State<CommonConfig> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('通用设置'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('是否开启时间戳重命名'),
            subtitle: const Text('同时开启的话优先时间戳'),
            trailing: Switch(
              value: Global.isTimeStamp,
              onChanged: (value) async {
                await Global.setTimeStamp(value);
                setState(() {});
              },
            ),
          ),
          ListTile(
            title: const Text('是否开启随机字符串重命名'),
            subtitle: const Text('字符串长度为30'),
            trailing: Switch(
              value: Global.isRandomName,
              onChanged: (value) async {
                await Global.setRandomName(value);
                setState(() {});
              },
            ),
          ),
          ListTile(
            title: const Text('上传后是否自动复制链接'),
            trailing: Switch(
              value: Global.isCopyLink,
              onChanged: (value) async {
                await Global.setCopyLink(value);
                setState(() {});
              },
            ),
          ),
          ListTile(
            title: const Text('主题设置'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const ChangeTheme()));
            },
          ),
          ListTile(
            title: const Text('默认复制链接格式'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const LinkFormatSelect()));
            },
          ),
        ],
      ),
    );
  }
}
