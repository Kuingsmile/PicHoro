import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluro/fluro.dart';
import 'package:external_path/external_path.dart';

import 'package:horopic/picture_host_manage/common/upload/managers/smms_upload_manager.dart';
import 'package:horopic/picture_host_manage/common/download/managers/smms_download_manager.dart';
import 'package:horopic/picture_host_manage/common/download/common_service/base_download_task.dart';
import 'package:horopic/picture_host_manage/common/download/common_service/base_download_status.dart';
import 'package:horopic/picture_host_manage/common/upload/common_service/base_upload_task.dart';
import 'package:horopic/pages/upload_helper/upload_status.dart';
import 'package:horopic/router/application.dart';
import 'package:horopic/router/routers.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/utils/global.dart';
//修改自flutter_download_manager包 https://github.com/nabil6391/flutter_download_manager 作者@nabil6391

class SmmsUpDownloadManagePage extends StatefulWidget {
  final String downloadPath;
  final String tabIndex;
  const SmmsUpDownloadManagePage({super.key, required this.downloadPath, required this.tabIndex});

  @override
  SmmsUpDownloadManagePageState createState() => SmmsUpDownloadManagePageState();
}

class SmmsUpDownloadManagePageState extends State<SmmsUpDownloadManagePage> {
  var downloadManager = DownloadManager();
  var uploadManager = UploadManager();
  List<String> uploadPathList = [];
  List<String> uploadFileNameList = [];
  List<Map<String, dynamic>> uploadConfigMapList = [];
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
        Map<String, dynamic> tempMap = currentElement[2];
        uploadConfigMapList.add(tempMap);
      }
    }
  }

  _createUploadListItem() {
    List<Widget> list = [];
    for (var i = Global.smmsUploadList.length - 1; i >= 0; i--) {
      list.add(GestureDetector(
          onLongPress: () {
            showCupertinoAlertDialogWithConfirmFunc(
                context: context,
                content: '是否从任务列表中删除?',
                title: '通知',
                onConfirm: () async {
                  Navigator.pop(context);
                  Global.smmsUploadList.remove(Global.smmsUploadList[i]);
                  Global.setSmmsUploadList(Global.smmsUploadList);
                  uploadPathList.removeAt(i);
                  uploadFileNameList.removeAt(i);
                  uploadConfigMapList.removeAt(i);
                  setState(() {});
                });
          },
          child: UploadListItem(
              onUploadPlayPausedPressed: (path, fileName, configMap) async {
                var task = uploadManager.getUpload(jsonDecode(Global.smmsUploadList[i])[1]);
                if (task != null && !task.status.value.isCompleted) {
                  switch (task.status.value) {
                    case UploadStatus.uploading:
                      await uploadManager.pauseUpload(path, fileName);
                    case UploadStatus.paused:
                      await uploadManager.resumeUpload(path, fileName);
                    default:
                      break;
                  }
                  setState(() {});
                } else {
                  await uploadManager.addUpload(path, fileName, configMap);
                  setState(() {});
                }
              },
              onDelete: (path, fileName) async {
                await uploadManager.removeUpload(path, fileName);
                setState(() {});
              },
              path: jsonDecode(Global.smmsUploadList[i])[0],
              fileName: jsonDecode(Global.smmsUploadList[i])[1],
              configMap: jsonDecode(Global.smmsUploadList[i])[2],
              uploadTask: uploadManager.getUpload(jsonDecode(Global.smmsUploadList[i])[1]))));
    }
    List<Widget> list2 = [
      const SizedBox(height: 16),
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFf8f9fa),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.2),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionButton(
                  icon: Icons.play_circle_fill,
                  label: "全部开始",
                  onPressed: () async {
                    await uploadManager.addBatchUploads(uploadPathList, uploadFileNameList, uploadConfigMapList);
                    setState(() {});
                  },
                ),
                _buildActionButton(
                  icon: Icons.cancel,
                  label: "全部取消",
                  onPressed: () async {
                    await uploadManager.cancelBatchUploads(uploadPathList, uploadFileNameList);
                  },
                ),
                _buildActionButton(
                  icon: Icons.clear_all,
                  label: "全部清空",
                  onPressed: () async {
                    Global.setSmmsUploadList([]);
                    uploadPathList.clear();
                    uploadFileNameList.clear();
                    uploadConfigMapList.clear();
                    setState(() {});
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            ValueListenableBuilder(
                valueListenable: uploadManager.getBatchUploadProgress(uploadPathList, uploadFileNameList),
                builder: (context, value, child) {
                  return Container(
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: value,
                        backgroundColor: Colors.grey.shade200,
                        color: const Color(0xFF2ecc71),
                      ),
                    ),
                  );
                }),
          ],
        ),
      ),
      const SizedBox(height: 12),
    ];
    list2.addAll(list);
    return list2;
  }

  _createDownloadListItem() {
    List<Widget> list = [];
    for (var i = Global.smmsDownloadList.length - 1; i >= 0; i--) {
      list.add(GestureDetector(
          onLongPress: () {
            showCupertinoAlertDialogWithConfirmFunc(
                context: context,
                content: '是否从任务列表中删除?',
                title: '通知',
                onConfirm: () async {
                  Navigator.pop(context);
                  Global.smmsDownloadList.remove(Global.smmsDownloadList[i]);
                  Global.setSmmsDownloadList(Global.smmsDownloadList);
                  Global.smmsSavedNameList.remove(Global.smmsSavedNameList[i]);
                  Global.setSmmsSavedNameList(Global.smmsSavedNameList);
                  setState(() {});
                });
          },
          child: ListItem(
              onDownloadPlayPausedPressed: (url) async {
                var task = downloadManager.getDownload(Global.smmsDownloadList[i]);
                if (task != null && !task.status.value.isCompleted) {
                  switch (task.status.value) {
                    case DownloadStatus.downloading:
                      await downloadManager.pauseDownload(url);
                    case DownloadStatus.paused:
                      await downloadManager.resumeDownload(url);
                    default:
                      break;
                  }
                  setState(() {});
                } else {
                  await downloadManager.addDownload(url, "$savedDir${Global.smmsSavedNameList[i]}");
                  setState(() {});
                }
              },
              onDelete: (url) async {
                var fileName = "$savedDir${Global.smmsSavedNameList[Global.smmsDownloadList.indexOf(url)]}";
                var file = File(fileName);
                try {
                  await file.delete();
                } catch (e) {
                  flogErr(
                      e,
                      {
                        'url': url,
                        'fileName': fileName,
                      },
                      'SmmsUpDownloadManagePageState',
                      '_createDownloadListItem');
                }
                await downloadManager.removeDownload(url);
                setState(() {});
              },
              index: i,
              savedFileNameList: Global.smmsSavedNameList,
              url: Global.smmsDownloadList[i],
              downloadTask: downloadManager.getDownload(Global.smmsDownloadList[i]))));
    }
    List<Widget> list2 = [
      const SizedBox(height: 16),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3498db),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 2,
                ),
                onPressed: () async {
                  String externalStorageDirectory =
                      await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_DOWNLOAD);
                  externalStorageDirectory = '$externalStorageDirectory/PicHoro/Download/smms';
                  // ignore: use_build_context_synchronously
                  Application.router.navigateTo(context,
                      '${Routes.fileExplorer}?currentDirPath=${Uri.encodeComponent(externalStorageDirectory)}&rootPath=${Uri.encodeComponent(externalStorageDirectory)}',
                      transition: TransitionType.cupertino);
                },
                icon: const Icon(Icons.folder_open, size: 20),
                label: const Text('打开下载目录', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFe74c3c),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 2,
                ),
                onPressed: () {
                  Global.setSmmsDownloadList([]);
                  Global.setSmmsSavedNameList([]);
                  setState(() {});
                },
                icon: const Icon(Icons.delete_sweep, size: 20),
                label: const Text('清空列表', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFf8f9fa),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.2),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionButton(
                  icon: Icons.download,
                  label: "全部下载",
                  onPressed: () async {
                    String externalStorageDirectory =
                        await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_DOWNLOAD);
                    externalStorageDirectory = '$externalStorageDirectory/PicHoro/Download/smms';
                    List<String> savedDirList = [];
                    for (var i = 0; i < Global.smmsSavedNameList.length; i++) {
                      savedDirList.add('$externalStorageDirectory/${Global.smmsSavedNameList[i]}');
                    }
                    await downloadManager.addBatchDownloadsWithDirs(Global.smmsDownloadList, savedDirList);
                    setState(() {});
                  },
                ),
                _buildActionButton(
                  icon: Icons.pause,
                  label: "全部暂停",
                  onPressed: () async {
                    await downloadManager.pauseBatchDownloads(Global.smmsDownloadList);
                  },
                ),
                _buildActionButton(
                  icon: Icons.play_arrow,
                  label: "全部继续",
                  onPressed: () async {
                    await downloadManager.resumeBatchDownloads(Global.smmsDownloadList);
                  },
                ),
                _buildActionButton(
                  icon: Icons.cancel,
                  label: "全部取消",
                  onPressed: () async {
                    await downloadManager.cancelBatchDownloads(Global.smmsDownloadList);
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            ValueListenableBuilder(
                valueListenable: downloadManager.getBatchDownloadProgress(Global.smmsDownloadList),
                builder: (context, value, child) {
                  return Container(
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: value,
                        backgroundColor: Colors.grey.shade200,
                        color: const Color(0xFF3498db),
                      ),
                    ),
                  );
                }),
          ],
        ),
      ),
      const SizedBox(height: 12),
    ];
    list2.addAll(list);
    return list2;
  }

  Widget _buildActionButton({required IconData icon, required String label, required VoidCallback onPressed}) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF3498db), size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF3498db),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
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
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColor.withValues(alpha: 0.8)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              title: titleText('上传下载管理'),
              bottom: const TabBar(
                labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                unselectedLabelStyle: TextStyle(fontSize: 14),
                padding: EdgeInsets.symmetric(horizontal: 16),
                indicatorColor: Colors.amber,
                indicatorWeight: 3,
                indicatorSize: TabBarIndicatorSize.label,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                tabs: <Widget>[
                  Tab(child: Text('上传')),
                  Tab(child: Text('下载')),
                ],
              ),
            ),
            body: TabBarView(
              children: <Widget>[
                SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: _createUploadListItem(),
                  ),
                ),
                SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: _createDownloadListItem(),
                  ),
                )
              ],
            )));
  }
}

