import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/utils/global.dart';
import 'package:horopic/utils/sql_utils.dart';

class DefaultPShostSelect extends StatefulWidget {
  const DefaultPShostSelect({Key? key}) : super(key: key);

  @override
  DefaultPShostSelectState createState() => DefaultPShostSelectState();
}

class DefaultPShostSelectState extends State<DefaultPShostSelect> {
  @override
  void initState() {
    super.initState();
  }

  final List<String> allPBhostToSelect = [
    'lsky.pro',
    'sm.ms',
    'github',
    'imgur',
    'qiniu',
    'tencent',
    'aliyun',
    'upyun',
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
              await setdefaultPShostRemoteAndLocal('lsky.pro');
              setState(() {});
            },
          ),
          ListTile(
            title: const Text('SM.MS'),
            trailing: Global.defaultPShost == 'sm.ms'
                ? const Icon(Icons.check)
                : null,
            onTap: () async {
              await setdefaultPShostRemoteAndLocal('sm.ms');
              setState(() {});
            },
          ),
          ListTile(
            title: const Text('Github图床'),
            trailing: Global.defaultPShost == 'github'
                ? const Icon(Icons.check)
                : null,
            onTap: () async {
              await setdefaultPShostRemoteAndLocal('github');
              setState(() {});
            },
          ),
          ListTile(
            title: const Text('Imgur图床'),
            trailing: Global.defaultPShost == 'imgur'
                ? const Icon(Icons.check)
                : null,
            onTap: () async {
              await setdefaultPShostRemoteAndLocal('imgur');
              setState(() {});
            },
          ),
          ListTile(
            title: const Text('七牛云'),
            trailing: Global.defaultPShost == 'qiniu'
                ? const Icon(Icons.check)
                : null,
            onTap: () async {
              await setdefaultPShostRemoteAndLocal('qiniu');
              setState(() {});
            },
          ),
          ListTile(
            title: const Text('腾讯云'),
            trailing: Global.defaultPShost == 'tencent'
                ? const Icon(Icons.check)
                : null,
            onTap: () async {
              await setdefaultPShostRemoteAndLocal('tencent');
              setState(() {});
            },
          ),
          ListTile(
            title: const Text('阿里云'),
            trailing: Global.defaultPShost == 'aliyun'
                ? const Icon(Icons.check)
                : null,
            onTap: () async {
              await setdefaultPShostRemoteAndLocal('aliyun');
              setState(() {});
            },
          ),
          ListTile(
            title: const Text('又拍云'),
            trailing: Global.defaultPShost == 'upyun'
                ? const Icon(Icons.check)
                : null,
            onTap: () async {
              await setdefaultPShostRemoteAndLocal('upyun');
              setState(() {});
            },
          ),
        ],
      ),
    );
  }
}

setdefaultPShostRemoteAndLocal(String psHost) async {
  //图床名和查询函数对应字典
  Map<String, Function> queryFunc = {
    'lsky.pro': MySqlUtils.queryLankong,
    'sm.ms': MySqlUtils.querySmms,
    'github': MySqlUtils.queryGithub,
    'imgur': MySqlUtils.queryImgur,
    'qiniu': MySqlUtils.queryQiniu,
    'tencent': MySqlUtils.queryTencent,
    'aliyun': MySqlUtils.queryAliyun,
    'upyun': MySqlUtils.queryUpyun,
  };

  try {
    String defaultUser = await Global.getUser();
    String defaultPassword = await Global.getPassword();
    var queryuser = await MySqlUtils.queryUser(username: defaultUser);

    if (queryuser == 'Empty') {
      return Fluttertoast.showToast(
          msg: "请先注册用户",
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 2,
          fontSize: 16.0);
    } else if (queryuser['password'] != defaultPassword) {
      return Fluttertoast.showToast(
          msg: "请先登录",
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 2,
          fontSize: 16.0);
    }
    var querypsHost = await queryFunc[psHost]!(username: defaultUser);
    if (querypsHost == 'Empty') {
      return Fluttertoast.showToast(
          msg: "请先配置上传参数",
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 2,
          fontSize: 16.0);
    }
    if (querypsHost == 'Error') {
      return Fluttertoast.showToast(
          msg: "Error",
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 2,
          fontSize: 16.0);
    }
    if (queryuser['defaultPShost'] == psHost) {
      await Global.setPShost(psHost);
      if (psHost == 'lsky.pro') {
        await Global.setShowedPBhost('lskypro');
      } else if (psHost == 'sm.ms') {
        await Global.setShowedPBhost('smms');
      } else if (psHost == 'github') {
        await Global.setShowedPBhost('github');
      } else if (psHost == 'imgur') {
        await Global.setShowedPBhost('imgur');
      } else if (psHost == 'qiniu') {
        await Global.setShowedPBhost('qiniu');
      } else if (psHost == 'tencent') {
        await Global.setShowedPBhost('tencent');
      } else if (psHost == 'aliyun') {
        await Global.setShowedPBhost('aliyun');
      } else if (psHost == 'upyun') {
        await Global.setShowedPBhost('upyun');
      }
      return Fluttertoast.showToast(
          msg: "已经是默认配置",
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 2,
          fontSize: 16.0);
    } else {
      List sqlconfig = [];
      sqlconfig.add(defaultUser);
      sqlconfig.add(defaultPassword);
      sqlconfig.add(psHost);

      var updateResult = await MySqlUtils.updateUser(content: sqlconfig);

      if (updateResult == 'Success') {
        await Global.setPShost(psHost);
        if (psHost == 'lsky.pro') {
          await Global.setShowedPBhost('lskypro');
        } else if (psHost == 'sm.ms') {
          await Global.setShowedPBhost('smms');
        } else if (psHost == 'github') {
          await Global.setShowedPBhost('github');
        } else if (psHost == 'imgur') {
          await Global.setShowedPBhost('imgur');
        } else if (psHost == 'qiniu') {
          await Global.setShowedPBhost('qiniu');
        } else if (psHost == 'tencent') {
          await Global.setShowedPBhost('tencent');
        } else if (psHost == 'aliyun') {
          await Global.setShowedPBhost('aliyun');
        } else if (psHost == 'upyun') {
          await Global.setShowedPBhost('upyun');
        }
        showToast('已设置$psHost为默认图床');
      } else {
        showToast('写入数据库失败');
      }
    }
  } catch (e) {
    showToast('错误');
  }
}
