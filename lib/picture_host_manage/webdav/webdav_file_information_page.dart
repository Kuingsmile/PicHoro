import 'package:flutter/material.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/widgets/common_widgets.dart';
import 'package:horopic/picture_host_manage/common/info_page_utils.dart';
import 'package:horopic/widgets/custom_speed_dial.dart';

class WebdavFileInformation extends StatefulWidget {
  final Map fileMap;
  const WebdavFileInformation({super.key, required this.fileMap});

  @override
  WebdavFileInformationState createState() => WebdavFileInformationState();
}

class WebdavFileInformationState extends State<WebdavFileInformation> {
  String rawUrl = '';

  @override
  initState() {
    super.initState();
    // Initialize the raw URL from the file map
    if (widget.fileMap.containsKey('rawUrl')) {
      rawUrl = widget.fileMap['rawUrl'].toString();
    }
  }

  List<Widget> _buildBasicInfoSection() {
    return [
      buildInfoSection(
        '基本信息',
        [
          buildInfoItem(
            context: context,
            title: '文件名称',
            value: widget.fileMap['name'],
            icon: Icons.insert_drive_file,
            copyable: true,
          ),
          const Divider(height: 1, indent: 56),
          buildInfoItem(
            context: context,
            title: '文件大小',
            value: getFileSize(int.parse(widget.fileMap['size'].toString())),
            icon: Icons.data_usage,
          ),
          const Divider(height: 1, indent: 56),
          buildInfoItem(
            context: context,
            title: '文件类型',
            value: widget.fileMap['mimeType'] == null ? '未知' : widget.fileMap['mimeType'].toString(),
            icon: Icons.description,
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
            value: widget.fileMap['mTime'] == null ? '未知' : widget.fileMap['mTime'].toString().substring(0, 19),
            icon: Icons.access_time,
          ),
        ],
      ),
    ];
  }

  List<Widget> _buildFileDetailsSection() {
    return [
      buildInfoSection(
        '文件详情',
        [
          if (widget.fileMap['eTag'] != null)
            buildInfoItem(
              context: context,
              title: '文件eTag',
              value: widget.fileMap['eTag'].toString().replaceAll('"', ''),
              icon: Icons.tag,
              copyable: true,
            ),
          if (widget.fileMap['eTag'] != null) const Divider(height: 1, indent: 56),
          buildInfoItem(
            context: context,
            title: '原始文件链接',
            value: rawUrl,
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
        leading: getLeadingIcon(context),
        title: titleText('文件基本信息'),
        flexibleSpace: getFlexibleSpace(context),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        children: [
          ..._buildBasicInfoSection(),
          ..._buildTimeInfoSection(),
          ..._buildFileDetailsSection(),
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
            onTap: () => copyToClipboard(context, rawUrl),
          ),
          SpeedDialChild(
            child: const Icon(Icons.insert_drive_file),
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            label: '复制文件名称',
            onTap: () => copyToClipboard(context, widget.fileMap['name']),
          ),
          if (widget.fileMap['eTag'] != null)
            SpeedDialChild(
              child: const Icon(Icons.tag),
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              label: '复制文件eTag',
              onTap: () => copyToClipboard(context, widget.fileMap['eTag'].toString().replaceAll('"', '')),
            ),
        ],
      ),
    );
  }
}
