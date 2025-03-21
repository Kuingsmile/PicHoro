import 'package:flutter/material.dart';
import 'package:horopic/picture_host_manage/manage_api/upyun_manage_api.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/widgets/common_widgets.dart';
import 'package:horopic/picture_host_manage/common/info_page_utils.dart';
import 'package:horopic/widgets/custom_speed_dial.dart';

class UpyunBucketInformation extends StatefulWidget {
  final Map bucketMap;
  const UpyunBucketInformation({super.key, required this.bucketMap});

  @override
  UpyunBucketInformationState createState() => UpyunBucketInformationState();
}

class UpyunBucketInformationState extends State<UpyunBucketInformation> {
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
            title: '存储桶名称',
            value: widget.bucketMap['bucket_name'].toString(),
            icon: Icons.folder,
            copyable: true,
          ),
          const Divider(height: 1, indent: 56),
          buildInfoItem(
            context: context,
            title: '存储桶ID',
            value: widget.bucketMap['bucket_id'].toString(),
            icon: Icons.perm_identity,
            copyable: true,
          ),
          const Divider(height: 1, indent: 56),
          buildInfoItem(
            context: context,
            title: '创建时间',
            value: widget.bucketMap['CreationDate'],
            icon: Icons.calendar_today,
          ),
          const Divider(height: 1, indent: 56),
          buildInfoItem(
            context: context,
            title: '状态',
            value: widget.bucketMap['status'],
            icon: Icons.info_outline,
          ),
        ],
      ),
    ];
  }

  List<Widget> _buildConfigurationSection() {
    return [
      buildInfoSection(
        '配置信息',
        [
          buildInfoItem(
            context: context,
            title: 'HTTPS',
            value: widget.bucketMap['https'] == false ? '关闭' : '开启',
            icon: Icons.security,
          ),
          const Divider(height: 1, indent: 56),
          buildInfoItem(
            context: context,
            title: '缩略图版本分隔符',
            value: widget.bucketMap['separator'],
            icon: Icons.text_format,
            copyable: true,
          ),
          const Divider(height: 1, indent: 56),
          buildInfoItem(
            context: context,
            title: '标签',
            value: '${widget.bucketMap['tag']}(${UpyunManageAPI.tagConvert[widget.bucketMap['tag']]})',
            icon: Icons.label,
          ),
        ],
      ),
    ];
  }

  List<Widget> _buildDomainSection() {
    return [
      buildInfoSection(
        '域名信息',
        [
          buildInfoItem(
            context: context,
            title: '访问域名',
            value: widget.bucketMap['domains'] == null ? '无' : widget.bucketMap['domains'].toString(),
            icon: Icons.language,
            copyable: widget.bucketMap['domains'] != null,
          ),
        ],
      ),
    ];
  }

  List<Widget> _buildOperatorSection() {
    return [
      buildInfoSection(
        '操作员信息',
        [
          buildInfoItem(
            context: context,
            title: '操作员',
            value: widget.bucketMap['operator'].toString() == '[]'
                ? '无'
                : widget.bucketMap['operator']
                    .toString()
                    .substring(1, widget.bucketMap['operator'].toString().length - 1),
            icon: Icons.person,
            copyable: widget.bucketMap['operator'].toString() != '[]',
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
        title: titleText('存储桶信息详情'),
        flexibleSpace: getFlexibleSpace(context),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          ..._buildBasicInfoSection(),
          ..._buildConfigurationSection(),
          ..._buildDomainSection(),
          ..._buildOperatorSection(),
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
            label: '复制存储桶名称',
            onTap: () => copyToClipboard(context, widget.bucketMap['bucket_name'].toString()),
          ),
          SpeedDialChild(
            child: const Icon(Icons.share),
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            label: '复制域名信息',
            onTap: () {
              if (widget.bucketMap['domains'] != null) {
                copyToClipboard(context, widget.bucketMap['domains'].toString());
              } else {
                showToast('无域名信息可复制');
              }
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.info),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            label: '复制存储桶ID',
            onTap: () => copyToClipboard(context, widget.bucketMap['bucket_id'].toString()),
          ),
        ],
      ),
    );
  }
}
