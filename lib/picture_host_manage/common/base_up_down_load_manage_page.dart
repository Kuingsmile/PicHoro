import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:external_path/external_path.dart';
import 'package:fluro/fluro.dart';

import 'package:horopic/picture_host_manage/common/download/common_service/base_download_manager.dart';
import 'package:horopic/picture_host_manage/common/download/common_service/base_download_status.dart';
import 'package:horopic/picture_host_manage/common/common_widget.dart';
import 'package:horopic/pages/upload_helper/upload_status.dart';
import 'package:horopic/picture_host_manage/common/upload/common_service/base_upload_manager.dart';
import 'package:horopic/router/application.dart';
import 'package:horopic/router/routers.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/utils/global.dart';
import 'package:horopic/picture_host_manage/common/upload/managers/alist_upload_manager.dart' as alist_upload_utils;
import 'package:horopic/picture_host_manage/common/upload/managers/aliyun_upload_manager.dart' as aliyun_upload_utils;
import 'package:horopic/picture_host_manage/common/upload/managers/aws_upload_manager.dart' as aws_upload_utils;
import 'package:horopic/picture_host_manage/common/upload/managers/sftp_upload_manager.dart' as ftp_upload_utils;
import 'package:horopic/picture_host_manage/common/upload/managers/github_upload_manager.dart' as github_upload_utils;
import 'package:horopic/picture_host_manage/common/upload/managers/imgur_upload_manager.dart' as imgur_upload_utils;
import 'package:horopic/picture_host_manage/common/upload/managers/lskypro_upload_manager.dart' as lskypro_upload_utils;
import 'package:horopic/picture_host_manage/common/upload/managers/qiniu_upload_manager.dart' as qiniu_upload_utils;
import 'package:horopic/picture_host_manage/common/upload/managers/smms_upload_manager.dart' as smms_upload_utils;
import 'package:horopic/picture_host_manage/common/upload/managers/tencent_upload_manager.dart' as tencent_upload_utils;
import 'package:horopic/picture_host_manage/common/upload/managers/upyun_upload_manager.dart' as upyun_upload_utils;
import 'package:horopic/picture_host_manage/common/upload/managers/webdav_upload_manager.dart' as webdav_upload_utils;

import 'package:horopic/picture_host_manage/common/download/managers/alist_download_manager.dart' as alist_downloader;
import 'package:horopic/picture_host_manage/common/download/managers/aliyun_download_manager.dart' as aliyun_downloader;
import 'package:horopic/picture_host_manage/common/download/managers/aws_download_manager.dart' as aws_downloader;
import 'package:horopic/picture_host_manage/common/download/managers/sftp_download_manager.dart' as ftp_downloader;
import 'package:horopic/picture_host_manage/common/download/managers/github_download_manager.dart' as github_downloader;
import 'package:horopic/picture_host_manage/common/download/managers/imgur_download_manager.dart' as imgur_downloader;
import 'package:horopic/picture_host_manage/common/download/managers/lskypro_download_manager.dart'
    as lskypro_downloader;
import 'package:horopic/picture_host_manage/common/download/managers/qiniu_download_manager.dart' as qiniu_downloader;
import 'package:horopic/picture_host_manage/common/download/managers/smms_download_manager.dart' as smms_downloader;
import 'package:horopic/picture_host_manage/common/download/managers/tencent_downloade_manager.dart'
    as tencent_downloader;
import 'package:horopic/picture_host_manage/common/download/managers/upyun_download_manager.dart' as upyun_downloader;
import 'package:horopic/picture_host_manage/common/download/managers/webdav_download_manager.dart' as webdav_downloader;
import 'package:horopic/widgets/common_widgets.dart';

class BaseUpDownloadManagePage extends StatefulWidget {
  final String userName;
  final String repoName;
  final String albumName;
  final String ftpHost;
  final String bucketName;
  final String downloadPath;
  final String tabIndex;
  final int currentListIndex;

  const BaseUpDownloadManagePage({
    super.key,
    required this.userName,
    required this.repoName,
    required this.albumName,
    required this.ftpHost,
    required this.bucketName,
    required this.downloadPath,
    required this.tabIndex,
    required this.currentListIndex,
  });

  @override
  BaseUpDownloadManagePageState createState() => BaseUpDownloadManagePageState();
}

class BaseUpDownloadManagePageState extends State<BaseUpDownloadManagePage> {
  String currentPShost = '';

  var savedDir = '';

  List<String> uploadPathList = [];
  List<String> uploadFileNameList = [];
  List<Map<String, dynamic>> uploadConfigMapList = [];
  List<String> currentUploadList = [];
  List<String> currentDownloadList = [];

