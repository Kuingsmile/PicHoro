import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/widgets/custom_speed_dial.dart';

class SmmsFileInformation extends StatefulWidget {
  final Map fileMap;
  const SmmsFileInformation({super.key, required this.fileMap});

  @override
  SmmsFileInformationState createState() => SmmsFileInformationState();
}

class SmmsFileInformationState extends State<SmmsFileInformation> {
  @override
  initState() {
    super.initState();
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
            value: widget.fileMap['filename'],
            icon: Icons.insert_drive_file,
            copyable: true,
          ),
          const Divider(height: 1, indent: 56),
          _buildInfoItem(
            title: '文件存储名',
            value: widget.fileMap['storename'],
            icon: Icons.storage,
            copyable: true,
          ),
          const Divider(height: 1, indent: 56),
          _buildInfoItem(
            title: '文件大小',
            value: getFileSize(widget.fileMap['size']),
            icon: Icons.data_usage,
          ),
        ],
      ),
    ];
  }

  List<Widget> _buildImageAttributesSection() {
    return [
      _buildInfoSection(
        '图像属性',
        [
          _buildInfoItem(
            title: '图片宽度',
            value: widget.fileMap['width'].toString(),
            icon: Icons.width_normal,
          ),
          const Divider(height: 1, indent: 56),
          _buildInfoItem(
            title: '图片高度',
            value: widget.fileMap['height'].toString(),
            icon: Icons.height,
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
            value: widget.fileMap['created_at'],
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
            title: '文件页面',
            value: widget.fileMap['page'],
            icon: Icons.web,
            copyable: true,
          ),
          const Divider(height: 1, indent: 56),
          _buildInfoItem(
            title: '文件链接',
            value: widget.fileMap['url'],
            icon: Icons.link,
            copyable: true,
          ),
        ],
      ),
    ];
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
              colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColor.withValues(alpha: 0.8)],
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
          ..._buildImageAttributesSection(),
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
            label: '复制图片链接',
            onTap: () => _copyToClipboard(widget.fileMap['url']),
          ),
          SpeedDialChild(
            child: const Icon(Icons.file_copy),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            label: '复制文件名称',
            onTap: () => _copyToClipboard(widget.fileMap['filename']),
          ),
          SpeedDialChild(
            child: const Icon(Icons.web),
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            label: '复制文件页面链接',
            onTap: () => _copyToClipboard(widget.fileMap['page']),
          ),
          SpeedDialChild(
            child: const Icon(Icons.storage),
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            label: '复制存储名',
            onTap: () => _copyToClipboard(widget.fileMap['storename']),
          ),
        ],
      ),
    );
  }
}
