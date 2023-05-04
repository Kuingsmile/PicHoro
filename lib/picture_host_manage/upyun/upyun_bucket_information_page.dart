import 'package:flutter/material.dart';
import 'package:horopic/picture_host_manage/manage_api/upyun_manage_api.dart';
import 'package:horopic/utils/common_functions.dart';

class UpyunBucketInformation extends StatefulWidget {
  final Map bucketMap;
  const UpyunBucketInformation({Key? key, required this.bucketMap}) : super(key: key);

  @override
  UpyunBucketInformationState createState() => UpyunBucketInformationState();
}

class UpyunBucketInformationState extends State<UpyunBucketInformation> {
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
        title: titleText('基本信息'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('存储桶名称'),
            trailing: SelectableText(widget.bucketMap['bucket_name'].toString()),
          ),
          ListTile(
            title: const Text('存储桶ID'),
            trailing: SelectableText(widget.bucketMap['bucket_id'].toString()),
          ),
          ListTile(
            title: const Text('创建时间'),
            trailing: SelectableText(widget.bucketMap['CreationDate']),
          ),
          ListTile(
            title: const Text('HTTPS'),
            trailing: SelectableText(widget.bucketMap['https'] == false ? '关闭' : '开启'),
          ),
          ListTile(
            title: const Text('缩略图版本分隔符'),
            trailing: SelectableText(widget.bucketMap['separator']),
          ),
          ListTile(
            title: const Text('标签'),
            trailing:
                SelectableText('${widget.bucketMap['tag']}(${UpyunManageAPI.tagConvert[widget.bucketMap['tag']]})'),
          ),
          ListTile(
            title: const Text('状态'),
            trailing: SelectableText(widget.bucketMap['status']),
          ),
          ListTile(
            title: const Text('访问域名'),
            subtitle:
                SelectableText(widget.bucketMap['domains'] == null ? '无' : widget.bucketMap['domains'].toString()),
          ),
          ListTile(
            title: const Text('操作员'),
            subtitle: SelectableText(widget.bucketMap['operator'].toString() == '[]'
                ? '无'
                : widget.bucketMap['operator']
                    .toString()
                    .substring(1, widget.bucketMap['operator'].toString().length - 1)),
          ),
        ],
      ),
    );
  }
}
