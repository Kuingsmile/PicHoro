import 'package:flutter/material.dart';
import 'package:horopic/utils/common_functions.dart';

class SmmsFileInformation extends StatefulWidget {
  final Map fileMap;
  const SmmsFileInformation({Key? key, required this.fileMap})
      : super(key: key);

  @override
  SmmsFileInformationState createState() => SmmsFileInformationState();
}

class SmmsFileInformationState extends State<SmmsFileInformation> {
  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: titleText('文件基本信息'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('文件名称'),
            subtitle: SelectableText(widget.fileMap['filename']),
          ),
          ListTile(
            title: const Text('文件存储名'),
            subtitle: SelectableText(widget.fileMap['storename']),
          ),
          ListTile(
            title: const Text('文件大小'),
            subtitle: SelectableText(getFileSize(widget.fileMap['size'])),
          ),
          ListTile(
            title: const Text('图片宽度'),
            subtitle: SelectableText(widget.fileMap['width'].toString()),
          ),
          ListTile(
            title: const Text('图片高度'),
            subtitle: SelectableText(widget.fileMap['height'].toString()),
          ),
          ListTile(
            title: const Text('文件页面'),
            subtitle: SelectableText(widget.fileMap['page']),
          ),
          ListTile(
            isThreeLine: true,
            title: const Text('文件创建时间'),
            subtitle: SelectableText(widget.fileMap['created_at']),
          ),
          ListTile(
            title: const Text('文件url'),
            subtitle: SelectableText(widget.fileMap['url']),
          ),
        ],
      ),
    );
  }
}
