import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:horopic/picture_host_manage/manage_api/alist_manage_api.dart';
import 'package:horopic/picture_host_manage/alist/alist_new_bucket_template.dart';
import 'package:horopic/utils/common_functions.dart';

class AlistNewBucketConfig extends StatefulWidget {
  final String driver;
  final String update;
  final Map bucketMap;
  const AlistNewBucketConfig({
    Key? key,
    required this.driver,
    required this.update,
    required this.bucketMap,
  }) : super(key: key);

  @override
  AlistNewBucketConfigState createState() => AlistNewBucketConfigState();
}

class AlistNewBucketConfigState extends State<AlistNewBucketConfig> {
  Map<String, dynamic> commonConfig = {};
  Map<String, dynamic> additionalConfig = {};

  @override
  initState() {
    super.initState();
    if (widget.update == 'false') {
      resetBucketConfig();
    } else {
      initBucketConfig();
    }
  }

  initBucketConfig() async {
    commonConfig.clear();
    Map driverConfigTemplate = alistNewBucketTemplate[widget.driver];

    List configList = driverConfigTemplate['common'];
    for (int j = 0; j < configList.length; j++) {
      if (configList[j]['type'] == 'select') {
        commonConfig[configList[j]['name']] = configList[j]['options'].toString().split(',')[0];
      } else if (configList[j]['type'] == 'bool') {
        commonConfig[configList[j]['name']] = false;
      } else if (configList[j]['type'] == 'number') {
        commonConfig[configList[j]['name']] = configList[j]['default'] == "" ? "" : int.parse(configList[j]['default']);
      } else {
        commonConfig[configList[j]['name']] = configList[j]['default'];
      }
    }
    List bucketMapkeys = widget.bucketMap.keys.toList();
    bucketMapkeys.remove('addition');
    for (int i = 0; i < bucketMapkeys.length; i++) {
      if (commonConfig.containsKey(bucketMapkeys[i])) {
        commonConfig[bucketMapkeys[i]] = widget.bucketMap[bucketMapkeys[i]];
      }
    }

    additionalConfig.clear();
    if (driverConfigTemplate['additional'] != null) {
      List configList = driverConfigTemplate['additional'];
      for (int j = 0; j < configList.length; j++) {
        if (configList[j]['type'] == 'select') {
          additionalConfig[configList[j]['name']] = configList[j]['options'].toString().split(',')[0];
        } else if (configList[j]['type'] == 'bool') {
          additionalConfig[configList[j]['name']] = false;
        } else if (configList[j]['type'] == 'number') {
          additionalConfig[configList[j]['name']] =
              configList[j]['default'] == "" ? "" : int.parse(configList[j]['default']);
        } else {
          additionalConfig[configList[j]['name']] = configList[j]['default'];
        }
      }
    }
    Map additionMap = jsonDecode(widget.bucketMap['addition']);
    List additionMapkeys = additionMap.keys.toList();
    for (int i = 0; i < additionMapkeys.length; i++) {
      if (additionalConfig.containsKey(additionMapkeys[i])) {
        additionalConfig[additionMapkeys[i]] = additionMap[additionMapkeys[i]];
      }
    }
    return true;
  }

  resetBucketConfig() async {
    commonConfig.clear();
    Map driverConfigTemplate = alistNewBucketTemplate[widget.driver];

    List configList = driverConfigTemplate['common'];
    for (int j = 0; j < configList.length; j++) {
      if (configList[j]['type'] == 'select') {
        commonConfig[configList[j]['name']] = configList[j]['options'].toString().split(',')[0];
      } else if (configList[j]['type'] == 'bool') {
        commonConfig[configList[j]['name']] = false;
      } else if (configList[j]['type'] == 'number') {
        commonConfig[configList[j]['name']] = configList[j]['default'] == "" ? "" : int.parse(configList[j]['default']);
      } else {
        commonConfig[configList[j]['name']] = configList[j]['default'];
      }
    }
    additionalConfig.clear();
    if (driverConfigTemplate['additional'] != null) {
      List configList = driverConfigTemplate['additional'];
      for (int j = 0; j < configList.length; j++) {
        if (configList[j]['type'] == 'select') {
          additionalConfig[configList[j]['name']] = configList[j]['options'].toString().split(',')[0];
        } else if (configList[j]['type'] == 'bool') {
          additionalConfig[configList[j]['name']] = false;
        } else if (configList[j]['type'] == 'number') {
          additionalConfig[configList[j]['name']] =
              configList[j]['default'] == "" ? "" : int.parse(configList[j]['default']);
        } else {
          additionalConfig[configList[j]['name']] = configList[j]['default'];
        }
      }
    }
    return true;
  }

