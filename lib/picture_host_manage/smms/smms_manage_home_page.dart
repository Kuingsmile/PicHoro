import 'package:flutter/material.dart';
import 'package:fluro/fluro.dart';
import 'package:horopic/picture_host_manage/common/info_page_utils.dart';

import 'package:horopic/router/application.dart';
import 'package:horopic/router/routers.dart';
import 'package:horopic/picture_host_manage/common/loading_state.dart' as loading_state;
import 'package:horopic/picture_host_manage/manage_api/smms_manage_api.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/widgets/common_widgets.dart';

class SmmsManageHomePage extends StatefulWidget {
  const SmmsManageHomePage({super.key});

  @override
  SmmsManageHomePageState createState() => SmmsManageHomePageState();
}

class SmmsManageHomePageState extends loading_state.BaseLoadingPageState<SmmsManageHomePage>
    with SingleTickerProviderStateMixin {
  Map userProfile = {};
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
      var profileMap = await SmmsManageAPI().getUserProfile();
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
      flogErr(e, {}, "SmmsManageHomePageState", "initProfile");
      if (mounted) {
        setState(() {
          state = loading_state.LoadState.error;
        });
      }
    }
  }

  @override
  AppBar get appBar => AppBar(
        elevation: 0,
        centerTitle: true,
        title: titleText('SM.MS图床'),
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

  @override
  Widget buildSuccess() {
    double usagePercentage = 0.0;
    if (userProfile.containsKey('disk_usage_raw') && userProfile.containsKey('disk_limit_raw')) {
      usagePercentage = (userProfile['disk_usage_raw'] as int) / (userProfile['disk_limit_raw'] as int);
      usagePercentage = usagePercentage.clamp(0.0, 1.0);
    }

    return FadeTransition(
      opacity: _fadeInAnimation,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileCard(),
                  const SizedBox(height: 20),
                  _buildStatsOverview(usagePercentage),
                  const SizedBox(height: 20),
                  _buildStorageSection(usagePercentage),
                  const SizedBox(height: 20),
                  _buildFeatureCards(),
                ],
              ),
            ),
          ),
        ],
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
            colors: [Color(0xFF2962FF), Color(0xFF0D47A1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          children: [
            // Background decoration
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

            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Avatar and name row
                  Row(
                    children: [
                      Hero(
                        tag: 'profile_avatar',
                        child: Container(
                          decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 8, spreadRadius: 2)
                          ]),
                          child: CircleAvatar(
                            radius: 35,
                            backgroundColor: Colors.white.withValues(alpha: 0.2),
                            child: CircleAvatar(
                              radius: 32,
                              backgroundColor: Colors.blue.shade300,
                              child: Text(
                                (userProfile['username'].toString()).isNotEmpty
                                    ? (userProfile['username'].toString()).substring(0, 1).toUpperCase()
                                    : "U",
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userProfile['username']?.toString() ?? "用户名",
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 5),
                            Text(
                              userProfile['email']?.toString() ?? "邮箱",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withValues(alpha: 0.9),
                                letterSpacing: 0.3,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Member status
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color:
                          userProfile['role'] == 'VIP' ? const Color(0xFFFFD700) : Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            userProfile['role'] == 'VIP' ? Icons.workspace_premium : Icons.person_outline,
                            color: userProfile['role'] == 'VIP' ? Colors.brown.shade900 : Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            userProfile['role'] == 'VIP' ? 'VIP会员' : '免费用户',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: userProfile['role'] == 'VIP' ? Colors.brown.shade900 : Colors.white,
                            ),
                          ),
                        ],
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

  Widget _buildStatsOverview(double usagePercentage) {
    return Row(
      children: [
        _buildStatCard(
          icon: Icons.cloud_upload,
          value: userProfile['role'] == 'VIP' ? '10 MB' : '5 MB',
          label: '文件上传限制',
          color: Colors.purple,
        ),
        const SizedBox(width: 16),
        _buildStatCard(
          icon: Icons.bar_chart,
          value: '${(usagePercentage * 100).toStringAsFixed(1)}%',
          label: '空间使用率',
          color: usagePercentage > 0.9
              ? Colors.red
              : usagePercentage > 0.7
                  ? Colors.orange
                  : Colors.green,
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

  Widget _buildStorageSection(double usagePercentage) {
    Color progressColor = usagePercentage > 0.9
        ? Colors.red
        : usagePercentage > 0.7
            ? Colors.orange
            : Colors.green;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.storage_rounded,
                  color: Colors.blue.shade700,
                  size: 22,
                ),
                const SizedBox(width: 8),
                const Text(
                  "存储空间",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Storage progress indicator
            Stack(
              children: [
                // Background track
                Container(
                  height: 18,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(9),
                  ),
                ),

                // Progress bar
                FractionallySizedBox(
                  widthFactor: usagePercentage,
                  child: Container(
                    height: 18,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          progressColor.withValues(alpha: 0.7),
                          progressColor,
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(9),
                      boxShadow: [
                        BoxShadow(
                          color: progressColor.withValues(alpha: 0.4),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),

                // Percentage text
                Center(
                  child: Container(
                    height: 18,
                    alignment: Alignment.center,
                    child: Text(
                      '${(usagePercentage * 100).toStringAsFixed(1)}%',
                      style: TextStyle(
                        color: usagePercentage > 0.5 ? Colors.white : Colors.black87,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Usage details
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStorageDetail(
                    icon: Icons.cloud_done,
                    label: "已用空间",
                    value: userProfile['disk_usage']?.toString() ?? "0",
                    color: Colors.blue,
                  ),
                  _buildStorageDetail(
                    icon: Icons.cloud_queue,
                    label: "总空间",
                    value: userProfile['disk_limit']?.toString() ?? "0",
                    color: Colors.indigo,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStorageDetail({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            "功能",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // File Explorer Card
        buildFeatureCard(
          icon: Icons.folder_open_rounded,
          title: '文件管理',
          subtitle: '查看和管理您上传的所有文件',
          color: Colors.blue,
          onTap: () {
            Application.router
                .navigateTo(context, Routes.smmsFileExplorer, transition: TransitionType.cupertino)
                .then((value) => setState(() {
                      initProfile();
                    }));
          },
        ),
      ],
    );
  }
}
