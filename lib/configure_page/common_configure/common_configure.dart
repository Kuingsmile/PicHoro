import 'package:flutter/material.dart';
import 'package:fluro/fluro.dart';

import 'package:horopic/utils/global.dart';
import 'package:horopic/utils/clear_cache.dart';
import 'package:horopic/router/application.dart';
import 'package:horopic/router/routers.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/widgets/common_widgets.dart';

class CommonConfig extends StatefulWidget {
  const CommonConfig({super.key});

  @override
  CommonConfigState createState() => CommonConfigState();
}

class CommonConfigState extends State<CommonConfig> {
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

  Widget _buildSettingItem({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    Widget? trailing,
    Color? iconColor,
    Widget? subtitle,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor ??
              Theme.of(context).primaryColor.withValues(
                    alpha: 0.2,
                  ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor ?? Theme.of(context).primaryColor),
      ),
      title: Text(title),
      subtitle: subtitle,
      onTap: onTap,
      trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: titleText(
          '通用设置',
        ),
        flexibleSpace: getFlexibleSpace(context),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          _buildSettingCard(
            title: '上传设置',
            children: [
              _buildSettingItem(
                title: '文件重命名方式',
                icon: Icons.drive_file_rename_outline,
                onTap: () {
                  Application.router.navigateTo(context, Routes.renameFile, transition: TransitionType.cupertino);
                },
              ),
              const Divider(height: 1, indent: 56),
              _buildSettingItem(
                title: '上传后是否自动复制链接',
                icon: Icons.content_copy,
                onTap: () async {},
                trailing: Switch(
                  value: Global.isCopyLink,
                  onChanged: (value) async {
                    Global.setIsCopyLink(value);
                    setState(() {});
                  },
                ),
              ),
              const Divider(height: 1, indent: 56),
              _buildSettingItem(
                title: '默认复制链接格式',
                icon: Icons.link,
                onTap: () {
                  Application.router.navigateTo(context, Routes.linkFormatSelect, transition: TransitionType.cupertino);
                },
              ),
              const Divider(height: 1, indent: 56),
              _buildSettingItem(
                title: '复制时URL编码',
                icon: Icons.code,
                onTap: () {
                  Application.router.navigateTo(context, Routes.linkFormatSelect, transition: TransitionType.cupertino);
                },
                trailing: Switch(
                  value: Global.isURLEncode,
                  onChanged: (value) async {
                    Global.setIsURLEncode(value);
                    setState(() {});
                  },
                ),
              ),
            ],
          ),
          _buildSettingCard(
            title: '图片处理',
            children: [
              _buildSettingItem(
                title: '上传前是否压缩图片',
                icon: Icons.compress,
                subtitle: const Text('大图片压缩耗时，请按需开启'),
                onTap: () {},
                trailing: Switch(
                  value: Global.isCompress,
                  onChanged: (value) async {
                    Global.setIsCompress(value);
                    setState(() {});
                  },
                ),
              ),
              const Divider(height: 1, indent: 56),
              _buildSettingItem(
                title: '图片压缩细节设置',
                icon: Icons.tune,
                onTap: () {
                  Application.router
                      .navigateTo(context, Routes.compressConfigurePage, transition: TransitionType.cupertino);
                },
              ),
            ],
          ),
          _buildSettingCard(
            title: '删除设置',
            children: [
              _buildSettingItem(
                title: '删除时是否同步删除本地图片',
                icon: Icons.delete_forever,
                subtitle: const Text('不推荐开启，会导致本地相册图片丢失'),
                onTap: () {},
                trailing: Switch(
                  value: Global.isDeleteLocal,
                  onChanged: (value) async {
                    Global.setIsDeleteLocal(value);
                    setState(() {});
                  },
                ),
              ),
              const Divider(height: 1, indent: 56),
              _buildSettingItem(
                title: '删除时是否同步删除云端图片',
                icon: Icons.cloud_off,
                subtitle: const Text('根据需要开启'),
                onTap: () {},
                trailing: Switch(
                  value: Global.isDeleteCloud,
                  onChanged: (value) async {
                    Global.setIsDeleteCloud(value);
                    setState(() {});
                  },
                ),
              ),
            ],
          ),
          _buildSettingCard(
            title: '应用设置',
            children: [
              _buildSettingItem(
                title: '主题设置',
                icon: Icons.color_lens,
                onTap: () {
                  Application.router.navigateTo(context, Routes.changeTheme, transition: TransitionType.cupertino);
                },
              ),
              const Divider(height: 1, indent: 56),
              _buildSettingItem(
                title: '清空缓存',
                icon: Icons.cleaning_services,
                subtitle: const Text('只会清空缓存，不会删除配置文件'),
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
                      },
                    );
                  }
                },
              ),
              const Divider(height: 1, indent: 56),
              _buildSettingItem(
                title: '清空数据库',
                icon: Icons.storage,
                subtitle: const Text('只会清空上传记录，不会清空任何图片'),
                onTap: () {
                  Application.router.navigateTo(context, Routes.emptyDatabase, transition: TransitionType.cupertino);
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
