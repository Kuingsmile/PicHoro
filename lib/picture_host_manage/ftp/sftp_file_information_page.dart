import 'package:flutter/material.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/widgets/common_widgets.dart';
import 'package:horopic/picture_host_manage/common/info_page_utils.dart';
import 'package:horopic/widgets/custom_speed_dial.dart';

class SFTPFileInformation extends StatefulWidget {
  final Map fileMap;
  const SFTPFileInformation({super.key, required this.fileMap});

  @override
  SFTPFileInformationState createState() => SFTPFileInformationState();
}

class SFTPFileInformationState extends State<SFTPFileInformation> {
  @override
  initState() {
    super.initState();
  }

  String permissionTranslate(String permission) {
    String result = '';
    if (permission.contains('r')) {
      result += '可读 ';
    }
    if (permission.contains('w')) {
      result += '可写 ';
    }
    if (permission.contains('x')) {
      result += '可执行';
    }
    if (result == '') {
      result = '无权限';
    }
    return result;
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

  List<Widget> _buildOwnershipSection() {
    return [
      buildInfoSection(
        '所有权信息',
        [
          buildInfoItem(
            context: context,
            title: '文件所有者',
            value: widget.fileMap['owner'],
            icon: Icons.person,
          ),
          const Divider(height: 1, indent: 56),
          buildInfoItem(
            context: context,
            title: '文件所属组',
            value: widget.fileMap['group'],
            icon: Icons.group,
          ),
        ],
      ),
    ];
  }

  List<Widget> _buildPermissionsSection() {
    return [
      buildInfoSection(
        '权限信息',
        [
          buildInfoItem(
            context: context,
            title: '文件所有者权限',
            value: permissionTranslate(widget.fileMap['permissions'].substring(1, 4)),
            icon: Icons.security,
          ),
          const Divider(height: 1, indent: 56),
          buildInfoItem(
            context: context,
            title: '文件所属组权限',
            value: permissionTranslate(widget.fileMap['permissions'].substring(4, 7)),
            icon: Icons.admin_panel_settings,
          ),
          const Divider(height: 1, indent: 56),
          buildInfoItem(
            context: context,
            title: '其他用户权限',
            value: permissionTranslate(widget.fileMap['permissions'].substring(7, 10)),
            icon: Icons.public,
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
            title: '文件最后修改时间',
            value: DateTime.fromMillisecondsSinceEpoch(widget.fileMap['mtime'] * 1000).toString().substring(0, 19),
            icon: Icons.edit_calendar,
          ),
          const Divider(height: 1, indent: 56),
          buildInfoItem(
            context: context,
            title: '文件最后访问时间',
            value: DateTime.fromMillisecondsSinceEpoch(widget.fileMap['atime'] * 1000).toString().substring(0, 19),
            icon: Icons.access_time,
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
          ..._buildOwnershipSection(),
          ..._buildPermissionsSection(),
          ..._buildTimeInfoSection(),
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
            onTap: () => copyToClipboard(context, widget.fileMap['name']),
          ),
          SpeedDialChild(
            child: const Icon(Icons.person),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            label: '复制文件所有者',
            onTap: () => copyToClipboard(context, widget.fileMap['owner']),
          ),
          SpeedDialChild(
            child: const Icon(Icons.group),
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            label: '复制文件所属组',
            onTap: () => copyToClipboard(context, widget.fileMap['group']),
          ),
          SpeedDialChild(
            child: const Icon(Icons.data_usage),
            backgroundColor: Colors.purple,
            foregroundColor: Colors.white,
            label: '复制文件大小',
            onTap: () => copyToClipboard(context, getFileSize(int.parse(widget.fileMap['size'].toString()))),
          ),
        ],
      ),
    );
  }
}
