import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:external_path/external_path.dart';
import 'package:fluro/fluro.dart';

import 'package:horopic/picture_host_manage/common_page/download/pnc_download_status.dart';
import 'package:horopic/picture_host_manage/common_page/common_widget.dart';
import 'package:horopic/pages/upload_pages/upload_status.dart';
import 'package:horopic/router/application.dart';
import 'package:horopic/router/routers.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/utils/global.dart';
import 'package:horopic/picture_host_manage/alist/upload_api/alist_upload_utils.dart'
    as alist_upload_utils;
import 'package:horopic/picture_host_manage/aliyun/upload_api/aliyun_upload_utils.dart'
    as aliyun_upload_utils;
import 'package:horopic/picture_host_manage/aws/upload_api/aws_upload_utils.dart'
    as aws_upload_utils;
import 'package:horopic/picture_host_manage/ftp/upload_api/sftp_upload_utils.dart'
    as ftp_upload_utils;
import 'package:horopic/picture_host_manage/github/upload_api/github_upload_utils.dart'
    as github_upload_utils;
import 'package:horopic/picture_host_manage/imgur/upload_api/imgur_upload_utils.dart'
    as imgur_upload_utils;
import 'package:horopic/picture_host_manage/lskypro/upload_api/lskypro_upload_utils.dart'
    as lskypro_upload_utils;
import 'package:horopic/picture_host_manage/qiniu/upload_api/qiniu_upload_utils.dart'
    as qiniu_upload_utils;
import 'package:horopic/picture_host_manage/smms/upload_api/smms_upload_utils.dart'
    as smms_upload_utils;
import 'package:horopic/picture_host_manage/tencent/upload_api/tencent_upload_utils.dart'
    as tencent_upload_utils;
import 'package:horopic/picture_host_manage/upyun/upload_api/upyun_upload_utils.dart'
    as upyun_upload_utils;
import 'package:horopic/picture_host_manage/webdav/upload_api/webdav_upload_utils.dart'
    as webdav_upload_utils;

import 'package:horopic/picture_host_manage/alist/download_api/alist_downloader.dart'
    as alist_downloader;
import 'package:horopic/picture_host_manage/aliyun/download_api/aliyun_downloader.dart'
    as aliyun_downloader;
import 'package:horopic/picture_host_manage/aws/download_api/aws_downloader.dart'
    as aws_downloader;
import 'package:horopic/picture_host_manage/ftp/download_api/sftp_downloader.dart'
    as ftp_downloader;
import 'package:horopic/picture_host_manage/github/download_api/github_downloader.dart'
    as github_downloader;
import 'package:horopic/picture_host_manage/imgur/download_api/imgur_downloader.dart'
    as imgur_downloader;
import 'package:horopic/picture_host_manage/lskypro/download_api/lskypro_downloader.dart'
    as lskypro_downloader;
import 'package:horopic/picture_host_manage/qiniu/download_api/qiniu_downloader.dart'
    as qiniu_downloader;
import 'package:horopic/picture_host_manage/smms/download_api/smms_downloader.dart'
    as smms_downloader;
import 'package:horopic/picture_host_manage/tencent/download_api/tencent_downloader.dart'
    as tencent_downloader;
import 'package:horopic/picture_host_manage/upyun/download_api/upyun_downloader.dart'
    as upyun_downloader;
import 'package:horopic/picture_host_manage/webdav/download_api/webdav_downloader.dart'
    as webdav_downloader;

//修改自flutter_download_manager包 https://github.com/nabil6391/flutter_download_manager 作者@nabil6391

class BaseUpDownloadManagePage extends StatefulWidget {
  final String userName;
  final String repoName;
  final String albumName;
  final String ftpHost;
  final String bucketName;
  String downloadPath;
  String tabIndex;
  int currentListIndex;
  BaseUpDownloadManagePage({
    Key? key,
    required this.userName,
    required this.repoName,
    required this.albumName,
    required this.ftpHost,
    required this.bucketName,
    required this.downloadPath,
    required this.tabIndex,
    required this.currentListIndex,
  }) : super(key: key);

  @override
  BaseUpDownloadManagePageState createState() =>
      BaseUpDownloadManagePageState();
}

class BaseUpDownloadManagePageState extends State<BaseUpDownloadManagePage> {
  var downloadManager;
  var uploadManager;
  var savedDir = '';
  List<String> uploadPathList = [];
  List<String> uploadFileNameList = [];
  List<Map<String, dynamic>> uploadConfigMapList = [];
  String currentPShost = '';
  List<String> currentUploadList = [];
  List<String> currentDownloadList = [];
  var currentUploadManager;
  var currentDownloadManager;
  late Function currentSetUploadList;
  late Function currentSetDownloadList;

