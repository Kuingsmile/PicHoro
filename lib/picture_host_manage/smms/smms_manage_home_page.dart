import 'package:flutter/material.dart';
import 'package:fluro/fluro.dart';
import 'package:f_logs/f_logs.dart';

import 'package:horopic/router/application.dart';
import 'package:horopic/router/routers.dart';
import 'package:horopic/picture_host_manage/common_page/loading_state.dart'
    as loading_state;
import 'package:horopic/picture_host_manage/manage_api/smms_manage_api.dart';
import 'package:horopic/utils/global.dart';
import 'package:horopic/utils/sql_utils.dart';
import 'package:horopic/utils/common_functions.dart';

class SmmsManageHomePage extends StatefulWidget {
  const SmmsManageHomePage({Key? key}) : super(key: key);

  @override
  SmmsManageHomePageState createState() => SmmsManageHomePageState();
}

class SmmsManageHomePageState
    extends loading_state.BaseLoadingPageState<SmmsManageHomePage> {
  Map userProfile = {};

  @override
  void initState() {
    super.initState();
    initProfile();
  }

  initProfile() async {
    try {
      String currentUser = await Global.getUser();
      String defaultPassword = await Global.getPassword();
      var queryuser = await MySqlUtils.queryUser(username: currentUser);
      if (queryuser == 'Empty') {
        setState(() {
          state = loading_state.LoadState.ERROR;
        });
        return showToast('请先登录');
      } else if (queryuser['password'] != defaultPassword) {
        setState(() {
          state = loading_state.LoadState.ERROR;
        });
        return showToast('请先登录');
      }
      var querySmms = await MySqlUtils.querySmms(username: currentUser);
      if (querySmms == 'Empty') {
        setState(() {
          state = loading_state.LoadState.ERROR;
        });
        return showToast('请先去配置SM.MS');
      }
      var profileMap = await SmmsManageAPI.getUserProfile();
      if (profileMap[0] == 'success') {
        userProfile = profileMap[1];
        state = loading_state.LoadState.SUCCESS;
      } else {
        state = loading_state.LoadState.ERROR;
      }
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      FLog.error(
          className: 'SmmsManageHomePageState',
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
        title: const Text('SM.MS图床信息'),
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
          const Text('暂无数据',
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
    //a user profile page
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
                  backgroundImage:
                      const Image(image: AssetImage('assets/icons/smms.png'))
                          .image,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
      Column(
        children: [
          Container(
            color: const Color.fromARGB(255, 255, 247, 222),
            child: ListTile(
              leading:
                  const Icon(Icons.folder_open_outlined, color: Colors.blue),
              minLeadingWidth: 0,
              title: const Text('文件管理'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Application.router
                    .navigateTo(context, Routes.smmsFileExplorer,
                        transition: TransitionType.cupertino)
                    .then((value) => setState(() {
                          initProfile();
                        }));
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person, color: Colors.blue),
            minLeadingWidth: 0,
            title: const Text('用户名'),
            trailing: Text(userProfile['username'].toString(),
                style: const TextStyle(fontSize: 15)),
          ),
          ListTile(
            leading: const Icon(Icons.email, color: Colors.blue),
            minLeadingWidth: 0,
            title: const Text('邮箱'),
            trailing: Text(userProfile['email'],
                style: const TextStyle(fontSize: 15)),
          ),
          ListTile(
            leading: const Icon(Icons.data_usage, color: Colors.blue),
            minLeadingWidth: 0,
            title: const Text('已用空间'),
            trailing: Text(userProfile['disk_usage'].toString(),
                style: const TextStyle(fontSize: 15)),
          ),
          ListTile(
            leading: const Icon(Icons.storage, color: Colors.blue),
            minLeadingWidth: 0,
            title: const Text('总空间'),
            trailing: Text(userProfile['disk_limit'],
                style: const TextStyle(fontSize: 15)),
          ),
          ListTile(
            leading: const Icon(Icons.diamond, color: Colors.blue),
            minLeadingWidth: 0,
            title: const Text('SM.MS会员'),
            trailing: Text(userProfile['role'] == 'VIP' ? '是' : '否',
                style: const TextStyle(fontSize: 15)),
          ),
          ListTile(
            leading: const Icon(Icons.file_upload_outlined, color: Colors.blue),
            minLeadingWidth: 0,
            title: const Text('最大上传文件大小'),
            trailing: Text(userProfile['role'] == 'VIP' ? '10 MB' : '5 MB',
                style: const TextStyle(fontSize: 15)),
          ),
        ],
      ),
    ]);
  }
}
