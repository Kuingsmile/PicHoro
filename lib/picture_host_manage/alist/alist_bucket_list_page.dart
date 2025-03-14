import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:fluro/fluro.dart';

import 'package:horopic/router/application.dart';
import 'package:horopic/router/routers.dart';
import 'package:horopic/picture_host_manage/common/loading_state.dart' as loading_state;
import 'package:horopic/picture_host_manage/manage_api/alist_manage_api.dart';
import 'package:horopic/utils/common_functions.dart';

class AlistBucketList extends StatefulWidget {
  const AlistBucketList({super.key});

  @override
  AlistBucketListState createState() => AlistBucketListState();
}

class AlistBucketListState extends loading_state.BaseLoadingPageState<AlistBucketList> {
  List bucketMap = [];
  List filteredBucketMap = [];
  String searchText = '';
  bool isSearching = false;
  TextEditingController searchController = TextEditingController();
  String sortBy = 'name'; // Options: 'name', 'driver', 'enabled'
  bool ascending = true;

  RefreshController refreshController = RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    _onRefresh();
  }

  @override
  dispose() {
    refreshController.dispose();
    searchController.dispose();
    super.dispose();
  }

  //下拉刷新
  _onRefresh() async {
    initBucketList();
    refreshController.refreshCompleted();
  }

  void filterBuckets() {
    if (searchText.isEmpty) {
      filteredBucketMap = List.from(bucketMap);
    } else {
      filteredBucketMap = bucketMap
          .where((element) =>
              element['mount_path'].toString().toLowerCase().contains(searchText.toLowerCase()) ||
              (AlistManageAPI.driverTranslate[element['driver']] ?? element['driver'])
                  .toString()
                  .toLowerCase()
                  .contains(searchText.toLowerCase()))
          .toList();
    }

    // Apply sorting
    switch (sortBy) {
      case 'name':
        filteredBucketMap.sort((a, b) => ascending
            ? a['mount_path'].toString().compareTo(b['mount_path'].toString())
            : b['mount_path'].toString().compareTo(a['mount_path'].toString()));
      case 'driver':
        filteredBucketMap.sort((a, b) => ascending
            ? a['driver'].toString().compareTo(b['driver'].toString())
            : b['driver'].toString().compareTo(a['driver'].toString()));
      case 'enabled':
        filteredBucketMap.sort((a, b) {
          bool aEnabled = a['disabled'] == false;
          bool bEnabled = b['disabled'] == false;
          return ascending
              ? aEnabled == bEnabled
                  ? 0
                  : aEnabled
                      ? -1
                      : 1
              : aEnabled == bEnabled
                  ? 0
                  : aEnabled
                      ? 1
                      : -1;
        });
    }

    setState(() {});
  }

  //初始化bucketList
  initBucketList() async {
    bucketMap.clear();
    filteredBucketMap.clear();
    try {
      var bucketListResponse = await AlistManageAPI.getBucketList();
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
      if (bucketListResponse[1]['total'] == 0) {
        if (mounted) {
          setState(() {
            state = loading_state.LoadState.empty;
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

      filterBuckets();

      if (mounted) {
        setState(() {
          if (filteredBucketMap.isEmpty) {
            state = loading_state.LoadState.empty;
          } else {
            state = loading_state.LoadState.success;
          }
          refreshController.refreshCompleted();
        });
      }
    } catch (e) {
      flogErr(e, {}, 'AlistBucketListState', 'initBucketList');
      if (mounted) {
        setState(() {
          state = loading_state.LoadState.error;
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
        centerTitle: !isSearching,
        title: isSearching
            ? TextField(
                controller: searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: '搜索存储...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.white70),
                ),
                style: TextStyle(color: Colors.white),
                onChanged: (value) {
                  searchText = value;
                  filterBuckets();
                },
              )
            : titleText('存储列表'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColor.withAlpha(204)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        leading: isSearching
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    isSearching = false;
                    searchText = '';
                    searchController.clear();
                    filterBuckets();
                  });
                },
              )
            : null,
        actions: [
          if (!isSearching)
            IconButton(
              onPressed: () {
                setState(() {
                  isSearching = true;
                });
              },
              icon: const Icon(
                Icons.search,
                color: Colors.white,
              ),
            ),
          if (!isSearching)
            PopupMenuButton<String>(
              icon: const Icon(Icons.sort, color: Colors.white),
              onSelected: (value) {
                if (sortBy == value) {
                  ascending = !ascending;
                } else {
                  sortBy = value;
                  ascending = true;
                }
                filterBuckets();
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'name',
                  child: Row(
                    children: [
                      const Icon(Icons.sort_by_alpha),
                      const SizedBox(width: 10),
                      const Text('按名称排序'),
                      if (sortBy == 'name') Icon(ascending ? Icons.arrow_upward : Icons.arrow_downward, size: 16),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'driver',
                  child: Row(
                    children: [
                      const Icon(Icons.drive_folder_upload),
                      const SizedBox(width: 10),
                      const Text('按类型排序'),
                      if (sortBy == 'driver') Icon(ascending ? Icons.arrow_upward : Icons.arrow_downward, size: 16),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'enabled',
                  child: Row(
                    children: [
                      const Icon(Icons.toggle_on),
                      const SizedBox(width: 10),
                      const Text('按状态排序'),
                      if (sortBy == 'enabled') Icon(ascending ? Icons.arrow_upward : Icons.arrow_downward, size: 16),
                    ],
                  ),
                ),
              ],
            ),
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
          const SizedBox(height: 20),
          Text(searchText.isNotEmpty ? '没有找到匹配的存储' : '没有存储，点击右上角添加哦',
              style: const TextStyle(fontSize: 16, color: Color.fromARGB(136, 121, 118, 118))),
          if (searchText.isNotEmpty)
            TextButton(
              onPressed: () {
                searchText = '';
                searchController.clear();
                filterBuckets();
              },
              child: const Text('清除搜索', style: TextStyle(color: Colors.blue)),
            ),
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
          const Icon(Icons.error_outline, size: 50, color: Colors.red),
          const SizedBox(height: 20),
          const Text('加载失败', style: TextStyle(fontSize: 18, color: Color.fromARGB(200, 121, 118, 118))),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
            ),
            onPressed: () {
              setState(() {
                state = loading_state.LoadState.loading;
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation(Colors.blue),
            ),
          ),
          SizedBox(height: 20),
          Text('加载中...', style: TextStyle(fontSize: 16, color: Colors.grey)),
        ],
      ),
    );
  }

  @override
  Widget buildSuccess() {
    return SmartRefresher(
        enablePullDown: true,
        enablePullUp: false,
        header: const WaterDropHeader(
          waterDropColor: Colors.blue,
          complete: Text('刷新完成', style: TextStyle(color: Colors.grey)),
          failed: Text('刷新失败', style: TextStyle(color: Colors.red)),
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
          elements: filteredBucketMap,
          groupBy: (element) => element['driver'],
          itemComparator: (item1, item2) => item1['id'].compareTo(item2['id']),
          groupComparator: (value1, value2) => value2.compareTo(value1),
          groupSeparatorBuilder: (String value) => Container(
            height: 40,
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.2),
                  spreadRadius: 1,
                  blurRadius: 1,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: ListTile(
              visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
              leading: const Icon(Icons.folder_special, color: Colors.blue),
              title: Text(
                '${AlistManageAPI.driverTranslate[value] ?? value} (${countBucketLocation(filteredBucketMap, value)})',
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          itemBuilder: (context, element) {
            String mountPath = element['mount_path'].toString();
            String displayName = mountPath == "/"
                ? "根目录"
                : mountPath.length > 15
                    ? '${mountPath.substring(0, 7)}...${mountPath.substring(mountPath.length - 7)}'
                    : mountPath;
            bool isEnabled = element['disabled'] == false;

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: isEnabled ? Colors.green.withValues(alpha: 0.3) : Colors.red.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    IconData(0xe6ab, fontFamily: 'iconfont'),
                    color: Colors.blue,
                    size: 25,
                  ),
                ),
                title: Text(
                  displayName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
                subtitle: Row(
                  children: [
                    Icon(
                      isEnabled ? Icons.check_circle_outline : Icons.cancel_outlined,
                      size: 14,
                      color: isEnabled ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isEnabled ? '已启用' : '被禁用',
                      style: TextStyle(
                        fontSize: 12,
                        color: isEnabled ? Colors.green : Colors.red,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      AlistManageAPI.driverTranslate[element['driver']] ?? element['driver'],
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                onTap: () async {
                  String prefix = mountPath;
                  if (!prefix.endsWith('/')) {
                    prefix += '/';
                  }
                  Application.router.navigateTo(context,
                      '${Routes.alistFileExplorer}?element=${Uri.encodeComponent(jsonEncode(element))}&bucketPrefix=${Uri.encodeComponent(prefix)}&refresh=${Uri.encodeComponent('Refresh')}',
                      transition: TransitionType.cupertino);
                },
                trailing: IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () async {
                    showModalBottomSheet(
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                        ),
                        context: context,
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
    String mountPath = element['mount_path'].toString();
    String displayName = mountPath == "/"
        ? "根目录"
        : mountPath.length > 15
            ? '${mountPath.substring(0, 7)}...${mountPath.substring(mountPath.length - 7)}'
            : mountPath;
    bool isEnabled = element['disabled'] == false;

    return Container(
      padding: const EdgeInsets.only(top: 16, bottom: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    IconData(0xe6ab, fontFamily: 'iconfont'),
                    color: Colors.blue,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color:
                                  isEnabled ? Colors.green.withValues(alpha: 0.2) : Colors.red.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              isEnabled ? '已启用' : '被禁用',
                              style: TextStyle(
                                fontSize: 12,
                                color: isEnabled ? Colors.green : Colors.red,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.blue.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              AlistManageAPI.driverTranslate[element['driver']] ?? element['driver'],
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.blue,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Divider(),
          _buildActionTile(
            icon: Icons.check_box_outlined,
            title: '设为默认图床',
            onTap: () async {
              String path = mountPath;
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
            iconColor: Colors.green,
          ),
          _buildActionTile(
            icon: Icons.info_outline,
            title: '存储信息',
            onTap: () {
              Navigator.pop(context);
              Application.router.navigateTo(
                  context, '${Routes.alistBucketInformation}?bucketMap=${Uri.encodeComponent(jsonEncode(element))}',
                  transition: TransitionType.none);
            },
            iconColor: Colors.blue,
          ),
          _buildStatusActionTile(
            element: element,
            isEnabled: isEnabled,
            onChanged: () {
              _onRefresh();
            },
          ),
          _buildActionTile(
            icon: Icons.dangerous_outlined,
            title: '卸载存储',
            onTap: () async {
              return showCupertinoAlertDialogWithConfirmFunc(
                title: '卸载存储',
                content: '是否卸载存储？卸载后将无法恢复。',
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
                    flogErr(
                      e,
                      {
                        'element': element,
                      },
                      'AlistBucketPage',
                      'buildBottomSheetWidget_deleteBucket',
                    );
                    showToast('删除失败');
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  }
                },
              );
            },
            iconColor: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required Function() onTap,
    required Color iconColor,
  }) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: iconColor,
        ),
      ),
      minLeadingWidth: 0,
      title: Text(title, style: const TextStyle(fontSize: 16)),
      onTap: onTap,
    );
  }

  Widget _buildStatusActionTile({
    required Map element,
    required bool isEnabled,
    required Function() onChanged,
  }) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.purple.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.manage_accounts_outlined,
          color: Colors.purple,
        ),
      ),
      minLeadingWidth: 0,
      title: const Text('状态修改', style: TextStyle(fontSize: 16)),
      trailing: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
        ),
        child: DropdownButton<String>(
          alignment: Alignment.centerRight,
          underline: Container(),
          icon: const Icon(Icons.arrow_drop_down, size: 20),
          borderRadius: BorderRadius.circular(8),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          value: isEnabled ? 'false' : 'true',
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
                onChanged();
              }
            } else {
              showToast('修改失败');
            }
          },
        ),
      ),
    );
  }
}
