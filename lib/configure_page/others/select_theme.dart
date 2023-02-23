import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:horopic/utils/theme_provider.dart';
import 'package:horopic/utils/common_functions.dart';

class ChangeTheme extends StatefulWidget {
  const ChangeTheme({Key? key}) : super(key: key);

  @override
  ChangeThemeState createState() => ChangeThemeState();
}

class ChangeThemeState extends State<ChangeTheme> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar:
            AppBar(elevation: 0, centerTitle: true, title: titleText('主题设置')),
        body: Consumer<AppInfoProvider>(builder: (context, appinfo, child) {
          return ListView(
            children: [
              ListTile(
                title: const Text('自动(8:00~22:00)'),
                trailing: appinfo.keyThemeColor == 'auto'
                    ? const Icon(Icons.check)
                    : null,
                onTap: () {
                  appinfo.setTheme('auto');
                },
              ),
              ListTile(
                title: const Text('浅色主题'),
                trailing: appinfo.keyThemeColor == 'light'
                    ? const Icon(Icons.check)
                    : null,
                onTap: () {
                  appinfo.setTheme('light');
                },
              ),
              ListTile(
                title: const Text('深色主题'),
                trailing: appinfo.keyThemeColor == 'dark'
                    ? const Icon(Icons.check)
                    : null,
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
                  SizedBox(
                    width: 30,
                    height: 40,
                    child: Container(
                      color: Colors.green,
                      child: TextButton(
                        onPressed: () {
                          appinfo.setTheme('green');
                        },
                        child: const Text(''),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  SizedBox(
                    width: 30,
                    height: 40,
                    child: Container(
                      color: Colors.purple,
                      child: GestureDetector(
                        onTap: () {
                          appinfo.setTheme('purple');
                        },
                        child: const Text(''),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  SizedBox(
                    width: 30,
                    height: 40,
                    child: Container(
                      color: Colors.orange,
                      child: GestureDetector(
                        onTap: () {
                          appinfo.setTheme('orange');
                        },
                        child: const Text(''),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  SizedBox(
                    width: 30,
                    height: 40,
                    child: Container(
                      color: const Color.fromARGB(255, 241, 160, 187),
                      child: GestureDetector(
                        onTap: () {
                          appinfo.setTheme('pink');
                        },
                        child: const Text(''),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  SizedBox(
                    width: 30,
                    height: 40,
                    child: Container(
                      color: Colors.cyan,
                      child: GestureDetector(
                        onTap: () {
                          appinfo.setTheme('cyan');
                        },
                        child: const Text(''),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  SizedBox(
                    width: 30,
                    height: 40,
                    child: Container(
                      color: const Color.fromARGB(255, 255, 215, 0),
                      child: GestureDetector(
                        onTap: () {
                          appinfo.setTheme('gold');
                        },
                        child: const Text(''),
                      ),
                    ),
                  ),
                ],
              )
            ],
          );
        }));
  }
}
