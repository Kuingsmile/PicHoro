import 'package:flutter/material.dart';
import 'package:flustars_flutter3/flustars_flutter3.dart';
import 'package:provider/provider.dart';
import 'package:horopic/utils/theme_provider.dart';

class ChangeTheme extends StatefulWidget {
  const ChangeTheme({Key? key}) : super(key: key);

  @override
  _ChangeThemeState createState() => _ChangeThemeState();
}

class _ChangeThemeState extends State<ChangeTheme> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('主题设置'),
        ),
        body: Consumer<AppInfoProvider>(builder: (context, appinfo, child) {
          return ListView(
            children: [
              ListTile(
                title: const Text('自动(8:00~22:00)'),
                trailing: appinfo.key_theme_color == 'auto'
                    ? const Icon(Icons.check)
                    : null,
                onTap: () {
                  appinfo.setTheme('auto');
                },
              ),
              ListTile(
                title: const Text('浅色主题'),
                trailing: appinfo.key_theme_color == 'light'
                    ? const Icon(Icons.check)
                    : null,
                onTap: () {
                  appinfo.setTheme('light');
                },
              ),
              ListTile(
                title: const Text('深色主题'),
                trailing: appinfo.key_theme_color == 'dark'
                    ? const Icon(Icons.check)
                    : null,
                onTap: () {
                  appinfo.setTheme('dark');
                },
              ),
            ],
          );
        }));
  }
}
