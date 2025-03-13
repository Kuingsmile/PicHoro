import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluro/fluro.dart';

import 'package:horopic/router/application.dart';
import 'package:horopic/picture_host_manage/common/loading_state.dart' as loading_state;
import 'package:horopic/picture_host_manage/manage_api/github_manage_api.dart';
import 'package:horopic/utils/common_functions.dart';

class GithubManageHomePage extends StatefulWidget {
  const GithubManageHomePage({super.key});

  @override
  GithubManageHomePageState createState() => GithubManageHomePageState();
}

class GithubManageHomePageState extends loading_state.BaseLoadingPageState<GithubManageHomePage> {
  Map userProfile = {};
  TextEditingController otherusernameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initProfile();
  }

  initProfile() async {
    try {
      var profileMap = await GithubManageAPI.getUserInfo();
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
      flogErr(e, {}, 'GithubManageHomePageState', 'initProfile');
      if (mounted) {
        setState(() {
          state = loading_state.LoadState.ERROR;
        });
      }
      showToast('获取用户信息失败');
    }
  }

  getUserAvatar() async {
    var profileMap = await GithubManageAPI.getUserInfo();
    if (profileMap[0] == 'success') {
      return profileMap[1]['avatar_url'];
    }
  }

  @override
  AppBar get appBar => AppBar(
        elevation: 0,
        centerTitle: true,
        title: titleText('Github 个人信息'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColor.withAlpha(204)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
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

  Widget otherRepo() {
    return StatefulBuilder(builder: (BuildContext context, void Function(void Function()) setState) {
      return CupertinoAlertDialog(
        title:
            const Text('请输入Github用户名', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue)),
        content: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            CupertinoTextField(
              textAlign: TextAlign.center,
              prefix: const Text('用户名：', style: TextStyle(fontSize: 16, color: Color.fromARGB(255, 121, 118, 118))),
              controller: otherusernameController,
              placeholder: '请输入Github用户名',
            ),
          ],
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('取消'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          CupertinoDialogAction(
            child: const Text('确定'),
            onPressed: () async {
              if (otherusernameController.text == '') {
                return showToast('请输入Github用户名');
              }
              Navigator.pop(context);
              Application.router.navigateTo(
                  context, '/githubReposList?showedUsername=${Uri.encodeComponent(otherusernameController.text)}',
                  transition: TransitionType.cupertino);
            },
          ),
        ],
      );
    });
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
                FutureBuilder(
                  future: getUserAvatar(),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      if (!snapshot.hasData) {
                        return CircleAvatar(
                            radius: MediaQuery.of(context).size.width / 10,
                            backgroundColor: Colors.transparent,
                            backgroundImage: const AssetImage('assets/icons/github.png'));
                      } else {
                        return CircleAvatar(
                          radius: MediaQuery.of(context).size.width / 10,
                          backgroundColor: Colors.transparent,
                          backgroundImage: NetworkImage(snapshot.data),
                        );
                      }
                    } else {
                      return SizedBox(
                          width: MediaQuery.of(context).size.width / 6,
                          height: MediaQuery.of(context).size.width / 6,
                          child: const CircularProgressIndicator(
                            strokeWidth: 4,
                            backgroundColor: Colors.transparent,
                            valueColor: AlwaysStoppedAnimation(Colors.blue),
                          ));
                    }
                  },
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
            title: const Text('我的仓库'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () async {
              Application.router
                  .navigateTo(context, '/githubReposList?showedUsername=${Uri.encodeComponent(userProfile['login'])}',
                      transition: TransitionType.cupertino)
                  .then((value) => setState(() {
                        initProfile();
                      }));
            },
          ),
          //他人仓库
          ListTile(
            leading: const Icon(Icons.folder_shared_outlined, color: Colors.blue),
            minLeadingWidth: 0,
            title: const Text('他人仓库'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () async {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return otherRepo();
                  });
            },
          ),
          ListTile(
            leading: const Icon(Icons.person, color: Colors.blue),
            minLeadingWidth: 0,
            title: const Text('登录ID'),
            trailing: SelectableText(userProfile['login'].toString(), style: const TextStyle(fontSize: 15)),
          ),
          ListTile(
            leading: const Icon(Icons.person_outline, color: Colors.blue),
            minLeadingWidth: 0,
            title: const Text('用户名'),
            trailing: SelectableText(userProfile['name'] ?? '未设置', style: const TextStyle(fontSize: 15)),
          ),
          ListTile(
            leading: const Icon(Icons.person_outline_sharp, color: Colors.blue),
            minLeadingWidth: 0,
            title: const Text('ID'),
            trailing: SelectableText(userProfile['id'].toString(), style: const TextStyle(fontSize: 15)),
          ),
          ListTile(
            leading: const Icon(Icons.person_outline_sharp, color: Colors.blue),
            minLeadingWidth: 0,
            title: const Text('node_id'),
            trailing: SelectableText(userProfile['node_id'].toString(), style: const TextStyle(fontSize: 15)),
          ),
          ListTile(
            leading: const Icon(Icons.person_outline_sharp, color: Colors.blue),
            minLeadingWidth: 0,
            title: const Text('头像链接'),
            subtitle: SelectableText(userProfile['avatar_url'] ?? '未设置', style: const TextStyle(fontSize: 15)),
          ),
          ListTile(
            leading: const Icon(Icons.email, color: Colors.blue),
            minLeadingWidth: 0,
            title: const Text('邮箱'),
            trailing: SelectableText(userProfile['email'] ?? '未设置', style: const TextStyle(fontSize: 15)),
          ),
          ListTile(
            leading: const Icon(Icons.location_on, color: Colors.blue),
            minLeadingWidth: 0,
            title: const Text('所在地'),
            trailing: SelectableText(userProfile['location'] ?? '未设置', style: const TextStyle(fontSize: 15)),
          ),
          ListTile(
            leading: const Icon(Icons.link, color: Colors.blue),
            minLeadingWidth: 0,
            title: const Text('个人主页'),
            subtitle: SelectableText(userProfile['blog'] ?? '未设置', style: const TextStyle(fontSize: 15)),
          ),
          ListTile(
            leading: const Icon(Icons.numbers, color: Colors.blue),
            minLeadingWidth: 0,
            title: const Text('公开仓库数'),
            trailing: SelectableText(
                userProfile['public_repos'] == null ? '无数据' : userProfile['public_repos'].toString(),
                style: const TextStyle(fontSize: 15)),
          ),
          ListTile(
            leading: const Icon(Icons.folder, color: Colors.blue),
            minLeadingWidth: 0,
            title: const Text('公开Gist数'),
            trailing: SelectableText(
                userProfile['public_gists'] == null ? '无数据' : userProfile['public_gists'].toString(),
                style: const TextStyle(fontSize: 15)),
          ),
          ListTile(
            leading: const Icon(Icons.person_add_alt, color: Colors.blue),
            minLeadingWidth: 0,
            title: const Text('关注数'),
            trailing: SelectableText(userProfile['following'] == null ? '无数据' : userProfile['following'].toString(),
                style: const TextStyle(fontSize: 15)),
          ),
          ListTile(
            leading: const Icon(Icons.person_add, color: Colors.blue),
            minLeadingWidth: 0,
            title: const Text('粉丝数'),
            trailing: SelectableText(userProfile['followers'] == null ? '无数据' : userProfile['followers'].toString(),
                style: const TextStyle(fontSize: 15)),
          ),
          ListTile(
            leading: const Icon(Icons.bubble_chart, color: Colors.blue),
            minLeadingWidth: 0,
            title: const Text('twitter用户名'),
            trailing: SelectableText(userProfile['twitter_username'] ?? '未设置', style: const TextStyle(fontSize: 15)),
          ),
          ListTile(
            leading: const Icon(Icons.link_sharp, color: Colors.blue),
            minLeadingWidth: 0,
            title: const Text('GitHub主页'),
            subtitle: SelectableText(userProfile['html_url'] ?? '未设置', style: const TextStyle(fontSize: 15)),
          ),
          ListTile(
            leading: const Icon(Icons.calendar_month_outlined, color: Colors.blue),
            minLeadingWidth: 0,
            title: const Text('创建时间'),
            trailing: SelectableText(userProfile['created_at'].replaceAll('T', ' ').replaceAll('Z', ''),
                style: const TextStyle(fontSize: 15)),
          ),
          ListTile(
            leading: const Icon(Icons.calendar_month_outlined, color: Colors.blue),
            minLeadingWidth: 0,
            title: const Text('更新时间'),
            trailing: SelectableText(userProfile['updated_at'].replaceAll('T', ' ').replaceAll('Z', ''),
                style: const TextStyle(fontSize: 15)),
          ),
        ],
      ),
    ]);
  }
}
