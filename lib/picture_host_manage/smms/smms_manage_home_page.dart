import 'package:flutter/material.dart';
import 'package:fluro/fluro.dart';
import 'package:f_logs/f_logs.dart';

import 'package:horopic/router/application.dart';
import 'package:horopic/router/routers.dart';
import 'package:horopic/picture_host_manage/common_page/loading_state.dart' as loading_state;
import 'package:horopic/picture_host_manage/manage_api/smms_manage_api.dart';
import 'package:horopic/utils/common_functions.dart';

class SmmsManageHomePage extends StatefulWidget {
  const SmmsManageHomePage({super.key});

  @override
  SmmsManageHomePageState createState() => SmmsManageHomePageState();
}

class SmmsManageHomePageState extends loading_state.BaseLoadingPageState<SmmsManageHomePage> {
  Map userProfile = {};

  @override
  void initState() {
    super.initState();
    initProfile();
  }

  initProfile() async {
    try {
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
        title: titleText('SM.MS图床信息'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColor.withValues(alpha: 0.8)],
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
          const Text('暂无数据',
              style: TextStyle(fontSize: 18, color: Color.fromARGB(136, 121, 118, 118), fontWeight: FontWeight.w500)),
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
          Icon(Icons.error_outline, size: 60, color: Colors.red.shade300),
          const SizedBox(height: 16),
          const Text('加载失败',
              style: TextStyle(fontSize: 18, color: Color.fromARGB(136, 121, 118, 118), fontWeight: FontWeight.w500)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: const Icon(Icons.refresh),
            label: const Text('重新加载'),
            onPressed: () {
              setState(() {
                state = loading_state.LoadState.LOADING;
                initProfile();
              });
            },
          )
        ],
      ),
    );
  }

  @override
  Widget buildLoading() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation(Colors.blue),
            ),
          ),
          SizedBox(height: 16),
          Text('加载中...', style: TextStyle(fontSize: 16, color: Colors.blue, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  @override
  Widget buildSuccess() {
    // Calculate storage usage percentage
    double usagePercentage = 0.0;
    if (userProfile.containsKey('disk_usage') &&
        userProfile.containsKey('disk_limit') &&
        userProfile['disk_usage'] is num &&
        userProfile['disk_limit'] is String) {
      // Extract just the number from disk_limit (assuming it's in format like "XXXX MB")
      String limitStr = userProfile['disk_limit'].toString();
      final RegExp regex = RegExp(r'(\d+)');
      final match = regex.firstMatch(limitStr);
      if (match != null) {
        String numStr = match.group(1) ?? "0";
        int limitValue = int.tryParse(numStr) ?? 1;
        num usageValue = userProfile['disk_usage'] as num;
        usagePercentage = (usageValue / limitValue).clamp(0.0, 1.0);
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF1A73E8),
                  Color(0xFF6C92F4),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.shade300.withValues(alpha: 0.4),
                  blurRadius: 12,
                  spreadRadius: 0,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white.withValues(alpha: 0.3),
                  child: Text(
                    (userProfile['username']?.toString() ?? "U").substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  userProfile['username']?.toString() ?? "用户",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        blurRadius: 2,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  userProfile['email']?.toString() ?? "",
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color:
                        userProfile['role'] == 'VIP' ? const Color(0xFFFFC107) : Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    userProfile['role'] == 'VIP' ? 'VIP会员' : '免费用户',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: userProfile['role'] == 'VIP' ? Colors.brown.shade900 : Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Storage Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "存储空间",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: usagePercentage,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation(usagePercentage > 0.9
                      ? Colors.red
                      : usagePercentage > 0.7
                          ? Colors.orange
                          : Colors.green),
                  minHeight: 10,
                  borderRadius: BorderRadius.circular(5),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "已用: ${userProfile['disk_usage']?.toString() ?? '0'} MB",
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    Text(
                      "总共: ${userProfile['disk_limit']?.toString() ?? '0 MB'}",
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "最大上传文件限制: ${userProfile['role'] == 'VIP' ? '10 MB' : '5 MB'}",
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // File Management Card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.folder_open_outlined, color: Colors.blue),
              ),
              title: const Text('文件管理', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('查看和管理您上传的所有文件'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Application.router
                    .navigateTo(context, Routes.smmsFileExplorer, transition: TransitionType.cupertino)
                    .then((value) => setState(() {
                          initProfile();
                        }));
              },
            ),
          ),
        ],
      ),
    );
  }
}
