import 'package:flutter/material.dart';
import 'package:horopic/utils/common_functions.dart';

class QiniuFileInformation extends StatefulWidget {
  final Map fileMap;
  const QiniuFileInformation({super.key, required this.fileMap});

  @override
  QiniuFileInformationState createState() => QiniuFileInformationState();
}

class QiniuFileInformationState extends State<QiniuFileInformation> {
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
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColor.withAlpha(204)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('文件名称'),
            subtitle: SelectableText(widget.fileMap['key'].split('/').last),
          ),
          ListTile(
            title: const Text('文件大小'),
            subtitle: SelectableText(getFileSize(widget.fileMap['fsize'])),
          ),
          ListTile(
            title: const Text('mime类型'),
            subtitle: SelectableText(widget.fileMap['mimeType']),
          ),
          ListTile(
            isThreeLine: true,
            title: const Text('文件创建时间'),
            subtitle: SelectableText(
                DateTime.fromMillisecondsSinceEpoch(int.parse((widget.fileMap['putTime']).toString().split('.')[0]))
                    .toString()
                    .split('.')[0]),
          ),
          ListTile(
            title: const Text('文件hash'),
            subtitle: SelectableText(widget.fileMap['hash']),
          ),
          ListTile(
            title: const Text('文件md5'),
            subtitle: SelectableText(widget.fileMap['md5']),
          ),
        ],
      ),
    );
  }
}
