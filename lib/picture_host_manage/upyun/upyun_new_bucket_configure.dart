import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:horopic/picture_host_manage/manage_api/upyun_manage_api.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/widgets/common_widgets.dart';

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
    var result = await UpyunManageAPI().getUpyunManageConfigMap();
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
        leading: getLeadingIcon(context),
        centerTitle: true,
        title: titleText('新建存储桶'),
        flexibleSpace: getFlexibleSpace(context),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header section
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      Icon(Icons.cloud_outlined, color: Theme.of(context).primaryColor, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        "基本信息",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),

                // Form Card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Bucket name field
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: '存储桶名称',
                            hintText: '请输入bucket名称',
                            prefixIcon: const Icon(Icons.folder_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Theme.of(context).primaryColor),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          controller: bucketNameController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '请输入bucket';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 20),

                        // Default operator field
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: '默认操作员',
                            hintText: '设定默认操作员',
                            prefixIcon: const Icon(Icons.person_outline),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Theme.of(context).primaryColor),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          controller: defaultOperatorController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '请输入默认操作员';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 20),

                        // Default password field
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: '默认操作员密码',
                            hintText: '设定默认操作员密码',
                            prefixIcon: const Icon(Icons.lock_outline),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Theme.of(context).primaryColor),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          obscureText: true,
                          controller: defaultPasswordController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '请输入默认操作员密码';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // Checkbox for using existing config
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: CheckboxListTile(
                              dense: true,
                              title: const Text(
                                '使用图床配置中的操作员和密码',
                                style: TextStyle(fontSize: 15),
                              ),
                              secondary: Icon(Icons.settings, color: Theme.of(context).primaryColor),
                              value: isUsePSConfig,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              activeColor: Theme.of(context).primaryColor,
                              checkColor: Colors.white,
                              onChanged: (value) async {
                                if (value == true) {
                                  var queryUpyun = await UpyunManageAPI().readCurrentConfig();
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
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Submit button
                ElevatedButton(
                  onPressed: () async {
                    if (bucketNameController.text.isEmpty ||
                        defaultOperatorController.text.isEmpty ||
                        defaultPasswordController.text.isEmpty) {
                      return showToast('请填写完整信息');
                    }
                    var bucketPutResponse = await UpyunManageAPI().putBucket(bucketNameController.text);

                    if (bucketPutResponse[0] == 'success') {
                      var addOperatorResult = await UpyunManageAPI().addOperator(
                        bucketNameController.text,
                        defaultOperatorController.text,
                      );
                      if (addOperatorResult[0] == 'success') {
                        showToast('创建成功');
                        var insertOperator = await UpyunManageAPI().saveUpyunOperatorConfig(
                          bucketNameController.text,
                          upyunManageConfigMap['email'],
                          defaultOperatorController.text,
                          defaultPasswordController.text,
                        );
                        if (!insertOperator) {
                          return showToast('数据保存错误');
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
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Theme.of(context).primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 2,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.cloud_upload_outlined, size: 22),
                      SizedBox(width: 8),
                      Text(
                        '创建存储桶',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
