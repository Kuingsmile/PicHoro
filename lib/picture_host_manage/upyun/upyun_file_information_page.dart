import 'package:flutter/material.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/widgets/common_widgets.dart';

class UpyunFileInformation extends StatefulWidget {
  final Map fileMap;
  const UpyunFileInformation({super.key, required this.fileMap});

  @override
  UpyunFileInformationState createState() => UpyunFileInformationState();
}

class UpyunFileInformationState extends State<UpyunFileInformation> {
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
            subtitle: SelectableText(getFileSize(widget.fileMap['length'])),
          ),
          ListTile(
            title: const Text('mime类型'),
            subtitle: SelectableText(widget.fileMap['type']),
          ),
          ListTile(
            isThreeLine: true,
            title: const Text('文件创建时间'),
            subtitle: SelectableText(DateTime.fromMillisecondsSinceEpoch(
                    int.parse((widget.fileMap['last_modified'] * 1000).toString().split('.')[0]))
                .toString()
                .split('.')[0]),
          ),
          ListTile(
            title: const Text('文件etag'),
            subtitle: SelectableText(widget.fileMap['etag'].replaceAll('"', '')),
          ),
        ],
      ),
    );
  }
}
