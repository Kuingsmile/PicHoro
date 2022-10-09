import 'package:flutter/material.dart';
import 'package:horopic/hostconfigure/hostconfig.dart';
import 'package:horopic/hostconfigure/smmsconfig.dart';
import 'package:horopic/hostconfigure/PShostSelect.dart';

//a configure page for user to show configure entry
class AllPShost extends StatefulWidget {
  const AllPShost({Key? key}) : super(key: key);

  @override
  _AllPShostState createState() => _AllPShostState();
}

class _AllPShostState extends State<AllPShost> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
            '图床设置',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: ListView(children: [
          ListTile(
            title: const Text('默认图床选择'),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const defaultPShostSelect()));
            },
            trailing: const Icon(Icons.arrow_forward_ios),
          ),
          ListTile(
            title: const Text('兰空图床'),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const HostConfig()));
            },
            trailing: const Icon(Icons.arrow_forward_ios),
          ),
          ListTile(
            title: const Text('SM.MS图床'),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const SmmsConfig()));
            },
            trailing: const Icon(Icons.arrow_forward_ios),
          ),
        ]));
  }
}