class ListItem extends StatefulWidget {
  final Function(String) onDownloadPlayPausedPressed;
  final Function(String) onDelete;
  final DownloadTask? downloadTask;
  final List savedFileNameList;
  final int index;
  final String url;
  const ListItem(
      {super.key,
      required this.onDownloadPlayPausedPressed,
      required this.onDelete,
      required this.savedFileNameList,
      required this.index,
      required this.url,
      this.downloadTask});

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
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.15),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Material(
            color: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                          child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${widget.savedFileNameList[widget.index]}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: Color(0xFF333333),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          if (widget.downloadTask != null)
                            ValueListenableBuilder(
                                valueListenable: widget.downloadTask!.status,
                                builder: (context, value, child) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(value).withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      "状态: ${downloadStatus[value.toString()]}",
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: _getStatusColor(value),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
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
                                          await widget.onDownloadPlayPausedPressed(widget.url);
                                        },
                                        icon: const Icon(
                                          Icons.pause_circle,
                                          color: Color(0xFF3498db),
                                          size: 32,
                                        ));
                                  case DownloadStatus.paused:
                                    return IconButton(
                                      onPressed: () async {
                                        await widget.onDownloadPlayPausedPressed(widget.url);
                                      },
                                      icon: const Icon(
                                        Icons.play_circle,
                                        color: Color(0xFF3498db),
                                        size: 32,
                                      ),
                                    );
                                  case DownloadStatus.completed:
                                    return IconButton(
                                        onPressed: () {
                                          widget.onDelete(widget.url);
                                        },
                                        icon: const Icon(
                                          Icons.check_circle,
                                          color: Color(0xFF2ecc71),
                                          size: 32,
                                        ));
                                  case DownloadStatus.failed:
                                  case DownloadStatus.canceled:
                                    return IconButton(
                                        onPressed: () async {
                                          await widget.onDownloadPlayPausedPressed(widget.url);
                                        },
                                        icon: const Icon(
                                          Icons.error,
                                          color: Color(0xFFe74c3c),
                                          size: 32,
                                        ));
                                  case DownloadStatus.queued:
                                    return const SizedBox(
                                      width: 32,
                                      height: 32,
                                      child: Padding(
                                        padding: EdgeInsets.all(4.0),
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Color(0xFF3498db),
                                        ),
                                      ),
                                    );
                                }
                              })
                          : IconButton(
                              onPressed: () async {
                                await widget.onDownloadPlayPausedPressed(widget.url);
                              },
                              icon: const Icon(
                                Icons.download_rounded,
                                color: Color(0xFF2ecc71),
                                size: 32,
                              ))
                    ],
                  ),
                  if (widget.downloadTask != null && !widget.downloadTask!.status.value.isCompleted)
                    ValueListenableBuilder(
                        valueListenable: widget.downloadTask!.progress,
                        builder: (context, value, child) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const SizedBox(height: 8),
                              Container(
                                height: 6,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(3),
                                  child: LinearProgressIndicator(
                                    value: value,
                                    backgroundColor: Colors.grey.shade200,
                                    color: widget.downloadTask!.status.value == DownloadStatus.paused
                                        ? Colors.grey
                                        : const Color(0xFF3498db),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${(value * 100).toStringAsFixed(0)}%",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          );
                        }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(DownloadStatus status) {
    switch (status) {
      case DownloadStatus.downloading:
        return const Color(0xFF3498db);
      case DownloadStatus.completed:
        return const Color(0xFF2ecc71);
      case DownloadStatus.paused:
        return Colors.orange;
      case DownloadStatus.failed:
      case DownloadStatus.canceled:
        return const Color(0xFFe74c3c);
      case DownloadStatus.queued:
        return Colors.grey;
    }
  }
}

class UploadListItem extends StatefulWidget {
  final Function(String, String, Map<String, dynamic>) onUploadPlayPausedPressed;
  final Function(String, String) onDelete;
  final UploadTask? uploadTask;
  final String path;
  final String fileName;
  final Map<String, dynamic> configMap;
  const UploadListItem(
      {super.key,
      required this.onUploadPlayPausedPressed,
      required this.onDelete,
      required this.path,
      required this.fileName,
      required this.configMap,
      this.uploadTask});

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
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.15),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Material(
            color: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 36,
                        height: 36,
                        child: getImageIcon(widget.path),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                          child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.fileName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: Color(0xFF333333),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          if (widget.uploadTask != null)
                            ValueListenableBuilder(
                                valueListenable: widget.uploadTask!.status,
                                builder: (context, value, child) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: _getUploadStatusColor(value).withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      "状态: ${uploadStatus[value.toString()]}",
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: _getUploadStatusColor(value),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  );
                                }),
                        ],
                      )),
                      widget.uploadTask != null
                          ? ValueListenableBuilder(
                              valueListenable: widget.uploadTask!.status,
                              builder: (context, value, child) {
                                switch (widget.uploadTask!.status.value) {
                                  case UploadStatus.completed:
                                    return IconButton(
                                        onPressed: () {
                                          widget.onDelete(widget.path, widget.fileName);
                                        },
                                        icon: const Icon(
                                          Icons.check_circle,
                                          color: Color(0xFF2ecc71),
                                          size: 32,
                                        ));
                                  case UploadStatus.failed:
                                  case UploadStatus.canceled:
                                    return IconButton(
                                        onPressed: () async {
                                          await widget.onUploadPlayPausedPressed(
                                              widget.path, widget.fileName, widget.configMap);
                                        },
                                        icon: const Icon(
                                          Icons.error,
                                          color: Color(0xFFe74c3c),
                                          size: 32,
                                        ));
                                  default:
                                    return widget.uploadTask == null ||
                                            widget.uploadTask!.status.value == UploadStatus.queued
                                        ? const SizedBox(
                                            width: 32,
                                            height: 32,
                                            child: Padding(
                                              padding: EdgeInsets.all(4.0),
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Color(0xFF2ecc71),
                                              ),
                                            ),
                                          )
                                        : ValueListenableBuilder(
                                            valueListenable: widget.uploadTask!.progress,
                                            builder: (context, value, child) {
                                              return Container(
                                                height: 32,
                                                width: 32,
                                                margin: const EdgeInsets.all(8),
                                                child: CircularProgressIndicator(
                                                  value: value,
                                                  strokeWidth: 3,
                                                  color: widget.uploadTask!.status.value == UploadStatus.paused
                                                      ? Colors.grey
                                                      : const Color(0xFF2ecc71),
                                                  backgroundColor: Colors.grey.shade200,
                                                ),
                                              );
                                            });
                                }
                              })
                          : IconButton(
                              onPressed: () async {
                                await widget.onUploadPlayPausedPressed(widget.path, widget.fileName, widget.configMap);
                              },
                              icon: const Icon(
                                Icons.cloud_upload_rounded,
                                color: Color(0xFF2ecc71),
                                size: 32,
                              ))
                    ],
                  ),
                  if (widget.uploadTask != null && widget.uploadTask!.status.value == UploadStatus.uploading)
                    ValueListenableBuilder(
                        valueListenable: widget.uploadTask!.progress,
                        builder: (context, value, child) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const SizedBox(height: 8),
                              Container(
                                height: 6,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(3),
                                  child: LinearProgressIndicator(
                                    value: value,
                                    backgroundColor: Colors.grey.shade200,
                                    color: const Color(0xFF2ecc71),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${(value * 100).toStringAsFixed(0)}%",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          );
                        }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getUploadStatusColor(UploadStatus status) {
    switch (status) {
      case UploadStatus.uploading:
        return const Color(0xFF2ecc71);
      case UploadStatus.completed:
        return const Color(0xFF2ecc71);
      case UploadStatus.paused:
        return Colors.orange;
      case UploadStatus.failed:
      case UploadStatus.canceled:
        return const Color(0xFFe74c3c);
      case UploadStatus.queued:
        return Colors.grey;
    }
  }
}
