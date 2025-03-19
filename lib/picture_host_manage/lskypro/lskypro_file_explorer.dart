import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:external_path/external_path.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/services.dart' as flutter_services;
import 'package:path/path.dart' as my_path;
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import 'package:horopic/picture_host_manage/manage_api/lskypro_manage_api.dart';
import 'package:horopic/widgets/net_loading_dialog.dart';
import 'package:horopic/utils/global.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/router/application.dart';
import 'package:horopic/router/routers.dart';
import 'package:horopic/picture_host_manage/common/loading_state.dart' as loading_state;
import 'package:horopic/utils/image_compressor.dart';
import 'package:horopic/picture_host_manage/common/base_file_explorer_page.dart';
import 'package:horopic/picture_host_manage/common/build_bottom_widget.dart';

class LskyproFileExplorer extends BaseFileExplorer {
  final Map userProfile;
  final Map albumInfo;
  const LskyproFileExplorer({
    super.key,
    required this.userProfile,
    required this.albumInfo,
  });

  @override
  LskyproFileExplorerState createState() => LskyproFileExplorerState();
}

class LskyproFileExplorerState extends BaseFileExplorerState<LskyproFileExplorer> {
  List fileAllInfoList = [];
  List dirAllInfoList = [];

  @override
  Future<void> initializeData() async {
    await _getFileList();
  }

  @override
  Future<void> refreshData() async {
    await _getFileList();
  }

