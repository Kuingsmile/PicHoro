import 'package:flutter/material.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/widgets/common_widgets.dart';
import 'package:horopic/picture_host_manage/common/info_page_utils.dart';
import 'package:horopic/widgets/custom_speed_dial.dart';

class TencentFileInformation extends StatefulWidget {
  final Map fileMap;
  const TencentFileInformation({super.key, required this.fileMap});

  @override
  TencentFileInformationState createState() => TencentFileInformationState();
}

class TencentFileInformationState extends State<TencentFileInformation> {
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
            value: widget.fileMap['Key'].split('/').last,
            icon: Icons.insert_drive_file,
            copyable: true,
          ),
          const Divider(height: 1, indent: 56),
          buildInfoItem(
            context: context,
            title: '文件大小',
            value: getFileSize(int.parse(widget.fileMap['Size'])),
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
            value: widget.fileMap['LastModified'].toString().substring(0, 19),
            icon: Icons.access_time,
          ),
        ],
      ),
    ];
  }

  List<Widget> _buildAdditionalInfoSection() {
    return [
      buildInfoSection(
        '其他信息',
        [
          buildInfoItem(
            context: context,
            title: '文件etag',
            value: widget.fileMap['ETag'].replaceAll('"', ''),
            icon: Icons.verified,
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
          ..._buildAdditionalInfoSection(),
          const SizedBox(height: 16),
        ],
      ),
      floatingActionButton: SpeedDial(
        icon: Icons.more_vert,
        activeIcon: Icons.close,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.verified),
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            label: '复制文件etag',
            onTap: () => copyToClipboard(context, widget.fileMap['ETag'].replaceAll('"', '')),
          ),
          SpeedDialChild(
            child: const Icon(Icons.insert_drive_file),
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            label: '复制文件名称',
            onTap: () => copyToClipboard(context, widget.fileMap['Key'].split('/').last),
          ),
        ],
      ),
    );
  }
}
