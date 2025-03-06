import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluro/fluro.dart';
import 'package:f_logs/f_logs.dart';

import 'package:horopic/router/application.dart';
import 'package:horopic/router/routers.dart';
import 'package:horopic/picture_host_manage/common_page/loading_state.dart' as loading_state;
import 'package:horopic/picture_host_manage/manage_api/lskypro_manage_api.dart';
import 'package:horopic/utils/common_functions.dart';

class LskyproManageHomePage extends StatefulWidget {
  const LskyproManageHomePage({super.key});

  @override
  LskyproManageHomePageState createState() => LskyproManageHomePageState();
}

class LskyproManageHomePageState extends loading_state.BaseLoadingPageState<LskyproManageHomePage> {
  Map userProfile = {};
  Map albumInfo = {};

  @override
  void initState() {
    super.initState();
    initProfile();
  }

  initProfile() async {
    try {
      var profileMap = await LskyproManageAPI.getUserInfo();
      if (profileMap[0] == 'success') {
        userProfile = profileMap[1]['data'];
        state = loading_state.LoadState.SUCCESS;
      } else {
        state = loading_state.LoadState.ERROR;
      }
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      FLog.error(
          className: 'LskyproManageHomePageState',
          methodName: 'initProfile',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      if (mounted) {
        setState(() {
          state = loading_state.LoadState.ERROR;
        });
      }
      showToast('获取用户信息失败');
    }
  }

  @override
  AppBar get appBar => AppBar(
        elevation: 0,
        centerTitle: true,
        title: titleText('兰空图床信息'),
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
          const Text('暂无数据', style: TextStyle(fontSize: 20, color: Color.fromARGB(136, 121, 118, 118)))
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
          const Text('加载失败', style: TextStyle(fontSize: 20, color: Color.fromARGB(136, 121, 118, 118))),
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(Colors.blue),
            ),
            onPressed: () {
              setState(() {
                state = loading_state.LoadState.LOADING;
              });
            },
            child: const Text('重新加载'),
          )
        ],
      ),
    );
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

  @override
  Widget buildSuccess() {
    return ListView(children: [
      Center(
        child: Padding(
          padding: const EdgeInsets.all(3.0),
          child: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: MediaQuery.of(context).size.width / 10,
                  backgroundColor: Colors.transparent,
                  backgroundImage: const Image(image: AssetImage('assets/icons/lskypro.png')).image,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
      Column(
        children: [
          ListTile(
            leading: const Icon(Icons.folder_open_outlined, color: Colors.blue),
            minLeadingWidth: 0,
            title: const Text('文件管理'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () async {
              Application.router
                  .navigateTo(context,
                      '${Routes.lskyproFileExplorer}?userProfile=${Uri.encodeComponent(jsonEncode(userProfile))}&albumInfo=${Uri.encodeComponent(jsonEncode(albumInfo))}',
                      transition: TransitionType.cupertino)
                  .then((value) => setState(() {
                        initProfile();
                      }));
            },
          ),
          ListTile(
            leading: const Icon(Icons.person, color: Colors.blue),
            minLeadingWidth: 0,
            title: const Text('用户名'),
            trailing: Text(userProfile['name'] == null ? '未知' : userProfile['name'].toString(),
                style: const TextStyle(fontSize: 15)),
          ),
          ListTile(
            leading: const Icon(Icons.email, color: Colors.blue),
            minLeadingWidth: 0,
            title: const Text('邮箱'),
            trailing: Text(userProfile['email'] == null ? '未知' : userProfile['email'].toString(),
                style: const TextStyle(fontSize: 15)),
          ),
          ListTile(
            leading: const Icon(Icons.data_usage, color: Colors.blue),
            minLeadingWidth: 0,
            title: const Text('已用空间'),
            trailing: Text(getFileSize(int.parse(userProfile['used_capacity'].toString().split('.')[0]) * 1000),
                style: const TextStyle(fontSize: 15)),
          ),
          ListTile(
            leading: const Icon(Icons.storage, color: Colors.blue),
            minLeadingWidth: 0,
            title: const Text('总空间'),
            trailing: Text(getFileSize(int.parse(userProfile['capacity'].toString().split('.')[0]) * 1000),
                style: const TextStyle(fontSize: 15)),
          ),
          ListTile(
            leading: const Icon(Icons.photo, color: Colors.blue),
            minLeadingWidth: 0,
            title: const Text('已保存图片数'),
            trailing: Text(userProfile['image_num'] == null ? '未知' : userProfile['image_num'].toString(),
                style: const TextStyle(fontSize: 15)),
          ),
          ListTile(
            leading: const Icon(Icons.photo_album_outlined, color: Colors.blue),
            minLeadingWidth: 0,
            title: const Text('相册数'),
            trailing: Text(userProfile['album_num'] == null ? '未知' : userProfile['album_num'].toString(),
                style: const TextStyle(fontSize: 15)),
          ),
        ],
      ),
    ]);
  }
}