  _getFileList() async {
    try {
      if (widget.userProfile['image_num'] == 0) {
        setState(() {
          state = loading_state.LoadState.empty;
        });
        return;
      }
      //主页模式
      if (widget.albumInfo.isEmpty) {
        //查询相册
        var albumResult = await LskyproManageAPI.getAlbums();
        if (albumResult[0] == 'success') {
          if (albumResult[1].length >= 1) {
            dirAllInfoList.clear();
            dirAllInfoList.addAll(albumResult[1]);
          } else {
            dirAllInfoList.clear();
          }
        } else {
          setState(() {
            state = loading_state.LoadState.error;
          });
          return;
        }
        //查询文件
        var fileResult = await LskyproManageAPI.getPhoto(null);
        if (fileResult[0] == 'success') {
          if (fileResult[1].length >= 1) {
            fileAllInfoList.clear();
            fileAllInfoList.addAll(fileResult[1]);
          } else {
            fileAllInfoList.clear();
          }
        } else {
          setState(() {
            state = loading_state.LoadState.error;
          });
          return;
        }
        //合并
        for (var i = 0; i < fileAllInfoList.length; i++) {
          fileAllInfoList[i]['date'] = DateTime.parse(
            fileAllInfoList[i]['date'],
          );
        }
        fileAllInfoList.sort((a, b) => b['date'].compareTo(a['date']));
        allInfoList.clear();
        allInfoList.addAll(dirAllInfoList);
        allInfoList.addAll(fileAllInfoList);
      } else {
        //相册内容模式
        dirAllInfoList.clear();
        var fileResult = await LskyproManageAPI.getPhoto(widget.albumInfo['id']);
        if (fileResult[0] == 'success') {
          if (fileResult[1].length >= 1) {
            fileAllInfoList.clear();
            fileAllInfoList.addAll(fileResult[1]);
          } else {
            fileAllInfoList.clear();
          }
        } else {
          setState(() {
            state = loading_state.LoadState.error;
          });
          return;
        }
        //合并
        for (var i = 0; i < fileAllInfoList.length; i++) {
          fileAllInfoList[i]['date'] = DateTime.parse(
            fileAllInfoList[i]['date'],
          );
        }
        fileAllInfoList.sort((a, b) => b['date'].compareTo(a['date']));
        allInfoList.clear();
        allInfoList.addAll(fileAllInfoList);
      }
      if (allInfoList.isEmpty) {
        if (mounted) {
          setState(() {
            state = loading_state.LoadState.empty;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            selectedFilesBool.clear();
            for (var i = 0; i < allInfoList.length; i++) {
              selectedFilesBool.add(false);
            }
            state = loading_state.LoadState.success;
          });
        }
      }
    } catch (e) {
      flogErr(e, {}, 'LskyproFileExplorerState', '_getFileList');
      state = loading_state.LoadState.error;
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  String getShareUrl(int index) => allInfoList[index]?['links']?['url'] ?? '';

  @override
  String getFileName(int index) => allInfoList[index]['name'];

  @override
  String getFileDate(int index) => allInfoList[index]['date'] == null
      ? ''
      : allInfoList[index]['date'].toString().replaceAll('T', ' ').replaceAll('Z', '').substring(0, 19);

  @override
  String? getFileSizeForList(int index) {
    if (index < dirAllInfoList.length) {
      return null;
    } else {
      return allInfoList[index]['size'] == null
          ? null
          : getFileSize(int.parse(allInfoList[index]['size'].toString().split('.')[0]) * 1024);
    }
  }

  @override
  Widget getThumbnailWidget(int index) {
    return index < dirAllInfoList.length
        ? Image.asset(
            'assets/icons/folder.png',
            width: 50,
            height: 50,
          )
        : super.getThumbnailWidget(index);
  }

  @override
  Future<void> deleteFiles(List<int> toDelete) async {
    try {
      for (int i = 0; i < toDelete.length; i++) {
        if ((toDelete[i] - i) < dirAllInfoList.length) {
          await LskyproManageAPI.deleteAlbum(allInfoList[toDelete[i] - i]['id'].toString());
          setState(() {
            allInfoList.removeAt(toDelete[i] - i);
            dirAllInfoList.removeAt(toDelete[i] - i);
            selectedFilesBool.removeAt(toDelete[i] - i);
          });
        } else {
          await LskyproManageAPI.deleteFile(allInfoList[toDelete[i] - i]['key']);
          setState(() {
            allInfoList.removeAt(toDelete[i] - i);
            fileAllInfoList.removeAt(toDelete[i] - i - dirAllInfoList.length);
            selectedFilesBool.removeAt(toDelete[i] - i);
          });
        }
      }
      if (allInfoList.isEmpty) {
        setState(() {
          state = loading_state.LoadState.empty;
        });
      }
    } catch (e) {
      flogErr(
          e,
          {
            'toDelete': toDelete,
          },
          'LskyproManagePage',
          'deleteAll');
      rethrow;
    }
  }

  @override
  DateTime getFormatedFileDate(dynamic item) {
    return DateTime.parse(item['date'] == null
        ? DateTime.now().toString()
        : item['date'].toString().replaceAll('T', ' ').replaceAll('Z', '').substring(0, 19));
  }

  @override
  String getFormatedFileName(dynamic item) {
    return item['name'];
  }

  @override
  int getFormatedSize(dynamic item) {
    return item['size'] == null ? 0 : int.parse(item['size'].toString().split('.')[0]) * 1024;
  }

  @override
  void sortListWithDirectories(int Function(dynamic a, dynamic b, bool ascending) comparator, bool ascending) {
    if (dirAllInfoList.isEmpty) {
      allInfoList.sort((a, b) => comparator(a, b, ascending));
    } else {
      List temp = allInfoList.sublist(dirAllInfoList.length, allInfoList.length);
      temp.sort((a, b) => comparator(a, b, ascending));
      allInfoList.clear();
      allInfoList.addAll(dirAllInfoList);
      allInfoList.addAll(temp);
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
                  AssetPickerConfig config = const AssetPickerConfig(
                    maxAssets: 100,
                    selectedAssets: [],
                  );
                  final List<AssetEntity>? pickedImage = await AssetPicker.pickAssets(context, pickerConfig: config);
                  if (pickedImage == null) {
                    return showToast('未选择图片');
                  }
                  List<File> files = [];
                  for (var i = 0; i < pickedImage.length; i++) {
                    File? fileImage = await pickedImage[i].originFile;
                    if (fileImage != null) {
                      files.add(fileImage);
                    }
                  }
                  Map configMap = await LskyproManageAPI.getConfigMap();
                  configMap['album_id'] = widget.albumInfo['id'] ?? 'None';
                  for (int i = 0; i < files.length; i++) {
                    if (Global.isCompress == true) {
                      files[i] = await compressAndGetFile(
                          files[i].path, my_path.basename(files[i].path), Global.defaultCompressFormat,
                          minHeight: Global.minHeight, minWidth: Global.minWidth, quality: Global.quality);
                    }
                    List uploadList = [
                      files[i].path,
                      my_path.basename(files[i].path),
                      configMap,
                    ];
                    String uploadListStr = jsonEncode(uploadList);
                    Global.lskyproUploadList.add(uploadListStr);
                  }
                  Global.setLskyproUploadList(Global.lskyproUploadList);
                  String downloadPath =
                      await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_DOWNLOAD);
                  if (mounted) {
                    String albumName = '';
                    if (widget.albumInfo.isEmpty) {
                      albumName = '其它';
                    } else {
                      albumName = widget.albumInfo['name'];
                    }
                    Application.router
                        .navigateTo(context,
                            '/baseUpDownloadManagePage?albumName=${Uri.encodeComponent(albumName)}&downloadPath=${Uri.encodeComponent(downloadPath)}&tabIndex=0&currentListIndex=6',
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
                              requestCallBack: LskyproManageAPI.uploadNetworkFileEntry(
                                fileLinkList,
                              ),
                            );
                          });
                    }
                    _getFileList();
                    setState(() {});
                  } catch (e) {
                    flogErr(
                        e,
                        {
                          'url': url,
                        },
                        'lskyproManagePage',
                        'uploadNetworkFileEntry');
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
  void navigateToDownloadManagement() async {
    String downloadPath = await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_DOWNLOAD);
    int index = 1;
    if (Global.lskyproDownloadList.isEmpty) {
      index = 0;
    }
    String albumName = '';
    if (widget.albumInfo.isEmpty) {
      albumName = '其它';
    } else {
      albumName = widget.albumInfo['name'];
    }
    if (mounted) {
      Application.router.navigateTo(context,
          '/baseUpDownloadManagePage?albumName=${Uri.encodeComponent(albumName)}&downloadPath=${Uri.encodeComponent(downloadPath)}&tabIndex=$index&currentListIndex=6',
          transition: TransitionType.inFromRight);
    }
  }

