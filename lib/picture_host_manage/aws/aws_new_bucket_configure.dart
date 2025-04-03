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
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _bucketNameController = TextEditingController();
  final TextEditingController _regionController = TextEditingController();
  bool _isLoading = false;

  Map newBucketConfig = {
    'bucketName': '',
    'region': '',
  };

  resetBucketConfig() {
    newBucketConfig = {
      'bucketName': '',
      'region': '',
    };
    _bucketNameController.clear();
    _regionController.clear();
  }

  @override
  initState() {
    super.initState();
    resetBucketConfig();
  }

  @override
  void dispose() {
    _bucketNameController.dispose();
    _regionController.dispose();
    super.dispose();
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  elevation: 2.0,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text(
                          '创建新的 AWS S3 存储桶',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _bucketNameController,
                          decoration: const InputDecoration(
                            labelText: '存储桶名称',
                            hintText: '请输入存储桶名称',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.storage),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '请输入存储桶名称';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            newBucketConfig['bucketName'] = value;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _regionController,
                          decoration: const InputDecoration(
                            labelText: '存储桶地域 (可选)',
                            hintText: '例如: us-east-1',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.location_on),
                            helperText: '留空将使用默认地域',
                          ),
                          onChanged: (value) {
                            newBucketConfig['region'] = value;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              _isLoading = true;
                            });

                            Map config = {
                              'bucketName': newBucketConfig['bucketName'],
                              'region': newBucketConfig['region'].isEmpty || newBucketConfig['region'].trim().isEmpty
                                  ? 'None'
                                  : newBucketConfig['region'],
                            };

                            try {
                              var result = await AwsManageAPI().createBucket(config);
                              if (result[0] == 'success') {
                                resetBucketConfig();
                                if (mounted) {
                                  showToastWithContext(context, "创建成功");
                                  Navigator.pop(context);
                                }
                              } else {
                                if (mounted) {
                                  showToastWithContext(context, "创建失败：${result[1]}");
                                }
                              }
                            } finally {
                              if (mounted) {
                                setState(() {
                                  _isLoading = false;
                                });
                              }
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          '创建存储桶',
                          style: TextStyle(fontSize: 16),
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
