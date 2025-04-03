import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:horopic/picture_host_manage/common/rename_dialog_widgets.dart';
import 'package:horopic/widgets/common_widgets.dart';
import 'package:minio/models.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:fluro/fluro.dart';

import 'package:horopic/router/application.dart';
import 'package:horopic/router/routers.dart';
import 'package:horopic/picture_host_manage/common/loading_state.dart' as loading_state;
import 'package:horopic/picture_host_manage/manage_api/aws_manage_api.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/utils/global.dart';

class AwsBucketList extends StatefulWidget {
  const AwsBucketList({super.key});

  @override
  AwsBucketListState createState() => AwsBucketListState();
}

class AwsBucketListState extends loading_state.BaseLoadingPageState<AwsBucketList> {
  List bucketMap = [];

  RefreshController refreshController = RefreshController(initialRefresh: false);
  TextEditingController vc = TextEditingController();

  @override
  void initState() {
    super.initState();
    _onRefresh();
  }

  @override
  dispose() {
    refreshController.dispose();
    super.dispose();
  }

  //下拉刷新
  _onRefresh() async {
    initBucketList();
  }

  //初始化bucketList
  initBucketList() async {
    bucketMap.clear();
    try {
      var bucketListResponse = await AwsManageAPI().getBucketList();
      //判断是否获取成功
      if (bucketListResponse[0] != 'success') {
        if (mounted) {
          setState(() {
            state = loading_state.LoadState.error;
          });
        }
        refreshController.refreshCompleted();
        return;
      }
      if (bucketListResponse[1].isEmpty) {
        if (mounted) {
          setState(() {
            state = loading_state.LoadState.empty;
          });
        }
        refreshController.refreshCompleted();
        return;
      }
      var allBucketList = bucketListResponse[1] as List<Bucket>;

      for (Bucket element in allBucketList) {
        String formatedTime = element.creationDate.toString().toString().replaceAll('Z', '').substring(0, 19);

        bucketMap.add({
          'name': element.name,
          'group': '存储桶',
          'CreationDate': formatedTime,
        });
      }
      for (var i = 0; i < bucketMap.length; i++) {
        if (Global.bucketCustomUrl.containsKey('s3-${bucketMap[i]['name']}')) {
          bucketMap[i]['customUrl'] = Global.bucketCustomUrl['s3-${bucketMap[i]['name']}'];
        } else {
          bucketMap[i]['customUrl'] = '';
        }
        var regionResponse = await AwsManageAPI().getBucketRegion(bucketMap[i]['name']);
        if (regionResponse[0] != 'success') {
          bucketMap[i]['region'] = 'None';
        } else {
          bucketMap[i]['region'] = regionResponse[1];
        }
      }

      if (mounted) {
        setState(() {
          if (bucketMap.isEmpty) {
            state = loading_state.LoadState.empty;
          } else {
            state = loading_state.LoadState.success;
          }
          refreshController.refreshCompleted();
        });
      }
    } catch (e) {
      flogErr(e, {}, 'AwsBucketListState', 'initBucketList');
      if (mounted) {
        setState(() {
          state = loading_state.LoadState.error;
        });
      }
      showToast('获取失败');
      refreshController.refreshCompleted();
    }
  }

  countBucketLocation(List elements, String location) {
    Map<String, int> locationCount = {};
    for (var i = 0; i < elements.length; i++) {
      if (locationCount.containsKey(elements[i]['region'])) {
        locationCount[elements[i]['region']] = locationCount[elements[i]['region']]! + 1;
      } else {
        locationCount[elements[i]['region']] = 1;
      }
    }
    return locationCount[location];
  }

  @override
  AppBar get appBar => AppBar(
        elevation: 0,
        centerTitle: true,
        leading: getLeadingIcon(context),
        title: titleText('S3存储桶列表'),
        flexibleSpace: getFlexibleSpace(context),
        actions: [
          IconButton(
            onPressed: () async {
              await Application.router
                  .navigateTo(context, Routes.awsNewBucketConfig, transition: TransitionType.cupertino);
              _onRefresh();
            },
            icon: const Icon(
              Icons.add,
              color: Colors.white,
            ),
            iconSize: 35,
          )
        ],
      );

  @override
  String get emptyText => '没有存储桶，点击右上角添加哦';

  @override
  void onErrorRetry() {
    setState(() {
      state = loading_state.LoadState.loading;
    });
    initBucketList();
  }

