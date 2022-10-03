import 'package:flutter/material.dart';
import 'package:horopic/hostconfig.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:horopic/AlertDialog.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:horopic/pages/author.dart';
import 'package:url_launcher/url_launcher.dart';

//a configure page for user to show configure entry
class ConfigurePage extends StatefulWidget {
  const ConfigurePage({Key? key}) : super(key: key);

  @override
  _ConfigurePageState createState() => _ConfigurePageState();
}

class _ConfigurePageState extends State<ConfigurePage> {
  String version = ' ';
  final Uri uri = Uri.parse('https://github.com/Kuingsmile/PicHoro');
  @override
  void initState() {
    super.initState();
    _getVersion();
  }

  void _getVersion() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    setState(() {
      version = info.version;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          '配置页面',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      child: CircleAvatar(
                        radius: MediaQuery.of(context).size.width / 6,
                        backgroundColor: Colors.grey,
                        backgroundImage:
                            const Image(image: AssetImage('assets/favicon.jpg'))
                                .image,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Text('v$version'),
                    )
                  ],
                ),
              ),
            ),
          ),
          ListTile(
            title: const Text('图床参数设置'),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const HostConfig()));
            },
            trailing: const Icon(Icons.arrow_forward_ios),
          ),
          ListTile(
            title: const Text('项目地址'),
            onTap: () {
              launchUrl(uri);
            },
            trailing: const Icon(Icons.arrow_forward_ios),
          ),
          ListTile(
            title: const Text('联系作者'),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AuthorInformation()));
            },
            trailing: const Icon(Icons.arrow_forward_ios),
          ),
        ],
      ),
    );
  }
}
