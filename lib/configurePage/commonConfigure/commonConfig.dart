import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:horopic/utils/global.dart';
import 'package:horopic/configurePage/others/selectTheme.dart';
import 'package:horopic/configurePage/commonConfigure/selectLinkFormat.dart';
import 'package:horopic/album/EmptyDatabase.dart';
import 'package:horopic/utils/clearcache.dart';
import 'package:horopic/configurePage/commonConfigure/renameFile.dart';
import 'package:horopic/router/application.dart';
import 'package:horopic/router/routes.dart';
import 'package:fluro/fluro.dart';

class CommonConfig extends StatefulWidget {
  const CommonConfig({Key? key}) : super(key: key);

  @override
  _CommonConfigState createState() => _CommonConfigState();
}

class _CommonConfigState extends State<CommonConfig> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('通用设置'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('文件重命名方式选项'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Application.router.navigateTo(context, Routes.renameFile,
                  transition: TransitionType.cupertino);
            },
          ),
          ListTile(
            title: const Text('上传后是否自动复制链接'),
            trailing: Switch(
              value: Global.isCopyLink,
              onChanged: (value) async {
                await Global.setCopyLink(value);
                setState(() {});
              },
            ),
          ),
          ListTile(
            title: const Text('默认复制链接格式'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Application.router.navigateTo(context, Routes.linkFormatSelect,
                  transition: TransitionType.cupertino);
            },
          ),
          ListTile(
            title: const Text('删除时是否同步删除本地图片'),
            subtitle: const Text('不推荐开启，会导致本地相册图片丢失'),
            trailing: Switch(
              value: Global.isDeleteLocal,
              onChanged: (value) async {
                await Global.setDeleteLocal(value);
                setState(() {});
              },
            ),
          ),
          ListTile(
            title: const Text('删除时是否同步删除云端图片'),
            subtitle: const Text('根据需要开启'),
            trailing: Switch(
              value: Global.isDeleteCloud,
              onChanged: (value) async {
                await Global.setDeleteCloud(value);
                setState(() {});
              },
            ),
          ),
          ListTile(
            title: const Text('主题设置'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Application.router.navigateTo(context, Routes.changeTheme,
                  transition: TransitionType.cupertino);
            },
          ),
          ListTile(
            title: const Text('清空缓存'),
            subtitle: const Text('只会清空缓存，不会删除配置文件'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () async {
              String currentCacheMemory = await CacheUtil.total();

              showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('清空缓存'),
                      content: Text('当前缓存大小为$currentCacheMemory MB,是否清空？'),
                      actions: [
                        TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('取消')),
                        TextButton(
                            onPressed: () async {
                              await CacheUtil.clear();
                              Fluttertoast.showToast(
                                  msg: "清理成功",
                                  toastLength: Toast.LENGTH_SHORT,
                                  timeInSecForIosWeb: 2,
                                  fontSize: 16.0);
                              Navigator.pop(context);
                            },
                            child: const Text('确定')),
                      ],
                    );
                  });
            },
          ),
          ListTile(
            title: const Text('清空数据库'),
            subtitle: const Text('只会清空上传记录，不会清空任何图片'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Application.router.navigateTo(context, Routes.emptyDatabase,
                  transition: TransitionType.cupertino);
            },
          ),
        ],
      ),
    );
  }
}
