import 'package:flutter/material.dart';
import 'package:flustars_flutter3/flustars_flutter3.dart';
import 'package:provider/provider.dart';
import 'package:horopic/utils/themeProvider.dart';
import 'package:horopic/pages/changeTheme.dart';
import 'package:horopic/pages/APPpassword.dart';

class CommonConfig extends StatefulWidget {
  const CommonConfig({Key? key}) : super(key: key);

  @override
  _CommonConfigState createState() => _CommonConfigState();
}

class _CommonConfigState extends State<CommonConfig> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('通用设置'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('主题设置'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const ChangeTheme()));
            },
          ),
          
        ],
      ),
    );
  }
}
