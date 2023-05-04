import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:fluro/fluro.dart';
import 'package:f_logs/f_logs.dart';

import 'package:horopic/router/application.dart';
import 'package:horopic/router/routers.dart';
import 'package:horopic/picture_host_manage/common_page/loading_state.dart' as loading_state;
import 'package:horopic/picture_host_manage/manage_api/tencent_manage_api.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/utils/global.dart';
import 'package:horopic/picture_host_manage/alist/alist_file_explorer.dart' show RenameDialog, RenameDialogContent;

class TencentBucketList extends StatefulWidget {
  const TencentBucketList({Key? key}) : super(key: key);

  @override
  TencentBucketListState createState() => TencentBucketListState();
}

class TencentBucketListState extends loading_state.BaseLoadingPageState<TencentBucketList> {
  List bucketMap = [];
  Map<String, String> aclState = {'aclState': '未获取'};

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
      var bucketListResponse = await TencentManageAPI.getBucketList();
      //判断是否获取成功
      if (bucketListResponse[0] != 'success') {
        if (mounted) {
          setState(() {
            state = loading_state.LoadState.ERROR;
          });
        }
        refreshController.refreshCompleted();
        return;
      }
      if (bucketListResponse[1]['ListAllMyBucketsResult']['Buckets'] == null) {
        if (mounted) {
          setState(() {
            state = loading_state.LoadState.EMPTY;
          });
        }
        refreshController.refreshCompleted();
        return;
      }
      var allBucketList = bucketListResponse[1]['ListAllMyBucketsResult']['Buckets']['Bucket'];

      if (allBucketList is! List) {
        allBucketList = [allBucketList];
      }

