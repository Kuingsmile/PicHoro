import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:fluro/fluro.dart';
import 'package:f_logs/f_logs.dart';
import 'package:external_path/external_path.dart';

import 'package:horopic/picture_host_manage/smms/download_api/smms_downloader.dart';
import 'package:horopic/picture_host_manage/smms/download_api/smms_download_task.dart';
import 'package:horopic/picture_host_manage/tencent/download_api/download_status.dart';
import 'package:horopic/router/application.dart';
import 'package:horopic/router/routers.dart';
import 'package:horopic/utils/common_functions.dart';
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
  List<String> savedFileNameList;
  List<String> downloadList;
  String downloadPath;
  SmmsUpDownloadManagePage(
      {Key? key,
      required this.savedFileNameList,
      required this.downloadList,
      required this.downloadPath})
      : super(key: key);

  @override
  SmmsUpDownloadManagePageState createState() =>
      SmmsUpDownloadManagePageState();
}

class SmmsUpDownloadManagePageState extends State<SmmsUpDownloadManagePage> {
  var downloadManager = DownloadManager();
  var savedDir = '';

  @override
  void initState() {
    super.initState();
    downloadManager = DownloadManager();
    savedDir = '${widget.downloadPath}/PicHoro/Download/smms';
  }

  _createDownloadListItem() {
    List<Widget> list = [];
    for (var i = 0; i < widget.downloadList.length; i++) {
      list.add(ListItem(
          onDownloadPlayPausedPressed: (url) async {
            var task = downloadManager.getDownload(widget.downloadList[i]);
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
                  url, "$savedDir/${widget.savedFileNameList[i]}");
              setState(() {});
            }
          },
          onDelete: (url) async {
            var fileName =
                "$savedDir/${widget.savedFileNameList[widget.downloadList.indexOf(url)]}";
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
              if (kDebugMode) {
                print(e);
              }
            }
            await downloadManager.removeDownload(url);
            setState(() {});
          },
          index: i,
          savedFileNameList: widget.savedFileNameList,
          url: widget.downloadList[i],
          downloadTask: downloadManager.getDownload(widget.downloadList[i])));
    }
    List<Widget> list2 = [
      const Divider(
        height: 5,
        color: Colors.transparent,
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
                for (var i = 0; i < widget.savedFileNameList.length; i++) {
                  savedDirList.add(
                      '$externalStorageDirectory/${widget.savedFileNameList[i]}');
                }
                await downloadManager.addBatchDownloads(
                    widget.downloadList, savedDirList);
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
                await downloadManager.pauseBatchDownloads(widget.downloadList);
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
                await downloadManager.resumeBatchDownloads(widget.downloadList);
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
                await downloadManager.cancelBatchDownloads(widget.downloadList);
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
              downloadManager.getBatchDownloadProgress(widget.downloadList),
          builder: (context, value, child) {
            return Container(
              height: 10,
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: LinearProgressIndicator(
                value: value,
              ),
            );
          }),
      /*
      FutureBuilder<List<DownloadTask?>?>(
          future:
              downloadManager.whenBatchDownloadsComplete(widget.downloadList),
          builder: (BuildContext context,
              AsyncSnapshot<List<DownloadTask?>?> snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                if (snapshot.data == null) {
                  return const Text("等待添加下载任务");
                } else {
                  return Text('${snapshot.data?.length}个下载任务');
                }
              default:
                if (snapshot.hasError) {
                  return Text('错误: ${snapshot.error}');
                } else {
                  return snapshot.data != null
                      ? Column(children: [
                          const Text("下载结果:"),
                          for (var e in snapshot.data!)
                            e != null
                                ? Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                        "${downloadManager.getFileNameFromUrl(e.request.url)}: ${downloadStatus[e.status.value.toString()]}"),
                                  )
                                : const Text("未下载"),
                        ])
                      : const Text("请点击单独下载按钮或全部下载");
                }
            }
          })*/
    ];
    list2.addAll(list);
    return list2;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          title: const Text("下载管理页面"),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: _createDownloadListItem(),
          ),
        ));
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
