import 'package:flutter/material.dart';
import 'package:horopic/utils/global.dart';
import 'package:horopic/utils/common_functions.dart';

class LinkFormatSelect extends StatefulWidget {
  const LinkFormatSelect({super.key});

  @override
  LinkFormatSelectState createState() => LinkFormatSelectState();
}

class LinkFormatSelectState extends State<LinkFormatSelect> {
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

  Widget _buildFormatOption(String title, String value) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.link,
          color: Theme.of(context).primaryColor,
        ),
      ),
      title: Text(title),
      trailing: Global.defaultLKformat == value ? Icon(Icons.check, color: Theme.of(context).primaryColor) : null,
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
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColor.withValues(alpha: 0.8)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          _buildSettingCard(
            title: '预设格式',
            children: [
              _buildFormatOption('URL格式', 'rawurl'),
              const Divider(height: 1, indent: 56),
              _buildFormatOption('HTML格式', 'html'),
              const Divider(height: 1, indent: 56),
              _buildFormatOption('BBcode格式', 'bbcode'),
              const Divider(height: 1, indent: 56),
              _buildFormatOption('Markdown格式', 'markdown'),
              const Divider(height: 1, indent: 56),
              _buildFormatOption('Markdown格式(带链接)', 'markdown_with_link'),
            ],
          ),
          _buildSettingCard(
            title: '自定义格式',
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.edit,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                title: const Text('使用自定义格式'),
                trailing: Global.defaultLKformat == 'custom'
                    ? Icon(Icons.check, color: Theme.of(context).primaryColor)
                    : null,
                onTap: () async {
                  await Global.setLKformat('custom');
                  setState(() {});
                },
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '格式说明:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text('• \$url - 图片的完整URL链接'),
                      const SizedBox(height: 4),
                      const Text('• \$fileName - 图片的文件名'),
                      const SizedBox(height: 8),
                      const Text('示例: <img src="\$url" alt="\$fileName">'),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: TextFormField(
                  initialValue: Global.customLinkFormat,
                  decoration: InputDecoration(
                    labelText: '自定义格式',
                    hintText: r'<img src="$url" alt="$fileName">',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).cardColor,
                  ),
                  onChanged: (String value) async {
                    await Global.setCustomLinkFormat(value);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
