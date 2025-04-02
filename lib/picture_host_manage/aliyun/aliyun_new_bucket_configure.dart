import 'package:flutter/material.dart';

import 'package:horopic/picture_host_manage/manage_api/aliyun_manage_api.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/widgets/common_widgets.dart';

class AliyunNewBucketConfig extends StatefulWidget {
  const AliyunNewBucketConfig({
    super.key,
  });

  @override
  AliyunNewBucketConfigState createState() => AliyunNewBucketConfigState();
}

class AliyunNewBucketConfigState extends State<AliyunNewBucketConfig> {
  Map newBucketConfig = {
    'bucketName': '',
    'region': 'oss-cn-hangzhou',
    'multiAZ': false,
    'xCosACL': 'private',
  };

  resetBucketConfig() {
    newBucketConfig = {
      'bucketName': '',
      'region': 'oss-cn-hangzhou',
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
        leading: getLeadingIcon(context),
        title: titleText('新建存储桶'),
        flexibleSpace: getFlexibleSpace(context),
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
              items: AliyunManageAPI().areaCodeName.keys.map((e) {
                return DropdownMenuItem(
                  value: e,
                  child: Text('${AliyunManageAPI().areaCodeName[e]}'),
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
            subtitle: const Text('仅限特定区域'),
            trailing: Tooltip(
              message: '多可用区特性提供更高的数据可靠性',
              child: Switch(
                value: newBucketConfig['multiAZ'],
                activeColor: Theme.of(context).primaryColor,
                onChanged: (value) {
                  setState(() {
                    newBucketConfig['multiAZ'] = value;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ElevatedButton(
              onPressed: () async {
                // Show loading indicator
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                );

                var result = await AliyunManageAPI().createBucket(newBucketConfig);

                // Close loading indicator
                if (mounted) Navigator.pop(context);

                if (result[0] == 'success') {
                  resetBucketConfig();
                  if (mounted) {
                    showToastWithContext(context, "创建成功");
                    Navigator.pop(context);
                  }
                } else if (result[0] == 'multiAZ error') {
                  if (mounted) {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('创建失败'),
                        content: const Text('该区域不支持多AZ特性，请关闭多AZ选项或选择其他区域'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('确定'),
                          ),
                        ],
                      ),
                    );
                  }
                } else {
                  if (mounted) {
                    showToastWithContext(context, "创建失败: ${result[1]}");
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                '创建存储桶',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
