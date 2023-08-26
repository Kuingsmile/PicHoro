import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:fluro/fluro.dart';
import 'package:f_logs/f_logs.dart';

import 'package:horopic/router/application.dart';
import 'package:horopic/router/routers.dart';
import 'package:horopic/picture_host_manage/common_page/loading_state.dart' as loading_state;
import 'package:horopic/picture_host_manage/manage_api/alist_manage_api.dart';

import 'package:horopic/utils/common_functions.dart';

class AlistBucketList extends StatefulWidget {
  const AlistBucketList({Key? key}) : super(key: key);

  @override
  AlistBucketListState createState() => AlistBucketListState();
}

class AlistBucketListState extends loading_state.BaseLoadingPageState<AlistBucketList> {
  List bucketMap = [];

  RefreshController refreshController = RefreshController(initialRefresh: false);

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
    refreshController.refreshCompleted();
  }

  //初始化bucketList
  initBucketList() async {
    bucketMap.clear();
    try {
      var bucketListResponse = await AlistManageAPI.getBucketList();
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
      if (bucketListResponse[1]['total'] == 0) {
        if (mounted) {
          setState(() {
            state = loading_state.LoadState.EMPTY;
          });
        }
        refreshController.refreshCompleted();
        return;
      }
      var allBucketList = bucketListResponse[1]['content'];

      if (allBucketList is! List) {
        allBucketList = [allBucketList];
      }

      for (var i = 0; i < allBucketList.length; i++) {
        bucketMap.add({for (var key in allBucketList[i].keys) key: allBucketList[i][key]});
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
          className: 'AlistBucketListState',
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

  countBucketLocation(List elements, String driver) {
    Map<dynamic, int> locationCount = {};
    for (var i = 0; i < elements.length; i++) {
      if (locationCount.containsKey(elements[i]['driver'])) {
        locationCount[elements[i]['driver']] = locationCount[elements[i]['driver']]! + 1;
      } else {
        locationCount[elements[i]['driver']] = 1;
      }
    }
    return locationCount[driver];
  }

  @override
  AppBar get appBar => AppBar(
        elevation: 0,
        centerTitle: true,
        title: titleText('Alist存储列表'),
        actions: [
          IconButton(
            onPressed: () async {
              await Application.router
                  .navigateTo(context, Routes.newAlistBucketNavigation, transition: TransitionType.cupertino);
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
          const Text('没有存储，点击右上角添加哦', style: TextStyle(fontSize: 20, color: Color.fromARGB(136, 121, 118, 118)))
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
          groupBy: (element) => element['driver'],
          itemComparator: (item1, item2) => item1['id'].compareTo(item2['id']),
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
                '${AlistManageAPI.driverTranslate[value]} (${countBucketLocation(bucketMap, value)})',
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
                title: Text(element['mount_path'].toString() == "/"
                    ? "根目录"
                    : element['mount_path'].toString().length > 15
                        ? '${element['mount_path'].toString().substring(0, 7)}...${element['mount_path'].toString().substring(element['mount_path'].toString().length - 7, element['mount_path'].toString().length)}'
                        : element['mount_path'].toString()),
                subtitle: Text(element['disabled'] == false ? '已启用' : '被禁用',
                    style: TextStyle(color: element['disabled'] == false ? Colors.green : Colors.red)),
                onTap: () async {
                  String prefix = element['mount_path'].toString();
                  if (!prefix.endsWith('/')) {
                    prefix += '/';
                  }
                  Application.router.navigateTo(context,
                      '${Routes.alistFileExplorer}?element=${Uri.encodeComponent(jsonEncode(element))}&bucketPrefix=${Uri.encodeComponent(prefix)}&refresh=${Uri.encodeComponent('Refresh')}',
                      transition: TransitionType.cupertino);
                },
                trailing: IconButton(
                  icon: const Icon(Icons.more_horiz_outlined),
                  onPressed: () async {
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
            leading: const Icon(
              IconData(0xe6ab, fontFamily: 'iconfont'),
              color: Colors.blue,
            ),
            visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
            minLeadingWidth: 0,
            title: Text(element['mount_path'].toString() == "/"
                ? "根目录"
                : element['mount_path'].toString().length > 15
                    ? '${element['mount_path'].toString().substring(0, 7)}...${element['mount_path'].toString().substring(element['mount_path'].toString().length - 7, element['mount_path'].toString().length)}'
                    : element['mount_path'].toString()),
            subtitle: Text(element['disabled'] == false ? '已启用' : '被禁用',
                style: TextStyle(color: element['disabled'] == false ? Colors.green : Colors.red)),
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
              String path = element['mount_path'].toString();
              var result = await AlistManageAPI.setDefaultBucket(path);
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
              Icons.info_outline,
              color: Color.fromARGB(255, 97, 141, 236),
            ),
            minLeadingWidth: 0,
            title: const Text('存储信息', style: TextStyle(fontSize: 15)),
            onTap: () {
              Application.router.navigateTo(
                  context, '${Routes.alistBucketInformation}?bucketMap=${Uri.encodeComponent(jsonEncode(element))}',
                  transition: TransitionType.none);
            },
          ),
          const Divider(
            height: 0.1,
            color: Color.fromARGB(255, 230, 230, 230),
          ),
          ListTile(
            leading: const Icon(
              Icons.edit_outlined,
              color: Color.fromARGB(255, 97, 141, 236),
            ),
            minLeadingWidth: 0,
            title: const Text('修改配置', style: TextStyle(fontSize: 15)),
            onTap: () async {
              String update = 'true';
              await Application.router.navigateTo(context,
                  '${Routes.alistNewBucketConfig}?driver=${Uri.encodeComponent(element['driver'])}&update=${Uri.encodeComponent(update)}&bucketMap=${Uri.encodeComponent(jsonEncode(element))}',
                  transition: TransitionType.cupertino);
              _onRefresh();
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
            title: const Text('状态修改', style: TextStyle(fontSize: 15)),
            trailing: DropdownButton(
              alignment: Alignment.centerRight,
              underline: Container(),
              icon: const Icon(Icons.arrow_drop_down, size: 20),
              autofocus: true,
              value: element['disabled'] == false ? 'false' : 'true',
              items: const [
                DropdownMenuItem(
                  value: 'false',
                  child: Text('启用'),
                ),
                DropdownMenuItem(
                  value: 'true',
                  child: Text('禁用'),
                ),
              ],
              onChanged: (value) async {
                var response = await AlistManageAPI.changeBucketState(element, value == 'true' ? false : true);
                if (response[0] == 'success') {
                  showToast('修改成功');
                  element['disabled'] = value == 'true' ? false : true;
                  if (mounted) {
                    Navigator.pop(context);
                    initBucketList();
                  }
                } else {
                  showToast('修改失败');
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
            title: const Text('卸载存储', style: TextStyle(fontSize: 15)),
            onTap: () async {
              return showCupertinoAlertDialogWithConfirmFunc(
                title: '卸载存储',
                content: '是否卸载存储？',
                context: context,
                onConfirm: () async {
                  try {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                    var result = await AlistManageAPI.deleteBucket(element);
                    if (result[0] == 'success') {
                      showToast('卸载成功');
                      _onRefresh();
                      return;
                    } else {
                      showToast('卸载失败');
                    }
                    return;
                  } catch (e) {
                    FLog.error(
                        className: 'AlistBucketPage',
                        methodName: 'buildBottomSheetWidget_deleteBucket',
                        text: formatErrorMessage({
                          'element': element,
                        }, e.toString()),
                        dataLogType: DataLogType.ERRORS.toString());
                    showToast('删除失败');
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
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
