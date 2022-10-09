import 'package:flutter/material.dart';
import 'package:horopic/pages/themeSet.dart';
import 'package:horopic/pages/homePage.dart';
import 'package:horopic/utils/global.dart';
import 'package:provider/provider.dart';
import 'package:horopic/utils/themeProvider.dart';
import 'package:horopic/utils/permission.dart';
import 'package:horopic/album/albumSQL.dart';
import 'package:sqflite/sqflite.dart';
/*
@Author: Horo
@e-mail: ma_shiqing@163.com
@Date: 2022-10-09
@Description:PicHoro, a picture upload tool 
@version: 1.5.0
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

  //初始化数据库
  Database db = await Global.getDatabase();
  await Global.setDatabase(db);

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: AppInfoProvider()),
      ],
      child: Consumer<AppInfoProvider>(builder: (context, appInfo, child) {
        return MaterialApp(
          title: 'PicHoro',
          debugShowCheckedModeBanner: false,
          theme: appInfo.themeColor == 'light' ? lightThemeData : darkThemeData,
          home: const HomePage(),
        );
      }),
    );
  }
}
