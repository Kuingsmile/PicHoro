import 'dart:convert';

import 'package:fluro/fluro.dart';
import 'package:f_logs/f_logs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:grouped_list/grouped_list.dart';

import 'package:horopic/router/application.dart';
import 'package:horopic/router/routers.dart';
import 'package:horopic/picture_host_manage/common_page/loading_state.dart' as loading_state;
import 'package:horopic/picture_host_manage/manage_api/upyun_manage_api.dart';
import 'package:horopic/utils/common_functions.dart';

class UpyunBucketList extends StatefulWidget {
  const UpyunBucketList({Key? key}) : super(key: key);

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
    var queryUpyun = await UpyunManageAPI.readUpyunConfig();
    if (queryUpyun != 'Error') {
      var jsonResult = jsonDecode(queryUpyun);
      nameController.text = jsonResult['operator'];
      passwdController.text = jsonResult['password'];
    }
    var result = await UpyunManageAPI.getUpyunManageConfigMap();
    if (result != 'Error') {
      upyunManageConfigMap = result;
    }
  }

  //初始化bucketList
  initBucketList() async {
    bucketMap.clear();
    try {
      var bucketListResponse = await UpyunManageAPI.getBucketList();
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
      if (bucketListResponse.isEmpty) {
        if (mounted) {
          setState(() {
            state = loading_state.LoadState.EMPTY;
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
        var bucketInfoResponse = await UpyunManageAPI.getBucketInfo(bucketName);
        if (bucketInfoResponse[0] != 'success') {
          if (mounted) {
            setState(() {
              state = loading_state.LoadState.ERROR;
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
            state = loading_state.LoadState.EMPTY;
          } else {
            state = loading_state.LoadState.SUCCESS;
          }
          refreshController.refreshCompleted();
        });
      }
    } catch (e) {
      FLog.error(
          className: 'UpyunBucketListState',
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

  @override
  AppBar get appBar => AppBar(
        elevation: 0,
        centerTitle: true,
        title: titleText('又拍云存储桶列表'),
        actions: [
          IconButton(
            onPressed: () async {
              await Application.router
                  .navigateTo(context, Routes.upyunTokenManagePage, transition: TransitionType.cupertino);
            },
            icon: const Icon(
              Icons.perm_identity,
              color: Colors.white,
            ),
            iconSize: 35,
          ),
          IconButton(
            onPressed: () async {
              await Application.router
                  .navigateTo(context, Routes.upyunNewBucketConfig, transition: TransitionType.cupertino);
              _onRefresh();
            },
            icon: const Icon(
              Icons.add,
              color: Colors.white,
            ),
            iconSize: 35,
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
          groupBy: (element) => element['status'],
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
              // dense: true,
              visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
              title: Text(
                value,
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
                title: Text(element['bucket_name']),
                subtitle: Text(element['CreationDate']),
                onTap: () async {
                  Map configElement = {};
                  configElement['bucket'] = element['bucket_name'];
                  var queryOperator = await UpyunManageAPI.readUpyunOperatorConfig();
                  if (queryOperator != 'Error') {
                    var jsonResult = jsonDecode(queryOperator);
                    // 判断bucket是否存在
                    if (jsonResult['${element['bucket_name']}'] == null) {
                      return showToast('请先在底部弹出栏中添加操作员');
                    }
                    configElement['operator'] = jsonResult['${element['bucket_name']}']['operator'];
                    configElement['password'] = jsonResult['${element['bucket_name']}']['password'];
                  } else {
                    return showToast('请先在底部弹出栏中添加操作员');
                  }
                  String url = element['domains'];
                  if (!url.startsWith('http') && !url.startsWith('https')) {
                    if (element['https'] == 'true') {
                      url = 'https://$url';
                    } else {
                      url = 'http://$url';
                    }
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

  Widget setDefaultPSHost(Map element) {
    return StatefulBuilder(builder: (BuildContext context, void Function(void Function()) setState) {
      return CupertinoAlertDialog(
        title:
            const Text('请输入网站后缀和图床路径', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue)),
        content: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            CupertinoTextField(
              textAlign: TextAlign.center,
              prefix: const Text('后缀：', style: TextStyle(fontSize: 16, color: Color.fromARGB(255, 121, 118, 118))),
              controller: optionController,
              placeholder: '网站后缀，非必填',
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
              prefix: const Text('防盗链密钥', style: TextStyle(fontSize: 16, color: Color.fromARGB(255, 121, 118, 118))),
              textAlign: TextAlign.center,
              controller: antiLeechTokenController,
              placeholder: '防盗链密钥，非必填',
            ),
            const SizedBox(
              height: 10,
            ),
            CupertinoTextField(
              prefix: const Text('过期时间', style: TextStyle(fontSize: 16, color: Color.fromARGB(255, 121, 118, 118))),
              textAlign: TextAlign.center,
              controller: antiLeechExpireController,
              placeholder: '防盗链过期时间，非必填',
            ),
            const SizedBox(
              height: 10,
            ),
            CupertinoTextField(
              prefix: const Text('操作员：', style: TextStyle(fontSize: 16, color: Color.fromARGB(255, 121, 118, 118))),
              textAlign: TextAlign.center,
              controller: defaultOperatorController,
              placeholder: '操作员',
            ),
            const SizedBox(
              height: 10,
            ),
            CupertinoTextField(
              prefix: const Text('密码：', style: TextStyle(fontSize: 16, color: Color.fromARGB(255, 121, 118, 118))),
              textAlign: TextAlign.center,
              controller: defaultPasswordController,
              placeholder: '操作员密码',
            ),
            CheckboxListTile(
                dense: true,
                title: const Text(
                  '使用图床配置中的操作员和密码',
                  style: TextStyle(fontSize: 14),
                ),
                value: isUsePSConfig,
                onChanged: (value) async {
                  if (value == true) {
                    var queryUpyun = await UpyunManageAPI.readUpyunConfig();
                    if (queryUpyun != 'Error') {
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
                }),
            CheckboxListTile(
                dense: true,
                title: const Text(
                  '使用已设置的操作员信息',
                  style: TextStyle(fontSize: 14),
                ),
                value: isUseRemotePSConfig,
                onChanged: (value) async {
                  if (value == true) {
                    var queryOperator = await UpyunManageAPI.readUpyunOperatorConfig();
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

                var updateOperator = await UpyunManageAPI.saveUpyunOperatorConfig(
                  element['bucket_name'],
                  upyunManageConfigMap['email'],
                  textMap['operator'],
                  textMap['password'],
                );
                if (!updateOperator) {
                  showToast('数据库错误');
                  return;
                }

                var result = await UpyunManageAPI.setDefaultBucketFromListPage(element, upyunManageConfigMap, textMap);
                if (result[0] == 'success') {
                  showToast('设置成功');
                  if (mounted) {
                    Navigator.pop(context);
                  }
                } else {
                  showToast('设置失败');
                }
              } catch (e) {
                FLog.error(
                    className: 'UpyunManagePage',
                    methodName: 'setDefaultPSHost',
                    text: formatErrorMessage({}, e.toString()),
                    dataLogType: DataLogType.ERRORS.toString());
              }
            },
          ),
        ],
      );
    });
  }

  Widget operatorNameAndPasswdInputCupertinoDialog(Map element) {
    return CupertinoAlertDialog(
      title: const Text('请输入操作员名称和密码'),
      content: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          CupertinoTextField(
            textAlign: TextAlign.center,
            controller: nameController,
            placeholder: '操作员名称',
          ),
          const SizedBox(
            height: 10,
          ),
          CupertinoTextField(
            textAlign: TextAlign.center,
            controller: passwdController,
            placeholder: '操作员密码',
          ),
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
            Navigator.of(context).pop();
            var queryOperator = await UpyunManageAPI.getOperator(
              element['bucket_name'],
            );
            if (queryOperator[0] == 'success') {
              List operatorList = [];
              for (var operator in queryOperator[1]) {
                operatorList.add(operator['operator_name']);
              }

              if (operatorList.contains(nameController.text)) {
                var updateOperator = await UpyunManageAPI.saveUpyunOperatorConfig(
                    element['bucket_name'], upyunManageConfigMap['email'], nameController.text, passwdController.text);
                if (!updateOperator) {
                  return showToast('更新操作员数据库失败');
                } else {
                  return showToast('设置操作员成功');
                }
              } else {
                var addOperator = await UpyunManageAPI.addOperator(
                  element['bucket_name'],
                  nameController.text,
                );
                if (addOperator[0] == 'success') {
                  var insertOperator = await UpyunManageAPI.saveUpyunOperatorConfig(element['bucket_name'],
                      upyunManageConfigMap['email'], nameController.text, passwdController.text);
                  if (!insertOperator) {
                    return showToast('插入操作员数据库失败');
                  } else {
                    return showToast('设置操作员成功');
                  }
                } else {
                  return showToast('添加操作员失败');
                }
              }
            } else {
              return showToast('获取操作员失败');
            }
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
                var removeOperator = await UpyunManageAPI.deleteOperator(element['bucket_name'], operatorList[i]);
                if (removeOperator[0] == 'success') {
                  var queryOperator = await UpyunManageAPI.readUpyunOperatorConfig();
                  if (queryOperator != 'Error') {
                    var jsonResult = jsonDecode(queryOperator);
                    var currentOperator = jsonResult['${element['bucket_name']}']['operator'];
                    if (currentOperator == operatorList[i]) {
                      await UpyunManageAPI.deleteUpyunOperatorConfig(element['bucket_name']);
                    }
                  }
                }
              }
            } catch (e) {
              FLog.error(
                  className: 'UpyunManagePage',
                  methodName: 'removeOperatorSelectionCupertinoDialog',
                  text: formatErrorMessage({}, e.toString()),
                  dataLogType: DataLogType.ERRORS.toString());
            }
          },
        ),
      ],
    );
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
              element['bucket_name'],
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
              Icons.check_box_outlined,
              color: Color.fromARGB(255, 97, 141, 236),
            ),
            minLeadingWidth: 0,
            title: const Text('设为默认图床', style: TextStyle(fontSize: 15)),
            onTap: () async {
              Navigator.pop(context);
              await showCupertinoDialog(
                  builder: (context) {
                    return setDefaultPSHost(element);
                  },
                  context: context);
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
                  context, '${Routes.upyunBucketInformation}?bucketMap=${Uri.encodeComponent(jsonEncode(element))}',
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
            title: const Text('设置操作员信息', style: TextStyle(fontSize: 15)),
            onTap: () async {
              Navigator.pop(context);
              await showCupertinoDialog(
                  builder: (context) {
                    return operatorNameAndPasswdInputCupertinoDialog(element);
                  },
                  context: context);
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.miscellaneous_services_sharp,
              color: Color.fromARGB(255, 97, 141, 236),
            ),
            minLeadingWidth: 0,
            title: const Text('解绑操作员', style: TextStyle(fontSize: 15)),
            onTap: () async {
              List operatorList = await UpyunManageAPI.getOperator(element['bucket_name']);
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
                    var result = await UpyunManageAPI.deleteBucket(element['bucket_name']);
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
                        className: 'UpyunBucketListPage',
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
