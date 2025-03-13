import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/picture_host_manage/manage_api/alist_manage_api.dart';
import 'package:horopic/widgets/custom_speed_dial.dart';

class AlistFileInformation extends StatefulWidget {
  final Map fileMap;
  const AlistFileInformation({super.key, required this.fileMap});

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

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('已复制到剪贴板'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 1),
        action: SnackBarAction(
          label: '关闭',
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
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
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required String title,
    required String value,
    required IconData icon,
    bool copyable = false,
  }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(title),
      subtitle: SelectableText(
        value,
        style: const TextStyle(fontSize: 15),
      ),
      trailing: copyable
          ? IconButton(
              icon: const Icon(Icons.copy, size: 20),
              onPressed: () => _copyToClipboard(value),
              tooltip: '复制',
            )
          : null,
    );
  }

  List<Widget> _buildBasicInfoSection() {
    return [
      _buildInfoSection(
        '基本信息',
        [
          _buildInfoItem(
            title: '文件名称',
            value: widget.fileMap['name'],
            icon: Icons.insert_drive_file,
            copyable: true,
          ),
          const Divider(height: 1, indent: 56),
          _buildInfoItem(
            title: '文件大小',
            value: getFileSize(int.parse(widget.fileMap['size'].toString())),
            icon: Icons.data_usage,
          ),
        ],
      ),
    ];
  }

  List<Widget> _buildTimeInfoSection() {
    return [
      _buildInfoSection(
        '时间信息',
        [
          _buildInfoItem(
            title: '文件创建时间',
            value: widget.fileMap['modified'].toString().substring(0, 19),
            icon: Icons.access_time,
          ),
        ],
      ),
    ];
  }

  List<Widget> _buildAccessLinksSection() {
    return [
      _buildInfoSection(
        '访问链接',
        [
          _buildInfoItem(
            title: '文件签名',
            value: widget.fileMap['sign'].toString(),
            icon: Icons.verified,
            copyable: true,
          ),
          const Divider(height: 1, indent: 56),
          _buildInfoItem(
            title: '缩略图链接',
            value: widget.fileMap['thumb'].toString(),
            icon: Icons.image,
            copyable: true,
          ),
          const Divider(height: 1, indent: 56),
          _buildInfoItem(
            title: '原始文件链接',
            value: rawUrl,
            icon: Icons.link,
            copyable: true,
          ),
        ],
      ),
    ];
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
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        children: [
          ..._buildBasicInfoSection(),
          ..._buildTimeInfoSection(),
          ..._buildAccessLinksSection(),
          const SizedBox(height: 16),
        ],
      ),
      floatingActionButton: SpeedDial(
        icon: Icons.more_vert,
        activeIcon: Icons.close,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.content_copy),
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            label: '复制原始文件链接',
            onTap: () => _copyToClipboard(rawUrl),
          ),
          SpeedDialChild(
            child: const Icon(Icons.image),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            label: '复制缩略图链接',
            onTap: () => _copyToClipboard(widget.fileMap['thumb'].toString()),
          ),
          SpeedDialChild(
            child: const Icon(Icons.verified),
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            label: '复制文件签名',
            onTap: () => _copyToClipboard(widget.fileMap['sign'].toString()),
          ),
          SpeedDialChild(
            child: const Icon(Icons.insert_drive_file),
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            label: '复制文件名称',
            onTap: () => _copyToClipboard(widget.fileMap['name']),
          ),
        ],
      ),
    );
  }
}
