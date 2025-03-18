import 'package:flutter/material.dart';

import 'package:horopic/picture_host_manage/common/info_page_utils.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/picture_host_manage/manage_api/alist_manage_api.dart';
import 'package:horopic/widgets/common_widgets.dart';
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
            value: widget.fileMap['modified'].toString().substring(0, 19),
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
            title: '文件签名',
            value: widget.fileMap['sign'].toString(),
            icon: Icons.verified,
            copyable: true,
          ),
          const Divider(height: 1, indent: 56),
          buildInfoItem(
            context: context,
            title: '缩略图链接',
            value: widget.fileMap['thumb'].toString(),
            icon: Icons.image,
            copyable: true,
          ),
          const Divider(height: 1, indent: 56),
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

  getcompleteInformation() async {
    Map fileMap = widget.fileMap;
    var res = await AlistManageAPI().getFileInfo(fileMap['fullPath']);
    if (res[0] == 'success') {
      setState(() {
        rawUrl = res[1]['raw_url'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(elevation: 0, centerTitle: true, title: titleText('文件基本信息'), flexibleSpace: getFlexibleSpace(context)),
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
            onTap: () => copyToClipboard(context, rawUrl),
          ),
          SpeedDialChild(
            child: const Icon(Icons.image),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            label: '复制缩略图链接',
            onTap: () => copyToClipboard(context, widget.fileMap['thumb'].toString()),
          ),
          SpeedDialChild(
            child: const Icon(Icons.verified),
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            label: '复制文件签名',
            onTap: () => copyToClipboard(context, widget.fileMap['sign'].toString()),
          ),
          SpeedDialChild(
            child: const Icon(Icons.insert_drive_file),
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            label: '复制文件名称',
            onTap: () => copyToClipboard(context, widget.fileMap['name']),
          ),
        ],
      ),
    );
  }
}
