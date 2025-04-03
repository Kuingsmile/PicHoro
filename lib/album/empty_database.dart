import 'package:flutter/material.dart';

import 'package:horopic/album/album_sql.dart';
import 'package:horopic/utils/global.dart';
import 'package:horopic/utils/event_bus_utils.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/widgets/common_widgets.dart';

class EmptyDatabase extends StatefulWidget {
  const EmptyDatabase({super.key});

  @override
  EmptyDatabaseState createState() => EmptyDatabaseState();
}

class EmptyDatabaseState extends State<EmptyDatabase> {
  // Database structure definition
  final List<Map<String, dynamic>> _databaseGroups = [
    {
      'title': '主要图床',
      'options': [
        {'name': '兰空', 'table': 'lskypro', 'icon': Icons.delete_outline},
        {'name': 'SM.MS', 'table': 'smms', 'icon': Icons.delete_outline},
        {'name': 'Github', 'table': 'github', 'icon': Icons.delete_outline},
        {'name': 'Imgur', 'table': 'imgur', 'icon': Icons.delete_outline},
        {'name': '七牛云', 'table': 'qiniu', 'icon': Icons.delete_outline},
        {'name': '腾讯云', 'table': 'tencent', 'icon': Icons.delete_outline},
        {'name': '阿里云', 'table': 'aliyun', 'icon': Icons.delete_outline},
        {'name': '又拍云', 'table': 'upyun', 'icon': Icons.delete_outline},
      ],
      'isExtended': false,
    },
    {
      'title': '扩展存储',
      'options': [
        {'name': 'FTP', 'table': 'PBhostExtend1', 'icon': Icons.storage},
        {'name': 'S3兼容平台', 'table': 'PBhostExtend2', 'icon': Icons.cloud_outlined},
        {'name': 'AList V3', 'table': 'PBhostExtend3', 'icon': Icons.view_list_outlined},
        {'name': 'WebDAV', 'table': 'PBhostExtend4', 'icon': Icons.web_outlined},
      ],
      'isExtended': true,
    },
    {
      'title': '全部数据',
      'options': [
        {'name': '清空所有数据库', 'table': 'all', 'icon': Icons.delete_forever},
      ],
      'isExtended': false,
    },
  ];

  // Clear a specific table
  Future<void> _clearTable(String table, String name, bool isExtended) async {
    if (table == 'all') {
      await AlbumSQL.emptyAllTable(Global.imageDB!);
      await AlbumSQL.emptyAllTableExtend(Global.imageDBExtend!);
    } else {
      await AlbumSQL.deleteTable(isExtended ? Global.imageDBExtend! : Global.imageDB!, table);
    }
    showToast('已清空${name == '清空所有数据库' ? '所有' : name}数据库');
    eventBus.fire(AlbumRefreshEvent(albumKeepAlive: false));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        leading: getLeadingIcon(context),
        title: titleText('选择需要清空的数据库'),
        flexibleSpace: getFlexibleSpace(context),
      ),
      body: ListView.builder(
        physics: const BouncingScrollPhysics(),
        itemCount: _databaseGroups.length + 1, // +1 for bottom padding
        itemBuilder: (context, index) {
          if (index == _databaseGroups.length) {
            return const SizedBox(height: 24);
          }

          final group = _databaseGroups[index];
          final options = group['options'] as List<Map<String, dynamic>>;
          final bool isExtended = group['isExtended'] as bool;

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
                    group['title'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ...List.generate(options.length * 2 - 1, (i) {
                  // For dividers
                  if (i.isOdd) return const Divider(height: 1, indent: 56);

                  // For list tiles
                  final optionIndex = i ~/ 2;
                  final option = options[optionIndex];

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        option['icon'],
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    title: Text(option['name']),
                    onTap: () {
                      showCupertinoAlertDialogWithConfirmFunc(
                        title: '通知',
                        content: '是否确定清空${option['name']}数据库？',
                        context: context,
                        onConfirm: () => _clearTable(option['table'], option['name'], isExtended),
                      );
                    },
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}