  /// used for alist
  List<String> downloadUrlList = [];
  List<String> downloadFileNameList = [];
  List<Map<String, dynamic>> downloadConfigMapList = [];

  late BaseDownloadManager downloadManager;
  late BaseUploadManager uploadManager;
  late BaseUploadManager currentUploadManager;
  late BaseDownloadManager currentDownloadManager;

  late Function currentSetUploadList;
  late Function currentSetDownloadList;

  @override
  void initState() {
    super.initState();

    List<String> psHosts = [
      'alist',
      'aliyun',
      'aws',
      'ftp',
      'github',
      'imgur',
      'lsky.pro',
      'qiniu',
      'sm.ms',
      'tencent',
      'upyun',
      'webdav',
    ];

    List<List<String>> uploadLists = [
      Global.alistUploadList,
      Global.aliyunUploadList,
      Global.awsUploadList,
      Global.ftpUploadList,
      Global.githubUploadList,
      Global.imgurUploadList,
      Global.lskyproUploadList,
      Global.qiniuUploadList,
      Global.smmsUploadList,
      Global.tencentUploadList,
      Global.upyunUploadList,
      Global.webdavUploadList,
    ];

    List<List<String>> downloadLists = [
      Global.alistDownloadList,
      Global.aliyunDownloadList,
      Global.awsDownloadList,
      Global.ftpDownloadList,
      Global.githubDownloadList,
      Global.imgurDownloadList,
      Global.lskyproDownloadList,
      Global.qiniuDownloadList,
      Global.smmsDownloadList,
      Global.tencentDownloadList,
      Global.upyunDownloadList,
      Global.webdavDownloadList,
    ];

    List<BaseUploadManager> uploadManagers = [
      alist_upload_utils.UploadManager(),
      aliyun_upload_utils.UploadManager(),
      aws_upload_utils.UploadManager(),
      ftp_upload_utils.UploadManager(),
      github_upload_utils.UploadManager(),
      imgur_upload_utils.UploadManager(),
      lskypro_upload_utils.UploadManager(),
      qiniu_upload_utils.UploadManager(),
      smms_upload_utils.UploadManager(),
      tencent_upload_utils.UploadManager(),
      upyun_upload_utils.UploadManager(),
      webdav_upload_utils.UploadManager(),
    ];

    List<BaseDownloadManager> downloadManagers = [
      alist_downloader.DownloadManager(),
      aliyun_downloader.DownloadManager(),
      aws_downloader.DownloadManager(),
      ftp_downloader.DownloadManager(),
      github_downloader.DownloadManager(),
      imgur_downloader.DownloadManager(),
      lskypro_downloader.DownloadManager(),
      qiniu_downloader.DownloadManager(),
      smms_downloader.DownloadManager(),
      tencent_downloader.DownloadManager(),
      upyun_downloader.DownloadManager(),
      webdav_downloader.DownloadManager(),
    ];

    List<void Function(List<String>)> setUploadLists = [
      Global.setAlistUploadList,
      Global.setAliyunUploadList,
      Global.setAwsUploadList,
      Global.setFtpUploadList,
      Global.setGithubUploadList,
      Global.setImgurUploadList,
      Global.setLskyproUploadList,
      Global.setQiniuUploadList,
      Global.setSmmsUploadList,
      Global.setTencentUploadList,
      Global.setUpyunUploadList,
      Global.setWebdavUploadList,
    ];

    List<void Function(List<String>)> setDownloadLists = [
      Global.setAlistDownloadList,
      Global.setAliyunDownloadList,
      Global.setAwsDownloadList,
      Global.setFtpDownloadList,
      Global.setGithubDownloadList,
      Global.setImgurDownloadList,
      Global.setLskyproDownloadList,
      Global.setQiniuDownloadList,
      Global.setSmmsDownloadList,
      Global.setTencentDownloadList,
      Global.setUpyunDownloadList,
      Global.setWebdavDownloadList,
    ];

    currentPShost = psHosts[widget.currentListIndex];
    if (currentPShost == 'qiniu') {
      showToast('请注意设置为公开存储，否则无法下载');
    }

    uploadManager = uploadManagers[widget.currentListIndex];
    downloadManager = downloadManagers[widget.currentListIndex];
    currentUploadManager = uploadManagers[widget.currentListIndex];
    currentDownloadManager = downloadManagers[widget.currentListIndex];

    currentUploadList = uploadLists[widget.currentListIndex];
    currentDownloadList = downloadLists[widget.currentListIndex];
    currentSetUploadList = setUploadLists[widget.currentListIndex];
    currentSetDownloadList = setDownloadLists[widget.currentListIndex];

    switch (currentPShost) {
      case 'lsky.pro':
        savedDir = '${widget.downloadPath}/PicHoro/Download/lskypro/${widget.albumName}/';
      case 'imgur':
        savedDir = '${widget.downloadPath}/PicHoro/Download/imgur/${widget.albumName}/';
      case 'github':
        savedDir = '${widget.downloadPath}/PicHoro/Download/github/${widget.userName}/${widget.repoName}/';
      case 'ftp':
        savedDir = '${widget.downloadPath}/PicHoro/Download/ftp/${widget.ftpHost}/';
      case 'sm.ms':
        savedDir = '${widget.downloadPath}/PicHoro/Download/smms/';
      default:
        savedDir = '${widget.downloadPath}/PicHoro/Download/$currentPShost/${widget.bucketName}/';
    }
    if (currentUploadList.isNotEmpty) {
      for (var i = 0; i < currentUploadList.length; i++) {
        var currentElement = jsonDecode(currentUploadList[i]);
        uploadPathList.add(currentElement[0]);
        uploadFileNameList.add(currentElement[1]);
        Map<String, dynamic> tempMap = currentElement[2];
        uploadConfigMapList.add(tempMap);
      }
    }
    if (currentPShost == 'alist' && currentDownloadList.isNotEmpty) {
      for (var i = 0; i < currentDownloadList.length; i++) {
        var currentElement = jsonDecode(currentDownloadList[i]);
        downloadUrlList.add(currentElement[0]);
        downloadFileNameList.add(currentElement[1]);
        Map<String, dynamic> tempMap = currentElement[2];
        downloadConfigMapList.add(tempMap);
      }
    }
  }

