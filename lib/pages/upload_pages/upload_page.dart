import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:external_path/external_path.dart';
import 'package:fluro/fluro.dart';

import 'package:horopic/pages/upload_pages/upload_task.dart';
import 'package:horopic/pages/upload_pages/upload_utils.dart';
import 'package:horopic/pages/upload_pages/upload_status.dart';
import 'package:horopic/router/application.dart';
import 'package:horopic/router/routers.dart';

Map uploadStatus = {
  'UploadStatus.uploading': "上传中",
  'UploadStatus.canceled': "取消",
  'UploadStatus.failed': "失败",
  'UploadStatus.completed': "完成",
  'UploadStatus.queued': "排队中",
  'UploadStatus.paused': "暂停",
};

class UploadManagePage extends StatefulWidget {
  List<String> uploadList;
  UploadManagePage({
    Key? key,
    required this.uploadList,
  }) : super(key: key);

  @override
  UploadManagePageState createState() => UploadManagePageState();
}

class UploadManagePageState extends State<UploadManagePage> {
  var uploadManager = UploadManager();

  @override
  void initState() {
    super.initState();
    uploadManager = UploadManager();
    uploadManager.addBatchUploads(widget.uploadList);
                setState(() {});
  }

  _createUploadListItem() {
    List<Widget> list = [];
    for (var i = 0; i < widget.uploadList.length; i++) {
      list.add(ListItem(
          onUploadPlayPausedPressed: (path) async {
            var task = uploadManager.getUpload(widget.uploadList[i]);
            if (task != null && !task.status.value.isCompleted) {
              switch (task.status.value) {
                case UploadStatus.uploading:
                  await uploadManager.pauseUpload(path);
                  break;
                case UploadStatus.paused:
                  await uploadManager.resumeUpload(path);
                  break;
              }
              setState(() {});
            } else {
              await uploadManager.addUpload(path);
              setState(() {});
            }
          },
          onDelete: (path) async {
            await uploadManager.removeUpload(path);
            setState(() {});
          },
          path: widget.uploadList[i],
          uploadTask: uploadManager.getUpload(widget.uploadList[i])));
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
                await uploadManager.addBatchUploads(widget.uploadList);
                setState(() {});
              },
              child: const Text(
                "全部上传",
                style: TextStyle(
                    color: Colors.blue,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              )),
          TextButton(
              onPressed: () async {
                await uploadManager.pauseBatchUploads(widget.uploadList);
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
                await uploadManager.resumeBatchUploads(widget.uploadList);
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
                await uploadManager.cancelBatchUploads(widget.uploadList);
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
              uploadManager.getBatchUploadProgress(widget.uploadList),
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

    return  Scaffold(
            appBar: AppBar(
              elevation: 0,
              centerTitle: true,
              title: const Text("上传管理"),
            ),
            body: SingleChildScrollView(
              child: Column(
                children: _createUploadListItem(),
              ),
            ));
  }
}

class ListItem extends StatefulWidget {
  Function(String) onUploadPlayPausedPressed;
  Function(String) onDelete;
  UploadTask? uploadTask;
  String path;
  ListItem(
      {Key? key,
      required this.onUploadPlayPausedPressed,
      required this.onDelete,
      required this.path,
      this.uploadTask})
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
                      '文件名:${widget.path.split('/').last}',
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
                                    await widget
                                        .onUploadPlayPausedPressed(widget.path);
                                  },
                                  icon: const Icon(
                                    Icons.pause,
                                    color: Colors.blue,
                                  ));
                            case UploadStatus.paused:
                              return IconButton(
                                onPressed: () async {
                                  await widget
                                      .onUploadPlayPausedPressed(widget.path);
                                },
                                icon: const Icon(Icons.play_arrow),
                                color: Colors.blue,
                              );
                            case UploadStatus.completed:
                              return IconButton(
                                  onPressed: () {
                                    widget.onDelete(widget.path);
                                  },
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ));
                            case UploadStatus.failed:
                            case UploadStatus.canceled:
                              return IconButton(
                                  onPressed: () async {
                                    await widget
                                        .onUploadPlayPausedPressed(widget.path);
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
                          await widget.onUploadPlayPausedPressed(widget.path);
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
