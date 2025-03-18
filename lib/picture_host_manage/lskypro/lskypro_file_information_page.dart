import 'package:flutter/material.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/picture_host_manage/common/info_page_utils.dart';
import 'package:horopic/widgets/common_widgets.dart';
import 'package:horopic/widgets/custom_speed_dial.dart';

class LskyproFileInformation extends StatefulWidget {
  final Map fileMap;
  const LskyproFileInformation({super.key, required this.fileMap});

  @override
  LskyproFileInformationState createState() => LskyproFileInformationState();
}

class LskyproFileInformationState extends State<LskyproFileInformation> {
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
            title: '文件名',
            value: widget.fileMap['name'],
            icon: Icons.insert_drive_file,
            copyable: true,
          ),
          const Divider(height: 1, indent: 56),
          buildInfoItem(
            context: context,
            title: '原始文件名',
            value: widget.fileMap['origin_name'],
            icon: Icons.drive_file_rename_outline,
            copyable: true,
          ),
          const Divider(height: 1, indent: 56),
          buildInfoItem(
            context: context,
            title: '文件大小',
            value: getFileSize(int.parse(widget.fileMap['size'].toString().split('.')[0]) * 1024),
            icon: Icons.data_usage,
          ),
          const Divider(height: 1, indent: 56),
          buildInfoItem(
            context: context,
            title: 'MIME类型',
            value: widget.fileMap['mimetype'].toString(),
            icon: Icons.format_align_left,
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
            value: widget.fileMap['date'],
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
            title: '文件URL',
            value: widget.fileMap['links']['url'],
            icon: Icons.link,
            copyable: true,
          ),
          const Divider(height: 1, indent: 56),
          buildInfoItem(
            context: context,
            title: '缩略图URL',
            value: widget.fileMap['links']['thumbnail_url'],
            icon: Icons.image,
            copyable: true,
          ),
        ],
      ),
    ];
  }

  List<Widget> _buildSecurityInfoSection() {
    return [
      buildInfoSection(
        '安全信息',
        [
          buildInfoItem(
            context: context,
            title: '文件唯一密钥',
            value: widget.fileMap['key'],
            icon: Icons.key,
            copyable: true,
          ),
          const Divider(height: 1, indent: 56),
          buildInfoItem(
            context: context,
            title: '文件MD5',
            value: widget.fileMap['md5'],
            icon: Icons.fingerprint,
            copyable: true,
          ),
          const Divider(height: 1, indent: 56),
          buildInfoItem(
            context: context,
            title: '文件SHA1',
            value: widget.fileMap['sha1'],
            icon: Icons.enhanced_encryption,
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
          ..._buildImageInfoSection(),
          ..._buildTimeInfoSection(),
          ..._buildAccessLinksSection(),
          ..._buildSecurityInfoSection(),
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
            label: '复制文件URL',
            onTap: () => copyToClipboard(context, widget.fileMap['links']['url']),
          ),
          SpeedDialChild(
            child: const Icon(Icons.image),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            label: '复制缩略图URL',
            onTap: () => copyToClipboard(context, widget.fileMap['links']['thumbnail_url']),
          ),
          SpeedDialChild(
            child: const Icon(Icons.key),
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            label: '复制文件密钥',
            onTap: () => copyToClipboard(context, widget.fileMap['key']),
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
