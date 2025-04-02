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
import 'package:horopic/picture_host_manage/manage_api/tencent_manage_api.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/utils/global.dart';

class TencentBucketList extends StatefulWidget {
  const TencentBucketList({super.key});

  @override
  TencentBucketListState createState() => TencentBucketListState();
}

class TencentBucketListState extends loading_state.BaseLoadingPageState<TencentBucketList> {
  List bucketMap = [];
  List filteredBucketMap = [];
  String searchText = '';
  bool isSearching = false;
  TextEditingController searchController = TextEditingController();
  TextEditingController vc = TextEditingController();
  Map<String, String> aclState = {'aclState': '未获取'};
  String sortBy = 'name'; // Options: 'name', 'location', 'date'
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
    vc.dispose();
    super.dispose();
  }

  //下拉刷新
  _onRefresh() async {
    initBucketList();
  }

  void filterBuckets() {
    filteredBucketMap = searchText.isEmpty
        ? List.from(bucketMap)
        : bucketMap
            .where((element) =>
                element['name'].toString().toLowerCase().contains(searchText.toLowerCase()) ||
                element['location'].toString().toLowerCase().contains(searchText.toLowerCase()))
            .toList();
    setState(() {});
  }

  //初始化bucketList
  initBucketList() async {
    bucketMap.clear();
    filteredBucketMap.clear();

    var bucketListResponse = await TencentManageAPI().getBucketList();
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
    if (bucketListResponse[1]['ListAllMyBucketsResult']['Buckets'] == null) {
      if (mounted) {
        setState(() {
          state = loading_state.LoadState.empty;
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
        centerTitle: !isSearching,
        title: isSearching
            ? TextField(
                controller: searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: '搜索存储桶...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.white70),
                ),
                style: const TextStyle(color: Colors.white),
                onChanged: (value) {
                  searchText = value;
                  filterBuckets();
                },
              )
            : titleText('存储桶'),
        flexibleSpace: getFlexibleSpace(context),
        leading: isSearching
            ? IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios,
                  size: 20,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    isSearching = false;
                    searchText = '';
                    searchController.clear();
                    filterBuckets();
                  });
                },
              )
            : getLeadingIcon(context),
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
                setState(() {});
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
                  value: 'location',
                  child: Row(
                    children: [
                      const Icon(Icons.location_on),
                      const SizedBox(width: 10),
                      const Text('按地区排序'),
                      if (sortBy == 'location') Icon(ascending ? Icons.arrow_upward : Icons.arrow_downward, size: 16),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'date',
                  child: Row(
                    children: [
                      const Icon(Icons.date_range),
                      const SizedBox(width: 10),
                      const Text('按创建日期排序'),
                      if (sortBy == 'date') Icon(ascending ? Icons.arrow_upward : Icons.arrow_downward, size: 16),
                    ],
                  ),
                ),
              ],
            ),
          if (!isSearching)
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
              iconSize: 30,
            )
        ],
      );

  @override
  String get emptyText => searchText.isNotEmpty ? '没有找到匹配的存储桶' : '没有存储桶，点击右上角添加哦';

  @override
  List<Widget> get extraEmptyWidgets => searchText.isNotEmpty
      ? [
          TextButton(
            onPressed: () {
              searchText = '';
              searchController.clear();
              filterBuckets();
            },
            child: const Text('清除搜索', style: TextStyle(color: Colors.blue)),
          ),
        ]
      : [];

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
          groupBy: (element) => element['location'],
          itemComparator: (item1, item2) {
            if (sortBy == 'name') {
              return ascending
                  ? item1['name'].toString().compareTo(item2['name'].toString())
                  : item2['name'].toString().compareTo(item1['name'].toString());
            } else if (sortBy == 'location') {
              return ascending
                  ? item1['location'].toString().compareTo(item2['location'].toString())
                  : item2['location'].toString().compareTo(item1['location'].toString());
            } else {
              return ascending
                  ? item1['CreationDate'].toString().compareTo(item2['CreationDate'].toString())
                  : item2['CreationDate'].toString().compareTo(item1['CreationDate'].toString());
            }
          },
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
              leading: const Icon(Icons.location_on, color: Colors.blue),
              title: Text(
                '${TencentManageAPI.areaCodeName[value]!}(${countBucketLocation(filteredBucketMap, value)})',
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          itemBuilder: (context, element) {
            String bucketName = element['name'].toString();
            String displayName = bucketName.length > 20
                ? '${bucketName.substring(0, 10)}...${bucketName.substring(bucketName.length - 10)}'
                : bucketName;

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: Colors.blue.withValues(alpha: 0.3),
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
                    const Icon(
                      Icons.date_range,
                      size: 14,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      element['CreationDate'].toString().substring(0, 10),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(width: 8),
                    if (element['customUrl'] != '')
                      const Icon(
                        Icons.link,
                        size: 14,
                        color: Colors.green,
                      ),
                  ],
                ),
                onTap: () {
                  Application.router.navigateTo(context,
                      '${Routes.tencentFileExplorer}?element=${Uri.encodeComponent(jsonEncode(element))}&bucketPrefix=${Uri.encodeComponent('')}',
                      transition: TransitionType.cupertino);
                },
                trailing: IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () async {
                    try {
                      var result = await TencentManageAPI().queryACLPolicy(element);
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
                      flogErr(
                        e,
                        {
                          'element': element,
                        },
                        "TencentBucketListState",
                        "buildSuccess_trailing_onPressed",
                      );
                      aclState['aclState'] = '未获取';
                    }
                    setState(() {});
                    if (context.mounted) {
                      showModalBottomSheet(
                          isScrollControlled: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                          ),
                          context: context,
                          builder: (context) {
                            return buildBottomSheetWidget(context, element);
                          });
                    }
                  },
                ),
              ),
            );
          },
          order: GroupedListOrder.DESC,
        ));
  }

  Widget buildBottomSheetWidget(BuildContext context, Map element) {
    String bucketName = element['name'].toString();
    String displayName = bucketName.length > 25
        ? '${bucketName.substring(0, 12)}...${bucketName.substring(bucketName.length - 12)}'
        : bucketName;

    bool isPublicReadable = aclState['aclState'] == 'public-read' || aclState['aclState'] == 'public-read-write';

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
                              color: Colors.blue.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              TencentManageAPI.areaCodeName[element['location']] ?? element['location'],
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.blue,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: isPublicReadable
                                  ? Colors.green.withValues(alpha: 0.2)
                                  : Colors.red.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              aclState['aclState'] == 'private'
                                  ? '私有'
                                  : aclState['aclState'] == 'public-read'
                                      ? '公有读'
                                      : aclState['aclState'] == 'public-read-write'
                                          ? '公有读写'
                                          : '未获取',
                              style: TextStyle(
                                fontSize: 12,
                                color: isPublicReadable ? Colors.green : Colors.red,
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
            icon: Icons.link,
            title: '设置自定义链接',
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
                        onConfirm: (bool isCoverFile) async {
                          if (!vc.text.startsWith(RegExp(r'http|https'))) {
                            showToast('链接必须以http或https开头');
                            return;
                          }
                          filteredBucketMap[filteredBucketMap.indexOf(element)]['customUrl'] = vc.text;
                          Global.bucketCustomUrl['tcyun-${element['name']}'] = vc.text;
                          Global.setBucketCustomUrl(Global.bucketCustomUrl);
                          showToast('设置成功');
                        },
                        renameTextController: vc,
                        onCancel: () {},
                      ),
                    );
                  });
            },
            iconColor: Colors.purple,
          ),
          _buildActionTile(
            icon: Icons.check_box_outlined,
            title: '设为默认图床',
            onTap: () async {
              if (aclState['aclState'] == '未获取' || aclState['aclState'] == 'private') {
                showToast('请先修改存储桶权限');
                return;
              } else {
                var result = await TencentManageAPI().setDefaultBucket(element, null);
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
            iconColor: Colors.green,
          ),
          _buildActionTile(
            icon: Icons.info_outline,
            title: '存储桶信息',
            onTap: () {
              Navigator.pop(context);
              Application.router.navigateTo(
                  context, '${Routes.tencentBucketInformation}?bucketMap=${Uri.encodeComponent(jsonEncode(element))}',
                  transition: TransitionType.none);
            },
            iconColor: Colors.blue,
          ),
          _buildACLActionTile(element),
          _buildActionTile(
            icon: Icons.dangerous_outlined,
            title: '删除存储桶',
            onTap: () async {
              Navigator.pop(context);
              return showCupertinoAlertDialogWithConfirmFunc(
                title: '删除存储桶',
                content: '是否删除存储桶？\n删除前请清空该存储桶!',
                context: context,
                onConfirm: () async {
                  var result = await TencentManageAPI().deleteBucket(element);
                  if (result[0] == 'success') {
                    showToast('删除成功');
                    _onRefresh();
                  } else {
                    showToast('删除失败');
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

  Widget _buildACLActionTile(Map element) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.orange.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.manage_accounts_outlined,
          color: Colors.orange,
        ),
      ),
      minLeadingWidth: 0,
      title: const Text('访问权限修改', style: TextStyle(fontSize: 16)),
      trailing: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
        ),
        child: DropdownButton(
          alignment: Alignment.centerRight,
          underline: Container(),
          icon: const Icon(Icons.arrow_drop_down, size: 20),
          borderRadius: BorderRadius.circular(8),
          padding: const EdgeInsets.symmetric(horizontal: 8),
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
              return;
            } else {
              var response = await TencentManageAPI().changeACLPolicy(element, value!);
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
    );
  }
}
