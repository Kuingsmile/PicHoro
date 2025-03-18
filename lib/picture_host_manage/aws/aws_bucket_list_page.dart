import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:horopic/picture_host_manage/common/rename_dialog_widgets.dart';
import 'package:horopic/widgets/common_widgets.dart';
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
      var bucketListResponse = await AwsManageAPI.getBucketList();
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
      var allBucketList = bucketListResponse[1];

      for (var element in allBucketList) {
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
        var regionResponse = await AwsManageAPI.getBucketRegion(bucketMap[i]['name']);
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
          groupBy: (element) => element['region'],
          itemComparator: (item1, item2) => item1['CreationDate'].compareTo(item2['CreationDate']),
          groupComparator: (value1, value2) => value2.compareTo(value1),
          separator: const Divider(
            height: 0.1,
            color: Color.fromARGB(255, 230, 230, 230),
          ),
          groupSeparatorBuilder: (String value) => Container(
            height: 30,
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 184, 182, 182),
              border: Border(
                bottom: BorderSide(
                  color: Color.fromARGB(255, 230, 230, 230),
                  width: 0.1,
                ),
              ),
            ),
            child: ListTile(
              visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
              title: Text(
                value == 'None'
                    ? '区域：未获取(${countBucketLocation(bucketMap, value)})'
                    : '区域：$value(${countBucketLocation(bucketMap, value)})',
                style: const TextStyle(
                  height: 0.3,
                  color: Colors.black,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          itemBuilder: (context, element) {
            return ListTile(
                minLeadingWidth: 0,
                contentPadding: const EdgeInsets.only(left: 20, right: 20),
                leading: const Icon(
                  IconData(0xe6ab, fontFamily: 'iconfont'),
                  color: Colors.blue,
                  size: 35,
                ),
                title: Text(element['name']),
                subtitle: Text(element['CreationDate']),
                onTap: () async {
                  Application.router.navigateTo(context,
                      '${Routes.awsFileExplorer}?element=${Uri.encodeComponent(jsonEncode(element))}&bucketPrefix=${Uri.encodeComponent('')}',
                      transition: TransitionType.cupertino);
                },
                trailing: IconButton(
                  icon: const Icon(Icons.more_horiz_outlined),
                  onPressed: () async {
                    showModalBottomSheet(
                        isScrollControlled: true,
                        context: context,
                        builder: (context) {
                          return buildBottomSheetWidget(context, element);
                        });
                  },
                ));
          },
          order: GroupedListOrder.DESC,
        ));
  }

  Widget buildBottomSheetWidget(BuildContext context, Map element) {
    return SingleChildScrollView(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(
              IconData(0xe6ab, fontFamily: 'iconfont'),
              color: Colors.blue,
            ),
            visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
            minLeadingWidth: 0,
            title: Text(
              element['name'],
              style: const TextStyle(fontSize: 14),
            ),
            subtitle: Text(element['CreationDate'], style: const TextStyle(fontSize: 12)),
          ),
          const Divider(
            height: 0.1,
            color: Color.fromARGB(255, 230, 230, 230),
          ),
          ListTile(
            leading: const Icon(
              Icons.link_sharp,
              color: Color.fromARGB(255, 97, 141, 236),
            ),
            minLeadingWidth: 0,
            title: const Text('设置自定义链接', style: TextStyle(fontSize: 15)),
            onTap: () async {
              Navigator.pop(context);
              showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (context) {
                    return RenameDialog(
                      contentWidget: RenameDialogContent(
                        title: Global.bucketCustomUrl['s3-${element['name']}'] == ''
                            ? '设置自定义链接'
                            : Global.bucketCustomUrl['s3-${element['name']}'] == null
                                ? '设置自定义链接'
                                : Global.bucketCustomUrl['s3-${element['name']}']!.length > 20
                                    ? '${Global.bucketCustomUrl['s3-${element['name']}']!.substring(0, 20)}...'
                                    : Global.bucketCustomUrl['s3-${element['name']}']!,
                        onConfirm: (bool isCoverFile) async {
                          if (!vc.text.startsWith(RegExp(r'http|https'))) {
                            showToast('链接必须以http或https开头');
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
          const Divider(
            height: 0.1,
            color: Color.fromARGB(255, 230, 230, 230),
          ),
          ListTile(
            leading: const Icon(
              Icons.check_box_outlined,
              color: Color.fromARGB(255, 97, 141, 236),
            ),
            minLeadingWidth: 0,
            title: const Text('设为默认图床', style: TextStyle(fontSize: 15)),
            onTap: () async {
              var result = await AwsManageAPI.setDefaultBucket(element, null);
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
          const Divider(
            height: 0.1,
            color: Color.fromARGB(255, 230, 230, 230),
          ),
          ListTile(
            leading: const Icon(
              Icons.dangerous_outlined,
              color: Color.fromARGB(255, 240, 85, 131),
            ),
            minLeadingWidth: 0,
            title: const Text('删除存储桶', style: TextStyle(fontSize: 15)),
            onTap: () async {
              Navigator.pop(context);
              return showCupertinoAlertDialogWithConfirmFunc(
                title: '删除存储桶',
                content: '是否删除存储桶？\n删除前请清空该存储桶!',
                context: context,
                onConfirm: () async {
                  try {
                    var result = await AwsManageAPI.deleteBucket(element);
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
}