      for (var i = 0; i < allBucketList.length; i++) {
        String formatedTime = allBucketList[i]['CreationDate'].toString().replaceAll('T', ' ').replaceAll('Z', '');

        bucketMap.add({
          'name': allBucketList[i]['Name'],
          'location': allBucketList[i]['Location'],
          'CreationDate': formatedTime,
          'customUrl': Global.bucketCustomUrl.containsKey('tcyun-${allBucketList[i]['Name']}')
              ? Global.bucketCustomUrl['tcyun-${allBucketList[i]['Name']}']
              : '',
        });
      }
      if (mounted) {
        setState(() {
          if (bucketMap.isEmpty) {
            state = loading_state.LoadState.EMPTY;
          } else {
            state = loading_state.LoadState.SUCCESS;
          }
          refreshController.refreshCompleted();
        });
      }
    } catch (e) {
      FLog.error(
          className: 'TencentBucketListState',
          methodName: 'initBucketList',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      if (mounted) {
        setState(() {
          state = loading_state.LoadState.ERROR;
        });
      }
      showToast('获取失败');
      refreshController.refreshCompleted();
    }
  }

  countBucketLocation(List elements, String location) {
    Map<String, int> locationCount = {};
    for (var i = 0; i < elements.length; i++) {
      if (locationCount.containsKey(elements[i]['location'])) {
        locationCount[elements[i]['location']] = locationCount[elements[i]['location']]! + 1;
      } else {
        locationCount[elements[i]['location']] = 1;
      }
    }
    return locationCount[location];
  }

  @override
  AppBar get appBar => AppBar(
        elevation: 0,
        centerTitle: true,
        title: titleText('腾讯云存储桶列表'),
        actions: [
          IconButton(
            onPressed: () async {
              await Application.router
                  .navigateTo(context, Routes.tencentNewBucketConfig, transition: TransitionType.cupertino);
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
          const Text('没有存储桶，点击右上角添加哦', style: TextStyle(fontSize: 20, color: Color.fromARGB(136, 121, 118, 118)))
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
              backgroundColor: MaterialStateProperty.all(Colors.blue),
            ),
            onPressed: () {
              setState(() {
                state = loading_state.LoadState.LOADING;
              });
              initBucketList();
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
          groupBy: (element) => element['location'],
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
                '${TencentManageAPI.areaCodeName[value]!}(${countBucketLocation(bucketMap, value)})',
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
                onTap: () {
                  Application.router.navigateTo(context,
                      '${Routes.tencentFileExplorer}?element=${Uri.encodeComponent(jsonEncode(element))}&bucketPrefix=${Uri.encodeComponent('')}',
                      transition: TransitionType.cupertino);
                },
                trailing: IconButton(
                  icon: const Icon(Icons.more_horiz_outlined),
                  onPressed: () async {
                    try {
                      var result = await TencentManageAPI.queryACLPolicy(element);
                      if (result[0] == 'success') {
                        var granteeURI = result[1]['AccessControlPolicy']['AccessControlList']['Grant'];
                        if (granteeURI is! List) {
                          granteeURI = [granteeURI];
                        }
                        bool publicRead = false;
                        bool publicWrite = false;
                        for (int i = 0; i < granteeURI.length; i++) {
                          String temp = granteeURI[i].toString();
                          if (temp.contains("http://cam.qcloud.com/groups/global/AllUsers") && temp.contains('WRITE')) {
                            publicWrite = true;
                          }
                          if (temp.contains("http://cam.qcloud.com/groups/global/AllUsers") && temp.contains('READ')) {
                            publicRead = true;
                          }
                        }
                        if (publicRead == true && publicWrite == true) {
                          aclState['aclState'] = 'public-read-write';
                        } else if (publicRead == true) {
                          aclState['aclState'] = 'public-read';
                        } else {
                          aclState['aclState'] = 'private';
                        }
                      } else {
                        aclState['aclState'] = '未获取';
                      }
                    } catch (e) {
                      FLog.error(
                          className: 'TencentBucketListPage',
                          methodName: 'buildSuccess_trailing_onPressed',
                          text: formatErrorMessage({
                            'element': element,
                          }, e.toString()),
                          dataLogType: DataLogType.ERRORS.toString());
                      aclState['aclState'] = '未获取';
                    }
                    setState(() {});
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
            //dense: true,
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
                        title: Global.bucketCustomUrl['tcyun-${element['name']}'] == ''
                            ? '设置自定义链接'
                            : Global.bucketCustomUrl['tcyun-${element['name']}'] == null
                                ? '设置自定义链接'
                                : Global.bucketCustomUrl['tcyun-${element['name']}']!.length > 20
                                    ? '${Global.bucketCustomUrl['tcyun-${element['name']}']!.substring(0, 20)}...'
                                    : Global.bucketCustomUrl['tcyun-${element['name']}']!,
                        okBtnTap: () async {
                          if (!vc.text.startsWith(RegExp(r'http|https'))) {
                            showToast('链接必须以http或https开头');
                            return;
                          }
                          bucketMap[bucketMap.indexOf(element)]['customUrl'] = vc.text;
                          Global.bucketCustomUrl['tcyun-${element['name']}'] = vc.text;
                          Global.setBucketCustomUrl(Global.bucketCustomUrl);
                          showToast('设置成功');
                        },
                        vc: vc,
                        cancelBtnTap: () {},
                        stateBoolText: '',
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
              if (aclState['aclState'] == '未获取' || aclState['aclState'] == 'private') {
                showToast('请先修改存储桶权限');
                return;
              } else {
                var result = await TencentManageAPI.setDefaultBucket(element, null);
                if (result[0] == 'success') {
                  showToast('设置成功');
                  if (mounted) {
                    Navigator.pop(context);
                  }
                } else {
                  showToast('设置失败');
                }
              }
            },
          ),
          const Divider(
            height: 0.1,
            color: Color.fromARGB(255, 230, 230, 230),
          ),
          ListTile(
            leading: const Icon(
              Icons.info_outline,
              color: Color.fromARGB(255, 97, 141, 236),
            ),
            minLeadingWidth: 0,
            title: const Text('存储桶信息', style: TextStyle(fontSize: 15)),
            onTap: () {
              Application.router.navigateTo(
                  context, '${Routes.tencentBucketInformation}?bucketMap=${Uri.encodeComponent(jsonEncode(element))}',
                  transition: TransitionType.none);
            },
          ),
          const Divider(
            height: 0.1,
            color: Color.fromARGB(255, 230, 230, 230),
          ),
          ListTile(
            leading: const Icon(
              Icons.manage_accounts_outlined,
              color: Color.fromARGB(255, 97, 141, 236),
            ),
            minLeadingWidth: 0,
            title: const Text('访问权限修改', style: TextStyle(fontSize: 15)),
            trailing: DropdownButton(
              alignment: Alignment.centerRight,
              underline: Container(),
              icon: const Icon(Icons.arrow_drop_down, size: 20),
              autofocus: true,
              value: aclState['aclState'],
              items: const [
                DropdownMenuItem(
                  value: '未获取',
                  child: Text('未获取'),
                ),
                DropdownMenuItem(
                  value: 'private',
                  child: Text('私有'),
                ),
                DropdownMenuItem(
                  value: 'public-read',
                  child: Text('公有读'),
                ),
                DropdownMenuItem(
                  value: 'public-read-write',
                  child: Text('公有读写'),
                ),
              ],
              onChanged: (value) async {
                if (value == '未获取') {
                } else {
                  var response = await TencentManageAPI.changeACLPolicy(element, value!);
                  if (response[0] == 'success') {
                    showToast('修改成功');
                    aclState['aclState'] = value;
                    if (mounted) {
                      setState(() {});
                      Navigator.pop(context);
                    }
                  } else {
                    showToast('修改失败');
                  }
                }
              },
            ),
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
              return showCupertinoAlertDialogWithConfirmFunc(
                title: '删除存储桶',
                content: '是否删除存储桶？\n删除前请清空该存储桶!',
                context: context,
                onConfirm: () async {
                  try {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                    var result = await TencentManageAPI.deleteBucket(element);
                    if (result[0] == 'success') {
                      showToast('删除成功');
                      _onRefresh();
                      return;
                    } else {
                      showToast('删除失败');
                    }
                    return;
                  } catch (e) {
                    FLog.error(
                        className: 'TencentBucketListPage',
                        methodName: 'buildBottomSheetWidget_deleteBucket',
                        text: formatErrorMessage({
                          'element': element,
                        }, e.toString()),
                        dataLogType: DataLogType.ERRORS.toString());
                    showToast('删除失败');
                    Navigator.of(context).pop();
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
