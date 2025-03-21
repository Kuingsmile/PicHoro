import 'package:flutter/material.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/widgets/common_widgets.dart';
import 'package:horopic/picture_host_manage/common/info_page_utils.dart';
import 'package:horopic/widgets/custom_speed_dial.dart';

class UpyunFileInformation extends StatefulWidget {
  final Map fileMap;
  const UpyunFileInformation({super.key, required this.fileMap});

  @override
  UpyunFileInformationState createState() => UpyunFileInformationState();
}

class UpyunFileInformationState extends State<UpyunFileInformation> {
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
            value: widget.fileMap['name'],
            icon: Icons.insert_drive_file,
            copyable: true,
          ),
          const Divider(height: 1, indent: 56),
          buildInfoItem(
            context: context,
            title: '文件大小',
            value: getFileSize(widget.fileMap['length']),
            icon: Icons.data_usage,
          ),
          const Divider(height: 1, indent: 56),
          buildInfoItem(
            context: context,
            title: 'mime类型',
            value: widget.fileMap['type'],
            icon: Icons.file_present,
            copyable: true,
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
            value: DateTime.fromMillisecondsSinceEpoch(
                    int.parse((widget.fileMap['last_modified'] * 1000).toString().split('.')[0]))
                .toString()
                .split('.')[0],
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
            value: widget.fileMap['etag'].replaceAll('"', ''),
            icon: Icons.tag,
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
        leading: getLeadingIcon(context),
        centerTitle: true,
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
            child: const Icon(Icons.content_copy),
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            label: '复制文件名称',
            onTap: () => copyToClipboard(context, widget.fileMap['name']),
          ),
          SpeedDialChild(
            child: const Icon(Icons.file_copy),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            label: '复制etag',
            onTap: () => copyToClipboard(context, widget.fileMap['etag'].replaceAll('"', '')),
          ),
          SpeedDialChild(
            child: const Icon(Icons.file_present),
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            label: '复制mime类型',
            onTap: () => copyToClipboard(context, widget.fileMap['type']),
          ),
        ],
      ),
    );
  }
}
