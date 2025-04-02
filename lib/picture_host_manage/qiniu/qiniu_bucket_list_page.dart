import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:horopic/widgets/common_widgets.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:fluro/fluro.dart';

import 'package:horopic/router/application.dart';
import 'package:horopic/router/routers.dart';
import 'package:horopic/picture_host_manage/common/loading_state.dart' as loading_state;
import 'package:horopic/picture_host_manage/manage_api/qiniu_manage_api.dart';
import 'package:horopic/utils/common_functions.dart';

class QiniuBucketList extends StatefulWidget {
  const QiniuBucketList({super.key});

  @override
  QiniuBucketListState createState() => QiniuBucketListState();
}

class QiniuBucketListState extends loading_state.BaseLoadingPageState<QiniuBucketList> {
  List bucketMap = [];
  List filteredBucketMap = [];
  String searchText = '';
  bool isSearching = false;
  TextEditingController searchController = TextEditingController();
  String sortBy = 'name'; // Options: 'name'
  bool ascending = true;

  RefreshController refreshController = RefreshController(initialRefresh: false);
  TextEditingController domainController = TextEditingController();
  TextEditingController pathController = TextEditingController();

  TextEditingController areaController = TextEditingController();
  TextEditingController optionController = TextEditingController();
  bool isUseRemotePSConfig = false;

  QiniuManageAPI manageAPI = QiniuManageAPI();

  @override
  void initState() {
    super.initState();
    _onRefresh();
  }

  @override
  dispose() {
    refreshController.dispose();
    domainController.dispose();
    pathController.dispose();
    areaController.dispose();
    optionController.dispose();
    searchController.dispose();
    super.dispose();
  }

  //下拉刷新
  _onRefresh() async {
    initBucketList();
  }

  _configMapWithCatch() async {
    try {
      var configMap = await manageAPI.getConfigMap();
      return configMap;
    } catch (e) {
      return null;
    }
  }

  void filterBuckets() {
    filteredBucketMap = searchText.isEmpty
        ? List.from(bucketMap)
        : bucketMap
            .where((element) => element['name'].toString().toLowerCase().contains(searchText.toLowerCase()))
            .toList();
    setState(() {});
  }

  //初始化bucketList
  initBucketList() async {
    bucketMap.clear();
    filteredBucketMap.clear();

    try {
      var configMap = await _configMapWithCatch();
      if (configMap != null) {
        if (configMap['options'] != 'None') {
          optionController.text = configMap['options'];
        }
        if (configMap['path'] != 'None') {
          pathController.text = configMap['path'];
        }
      }

      var bucketListResponse = await manageAPI.getBucketNameList();

      //判断是否获取成功
      if (bucketListResponse[0] != 'success') {
        if (mounted) {
          setState(() {
            state = loading_state.LoadState.error;
          });
          showToast('获取失败');
        }
        refreshController.refreshCompleted();
        return;
      }
      //没有bucket
      if (bucketListResponse[1] == null) {
        if (mounted) {
          setState(() {
            state = loading_state.LoadState.empty;
          });
        }
        refreshController.refreshCompleted();
        return;
      }
      //有bucket
      var allBucketList = bucketListResponse[1];

      if (allBucketList is! List) {
        allBucketList = [allBucketList];
      }
      for (var i = 0; i < allBucketList.length; i++) {
        bucketMap.add({
          'name': allBucketList[i],
          'tag': '存储桶',
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
    } catch (e) {
      flogErr(e, {}, 'QiniuBucketListState', 'initBucketList');
      if (mounted) {
        setState(() {
          state = loading_state.LoadState.error;
        });
      }
      showToast('获取失败');
      refreshController.refreshCompleted();
    }
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
              ],
            ),
          if (!isSearching)
            IconButton(
              onPressed: () async {
                await Application.router
                    .navigateTo(context, Routes.qiniuNewBucketConfig, transition: TransitionType.cupertino);
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

  Widget setDefaultPSHost(Map element) {
    return StatefulBuilder(builder: (BuildContext context, void Function(void Function()) setState) {
      return CupertinoAlertDialog(
        title: const Text('请确认域名等信息', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue)),
        content: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            CupertinoTextField(
              textAlign: TextAlign.center,
              prefix: const Text('域名：', style: TextStyle(fontSize: 16, color: Color.fromARGB(255, 121, 118, 118))),
              controller: domainController,
              placeholder: '网站域名',
            ),
            const SizedBox(
              height: 10,
            ),
            CupertinoTextField(
              textAlign: TextAlign.center,
              prefix: const Text('区域：', style: TextStyle(fontSize: 16, color: Color.fromARGB(255, 121, 118, 118))),
              controller: areaController,
              placeholder: '存储区域',
            ),
            const SizedBox(
              height: 10,
            ),
            CupertinoTextField(
              prefix: const Text('路径：', style: TextStyle(fontSize: 16, color: Color.fromARGB(255, 121, 118, 118))),
              textAlign: TextAlign.center,
              controller: pathController,
              placeholder: '图床路径，非必填',
            ),
            const SizedBox(
              height: 10,
            ),
            CupertinoTextField(
              prefix: const Text('后缀：', style: TextStyle(fontSize: 16, color: Color.fromARGB(255, 121, 118, 118))),
              textAlign: TextAlign.center,
              controller: optionController,
              placeholder: '网址后缀，非必填',
            ),
            const SizedBox(
              height: 10,
            ),
            CheckboxListTile(
                dense: true,
                title: const Text(
                  '使用已添加的域名和区域信息',
                  style: TextStyle(fontSize: 14),
                ),
                value: isUseRemotePSConfig,
                onChanged: (value) async {
                  if (value == true) {
                    var queryQiniu = await manageAPI.readQiniuManageConfig();
                    if (queryQiniu != 'Error') {
                      var jsonResult = jsonDecode(queryQiniu);
                      domainController.text = jsonResult['domain'];
                      areaController.text = jsonResult['area'];
                      setState(() {
                        isUseRemotePSConfig = value!;
                      });
                    } else {
                      showToast('请先在弹出栏添加域名和区域信息');
                    }
                  } else {
                    domainController.clear();
                    areaController.clear();
                    setState(() {
                      isUseRemotePSConfig = value!;
                    });
                  }
                }),
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
              try {
                var option = optionController.text;
                var path = pathController.text;
                var domain = domainController.text;
                var area = areaController.text;
                Map textMap = {};
                if (option == '' || option.replaceAll(' ', '').isEmpty) {
                  textMap['option'] = '';
                } else {
                  textMap['option'] = option;
                }
                if (path == '' || path.replaceAll(' ', '').isEmpty) {
                  textMap['path'] = '';
                } else {
                  textMap['path'] = path;
                }
                if (domain == '' || domain.replaceAll(' ', '').isEmpty) {
                  showToast('请设定域名');
                  return;
                }
                if (area == '' || area.replaceAll(' ', '').isEmpty) {
                  showToast('请设定区域');
                  return;
                }
                textMap['domain'] = domain;
                textMap['area'] = area;
                var insertQiniuManage =
                    await manageAPI.saveQiniuManageConfig(element['name'], textMap['domain'], textMap['area']);
                if (!insertQiniuManage) {
                  showToast('数据保存错误');
                  return;
                }
                var result = await manageAPI.setDefaultBucketFromListPage(element, textMap, null);
                if (result[0] == 'success') {
                  showToast('设置成功');
                  if (mounted) {
                    Navigator.pop(context);
                  }
                } else {
                  showToast('设置失败');
                }
              } catch (e) {
                flogErr(
                    e,
                    {
                      'domain': domainController.text,
                      'area': areaController.text,
                      'path': pathController.text,
                      'option': optionController.text,
                    },
                    'QiniuManagePage',
                    'setDefaultPSHost');
              }
            },
          ),
        ],
      );
    });
  }

