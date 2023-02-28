import 'package:flutter/material.dart';
import 'package:horopic/utils/common_functions.dart';

class AliyunFileInformation extends StatefulWidget {
  final Map fileMap;
  const AliyunFileInformation({Key? key, required this.fileMap})
      : super(key: key);

  @override
  AliyunFileInformationState createState() => AliyunFileInformationState();
}

class AliyunFileInformationState extends State<AliyunFileInformation> {
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
            subtitle: SelectableText(widget.fileMap['Key'].split('/').last),
          ),
          ListTile(
            title: const Text('文件大小'),
            subtitle: SelectableText(getFileSize(int.parse(widget.fileMap['Size']))),
          ),
          ListTile(
            isThreeLine: true,
            title: const Text('文件创建时间'),
            subtitle: SelectableText(widget.fileMap['LastModified'].toString().substring(0, 19)),
          ),
          ListTile(
            title: const Text('文件etag'),
            subtitle: SelectableText(widget.fileMap['ETag'].replaceAll('"', '')),
          ),
        ],
      ),
    );
  }
}
