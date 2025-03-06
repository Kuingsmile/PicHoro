import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:horopic/utils/theme_provider.dart';
import 'package:horopic/utils/common_functions.dart';

class ChangeTheme extends StatefulWidget {
  const ChangeTheme({super.key});

  @override
  ChangeThemeState createState() => ChangeThemeState();
}

class ChangeThemeState extends State<ChangeTheme> {
  static const Map<String, dynamic> themeColor = {
    'green': Colors.green,
    'purple': Colors.purple,
    'orange': Colors.orange,
    'pink': Color.fromARGB(255, 241, 160, 187),
    'cyan': Colors.cyan,
    'gold': Color.fromARGB(255, 255, 215, 0),
  };

  Widget _buildSizeBoxItem(String key, AppInfoProvider appinfo) {
    return SizedBox(
      width: 30,
      height: 40,
      child: Container(
        color: themeColor[key],
        child: GestureDetector(
          onTap: () {
            appinfo.setTheme(key);
          },
          child: const Text(''),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(elevation: 0, centerTitle: true, title: titleText('主题设置')),
        body: Consumer<AppInfoProvider>(builder: (context, appinfo, child) {
          return ListView(
            children: [
              ListTile(
                title: const Text('自动(8:00~22:00)'),
                trailing: appinfo.keyThemeColor == 'auto' ? const Icon(Icons.check) : null,
                onTap: () {
                  appinfo.setTheme('auto');
                },
              ),
              ListTile(
                title: const Text('浅色主题'),
                trailing: appinfo.keyThemeColor == 'light' ? const Icon(Icons.check) : null,
                onTap: () {
                  appinfo.setTheme('light');
                },
              ),
              ListTile(
                title: const Text('深色主题'),
                trailing: appinfo.keyThemeColor == 'dark' ? const Icon(Icons.check) : null,
                onTap: () {
                  appinfo.setTheme('dark');
                },
              ),
              const SizedBox(
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSizeBoxItem('green', appinfo),
                  const SizedBox(
                    width: 10,
                  ),
                  _buildSizeBoxItem('purple', appinfo),
                  const SizedBox(
                    width: 10,
                  ),
                  _buildSizeBoxItem('orange', appinfo),
                  const SizedBox(
                    width: 10,
                  ),
                  _buildSizeBoxItem('pink', appinfo),
                  const SizedBox(
                    width: 10,
                  ),
                  _buildSizeBoxItem('cyan', appinfo),
                  const SizedBox(
                    width: 10,
                  ),
                  _buildSizeBoxItem('gold', appinfo),
                ],
              )
            ],
          );
        }));
  }
}
