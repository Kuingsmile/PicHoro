library;

import 'dart:convert';
import 'dart:io';

import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluro/fluro.dart';

import 'package:horopic/picture_host_manage/manage_api/alist_manage_api.dart';
import 'package:horopic/picture_host_manage/manage_api/aliyun_manage_api.dart';
import 'package:horopic/picture_host_manage/manage_api/aws_manage_api.dart';
import 'package:horopic/picture_host_manage/manage_api/github_manage_api.dart';
import 'package:horopic/picture_host_manage/manage_api/imgur_manage_api.dart';
import 'package:horopic/picture_host_manage/manage_api/lskypro_manage_api.dart';
import 'package:horopic/picture_host_manage/manage_api/qiniu_manage_api.dart';
import 'package:horopic/picture_host_manage/manage_api/smms_manage_api.dart';
import 'package:horopic/picture_host_manage/manage_api/tencent_manage_api.dart';
import 'package:horopic/picture_host_manage/manage_api/upyun_manage_api.dart';
import 'package:path_provider/path_provider.dart';

import 'package:horopic/utils/global.dart';
import 'package:horopic/utils/common_functions.dart';

import 'package:horopic/picture_host_configure/configure_page/configure_export.dart';

import 'package:horopic/widgets/net_loading_dialog.dart';

import 'package:horopic/router/application.dart';
import 'package:horopic/router/routers.dart';

part 'picture_host_import_qr.dart';

//a configure page for user to show configure entry
class AllPShost extends StatefulWidget {
  const AllPShost({super.key});

  @override
  AllPShostState createState() => AllPShostState();
}

class AllPShostState extends State<AllPShost> {
  Future<void> _scan() async {
    try {
      final result = await BarcodeScanner.scan(
          options: const ScanOptions(
        strings: {"cancel": "取消", "flash_on": "打开闪光灯", "flash_off": "关闭闪光灯"},
        restrictFormat: [BarcodeFormat.qr],
        android: AndroidOptions(aspectTolerance: 0.00, useAutoFocus: true),
        autoEnableFlash: false,
      ));
      setState(() => Global.qrScanResult = result.rawContent.toString());
    } catch (e) {
      _logError('_scan', {}, e);
      setState(() {
        Global.qrScanResult = ScanResult(
          type: ResultType.Error,
          format: BarcodeFormat.unknown,
          rawContent: e.toString(),
        ).rawContent;
      });
    }
  }

  static Future<String> get localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<void> exportConfiguration([String? pshost]) async {
    try {
      String configPath = await localPath;
      String defaultUser = Global.getUser();
      Map<String, String> configFilePaths = {
        "smms": "$configPath/${defaultUser}_smms_config.txt",
        "lankong": "$configPath/${defaultUser}_host_config.txt",
        "github": "$configPath/${defaultUser}_github_config.txt",
        "imgur": "$configPath/${defaultUser}_imgur_config.txt",
        "qiniu": "$configPath/${defaultUser}_qiniu_config.txt",
        "tcyun": "$configPath/${defaultUser}_tencent_config.txt",
        "aliyun": "$configPath/${defaultUser}_aliyun_config.txt",
        "upyun": "$configPath/${defaultUser}_upyun_config.txt",
        "ftp": "$configPath/${defaultUser}_ftp_config.txt",
        "aws": "$configPath/${defaultUser}_aws_config.txt",
        "alist": "$configPath/${defaultUser}_alist_config.txt",
        "webdav": "$configPath/${defaultUser}_webdav_config.txt",
      };

      Map<String, dynamic> configMap = {};

      if (pshost != null) {
        if (!configFilePaths.containsKey(pshost)) return;

        String filePath = configFilePaths[pshost]!;
        if (!File(filePath).existsSync()) {
          return showToast("配置文件不存在");
        }

        String config = await File(filePath).readAsString();
        if (config.isEmpty) {
          return showToast("该图床未配置");
        }

        configMap[pshost] = jsonDecode(config);
      } else {
        for (var key in configFilePaths.keys) {
          String filePath = configFilePaths[key]!;
          if (!File(filePath).existsSync()) continue;

          String config = await File(filePath).readAsString();
          if (config.isEmpty) continue;

          configMap[key] = jsonDecode(config);
        }
      }

      if (configMap.isEmpty) {
        return showToast("没有可导出的配置");
      }

      String configJson = jsonEncode(configMap).replaceAll('None', '');
      await Clipboard.setData(ClipboardData(text: configJson));
      showToast(pshost != null ? "$pshost配置已复制到剪贴板" : "配置已复制到剪贴板");
    } catch (e) {
      _logError(pshost != null ? 'exportConfiguration' : 'exportAllConfiguration',
          pshost != null ? {"pshost": pshost} : {}, e);
      showToast("导出失败");
    }
  }