  _createUploadListItem() {
    List<Widget> list = [];
    for (var i = currentUploadList.length - 1; i >= 0; i--) {
      list.add(GestureDetector(
          onLongPress: () {
            showCupertinoAlertDialogWithConfirmFunc(
                context: context,
                content: '是否从任务列表中删除?',
                title: '通知',
                onConfirm: () async {
                  currentUploadList.remove(currentUploadList[i]);
                  await currentSetUploadList(currentUploadList);
                  uploadPathList.removeAt(i);
                  uploadFileNameList.removeAt(i);
                  uploadConfigMapList.removeAt(i);
                  setState(() {});
                });
          },
          child: UploadListItem(
              onUploadPlayPausedPressed: (path, fileName, configMap) async {
                var task = uploadManager.getUpload(jsonDecode(currentUploadList[i])[1]);
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
              path: jsonDecode(currentUploadList[i])[0],
              fileName: jsonDecode(currentUploadList[i])[1],
              configMap: jsonDecode(currentUploadList[i])[2],
              uploadTask: uploadManager.getUpload(jsonDecode(currentUploadList[i])[1]))));
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
                    List<String> tempList = [];
                    await currentSetUploadList(tempList);
                    currentUploadList = tempList;
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
                        value: double.parse(value.toString()),
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
    for (var i = currentDownloadList.length - 1; i >= 0; i--) {
      list.add(GestureDetector(
          onLongPress: () {
            showCupertinoAlertDialogWithConfirmFunc(
                context: context,
                content: '是否从任务列表中删除?',
                title: '通知',
                onConfirm: () async {
                  currentDownloadList.remove(currentDownloadList[i]);
                  await currentSetDownloadList(currentDownloadList);
                  if (currentPShost == 'smms') {
                    Global.smmsSavedNameList.remove(Global.smmsSavedNameList[i]);
                    Global.setSmmsSavedNameList(Global.smmsSavedNameList);
                  }
                  setState(() {});
                });
          },
          child: DownloadListItem(
              onDownloadPlayPausedPressed: (url, fileName, configMap) async {
                var task = downloadManager.getDownload(currentDownloadList[i]);
                if (task != null &&
                    task.status.value != DownloadStatus.completed &&
                    task.status.value != DownloadStatus.failed &&
                    task.status.value != DownloadStatus.canceled) {
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
                  List case1 = ['github', 'lsky.pro', 'ftp', 'imgur'];
                  if (case1.contains(currentPShost)) {
                    String fileName = url.substring(url.lastIndexOf('/') + 1);
                    await downloadManager.addDownload(url, "$savedDir$fileName");
                  } else if (currentPShost == 'sm.ms') {
                    await downloadManager.addDownload(url, "$savedDir${Global.smmsSavedNameList[i]}");
                  } else if (currentPShost == 'alist') {
                    await downloadManager.addDownload(url, "$savedDir$fileName",
                        fileName: fileName, configMap: configMap);
                  } else {
                    await downloadManager.addDownload(url, "$savedDir${downloadManager.getFileNameFromUrl(url)}");
                  }

                  setState(() {});
                }
              },
              onDelete: (url, fileName) async {
                String fileNameFormated;
                if (currentPShost == 'sm.ms') {
                  fileNameFormated = "$savedDir${Global.smmsSavedNameList[Global.smmsDownloadList.indexOf(url)]}";
                } else if (currentPShost == 'alist') {
                  fileNameFormated = '$savedDir$fileName';
                } else {
                  fileNameFormated = "$savedDir${downloadManager.getFileNameFromUrl(url)}";
                }
                if (currentPShost == 'github' && fileNameFormated.contains('?')) {
                  fileNameFormated = fileNameFormated.substring(0, fileNameFormated.indexOf('?'));
                }
                var file = File(fileNameFormated);
                try {
                  await file.delete();
                } catch (e) {
                  flogErr(
                      e,
                      {
                        'url': url,
                        'fileName': fileName,
                      },
                      'UpDownloadManagePageState',
                      '_createDownloadListItem_delete');
                }
                await downloadManager.removeDownload(url);
                setState(() {});
              },
              index: i,
              savedFileNameList: currentPShost == 'sm.ms' ? Global.smmsSavedNameList : null,
              currentPShost: currentPShost,
              url: currentPShost == 'alist' ? jsonDecode(Global.alistDownloadList[i])[0] : currentDownloadList[i],
              fileName: currentPShost == 'alist' ? jsonDecode(Global.alistDownloadList[i])[1] : null,
              configMap: currentPShost == 'alist' ? jsonDecode(Global.alistDownloadList[i])[2] : null,
              downloadTask: downloadManager.getDownload(
                  currentPShost == 'alist' ? jsonDecode(Global.alistDownloadList[i])[0] : currentDownloadList[i]))));
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
                  switch (currentPShost) {
                    case 'lsky.pro':
                      externalStorageDirectory = '$externalStorageDirectory/PicHoro/Download/lskypro';
                    case 'sm.ms':
                      externalStorageDirectory = '$externalStorageDirectory/PicHoro/Download/smms';
                    default:
                      externalStorageDirectory = '$externalStorageDirectory/PicHoro/Download/$currentPShost';
                  }
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
                onPressed: () async {
                  List<String> tempList = [];
                  await currentSetDownloadList(tempList);
                  currentDownloadList = tempList;
                  if (currentPShost == 'sm.ms') {
                    Global.setSmmsSavedNameList([]);
                  }
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
                    if (currentPShost == 'sm.ms') {
                      String externalStorageDirectory =
                          await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_DOWNLOAD);
                      externalStorageDirectory = '$externalStorageDirectory/PicHoro/Download/smms';
                      List<String> savedDirList = [];
                      for (var i = 0; i < Global.smmsSavedNameList.length; i++) {
                        savedDirList.add('$externalStorageDirectory/${Global.smmsSavedNameList[i]}');
                      }
                      await downloadManager.addBatchDownloadsWithDirs(currentDownloadList, savedDirList);
                    } else if (currentPShost == 'alist') {
                      await downloadManager.addBatchDownloads(downloadUrlList, savedDir,
                          fileNames: downloadFileNameList, configMaps: downloadConfigMapList);
                    } else {
                      await downloadManager.addBatchDownloads(currentDownloadList, savedDir);
                    }
                    setState(() {});
                  },
                ),
                _buildActionButton(
                  icon: Icons.pause,
                  label: "全部暂停",
                  onPressed: () async {
                    await downloadManager.pauseBatchDownloads(
                      currentPShost == 'alist' ? downloadUrlList : currentDownloadList,
                    );
                  },
                ),
                _buildActionButton(
                  icon: Icons.play_arrow,
                  label: "全部继续",
                  onPressed: () async {
                    await downloadManager.resumeBatchDownloads(
                      currentPShost == 'alist' ? downloadUrlList : currentDownloadList,
                    );
                  },
                ),
                _buildActionButton(
                  icon: Icons.cancel,
                  label: "全部取消",
                  onPressed: () async {
                    await downloadManager.cancelBatchDownloads(
                      currentPShost == 'alist' ? downloadUrlList : currentDownloadList,
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            ValueListenableBuilder(
                valueListenable: downloadManager
                    .getBatchDownloadProgress(currentPShost == 'alist' ? downloadUrlList : currentDownloadList),
                builder: (context, value, child) {
                  return Container(
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: double.parse(value.toString()),
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
              flexibleSpace: getFlexibleSpace(context),
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
