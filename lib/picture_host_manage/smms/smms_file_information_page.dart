import 'package:flutter/material.dart';

import 'package:horopic/picture_host_manage/common/info_page_utils.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/widgets/common_widgets.dart';
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

  List<Widget> _buildBasicInfoSection() {
    return [
      buildInfoSection(
        '基本信息',
        [
          buildInfoItem(
            context: context,
            title: '文件名称',
            value: widget.fileMap['filename'],
            icon: Icons.insert_drive_file,
            copyable: true,
          ),
          const Divider(height: 1, indent: 56),
          buildInfoItem(
            context: context,
            title: '文件存储名',
            value: widget.fileMap['storename'],
            icon: Icons.storage,
            copyable: true,
          ),
          const Divider(height: 1, indent: 56),
          buildInfoItem(
            context: context,
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
      buildInfoSection(
        '图像属性',
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
            value: widget.fileMap['created_at'],
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
            title: '文件页面',
            value: widget.fileMap['page'],
            icon: Icons.web,
            copyable: true,
          ),
          const Divider(height: 1, indent: 56),
          buildInfoItem(
            context: context,
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
        flexibleSpace: getFlexibleSpace(context),
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
            onTap: () => copyToClipboard(context, widget.fileMap['url']),
          ),
          SpeedDialChild(
            child: const Icon(Icons.file_copy),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            label: '复制文件名称',
            onTap: () => copyToClipboard(context, widget.fileMap['filename']),
          ),
          SpeedDialChild(
            child: const Icon(Icons.web),
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            label: '复制文件页面链接',
            onTap: () => copyToClipboard(context, widget.fileMap['page']),
          ),
          SpeedDialChild(
            child: const Icon(Icons.storage),
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            label: '复制存储名',
            onTap: () => copyToClipboard(context, widget.fileMap['storename']),
          ),
        ],
      ),
    );
  }
}
