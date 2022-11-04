import 'package:flutter/material.dart';

import 'package:horopic/picture_host_manage/manage_api/upyun_manage_api.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/utils/global.dart';
import 'package:horopic/utils/sql_utils.dart';

class UpyunNewBucketConfig extends StatefulWidget {
  const UpyunNewBucketConfig({
    Key? key,
  }) : super(key: key);

  @override
  UpyunNewBucketConfigState createState() => UpyunNewBucketConfigState();
}

class UpyunNewBucketConfigState extends State<UpyunNewBucketConfig> {
  Map upyunManageConfigMap = {};
  TextEditingController bucketNameController = TextEditingController();
  TextEditingController defaultOperatorController = TextEditingController();
  TextEditingController defaultPasswordController = TextEditingController();
  bool isUsePSConfig = false;

  @override
  initState() {
    super.initState();
    _onRefresh();
  }

  _onRefresh() async {
    var result = await UpyunManageAPI.getUpyunManageConfigMap();
    if (result != 'Error') {
      upyunManageConfigMap = result;
    }
    setState(() {});
  }

  @override
  void dispose() {
    bucketNameController.dispose();
    defaultOperatorController.dispose();
    defaultPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text('新建存储桶'),
      ),
      body: ListView(
        children: [
          TextFormField(
            decoration: const InputDecoration(
              label: Center(child: Text('bucket名称')),
              hintText: '设定bucket',
            ),
            controller: bucketNameController,
            textAlign: TextAlign.center,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '请输入bucket';
              }
              return null;
            },
          ),
          TextFormField(
            decoration: const InputDecoration(
              label: Center(child: Text('默认操作员')),
              hintText: '设定默认操作员',
            ),
            controller: defaultOperatorController,
            textAlign: TextAlign.center,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '请输入默认操作员';
              }
              return null;
            },
          ),
          TextFormField(
            decoration: const InputDecoration(
              label: Center(child: Text('默认操作员密码')),
              hintText: '设定默认操作员密码',
            ),
            controller: defaultPasswordController,
            textAlign: TextAlign.center,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '请输入默认操作员密码';
              }
              return null;
            },
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
                  var queryUpyun =
                      await MySqlUtils.queryUpyun(username: Global.defaultUser);
                  if (queryUpyun != 'Empty' && queryUpyun != 'Error') {
                    defaultOperatorController.text = queryUpyun['operator'];
                    defaultPasswordController.text = queryUpyun['password'];
                    setState(() {
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
          ListTile(
            subtitle: ElevatedButton(
              onPressed: () async {
                if (bucketNameController.text.isEmpty ||
                    defaultOperatorController.text.isEmpty ||
                    defaultPasswordController.text.isEmpty) {
                  showToast('请填写完整信息');
                } else {
                  var result =
                      await UpyunManageAPI.putBucket(bucketNameController.text);

                  if (result[0] == 'success') {
                    var result2 = await UpyunManageAPI.addOperator(
                      bucketNameController.text,
                      defaultOperatorController.text,
                    );
                    if (result2[0] == 'success') {
                      showToast('创建成功');
                      String usernameEmailBucket =
                          '${Global.defaultUser}_${upyunManageConfigMap['email']}_${bucketNameController.text}';
                      var queryOperator = await MySqlUtils.queryUpyunOperator(
                          username: usernameEmailBucket);
                      if (queryOperator == 'Error') {
                        showToast('数据库错误');
                        return;
                      } else if (queryOperator == 'Empty') {
                        List content = [
                          bucketNameController.text,
                          upyunManageConfigMap['email'],
                          defaultOperatorController.text,
                          defaultPasswordController.text,
                          usernameEmailBucket
                        ];
                        var insertOperator =
                            await MySqlUtils.insertUpyunOperator(
                                content: content);
                        if (insertOperator == 'Error') {
                          showToast('数据库错误');
                          return;
                        }
                      } else {
                        List content = [
                          bucketNameController.text,
                          upyunManageConfigMap['email'],
                          defaultOperatorController.text,
                          defaultPasswordController.text,
                          usernameEmailBucket
                        ];
                        var updateOperator =
                            await MySqlUtils.updateUpyunOperator(
                                content: content);
                        if (updateOperator == 'Error') {
                          showToast('数据库错误');
                          return;
                        }
                      }
                      if (mounted) {
                        Navigator.pop(context);
                      }
                    } else {
                      showToast('添加操作员失败');
                    }
                  } else {
                    showToast('创建失败');
                  }
                }
              },
              child: const Text('创建'),
            ),
          ),
        ],
      ),
    );
  }
}
