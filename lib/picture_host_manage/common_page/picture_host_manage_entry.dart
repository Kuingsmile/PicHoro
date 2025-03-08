import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:fluro/fluro.dart';
import 'package:flutter_draggable_gridview/flutter_draggable_gridview.dart';
import 'package:horopic/picture_host_manage/manage_api/webdav_manage_api.dart';

import 'package:horopic/utils/global.dart';

import 'package:horopic/router/application.dart';
import 'package:horopic/router/routers.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/picture_host_manage/manage_api/upyun_manage_api.dart';
import 'package:horopic/picture_host_manage/manage_api/imgur_manage_api.dart';
import 'package:horopic/picture_host_manage/manage_api/ftp_manage_api.dart';
import 'package:horopic/picture_host_manage/manage_api/alist_manage_api.dart';

class PsHostHomePage extends StatefulWidget {
  const PsHostHomePage({super.key});

  @override
  PsHostHomePageState createState() => PsHostHomePageState();
}

class PsHostHomePageState extends State<PsHostHomePage> with AutomaticKeepAliveClientMixin<PsHostHomePage> {
  List psHostHomePageOrder = [];

  @override
  bool get wantKeepAlive => false;

  @override
  void initState() {
    super.initState();
    initOrder();
  }

  initOrder() {
    psHostHomePageOrder.clear();
    List temppsHostHomePageOrder = Global.psHostHomePageOrder;
    setState(() {
      for (var i = 0; i < temppsHostHomePageOrder.length; i++) {
        psHostHomePageOrder.add(int.parse(temppsHostHomePageOrder[i]));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    List<DraggableGridItem> listOfDraggableGridItem = [
      DraggableGridItem(
        child: _buildCard(
          'assets/icons/tcyun.png',
          '腾讯云',
          () async {
            Application.router.navigateTo(
              context,
              Routes.tencentBucketList,
              transition: TransitionType.inFromRight,
            );
          },
        ),
        isDraggable: true,
      ),
      DraggableGridItem(
        child: _buildCard(
          'assets/icons/smms.png',
          'SM.MS',
          () {
            Application.router.navigateTo(
              context,
              Routes.smmsManageHomePage,
              transition: TransitionType.inFromRight,
            );
          },
        ),
        isDraggable: true,
      ),
      DraggableGridItem(
        child: _buildCard(
          'assets/icons/aliyun.png',
          '阿里云',
          () {
            Application.router.navigateTo(
              context,
              Routes.aliyunBucketList,
              transition: TransitionType.inFromRight,
            );
          },
        ),
        isDraggable: true,
      ),
      DraggableGridItem(
        child: _buildCard(
          'assets/icons/qiniu.png',
          '七牛云',
          () async {
            Application.router.navigateTo(
              context,
              Routes.qiniuBucketList,
              transition: TransitionType.inFromRight,
            );
          },
        ),
        isDraggable: true,
      ),
      DraggableGridItem(
        child: _buildCard(
          'assets/icons/upyun.png',
          '又拍云',
          () async {
            var queryUpyunManage = await UpyunManageAPI.readUpyunManageConfig();
            if (queryUpyunManage == 'Error' || queryUpyunManage == '') {
              if (mounted) {
                Application.router.navigateTo(
                  context,
                  Routes.upyunLogIn,
                  transition: TransitionType.inFromRight,
                );
              }
            } else {
              showToast('开始校验');
              var jsonResult = jsonDecode(queryUpyunManage);
              String token = jsonResult['token'];
              var checkTokenResult = await UpyunManageAPI.checkToken(token);
              if (checkTokenResult[0] == 'success') {
                if (mounted) {
                  Application.router.navigateTo(
                    context,
                    Routes.upyunBucketList,
                    transition: TransitionType.inFromRight,
                  );
                }
              } else {
                if (mounted) {
                  Application.router.navigateTo(
                    context,
                    Routes.upyunLogIn,
                    transition: TransitionType.inFromRight,
                  );
                }
              }
            }
          },
        ),
        isDraggable: true,
      ),
      DraggableGridItem(
        child: _buildCard(
          'assets/icons/lskypro.png',
          '兰空图床',
          () async {
            Application.router.navigateTo(
              context,
              Routes.lskyproManageHomePage,
              transition: TransitionType.inFromRight,
            );
          },
        ),
        isDraggable: true,
      ),
      DraggableGridItem(
        child: _buildCard(
          'assets/icons/github.png',
          'Github',
          () async {
            Application.router.navigateTo(
              context,
              Routes.githubManageHomePage,
              transition: TransitionType.inFromRight,
            );
          },
        ),
        isDraggable: true,
      ),
      DraggableGridItem(
        child: _buildCard(
          'assets/icons/fakesmms.png',
          'Imgur',
          () async {
            var queryImgurManage = await ImgurManageAPI.readImgurManageConfig();
            if (queryImgurManage == 'Error') {
              if (mounted) {
                Application.router.navigateTo(
                  context,
                  Routes.imgurLogIn,
                  transition: TransitionType.inFromRight,
                );
              }
            } else {
              showToast('开始校验');
              var jsonResult = jsonDecode(queryImgurManage);
              String imguruser = jsonResult['imguruser'];
              String token = jsonResult['accesstoken'];
              String proxy = jsonResult['proxy'];
              if (token == 'None') {
                if (mounted) {
                  Application.router.navigateTo(
                    context,
                    Routes.imgurLogIn,
                    transition: TransitionType.inFromRight,
                  );
                }
                return;
              }
              var checkTokenResult = await ImgurManageAPI.checkToken(imguruser, token, proxy);
              if (checkTokenResult[0] == 'success') {
                if (mounted) {
                  Application.router.navigateTo(
                    context,
                    '${Routes.imgurFileExplorer}?userProfile=${Uri.encodeComponent(jsonEncode(jsonResult))}&albumInfo=${Uri.encodeComponent(jsonEncode({}))}&allImages=${Uri.encodeComponent(jsonEncode([]))}',
                    transition: TransitionType.inFromRight,
                  );
                }
              } else {
                if (mounted) {
                  Application.router.navigateTo(
                    context,
                    Routes.imgurLogIn,
                    transition: TransitionType.inFromRight,
                  );
                }
              }
            }
          },
        ),
        isDraggable: true,
      ),
      DraggableGridItem(
        child: _buildCard(
          'assets/images/ftp.png',
          'SSH/SFTP',
          () async {
            Map configMap = await FTPManageAPI.getConfigMap();
            if (mounted && configMap['ftpType'] == 'SFTP') {
              String startDir = configMap['ftpHomeDir'];
              if (startDir == 'None') {
                startDir = '/';
              } else {
                if (!startDir.endsWith('/')) {
                  startDir = '$startDir/';
                }
                if (!startDir.startsWith('/')) {
                  startDir = '/$startDir';
                }
              }
              Application.router.navigateTo(context,
                  '${Routes.sftpFileExplorer}?element=${Uri.encodeComponent(jsonEncode(configMap))}&bucketPrefix=${Uri.encodeComponent(startDir)}',
                  transition: TransitionType.cupertino);
            } else {
              showToast('仅支持管理SFTP');
            }
          },
        ),
        isDraggable: true,
      ),
      DraggableGridItem(
        child: _buildCard(
          'assets/images/aws_s3.png',
          'S3兼容平台',
          () async {
            Application.router.navigateTo(
              context,
              Routes.awsBucketList,
              transition: TransitionType.inFromRight,
            );
          },
        ),
        isDraggable: true,
      ),
      DraggableGridItem(
        child: _buildCard(
          'assets/images/alist.png',
          'Alist',
          () async {
            showToast('开始校验');
            try {
              Map configMap = await AlistManageAPI.getConfigMap();
              if (configMap['token'] == '') {
                String prefix = configMap['uploadPath'];
                if (prefix == 'None') {
                  prefix = '/';
                }
                if (!prefix.endsWith('/')) {
                  prefix += '/';
                }
                Map element = {
                  'mount_path': prefix == '/' ? '/' : prefix.substring(0, prefix.length - 1),
                  'driver': 'BaiduNetdisk',
                  'addition': jsonEncode({'download_api': 'offical'})
                };
                if (mounted) {
                  Application.router.navigateTo(context,
                      '${Routes.alistFileExplorer}?element=${Uri.encodeComponent(jsonEncode(element))}&bucketPrefix=${Uri.encodeComponent(prefix)}&refresh=${Uri.encodeComponent('doNotRefresh')}',
                      transition: TransitionType.cupertino);
                  return;
                }
              }
              String? adminToken = configMap['adminToken'];
              if (adminToken == null || adminToken == 'None' || adminToken.trim().isNotEmpty) {
                String today = getToday('yyyyMMdd');

                var refreshToken = await AlistManageAPI.refreshToken();
                if (refreshToken[0] != 'success') {
                  showToast('刷新Token失败');
                  return;
                }
                Global.setTodayAlistUpdate(today);
              }

              var bucketListResponse = await AlistManageAPI.getBucketList();
              if (bucketListResponse[0] != 'success') {
                Map configMap = await AlistManageAPI.getConfigMap();
                String prefix = configMap['uploadPath'];
                if (prefix == 'None') {
                  prefix = '/';
                }
                if (!prefix.endsWith('/')) {
                  prefix += '/';
                }
                Map element = {
                  'mount_path': prefix == '/' ? '/' : prefix.substring(0, prefix.length - 1),
                  'driver': 'BaiduNetdisk',
                  'addition': jsonEncode({'download_api': 'offical'})
                };
                if (mounted) {
                  Application.router.navigateTo(context,
                      '${Routes.alistFileExplorer}?element=${Uri.encodeComponent(jsonEncode(element))}&bucketPrefix=${Uri.encodeComponent(prefix)}&refresh=${Uri.encodeComponent('doNotRefresh')}',
                      transition: TransitionType.cupertino);
                }
              } else {
                if (mounted) {
                  Application.router.navigateTo(
                    context,
                    Routes.alistBucketList,
                    transition: TransitionType.inFromRight,
                  );
                }
              }
            } catch (e) {
              showToast('校验失败');
            }
          },
        ),
        isDraggable: true,
      ),
      DraggableGridItem(
        child: _buildCard(
          'assets/images/webdav.png',
          'Webdav',
          () async {
            try {
              Map configMap = await WebdavManageAPI.getConfigMap();
              String prefix = configMap['uploadPath'];
              if (prefix == 'None') {
                prefix = '/';
              }
              if (!prefix.endsWith('/')) {
                prefix += '/';
              }
              Map element = configMap;
              if (mounted) {
                Application.router.navigateTo(context,
                    '${Routes.webdavFileExplorer}?element=${Uri.encodeComponent(jsonEncode(element))}&bucketPrefix=${Uri.encodeComponent(prefix)}',
                    transition: TransitionType.cupertino);
              }
            } catch (e) {
              showToast('请先配置Webdav');
            }
          },
        ),
        isDraggable: true,
      ),
    ];
    List<DraggableGridItem> newItems = [];
    for (int i = 0; i < listOfDraggableGridItem.length; i++) {
      newItems.add(listOfDraggableGridItem[psHostHomePageOrder[i]]);
    }
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: titleText(
          '图床管理-长按拖动',
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withValues(alpha: 0.7),
                Theme.of(context).primaryColor.withValues(alpha: 0.5),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8.0),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(15),
            ),
            child: IconButton(
              icon: const Icon(Icons.restart_alt_rounded, color: Colors.white, size: 28),
              onPressed: () async {
                List<String> order = [];
                for (int i = 0; i < 22; i++) {
                  order.add(i.toString());
                }
                Global.setpsHostHomePageOrder(order);
                setState(() {
                  initOrder();
                });
                showToast('已重置排序');
              },
              tooltip: '重置排序',
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Theme.of(context).primaryColor.withValues(alpha: 0.05),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: DraggableGridViewBuilder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 15,
              crossAxisSpacing: 15,
              childAspectRatio: 1.5,
            ),
            children: newItems,
            dragCompletion: (List<DraggableGridItem> list, int beforeIndex, int afterIndex) async {
              List<String> newOrder = [];
              for (int i = 0; i < list.length; i++) {
                newOrder.add(listOfDraggableGridItem.indexOf(list[i]).toString());
              }
              Global.setpsHostHomePageOrder(newOrder);
            },
            dragFeedback: (List<DraggableGridItem> list, int index) {
              return SizedBox(
                width: 200,
                height: 150,
                child: list[index].child,
              );
            },
            dragPlaceHolder: (List<DraggableGridItem> list, int index) {
              return PlaceHolderWidget(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: Theme.of(context).primaryColor.withValues(alpha: 0.5),
                      width: 2,
                      style: BorderStyle.solid,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCard(String imagePath, String title, VoidCallback onTap) {
    return Hero(
      tag: title,
      child: Material(
        color: Colors.transparent,
        child: Card(
          elevation: 5,
          shadowColor: Colors.black26,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(15),
            splashColor: Theme.of(context).primaryColor.withValues(alpha: 0.3),
            highlightColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    Theme.of(context).cardColor,
                  ],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset(
                    imagePath,
                    width: 70,
                    height: 65,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).primaryColor.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
