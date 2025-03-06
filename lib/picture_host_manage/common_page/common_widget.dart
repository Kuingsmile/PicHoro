import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:horopic/picture_host_manage/common_page/upload/pnc_upload_task.dart';
import 'package:horopic/picture_host_manage/common_page/download/pnc_download_task.dart';
import 'package:horopic/picture_host_manage/common_page/download/pnc_download_status.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/pages/upload_pages/upload_status.dart';

//上传列表
// ignore: must_be_immutable
class UploadListItem extends StatefulWidget {
  Function(String, String, Map<String, dynamic>) onUploadPlayPausedPressed;
  Function(String, String) onDelete;
  UploadTask? uploadTask;
  String path;
  String fileName;
  Map<String, dynamic> configMap;
  UploadListItem(
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
                              child:
                                  Text("状态: ${uploadStatus[value.toString()]}", style: const TextStyle(fontSize: 14)),
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
                                    Icons.delete,
                                    color: Colors.red,
                                  ));
                            case UploadStatus.failed:
                            case UploadStatus.canceled:
                              return IconButton(
                                  onPressed: () async {
                                    await widget.onUploadPlayPausedPressed(
                                        widget.path, widget.fileName, widget.configMap);
                                  },
                                  icon: const Icon(
                                    Icons.cloud_upload_outlined,
                                    color: Colors.blue,
                                  ));
                            default:
                              return widget.uploadTask == null || widget.uploadTask!.status.value == UploadStatus.queued
                                  ? const Icon(
                                      Icons.query_builder_rounded,
                                      color: Colors.blue,
                                    )
                                  : ValueListenableBuilder(
                                      valueListenable: widget.uploadTask!.progress,
                                      builder: (context, value, child) {
                                        return Container(
                                          height: 20,
                                          width: 20,
                                          margin: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                                          child: CircularProgressIndicator(
                                            value: value,
                                            strokeWidth: 4,
                                            color: widget.uploadTask!.status.value == UploadStatus.paused
                                                ? Colors.grey
                                                : Colors.blue,
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
                          Icons.cloud_upload_outlined,
                          color: Colors.green,
                        ))
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ListItem extends StatefulWidget {
  final Function(String) onDownloadPlayPausedPressed;
  final Function(String) onDelete;
  final DownloadTask? downloadTask;
  final String url;
  const ListItem(
      {super.key,
      required this.onDownloadPlayPausedPressed,
      required this.onDelete,
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
                    Text(widget.url.contains('/')
                        ? '文件名：${widget.url.split('/').last.split('?').first}'
                        : widget.url.contains('object') &&
                                widget.url.contains('bucket') &&
                                widget.url.contains('region')
                            ? '文件名:${jsonDecode(widget.url)['object'].split('/').last}'
                            : '文件名:${widget.url}'),
                    if (widget.downloadTask != null)
                      ValueListenableBuilder(
                          valueListenable: widget.downloadTask!.status,
                          builder: (context, value, child) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child:
                                  Text("状态: ${downloadStatus[value.toString()]}", style: const TextStyle(fontSize: 14)),
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
                                    Icons.pause,
                                    color: Colors.blue,
                                  ));
                            case DownloadStatus.paused:
                              return IconButton(
                                onPressed: () async {
                                  await widget.onDownloadPlayPausedPressed(widget.url);
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
                                    await widget.onDownloadPlayPausedPressed(widget.url);
                                  },
                                  icon: const Icon(
                                    Icons.download,
                                    color: Colors.blue,
                                  ));
                            case DownloadStatus.queued:
                              return const Icon(
                                Icons.query_builder_rounded,
                                color: Colors.blue,
                              );
                          }
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
            if (widget.downloadTask != null && !widget.downloadTask!.status.value.isCompleted)
              ValueListenableBuilder(
                  valueListenable: widget.downloadTask!.progress,
                  builder: (context, value, child) {
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: LinearProgressIndicator(
                        value: value,
                        color: widget.downloadTask!.status.value == DownloadStatus.paused ? Colors.grey : Colors.amber,
                      ),
                    );
                  }),
          ],
        ),
      ),
    );
  }
}
