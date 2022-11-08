import 'dart:io';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluro/fluro.dart';
import 'package:f_logs/f_logs.dart';
import 'package:external_path/external_path.dart';

import 'package:horopic/picture_host_manage/smms/download_api/smms_downloader.dart';
import 'package:horopic/picture_host_manage/smms/download_api/smms_download_task.dart';
import 'package:horopic/picture_host_manage/tencent/download_api/download_status.dart';
import 'package:horopic/picture_host_manage/smms/upload_api/smms_upload_utils.dart';
import 'package:horopic/pages/upload_pages/upload_status.dart';
import 'package:horopic/picture_host_manage/smms/upload_api/smms_upload_task.dart';
import 'package:horopic/router/application.dart';
import 'package:horopic/router/routers.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/utils/global.dart';
//修改自flutter_download_manager包 https://github.com/nabil6391/flutter_download_manager 作者@nabil6391

Map downloadStatus = {
  'DownloadStatus.downloading': "下载中",
  'DownloadStatus.paused': "暂停",
  'DownloadStatus.canceled': "取消",
  'DownloadStatus.failed': "失败",
  'DownloadStatus.completed': "完成",
  'DownloadStatus.queued': "排队中",
};

class SmmsUpDownloadManagePage extends StatefulWidget {
  String downloadPath;
  String tabIndex;
  SmmsUpDownloadManagePage(
      {Key? key, required this.downloadPath, required this.tabIndex})
      : super(key: key);

  @override
  SmmsUpDownloadManagePageState createState() =>
      SmmsUpDownloadManagePageState();
}

class SmmsUpDownloadManagePageState extends State<SmmsUpDownloadManagePage> {
  var downloadManager = DownloadManager();
  var uploadManager = UploadManager();
  List<String> uploadPathList = [];
  List<String> uploadFileNameList = [];
  List<String> uploadTokenList = [];
  var savedDir = '';

  @override
  void initState() {
    super.initState();
    downloadManager = DownloadManager();
    uploadManager = UploadManager();
    savedDir = '${widget.downloadPath}/PicHoro/Download/smms/';
    if (Global.smmsUploadList.isNotEmpty) {
      for (var i = 0; i < Global.smmsUploadList.length; i++) {
        var currentElement = jsonDecode(Global.smmsUploadList[i]);
        uploadPathList.add(currentElement[0]);
        uploadFileNameList.add(currentElement[1]);
        uploadTokenList.add(currentElement[2]);
      }
    }
  }