  @override
  Widget buildSuccess() {
    return SmartRefresher(
        enablePullDown: true,
        enablePullUp: false,
        header: const ClassicHeader(
          refreshStyle: RefreshStyle.Follow,
          idleText: '下拉刷新',
          refreshingText: '正在刷新',
          completeText: '刷新完成',
          failedText: '刷新失败',
          releaseText: '释放刷新',
        ),
        footer: const ClassicFooter(
          loadStyle: LoadStyle.ShowWhenLoading,
          idleText: '上拉加载',
          loadingText: '正在加载',
          noDataText: '没有更多了',
          failedText: '没有更多了',
          canLoadingText: '释放加载',
        ),
        controller: refreshController,
        onRefresh: _onRefresh,
        child: GroupedListView(
          shrinkWrap: true,
          elements: bucketMap,
          groupBy: (element) => element['region'].toString(),
          itemComparator: (item1, item2) => item1['CreationDate'].compareTo(item2['CreationDate']),
          groupComparator: (value1, value2) => value2.compareTo(value1),
          separator: const SizedBox(height: 6),
          groupSeparatorBuilder: (String value) => Container(
            margin: const EdgeInsets.only(top: 10, bottom: 5),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.2),
                  spreadRadius: 1,
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.cloud, color: Colors.blue.shade700, size: 20),
                const SizedBox(width: 8),
                Text(
                  value == 'None'
                      ? '区域：未获取(${countBucketLocation(bucketMap, value)})'
                      : '区域：$value(${countBucketLocation(bucketMap, value)})',
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          itemBuilder: (context, element) {
            return Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    IconData(0xe6ab, fontFamily: 'iconfont'),
                    color: Colors.blue,
                    size: 28,
                  ),
                ),
                title: Text(
                  element['name'],
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            element['CreationDate'],
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.link,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              element['customUrl'] == '' ? '未设置自定义域名' : element['customUrl'],
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                onTap: () async {
                  Application.router.navigateTo(context,
                      '${Routes.awsFileExplorer}?element=${Uri.encodeComponent(jsonEncode(element))}&bucketPrefix=${Uri.encodeComponent('')}',
                      transition: TransitionType.cupertino);
                },
                trailing: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.more_horiz_outlined, color: Colors.blue),
                  ),
                  onPressed: () async {
                    showModalBottomSheet(
                        isScrollControlled: true,
                        context: context,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        builder: (context) {
                          return buildBottomSheetWidget(context, element);
                        });
                  },
                ),
              ),
            );
          },
          order: GroupedListOrder.DESC,
        ));
  }

  Widget buildBottomSheetWidget(BuildContext context, Map element) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 5,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withValues(alpha: 0.1),
                        spreadRadius: 1,
                        blurRadius: 3,
                      ),
                    ],
                  ),
                  child: const Icon(
                    IconData(0xe6ab, fontFamily: 'iconfont'),
                    color: Colors.blue,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        element['name'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        element['CreationDate'],
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 10),
          _buildActionTile(
            icon: Icons.link_sharp,
            iconColor: Colors.blue,
            title: '设置自定义域名',
            onTap: () async {
              Navigator.pop(context);
              showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (context) {
                    return RenameDialog(
                      contentWidget: RenameDialogContent(
                        title: Global.bucketCustomUrl['s3-${element['name']}'] == ''
                            ? '设置自定义域名'
                            : Global.bucketCustomUrl['s3-${element['name']}'] == null
                                ? '设置自定义域名'
                                : Global.bucketCustomUrl['s3-${element['name']}']!.length > 20
                                    ? '${Global.bucketCustomUrl['s3-${element['name']}']!.substring(0, 20)}...'
                                    : Global.bucketCustomUrl['s3-${element['name']}']!,
                        onConfirm: (bool isCoverFile) async {
                          if (!vc.text.startsWith(RegExp(r'http|https'))) {
                            showToast('域名必须以http或https开头');
                            return;
                          }
                          bucketMap[bucketMap.indexOf(element)]['customUrl'] = vc.text;
                          Global.bucketCustomUrl['s3-${element['name']}'] = vc.text;
                          Global.setBucketCustomUrl(Global.bucketCustomUrl);
                          showToast('设置成功');
                        },
                        renameTextController: vc,
                        onCancel: () {},
                      ),
                    );
                  });
            },
          ),
          _buildActionTile(
            icon: Icons.check_box_outlined,
            iconColor: Colors.green,
            title: '设为默认图床',
            onTap: () async {
              var result = await AwsManageAPI().setDefaultBucket(element, null);
              if (result[0] == 'success') {
                showToast('设置成功');
                if (mounted) {
                  Navigator.pop(context);
                }
              } else {
                showToast('设置失败');
              }
            },
          ),
          const Divider(height: 10),
          _buildActionTile(
            icon: Icons.dangerous_outlined,
            iconColor: Colors.red,
            title: '删除存储桶',
            onTap: () async {
              Navigator.pop(context);
              return showCupertinoAlertDialogWithConfirmFunc(
                title: '删除存储桶',
                content: '是否删除存储桶？\n删除前请清空该存储桶!',
                context: context,
                onConfirm: () async {
                  try {
                    var result = await AwsManageAPI().deleteBucket(element);
                    if (result[0] == 'success') {
                      showToast('删除成功');
                      _onRefresh();
                    } else {
                      showToast('删除失败');
                    }
                  } catch (e) {
                    flogErr(
                        e,
                        {
                          'element': element,
                        },
                        'AwsBucketListPage',
                        'buildBottomSheetWidget_deleteBucket');
                    showToast('删除失败');
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    VoidCallback? onTap,
    Widget? rightWidget,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 15),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            rightWidget ?? const SizedBox(),
          ],
        ),
      ),
    );
  }
}
