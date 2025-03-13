import 'package:flutter/material.dart';

import 'package:horopic/picture_host_manage/manage_api/qiniu_manage_api.dart';
import 'package:horopic/utils/common_functions.dart';

class QiniuNewBucketConfig extends StatefulWidget {
  const QiniuNewBucketConfig({
    super.key,
  });

  @override
  QiniuNewBucketConfigState createState() => QiniuNewBucketConfigState();
}

class QiniuNewBucketConfigState extends State<QiniuNewBucketConfig> {
  Map newBucketConfig = {
    'bucketName': '',
    'region': 'z0',
  };

  resetBucketConfig() {
    newBucketConfig = {
      'bucketName': '',
      'region': 'z0',
    };
  }

  @override
  initState() {
    super.initState();
    resetBucketConfig();
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
          ListTile(
            title: const Text('存储桶名称'),
            subtitle: TextFormField(
              textAlign: TextAlign.center,
              initialValue: newBucketConfig['bucketName'],
              onChanged: (value) {
                newBucketConfig['bucketName'] = value;
                setState(() {});
              },
            ),
          ),
          ListTile(
            title: const Text('所属地域'),
            trailing: DropdownButton(
              alignment: Alignment.centerRight,
              underline: Container(),
              icon: const Icon(Icons.arrow_drop_down, size: 30),
              autofocus: true,
              value: newBucketConfig['region'],
              items: QiniuManageAPI.areaCodeName.keys.map((e) {
                return DropdownMenuItem(
                  value: e,
                  child: Text('${QiniuManageAPI.areaCodeName[e]}'),
                );
              }).toList(),
              onChanged: (value) {
                newBucketConfig['region'] = value;
                setState(() {});
              },
            ),
          ),
          ListTile(
            subtitle: ElevatedButton(
              onPressed: () async {
                RegExp validBucketName = RegExp(r'^[a-z0-9][a-z0-9-]{1,61}[a-z0-9]$');
                if (newBucketConfig['bucketName'] == '') {
                  showToastWithContext(context, '存储桶名称不能为空');
                  return;
                }
                if (!validBucketName.hasMatch(newBucketConfig['bucketName'])) {
                  showToastWithContext(context, '存储桶名称不符合规范');
                  return;
                }
                var result = await QiniuManageAPI.createBucket(newBucketConfig);
                if (result[0] == 'success') {
                  resetBucketConfig();
                  if (mounted) {
                    showToastWithContext(context, "创建成功");
                    Navigator.pop(context);
                  }
                } else {
                  if (mounted) {
                    showToastWithContext(context, "创建失败");
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
