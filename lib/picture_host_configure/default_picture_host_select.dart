import 'package:flutter/material.dart';
import 'package:f_logs/f_logs.dart';
import 'package:horopic/utils/event_bus_utils.dart';

import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/utils/global.dart';

class DefaultPShostSelect extends StatefulWidget {
  const DefaultPShostSelect({super.key});

  @override
  DefaultPShostSelectState createState() => DefaultPShostSelectState();
}

class DefaultPShostSelectState extends State<DefaultPShostSelect> {
  @override
  void initState() {
    super.initState();
  }

  final List<String> allPBhostToSelect = [
    'lsky.pro',
    'sm.ms',
    'github',
    'imgur',
    'qiniu',
    'tencent',
    'aliyun',
    'upyun',
    'ftp',
    'aws',
    'alist',
    'webdav',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: titleText('默认图床选择'),
      ),
      body: ListView(
        children: _buildHostTiles(),
      ),
    );
  }

  List<Widget> _buildHostTiles() {
    final hosts = [
      {'name': 'Alist V3', 'id': 'alist'},
      {'name': '阿里云', 'id': 'aliyun'},
      {'name': 'FTP-SSH/SFTP', 'id': 'ftp'},
      {'name': 'Github图床', 'id': 'github'},
      {'name': 'Imgur图床', 'id': 'imgur'},
      {'name': '兰空图床', 'id': 'lsky.pro'},
      {'name': '七牛云', 'id': 'qiniu'},
      {'name': 'S3兼容平台', 'id': 'aws'},
      {'name': 'SM.MS', 'id': 'sm.ms'},
      {'name': '腾讯云', 'id': 'tencent'},
      {'name': '又拍云', 'id': 'upyun'},
      {'name': 'WebDAV', 'id': 'webdav'},
    ];

    return hosts.map((host) {
      return ListTile(
        title: Text(host['name']!),
        trailing: Global.defaultPShost == host['id'] ? const Icon(Icons.check) : null,
        onTap: () async {
          await setdefaultPShostRemoteAndLocal(host['id']!);
          eventBus.fire(AlbumRefreshEvent(albumKeepAlive: false));
          eventBus.fire(HomePhotoRefreshEvent(homePhotoKeepAlive: false));
          setState(() {});
        },
      );
    }).toList();
  }
}

setdefaultPShostRemoteAndLocal(String psHost) async {
  try {
    await Global.setPShost(psHost);

    Map<String, String> hostMapping = {
      'lsky.pro': 'lskypro',
      'sm.ms': 'smms',
      'github': 'github',
      'imgur': 'imgur',
      'qiniu': 'qiniu',
      'tencent': 'tencent',
      'aliyun': 'aliyun',
      'upyun': 'upyun',
      'ftp': 'PBhostExtend1',
      'aws': 'PBhostExtend2',
      'alist': 'PBhostExtend3',
      'webdav': 'PBhostExtend4',
    };

    if (hostMapping.containsKey(psHost)) {
      await Global.setShowedPBhost(hostMapping[psHost]!);
    }

    showToast('已设置$psHost为默认图床');
  } catch (e) {
    FLog.error(
        className: 'setdefaultPShostRemoteAndLocal',
        methodName: 'setdefaultPShostRemoteAndLocal',
        text: formatErrorMessage({
          'psHost': psHost,
        }, e.toString()),
        dataLogType: DataLogType.ERRORS.toString());
    showToast('错误');
  }
}
