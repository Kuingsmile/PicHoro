import 'package:flutter/material.dart';

//import 'package:flutter_uploader/flutter_uploader.dart';
import 'package:fluro/fluro.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:horopic/configure_page/others/theme_data.dart';

import 'package:horopic/router/application.dart';
import 'package:horopic/router/routers.dart';
import 'package:horopic/utils/global.dart';
import 'package:horopic/utils/permission.dart';
import 'package:horopic/utils/theme_provider.dart';

/*
@Author: Horo
@e-mail: ma_shiqing@163.com
@Date: 2022-10-26
@Description:PicHoro, a picture upload tool 
@version: 1.8.2
*/

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //请求权限
  await Permissionutils.askPermission();
  await Permissionutils.askPermissionCamera();
  await Permissionutils.askPermissionGallery();
  await Permissionutils.askPermissionManageExternalStorage();
  await Permissionutils.askPermissionMediaLibrary();
  //初始化全局信息，会在APP启动时执行
  String initUser = await Global.getUser();
  await Global.setUser(initUser);
  String initPassword = await Global.getPassword();
  await Global.setPassword(initPassword);
  String initPShost = await Global.getPShost();
  await Global.setPShost(initPShost);
  String initLKformat = await Global.getLKformat();
  await Global.setLKformat(initLKformat);
  bool initIsTimeStamp = await Global.getTimeStamp();
  await Global.setTimeStamp(initIsTimeStamp);
  bool initIsRandomName = await Global.getRandomName();
  await Global.setRandomName(initIsRandomName);
  bool initIsCopyLink = await Global.getCopyLink();
  await Global.setCopyLink(initIsCopyLink);
  String initShowedPBhost = await Global.getShowedPBhost();
  await Global.setShowedPBhost(initShowedPBhost);
  bool isDeleteLocal = await Global.getDeleteLocal();
  await Global.setDeleteLocal(isDeleteLocal);
  String initCustomLinkFormat = await Global.getCustomLinkFormat();
  await Global.setCustomLinkFormat(initCustomLinkFormat);
  bool isDeleteCloud = await Global.getDeleteCloud();
  await Global.setDeleteCloud(isDeleteCloud);
  bool iscustomRename = await Global.getCustomeRename();
  await Global.setCustomeRename(iscustomRename);
  String initCustomRenameFormat = await Global.getCustomeRenameFormat();
  await Global.setCustomeRenameFormat(initCustomRenameFormat);

  //初始化图床相册数据库
  Database db = await Global.getDatabase();
  await Global.setDatabase(db);

  //初始化路由
  FluroRouter router = FluroRouter();
  Application.router = router;
  Routes.configureRoutes(router);
  //初始化图床管理页面排列顺序
  List<String> psHostHomePageOrder = await Global.getpsHostHomePageOrder();
  await Global.setpsHostHomePageOrder(psHostHomePageOrder);
  //设定loading样式
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..loadingStyle = EasyLoadingStyle.custom
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..progressColor = Colors.blue
    ..backgroundColor = Colors.white
    ..indicatorColor = Colors.blue
    ..textColor = Colors.blue
    ..maskColor = Colors.blue.withOpacity(0.5)
    ..userInteractions = false
    ..dismissOnTap = false;

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: AppInfoProvider()),
      ],
      child: Consumer<AppInfoProvider>(builder: (context, appInfo, child) {
        return appInfo.themeColor == 'light'
            ? MaterialApp(
                title: 'PicHoro',
                debugShowCheckedModeBanner: false,
                theme: lightThemeData,
                initialRoute: '/',
                onGenerateRoute: Application.router.generator,
                builder: EasyLoading.init(),
              )
            : MaterialApp(
                title: 'PicHoro',
                debugShowCheckedModeBanner: false,
                theme: darkThemeData,
                initialRoute: '/',
                onGenerateRoute: Application.router.generator,
                builder: EasyLoading.init(),
              );
      }),
    );
  }
}
