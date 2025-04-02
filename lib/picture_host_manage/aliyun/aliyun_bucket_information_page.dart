import 'package:flutter/material.dart';
import 'package:horopic/picture_host_manage/manage_api/aliyun_manage_api.dart';
import 'package:horopic/picture_host_manage/common/info_page_utils.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/widgets/common_widgets.dart';
import 'package:horopic/widgets/custom_speed_dial.dart';

class AliyunBucketInformation extends StatefulWidget {
  final Map bucketMap;
  const AliyunBucketInformation({super.key, required this.bucketMap});

  @override
  AliyunBucketInformationState createState() => AliyunBucketInformationState();
}

class AliyunBucketInformationState extends State<AliyunBucketInformation> {
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
            value: widget.bucketMap['name'],
            icon: Icons.storage,
            copyable: true,
          ),
          const Divider(height: 1, indent: 56),
          buildInfoItem(
            context: context,
            title: '所属地域',
            value: '${widget.bucketMap['location']}(${AliyunManageAPI().areaCodeName[widget.bucketMap['location']]})',
            icon: Icons.location_on,
          ),
          const Divider(height: 1, indent: 56),
          buildInfoItem(
            context: context,
            title: '创建时间',
            value: widget.bucketMap['CreationDate'].substring(0, 19),
            icon: Icons.calendar_today,
          ),
          const Divider(height: 1, indent: 56),
          buildInfoItem(
            context: context,
            title: '访问域名',
            value: 'https://${widget.bucketMap['name']}.${widget.bucketMap['location']}.aliyuncs.com',
            icon: Icons.language,
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
        title: titleText('基本信息'),
        flexibleSpace: getFlexibleSpace(context),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          ..._buildBasicInfoSection(),
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
            onTap: () => copyToClipboard(context, widget.bucketMap['name']),
          ),
          SpeedDialChild(
            child: const Icon(Icons.language),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            label: '复制访问域名',
            onTap: () => copyToClipboard(
                context, 'https://${widget.bucketMap['name']}.${widget.bucketMap['location']}.aliyuncs.com'),
          ),
        ],
      ),
    );
  }
}
