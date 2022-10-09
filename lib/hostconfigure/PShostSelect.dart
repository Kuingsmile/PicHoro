import 'package:flutter/material.dart';
import 'package:horopic/utils/global.dart';

class defaultPShostSelect extends StatefulWidget {
  const defaultPShostSelect({Key? key}) : super(key: key);

  @override
  _defaultPShostSelectState createState() => _defaultPShostSelectState();
}

class _defaultPShostSelectState extends State<defaultPShostSelect> {
  @override
  void initState() {
    super.initState();
  }

  final List<String> allPBhostToSelect = [
    'lsky.pro',
    'sm.ms',
    'github',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('默认图床选择'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('兰空图床'),
            trailing: Global.defaultPShost == 'lsky.pro'
                ? const Icon(Icons.check)
                : null,
            onTap: () async {
              await Global.setPShost('lsky.pro');
              setState(() {});
            },
          ),
          ListTile(
            title: const Text('SM.MS'),
            trailing: Global.defaultPShost == 'sm.ms'
                ? const Icon(Icons.check)
                : null,
            onTap: () async {
              await Global.setPShost('sm.ms');
              setState(() {});
            },
          ),
        ],
      ),
    );
  }
}
