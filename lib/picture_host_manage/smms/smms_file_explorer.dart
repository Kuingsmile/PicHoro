import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:external_path/external_path.dart';
import 'package:fluro/fluro.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart' as flutter_services;
import 'package:path/path.dart' as my_path;
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import 'package:horopic/picture_host_manage/manage_api/smms_manage_api.dart';
import 'package:horopic/widgets/net_loading_dialog.dart';
import 'package:horopic/utils/global.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/router/application.dart';
import 'package:horopic/router/routers.dart';
import 'package:horopic/picture_host_manage/common/loading_state.dart' as loading_state;
import 'package:horopic/utils/image_compressor.dart';
import 'package:horopic/picture_host_manage/common/base_file_explorer_page.dart';

class SmmsFileExplorer extends BaseFileExplorer {
  const SmmsFileExplorer({
    super.key,
  });

  @override
  SmmsFileExplorerState createState() => SmmsFileExplorerState();
}

class SmmsFileExplorerState extends BaseFileExplorerState<SmmsFileExplorer> {
  SmmsManageAPI get manageAPI => SmmsManageAPI();
  @override
  Future<void> initializeData() async {
    await _getFileList();
  }

  @override
  Future<void> refreshData() async {
    await _getFileList();
  }

  Future<void> _getFileList() async {
    try {
      var firstPageResult = await manageAPI.getFileList(page: 1);
      if (firstPageResult[0] != 'success') {
        state = loading_state.LoadState.error;
        return;
      }

      Map firstPageMap = firstPageResult[1];
      if (firstPageMap['Count'] == 0) {
        state = loading_state.LoadState.empty;
        return;
      }

      allInfoList.clear();
      allInfoList.addAll(firstPageMap['data']);
      int totalPage = firstPageMap['TotalPages'];
      if (totalPage > 1) {
        List<Future<List>> futures = [];
        for (int i = 2; i <= totalPage; i++) {
          futures.add(manageAPI.getFileList(page: i));
        }
        List<List> results = await Future.wait(futures);
        for (var result in results) {
          if (result[0] == 'success') {
            allInfoList.addAll(result[1]['data']);
          } else {
            flogErr('Failed to load page', {'result': result}, "SmmsFileExplorerState", "_getFileList_parallel");
          }
        }
      }
      selectedFilesBool = List.generate(allInfoList.length, (index) => false, growable: true);
      state = loading_state.LoadState.success;
    } catch (e) {
      flogErr(e, {}, "SmmsFileExplorerState", "_getFileList");
      state = loading_state.LoadState.error;
    } finally {
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  String getShareUrl(int index) => allInfoList[index]['url'];

  @override
  String getFileName(int index) => allInfoList[index]['filename'];

  @override
  String getFileDate(int index) {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(allInfoList[index]['created_at'].toString() != 'null'
        ? DateTime.parse(allInfoList[index]['created_at'].toString())
        : DateTime.now());
  }

  @override
  String getFormatedFileName(dynamic item) => item['filename'];

  @override
  Future<void> deleteFiles(List<int> toDelete) async {
    for (int i = 0; i < toDelete.length; i++) {
      var result = await manageAPI.deleteFile(allInfoList[toDelete[i] - i]['hash']);
      if (result[0] != 'success') {
        throw Exception(result[0]);
      }
      setState(() {
        allInfoList.removeAt(toDelete[i] - i);
        selectedFilesBool.removeAt(toDelete[i] - i);
      });
      if (allInfoList.isEmpty) {
        setState(() {
          state = loading_state.LoadState.empty;
        });
      }
    }
  }

  @override
  void navigateToDownloadManagement() async {
    String downloadPath = await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_DOWNLOAD);
    final int index = Global.smmsDownloadList.isNotEmpty ? 1 : 0;
    if (mounted) {
      Application.router.navigateTo(context,
          '/baseUpDownloadManagePage?downloadPath=${Uri.encodeComponent(downloadPath)}&tabIndex=$index&currentListIndex=8',
          transition: TransitionType.inFromRight);
    }
  }

  @override
  void showUploadOptions(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
              child: Wrap(
            children: [
              ListTile(
                minLeadingWidth: 0,
                leading: const Icon(Icons.image_outlined, color: Colors.blue),
                title: const Text('上传照片'),
                onTap: () async {
                  Navigator.pop(context);
                  final List<AssetEntity>? pickedImage = await AssetPicker.pickAssets(context,
                      pickerConfig: const AssetPickerConfig(
                        maxAssets: 100,
                        selectedAssets: [],
                      ));
                  if (pickedImage == null) {
                    showToast('未选择图片');
                    return;
                  }
                  List<File> files = [];
                  for (var i = 0; i < pickedImage.length; i++) {
                    File? fileImage = await pickedImage[i].originFile;
                    if (fileImage != null) {
                      files.add(fileImage);
                    }
                  }
                  Map configMap = await manageAPI.getConfigMap();
                  for (int i = 0; i < files.length; i++) {
                    if (Global.isCompress == true) {
                      files[i] = await compressAndGetFile(
                          files[i].path, my_path.basename(files[i].path), Global.defaultCompressFormat,
                          minHeight: Global.minHeight, minWidth: Global.minWidth, quality: Global.quality);
                    }
                    List uploadList = [files[i].path, my_path.basename(files[i].path), configMap];
                    Global.smmsUploadList.add(jsonEncode(uploadList));
                  }
                  Global.smmsUploadList = removeDuplicates(Global.smmsUploadList);
                  Global.setSmmsUploadList(Global.smmsUploadList);
                  String downloadPath =
                      await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_DOWNLOAD);
                  if (mounted) {
                    Application.router
                        .navigateTo(context,
                            '/baseUpDownloadManagePage?downloadPath=${Uri.encodeComponent(downloadPath)}&tabIndex=0&currentListIndex=8',
                            transition: TransitionType.inFromRight)
                        .then((value) {
                      _getFileList();
                    });
                  }
                },
              ),
              ListTile(
                minLeadingWidth: 0,
                leading: const Icon(Icons.link, color: Colors.blue),
                title: const Text('上传剪贴板内链接(换行分隔多个)'),
                onTap: () async {
                  Navigator.pop(context);
                  var url = await flutter_services.Clipboard.getData('text/plain');
                  if (url == null || url.text == null || url.text!.isEmpty) {
                    if (mounted) {
                      showToastWithContext(context, '剪贴板为空');
                    }
                    return;
                  }
                  try {
                    String urlStr = url.text!;
                    List fileLinkList = urlStr.split("\n");
                    if (context.mounted) {
                      await showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) {
                            return NetLoadingDialog(
                              outsideDismiss: false,
                              loading: true,
                              loadingText: "上传中...",
                              requestCallBack: manageAPI.uploadNetworkFileEntry(
                                fileLinkList,
                              ),
                            );
                          });
                    }
                    _getFileList();
                    setState(() {});
                  } catch (e) {
                    flogErr(e, {'url': url}, "SmmsFileExplorerState", "uploadNetworkFileEntry");
                    if (mounted) {
                      showToastWithContext(context, '错误');
                    }
                    return;
                  }
                },
              ),
            ],
          ));
        });
  }

  @override
  Future<void> onDownloadButtonPressed() async {
    if (!selectedFilesBool.contains(true)) {
      return showToastWithContext(context, '没有选择文件');
    }
    List downloadList = [];
    for (int i = 0; i < allInfoList.length; i++) {
      if (selectedFilesBool[i]) {
        downloadList.add(allInfoList[i]);
        Global.smmsDownloadList.add(allInfoList[i]['url']);
        Global.smmsSavedNameList.add(allInfoList[i]['filename']);
      }
    }
    Global.smmsDownloadList = removeDuplicates(Global.smmsDownloadList);
    Global.smmsSavedNameList = removeDuplicates(Global.smmsSavedNameList);
    Global.setSmmsDownloadList(Global.smmsDownloadList);
    Global.setSmmsSavedNameList(Global.smmsSavedNameList);
    String downloadPath = await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_DOWNLOAD);
    if (mounted) {
      Application.router.navigateTo(context,
          '/baseUpDownloadManagePage?downloadPath=${Uri.encodeComponent(downloadPath)}&tabIndex=1&currentListIndex=8',
          transition: TransitionType.inFromRight);
    }
  }

  @override
  Future<void> onFileItemTap(int index) async {
    String urlList = allInfoList.map((info) => info['url']).join(',');
    Application.router.navigateTo(
        context, '${Routes.albumImagePreview}?index=$index&images=${Uri.encodeComponent(urlList)}',
        transition: TransitionType.none);
  }

  @override
  void onFileInfoTap(int index) {
    Application.router.navigateTo(
        context, '${Routes.smmsFileInformation}?fileMap=${Uri.encodeComponent(jsonEncode(allInfoList[index]))}',
        transition: TransitionType.cupertino);
  }
}