  @override
  Future<void> onDownloadButtonPressed() async {
    if (!selectedFilesBool.contains(true) || selectedFilesBool.isEmpty) {
      showToastWithContext(context, '没有选择文件');
      return;
    }
    List downloadList = [];
    for (int i = 0; i < allInfoList.length; i++) {
      if (selectedFilesBool[i] && i >= dirAllInfoList.length) {
        downloadList.add(allInfoList[i]);
      }
    }
    if (downloadList.isEmpty) {
      showToast('没有选择文件');
      return;
    }
    for (int i = 0; i < downloadList.length; i++) {
      Global.lskyproDownloadList.add(downloadList[i]['links']['url']);
    }
    String downloadPath = await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_DOWNLOAD);
    String albumName = '';
    if (widget.albumInfo.isEmpty) {
      albumName = '其它';
    } else {
      albumName = widget.albumInfo['name'];
    }
    if (mounted) {
      Application.router.navigateTo(context,
          '/baseUpDownloadManagePage?albumName=${Uri.encodeComponent(albumName)}&downloadPath=${Uri.encodeComponent(downloadPath)}&tabIndex=1&currentListIndex=6',
          transition: TransitionType.inFromRight);
    }
  }

  @override
  Future<void> onFileItemTap(int index) async {
    if (index < dirAllInfoList.length) {
      Application.router.navigateTo(context,
          '${Routes.lskyproFileExplorer}?userProfile=${Uri.encodeComponent(jsonEncode(widget.userProfile))}&albumInfo=${Uri.encodeComponent(jsonEncode(allInfoList[index]))}',
          transition: TransitionType.cupertino);
    } else {
      String urlList = '';
      //预览图片
      int newImageIndex = index - dirAllInfoList.length;
      for (int i = dirAllInfoList.length; i < allInfoList.length; i++) {
        urlList += '${allInfoList[i]['links']['url']},';
      }
      urlList = urlList.substring(0, urlList.length - 1);
      Application.router.navigateTo(
          context, '${Routes.albumImagePreview}?index=$newImageIndex&images=${Uri.encodeComponent(urlList)}',
          transition: TransitionType.none);
    }
  }

  @override
  Widget buildBottomSheetWidget(
    BuildContext context,
    int index,
  ) {
    return FileBottomSheetWidget(
        thumbnailWidget: getThumbnailWidget(index),
        fileName: getFileName(index),
        fileDate: getFileDate(index),
        actions: index < dirAllInfoList.length
            ? [
                BottomSheetAction(
                    icon: Icons.delete_outline,
                    iconColor: Color.fromARGB(255, 240, 85, 131),
                    title: '删除',
                    onTap: () async {
                      Navigator.pop(context);
                      showCupertinoAlertDialogWithConfirmFunc(
                          context: context,
                          title: '通知',
                          content: '确定要删除${allInfoList[index]['name']}吗?',
                          onConfirm: () async {
                            var result = await LskyproManageAPI.deleteAlbum(allInfoList[index]['id'].toString());
                            if (result[0] == 'success') {
                              showToast('删除成功');
                              setState(() {
                                allInfoList.removeAt(index);
                                dirAllInfoList.removeAt(index);
                                selectedFilesBool.removeAt(index);
                              });
                            } else {
                              showToast('删除失败');
                            }
                          });
                    })
              ]
            : [
                BottomSheetAction(
                    icon: Icons.info_outline_rounded,
                    iconColor: Color.fromARGB(255, 97, 141, 236),
                    title: '文件详情',
                    onTap: () async {
                      Navigator.pop(context);
                      Map fileMap = allInfoList[index];
                      fileMap['date'] = getFileDate(index);
                      Application.router.navigateTo(context,
                          '${Routes.lskyproFileInformation}?fileMap=${Uri.encodeComponent(jsonEncode(fileMap))}',
                          transition: TransitionType.cupertino);
                    }),
                BottomSheetAction(
                  icon: Icons.link_rounded,
                  iconColor: Color.fromARGB(255, 97, 141, 236),
                  title: '复制链接(设置中的默认格式)',
                  onTap: () async {
                    String shareUrl = getShareUrl(index);
                    String filename = my_path.basename(getFileName(index));
                    String formatedLink = getFormatedUrl(shareUrl, filename);
                    await flutter_services.Clipboard.setData(flutter_services.ClipboardData(text: formatedLink));
                    if (mounted) {
                      Navigator.pop(context);
                    }
                    showToast('复制成功');
                  },
                ),
                BottomSheetAction(
                  icon: Icons.delete_outline,
                  iconColor: Color.fromARGB(255, 240, 85, 131),
                  title: '删除',
                  onTap: () async {
                    Navigator.pop(context);
                    showCupertinoAlertDialogWithConfirmFunc(
                      context: context,
                      title: '通知',
                      content: '确定要删除${allInfoList[index]['name']}吗？',
                      onConfirm: () async {
                        var result = await LskyproManageAPI.deleteFile(allInfoList[index]['key']);
                        if (result[0] == 'success') {
                          showToast('删除成功');
                          setState(() {
                            allInfoList.removeAt(index);
                            selectedFilesBool.removeAt(index);
                          });
                        } else {
                          showToast('删除失败');
                        }
                      },
                    );
                  },
                )
              ]);
  }
}