  _createUploadListItem() {
    List<Widget> list = [];
    for (var i = 0; i < Global.smmsUploadList.length; i++) {
      list.add(GestureDetector(
          onLongPress: () {
            showCupertinoAlertDialogWithConfirmFunc(
                context: context,
                content: '是否从任务列表中删除?',
                title: '通知',
                onConfirm: () async {
                  Navigator.pop(context);
                  Global.smmsUploadList.remove(Global.smmsUploadList[i]);
                  await Global.setSmmsUploadList(Global.smmsUploadList);
                  setState(() {});
                });
          },
          child: UploadListItem(
              onUploadPlayPausedPressed: (path, fileName, token) async {
                var task = uploadManager
                    .getUpload(jsonDecode(Global.smmsUploadList[i])[1]);
                if (task != null && !task.status.value.isCompleted) {
                  switch (task.status.value) {
                    case UploadStatus.uploading:
                      await uploadManager.pauseUpload(path, fileName);
                      break;
                    case UploadStatus.paused:
                      await uploadManager.resumeUpload(path, fileName);
                      break;
                  }
                  setState(() {});
                } else {
                  await uploadManager.addUpload(path, fileName, token);
                  setState(() {});
                }
              },
              onDelete: (path, fileName) async {
                await uploadManager.removeUpload(path, fileName);
                setState(() {});
              },
              path: jsonDecode(Global.smmsUploadList[i])[0],
              fileName: jsonDecode(Global.smmsUploadList[i])[1],
              token: jsonDecode(Global.smmsUploadList[i])[2],
              uploadTask: uploadManager
                  .getUpload(jsonDecode(Global.smmsUploadList[i])[1]))));
    }
    List<Widget> list2 = [
      const Divider(
        height: 5,
        color: Colors.transparent,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(
              onPressed: () async {
                await uploadManager.addBatchUploads(
                    uploadPathList, uploadFileNameList, uploadTokenList);
                setState(() {});
              },
              child: const Text(
                "全部开始",
                style: TextStyle(
                    color: Colors.blue,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              )),
          TextButton(
              onPressed: () async {
                await uploadManager.cancelBatchUploads(
                    uploadPathList, uploadFileNameList);
              },
              child: const Text(
                "全部取消",
                style: TextStyle(
                    color: Colors.blue,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              )),
          TextButton(
              onPressed: () async {
                await Global.setSmmsUploadList([]);
                setState(() {});
              },
              child: const Text(
                "全部清空",
                style: TextStyle(
                    color: Colors.blue,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              )),
        ],
      ),
      ValueListenableBuilder(
          valueListenable: uploadManager.getBatchUploadProgress(
              uploadPathList, uploadFileNameList),
          builder: (context, value, child) {
            return Container(
              color: const Color.fromARGB(255, 219, 239, 255),
              height: 10,
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: LinearProgressIndicator(
                value: value,
              ),
            );
          }),
    ];
    list2.addAll(list);

    return list2;
  }

  _createDownloadListItem() {
    List<Widget> list = [];
    for (var i = 0; i < Global.smmsDownloadList.length; i++) {
      list.add(GestureDetector(
          onLongPress: () {
            showCupertinoAlertDialogWithConfirmFunc(
                context: context,
                content: '是否从任务列表中删除?',
                title: '通知',
                onConfirm: () async {
                  Navigator.pop(context);
                  Global.smmsDownloadList.remove(Global.smmsDownloadList[i]);
                  await Global.setSmmsDownloadList(Global.smmsDownloadList);
                  Global.smmsSavedNameList.remove(Global.smmsSavedNameList[i]);
                  await Global.setSmmsSavedNameList(Global.smmsSavedNameList);
                  setState(() {});
                });
          },
          child: ListItem(
              onDownloadPlayPausedPressed: (url) async {
                var task =
                    downloadManager.getDownload(Global.smmsDownloadList[i]);
                if (task != null && !task.status.value.isCompleted) {
                  switch (task.status.value) {
                    case DownloadStatus.downloading:
                      await downloadManager.pauseDownload(url);
                      break;
                    case DownloadStatus.paused:
                      await downloadManager.resumeDownload(url);
                      break;
                  }
                  setState(() {});
                } else {
                  await downloadManager.addDownload(
                      url, "$savedDir${Global.smmsSavedNameList[i]}");
                  setState(() {});
                }
              },
              onDelete: (url) async {
                var fileName =
                    "$savedDir${Global.smmsSavedNameList[Global.smmsDownloadList.indexOf(url)]}";
                var file = File(fileName);
                try {
                  await file.delete();
                } catch (e) {
                  FLog.error(
                      className: 'SmmsUpDownloadManagePageState',
                      methodName: '_createDownloadListItem',
                      text: formatErrorMessage({
                        'url': url,
                        'fileName': fileName,
                      }, e.toString()),
                      dataLogType: DataLogType.ERRORS.toString());
                }
                await downloadManager.removeDownload(url);
                setState(() {});
              },
              index: i,
              savedFileNameList: Global.smmsSavedNameList,
              url: Global.smmsDownloadList[i],
              downloadTask:
                  downloadManager.getDownload(Global.smmsDownloadList[i]))));
    }
    List<Widget> list2 = [
      const Divider(
        height: 5,
        color: Colors.transparent,
      ),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        const SizedBox(
          width: 10,
        ),
        CupertinoButton(
          color: const Color.fromARGB(255, 78, 163, 233),
          padding: const EdgeInsets.all(10),
          onPressed: () async {
            String externalStorageDirectory =
                await ExternalPath.getExternalStoragePublicDirectory(
                    ExternalPath.DIRECTORY_DOWNLOADS);
            externalStorageDirectory =
                '$externalStorageDirectory/PicHoro/Download/smms';
            // ignore: use_build_context_synchronously
            Application.router.navigateTo(context,
                '${Routes.fileExplorer}?currentDirPath=${Uri.encodeComponent(externalStorageDirectory)}&rootPath=${Uri.encodeComponent(externalStorageDirectory)}',
                transition: TransitionType.cupertino);
          },
          child: const Text('打开下载文件目录',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
        ),
        const SizedBox(
          width: 10,
        ),
        CupertinoButton(
          color: const Color.fromARGB(255, 78, 163, 233),
          padding: const EdgeInsets.all(10),
          onPressed: () async {
            await Global.setSmmsDownloadList([]);
            await Global.setSmmsSavedNameList([]);
            setState(() {});
          },
          child: Row(
            children: const [
              Icon(
                Icons.delete,
                color: Colors.white,
              ),
              Text('清空下载文件列表',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ]),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(
              onPressed: () async {
                String externalStorageDirectory =
                    await ExternalPath.getExternalStoragePublicDirectory(
                        ExternalPath.DIRECTORY_DOWNLOADS);
                externalStorageDirectory =
                    '$externalStorageDirectory/PicHoro/Download/smms';
                List savedDirList = [];
                for (var i = 0; i < Global.smmsSavedNameList.length; i++) {
                  savedDirList.add(
                      '$externalStorageDirectory/${Global.smmsSavedNameList[i]}');
                }
                await downloadManager.addBatchDownloads(
                    Global.smmsDownloadList, savedDirList);
                setState(() {});
              },
              child: const Text(
                "全部下载",
                style: TextStyle(
                    color: Colors.blue,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              )),
          TextButton(
              onPressed: () async {
                await downloadManager
                    .pauseBatchDownloads(Global.smmsDownloadList);
              },
              child: const Text(
                "全部暂停",
                style: TextStyle(
                    color: Colors.blue,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              )),
          TextButton(
              onPressed: () async {
                await downloadManager
                    .resumeBatchDownloads(Global.smmsDownloadList);
              },
              child: const Text(
                "全部继续",
                style: TextStyle(
                    color: Colors.blue,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              )),
          TextButton(
              onPressed: () async {
                await downloadManager
                    .cancelBatchDownloads(Global.smmsDownloadList);
              },
              child: const Text(
                "全部取消",
                style: TextStyle(
                    color: Colors.blue,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              )),
        ],
      ),
      ValueListenableBuilder(
          valueListenable:
              downloadManager.getBatchDownloadProgress(Global.smmsDownloadList),
          builder: (context, value, child) {
            return Container(
              height: 10,
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: LinearProgressIndicator(
                value: value,
              ),
            );
          }),
    ];
    list2.addAll(list);
    return list2;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        initialIndex: int.parse(widget.tabIndex),
        length: 2,
        child: Scaffold(
            appBar: AppBar(
              centerTitle: true,
              elevation: 0,
              title: const Text('上传下载管理',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              bottom: const TabBar(
                padding: EdgeInsets.all(0),
                indicatorColor: Colors.amber,
                indicatorPadding: EdgeInsets.symmetric(horizontal: 30),
                unselectedLabelColor: Colors.white,
                tabs: <Widget>[
                  Tab(
                      child: Text('上传',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold))),
                  Tab(
                      child: Text('下载',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold))),
                ],
              ),
            ),
            body: TabBarView(
              children: <Widget>[
                SingleChildScrollView(
                  child: Column(
                    children: _createUploadListItem(),
                  ),
                ),
                SingleChildScrollView(
                  child: Column(
                    children: _createDownloadListItem(),
                  ),
                )
              ],
            )));
  }
}

class ListItem extends StatefulWidget {
  Function(String) onDownloadPlayPausedPressed;
  Function(String) onDelete;
  DownloadTask? downloadTask;
  List savedFileNameList;
  int index;
  String url;
  ListItem(
      {Key? key,
      required this.onDownloadPlayPausedPressed,
      required this.onDelete,
      required this.savedFileNameList,
      required this.index,
      required this.url,
      this.downloadTask})
      : super(key: key);

  @override
  ListItemState createState() => ListItemState();
}

class ListItemState extends State<ListItem> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(
              color: const Color.fromARGB(255, 80, 183, 231),
            ),
            borderRadius: const BorderRadius.all(Radius.circular(20))),
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '文件名:${widget.savedFileNameList[widget.index]}',
                    ),
                    if (widget.downloadTask != null)
                      ValueListenableBuilder(
                          valueListenable: widget.downloadTask!.status,
                          builder: (context, value, child) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                  "状态: ${downloadStatus[value.toString()]}",
                                  style: const TextStyle(fontSize: 14)),
                            );
                          }),
                  ],
                )),
                widget.downloadTask != null
                    ? ValueListenableBuilder(
                        valueListenable: widget.downloadTask!.status,
                        builder: (context, value, child) {
                          switch (widget.downloadTask!.status.value) {
                            case DownloadStatus.downloading:
                              return IconButton(
                                  onPressed: () async {
                                    await widget.onDownloadPlayPausedPressed(
                                        widget.url);
                                  },
                                  icon: const Icon(
                                    Icons.pause,
                                    color: Colors.blue,
                                  ));
                            case DownloadStatus.paused:
                              return IconButton(
                                onPressed: () async {
                                  await widget
                                      .onDownloadPlayPausedPressed(widget.url);
                                },
                                icon: const Icon(Icons.play_arrow),
                                color: Colors.blue,
                              );
                            case DownloadStatus.completed:
                              return IconButton(
                                  onPressed: () {
                                    widget.onDelete(widget.url);
                                  },
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ));
                            case DownloadStatus.failed:
                            case DownloadStatus.canceled:
                              return IconButton(
                                  onPressed: () async {
                                    await widget.onDownloadPlayPausedPressed(
                                        widget.url);
                                  },
                                  icon: const Icon(
                                    Icons.download,
                                    color: Colors.blue,
                                  ));
                          }
                          return Text("${downloadStatus[value.toString()]}",
                              style: const TextStyle(fontSize: 16));
                        })
                    : IconButton(
                        onPressed: () async {
                          await widget.onDownloadPlayPausedPressed(widget.url);
                        },
                        icon: const Icon(
                          Icons.download,
                          color: Colors.green,
                        ))
              ],
            ),
            if (widget.downloadTask != null &&
                !widget.downloadTask!.status.value.isCompleted)
              ValueListenableBuilder(
                  valueListenable: widget.downloadTask!.progress,
                  builder: (context, value, child) {
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: LinearProgressIndicator(
                        value: value,
                        color: widget.downloadTask!.status.value ==
                                DownloadStatus.paused
                            ? Colors.grey
                            : Colors.amber,
                      ),
                    );
                  }),
            if (widget.downloadTask != null)
              FutureBuilder<DownloadStatus>(
                  future: widget.downloadTask!.whenDownloadComplete(),
                  builder: (BuildContext context,
                      AsyncSnapshot<DownloadStatus> snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                        return const Text('请等待下载完成');
                      default:
                        if (snapshot.hasError) {
                          return Text('错误: ${snapshot.error}');
                        } else {
                          return Text(
                              '结果: ${downloadStatus[snapshot.data.toString()]}');
                        }
                    }
                  })
          ],
        ),
      ),
    );
  }
}

