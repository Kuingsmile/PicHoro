import 'package:flutter/material.dart';

import 'package:horopic/album/album_sql.dart';
import 'package:horopic/utils/global.dart';
import 'package:horopic/utils/event_bus_utils.dart';
import 'package:horopic/utils/common_functions.dart';

class EmptyDatabase extends StatefulWidget {
  const EmptyDatabase({super.key});

  @override
  EmptyDatabaseState createState() => EmptyDatabaseState();
}

class EmptyDatabaseState extends State<EmptyDatabase> {
  final _psHostNameList = [
    '兰空',
    'SM.MS',
    'Github',
    'Imgur',
    '七牛云',
    '腾讯云',
    '阿里云',
    '又拍云',
  ];
  final _tableNameList = [
    'lskypro',
    'smms',
    'github',
    'imgur',
    'qiniu',
    'tencent',
    'aliyun',
    'upyun',
  ];

  Widget getListTile(BuildContext context, int index) {
    return ListTile(
        title: Center(child: Text(_psHostNameList[index])),
        onTap: () async {
          showCupertinoAlertDialogWithConfirmFunc(
            title: '通知',
            content: '是否确定清空${_psHostNameList[index]}数据库？',
            context: context,
            onConfirm: () async {
              Navigator.pop(context);
              await AlbumSQL.deleteTable(
                  Global.imageDB!, _tableNameList[index]);
              showToast('已清空${_psHostNameList[index]}数据库');
              eventBus.fire(AlbumRefreshEvent(albumKeepAlive: false));
            },
          );
        });
  }

  List<Widget> getListTiles(BuildContext context) {
    List<Widget> listTiles = [];
    for (int i = 0; i < _psHostNameList.length; i++) {
      listTiles.add(getListTile(context, i));
    }
    ListTile allEmpty = ListTile(
        title: const Center(child: Text('所有数据库')),
        onTap: () async {
          showCupertinoAlertDialogWithConfirmFunc(
            title: '通知',
            content: '是否确定清空全部数据库?',
            context: context,
            onConfirm: () async {
              Navigator.pop(context);
              await AlbumSQL.emptyAllTable(
                Global.imageDB!,
              );
              showToast('已清空所有数据库');
              eventBus.fire(AlbumRefreshEvent(albumKeepAlive: false));
            },
          );
        });
    listTiles.add(allEmpty);
    return listTiles;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text('选择需要清空的数据库'),
      ),
      body: ListView(
        children: getListTiles(context),
      ),
    );
  }
}