  Future<dynamic> processingQRCodeResult() async {
    try {
      String result = Global.qrScanResult;
      Global.qrScanResult = "";
      Map<String, dynamic> jsonResult = jsonDecode(result);

      // Check if any supported services exist in the JSON
      List<String> supportedServices = [
        'smms',
        'alist',
        'alistplist',
        'aws-s3-plist',
        'aws-s3',
        'github',
        'lankong',
        'lskyplist',
        'imgur',
        'qiniu',
        'tcyun',
        'aliyun',
        'upyun'
      ];

      if (!supportedServices.any((service) => jsonResult.containsKey(service))) {
        return showToast("不包含支持的图床配置信息");
      }

      // Handle each service configuration
      if (jsonResult['smms'] != null) _configureSmms(jsonResult);
      if (jsonResult['aws-s3-plist'] != null || jsonResult['aws-s3'] != null) _configureAws(jsonResult);
      if (jsonResult['alist'] != null || jsonResult['alistplist'] != null) _configureAlist(jsonResult);
      if (jsonResult['github'] != null) _configureGithub(jsonResult);
      if (jsonResult['lankong'] != null || jsonResult['lskyplist'] != null) _configureLankong(jsonResult);
      if (jsonResult['imgur'] != null) _configureImgur(jsonResult);
      if (jsonResult['qiniu'] != null) _configureQiniu(jsonResult);
      if (jsonResult['tcyun'] != null) _configureTencent(jsonResult);
      if (jsonResult['aliyun'] != null) _configureAliyun(jsonResult);
      if (jsonResult['upyun'] != null) _configureUpyun(jsonResult);

      return true;
    } catch (e) {
      _logError('processingQRCodeResult', {}, e);
      showToast("导入失败");
    }
  }

  // UI Building Methods
  Widget _buildSettingCard({required String title, required List<Widget> children}) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor ?? Theme.of(context).primaryColor.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor ?? Theme.of(context).primaryColor),
      ),
      title: Text(title),
      onTap: onTap,
      trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
    );
  }

  List<SimpleDialogOption> _buildSimpleDialogOptions(BuildContext context) {
    // Define service mappings once
    final serviceMap = {
      "全部导出": null,
      "AList V3": 'alist',
      '阿里云': 'aliyun',
      'FTP-SSH/SFTP': 'ftp',
      'Github': 'github',
      'Imgur': 'imgur',
      '兰空图床': 'lankong',
      '七牛云': 'qiniu',
      'S3兼容平台': 'aws',
      'SM.MS': 'smms',
      '腾讯云': 'tcyun',
      '又拍云': 'upyun',
      'WebDAV': 'webdav',
    };

    return serviceMap.entries.map((entry) {
      return SimpleDialogOption(
        child: Text(entry.key, textAlign: TextAlign.center),
        onPressed: () {
          entry.value == null ? exportConfiguration() : exportConfiguration(entry.value!);
          Navigator.pop(context);
        },
      );
    }).toList();
  }

  // Service navigation helper
  void _navigateToService(String route) {
    Application.router.navigateTo(context, route, transition: TransitionType.cupertino);
  }

  @override
  Widget build(BuildContext context) {
    // Define service items
    final serviceItems = [
      {'title': '默认图床选择', 'icon': Icons.photo_library, 'route': Routes.defaultPShostSelect},
      {'title': 'AList V3', 'icon': Icons.folder_shared, 'route': Routes.alistPShostSelect},
      {'title': '阿里云OSS', 'icon': Icons.cloud_upload, 'route': Routes.aliyunPShostSelect},
      {'title': 'FTP-SSH/SFTP', 'icon': Icons.storage, 'route': Routes.ftpPShostSelect},
      {'title': 'Github图床', 'icon': Icons.code, 'route': Routes.githubPShostSelect},
      {'title': 'Imgur图床', 'icon': Icons.image, 'route': Routes.imgurPShostSelect},
      {'title': '兰空图床V2', 'icon': Icons.cloud, 'route': Routes.lskyproPShostSelect},
      {'title': '七牛云存储', 'icon': Icons.cloud_circle, 'route': Routes.qiniuPShostSelect},
      {'title': 'S3兼容平台', 'icon': Icons.storage_rounded, 'route': Routes.awsPShostSelect},
      {'title': 'SM.MS图床', 'icon': Icons.camera, 'route': Routes.smmsPShostSelect},
      {'title': '腾讯云COS V5', 'icon': Icons.cloud_queue, 'route': Routes.tencentPShostSelect},
      {'title': '又拍云存储', 'icon': Icons.cloud_done, 'route': Routes.upyunPShostSelect},
      {'title': 'WebDAV', 'icon': Icons.web, 'route': Routes.webdavPShostSelect},
    ];

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: titleText('图床设置'),
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
            title: '导入导出',
            children: [
              _buildSettingItem(
                title: '二维码扫描导入PicGo配置',
                icon: Icons.qr_code_scanner,
                onTap: () async {
                  await _scan();
                  if (context.mounted) {
                    showDialog(
                      context: this.context,
                      barrierDismissible: false,
                      builder: (context) => NetLoadingDialog(
                        outsideDismiss: false,
                        loading: true,
                        loadingText: "配置中...",
                        requestCallBack: processingQRCodeResult(),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
          _buildSettingCard(
            title: '图床配置',
            children: [
              for (int i = 0; i < serviceItems.length; i++) ...[
                if (i > 0) const Divider(height: 1, indent: 56),
                _buildSettingItem(
                  title: serviceItems[i]['title'] as String,
                  icon: serviceItems[i]['icon'] as IconData,
                  onTap: () => _navigateToService(serviceItems[i]['route'] as String),
                ),
              ],
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
      floatingActionButton: SizedBox(
        height: 50,
        width: 50,
        child: FloatingActionButton(
          heroTag: 'copyConfig',
          elevation: 3,
          backgroundColor: Theme.of(context).primaryColor,
          onPressed: () async {
            await showDialog(
              barrierDismissible: true,
              context: context,
              builder: (context) => SimpleDialog(
                title: const Text(
                  '选择要复制配置的图床',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                children: _buildSimpleDialogOptions(context),
              ),
            );
          },
          child: const Icon(Icons.outbox_outlined, color: Colors.white, size: 30),
        ),
      ),
    );
  }
}
