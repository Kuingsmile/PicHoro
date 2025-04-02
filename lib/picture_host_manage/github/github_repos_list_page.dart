import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:horopic/widgets/common_widgets.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:fluro/fluro.dart';

import 'package:horopic/router/application.dart';
import 'package:horopic/router/routers.dart';
import 'package:horopic/picture_host_manage/common/loading_state.dart' as loading_state;
import 'package:horopic/picture_host_manage/manage_api/github_manage_api.dart';
import 'package:horopic/utils/common_functions.dart';

class GithubReposList extends StatefulWidget {
  final String showedUsername;
  const GithubReposList({
    super.key,
    required this.showedUsername,
  });

  @override
  GithubReposListState createState() => GithubReposListState();
}

class GithubReposListState extends loading_state.BaseLoadingPageState<GithubReposList> {
  List repoMap = [];

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
    initRepoList();
  }

  //初始化bucketList
  initRepoList() async {
    repoMap.clear();
    try {
      Map configMap = await GithubManageAPI().getConfigMap();
      dynamic bucketListResponse;
      if (configMap['githubusername'].toString().toLowerCase() == widget.showedUsername.toLowerCase()) {
        bucketListResponse = await GithubManageAPI().getReposList();
      } else {
        bucketListResponse = await GithubManageAPI().getOtherReposList(widget.showedUsername);
      }
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
      if (bucketListResponse[1].length == 0) {
        if (mounted) {
          setState(() {
            state = loading_state.LoadState.empty;
          });
        }
        refreshController.refreshCompleted();
        return;
      }
      var allReposList = bucketListResponse[1];
      List keys = allReposList[0].keys.toList();

      for (var i = 0; i < allReposList.length; i++) {
        Map repo = {};
        for (var j = 0; j < keys.length; j++) {
          repo[keys[j]] = allReposList[i][keys[j]];
        }
        repoMap.add(repo);
      }

      if (mounted) {
        setState(() {
          if (repoMap.isEmpty) {
            state = loading_state.LoadState.empty;
          } else {
            state = loading_state.LoadState.success;
          }
          refreshController.refreshCompleted();
        });
      }
    } catch (e) {
      flogErr(e, {}, 'GithubReposListState', 'initRepoList');
      if (mounted) {
        setState(() {
          state = loading_state.LoadState.error;
        });
      }
      showToast('获取失败');
      refreshController.refreshCompleted();
    }
  }

  countRepoVisibility(List elements, String location) {
    Map<String, int> visibilityCount = {};
    for (var i = 0; i < elements.length; i++) {
      if (visibilityCount.containsKey(elements[i]['visibility'])) {
        visibilityCount[elements[i]['visibility']] = visibilityCount[elements[i]['visibility']]! + 1;
      } else {
        visibilityCount[elements[i]['visibility']] = 1;
      }
    }
    return visibilityCount[location];
  }

  @override
  AppBar get appBar => AppBar(
        elevation: 0,
        centerTitle: true,
        leading: getLeadingIcon(context),
        title: titleText('${widget.showedUsername}的仓库', fontsize: 16),
        flexibleSpace: getFlexibleSpace(context),
        actions: [
          IconButton(
            onPressed: () async {
              try {
                var configMap = await GithubManageAPI().getConfigMap();
                if (configMap['githubusername'].toString().toLowerCase() == widget.showedUsername.toLowerCase()) {
                  if (mounted) {
                    await Application.router
                        .navigateTo(context, Routes.githubNewRepoConfig, transition: TransitionType.cupertino);
                    _onRefresh();
                  }
                } else {
                  showToast('只有自己的仓库才能创建');
                }
              } catch (e) {
                showToast('获取失败');
              }
            },
            icon: const Icon(Icons.add, color: Colors.white),
            iconSize: 35,
          )
        ],
      );

  @override
  String get emptyText => '没有仓库，点击右上角添加哦';

  @override
  void onErrorRetry() {
    setState(() {
      state = loading_state.LoadState.loading;
    });
    initRepoList();
  }

  @override
  Widget buildSuccess() {
    return SmartRefresher(
        enablePullDown: true,
        enablePullUp: false,
        header: const WaterDropHeader(
          waterDropColor: Colors.blue,
          complete: Text('刷新完成', style: TextStyle(color: Colors.grey)),
          failed: Text('刷新失败', style: TextStyle(color: Colors.grey)),
        ),
        footer: ClassicFooter(
          loadStyle: LoadStyle.ShowWhenLoading,
          idleText: '上拉加载',
          loadingText: '正在加载',
          noDataText: '没有更多了',
          failedText: '加载失败',
          canLoadingText: '释放加载',
          textStyle: TextStyle(color: Theme.of(context).primaryColor),
        ),
        controller: refreshController,
        onRefresh: _onRefresh,
        child: GroupedListView(
          shrinkWrap: true,
          elements: repoMap,
          groupBy: (element) => element['visibility'],
          itemComparator: (item1, item2) => item2['name'].toString().toLowerCase().compareTo(
                item1['name'].toString().toLowerCase(),
              ),
          groupComparator: (value1, value2) => value2.compareTo(value1),
          separator: Divider(
            height: 1,
            thickness: 0.3,
            color: Colors.grey.withValues(alpha: 0.3),
            indent: 70,
          ),
          groupSeparatorBuilder: (String value) => Container(
            height: 45,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(0),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    value.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '(${countRepoVisibility(repoMap, value)})',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          itemBuilder: (context, element) {
            return Card(
              elevation: 0,
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: ListTile(
                minLeadingWidth: 0,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Image.asset(
                    'assets/images/githubrepo.png',
                    width: 24,
                    height: 24,
                  ),
                ),
                title: Text(
                  element['name'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: element['description'] != null && element['description'].toString().isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          element['description'],
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                    : null,
                onTap: () async {
                  Map newElement = Map.from(element);
                  newElement['showedUsername'] = widget.showedUsername;
                  Application.router.navigateTo(context,
                      '${Routes.githubFileExplorer}?element=${Uri.encodeComponent(jsonEncode(newElement))}&bucketPrefix=${Uri.encodeComponent('')}',
                      transition: TransitionType.cupertino);
                },
                trailing: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(Icons.more_horiz_outlined, size: 20),
                  ),
                  onPressed: () async {
                    showModalBottomSheet(
                      isScrollControlled: true,
                      context: context,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      builder: (context) {
                        return buildBottomSheetWidget(context, element);
                      },
                    );
                  },
                ),
              ),
            );
          },
          order: GroupedListOrder.DESC,
        ));
  }

  Widget buildBottomSheetWidget(BuildContext context, Map element) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                IconData(0xe6ab, fontFamily: 'iconfont'),
                color: Colors.blue,
                size: 20,
              ),
            ),
            visualDensity: const VisualDensity(horizontal: 0, vertical: -2),
            minLeadingWidth: 0,
            title: Text(
              element['name'],
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(
              Icons.check_box_outlined,
              color: Color.fromARGB(255, 97, 141, 236),
            ),
            minLeadingWidth: 0,
            title: const Text('设为默认图床', style: TextStyle(fontSize: 15)),
            onTap: () async {
              try {
                var configMap = await GithubManageAPI().getConfigMap();
                if (widget.showedUsername.toLowerCase() != configMap['githubusername'].toString().toLowerCase()) {
                  showToast('该仓库不属于当前登录用户');
                  return;
                }
                var result = await GithubManageAPI().setDefaultRepo(element, null);
                if (result[0] == 'success') {
                  showToast('设置成功');
                  if (mounted) {
                    Navigator.pop(context);
                  }
                } else {
                  showToast('设置失败');
                }
              } catch (e) {
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
            title: const Text('仓库信息', style: TextStyle(fontSize: 15)),
            onTap: () {
              Navigator.pop(context);
              Application.router.navigateTo(
                  context, '${Routes.githubRepoInformation}?repoMap=${Uri.encodeComponent(jsonEncode(element))}',
                  transition: TransitionType.none);
            },
          ),
        ],
      ),
    );
  }
}