class UploadListItem extends StatefulWidget {
  Function(String, String, String) onUploadPlayPausedPressed;
  Function(String, String) onDelete;
  UploadTask? uploadTask;
  String path;
  String fileName;
  String token;
  UploadListItem(
      {Key? key,
      required this.onUploadPlayPausedPressed,
      required this.onDelete,
      required this.path,
      required this.fileName,
      required this.token,
      this.uploadTask})
      : super(key: key);

  @override
  UploadListItemState createState() => UploadListItemState();
}

class UploadListItemState extends State<UploadListItem> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(1.0),
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(
              color: const Color.fromARGB(255, 203, 237, 253),
            ),
            borderRadius: const BorderRadius.all(Radius.circular(20))),
        padding: const EdgeInsets.all(1.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                getImageIcon(widget.path),
                Expanded(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '文件名:${widget.fileName}',
                    ),
                    if (widget.uploadTask != null)
                      ValueListenableBuilder(
                          valueListenable: widget.uploadTask!.status,
                          builder: (context, value, child) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                  "状态: ${uploadStatus[value.toString()]}",
                                  style: const TextStyle(fontSize: 14)),
                            );
                          }),
                  ],
                )),
                widget.uploadTask != null
                    ? ValueListenableBuilder(
                        valueListenable: widget.uploadTask!.status,
                        builder: (context, value, child) {
                          switch (widget.uploadTask!.status.value) {
                            case UploadStatus.uploading:
                              return IconButton(
                                  onPressed: () async {
                                    await widget.onUploadPlayPausedPressed(
                                        widget.path,
                                        widget.fileName,
                                        widget.token);
                                  },
                                  icon: const Icon(
                                    Icons.pause,
                                    color: Colors.blue,
                                  ));
                            case UploadStatus.paused:
                              return IconButton(
                                onPressed: () async {
                                  await widget.onUploadPlayPausedPressed(
                                      widget.path,
                                      widget.fileName,
                                      widget.token);
                                },
                                icon: const Icon(Icons.play_arrow),
                                color: Colors.blue,
                              );
                            case UploadStatus.completed:
                              return IconButton(
                                  onPressed: () {
                                    widget.onDelete(
                                        widget.path, widget.fileName);
                                  },
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ));
                            case UploadStatus.failed:
                            case UploadStatus.canceled:
                              return IconButton(
                                  onPressed: () async {
                                    await widget.onUploadPlayPausedPressed(
                                        widget.path,
                                        widget.fileName,
                                        widget.token);
                                  },
                                  icon: const Icon(
                                    Icons.cloud_upload_outlined,
                                    color: Colors.blue,
                                  ));
                          }
                          return Text("${uploadStatus[value.toString()]}",
                              style: const TextStyle(fontSize: 16));
                        })
                    : IconButton(
                        onPressed: () async {
                          await widget.onUploadPlayPausedPressed(
                              widget.path, widget.fileName, widget.token);
                        },
                        icon: const Icon(
                          Icons.cloud_upload_outlined,
                          color: Colors.green,
                        ))
              ],
            ),
            if (widget.uploadTask != null &&
                !widget.uploadTask!.status.value.isCompleted)
              ValueListenableBuilder(
                  valueListenable: widget.uploadTask!.progress,
                  builder: (context, value, child) {
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: LinearProgressIndicator(
                        value: value,
                        color: widget.uploadTask!.status.value ==
                                UploadStatus.paused
                            ? Colors.grey
                            : Colors.amber,
                      ),
                    );
                  }),
            if (widget.uploadTask != null)
              FutureBuilder<UploadStatus>(
                  future: widget.uploadTask!.whenUploadComplete(),
                  builder: (BuildContext context,
                      AsyncSnapshot<UploadStatus> snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                        return const Text('请等待上传完成');
                      default:
                        if (snapshot.hasError) {
                          return Text('错误: ${snapshot.error}');
                        } else {
                          return Text(
                              '结果: ${uploadStatus[snapshot.data.toString()]}');
                        }
                    }
                  })
          ],
        ),
      ),
    );
  }
}