  countBucketLocation(List elements) {
    return elements.length;
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
          groupBy: (element) => element['tag'],
          itemComparator: (item1, item2) => ascending
              ? item1['name'].toString().compareTo(item2['name'].toString())
              : item2['name'].toString().compareTo(item1['name'].toString()),
          groupComparator: (value1, value2) => value2.compareTo(value1),
          separator: const SizedBox(height: 0),
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
                '$value (${countBucketLocation(filteredBucketMap)})',
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
                subtitle: const Row(
                  children: [
                    Icon(
                      Icons.cloud_done_outlined,
                      size: 14,
                      color: Colors.green,
                    ),
                    SizedBox(width: 4),
                    Text(
                      '七牛云存储',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                onTap: () async {
                  Map<String, dynamic> textMap = {};
                  textMap['name'] = element['name'];
                  var queryQiniuManage = await manageAPI.readQiniuManageConfig();
                  if (queryQiniuManage == 'Error') {
                    showToast('请先设置域名和区域');
                    return;
                  } else {
                    var jsonResult = jsonDecode(queryQiniuManage);
                    if (jsonResult['domain'] == 'None' || jsonResult['area'] == 'None') {
                      showToast('请先设置域名和区域');
                      return;
                    }
                    textMap['domain'] = jsonResult['domain'];
                    textMap['area'] = jsonResult['area'];
                  }
                  if (mounted) {
                    Application.router.navigateTo(context,
                        '${Routes.qiniuFileExplorer}?element=${Uri.encodeComponent(jsonEncode(textMap))}&bucketPrefix=${Uri.encodeComponent('')}',
                        transition: TransitionType.cupertino);
                  }
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
    String bucketName = element['name'].toString();
    String displayName = bucketName.length > 20
        ? '${bucketName.substring(0, 10)}...${bucketName.substring(bucketName.length - 10)}'
        : bucketName;

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
                            child: const Text(
                              '七牛云存储桶',
                              style: TextStyle(
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
              Navigator.pop(context);
              await showCupertinoDialog(
                  builder: (context) {
                    return setDefaultPSHost(element);
                  },
                  context: context);
            },
            iconColor: Colors.green,
          ),
          _buildActionTile(
            icon: Icons.settings_outlined,
            title: '设置存储桶参数',
            onTap: () {
              Navigator.pop(context);
              Application.router.navigateTo(
                  context, '${Routes.qiniuBucketDomainAreaConfig}?element=${Uri.encodeComponent(jsonEncode(element))}',
                  transition: TransitionType.cupertino);
            },
            iconColor: Colors.blue,
          ),
          _buildActionTile(
            icon: Icons.public,
            title: '设为公开',
            onTap: () async {
              var result = await manageAPI.setACL(element, '0');
              if (result[0] == 'success') {
                showToast('设置成功');
                if (mounted) {
                  Navigator.pop(context);
                }
              } else {
                showToast('设置失败');
              }
            },
            iconColor: Colors.purple,
          ),
          _buildActionTile(
            icon: Icons.lock_outline,
            title: '设为私有',
            onTap: () async {
              var result = await manageAPI.setACL(element, '1');
              if (result[0] == 'success') {
                showToast('设置成功');
                if (mounted) {
                  Navigator.pop(context);
                }
              } else {
                showToast('设置失败');
              }
            },
            iconColor: Colors.amber,
          ),
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
                  var result = await manageAPI.deleteBucket(element);
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
}