  List<Widget> generateListTile() {
    List<Widget> list = [];
    list.clear();
    Map driverConfigTemplate = alistNewBucketTemplate[widget.driver];
    List configList = [];
    configList.clear();
    configList.addAll(driverConfigTemplate['common']);
    configList.addAll(driverConfigTemplate['additional']);
    configList.sort((a, b) {
      if (((a['type'] == 'string' || a['type'] == 'number' || a['type'] == 'text') &&
              (b['type'] == 'select' || b['type'] == 'bool')) ||
          (a['type'] == 'select' && b['type'] == 'bool')) {
        return -1;
      } else if (((a['type'] == 'select' || a['type'] == 'bool') &&
              (b['type'] == 'string' || b['type'] == 'number' || b['type'] == 'text')) ||
          (a['type'] == 'bool' && b['type'] == 'select')) {
        return 1;
      } else {
        return 0;
      }
    });
    for (int i = 0; i < configList.length; i++) {
      if (configList[i]['type'] == 'select') {
        Map optionsMap = {};
        List optionsList = configList[i]['options'].toString().split(',');
        List optionsTranslatedList = configList[i]['options_translate'].toString().split(',');
        for (int j = 0; j < optionsList.length; j++) {
          optionsMap[optionsList[j]] = optionsTranslatedList[j];
        }
        list.add(ListTile(
          title: Text(configList[i]['required'] == true
              ? configList[i]['translate'] + '*'
              : '可选:${configList[i]['translate']}'),
          subtitle: Text(configList[i]['help']),
          trailing: DropdownButton(
            value: commonConfig.keys.toList().contains(configList[i]['name'])
                ? commonConfig[configList[i]['name']]
                : additionalConfig[configList[i]['name']],
            items: optionsMap.keys
                .map((e) => DropdownMenuItem(
                      value: e,
                      child: Text(optionsMap[e]),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                if (commonConfig.keys.toList().contains(configList[i]['name'])) {
                  commonConfig[configList[i]['name']] = value;
                  setState(() {});
                } else {
                  additionalConfig[configList[i]['name']] = value;
                  setState(() {});
                }
              });
            },
          ),
        ));
      }
      if (configList[i]['type'] == 'bool') {
        list.add(ListTile(
          title: Text(configList[i]['required'] == true
              ? configList[i]['translate'] + '*'
              : '可选:${configList[i]['translate']}'),
          subtitle: Text(configList[i]['help']),
          trailing: Switch(
            value: commonConfig.keys.toList().contains(configList[i]['name'])
                ? commonConfig[configList[i]['name']]
                : additionalConfig[configList[i]['name']],
            onChanged: (value) {
              setState(() {
                if (commonConfig.keys.toList().contains(configList[i]['name'])) {
                  commonConfig[configList[i]['name']] = value;
                } else {
                  additionalConfig[configList[i]['name']] = value;
                }
              });
            },
          ),
        ));
      }
      if (configList[i]['type'] == 'string' || configList[i]['type'] == 'number' || configList[i]['type'] == 'text') {
        list.add(
          ListTile(
            title: Center(
                child: Text(configList[i]['required'] == true
                    ? configList[i]['translate'] + '*'
                    : '可选:${configList[i]['translate']}')),
            subtitle: TextFormField(
              textAlign: TextAlign.center,
              initialValue: commonConfig.keys.toList().contains(configList[i]['name'])
                  ? commonConfig[configList[i]['name']].toString()
                  : additionalConfig[configList[i]['name']].toString(),
              onChanged: (value) {
                setState(() {
                  if (commonConfig.keys.toList().contains(configList[i]['name'])) {
                    //type为number时，需要转换为int
                    if (configList[i]['type'] == 'number') {
                      commonConfig[configList[i]['name']] = int.parse(value.toString());
                    } else {
                      commonConfig[configList[i]['name']] = value;
                    }
                  } else {
                    if (configList[i]['type'] == 'number') {
                      additionalConfig[configList[i]['name']] = int.parse(value.toString());
                    } else {
                      additionalConfig[configList[i]['name']] = value;
                    }
                  }
                });
                setState(() {});
              },
            ),
          ),
        );
      }
    }
    //submit
    list.add(ListTile(
        title: ElevatedButton(
      onPressed: () async {
        Map submitData = {};
        Map driverConfigTemplate = alistNewBucketTemplate[widget.driver];
        List commonConfigList = driverConfigTemplate['common'];
        List additionalConfigList = driverConfigTemplate['additional'];
        for (int i = 0; i < commonConfigList.length; i++) {
          if (commonConfigList[i]['required'] == true && commonConfig[commonConfigList[i]['name']] == '') {
            showToast('请填写${commonConfigList[i]['translate']}');
            return;
          }
        }
        for (int i = 0; i < additionalConfigList.length; i++) {
          if (additionalConfigList[i]['required'] == true && additionalConfig[additionalConfigList[i]['name']] == '') {
            showToast('请填写${additionalConfigList[i]['translate']}');
            return;
          }
        }
        commonConfig.forEach((key, value) {
          if (value != "") {
            //type为number的转换

            submitData[key] = value;
          }
        });
        submitData['driver'] = widget.driver;
        Map additionalConfigTemp = {};
        additionalConfig.forEach((key, value) {
          if (value != '') {
            additionalConfigTemp[key] = value;
          }
        });
        dynamic res;
        submitData["addition"] = jsonEncode(additionalConfigTemp);
        if (widget.update == 'true') {
          submitData['id'] = widget.bucketMap['id'];
          res = await AlistManageAPI.updateBucket(submitData);
        } else {
          res = await AlistManageAPI.createBucket(submitData);
        }

        if (res[0] == 'success') {
          if (widget.update == 'true') {
            showToast('修改成功');
          } else {
            showToast('创建成功');
          }
        } else {
          showToast('创建失败');
        }
      },
      child: titleText('提交', fontsize: null),
    )));
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: titleText(AlistManageAPI.driverTranslate[widget.driver]),
      ),
      body: ListView(
        children: generateListTile(),
      ),
    );
  }
}
