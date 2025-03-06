import 'package:flutter/material.dart';
import 'package:fluro/fluro.dart';

import 'package:horopic/utils/global.dart';
import 'package:horopic/utils/clear_cache.dart';
import 'package:horopic/router/application.dart';
import 'package:horopic/router/routers.dart';
import 'package:horopic/utils/common_functions.dart';

class CommonConfig extends StatefulWidget {
  const CommonConfig({super.key});

  @override
  CommonConfigState createState() => CommonConfigState();
}

class CommonConfigState extends State<CommonConfig> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: titleText(
          '通用设置',
        ),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('文件重命名方式'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Application.router.navigateTo(context, Routes.renameFile, transition: TransitionType.cupertino);
            },
          ),
          ListTile(
            title: const Text('上传后是否自动复制链接'),
            trailing: Switch(
              value: Global.isCopyLink,
              onChanged: (value) async {
                await Global.setIsCopyLink(value);
                setState(() {});
              },
            ),
          ),
          ListTile(
            title: const Text('默认复制链接格式'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Application.router.navigateTo(context, Routes.linkFormatSelect, transition: TransitionType.cupertino);
            },
          ),
          ListTile(
            title: const Text('复制时URL编码'),
            trailing: Switch(
              value: Global.isURLEncode,
              onChanged: (value) async {
                await Global.setIsURLEncode(value);
                setState(() {});
              },
            ),
            onTap: () {
              Application.router.navigateTo(context, Routes.linkFormatSelect, transition: TransitionType.cupertino);
            },
          ),
          ListTile(
            title: const Text('上传前是否压缩图片'),
            subtitle: const Text('大图片压缩耗时，请按需开启'),
            trailing: Switch(
              value: Global.isCompress,
              onChanged: (value) async {
                await Global.setIsCompress(value);
                setState(() {});
              },
            ),
          ),
          ListTile(
            title: const Text('图片压缩细节设置'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Application.router
                  .navigateTo(context, Routes.compressConfigurePage, transition: TransitionType.cupertino);
            },
          ),
          ListTile(
            title: const Text('删除时是否同步删除本地图片'),
            subtitle: const Text('不推荐开启，会导致本地相册图片丢失'),
            trailing: Switch(
              value: Global.isDeleteLocal,
              onChanged: (value) async {
                await Global.setIsDeleteLocal(value);
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
                await Global.setIsDeleteCloud(value);
                setState(() {});
              },
            ),
          ),
          ListTile(
            title: const Text('主题设置'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Application.router.navigateTo(context, Routes.changeTheme, transition: TransitionType.cupertino);
            },
          ),
          ListTile(
            title: const Text('清空缓存'),
            subtitle: const Text('只会清空缓存，不会删除配置文件'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () async {
              String currentCacheMemory = await CacheUtil.total();
              if (context.mounted) {
                showCupertinoAlertDialogWithConfirmFunc(
                  title: '通知',
                  content: '当前缓存大小为$currentCacheMemory MB,是否清空?',
                  context: context,
                  onConfirm: () async {
                    await CacheUtil.clear();
                    showToast('清理成功');
                    if (mounted) {
                      Navigator.pop(context);
                    }
                  },
                );
              }
            },
          ),
          ListTile(
            title: const Text('清空数据库'),
            subtitle: const Text('只会清空上传记录，不会清空任何图片'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Application.router.navigateTo(context, Routes.emptyDatabase, transition: TransitionType.cupertino);
            },
          ),
        ],
      ),
    );
  }
}
