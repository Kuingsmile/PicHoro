import 'package:flutter/material.dart';
import 'package:horopic/picture_host_manage/manage_api/tencent_manage_api.dart';
import 'package:horopic/picture_host_manage/common/info_page_utils.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/widgets/common_widgets.dart';
import 'package:horopic/widgets/custom_speed_dial.dart';

class BucketInformation extends StatefulWidget {
  final Map bucketMap;
  const BucketInformation({super.key, required this.bucketMap});

  @override
  BucketInformationState createState() => BucketInformationState();
}

class BucketInformationState extends State<BucketInformation> {
  @override
  initState() {
    super.initState();
  }

  List<Widget> _buildBasicInfoSection() {
    String accessDomain = 'https://${widget.bucketMap['name']}.cos.${widget.bucketMap['location']}.myqcloud.com';
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
            value: '${widget.bucketMap['location']}(${TencentManageAPI.areaCodeName[widget.bucketMap['location']]})',
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
            value: accessDomain,
            icon: Icons.link,
            copyable: true,
          ),
        ],
      ),
    ];
  }

  List<Widget> _buildAdditionalInfoSection() {
    List<Widget> additionalItems = [];

    if (additionalItems.isEmpty) {
      return [];
    }

    return [buildInfoSection('附加信息', additionalItems)];
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
            label: '复制存储桶名称',
            onTap: () => copyToClipboard(context, widget.bucketMap['name']),
          ),
          SpeedDialChild(
            child: const Icon(Icons.link),
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            label: '复制访问域名',
            onTap: () => copyToClipboard(
                context, 'https://${widget.bucketMap['name']}.cos.${widget.bucketMap['location']}.myqcloud.com'),
          ),
          SpeedDialChild(
            child: const Icon(Icons.location_on),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            label: '复制地域信息',
            onTap: () => copyToClipboard(context,
                '${widget.bucketMap['location']}(${TencentManageAPI.areaCodeName[widget.bucketMap['location']]})'),
          ),
        ],
      ),
    );
  }
}
