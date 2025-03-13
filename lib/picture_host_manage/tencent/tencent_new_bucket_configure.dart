import 'package:flutter/material.dart';

import 'package:horopic/picture_host_manage/manage_api/tencent_manage_api.dart';
import 'package:horopic/utils/common_functions.dart';

class NewBucketConfig extends StatefulWidget {
  const NewBucketConfig({
    super.key,
  });

  @override
  NewBucketConfigState createState() => NewBucketConfigState();
}

class NewBucketConfigState extends State<NewBucketConfig> {
  Map newBucketConfig = {
    'bucketName': '',
    'region': 'ap-nanjing',
    'multiAZ': false,
    'xCosACL': 'private',
  };

  resetBucketConfig() {
    newBucketConfig = {
      'bucketName': '',
      'region': 'ap-nanjing',
      'multiAZ': false,
      'xCosACL': 'private',
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
              items: TencentManageAPI.areaCodeName.keys.map((e) {
                return DropdownMenuItem(
                  value: e,
                  child: Text('${TencentManageAPI.areaCodeName[e]}'),
                );
              }).toList(),
              onChanged: (value) {
                newBucketConfig['region'] = value;
                setState(() {});
              },
            ),
          ),
          ListTile(
            title: const Text('访问权限'),
            trailing: DropdownButton(
              alignment: Alignment.centerRight,
              underline: Container(),
              icon: const Icon(Icons.arrow_drop_down, size: 30),
              autofocus: true,
              value: newBucketConfig['xCosACL'],
              items: const [
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
              onChanged: (value) {
                newBucketConfig['xCosACL'] = value;
                setState(() {});
              },
            ),
          ),
          ListTile(
            title: const Text('开启多AZ特性'),
            subtitle: const Text('仅限北京，广州，上海，新加坡'),
            trailing: Switch(
              value: newBucketConfig['multiAZ'],
              onChanged: (value) {
                setState(() {
                  newBucketConfig['multiAZ'] = value;
                });
              },
            ),
          ),
          ListTile(
            subtitle: ElevatedButton(
              onPressed: () async {
                var result = await TencentManageAPI.createBucket(newBucketConfig);
                if (result[0] == 'success') {
                  resetBucketConfig();
                  if (mounted) {
                    showToastWithContext(context, "创建成功");
                    Navigator.pop(context);
                  }
                } else if (result[0] == 'multiAZ error') {
                  if (mounted) {
                    showToastWithContext(context, "区域不支持多AZ特性");
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
