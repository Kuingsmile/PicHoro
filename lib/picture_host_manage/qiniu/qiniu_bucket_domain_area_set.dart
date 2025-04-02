import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:horopic/picture_host_manage/manage_api/qiniu_manage_api.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/widgets/common_widgets.dart';

class QiniuBucketDomainAreaConfig extends StatefulWidget {
  final Map element;
  const QiniuBucketDomainAreaConfig({
    super.key,
    required this.element,
  });

  @override
  QiniuBucketDomainAreaConfigState createState() => QiniuBucketDomainAreaConfigState();
}

class QiniuBucketDomainAreaConfigState extends State<QiniuBucketDomainAreaConfig> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController domainController = TextEditingController();
  Map bucketConfig = {
    'region': 'z0',
  };

  resetBucketConfig() {
    bucketConfig = {
      'region': 'z0',
    };
  }

  @override
  initState() {
    super.initState();
    _initConfig();
  }

  _initConfig() async {
    resetBucketConfig();
    try {
      var config = await QiniuManageAPI().readQiniuManageConfig();
      if (config == 'Error') {
        return;
      } else {
        var jsonResult = jsonDecode(config);
        if (jsonResult['domain'] != 'None') {
          domainController.text = jsonResult['domain'];
        }
        if (jsonResult['region'] != 'None') {
          bucketConfig['region'] = jsonResult['area'];
        }
        setState(() {});
      }
    } catch (e) {
      flogErr(e, {}, "QiniuBucketDomainAreaConfigState", "_initConfig");
    }
  }

  @override
  void dispose() {
    domainController.dispose();
    super.dispose();
  }

  getExistedDomain() async {
    return await QiniuManageAPI().queryDomains(widget.element);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        leading: getLeadingIcon(context),
        title: titleText('${widget.element['name']}配置'),
        flexibleSpace: getFlexibleSpace(context),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Configuration Section Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '存储桶配置',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Domain Input
                      TextFormField(
                        controller: domainController,
                        decoration: InputDecoration(
                          labelText: '访问域名',
                          hintText: '请输入域名',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          prefixIcon: const Icon(Icons.language),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 16,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '域名不能为空';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      // Region Selection
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            const Icon(Icons.location_on, color: Colors.blue),
                            const SizedBox(width: 10),
                            const Text(
                              '所属地域',
                              style: TextStyle(fontSize: 16),
                            ),
                            Expanded(child: Container()),
                            DropdownButton(
                              underline: Container(),
                              icon: const Icon(Icons.arrow_drop_down, size: 30),
                              value: bucketConfig['region'],
                              items: QiniuManageAPI.areaCodeName.keys.map((e) {
                                return DropdownMenuItem(
                                  value: e,
                                  child: Text('${QiniuManageAPI.areaCodeName[e]}'),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  bucketConfig['region'] = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              try {
                                var result = await QiniuManageAPI().saveQiniuManageConfig(
                                    widget.element['name'], domainController.text, bucketConfig['region']);
                                if (!result) {
                                  showToast('保存数据失败');
                                  return;
                                } else {
                                  showToast('配置成功');
                                  if (mounted) {
                                    Navigator.pop(context);
                                  }
                                }
                              } catch (e) {
                                flogErr(e, {}, "QiniuBucketDomainAreaConfigState", "build");
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            '保存配置',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Available Domains Section Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.list, color: Colors.blue),
                          SizedBox(width: 8),
                          Text(
                            '可用域名列表',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      FutureBuilder(
                        future: getExistedDomain(),
                        builder: (BuildContext context, AsyncSnapshot snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(20.0),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          } else if (snapshot.hasData &&
                              snapshot.data[0] == 'success' &&
                              snapshot.data[1] != null &&
                              snapshot.data[1].length > 0) {
                            return ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: snapshot.data[1].length,
                              itemBuilder: (context, index) {
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.link, color: Colors.blue, size: 20),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: SelectableText(
                                          snapshot.data[1][index].toString(),
                                          style: const TextStyle(
                                            color: Colors.blue,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.content_copy, size: 20),
                                        onPressed: () {
                                          copyToClipboard(context, snapshot.data[1][index].toString());
                                        },
                                        tooltip: '复制',
                                        color: Colors.blue,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          } else {
                            return Container(
                              padding: const EdgeInsets.all(20),
                              alignment: Alignment.center,
                              child: Column(
                                children: [
                                  Icon(Icons.domain_disabled, size: 48, color: Colors.grey.shade400),
                                  const SizedBox(height: 16),
                                  Text(
                                    '未查询到可用域名',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void copyToClipboard(BuildContext context, String text) {
    // Implement clipboard functionality
    // This is a placeholder for the actual implementation
    showToast('已复制到剪贴板');
  }
}
