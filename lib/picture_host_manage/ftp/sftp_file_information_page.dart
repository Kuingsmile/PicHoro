import 'package:flutter/material.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/widgets/common_widgets.dart';

class SFTPFileInformation extends StatefulWidget {
  final Map fileMap;
  const SFTPFileInformation({super.key, required this.fileMap});

  @override
  SFTPFileInformationState createState() => SFTPFileInformationState();
}

class SFTPFileInformationState extends State<SFTPFileInformation> {
  @override
  initState() {
    super.initState();
  }

  permissionTranslate(String permission) {
    String result = '';
    if (permission.contains('r')) {
      result += '可读 ';
    }
    if (permission.contains('w')) {
      result += '可写 ';
    }
    if (permission.contains('x')) {
      result += '可执行';
    }
    if (result == '') {
      result = '无权限';
    }
    return result;
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
            title: const Text('文件名'),
            subtitle: Text(widget.fileMap['name']),
          ),
          ListTile(
            title: const Text('文件所有者'),
            subtitle: Text(widget.fileMap['owner']),
          ),
          ListTile(
            title: const Text('文件所属组'),
            subtitle: Text(widget.fileMap['group']),
          ),
          ListTile(
            title: const Text('文件所有者权限'),
            subtitle: SelectableText(permissionTranslate(widget.fileMap['permissions'].substring(1, 3))),
          ),
          ListTile(
            title: const Text('文件所属组权限'),
            subtitle: SelectableText(permissionTranslate(widget.fileMap['permissions'].substring(4, 6))),
          ),
          ListTile(
            title: const Text('其他用户权限'),
            subtitle: SelectableText(permissionTranslate(widget.fileMap['permissions'].substring(7, 9))),
          ),
          ListTile(
            title: const Text('文件大小'),
            subtitle: SelectableText(getFileSize(int.parse(widget.fileMap['size'].toString()))),
          ),
          ListTile(
            isThreeLine: true,
            title: const Text('文件最后修改时间'),
            subtitle: SelectableText(
                DateTime.fromMillisecondsSinceEpoch(widget.fileMap['mtime'] * 1000).toString().substring(0, 19)),
          ),
          ListTile(
            isThreeLine: true,
            title: const Text('文件最后访问时间'),
            subtitle: SelectableText(
                DateTime.fromMillisecondsSinceEpoch(widget.fileMap['atime'] * 1000).toString().substring(0, 19)),
          ),
        ],
      ),
    );
  }
}
