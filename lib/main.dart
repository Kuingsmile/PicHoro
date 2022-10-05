import 'package:flutter/material.dart';
import 'package:horopic/pages/themeSet.dart';
import 'package:horopic/pages/homePage.dart';
import 'package:horopic/utils/global.dart';
import 'package:provider/provider.dart';
import 'package:horopic/utils/themeProvider.dart';

/*
@Author: Horo
@e-mail: ma_shiqing@163.com
@Date: 2022-10-05
@Description:PicHoro, a picture upload tool 
@version: 1.3.0
*/

initGLobal() async {}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  String initUSer = await Global.getUser();
  await Global.setUser(initUSer);
  String initPassword = await Global.getPassword();
  await Global.setPassword(initPassword);
  String initPShost = await Global.getPShost();
  await Global.setPShost(initPShost);
  await initGLobal();

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
