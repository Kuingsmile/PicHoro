import 'package:flutter/material.dart';
import 'package:horopic/PShostFileManage/manageAPI/tencentManage.dart';
import 'package:fluttertoast/fluttertoast.dart';

class NewBucketConfig extends StatefulWidget {
  NewBucketConfig({
    Key? key,
  }) : super(key: key);

  @override
  _NewBucketConfigState createState() => _NewBucketConfigState();
}

class _NewBucketConfigState extends State<NewBucketConfig> {
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
        title: const Text('新建存储桶'),
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
                var result =
                    await TencentManageAPI.createBucket(newBucketConfig);
                if (result[0] == 'success') {
                  resetBucketConfig();
                  Fluttertoast.showToast(
                      msg: "创建成功",
                      toastLength: Toast.LENGTH_SHORT,
                      timeInSecForIosWeb: 2,
                      backgroundColor:
                          Theme.of(context).brightness == Brightness.light
                              ? Colors.black
                              : Colors.white,
                      textColor:
                          Theme.of(context).brightness == Brightness.light
                              ? Colors.white
                              : Colors.black,
                      fontSize: 16.0);
                  Navigator.pop(context);
                } else if (result[0] == 'multiAZ error') {
                  Fluttertoast.showToast(
                      msg: '区域不支持多AZ特性',
                      toastLength: Toast.LENGTH_SHORT,
                      timeInSecForIosWeb: 2,
                      backgroundColor:
                          Theme.of(context).brightness == Brightness.light
                              ? Colors.black
                              : Colors.white,
                      textColor:
                          Theme.of(context).brightness == Brightness.light
                              ? Colors.white
                              : Colors.black,
                      fontSize: 16.0);
                } else {
                  Fluttertoast.showToast(
                      msg: '创建失败',
                      toastLength: Toast.LENGTH_SHORT,
                      timeInSecForIosWeb: 2,
                      backgroundColor:
                          Theme.of(context).brightness == Brightness.light
                              ? Colors.black
                              : Colors.white,
                      textColor:
                          Theme.of(context).brightness == Brightness.light
                              ? Colors.white
                              : Colors.black,
                      fontSize: 16.0);
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
