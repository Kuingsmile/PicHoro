import 'package:f_logs/f_logs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:horopic/utils/system_font_provider.dart';
import 'package:provider/provider.dart';

import 'package:horopic/router/application.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/utils/theme_provider.dart';

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
  const MyApp({super.key});

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
        NativeFeatures.loadSystemFont();
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
