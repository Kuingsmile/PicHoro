import 'package:flutter/material.dart';

import 'package:horopic/picture_host_manage/manage_api/qiniu_manage_api.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/widgets/common_widgets.dart';

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

  final _formKey = GlobalKey<FormState>();
  bool _isProcessing = false;

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
        leading: getLeadingIcon(context),
        title: titleText('新建存储桶'),
        flexibleSpace: getFlexibleSpace(context),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            Card(
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '存储桶信息',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      initialValue: newBucketConfig['bucketName'],
                      decoration: InputDecoration(
                        labelText: '存储桶名称',
                        prefixIcon: const Icon(Icons.storage),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        hintText: '请输入存储桶名称',
                      ),
                      onChanged: (value) {
                        newBucketConfig['bucketName'] = value;
                        setState(() {});
                      },
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField(
                      decoration: InputDecoration(
                        labelText: '所属地域',
                        prefixIcon: const Icon(Icons.public),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      value: newBucketConfig['region'],
                      items: QiniuManageAPI.areaCodeName.keys.map((e) {
                        return DropdownMenuItem(
                          value: e,
                          child: Text('${QiniuManageAPI.areaCodeName[e]}'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          newBucketConfig['region'] = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: ElevatedButton(
                onPressed: _isProcessing
                    ? null
                    : () async {
                        RegExp validBucketName = RegExp(r'^[a-z0-9][a-z0-9-]{1,61}[a-z0-9]$');
                        if (newBucketConfig['bucketName'] == '') {
                          showToastWithContext(context, '存储桶名称不能为空');
                          return;
                        }
                        if (!validBucketName.hasMatch(newBucketConfig['bucketName'])) {
                          showToastWithContext(context, '存储桶名称不符合规范');
                          return;
                        }

                        setState(() {
                          _isProcessing = true;
                        });

                        try {
                          var result = await QiniuManageAPI().createBucket(newBucketConfig);

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
                        } finally {
                          if (mounted) {
                            setState(() {
                              _isProcessing = false;
                            });
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isProcessing
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        '创建',
                        style: TextStyle(fontSize: 18),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
