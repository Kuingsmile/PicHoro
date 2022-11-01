import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:fluro/fluro.dart';
import 'package:f_logs/f_logs.dart';

import 'package:horopic/router/application.dart';
import 'package:horopic/router/routers.dart';
import 'package:horopic/utils/global.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/picture_host_manage/common_page/loading_state.dart'
    as loading_state;

class PictureHostInfoPage extends StatefulWidget {
  const PictureHostInfoPage({Key? key}) : super(key: key);

  @override
  PictureHostInfoPageState createState() => PictureHostInfoPageState();
}

class PictureHostInfoPageState
    extends loading_state.BaseLoadingPageState<PictureHostInfoPage> {
  Map pictureHostInfo = {};
  List configList = [];
  final Map<String, String> psNameTranslate = {
    'smms': 'SM.MS',
    'tcyun': '腾讯云',
    'aliyun': '阿里云',
    'qiniu': '七牛云',
    'upyun': '又拍云',
    'github': 'GitHub',
    'imgur': 'Imgur',
    'lankong': '兰空图床',
  };
  final Map<String, dynamic> psNameRouterMap = {
    'smms': Routes.smmsPShostSelect,
    'tcyun': Routes.tencentPShostSelect,
    'aliyun': Routes.aliyunPShostSelect,
    'qiniu': Routes.qiniuPShostSelect,
    'upyun': Routes.upyunPShostSelect,
    'github': Routes.githubPShostSelect,
    'imgur': Routes.imgurPShostSelect,
    'lankong': Routes.lskyproPShostSelect,
  };

  @override
  void initState() {
    super.initState();
    initPictureHostInfo();
  }

  initPictureHostInfo() async {
    try {
      Directory directory = await getApplicationDocumentsDirectory();
      String configPath = directory.path;
      String defaultUser = await Global.getUser();
      Map<String, dynamic> configFilePath = {
        "smms": "$configPath/${defaultUser}_smms_config.txt",
        "lankong": "$configPath/${defaultUser}_host_config.txt",
        "github": "$configPath/${defaultUser}_github_config.txt",
        "imgur": "$configPath/${defaultUser}_imgur_config.txt",
        "qiniu": "$configPath/${defaultUser}_qiniu_config.txt",
        "tcyun": "$configPath/${defaultUser}_tencent_config.txt",
        "aliyun": "$configPath/${defaultUser}_aliyun_config.txt",
        "upyun": "$configPath/${defaultUser}_upyun_config.txt",
      };
      List pictureHostInfoList = [
        'smms',
        'lankong',
        'github',
        'imgur',
        'qiniu',
        'tcyun',
        'aliyun',
        'upyun'
      ];

      for (var i = 0; i < pictureHostInfoList.length; i++) {
        try {
          String config = await File(configFilePath[pictureHostInfoList[i]]!)
              .readAsString();
          Map<String, dynamic> configMap = jsonDecode(config);
          Map configMap2 = {pictureHostInfoList[i]: configMap};
          String configJson = jsonEncode(configMap2);
          configJson = configJson.replaceAll('None', '');
          configJson = configJson.replaceAll('keyId', 'accessKeyId');
          configJson = configJson.replaceAll('keySecret', 'accessKeySecret');
          configList.add(configJson);
        } catch (e) {
          FLog.error(
              className: 'PictureHostInfoPageState',
              methodName: 'initPictureHostInfo_1',
              text: formatErrorMessage({
                'pictureHostInfoList': pictureHostInfoList[i],
              }, e.toString()),
              dataLogType: DataLogType.ERRORS.toString());
        }
      }
      if (configList.isEmpty) {
        state = loading_state.LoadState.EMPTY;
      } else {
        state = loading_state.LoadState.SUCCESS;
      }
      setState(() {});
    } catch (e) {
      FLog.error(
          className: 'PictureHostInfoPageState',
          methodName: 'initPictureHostInfo_2',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      if (mounted) {
        setState(() {
          state = loading_state.LoadState.ERROR;
        });
      }
    }
  }

  @override
  AppBar get appBar => AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text('图床配置'),
      );

  @override
  Widget buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/empty.png',
            width: 100,
            height: 100,
          ),
          const Text('没有配置图床，快去配置吧',
              style: TextStyle(
                  fontSize: 20, color: Color.fromARGB(136, 121, 118, 118)))
        ],
      ),
    );
  }

  @override
  Widget buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('加载失败',
              style: TextStyle(
                  fontSize: 20, color: Color.fromARGB(136, 121, 118, 118))),
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.blue),
            ),
            onPressed: () {
              setState(() {
                state = loading_state.LoadState.LOADING;
              });
              initPictureHostInfo();
            },
            child: const Text('重新加载'),
          )
        ],
      ),
    );
  }

  iconProvider(String pshost) {
    Map iconMap = {
      'smms': 'assets/icons/smms.png',
      'lankong': 'assets/icons/lskypro.png',
      'github': 'assets/icons/github.png',
      'imgur': 'assets/icons/fakesmms.png',
      'qiniu': 'assets/icons/qiniu.png',
      'tcyun': 'assets/icons/tcyun.png',
      'aliyun': 'assets/icons/aliyun.png',
      'upyun': 'assets/icons/upyun.png',
    };
    return Image.asset(iconMap[pshost]!, width: 30, height: 30);
  }

  @override
  Widget buildLoading() {
    return const Center(
      child: SizedBox(
        width: 30,
        height: 30,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          backgroundColor: Colors.transparent,
          valueColor: AlwaysStoppedAnimation(Colors.blue),
        ),
      ),
    );
  }

  List<Widget> buildPsInfoListTile(Map pictureHostInfo) {
    String psName = pictureHostInfo.keys.first;
    List keys = pictureHostInfo[psName].keys.toList();
    List values = pictureHostInfo[psName].values.toList();
    List<Widget> psInfoListTile = [];
    psInfoListTile.add(
      ListTile(
        title: Center(
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          iconProvider(psName),
          const SizedBox(
            width: 10,
          ),
          Text(psNameTranslate[psName]!),
        ])),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Colors.blue,
        ),
        onTap: () {
          Application.router.navigateTo(context, psNameRouterMap[psName]!,
              transition: TransitionType.cupertino);
        },
      ),
    );
    for (var i = 0; i < keys.length; i++) {
      if (values[i] != '') {
        psInfoListTile.add(Table(
          children: [
            TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: SelectableText(keys[i],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.black,
                      )),
                ),
                SelectableText(values[i],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.black54,
                    )),
              ],
            ),
          ],
        ));
        if (i != keys.length - 1) {
          psInfoListTile.add(const Divider(
            height: 2,
            color: Colors.transparent,
          ));
        }
      }
    }
    psInfoListTile.add(const Divider(
      height: 2,
      color: Colors.black,
    ));
    return psInfoListTile;
  }

  buildAllPsInfoListTile(List configList) {
    List<Widget> allPsInfoListTile = [];
    for (var i = 0; i < configList.length; i++) {
      Map pictureHostInfo = jsonDecode(configList[i]);
      allPsInfoListTile.addAll(buildPsInfoListTile(pictureHostInfo));
    }
    return allPsInfoListTile;
  }

  @override
  Widget buildSuccess() {
    return ListView(
      children: buildAllPsInfoListTile(configList),
    );
  }
}
