import 'package:flutter/material.dart';
import 'package:horopic/pages/upload_helper/upload_status.dart';
import 'package:horopic/pages/upload_helper/upload_task.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:flutter/services.dart' as flutter_services;

class HomePageUploadItem extends StatefulWidget {
  final Function(String, String) onUploadPlayPausedPressed;
  final Function(String, String) onDelete;
  final UploadTask? uploadTask;
  final String path;
  final String fileName;
  final String? clipboardLink;
  final Function(String?)? onCopy;
  const HomePageUploadItem(
      {super.key,
      required this.onUploadPlayPausedPressed,
      required this.onDelete,
      required this.path,
      required this.fileName,
      this.uploadTask,
      this.clipboardLink,
      this.onCopy});

  @override
  HomePageUploadItemState createState() => HomePageUploadItemState();
}

class HomePageUploadItemState extends State<HomePageUploadItem> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Get clipboard link from task if available and not already set
    String? clipboardLink = widget.clipboardLink;
    if (clipboardLink == null &&
        widget.uploadTask != null &&
        widget.uploadTask!.status.value == UploadStatus.completed) {
      clipboardLink = widget.uploadTask!.formattedUrl;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.15),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: SizedBox(
                width: 45,
                height: 45,
                child: getImageIcon(widget.path),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.fileName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (widget.uploadTask != null)
                    ValueListenableBuilder(
                      valueListenable: widget.uploadTask!.status,
                      builder: (context, value, child) {
                        Color statusColor;
                        switch (value) {
                          case UploadStatus.completed:
                            statusColor = Colors.green;
                          case UploadStatus.failed:
                          case UploadStatus.canceled:
                            statusColor = Colors.red;
                          case UploadStatus.uploading:
                            statusColor = Colors.blue;
                          default:
                            statusColor = Colors.grey;
                        }

                        return Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: statusColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "${uploadStatus[value.toString()]}",
                              style: TextStyle(
                                fontSize: 12,
                                color: statusColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (value == UploadStatus.uploading)
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: ValueListenableBuilder(
                                    valueListenable: widget.uploadTask!.progress,
                                    builder: (context, progressValue, child) {
                                      return Container(
                                        height: 4,
                                        clipBehavior: Clip.hardEdge,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(2),
                                        ),
                                        child: LinearProgressIndicator(
                                          value: progressValue,
                                          backgroundColor: Colors.grey.withValues(alpha: 0.2),
                                          valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                ],
              ),
            ),
            if (widget.uploadTask != null &&
                widget.uploadTask!.status.value == UploadStatus.completed &&
                (clipboardLink != null || widget.uploadTask!.formattedUrl.isNotEmpty))
              IconButton(
                onPressed: () {
                  String linkText = clipboardLink ?? widget.uploadTask!.formattedUrl;
                  flutter_services.Clipboard.setData(flutter_services.ClipboardData(
                    text: linkText,
                  ));
                  showToastWithContext(context, '链接已复制到剪贴板');
                  if (widget.onCopy != null) {
                    widget.onCopy!(linkText);
                  }
                },
                icon: const Icon(
                  Icons.copy,
                  color: Colors.green,
                  size: 22,
                ),
                splashRadius: 24,
              ),
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
                              Icons.delete_outline,
                              color: Colors.red,
                              size: 22,
                            ),
                            splashRadius: 24,
                          );
                        case UploadStatus.failed:
                        case UploadStatus.canceled:
                          return IconButton(
                            onPressed: () async {
                              await widget.onUploadPlayPausedPressed(widget.path, widget.fileName);
                            },
                            icon: const Icon(
                              Icons.refresh_rounded,
                              color: Colors.blue,
                              size: 22,
                            ),
                            splashRadius: 24,
                          );
                        case UploadStatus.paused:
                          return IconButton(
                            onPressed: () async {
                              await widget.onUploadPlayPausedPressed(widget.path, widget.fileName);
                            },
                            icon: const Icon(
                              Icons.play_arrow_rounded,
                              color: Colors.green,
                              size: 24,
                            ),
                            splashRadius: 24,
                          );
                        case UploadStatus.uploading:
                          return IconButton(
                            onPressed: () async {
                              await widget.onUploadPlayPausedPressed(widget.path, widget.fileName);
                            },
                            icon: const Icon(
                              Icons.pause_rounded,
                              color: Colors.orange,
                              size: 22,
                            ),
                            splashRadius: 24,
                          );
                        default:
                          return widget.uploadTask == null || widget.uploadTask!.status.value == UploadStatus.queued
                              ? const Padding(
                                  padding: EdgeInsets.all(12.0),
                                  child: Icon(
                                    Icons.access_time_rounded,
                                    color: Colors.grey,
                                    size: 22,
                                  ),
                                )
                              : ValueListenableBuilder(
                                  valueListenable: widget.uploadTask!.progress,
                                  builder: (context, value, child) {
                                    return Container(
                                      height: 24,
                                      width: 24,
                                      margin: const EdgeInsets.fromLTRB(0, 0, 12, 0),
                                      child: CircularProgressIndicator(
                                        value: value,
                                        strokeWidth: 3,
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
                      await widget.onUploadPlayPausedPressed(widget.path, widget.fileName);
                    },
                    icon: const Icon(
                      Icons.cloud_upload_outlined,
                      color: Colors.green,
                      size: 22,
                    ),
                    splashRadius: 24,
                  ),
          ],
        ),
      ),
    );
  }
}
