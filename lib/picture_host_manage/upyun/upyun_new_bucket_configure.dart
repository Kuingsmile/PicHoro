import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:horopic/picture_host_manage/manage_api/upyun_manage_api.dart';
import 'package:horopic/utils/common_functions.dart';

class UpyunNewBucketConfig extends StatefulWidget {
  const UpyunNewBucketConfig({
    super.key,
  });

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
        title: titleText('新建存储桶'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColor.withAlpha(204)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
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
                  var queryUpyun = await UpyunManageAPI.readUpyunConfig();
                  if (queryUpyun != 'Error') {
                    var jsonResult = jsonDecode(queryUpyun);
                    defaultOperatorController.text = jsonResult['operator'];
                    defaultPasswordController.text = jsonResult['password'];
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
                  var result = await UpyunManageAPI.putBucket(bucketNameController.text);

                  if (result[0] == 'success') {
                    var result2 = await UpyunManageAPI.addOperator(
                      bucketNameController.text,
                      defaultOperatorController.text,
                    );
                    if (result2[0] == 'success') {
                      showToast('创建成功');
                      var insertOperator = await UpyunManageAPI.saveUpyunOperatorConfig(
                        bucketNameController.text,
                        upyunManageConfigMap['email'],
                        defaultOperatorController.text,
                        defaultPasswordController.text,
                      );
                      if (!insertOperator) {
                        showToast('数据保存错误');
                        return;
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
