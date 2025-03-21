import 'dart:convert';

import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:horopic/widgets/common_widgets.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:grouped_list/grouped_list.dart';

import 'package:horopic/router/application.dart';
import 'package:horopic/router/routers.dart';
import 'package:horopic/picture_host_manage/common/loading_state.dart' as loading_state;
import 'package:horopic/picture_host_manage/manage_api/upyun_manage_api.dart';
import 'package:horopic/utils/common_functions.dart';

class UpyunBucketList extends StatefulWidget {
  const UpyunBucketList({super.key});

  @override
  UpyunBucketListState createState() => UpyunBucketListState();
}

class UpyunBucketListState extends loading_state.BaseLoadingPageState<UpyunBucketList> {
  List bucketMap = [];
  Map upyunManageConfigMap = {};

  RefreshController refreshController = RefreshController(initialRefresh: false);
  TextEditingController nameController = TextEditingController();
  TextEditingController passwdController = TextEditingController();
  TextEditingController optionController = TextEditingController();
  TextEditingController pathController = TextEditingController();
  TextEditingController antiLeechTokenController = TextEditingController();
  TextEditingController antiLeechExpireController = TextEditingController();
  TextEditingController defaultOperatorController = TextEditingController();
  TextEditingController defaultPasswordController = TextEditingController();
  List selectionList = [];
  bool isUsePSConfig = false;
  bool isUseRemotePSConfig = false;

