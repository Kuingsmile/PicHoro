import 'package:flutter/material.dart';
import 'package:horopic/PShostFileManage/manageAPI/tencentManage.dart';

class BucketInformation extends StatefulWidget {
  final Map bucketMap;
  BucketInformation({Key? key, required this.bucketMap}) : super(key: key);

  @override
  _BucketInformationState createState() => _BucketInformationState();
}

class _BucketInformationState extends State<BucketInformation> {
  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('基本信息'),
      ),
      body: ListView(
        children: [
      ListTile(
        title: const Text('存储桶名称'),
        subtitle: Text(widget.bucketMap['name']),
      ),
      ListTile(
        title: const Text('所属地域'),
        subtitle: Text(
            '${widget.bucketMap['location']}(${TencentManageAPI.areaCodeName[widget.bucketMap['location']]})'),
      ),
      ListTile(
        title: const Text('创建时间'),
        subtitle: Text(widget.bucketMap['CreationDate']),
      ),
      ListTile(
        isThreeLine: true,
        title: const Text('访问域名'),
        subtitle: Text(
            'https://${widget.bucketMap['name']}.cos.${widget.bucketMap['location']}.myqcloud.com'),
      ),
        ],
      ),
    );
  }
}
