import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:horopic/picture_host_manage/manage_api/alist_manage_api.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/widgets/custom_speed_dial.dart';

class AlistBucketInformation extends StatefulWidget {
  final Map bucketMap;

  const AlistBucketInformation({super.key, required this.bucketMap});

  @override
  AlistBucketInformationState createState() => AlistBucketInformationState();
}

class AlistBucketInformationState extends State<AlistBucketInformation> {
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
            title: 'ID',
            value: widget.bucketMap['id'].toString(),
            icon: Icons.perm_identity,
            copyable: true,
          ),
          const Divider(height: 1, indent: 56),
          _buildInfoItem(
            title: '状态',
            value: widget.bucketMap['status'].toString(),
            icon: Icons.info_outline,
          ),
          const Divider(height: 1, indent: 56),
          _buildInfoItem(
            title: '驱动类型',
            value:
                '${widget.bucketMap['driver']}(${AlistManageAPI.driverTranslate[widget.bucketMap['driver']] ?? widget.bucketMap['driver']})',
            icon: Icons.drive_folder_upload,
          ),
          const Divider(height: 1, indent: 56),
          _buildInfoItem(
            title: '挂载目录',
            value: widget.bucketMap['mount_path'],
            icon: Icons.folder,
            copyable: true,
          ),
          const Divider(height: 1, indent: 56),
          _buildInfoItem(
            title: '缓存过期时间',
            value: '${widget.bucketMap['cache_expiration']}分钟',
            icon: Icons.access_time,
          ),
          const Divider(height: 1, indent: 56),
          _buildInfoItem(
            title: '备注',
            value: widget.bucketMap['remark'] == "" ? '无' : widget.bucketMap['remark'],
            icon: Icons.note,
          ),
        ],
      ),
    ];
  }

  List<Widget> _buildConfigurationSection() {
    return [
      _buildInfoSection(
        '配置信息',
        [
          _buildInfoItem(
            title: '修改时间',
            value: widget.bucketMap['modified'].toString().substring(0, 19).replaceAll('T', ' '),
            icon: Icons.update,
          ),
          const Divider(height: 1, indent: 56),
          _buildInfoItem(
            title: '是否启用',
            value: widget.bucketMap['disabled'] ? '否' : '是',
            icon: Icons.toggle_on,
          ),
          const Divider(height: 1, indent: 56),
          _buildInfoItem(
            title: '提取文件夹',
            value: widget.bucketMap['extract_folder'] == ""
                ? "未设定"
                : widget.bucketMap['extract_folder'] == "front"
                    ? "提取到最前"
                    : "提取到最后",
            icon: Icons.folder_open,
          ),
          const Divider(height: 1, indent: 56),
          _buildInfoItem(
            title: 'Web代理',
            value: widget.bucketMap['web_proxy'] == true ? "启用" : "未启用",
            icon: Icons.language,
          ),
          const Divider(height: 1, indent: 56),
          _buildInfoItem(
            title: 'WebDav策略',
            value: widget.bucketMap['webdav_policy'],
            icon: Icons.policy,
          ),
        ],
      ),
    ];
  }

  List<Widget> _buildAdditionalInfoSection() {
    Map additionalInfo = jsonDecode(widget.bucketMap['addition']);
    List<Widget> widgets = [];

    if (additionalInfo.isNotEmpty) {
      List<Widget> additionalItems = [];
      int index = 0;

      additionalInfo.forEach((key, value) {
        additionalItems.add(
          _buildInfoItem(
            title: key.toString(),
            value: value.toString(),
            icon: Icons.settings,
            copyable: true,
          ),
        );

        // Add divider between items except the last one
        if (index < additionalInfo.length - 1) {
          additionalItems.add(const Divider(height: 1, indent: 56));
        }
        index++;
      });

      widgets.add(_buildInfoSection('附加信息', additionalItems));
    }

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: titleText('存储信息详情'),
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
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          ..._buildBasicInfoSection(),
          ..._buildConfigurationSection(),
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
            label: '复制挂载目录',
            onTap: () => _copyToClipboard(widget.bucketMap['mount_path']),
          ),
          SpeedDialChild(
            child: const Icon(Icons.share),
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            label: '分享存储配置',
            onTap: () {
              // Extract essential information
              final shareInfo = {
                'driver': widget.bucketMap['driver'],
                'mount_path': widget.bucketMap['mount_path'],
                'cache_expiration': widget.bucketMap['cache_expiration'],
                'modified': widget.bucketMap['modified'],
              };
              _copyToClipboard(json.encode(shareInfo));
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.refresh),
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            label: '复制添加信息',
            onTap: () => _copyToClipboard(widget.bucketMap['addition']),
          ),
          SpeedDialChild(
            child: const Icon(Icons.info),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            label: '复制存储ID',
            onTap: () => _copyToClipboard(widget.bucketMap['id'].toString()),
          ),
        ],
      ),
    );
  }
}
