import 'dart:convert';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:horopic/picture_host_manage/common/upload/common_service/base_upload_task.dart';
import 'package:horopic/picture_host_manage/common/download/common_service/base_download_task.dart';
import 'package:horopic/picture_host_manage/common/download/common_service/base_download_status.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/pages/upload_helper/upload_status.dart';
import 'package:horopic/utils/global.dart';
import 'package:horopic/widgets/load_state_change.dart';

//上传列表
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
                                  await widget.onUploadPlayPausedPressed(
                                      widget.path, widget.fileName, widget.configMap);
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
        ));
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

/// 下载列表
class DownloadListItem extends StatefulWidget {
  final Function(String, String?, Map<String, dynamic>?) onDownloadPlayPausedPressed;
  final Function(String, String?) onDelete;
  final DownloadTask? downloadTask;
  final String currentPShost;
  final String url;
  // used for sm.ms
  final List<String>? savedFileNameList;
  final int? index;
  // used for alist
  final String? fileName;
  final Map<String, dynamic>? configMap;

  const DownloadListItem(
      {super.key,
      required this.onDownloadPlayPausedPressed,
      required this.onDelete,
      required this.url,
      this.savedFileNameList,
      this.index,
      required this.currentPShost,
      this.downloadTask,
      this.fileName,
      this.configMap});

  @override
  DownloadListItemState createState() => DownloadListItemState();
}

class DownloadListItemState extends State<DownloadListItem> {
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
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                          child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.currentPShost == 'sm.ms'
                              ? widget.savedFileNameList![widget.index!]
                              : widget.currentPShost == 'alist'
                                  ? '${widget.fileName}'
                                  : widget.url.contains('/')
                                      ? widget.url.split('/').last.split('?').first
                                      : widget.url.contains('object') &&
                                              widget.url.contains('bucket') &&
                                              widget.url.contains('region')
                                          ? '${jsonDecode(widget.url)['object'].split('/').last}'
                                          : widget.url),
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
                                          await widget.onDownloadPlayPausedPressed(
                                              widget.url, widget.fileName, widget.configMap);
                                        },
                                        icon: const Icon(
                                          Icons.pause_circle,
                                          color: Color(0xFF3498db),
                                          size: 32,
                                        ));
                                  case DownloadStatus.paused:
                                    return IconButton(
                                      onPressed: () async {
                                        await widget.onDownloadPlayPausedPressed(
                                            widget.url, widget.fileName, widget.configMap);
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
                                          widget.onDelete(widget.url, widget.fileName);
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
                                          await widget.onDownloadPlayPausedPressed(
                                              widget.url, widget.fileName, widget.configMap);
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
                                await widget.onDownloadPlayPausedPressed(widget.url, widget.fileName, widget.configMap);
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

Widget iconImageLoad(String url, String fileName) {
  String fileExtension = fileName.split('.').last.toLowerCase();
  try {
    if (Global.imgExt.contains(fileExtension)) {
      return ExtendedImage.network(
        url,
        clearMemoryCacheIfFailed: true,
        retries: 5,
        height: 50,
        width: 50,
        fit: BoxFit.cover,
        cache: true,
        loadStateChanged: (state) => defaultLoadStateChanged(state, iconSize: 50),
      );
    } else {
      throw Exception('Not an image file');
    }
  } catch (e) {
    // If the file is not an image, return a default icon
  }
  String iconPath = 'assets/icons/';
  if (fileExtension == '') {
    iconPath += '_blank.png';
  } else if (Global.iconList.contains(fileExtension)) {
    iconPath += '$fileExtension.png';
  } else {
    iconPath += 'unknown.png';
  }
  return Image.asset(
    iconPath,
    width: 50,
    height: 50,
  );
}
