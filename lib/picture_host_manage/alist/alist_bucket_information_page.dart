import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:horopic/picture_host_manage/manage_api/alist_manage_api.dart';
import 'package:horopic/utils/common_functions.dart';

class AlistBucketInformation extends StatefulWidget {
  final Map bucketMap;
  
  const AlistBucketInformation({Key? key, required this.bucketMap})
      : super(key: key);

  @override
  AlistBucketInformationState createState() => AlistBucketInformationState();
}

class AlistBucketInformationState extends State<AlistBucketInformation> {
  @override
  initState() {
    super.initState();
  }

  List<ListTile> generateFromMap(Map map) {
    List<ListTile> list = [];
    map.forEach((key, value) {
      list.add(ListTile(
        title: Text(key),
        subtitle: Text(value.toString()),
      ));
    });
    return list;
  }

  List<ListTile> allListTile(Map map) {
    List<ListTile> list = [
      ListTile(
        title: const Text('id'),
        subtitle: SelectableText(widget.bucketMap['id'].toString()),
      ),
      ListTile(
        title: const Text('状态'),
        subtitle: SelectableText(widget.bucketMap['status'].toString()),
      ),
      ListTile(
        title: const Text('驱动类型'),
        subtitle: SelectableText(
            '${widget.bucketMap['driver']}(${AlistManageAPI.driverTranslate[widget.bucketMap['driver']]})'),
      ),
      ListTile(
        title: const Text('挂载目录'),
        subtitle: SelectableText(widget.bucketMap['mount_path']),
      ),
      ListTile(
        isThreeLine: true,
        title: const Text('缓存过期时间'),
        subtitle: SelectableText('${widget.bucketMap['cache_expiration']}分钟'),
      ),
      ListTile(
        title: const Text('备注'),
        subtitle: SelectableText(widget.bucketMap['remark'] == ""
            ? '无'
            : widget.bucketMap['remark']),
      ),
      ListTile(
        title: const Text('修改时间'),
        subtitle: SelectableText(widget.bucketMap['modified']
            .toString()
            .substring(0, 19)
            .replaceAll('T', ' ')),
      ),
      ListTile(
        title: const Text('是否启用'),
        subtitle: SelectableText(widget.bucketMap['disabled'] ? '否' : '是'),
      ),
      ListTile(
        title: const Text('提取文件夹'),
        subtitle: SelectableText(widget.bucketMap['extract_folder'] == ""
            ? "未设定"
            : widget.bucketMap['extract_folder'] == "front"
                ? "提取到最前"
                : "提取到最后"),
      ),
      ListTile(
        title: const Text('web代理'),
        subtitle: SelectableText(
            widget.bucketMap['web_proxy'] == true ? "启用" : "未启用"),
      ),
      ListTile(
        title: const Text('webDav策略'),
        subtitle: SelectableText(widget.bucketMap['webdav_policy']),
      ),
    ];

    map.forEach((key, value) {
      list.add(ListTile(
        title: Text(key),
        subtitle: Text(value.toString()),
      ));
    });
    return list;
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
        children: allListTile(jsonDecode(widget.bucketMap['addition'])),
      ),
    );
  }
}
