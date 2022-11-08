import 'package:flutter/material.dart';
import 'package:horopic/utils/common_functions.dart';

class LskyproFileInformation extends StatefulWidget {
  final Map fileMap;
  const LskyproFileInformation({Key? key, required this.fileMap})
      : super(key: key);

  @override
  LskyproFileInformationState createState() => LskyproFileInformationState();
}

class LskyproFileInformationState extends State<LskyproFileInformation> {
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
            title: const Text('文件名'),
            subtitle: SelectableText(widget.fileMap['name']),
          ),
          ListTile(
            title: const Text('原始文件名'),
            subtitle: SelectableText(widget.fileMap['origin_name']),
          ),
          ListTile(
            title: const Text('文件大小'),
            subtitle: SelectableText(getFileSize(
                int.parse(widget.fileMap['size'].toString().split('.')[0]) *
                    1024)),
          ),
          ListTile(
            title: const Text('mime类型'),
            subtitle: SelectableText(widget.fileMap['mimetype'].toString()),
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
            subtitle: SelectableText(widget.fileMap['date']),
          ),
          ListTile(
            title: const Text('文件url'),
            subtitle: SelectableText(widget.fileMap['links']['url']),
          ),
          ListTile(
            title: const Text('文件缩略图url'),
            subtitle: SelectableText(widget.fileMap['links']['thumbnail_url']),
          ),
          ListTile(
            title: const Text('文件唯一密钥'),
            subtitle: SelectableText(widget.fileMap['key']),
          ),
          ListTile(
            title: const Text('文件md5'),
            subtitle: SelectableText(widget.fileMap['md5']),
          ),
          ListTile(
            title: const Text('文件sha1'),
            subtitle: SelectableText(widget.fileMap['sha1']),
          ),
        ],
      ),
    );
  }
}
