import 'package:flutter/material.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/widgets/common_widgets.dart';

class WebdavFileInformation extends StatefulWidget {
  final Map fileMap;
  const WebdavFileInformation({super.key, required this.fileMap});

  @override
  WebdavFileInformationState createState() => WebdavFileInformationState();
}

class WebdavFileInformationState extends State<WebdavFileInformation> {
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
        flexibleSpace: getFlexibleSpace(context),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('文件名称'),
            subtitle: SelectableText(widget.fileMap['name']),
          ),
          ListTile(
            title: const Text('文件大小'),
            subtitle: SelectableText(getFileSize(int.parse(widget.fileMap['size'].toString()))),
          ),
          ListTile(
            isThreeLine: true,
            title: const Text('文件创建时间'),
            subtitle: SelectableText(
                widget.fileMap['mTime'] == null ? '' : widget.fileMap['mTime'].toString().substring(0, 19)),
          ),
          ListTile(
            title: const Text('文件类型'),
            subtitle: SelectableText(widget.fileMap['mimeType'] == null ? '' : widget.fileMap['mimeType'].toString()),
          ),
          ListTile(
            title: const Text('文件eTag'),
            subtitle: SelectableText(
                widget.fileMap['eTag'] == null ? '' : widget.fileMap['eTag'].toString().replaceAll('"', '')),
          ),
          ListTile(
            title: const Text('原始文件链接'),
            subtitle: SelectableText(widget.fileMap['rawUrl']),
          ),
        ],
      ),
    );
  }
}
