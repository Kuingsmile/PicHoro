import 'package:flutter/material.dart';
import 'package:horopic/utils/global.dart';

class LinkFormatSelect extends StatefulWidget {
  const LinkFormatSelect({Key? key}) : super(key: key);

  @override
  _LinkFormatSelectState createState() => _LinkFormatSelectState();
}

class _LinkFormatSelectState extends State<LinkFormatSelect> {
  @override
  void initState() {
    super.initState();
  }

  final List<String> _linkformat = [
    'rawurl',
    'html',
    'BBcode',
    'markdown',
    'markdown_with_link'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('链接格式选择'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('URL格式'),
            trailing: Global.defaultLKformat == 'rawurl'
                ? const Icon(Icons.check)
                : null,
            onTap: () async {
              await Global.setLKformat('rawurl');
              setState(() {});
            },
          ),
          ListTile(
            trailing: Global.defaultLKformat == 'html'
                ? const Icon(Icons.check)
                : null,
            title: const Text('HTML格式'),
            onTap: () async {
              await Global.setLKformat('html');
              setState(() {});
            },
          ),
          ListTile(
            trailing: Global.defaultLKformat == 'BBcode'
                ? const Icon(Icons.check)
                : null,
            title: const Text('BBcode格式'),
            onTap: () async {
              await Global.setLKformat('BBcode');
              setState(() {});
            },
          ),
          ListTile(
            trailing: Global.defaultLKformat == 'markdown'
                ? const Icon(Icons.check)
                : null,
            title: const Text('markdown格式'),
            onTap: () async {
              await Global.setLKformat('markdown');
              setState(() {});
            },
          ),
          ListTile(
            trailing: Global.defaultLKformat == 'markdown_with_link'
                ? const Icon(Icons.check)
                : null,
            title: const Text('markdown格式(带链接)'),
            onTap: () async {
              await Global.setLKformat('markdown_with_link');
              setState(() {});
            },
          ),
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
                  labelText: '自定义格式',
                  hintText: r'使用$url和$fileName作为占位符',
                ),
                onChanged: (String value) async {
                  await Global.setCustomLinkFormat(value);
                },
                validator: (String? value) {
                  if (!value!.contains(r'$url') &&
                      !value.contains(r'$fileName')) {
                    return '格式错误';
                  }
                  return null;
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
