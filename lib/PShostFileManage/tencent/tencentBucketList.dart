import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:horopic/PShostFileManage/manageAPI/tencentManage.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:fluro/fluro.dart';
import 'package:horopic/router/application.dart';
import 'package:horopic/router/routes.dart';
import 'package:horopic/PShostFileManage/commonPage/loadingState.dart'
    as loadingState;
import 'package:fluttertoast/fluttertoast.dart';

class TencentBucketList extends StatefulWidget {
  TencentBucketList({Key? key}) : super(key: key);

  @override
  _TencentBucketListState createState() => _TencentBucketListState();
}

class _TencentBucketListState
    extends loadingState.BaseLoadingPageState<TencentBucketList> {
  List bucketMap = [];
  Map<String, String> aclState = {'aclState': '未获取'};

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    _onRefresh();
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
        setState(() {
          state = loadingState.LoadState.ERROR;
        });
        _refreshController.refreshCompleted();
        return;
      }
      if (bucketListResponse[1]['ListAllMyBucketsResult']['Buckets'] == null) {
        setState(() {
          state = loadingState.LoadState.EMPTY;
        });
        _refreshController.refreshCompleted();
        return;
      }
      var allBucketList =
          bucketListResponse[1]['ListAllMyBucketsResult']['Buckets']['Bucket'];

      if (allBucketList is! List) {
        allBucketList = [allBucketList];
      }

      for (var i = 0; i < allBucketList.length; i++) {
        String formatedTime = allBucketList[i]['CreationDate']
            .toString()
            .replaceAll('T', ' ')
            .replaceAll('Z', '');

        bucketMap.add({
          'name': allBucketList[i]['Name'],
          'location': allBucketList[i]['Location'],
          'CreationDate': formatedTime,
        });
      }
      setState(() {
        if (bucketMap.isEmpty) {
          state = loadingState.LoadState.EMPTY;
        } else {
          state = loadingState.LoadState.SUCCESS;
        }
        _refreshController.refreshCompleted();
      });
    } catch (e) {
      setState(() {
        state = loadingState.LoadState.ERROR;
      });
      Fluttertoast.showToast(msg: '请先登录');
      _refreshController.refreshCompleted();
    }
  }

  countBucketLocation(List elements, String location) {
    Map<String, int> locationCount = {};
    for (var i = 0; i < elements.length; i++) {
      if (locationCount.containsKey(elements[i]['location'])) {
        locationCount[elements[i]['location']] =
            locationCount[elements[i]['location']]! + 1;
      } else {
        locationCount[elements[i]['location']] = 1;
      }
    }
    return locationCount[location];
  }

  @override
  AppBar get appBar => AppBar(
        centerTitle: true,
        title: const Text('腾讯云存储桶列表'),
        actions: [
          IconButton(
            onPressed: () async {
              await Application.router.navigateTo(
                  context, Routes.tencentNewBucketConfig,
                  transition: TransitionType.cupertino);
              _onRefresh();
            },
            icon: const Icon(Icons.add),
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
          const Text('没有存储桶，点击右上角添加哦',
              style: TextStyle(
                  fontSize: 20, color: Color.fromARGB(136, 121, 118, 118)))
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
          const Text('加载失败',
              style: TextStyle(
                  fontSize: 20, color: Color.fromARGB(136, 121, 118, 118))),
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.blue),
            ),
            onPressed: () {
              setState(() {
                state = loadingState.LoadState.LOADING;
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
        controller: _refreshController,
        onRefresh: _onRefresh,
        child: GroupedListView(
          shrinkWrap: true,
          elements: bucketMap,
          groupBy: (element) => element['location'],
          itemComparator: (item1, item2) =>
              item1['CreationDate'].compareTo(item2['CreationDate']),
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
              // dense: true,
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
                //dense: true,
                minLeadingWidth: 0,
                contentPadding: const EdgeInsets.only(left: 20, right: 20),
                // visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
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
                      var result =
                          await TencentManageAPI.queryACLPolicy(element);
                      if (result[0] == 'success') {
                        var granteeURI = result[1]['AccessControlPolicy']
                            ['AccessControlList']['Grant'];

                        if (granteeURI is! List) {
                          granteeURI = [granteeURI];
                        }

                        bool publicRead = false;
                        bool publicWrite = false;
                        for (int i = 0; i < granteeURI.length; i++) {
                          String temp = granteeURI[i].toString();
                          if (temp.contains(
                                  "http://cam.qcloud.com/groups/global/AllUsers") &&
                              temp.contains('WRITE')) {
                            publicWrite = true;
                          }
                          if (temp.contains(
                                  "http://cam.qcloud.com/groups/global/AllUsers") &&
                              temp.contains('READ')) {
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
            subtitle: Text(element['CreationDate'],
                style: const TextStyle(fontSize: 12)),
          ),
          const Divider(
            height: 0.1,
            color: Color.fromARGB(255, 230, 230, 230),
          ),
          ListTile(
            // dense: true,
            leading: const Icon(
              Icons.check_box_outlined,
              color: Color.fromARGB(255, 97, 141, 236),
            ),
            // visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
            minLeadingWidth: 0,
            title: const Text('设为默认图床', style: TextStyle(fontSize: 15)),
            onTap: () async {
              if (aclState['aclState'] == '未获取' ||
                  aclState['aclState'] == 'private') {
                Fluttertoast.showToast(
                    msg: '请先修改存储桶权限',
                    toastLength: Toast.LENGTH_SHORT,
                    timeInSecForIosWeb: 2,
                    fontSize: 16.0);
                return;
              } else {
                var result =
                    await TencentManageAPI.setDefaultBucket(element, null);
                if (result[0] == 'success') {
                  Fluttertoast.showToast(
                      msg: '设置成功',
                      toastLength: Toast.LENGTH_SHORT,
                      timeInSecForIosWeb: 2,
                      fontSize: 16.0);
                  Navigator.pop(context);
                } else {
                  Fluttertoast.showToast(
                      msg: '设置失败',
                      toastLength: Toast.LENGTH_SHORT,
                      timeInSecForIosWeb: 2,
                      fontSize: 16.0);
                }
              }
            },
          ),
          const Divider(
            height: 0.1,
            color: Color.fromARGB(255, 230, 230, 230),
          ),
          ListTile(
            //dense: true,
            leading: const Icon(
              Icons.info_outline,
              color: Color.fromARGB(255, 97, 141, 236),
            ),
            // visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
            minLeadingWidth: 0,
            title: const Text('存储桶信息', style: TextStyle(fontSize: 15)),
            onTap: () {
              Application.router.navigateTo(context,
                  '${Routes.tencentBucketInformation}?bucketMap=${Uri.encodeComponent(jsonEncode(element))}',
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
            // visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
            minLeadingWidth: 0,
            // dense: true,
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
                  var response =
                      await TencentManageAPI.changeACLPolicy(element, value!);
                  if (response[0] == 'success') {
                    Fluttertoast.showToast(
                        msg: '修改完毕',
                        toastLength: Toast.LENGTH_SHORT,
                        timeInSecForIosWeb: 2,
                        fontSize: 16.0);
                    setState(() {
                      aclState['aclState'] = value;
                    });
                    Navigator.pop(context);
                  } else {
                    Fluttertoast.showToast(
                        msg: '修改失败',
                        toastLength: Toast.LENGTH_SHORT,
                        timeInSecForIosWeb: 2,
                        fontSize: 16.0);
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
              // dense: true,
              leading: const Icon(
                Icons.dangerous_outlined,
                color: Color.fromARGB(255, 240, 85, 131),
              ),
              //  visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
              minLeadingWidth: 0,
              title: const Text('删除存储桶', style: TextStyle(fontSize: 15)),
              onTap: () async {
                return showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text(
                        '删除存储桶',
                        textAlign: TextAlign.center,
                      ),
                      content: const Text(
                        '是否删除存储桶？\n删除前请清空该存储桶!',
                        textAlign: TextAlign.center,
                      ),
                      actions: [
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextButton(
                                child: const Text(
                                  '确定',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                                onPressed: () async {
                                  try {
                                    Navigator.of(context).pop();
                                    Navigator.of(context).pop();
                                    var result =
                                        await TencentManageAPI.deleteBucket(
                                            element);
                                    if (result[0] == 'success') {
                                      Fluttertoast.showToast(
                                          msg: '删除成功',
                                          toastLength: Toast.LENGTH_SHORT,
                                          timeInSecForIosWeb: 2,
                                          fontSize: 16.0);
                                      _onRefresh();
                                      return;
                                    } else {
                                      Fluttertoast.showToast(
                                          msg: '删除失败',
                                          toastLength: Toast.LENGTH_SHORT,
                                          timeInSecForIosWeb: 2,
                                          fontSize: 16.0);
                                    }
                                    return;
                                  } catch (e) {
                                    Fluttertoast.showToast(
                                        msg: '删除失败',
                                        toastLength: Toast.LENGTH_SHORT,
                                        timeInSecForIosWeb: 2,
                                        fontSize: 16.0);
                                    Navigator.of(context).pop();
                                  }
                                },
                              ),
                              TextButton(
                                style: TextButton.styleFrom(
                                  alignment: Alignment.center,
                                ),
                                child: const Text(
                                  '取消',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          ),
                        )
                      ],
                    );
                  },
                );
              }),
        ],
      ),
    );
  }
}
