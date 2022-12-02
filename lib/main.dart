import 'package:f_logs/f_logs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';

import 'package:horopic/router/application.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/utils/theme_provider.dart';


/*
@Author: Kuingsmile@Github
@HomePage: https://www.horosama.com
@e-mail: ma_shiqing@163.com
@Date: 2022-12-02
@Description:PicHoro,一款云储存平台和图床管理工具
@version: 1.9.6
*/

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await mainInit();
  } catch (e) {
    FLog.error(
        className: 'main',
        methodName: 'mainInit',
        text: formatErrorMessage({}, e.toString()),
        dataLogType: DataLogType.ERRORS.toString());
  }

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
        return MaterialApp(
          title: 'PicHoro',
          debugShowCheckedModeBanner: false,
          theme: themeDataMap[appInfo.keyThemeColor]!,
          initialRoute: '/',
          onGenerateRoute: Application.router.generator,
          builder: EasyLoading.init(),
        );
      }),
    );
  }
}