  @override
  void initState() {
    super.initState();

    List psHosts = [
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

    List uploadManagers = [
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

    List downloadManagers = [
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

    List setUploadLists = [
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

    List setDownloadLists = [
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
    downloadManager = downloadManagers[widget.currentListIndex];
    uploadManager = uploadManagers[widget.currentListIndex];
    currentPShost = psHosts[widget.currentListIndex];
    if (currentPShost == 'qiniu') {
      showToast('请注意设置为公开存储，否则无法下载');
    }
    currentUploadList = uploadLists[widget.currentListIndex];
    currentDownloadList = downloadLists[widget.currentListIndex];
    currentSetUploadList = setUploadLists[widget.currentListIndex];
    currentSetDownloadList = setDownloadLists[widget.currentListIndex];
    currentUploadManager = uploadManagers[widget.currentListIndex];
    currentDownloadManager = downloadManagers[widget.currentListIndex];
    switch (currentPShost) {
      case 'lsky.pro':
        savedDir =
            '${widget.downloadPath}/PicHoro/Download/lskypro/${widget.albumName}/';
        break;
      case 'github':
        savedDir =
            '${widget.downloadPath}/PicHoro/Download/github/${widget.userName}/${widget.repoName}/';
        break;
      case 'ftp':
        savedDir =
            '${widget.downloadPath}/PicHoro/Download/ftp/${widget.ftpHost}/';
        break;
      default:
        savedDir =
            '${widget.downloadPath}/PicHoro/Download/$currentPShost/${widget.bucketName}/';
        break;
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
                  Navigator.pop(context);
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
                var task = uploadManager
                    .getUpload(jsonDecode(currentUploadList[i])[1]);
                if (task != null && !task.status.isCompleted) {
                  switch (task.status.value) {
                    case UploadStatus.uploading:
                      await uploadManager.pauseUpload(path, fileName);
                      break;
                    case UploadStatus.paused:
                      await uploadManager.resumeUpload(path, fileName);
                      break;
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
              uploadTask: uploadManager
                  .getUpload(jsonDecode(currentUploadList[i])[1]))));
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
                    uploadPathList, uploadFileNameList, uploadConfigMapList);
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
                List<String> tempList = [];
                await currentSetUploadList(tempList);
                currentUploadList = tempList;
                uploadPathList.clear();
                uploadFileNameList.clear();
                uploadConfigMapList.clear();
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
                value: double.parse(value.toString()),
              ),
            );
          }),
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
                  Navigator.pop(context);
                  currentDownloadList.remove(currentDownloadList[i]);
                  await currentSetDownloadList(currentDownloadList);
                  setState(() {});
                });
          },
          child: ListItem(
              onDownloadPlayPausedPressed: (url) async {
                var task = downloadManager.getDownload(currentDownloadList[i]);
                if (task != null && !task.status.isCompleted) {
                  switch (task.status.value) {
                    case DownloadStatus.downloading:
                      await downloadManager.pauseDownload(url);
                      break;
                    case DownloadStatus.paused:
                      await downloadManager.resumeDownload(url);
                      break;
                    default:
                      break;
                  }
                  setState(() {});
                } else {
                  if (currentPShost == 'github' ||
                      currentPShost == 'lsky.pro' ||
                      currentPShost == 'ftp') {
                    String fileName = url.substring(url.lastIndexOf('/') + 1);
                    await downloadManager.addDownload(
                        url, "$savedDir$fileName");
                  } else {
                    await downloadManager.addDownload(url,
                        "$savedDir${downloadManager.getFileNameFromUrl(url)}");
                  }

                  setState(() {});
                }
              },
              onDelete: (url) async {
                var fileName =
                    "$savedDir${downloadManager.getFileNameFromUrl(url)}";
                if (currentPShost == 'github' && fileName.contains('?')) {
                  fileName = fileName.substring(0, fileName.indexOf('?'));
                }
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
                      'UpDownloadManagePageState',
                      '_createDownloadListItem_delete');
                }
                await downloadManager.removeDownload(url);
                setState(() {});
              },
              url: currentDownloadList[i],
              downloadTask:
                  downloadManager.getDownload(currentDownloadList[i]))));
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
            switch (currentPShost) {
              case 'lsky.pro':
                externalStorageDirectory =
                    '$externalStorageDirectory/PicHoro/Download/lskypro';
                break;
              default:
                externalStorageDirectory =
                    '$externalStorageDirectory/PicHoro/Download/$currentPShost';
                break;
            }
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
            List<String> tempList = [];
            await currentSetDownloadList(tempList);
            currentDownloadList = tempList;
            setState(() {});
          },
          child: Row(
            children: const [
              Icon(
                Icons.delete,
                color: Colors.white,
              ),
              Text('清空下载列表',
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
                await downloadManager.addBatchDownloads(
                    currentDownloadList, savedDir);
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
                await downloadManager.pauseBatchDownloads(currentDownloadList);
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
                await downloadManager.resumeBatchDownloads(currentDownloadList);
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
                await downloadManager.cancelBatchDownloads(currentDownloadList);
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
              downloadManager.getBatchDownloadProgress(currentDownloadList),
          builder: (context, value, child) {
            return Container(
              height: 10,
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: LinearProgressIndicator(
                value: double.parse(value.toString()),
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
              title: titleText(
                '上传下载管理',
              ),
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
