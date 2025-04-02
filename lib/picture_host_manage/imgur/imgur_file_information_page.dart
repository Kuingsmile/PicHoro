import 'package:flutter/material.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/widgets/common_widgets.dart';
import 'package:horopic/picture_host_manage/common/info_page_utils.dart';
import 'package:horopic/widgets/custom_speed_dial.dart';

class ImgurFileInformation extends StatefulWidget {
  final Map fileMap;
  const ImgurFileInformation({super.key, required this.fileMap});

  @override
  ImgurFileInformationState createState() => ImgurFileInformationState();
}

class ImgurFileInformationState extends State<ImgurFileInformation> {
  @override
  initState() {
    super.initState();
  }

  List<Widget> _buildBasicInfoSection() {
    return [
      buildInfoSection(
        '基本信息',
        [
          buildInfoItem(
            context: context,
            title: '文件ID',
            value: widget.fileMap['id'],
            icon: Icons.tag,
            copyable: true,
          ),
          const Divider(height: 1, indent: 56),
          buildInfoItem(
            context: context,
            title: '原始文件名',
            value: widget.fileMap['name'] == null ? '无' : widget.fileMap['name'].toString(),
            icon: Icons.insert_drive_file,
            copyable: true,
          ),
          const Divider(height: 1, indent: 56),
          buildInfoItem(
            context: context,
            title: '文件大小',
            value: getFileSize(int.parse(widget.fileMap['size'].toString().split('.')[0])),
            icon: Icons.data_usage,
          ),
          const Divider(height: 1, indent: 56),
          buildInfoItem(
            context: context,
            title: 'mime类型',
            value: widget.fileMap['type'].toString(),
            icon: Icons.description,
          ),
        ],
      ),
    ];
  }

  List<Widget> _buildImageInfoSection() {
    return [
      buildInfoSection(
        '图片信息',
        [
          buildInfoItem(
            context: context,
            title: '图片宽度',
            value: widget.fileMap['width'].toString(),
            icon: Icons.width_normal,
          ),
          const Divider(height: 1, indent: 56),
          buildInfoItem(
            context: context,
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
      buildInfoSection(
        '时间信息',
        [
          buildInfoItem(
            context: context,
            title: '文件创建时间',
            value: DateTime.fromMillisecondsSinceEpoch(widget.fileMap['datetime'] * 1000).toString().substring(0, 19),
            icon: Icons.access_time,
          ),
        ],
      ),
    ];
  }

  List<Widget> _buildAccessLinksSection() {
    return [
      buildInfoSection(
        '访问链接',
        [
          buildInfoItem(
            context: context,
            title: '文件url',
            value: widget.fileMap['link'],
            icon: Icons.link,
            copyable: true,
          ),
          const Divider(height: 1, indent: 56),
          buildInfoItem(
            context: context,
            title: '文件描述',
            value: widget.fileMap['description'] == null ? '无' : widget.fileMap['description'].toString(),
            icon: Icons.description,
          ),
          const Divider(height: 1, indent: 56),
          buildInfoItem(
            context: context,
            title: '文件deletehash',
            value: widget.fileMap['deletehash'] == null ? '无' : widget.fileMap['deletehash'].toString(),
            icon: Icons.delete_outline,
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
        leading: getLeadingIcon(context),
        title: titleText('文件基本信息'),
        flexibleSpace: getFlexibleSpace(context),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        children: [
          ..._buildBasicInfoSection(),
          ..._buildImageInfoSection(),
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
            child: const Icon(Icons.link),
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            label: '复制文件链接',
            onTap: () => copyToClipboard(context, widget.fileMap['link']),
          ),
          SpeedDialChild(
            child: const Icon(Icons.tag),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            label: '复制文件ID',
            onTap: () => copyToClipboard(context, widget.fileMap['id']),
          ),
          SpeedDialChild(
            child: const Icon(Icons.delete_outline),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            label: '复制删除哈希',
            onTap: () => copyToClipboard(
                context, widget.fileMap['deletehash'] == null ? '无' : widget.fileMap['deletehash'].toString()),
          ),
          SpeedDialChild(
            child: const Icon(Icons.insert_drive_file),
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            label: '复制文件名称',
            onTap: () =>
                copyToClipboard(context, widget.fileMap['name'] == null ? '无' : widget.fileMap['name'].toString()),
          ),
        ],
      ),
    );
  }
}