  UpyunManageAPI manageAPI = UpyunManageAPI();

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
    await initBucketList();
    refreshController.refreshCompleted();
    var queryUpyun = await manageAPI.readCurrentConfig();
    if (queryUpyun != 'Error' && queryUpyun != '') {
      var jsonResult = jsonDecode(queryUpyun);
      nameController.text = jsonResult['operator'];
      passwdController.text = jsonResult['password'];
    }
    var result = await manageAPI.getUpyunManageConfigMap();
    if (result != 'Error') {
      upyunManageConfigMap = result;
    }
  }

  //初始化bucketList
  initBucketList() async {
    bucketMap.clear();
    try {
      var bucketListResponse = await manageAPI.getBucketList();
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
      if (bucketListResponse.isEmpty) {
        if (mounted) {
          setState(() {
            state = loading_state.LoadState.empty;
          });
        }
        refreshController.refreshCompleted();
        return;
      }
      var allBucketList = bucketListResponse[1];

      if (allBucketList is! List) {
        allBucketList = [allBucketList];
      }
      for (var i = 0; i < allBucketList.length; i++) {
        String formatedTime = allBucketList[i]['created_at'];
        String bucketName = allBucketList[i]['bucket_name'];
        var bucketInfoResponse = await manageAPI.getBucketInfo(bucketName);
        if (bucketInfoResponse[0] != 'success') {
          if (mounted) {
            setState(() {
              state = loading_state.LoadState.error;
            });
          }
          refreshController.refreshCompleted();
          return;
        }
        var bucketInfo = bucketInfoResponse[1];
        bucketMap.add({
          'bucket_id': allBucketList[i]['bucket_id'],
          'bucket_name': allBucketList[i]['bucket_name'],
          'https': bucketInfo['default_domain']['https'],
          'operator': bucketInfo['operators'],
          'separator': bucketInfo['separator'],
          'domains': bucketInfo['default_domain']['domain'],
          'tag': allBucketList[i]['tag'], // 可选值：vod，download,picture,null
          'status': allBucketList[i]['status'],
          'CreationDate': formatedTime,
        });
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
      flogErr(
        e,
        {},
        'UpyunBucketListState',
        'initBucketList',
      );
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
        elevation: 3,
        centerTitle: true,
        leading: getLeadingIcon(context),
        title: titleText('又拍云存储桶列表'),
        flexibleSpace: getFlexibleSpace(context),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: IconButton(
              onPressed: () async {
                await Application.router
                    .navigateTo(context, Routes.upyunTokenManagePage, transition: TransitionType.cupertino);
              },
              icon: const Icon(
                Icons.perm_identity,
                color: Colors.white,
              ),
              iconSize: 30,
              tooltip: '令牌管理',
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              onPressed: () async {
                await Application.router
                    .navigateTo(context, Routes.upyunNewBucketConfig, transition: TransitionType.cupertino);
                _onRefresh();
              },
              icon: const Icon(
                Icons.add_circle_outline,
                color: Colors.white,
              ),
              iconSize: 30,
              tooltip: '新建存储桶',
            ),
          ),
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
          groupBy: (element) => element['status'],
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
                Icon(Icons.folder_special, color: Colors.blue.shade700, size: 20),
                const SizedBox(width: 8),
                Text(
                  value,
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
                  element['bucket_name'],
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
                      Text(
                        element['CreationDate'],
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '域名: ${element['domains']}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                onTap: () async {
                  Map configElement = {};
                  configElement['bucket'] = element['bucket_name'];
                  var queryOperator = await manageAPI.readUpyunOperatorConfig();
                  if (queryOperator == 'Error') {
                    return showToast('请先设置操作员信息');
                  }
                  var jsonResult = jsonDecode(queryOperator);
                  // 判断bucket是否存在
                  if (jsonResult['${element['bucket_name']}'] == null) {
                    return showToast('请先在底部弹出栏中添加操作员');
                  }
                  configElement['operator'] = jsonResult['${element['bucket_name']}']['operator'];
                  configElement['password'] = jsonResult['${element['bucket_name']}']['password'];

                  String url = element['domains'];
                  if (!url.startsWith('http') && !url.startsWith('https')) {
                    url = element['https'] == 'true' ? 'https://$url' : 'http://$url';
                  }
                  if (url.endsWith('/')) {
                    url = url.substring(0, url.length - 1);
                  }
                  configElement['url'] = url;
                  if (mounted) {
                    Application.router.navigateTo(context,
                        '${Routes.upyunFileExplorer}?element=${Uri.encodeComponent(jsonEncode(configElement))}&bucketPrefix=${Uri.encodeComponent('/')}',
                        transition: TransitionType.cupertino);
                  }
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

  Widget setDefaultPSHost(Map element) {
    return StatefulBuilder(builder: (BuildContext context, void Function(void Function()) setState) {
      return CupertinoAlertDialog(
        title:
            Text('设置默认图床配置', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue.shade700)),
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Column(
            children: [
              const SizedBox(height: 10),
              CupertinoTextField(
                textAlign: TextAlign.center,
                prefix: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('后缀', style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
                ),
                controller: optionController,
                placeholder: '网站后缀，非必填',
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              ),
              const SizedBox(height: 10),
              CupertinoTextField(
                prefix: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('路径', style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
                ),
                textAlign: TextAlign.center,
                controller: pathController,
                placeholder: '图床路径，非必填',
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              ),
              const SizedBox(height: 10),
              CupertinoTextField(
                prefix: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('防盗链密钥', style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
                ),
                textAlign: TextAlign.center,
                controller: antiLeechTokenController,
                placeholder: '防盗链密钥，非必填',
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              ),
              const SizedBox(height: 10),
              CupertinoTextField(
                prefix: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('过期时间', style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
                ),
                textAlign: TextAlign.center,
                controller: antiLeechExpireController,
                placeholder: '防盗链过期时间，非必填',
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              ),
              const SizedBox(height: 10),
              CupertinoTextField(
                prefix: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('操作员', style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
                ),
                textAlign: TextAlign.center,
                controller: defaultOperatorController,
                placeholder: '操作员',
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              ),
              const SizedBox(height: 10),
              CupertinoTextField(
                prefix: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('密码', style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
                ),
                textAlign: TextAlign.center,
                controller: defaultPasswordController,
                placeholder: '操作员密码',
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              ),
              Container(
                margin: const EdgeInsets.only(top: 12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CheckboxListTile(
                  dense: true,
                  title: const Text(
                    '使用图床配置中的操作员和密码',
                    style: TextStyle(fontSize: 14),
                  ),
                  value: isUsePSConfig,
                  activeColor: Colors.blue,
                  onChanged: (value) async {
                    if (value == true) {
                      var queryUpyun = await manageAPI.readCurrentConfig();
                      if (queryUpyun != 'Error' && queryUpyun != '') {
                        var jsonResult = jsonDecode(queryUpyun);
                        defaultOperatorController.text = jsonResult['operator'];
                        defaultPasswordController.text = jsonResult['password'];
                        setState(() {
                          if (isUseRemotePSConfig) {
                            isUseRemotePSConfig = false;
                          }
                          isUsePSConfig = value!;
                        });
                      } else {
                        showToast('请先去设置页面配置');
                      }
                    } else {
                      defaultOperatorController.clear();
                      defaultPasswordController.clear();
                      setState(() {
                        isUsePSConfig = value!;
                      });
                    }
                  },
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 6),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CheckboxListTile(
                  dense: true,
                  title: const Text(
                    '使用已设置的操作员信息',
                    style: TextStyle(fontSize: 14),
                  ),
                  value: isUseRemotePSConfig,
                  activeColor: Colors.blue,
                  onChanged: (value) async {
                    if (value == true) {
                      var queryOperator = await manageAPI.readUpyunOperatorConfig();
                      if (queryOperator != 'Error') {
                        var jsonResult = jsonDecode(queryOperator);
                        defaultOperatorController.text = jsonResult['${element['bucket_name']}']['operator'];
                        defaultPasswordController.text = jsonResult['${element['bucket_name']}']['password'];
                        setState(() {
                          if (isUsePSConfig) {
                            isUsePSConfig = false;
                          }
                          isUseRemotePSConfig = value!;
                        });
                      } else {
                        showToast('请先设置操作员信息');
                      }
                    } else {
                      defaultOperatorController.clear();
                      defaultPasswordController.clear();
                      setState(() {
                        isUseRemotePSConfig = value!;
                      });
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('取消', style: TextStyle(color: Colors.grey)),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          CupertinoDialogAction(
            child: const Text('确定', style: TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () async {
              try {
                var option = optionController.text;
                var path = pathController.text;
                var operator = defaultOperatorController.text;
                var password = defaultPasswordController.text;
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
                if (antiLeechTokenController.text == '' || antiLeechTokenController.text.replaceAll(' ', '').isEmpty) {
                  textMap['antiLeechToken'] = '';
                } else {
                  textMap['antiLeechToken'] = antiLeechTokenController.text;
                }
                if (antiLeechExpireController.text == '' ||
                    antiLeechExpireController.text.replaceAll(' ', '').isEmpty) {
                  textMap['antiLeechExpire'] = '';
                } else {
                  textMap['antiLeechExpire'] = antiLeechExpireController.text;
                }
                if (operator == '' || password == '') {
                  showToast('请设定操作员和密码');
                  return;
                }
                textMap['operator'] = operator;
                textMap['password'] = password;

                var updateOperator = await manageAPI.saveUpyunOperatorConfig(
                  element['bucket_name'],
                  upyunManageConfigMap['email'],
                  textMap['operator'],
                  textMap['password'],
                );
                if (!updateOperator) {
                  showToast('数据库错误');
                  return;
                }

                var result = await manageAPI.setDefaultBucketFromListPage(element, upyunManageConfigMap, textMap);
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
                  {},
                  'UpyunBucketListState',
                  'setDefaultPSHost',
                );
              }
            },
          ),
        ],
      );
    });
  }

  Widget operatorNameAndPasswdInputCupertinoDialog(Map element) {
    return CupertinoAlertDialog(
      title: Text('设置操作员', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue.shade700)),
      content: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            CupertinoTextField(
              textAlign: TextAlign.center,
              controller: nameController,
              placeholder: '操作员名称',
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            ),
            const SizedBox(height: 12),
            CupertinoTextField(
              textAlign: TextAlign.center,
              controller: passwdController,
              placeholder: '操作员密码',
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              obscureText: true,
            ),
          ],
        ),
      ),
      actions: [
        CupertinoDialogAction(
          child: const Text('取消', style: TextStyle(color: Colors.grey)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        CupertinoDialogAction(
          child: const Text('确定', style: TextStyle(fontWeight: FontWeight.bold)),
          onPressed: () async {
            Navigator.of(context).pop();
            var queryOperator = await manageAPI.getOperator(
              element['bucket_name'],
            );
            if (queryOperator[0] != 'success') {
              return showToast('获取操作员失败');
            }
            List operatorList = [];
            for (var operator in queryOperator[1]) {
              operatorList.add(operator['operator_name']);
            }

            if (operatorList.contains(nameController.text)) {
              var updateOperator = await manageAPI.saveUpyunOperatorConfig(
                  element['bucket_name'], upyunManageConfigMap['email'], nameController.text, passwdController.text);
              if (!updateOperator) {
                return showToast('更新操作员数据库失败');
              }
              return showToast('设置操作员成功');
            }
            var addOperator = await manageAPI.addOperator(
              element['bucket_name'],
              nameController.text,
            );
            if (addOperator[0] == 'success') {
              var insertOperator = await manageAPI.saveUpyunOperatorConfig(
                  element['bucket_name'], upyunManageConfigMap['email'], nameController.text, passwdController.text);
              if (!insertOperator) {
                return showToast('插入操作员数据库失败');
              }
              return showToast('设置操作员成功');
            }
            return showToast('添加操作员失败');
          },
        ),
      ],
    );
  }

  List<Widget> buildremoveOperatorSelectionCupertinoDialog(Map operatorMap) {
    List<Widget> children = [];
    for (var i = 0; i < operatorMap.length; i++) {
      children.add(StatefulBuilder(
        builder: (BuildContext context, void Function(void Function()) setState) {
          Map<bool, String> trans = {
            true: '√',
            false: '×',
          };
          return CheckboxListTile(
            dense: true,
            visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
            title: Text(operatorMap.keys.toList()[i]),
            subtitle: Text(
                '读${trans[operatorMap[operatorMap.keys.toList()[i]]['read']]}写${trans[operatorMap[operatorMap.keys.toList()[i]]['write']]}删${trans[operatorMap[operatorMap.keys.toList()[i]]['delete']]}',
                style: const TextStyle(fontSize: 12, color: Colors.blue, fontWeight: FontWeight.bold)),
            value: selectionList[i],
            onChanged: (value) {
              setState(() {
                selectionList[i] = value;
              });
            },
          );
        },
      ));
    }
    return children;
  }

  Widget removeOperatorSelectionCupertinoDialog(BuildContext context, Map element, Map operatorMap) {
    selectionList.clear();
    for (var i = 0; i < operatorMap.length; i++) {
      selectionList.add(false);
    }
    return CupertinoAlertDialog(
      scrollController: ScrollController(),
      title: const Text('请选择要解绑的操作员'),
      content: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blueGrey),
            borderRadius: BorderRadius.circular(5),
          ),
          child: SizedBox(
              height: 150,
              width: 300,
              child: SingleChildScrollView(
                  child: Column(children: buildremoveOperatorSelectionCupertinoDialog(operatorMap))))),
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
              Navigator.of(context).pop();
              List<String> operatorList = [];
              for (var i = 0; i < selectionList.length; i++) {
                if (selectionList[i]) {
                  operatorList.add(operatorMap.keys.toList()[i]);
                }
              }
              for (var i = 0; i < operatorList.length; i++) {
                var removeOperator = await manageAPI.deleteOperator(element['bucket_name'], operatorList[i]);
                if (removeOperator[0] == 'success') {
                  var queryOperator = await manageAPI.readUpyunOperatorConfig();
                  if (queryOperator != 'Error') {
                    var jsonResult = jsonDecode(queryOperator);
                    var currentOperator = jsonResult['${element['bucket_name']}']['operator'];
                    if (currentOperator == operatorList[i]) {
                      await manageAPI.deleteUpyunOperatorConfig(element['bucket_name']);
                    }
                  }
                }
              }
            } catch (e) {
              flogErr(
                e,
                {},
                'UpyunBucketListState',
                'removeOperatorSelectionCupertinoDialog',
              );
            }
          },
        ),
      ],
    );
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
                        element['bucket_name'],
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
            icon: Icons.check_circle_outline,
            iconColor: Colors.green,
            title: '设为默认图床',
            onTap: () async {
              Navigator.pop(context);
              await showCupertinoDialog(
                  builder: (context) {
                    return setDefaultPSHost(element);
                  },
                  context: context);
            },
          ),
          _buildActionTile(
            icon: Icons.info_outline,
            iconColor: Colors.blue,
            title: '存储桶信息',
            onTap: () {
              Navigator.pop(context);
              Application.router.navigateTo(
                  context, '${Routes.upyunBucketInformation}?bucketMap=${Uri.encodeComponent(jsonEncode(element))}',
                  transition: TransitionType.none);
            },
          ),
          _buildActionTile(
            icon: Icons.manage_accounts_outlined,
            iconColor: Colors.purple,
            title: '设置操作员信息',
            onTap: () async {
              Navigator.pop(context);
              await showCupertinoDialog(
                  builder: (context) {
                    return operatorNameAndPasswdInputCupertinoDialog(element);
                  },
                  context: context);
            },
          ),
          _buildActionTile(
            icon: Icons.link_off,
            iconColor: Colors.orange,
            title: '解绑操作员',
            onTap: () async {
              List operatorList = await manageAPI.getOperator(element['bucket_name']);
              Map operatorMap = {};
              if (operatorList.isEmpty) {
                return showToast('获取操作员失败');
              } else {
                for (var operators in operatorList[1]) {
                  operatorMap[operators['operator_name']] = {
                    'read': operators['operator_auth']['read'],
                    'write': operators['operator_auth']['write'],
                    'delete': operators['operator_auth']['delete'],
                  };
                }
              }
              if (mounted) {
                Navigator.pop(context);
              }
              if (operatorMap.isEmpty) {
                return showToast('没有绑定的操作员');
              }
              if (context.mounted) {
                await showCupertinoDialog(
                    builder: (context) {
                      return removeOperatorSelectionCupertinoDialog(context, element, operatorMap);
                    },
                    context: context);
              }
            },
          ),
          const Divider(height: 10),
          _buildActionTile(
            icon: Icons.delete_outline,
            iconColor: Colors.red,
            title: '删除存储桶',
            onTap: () async {
              Navigator.pop(context);
              return showCupertinoAlertDialogWithConfirmFunc(
                title: '删除存储桶',
                content: '是否删除存储桶？\n删除前请清空该存储桶!',
                context: context,
                onConfirm: () async {
                  var result = await manageAPI.deleteBucket(element['bucket_name']);
                  if (result[0] == 'success') {
                    showToast('删除成功');
                    _onRefresh();
                  } else {
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
    required VoidCallback onTap,
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
          ],
        ),
      ),
    );
  }
}
