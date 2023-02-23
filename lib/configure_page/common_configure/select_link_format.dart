import 'package:flutter/material.dart';
import 'package:horopic/utils/global.dart';
import 'package:horopic/utils/common_functions.dart';

class LinkFormatSelect extends StatefulWidget {
  const LinkFormatSelect({Key? key}) : super(key: key);

  @override
  LinkFormatSelectState createState() => LinkFormatSelectState();
}

class LinkFormatSelectState extends State<LinkFormatSelect> {
  @override
  void initState() {
    super.initState();
  }

  ListTile _buildListTile(String title, String value) {
    return ListTile(
      title: Text(title),
      trailing:
          Global.defaultLKformat == value ? const Icon(Icons.check) : null,
      onTap: () async {
        await Global.setLKformat(value);
        setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: titleText(
          '链接格式选择',
        ),
      ),
      body: ListView(
        children: [
          _buildListTile('URL格式', 'rawurl'),
          _buildListTile('HTML格式', 'html'),
          _buildListTile('BBcode格式', 'BBcode'),
          _buildListTile('Markdown格式', 'markdown'),
          _buildListTile('Markdown格式(带链接)', 'markdown_with_link'),
          ListTile(
            trailing: Global.defaultLKformat == 'custom'
                ? const Icon(Icons.check)
                : null,
            title: const Text('自定义格式,下方输入框内设置'),
            onTap: () async {
              await Global.setLKformat('custom');
              setState(() {});
            },
          ),
          ListView(
            shrinkWrap: true,
            children: [
              TextFormField(
                textAlign: TextAlign.center,
                initialValue: Global.customLinkFormat,
                decoration: const InputDecoration(
                  label: Center(child: Text('自定义格式')),
                  hintText: r'使用$url和$fileName作为占位符',
                ),
                onChanged: (String value) async {
                  await Global.setCustomLinkFormat(value);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
