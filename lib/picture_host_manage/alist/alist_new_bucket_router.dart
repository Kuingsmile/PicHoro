import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluro/fluro.dart';

import 'package:horopic/router/application.dart';
import 'package:horopic/router/routers.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/picture_host_manage/manage_api/alist_manage_api.dart';

class AlistNewBucketRouter extends StatefulWidget {
  const AlistNewBucketRouter({Key? key}) : super(key: key);

  @override
  AlistNewBucketRouterState createState() => AlistNewBucketRouterState();
}

class AlistNewBucketRouterState extends State<AlistNewBucketRouter> {
  List<ListTile> generateListTile() {
    List<ListTile> listTileList = [];
    List drivers = AlistManageAPI.driverTranslate.keys.toList();
    List driversShowedName = AlistManageAPI.driverTranslate.values.toList();
    for (int i = 0; i < drivers.length; i++) {
      listTileList.add(ListTile(
        trailing: const Icon(Icons.navigate_next),
        title: Text(driversShowedName[i]),
        onTap: () {
          String update = 'false';
          Application.router.navigateTo(context,
              '${Routes.alistNewBucketConfig}?driver=${Uri.encodeComponent(drivers[i])}&update=${Uri.encodeComponent(update)}&bucketMap=${Uri.encodeComponent(jsonEncode({}))}',
              transition: TransitionType.cupertino);
        },
      ));
    }
    return listTileList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: titleText('新建存储'),
        ),
        body: ListView(
          children: generateListTile(),
        ));
  }
}
