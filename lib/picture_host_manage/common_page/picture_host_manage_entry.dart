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
        child: Card(
          borderOnForeground: true,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Stack(
            children: [
              Center(
                child: InkWell(
                  onTap: () async {
                    Application.router.navigateTo(
                      context,
                      Routes.tencentBucketList,
                      transition: TransitionType.inFromRight,
                    );
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image.asset(
                        'assets/icons/tcyun.png',
                        width: 80,
                        height: 75,
                      ),
                      const Text('腾讯云'),
                    ],
                  ),
                ),
              ),
              Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    color: Colors.transparent,
                    child: const Text(''),
                  )),
            ],
          ),
        ),
        isDraggable: true,
      ),
      DraggableGridItem(
        child: Card(
          child: Stack(
            children: [
              Center(
                child: InkWell(
                  onTap: () {
                    Application.router.navigateTo(
                      context,
                      Routes.smmsManageHomePage,
                      transition: TransitionType.inFromRight,
                    );
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image.asset(
                        'assets/icons/smms.png',
                        width: 80,
                        height: 75,
                      ),
                      const Text('SM.MS'),
                    ],
                  ),
                ),
              ),
              Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    color: Colors.transparent,
                    child: const Text(''),
                  )),
            ],
          ),
        ),
        isDraggable: true,
      ),
      DraggableGridItem(
        child: Card(
          child: Stack(
            children: [
              Center(
                child: InkWell(
                  onTap: () {
                    Application.router.navigateTo(
                      context,
                      Routes.aliyunBucketList,
                      transition: TransitionType.inFromRight,
                    );
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image.asset(
                        'assets/icons/aliyun.png',
                        width: 80,
                        height: 75,
                      ),
                      const Text('阿里云'),
                    ],
                  ),
                ),
              ),
              Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    color: Colors.transparent,
                    child: const Text(''),
                  )),
            ],
          ),
        ),
        isDraggable: true,
      ),
      DraggableGridItem(
        child: Card(
          child: Stack(
            children: [
              Center(
                child: InkWell(
                  onTap: () async {
                    Application.router.navigateTo(
                      context,
                      Routes.qiniuBucketList,
                      transition: TransitionType.inFromRight,
                    );
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image.asset(
                        'assets/icons/qiniu.png',
                        width: 80,
                        height: 75,
                      ),
                      const Text('七牛云'),
                    ],
                  ),
                ),
              ),
              Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    color: Colors.transparent,
                    child: const Text(''),
                  )),
            ],
          ),
        ),
        isDraggable: true,
      ),
      DraggableGridItem(
        child: Card(
          child: Stack(
            children: [
              Center(
                  child: InkWell(
                onTap: () async {
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image.asset(
                      'assets/icons/upyun.png',
                      width: 80,
                      height: 75,
                    ),
                    const Text('又拍云'),
                  ],
                ),
              )),
              Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    color: Colors.transparent,
                    child: const Text(''),
                  )),
            ],
          ),
        ),
        isDraggable: true,
      ),
      DraggableGridItem(
        child: Card(
          child: Stack(
            children: [
              Center(
                child: InkWell(
                  onTap: () async {
                    Application.router.navigateTo(
                      context,
                      Routes.lskyproManageHomePage,
                      transition: TransitionType.inFromRight,
                    );
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image.asset(
                        'assets/icons/lskypro.png',
                        width: 80,
                        height: 75,
                      ),
                      const Text('兰空图床'),
                    ],
                  ),
                ),
              ),
              Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    color: Colors.transparent,
                    child: const Text(''),
                  )),
            ],
          ),
        ),
        isDraggable: true,
      ),
      DraggableGridItem(
        child: Card(
          child: Stack(
            children: [
              Center(
                child: InkWell(
                  onTap: () async {
                    Application.router.navigateTo(
                      context,
                      Routes.githubManageHomePage,
                      transition: TransitionType.inFromRight,
                    );
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image.asset(
                        'assets/icons/github.png',
                        width: 80,
                        height: 75,
                      ),
                      const Text('Github'),
                    ],
                  ),
                ),
              ),
              Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    color: Colors.transparent,
                    child: const Text(''),
                  )),
            ],
          ),
        ),
        isDraggable: true,
      ),
      DraggableGridItem(
        child: Card(
          child: Stack(
            children: [
              Center(
                child: InkWell(
                  onTap: () async {
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image.asset(
                        'assets/icons/fakesmms.png',
                        width: 70,
                        height: 75,
                      ),
                      const Text('Imgur'),
                    ],
                  ),
                ),
              ),
              Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    color: Colors.transparent,
                    child: const Text(''),
                  )),
            ],
          ),
        ),
        isDraggable: true,
      ),
      DraggableGridItem(
        child: Card(
          child: Stack(
            children: [
              Center(
                child: InkWell(
                  onTap: () async {
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image.asset(
                        'assets/images/ftp.png',
                        width: 80,
                        height: 75,
                      ),
                      const Text('SSH/SFTP'),
                    ],
                  ),
                ),
              ),
              Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    color: Colors.transparent,
                    child: const Text(''),
                  )),
            ],
          ),
        ),
        isDraggable: true,
      ),
      DraggableGridItem(
        child: Card(
          child: Stack(
            children: [
              Center(
                child: InkWell(
                  onTap: () async {
                    Application.router.navigateTo(
                      context,
                      Routes.awsBucketList,
                      transition: TransitionType.inFromRight,
                    );
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image.asset(
                        'assets/images/aws_s3.png',
                        width: 80,
                        height: 75,
                      ),
                      const Text('S3兼容平台'),
                    ],
                  ),
                ),
              ),
              Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    color: Colors.transparent,
                    child: const Text(''),
                  )),
            ],
          ),
        ),
        isDraggable: true,
      ),
      DraggableGridItem(
        child: Card(
          child: Stack(
            children: [
              Center(
                child: InkWell(
                  onTap: () async {
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
                        await Global.setTodayAlistUpdate(today);
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image.asset(
                        'assets/images/alist.png',
                        width: 80,
                        height: 75,
                      ),
                      const Text('Alist'),
                    ],
                  ),
                ),
              ),
              Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    color: Colors.transparent,
                    child: const Text(''),
                  )),
            ],
          ),
        ),
        isDraggable: true,
      ),
      DraggableGridItem(
        child: Card(
          child: Stack(
            children: [
              Center(
                child: InkWell(
                  onTap: () async {
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image.asset(
                        'assets/images/webdav.png',
                        width: 80,
                        height: 75,
                      ),
                      const Text('Webdav'),
                    ],
                  ),
                ),
              ),
              Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    color: Colors.transparent,
                    child: const Text(''),
                  )),
            ],
          ),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.restart_alt_rounded, color: Colors.white, size: 30),
            onPressed: () async {
              List<String> order = [];
              for (int i = 0; i < 22; i++) {
                order.add(i.toString());
              }
              await Global.setpsHostHomePageOrder(order);
              setState(() {
                initOrder();
              });
              showToast('已重置排序');
            },
          ),
        ],
      ),
      body: DraggableGridViewBuilder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.6,
        ),
        children: newItems,
        dragCompletion: (List<DraggableGridItem> list, int beforeIndex, int afterIndex) async {
          List<String> newOrder = [];
          for (int i = 0; i < list.length; i++) {
            newOrder.add(listOfDraggableGridItem.indexOf(list[i]).toString());
          }
          await Global.setpsHostHomePageOrder(newOrder);
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
              color: Colors.white,
            ),
          );
        },
      ),
    );
  }
}
