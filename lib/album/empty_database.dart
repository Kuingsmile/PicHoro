import 'package:horopic/album/albumSQL.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:horopic/utils/global.dart';
import 'package:fluttertoast/fluttertoast.dart';

class EmptyDatabase extends StatefulWidget {
  @override
  _EmptyDatabaseState createState() => _EmptyDatabaseState();
}

class _EmptyDatabaseState extends State<EmptyDatabase> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('选择需要清空的数据库'),
      ),
      body: ListView(
        children: [
          ListTile(
              title: const Text('兰空'),
              onTap: () async {
                showCupertinoDialog(
                    barrierDismissible: true,
                    context: context,
                    builder: (BuildContext context) {
                      return CupertinoAlertDialog(
                          title: const Text('通知'),
                          content: const Text('是否确定清空兰空数据库?'),
                          actions: <Widget>[
                            CupertinoDialogAction(
                              child: const Text('取消',
                                  style: TextStyle(color: Colors.blue)),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                            CupertinoDialogAction(
                                child: const Text('确定',
                                    style: TextStyle(color: Colors.blue)),
                                onPressed: () async {
                                  await AlbumSQL.deleteTable(
                                      Global.imageDB!, 'lskypro');
                                  Fluttertoast.showToast(
                                      msg: "已清空兰空数据库",
                                      toastLength: Toast.LENGTH_SHORT,
                                      timeInSecForIosWeb: 2,
                                      backgroundColor:
                                          Theme.of(this.context).brightness ==
                                                  Brightness.light
                                              ? Colors.black
                                              : Colors.white,
                                      textColor:
                                          Theme.of(this.context).brightness ==
                                                  Brightness.light
                                              ? Colors.white
                                              : Colors.black,
                                      fontSize: 16.0);
                                })
                          ]);
                    });
              }),
          ListTile(
              title: const Text('SM.MS'),
              onTap: () async {
                showCupertinoDialog(
                    barrierDismissible: true,
                    context: context,
                    builder: (BuildContext context) {
                      return CupertinoAlertDialog(
                          title: const Text('通知'),
                          content: const Text('是否确定清空SM.MS数据库?'),
                          actions: <Widget>[
                            CupertinoDialogAction(
                              child: const Text('取消',
                                  style: TextStyle(color: Colors.blue)),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                            CupertinoDialogAction(
                              child: const Text('确定',
                                  style: TextStyle(color: Colors.blue)),
                              onPressed: () async {
                                await AlbumSQL.deleteTable(
                                    Global.imageDB!, 'smms');
                                Fluttertoast.showToast(
                                    msg: "已清空SM.MS数据库",
                                    toastLength: Toast.LENGTH_SHORT,
                                    timeInSecForIosWeb: 2,
                                    backgroundColor:
                                        Theme.of(this.context).brightness ==
                                                Brightness.light
                                            ? Colors.black
                                            : Colors.white,
                                    textColor:
                                        Theme.of(this.context).brightness ==
                                                Brightness.light
                                            ? Colors.white
                                            : Colors.black,
                                    fontSize: 16.0);
                              },
                            )
                          ]);
                    });
              }),
          ListTile(
              title: const Text('github'),
              onTap: () async {
                showCupertinoDialog(
                    barrierDismissible: true,
                    context: context,
                    builder: (BuildContext context) {
                      return CupertinoAlertDialog(
                          title: const Text('通知'),
                          content: const Text('是否确定清空Github数据库?'),
                          actions: <Widget>[
                            CupertinoDialogAction(
                              child: const Text('取消',
                                  style: TextStyle(color: Colors.blue)),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                            CupertinoDialogAction(
                              child: const Text('确定',
                                  style: TextStyle(color: Colors.blue)),
                              onPressed: () async {
                                await AlbumSQL.deleteTable(
                                    Global.imageDB!, 'github');
                                Fluttertoast.showToast(
                                    msg: "已清空github数据库",
                                    toastLength: Toast.LENGTH_SHORT,
                                    timeInSecForIosWeb: 2,
                                    backgroundColor:
                                        Theme.of(this.context).brightness ==
                                                Brightness.light
                                            ? Colors.black
                                            : Colors.white,
                                    textColor:
                                        Theme.of(this.context).brightness ==
                                                Brightness.light
                                            ? Colors.white
                                            : Colors.black,
                                    fontSize: 16.0);
                              },
                            )
                          ]);
                    });
              }),
          ListTile(
              title: const Text('Imgur'),
              onTap: () async {
                showCupertinoDialog(
                    barrierDismissible: true,
                    context: context,
                    builder: (BuildContext context) {
                      return CupertinoAlertDialog(
                          title: const Text('通知'),
                          content: const Text('是否确定清空Imgur数据库?'),
                          actions: <Widget>[
                            CupertinoDialogAction(
                              child: const Text('取消',
                                  style: TextStyle(color: Colors.blue)),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                            CupertinoDialogAction(
                              child: const Text('确定',
                                  style: TextStyle(color: Colors.blue)),
                              onPressed: () async {
                                await AlbumSQL.deleteTable(
                                    Global.imageDB!, 'imgur');
                                Fluttertoast.showToast(
                                    msg: "已清空Imgur数据库",
                                    toastLength: Toast.LENGTH_SHORT,
                                    timeInSecForIosWeb: 2,
                                    backgroundColor:
                                        Theme.of(this.context).brightness ==
                                                Brightness.light
                                            ? Colors.black
                                            : Colors.white,
                                    textColor:
                                        Theme.of(this.context).brightness ==
                                                Brightness.light
                                            ? Colors.white
                                            : Colors.black,
                                    fontSize: 16.0);
                              },
                            )
                          ]);
                    });
              }),
          ListTile(
              title: const Text('七牛云'),
              onTap: () async {
                showCupertinoDialog(
                    barrierDismissible: true,
                    context: context,
                    builder: (BuildContext context) {
                      return CupertinoAlertDialog(
                          title: const Text('通知'),
                          content: const Text('是否确定清空七牛云数据库?'),
                          actions: <Widget>[
                            CupertinoDialogAction(
                              child: const Text('取消',
                                  style: TextStyle(color: Colors.blue)),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                            CupertinoDialogAction(
                              child: const Text('确定',
                                  style: TextStyle(color: Colors.blue)),
                              onPressed: () async {
                                await AlbumSQL.deleteTable(
                                    Global.imageDB!, 'qiniu');
                                Fluttertoast.showToast(
                                    msg: "已清空七牛云数据库",
                                    toastLength: Toast.LENGTH_SHORT,
                                    timeInSecForIosWeb: 2,
                                    backgroundColor:
                                        Theme.of(this.context).brightness ==
                                                Brightness.light
                                            ? Colors.black
                                            : Colors.white,
                                    textColor:
                                        Theme.of(this.context).brightness ==
                                                Brightness.light
                                            ? Colors.white
                                            : Colors.black,
                                    fontSize: 16.0);
                              },
                            )
                          ]);
                    });
              }),
          ListTile(
              title: const Text('腾讯云'),
              onTap: () async {
                showCupertinoDialog(
                    barrierDismissible: true,
                    context: context,
                    builder: (BuildContext context) {
                      return CupertinoAlertDialog(
                          title: const Text('通知'),
                          content: const Text('是否确定清空腾讯云数据库?'),
                          actions: <Widget>[
                            CupertinoDialogAction(
                              child: const Text('取消',
                                  style: TextStyle(color: Colors.blue)),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                            CupertinoDialogAction(
                              child: const Text('确定',
                                  style: TextStyle(color: Colors.blue)),
                              onPressed: () async {
                                await AlbumSQL.deleteTable(
                                    Global.imageDB!, 'tencent');
                                Fluttertoast.showToast(
                                    msg: "已清空腾讯云数据库",
                                    toastLength: Toast.LENGTH_SHORT,
                                    timeInSecForIosWeb: 2,
                                    backgroundColor:
                                        Theme.of(this.context).brightness ==
                                                Brightness.light
                                            ? Colors.black
                                            : Colors.white,
                                    textColor:
                                        Theme.of(this.context).brightness ==
                                                Brightness.light
                                            ? Colors.white
                                            : Colors.black,
                                    fontSize: 16.0);
                              },
                            )
                          ]);
                    });
              }),
          ListTile(
              title: const Text('阿里云'),
              onTap: () async {
                showCupertinoDialog(
                    barrierDismissible: true,
                    context: context,
                    builder: (BuildContext context) {
                      return CupertinoAlertDialog(
                          title: const Text('通知'),
                          content: const Text('是否确定清空阿里云数据库?'),
                          actions: <Widget>[
                            CupertinoDialogAction(
                              child: const Text('取消',
                                  style: TextStyle(color: Colors.blue)),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                            CupertinoDialogAction(
                              child: const Text('确定',
                                  style: TextStyle(color: Colors.blue)),
                              onPressed: () async {
                                await AlbumSQL.deleteTable(
                                    Global.imageDB!, 'aliyun');
                                Fluttertoast.showToast(
                                    msg: "已清空阿里云数据库",
                                    toastLength: Toast.LENGTH_SHORT,
                                    timeInSecForIosWeb: 2,
                                    backgroundColor:
                                        Theme.of(this.context).brightness ==
                                                Brightness.light
                                            ? Colors.black
                                            : Colors.white,
                                    textColor:
                                        Theme.of(this.context).brightness ==
                                                Brightness.light
                                            ? Colors.white
                                            : Colors.black,
                                    fontSize: 16.0);
                              },
                            )
                          ]);
                    });
              }),
          ListTile(
              title: const Text('又拍云'),
              onTap: () async {
                showCupertinoDialog(
                    barrierDismissible: true,
                    context: context,
                    builder: (BuildContext context) {
                      return CupertinoAlertDialog(
                          title: const Text('通知'),
                          content: const Text('是否确定清空又拍云数据库?'),
                          actions: <Widget>[
                            CupertinoDialogAction(
                              child: const Text('取消',
                                  style: TextStyle(color: Colors.blue)),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                            CupertinoDialogAction(
                              child: const Text('确定',
                                  style: TextStyle(color: Colors.blue)),
                              onPressed: () async {
                                await AlbumSQL.deleteTable(
                                    Global.imageDB!, 'upyun');
                                Fluttertoast.showToast(
                                    msg: "已清空又拍云数据库",
                                    toastLength: Toast.LENGTH_SHORT,
                                    timeInSecForIosWeb: 2,
                                    backgroundColor:
                                        Theme.of(this.context).brightness ==
                                                Brightness.light
                                            ? Colors.black
                                            : Colors.white,
                                    textColor:
                                        Theme.of(this.context).brightness ==
                                                Brightness.light
                                            ? Colors.white
                                            : Colors.black,
                                    fontSize: 16.0);
                              },
                            )
                          ]);
                    });
              }),
          ListTile(
              title: const Text('所有数据库'),
              onTap: () async {
                showCupertinoDialog(
                    barrierDismissible: true,
                    context: context,
                    builder: (BuildContext context) {
                      return CupertinoAlertDialog(
                          title: const Text('通知'),
                          content: const Text('是否确定清空全部数据库?'),
                          actions: <Widget>[
                            CupertinoDialogAction(
                              child: const Text('取消',
                                  style: TextStyle(color: Colors.blue)),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                            CupertinoDialogAction(
                              child: const Text('确定',
                                  style: TextStyle(color: Colors.blue)),
                              onPressed: () async {
                                await AlbumSQL.emptyAllTable(
                                  Global.imageDB!,
                                );
                                Fluttertoast.showToast(
                                    msg: "已清空所有数据库",
                                    toastLength: Toast.LENGTH_SHORT,
                                    timeInSecForIosWeb: 2,
                                    backgroundColor:
                                        Theme.of(this.context).brightness ==
                                                Brightness.light
                                            ? Colors.black
                                            : Colors.white,
                                    textColor:
                                        Theme.of(this.context).brightness ==
                                                Brightness.light
                                            ? Colors.white
                                            : Colors.black,
                                    fontSize: 16.0);
                              },
                            )
                          ]);
                    });
              }),
        ],
      ),
    );
  }
}
