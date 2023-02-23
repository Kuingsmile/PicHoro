import 'package:flutter/material.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/picture_host_manage/manage_api/alist_manage_api.dart';

class AlistFileInformation extends StatefulWidget {
  final Map fileMap;
  const AlistFileInformation({Key? key, required this.fileMap})
      : super(key: key);

  @override
  AlistFileInformationState createState() => AlistFileInformationState();
}

class AlistFileInformationState extends State<AlistFileInformation> {
  String rawUrl = '';

  @override
  initState() {
    super.initState();
    getcompleteInformation();
  }

  getcompleteInformation() async {
    Map fileMap = widget.fileMap;
    var res = await AlistManageAPI.getFileInfo(fileMap['fullPath']);
    if (res[0] == 'success') {
      setState(() {
        rawUrl = res[1]['raw_url'];
      });
    }
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
            subtitle: SelectableText(widget.fileMap['name']),
          ),
          ListTile(
            title: const Text('文件大小'),
            subtitle: SelectableText(
                getFileSize(int.parse(widget.fileMap['size'].toString()))),
          ),
          ListTile(
            isThreeLine: true,
            title: const Text('文件创建时间'),
            subtitle: SelectableText(
                widget.fileMap['modified'].toString().substring(0, 19)),
          ),
          ListTile(
            title: const Text('文件签名'),
            subtitle: SelectableText(widget.fileMap['sign'].toString()),
          ),
          ListTile(
            title: const Text('缩略图链接'),
            subtitle: SelectableText(widget.fileMap['thumb'].toString()),
          ),
          ListTile(
            title: const Text('原始文件链接'),
            subtitle: SelectableText(rawUrl),
          ),
        ],
      ),
    );
  }
}
