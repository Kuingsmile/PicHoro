import 'package:flutter/material.dart';

import 'package:horopic/picture_host_manage/manage_api/aws_manage_api.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/widgets/common_widgets.dart';

class AwsNewBucketConfig extends StatefulWidget {
  const AwsNewBucketConfig({
    super.key,
  });

  @override
  AwsNewBucketConfigState createState() => AwsNewBucketConfigState();
}

class AwsNewBucketConfigState extends State<AwsNewBucketConfig> {
  Map newBucketConfig = {
    'bucketName': '',
    'region': '',
  };

  resetBucketConfig() {
    newBucketConfig = {
      'bucketName': '',
      'region': '',
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
        flexibleSpace: getFlexibleSpace(context),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Center(
                child: Text(
              '存储桶名称',
              textAlign: TextAlign.center,
            )),
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
            title: const Center(
                child: Text(
              '可选：存储桶地域',
              textAlign: TextAlign.center,
            )),
            subtitle: TextFormField(
              textAlign: TextAlign.center,
              initialValue: newBucketConfig['region'],
              onChanged: (value) {
                newBucketConfig['region'] = value;
                setState(() {});
              },
            ),
          ),
          ListTile(
            subtitle: ElevatedButton(
              onPressed: () async {
                Map config = {
                  'bucketName': newBucketConfig['bucketName'],
                  'region': newBucketConfig['region'].isEmpty || newBucketConfig['region'].trim().isEmpty
                      ? 'None'
                      : newBucketConfig['region'],
                };
                var result = await AwsManageAPI.createBucket(config);
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
