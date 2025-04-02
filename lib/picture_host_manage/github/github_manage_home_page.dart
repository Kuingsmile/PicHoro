import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluro/fluro.dart';

import 'package:horopic/router/application.dart';
import 'package:horopic/picture_host_manage/common/loading_state.dart' as loading_state;
import 'package:horopic/picture_host_manage/manage_api/github_manage_api.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/widgets/common_widgets.dart';

class GithubManageHomePage extends StatefulWidget {
  const GithubManageHomePage({super.key});

  @override
  GithubManageHomePageState createState() => GithubManageHomePageState();
}

class GithubManageHomePageState extends loading_state.BaseLoadingPageState<GithubManageHomePage>
    with SingleTickerProviderStateMixin {
  Map userProfile = {};
  TextEditingController otherusernameController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    initProfile();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  initProfile() async {
    try {
      var profileMap = await GithubManageAPI().getUserInfo();
      if (profileMap[0] == 'success') {
        userProfile = profileMap[1];
        state = loading_state.LoadState.success;
        _animationController.forward();
      } else {
        state = loading_state.LoadState.error;
      }
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      flogErr(e, {}, 'GithubManageHomePageState', 'initProfile');
      if (mounted) {
        setState(() {
          state = loading_state.LoadState.error;
        });
      }
      showToast('获取用户信息失败');
    }
  }

  getUserAvatar() async {
    var profileMap = await GithubManageAPI().getUserInfo();
    if (profileMap[0] == 'success') {
      return profileMap[1]['avatar_url'];
    }
  }

  @override
  AppBar get appBar => AppBar(
        elevation: 0,
        centerTitle: true,
        leading: getLeadingIcon(context),
        title: titleText('Github 个人信息'),
        flexibleSpace: getFlexibleSpace(context),
      );

  @override
  String get emptyText => '暂无数据';

  @override
  void onErrorRetry() {
    setState(() {
      state = loading_state.LoadState.loading;
    });
    initProfile();
  }

  Widget otherRepo() {
    return StatefulBuilder(builder: (BuildContext context, void Function(void Function()) setState) {
      return CupertinoAlertDialog(
        title: Container(
          margin: const EdgeInsets.only(bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.account_circle, color: Colors.blue, size: 22),
              const SizedBox(width: 8),
              const Text('查看他人仓库', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.blue)),
            ],
          ),
        ),
        content: Column(
          children: [
            CupertinoTextField(
              controller: otherusernameController,
              placeholder: '请输入GitHub用户名',
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              prefix: Container(
                padding: const EdgeInsets.only(left: 8),
                child: const Icon(Icons.person, color: Colors.blue, size: 18),
              ),
              style: const TextStyle(fontSize: 16),
              clearButtonMode: OverlayVisibilityMode.editing,
            ),
          ],
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('取消', style: TextStyle(color: Colors.grey)),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('确定', style: TextStyle(fontWeight: FontWeight.bold)),
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
    return FadeTransition(
      opacity: _fadeInAnimation,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildProfileCard(),
            const SizedBox(height: 20),
            _buildStatsOverview(),
            const SizedBox(height: 20),
            _buildRepositorySection(),
            const SizedBox(height: 20),
            _buildUserInfoSections(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Card(
      elevation: 8,
      shadowColor: Colors.blue.withValues(alpha: 0.4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2196F3), Color(0xFF1565C0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              left: -15,
              bottom: -15,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      FutureBuilder(
                        future: getUserAvatar(),
                        builder: (BuildContext context, AsyncSnapshot snapshot) {
                          return Hero(
                            tag: 'github-avatar',
                            child: Container(
                              decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [
                                BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 8, spreadRadius: 2)
                              ]),
                              child: CircleAvatar(
                                radius: 35,
                                backgroundColor: Colors.white.withValues(alpha: 0.2),
                                child: CircleAvatar(
                                  radius: 32,
                                  backgroundColor: Colors.white,
                                  backgroundImage: snapshot.hasData
                                      ? NetworkImage(snapshot.data)
                                      : const AssetImage('assets/icons/github.png') as ImageProvider,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userProfile['name'] ?? userProfile['login']?.toString() ?? "用户名",
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (userProfile['name'] != null && userProfile['login'] != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 5),
                                child: Text(
                                  '@${userProfile['login']}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white.withValues(alpha: 0.9),
                                    letterSpacing: 0.3,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Bio
                  if (userProfile['bio'] != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        userProfile['bio'],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.95),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsOverview() {
    return Row(
      children: [
        _buildStatCard(
          icon: Icons.people,
          value: userProfile['followers'] == null ? '0' : userProfile['followers'].toString(),
          label: '粉丝',
          color: Colors.indigo,
        ),
        const SizedBox(width: 16),
        _buildStatCard(
          icon: Icons.person_add,
          value: userProfile['following'] == null ? '0' : userProfile['following'].toString(),
          label: '关注',
          color: Colors.blue,
        ),
        const SizedBox(width: 16),
        _buildStatCard(
          icon: Icons.folder_open,
          value: userProfile['public_repos'] == null ? '0' : userProfile['public_repos'].toString(),
          label: '仓库',
          color: Colors.teal,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 12),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRepositorySection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.folder_open_outlined, color: Colors.blue),
              ),
              title: const Text('我的仓库', style: TextStyle(fontWeight: FontWeight.w500)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 18),
              onTap: () async {
                Application.router
                    .navigateTo(context, '/githubReposList?showedUsername=${Uri.encodeComponent(userProfile['login'])}',
                        transition: TransitionType.cupertino)
                    .then((value) => setState(() {
                          initProfile();
                        }));
              },
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.folder_shared_outlined, color: Colors.green),
              ),
              title: const Text('他人仓库', style: TextStyle(fontWeight: FontWeight.w500)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 18),
              onTap: () async {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return otherRepo();
                    });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfoSections() {
    // Group information into sections
    List<Map<String, dynamic>> infoSections = [
      {
        'title': '基本信息',
        'icon': Icons.info_outline,
        'items': [
          {'icon': Icons.person, 'title': '登录ID', 'value': userProfile['login'].toString()},
          {'icon': Icons.person_outline, 'title': '用户名', 'value': userProfile['name'] ?? '未设置'},
          {'icon': Icons.fingerprint, 'title': 'ID', 'value': userProfile['id'].toString()},
          {'icon': Icons.code, 'title': 'node_id', 'value': userProfile['node_id'].toString()},
        ]
      },
      {
        'title': '联系方式',
        'icon': Icons.contact_mail,
        'items': [
          {'icon': Icons.email, 'title': '邮箱', 'value': userProfile['email'] ?? '未设置'},
          {'icon': Icons.location_on, 'title': '所在地', 'value': userProfile['location'] ?? '未设置'},
          {'icon': Icons.bubble_chart, 'title': 'Twitter', 'value': userProfile['twitter_username'] ?? '未设置'},
        ]
      },
      {
        'title': '链接',
        'icon': Icons.link,
        'items': [
          {'icon': Icons.link, 'title': '个人主页', 'value': userProfile['blog'] ?? '未设置', 'isLong': true},
          {'icon': Icons.link_sharp, 'title': 'GitHub主页', 'value': userProfile['html_url'] ?? '未设置', 'isLong': true},
        ]
      },
      {
        'title': '时间信息',
        'icon': Icons.access_time,
        'items': [
          {
            'icon': Icons.calendar_month_outlined,
            'title': '创建时间',
            'value': userProfile['created_at'] != null
                ? userProfile['created_at'].replaceAll('T', ' ').replaceAll('Z', '')
                : '无数据'
          },
          {
            'icon': Icons.calendar_month_outlined,
            'title': '更新时间',
            'value': userProfile['updated_at'] != null
                ? userProfile['updated_at'].replaceAll('T', ' ').replaceAll('Z', '')
                : '无数据'
          },
        ]
      },
    ];

    return Column(
      children: infoSections.map((section) => _buildInfoSection(context, section)).toList(),
    );
  }

  Widget _buildInfoSection(BuildContext context, Map<String, dynamic> section) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Icon(section['icon'], color: Colors.blue, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    section['title'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1, indent: 16, endIndent: 16),
            ...section['items'].map<Widget>((item) => _buildInfoItem(context, item)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, Map<String, dynamic> item) {
    final bool isLongValue = item['isLong'] == true;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(item['icon'], color: Colors.blue, size: 20),
        ),
        title: Text(item['title'], style: TextStyle(fontSize: 15, color: Colors.grey[800])),
        subtitle: isLongValue
            ? SelectableText(
                item['value'],
                style: TextStyle(fontSize: 14, color: Colors.blue[700]),
              )
            : null,
        trailing: !isLongValue
            ? Container(
                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.4),
                child: SelectableText(
                  item['value'],
                  style: TextStyle(fontSize: 14, color: Colors.blue[700]),
                  textAlign: TextAlign.right,
                ),
              )
            : null,
      ),
    );
  }
}
