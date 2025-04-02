import 'package:flutter/material.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/widgets/common_widgets.dart';
import 'package:horopic/picture_host_manage/common/info_page_utils.dart';
import 'package:horopic/widgets/custom_speed_dial.dart';

class QiniuFileInformation extends StatefulWidget {
  final Map fileMap;
  const QiniuFileInformation({super.key, required this.fileMap});

  @override
  QiniuFileInformationState createState() => QiniuFileInformationState();
}

class QiniuFileInformationState extends State<QiniuFileInformation> {
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
            value: widget.fileMap['key'].split('/').last,
            icon: Icons.insert_drive_file,
            copyable: true,
          ),
          const Divider(height: 1, indent: 56),
          buildInfoItem(
            context: context,
            title: '文件大小',
            value: getFileSize(widget.fileMap['fsize']),
            icon: Icons.data_usage,
          ),
          const Divider(height: 1, indent: 56),
          buildInfoItem(
            context: context,
            title: 'mime类型',
            value: widget.fileMap['mimeType'],
            icon: Icons.description,
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
            value: DateTime.fromMillisecondsSinceEpoch(int.parse((widget.fileMap['putTime']).toString().split('.')[0]))
                .toString()
                .split('.')[0],
            icon: Icons.access_time,
          ),
        ],
      ),
    ];
  }

  List<Widget> _buildHashInfoSection() {
    return [
      buildInfoSection(
        '文件哈希信息',
        [
          buildInfoItem(
            context: context,
            title: '文件hash',
            value: widget.fileMap['hash'],
            icon: Icons.tag,
            copyable: true,
          ),
          const Divider(height: 1, indent: 56),
          buildInfoItem(
            context: context,
            title: '文件md5',
            value: widget.fileMap['md5'],
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
          ..._buildHashInfoSection(),
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
            onTap: () => copyToClipboard(context, widget.fileMap['key'].split('/').last),
          ),
          SpeedDialChild(
            child: const Icon(Icons.fingerprint),
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            label: '复制文件md5',
            onTap: () => copyToClipboard(context, widget.fileMap['md5']),
          ),
          SpeedDialChild(
            child: const Icon(Icons.tag),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            label: '复制文件hash',
            onTap: () => copyToClipboard(context, widget.fileMap['hash']),
          ),
        ],
      ),
    );
  }
}
