import 'package:flutter/material.dart';
import 'package:f_logs/f_logs.dart';

import 'package:horopic/picture_host_manage/manage_api/qiniu_manage_api.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/utils/global.dart';
import 'package:horopic/utils/sql_utils.dart';

class QiniuBucketDomainAreaConfig extends StatefulWidget {
  final Map element;
  const QiniuBucketDomainAreaConfig({
    Key? key,
    required this.element,
  }) : super(key: key);

  @override
  QiniuBucketDomainAreaConfigState createState() =>
      QiniuBucketDomainAreaConfigState();
}

class QiniuBucketDomainAreaConfigState
    extends State<QiniuBucketDomainAreaConfig> {
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
      String user = await Global.getUser();
      String userBucket = '${user}_${widget.element['name']}';
      var config = await MySqlUtils.queryQiniuManage(username: userBucket);
      if (config == 'Empty' || config == 'Error') {
        return;
      } else {
        if (config['domain'] != 'None') {
          domainController.text = config['domain'];
        }
        if (config['region'] != 'None') {
          bucketConfig['region'] = config['area'];
        }
        setState(() {});
      }
    } catch (e) {
      FLog.error(
          className: 'QiniuBucketDomainAreaConfigState',
          methodName: '_initConfig',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
    }
  }

  @override
  void dispose() {
    domainController.dispose();
    super.dispose();
  }

  getExistedDomain() async {
    var result = await QiniuManageAPI.queryDomains(widget.element);
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text('${widget.element['name']}配置'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          children: [
            TextFormField(
              controller: domainController,
              decoration: const InputDecoration(
                label: Center(child: Text('设定访问域名')),
                hintText: '请输入域名',
              ),
              textAlign: TextAlign.center,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '域名不能为空';
                }
                return null;
              },
            ),
            ListTile(
              title: const Text('所属地域'),
              trailing: DropdownButton(
                alignment: Alignment.centerRight,
                underline: Container(),
                icon: const Icon(Icons.arrow_drop_down, size: 30),
                autofocus: true,
                value: bucketConfig['region'],
                items: QiniuManageAPI.areaCodeName.keys.map((e) {
                  return DropdownMenuItem(
                    value: e,
                    child: Text('${QiniuManageAPI.areaCodeName[e]}'),
                  );
                }).toList(),
                onChanged: (value) {
                  bucketConfig['region'] = value;
                  setState(() {});
                },
              ),
            ),
            ListTile(
              subtitle: ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    try {
                      List content = [];
                      String user = await Global.getUser();
                      String userBucket = '${user}_${widget.element['name']}';
                      var config = await MySqlUtils.queryQiniuManage(
                          username: userBucket);
                      if (config == 'Error') {
                        showToast('连接数据库失败');
                        return;
                      } else if (config == 'Empty') {
                        content = [
                          widget.element['name'],
                          domainController.text,
                          bucketConfig['region'],
                          userBucket
                        ];
                        var result = await MySqlUtils.insertQiniuManage(
                            content: content);
                        if (result == 'Error') {
                          showToast('连接数据库失败');
                          return;
                        } else if (result == 'Success') {
                          showToast('配置成功');
                          if (mounted) {
                            Navigator.pop(context);
                          }
                        }
                      } else {
                        content = [
                          widget.element['name'],
                          domainController.text,
                          bucketConfig['region'],
                          userBucket
                        ];
                        var result = await MySqlUtils.updateQiniuManage(
                            content: content);
                        if (result == 'Error') {
                          showToast('连接数据库失败');
                          return;
                        } else if (result == 'Success') {
                          showToast('配置成功');
                          if (mounted) {
                            Navigator.pop(context);
                          }
                        }
                      }
                    } catch (e) {
                      FLog.error(
                          className: 'QiniuBucketDomainAreaConfigState',
                          methodName: 'build',
                          text: formatErrorMessage({}, e.toString()),
                          dataLogType: DataLogType.ERRORS.toString());
                    }
                  }
                },
                child: const Text('提交'),
              ),
            ),
            FutureBuilder(
              future: getExistedDomain(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data[0] == 'success') {
                    if (snapshot.data[1] == null ||
                        snapshot.data[1].length == 0) {
                      return const Center(
                          child: ListTile(
                        title: Text('未查询到可用域名'),
                      ));
                    } else {
                      return ListTile(
                        title: const Center(child: Text('可用域名列表')),
                        subtitle: Table(
                          children: snapshot.data[1].map<TableRow>((e) {
                            return TableRow(
                              children: [
                                Center(
                                    child: SelectableText(
                                  e.toString(),
                                  style: const TextStyle(
                                      color: Colors.blue,
                                      decoration: TextDecoration.underline),
                                )),
                              ],
                            );
                          }).toList(),
                        ),
                      );
                    }
                  } else {
                    return const Center(
                        child: ListTile(
                      title: Text('未查询到可用域名'),
                    ));
                  }
                } else {
                  return const Center(
                      child: ListTile(
                    title: Text('未查询到可用域名'),
                  ));
                }
              },
            )
          ],
        ),
      ),
    );
  }
}
