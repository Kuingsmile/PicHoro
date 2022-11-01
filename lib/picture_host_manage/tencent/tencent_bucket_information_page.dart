import 'package:flutter/material.dart';
import 'package:horopic/picture_host_manage/manage_api/tencent_manage_api.dart';

class BucketInformation extends StatefulWidget {
  final Map bucketMap;
  const BucketInformation({Key? key, required this.bucketMap})
      : super(key: key);

  @override
  BucketInformationState createState() => BucketInformationState();
}

class BucketInformationState extends State<BucketInformation> {
  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text('基本信息'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('存储桶名称'),
            subtitle: SelectableText(widget.bucketMap['name']),
          ),
          ListTile(
            title: const Text('所属地域'),
            subtitle: SelectableText(
                '${widget.bucketMap['location']}(${TencentManageAPI.areaCodeName[widget.bucketMap['location']]})'),
          ),
          ListTile(
            title: const Text('创建时间'),
            subtitle: SelectableText(
                widget.bucketMap['CreationDate'].substring(0, 19)),
          ),
          ListTile(
            isThreeLine: true,
            title: const Text('访问域名'),
            subtitle: SelectableText(
                'https://${widget.bucketMap['name']}.cos.${widget.bucketMap['location']}.myqcloud.com'),
          ),
        ],
      ),
    );
  }
}
