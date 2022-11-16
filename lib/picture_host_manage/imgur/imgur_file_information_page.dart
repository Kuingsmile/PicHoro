import 'package:flutter/material.dart';
import 'package:horopic/utils/common_functions.dart';

class ImgurFileInformation extends StatefulWidget {
  final Map fileMap;
  const ImgurFileInformation({Key? key, required this.fileMap})
      : super(key: key);

  @override
  ImgurFileInformationState createState() => ImgurFileInformationState();
}

class ImgurFileInformationState extends State<ImgurFileInformation> {
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
        title: const Text('文件基本信息'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('文件ID'),
            subtitle: SelectableText(widget.fileMap['id']),
          ),
          ListTile(
              title: const Text('原始文件名'),
              subtitle: SelectableText(widget.fileMap['name'] == null
                  ? '无'
                  : widget.fileMap['name'].toString())),
          ListTile(
            title: const Text('文件大小'),
            subtitle: SelectableText(getFileSize(
                int.parse(widget.fileMap['size'].toString().split('.')[0]))),
          ),
          ListTile(
            title: const Text('mime类型'),
            subtitle: SelectableText(widget.fileMap['type'].toString()),
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
              isThreeLine: true,
              title: const Text('文件创建时间'),
              subtitle: SelectableText(DateTime.fromMillisecondsSinceEpoch(
                      widget.fileMap['datetime'] * 1000)
                  .toString()
                  .substring(0, 19))),
          ListTile(
            title: const Text('文件url'),
            subtitle: SelectableText(widget.fileMap['link']),
          ),
          ListTile(
            title: const Text('文件描述'),
            subtitle: SelectableText(widget.fileMap['description'] == null
                ? '无'
                : widget.fileMap['description'].toString()),
          ),
          ListTile(
            title: const Text('文件deletehash'),
            subtitle: SelectableText(widget.fileMap['deletehash'] == null
                ? '无'
                : widget.fileMap['deletehash'].toString()),
          ),
        ],
      ),
    );
  }
}
