import 'package:flutter/material.dart';
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

  Widget _buildSettingCard({required String title, required List<Widget> children}) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
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
        ],
      ),
    );
  }

  Widget _buildHostItem({
    required String title,
    required String id,
    required IconData icon,
  }) {
    final bool isSelected = Global.defaultPShost == id;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color:
              isSelected ? Theme.of(context).primaryColor.withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
        ),
      ),
      title: Text(title),
      trailing: isSelected
          ? Icon(Icons.check_circle, color: Theme.of(context).primaryColor)
          : const Icon(Icons.circle_outlined, color: Colors.grey),
      onTap: () async {
        await setdefaultPShostRemoteAndLocal(id);
        eventBus.fire(AlbumRefreshEvent(albumKeepAlive: false));
        eventBus.fire(HomePhotoRefreshEvent(homePhotoKeepAlive: false));
        setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: titleText('默认图床选择'),
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
        children: [
          const SizedBox(height: 8),
          _buildSettingCard(
            title: '云存储图床',
            children: [
              _buildHostItem(
                title: '七牛云',
                id: 'qiniu',
                icon: Icons.cloud_upload,
              ),
              const Divider(height: 1, indent: 56),
              _buildHostItem(
                title: '腾讯云',
                id: 'tencent',
                icon: Icons.cloud,
              ),
              const Divider(height: 1, indent: 56),
              _buildHostItem(
                title: '阿里云',
                id: 'aliyun',
                icon: Icons.cloud_circle,
              ),
              const Divider(height: 1, indent: 56),
              _buildHostItem(
                title: '又拍云',
                id: 'upyun',
                icon: Icons.cloud_queue,
              ),
              const Divider(height: 1, indent: 56),
              _buildHostItem(
                title: 'S3兼容平台',
                id: 'aws',
                icon: Icons.all_inbox,
              ),
            ],
          ),
          _buildSettingCard(
            title: '公共图床',
            children: [
              _buildHostItem(
                title: '兰空图床',
                id: 'lsky.pro',
                icon: Icons.photo_album,
              ),
              const Divider(height: 1, indent: 56),
              _buildHostItem(
                title: 'SM.MS',
                id: 'sm.ms',
                icon: Icons.photo_library,
              ),
              const Divider(height: 1, indent: 56),
              _buildHostItem(
                title: 'Github图床',
                id: 'github',
                icon: Icons.code,
              ),
              const Divider(height: 1, indent: 56),
              _buildHostItem(
                title: 'Imgur图床',
                id: 'imgur',
                icon: Icons.image,
              ),
            ],
          ),
          _buildSettingCard(
            title: '自建图床/网盘',
            children: [
              _buildHostItem(
                title: 'Alist V3',
                id: 'alist',
                icon: Icons.folder_shared,
              ),
              const Divider(height: 1, indent: 56),
              _buildHostItem(
                title: 'FTP-SSH/SFTP',
                id: 'ftp',
                icon: Icons.storage,
              ),
              const Divider(height: 1, indent: 56),
              _buildHostItem(
                title: 'WebDAV',
                id: 'webdav',
                icon: Icons.web,
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

setdefaultPShostRemoteAndLocal(String psHost) async {
  try {
    Global.setPShost(psHost);

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
      Global.setShowedPBhost(hostMapping[psHost]!);
    }

    showToast('已设置$psHost为默认图床');
  } catch (e) {
    flogErr(
        e,
        {
          'psHost': psHost,
        },
        'setdefaultPShostRemoteAndLocal',
        'setdefaultPShostRemoteAndLocal');
    showToast('错误');
  }
}
