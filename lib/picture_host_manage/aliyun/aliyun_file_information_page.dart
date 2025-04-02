import 'package:flutter/material.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/widgets/common_widgets.dart';
import 'package:horopic/picture_host_manage/common/info_page_utils.dart';
import 'package:horopic/widgets/custom_speed_dial.dart';

class AliyunFileInformation extends StatefulWidget {
  final Map fileMap;
  const AliyunFileInformation({super.key, required this.fileMap});

  @override
  AliyunFileInformationState createState() => AliyunFileInformationState();
}

class AliyunFileInformationState extends State<AliyunFileInformation> {
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

  List<Widget> _buildIdentifierSection() {
    return [
      buildInfoSection(
        '文件标识',
        [
          buildInfoItem(
            context: context,
            title: '文件etag',
            value: widget.fileMap['ETag'].replaceAll('"', ''),
            icon: Icons.fingerprint,
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
          ..._buildIdentifierSection(),
          const SizedBox(height: 16),
        ],
      ),
      floatingActionButton: SpeedDial(
        icon: Icons.more_vert,
        activeIcon: Icons.close,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.insert_drive_file),
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            label: '复制文件名称',
            onTap: () => copyToClipboard(context, widget.fileMap['Key'].split('/').last),
          ),
          SpeedDialChild(
            child: const Icon(Icons.fingerprint),
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            label: '复制文件etag',
            onTap: () => copyToClipboard(context, widget.fileMap['ETag'].replaceAll('"', '')),
          ),
        ],
      ),
    );
  }
}
