import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:external_path/external_path.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/services.dart' as flutter_services;
import 'package:path/path.dart' as my_path;
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import 'package:horopic/picture_host_manage/manage_api/imgur_manage_api.dart';
import 'package:horopic/widgets/net_loading_dialog.dart';
import 'package:horopic/utils/global.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/router/application.dart';
import 'package:horopic/router/routers.dart';
import 'package:horopic/picture_host_manage/common/loading_state.dart' as loading_state;
import 'package:horopic/utils/image_compressor.dart';
import 'package:horopic/picture_host_manage/common/new_folder_widgets.dart';
import 'package:horopic/picture_host_manage/common/base_file_explorer_page.dart';

class ImgurFileExplorer extends BaseFileExplorer {
  final Map userProfile;
  final Map albumInfo;
  final List allImages;
  const ImgurFileExplorer({
    super.key,
    required this.userProfile,
    required this.albumInfo,
    required this.allImages,
  });

  @override
  ImgurFileExplorerState createState() => ImgurFileExplorerState();
}

class ImgurFileExplorerState extends BaseFileExplorerState<ImgurFileExplorer> {
  TextEditingController newFolder = TextEditingController();

  ImgurManageAPI manageAPI = ImgurManageAPI();

  @override
  Future<void> initializeData() async {
    await _getFileList();
  }

  @override
  Future<void> refreshData() async {
    await _getFileList();
  }

  _getFileList() async {
    //主页模式
    if (widget.albumInfo.isEmpty) {
      //查询相册
      var albumResult = await manageAPI.getAlbumList(
        widget.userProfile['imguruser'],
        widget.userProfile['accesstoken'],
        widget.userProfile['proxy'],
      );
      if (albumResult[0] != 'success') {
        setState(() {
          state = loading_state.LoadState.error;
        });
        return;
      }
      dirAllInfoList.clear();
      if (albumResult[1].length >= 1) {
        for (int i = 0; i < albumResult[1].length; i++) {
          var albumInforesult = await manageAPI.getAlbumInfo(
            widget.userProfile['clientid'],
            albumResult[1][i],
            widget.userProfile['proxy'],
          );
          if (albumInforesult[0] != 'success') {
            setState(() {
              state = loading_state.LoadState.error;
            });
            return;
          }
          dirAllInfoList.add(albumInforesult[1]);
        }
      }

      //查询文件
      var fileResult = await manageAPI.getNotInAlbumImages(
        widget.userProfile['imguruser'],
        widget.userProfile['accesstoken'],
        widget.userProfile['clientid'],
        widget.userProfile['proxy'],
      );
      if (fileResult[0] != 'success') {
        setState(() {
          state = loading_state.LoadState.error;
        });
        return;
      }

      widget.allImages.clear();
      widget.allImages.addAll(fileResult[2]);

      fileAllInfoList.clear();
      if (fileResult[1].length >= 1) {
        fileAllInfoList.addAll(fileResult[1]);
      }
    } else {
      //相册内容模式
      dirAllInfoList.clear();
      var fileResult = await manageAPI.getAlbumImages(
        widget.userProfile['clientid'],
        widget.albumInfo['id'],
        widget.userProfile['proxy'],
      );
      if (fileResult[0] != 'success') {
        setState(() {
          state = loading_state.LoadState.error;
        });
        return;
      }
      fileAllInfoList.clear();
      if (fileResult[1] != null && fileResult[1].length >= 1) {
        fileAllInfoList.addAll(fileResult[1]);
      }
    }
    fileAllInfoList.sort((a, b) => b['datetime'].compareTo(a['datetime']));
    allInfoList = [...dirAllInfoList, ...fileAllInfoList];
    if (mounted) {
      setState(() {
        if (allInfoList.isEmpty) {
          state = loading_state.LoadState.empty;
        } else {
          selectedFilesBool = List.filled(allInfoList.length, false, growable: true);
          state = loading_state.LoadState.success;
        }
      });
    }
  }

  @override
  Future<String> getShareUrl(int index) async => allInfoList[index]['link'] ?? '';

  @override
  String getFileDate(int index) {
    return allInfoList[index]['datetime'] == null
        ? ''
        : DateTime.fromMillisecondsSinceEpoch(allInfoList[index]['datetime'] * 1000).toString().substring(0, 19);
  }

  @override
  String getFileName(int index) {
    if (index < dirAllInfoList.length) {
      return allInfoList[index]['title'] ?? '相册';
    } else {
      String fileName = allInfoList[index]['id'].toString();
      if (allInfoList[index]['link'] != null) {
        fileName = '$fileName.${allInfoList[index]['link'].split('.').last}';
      }
      return fileName;
    }
  }

  @override
  String? getFileSizeForList(int index) {
    int size = allInfoList[index]['size'] ?? 0;
    return size > 0 ? getFileSize(int.parse(allInfoList[index]['size'].toString().split('.')[0])) : null;
  }

  @override
  Future<void> onFileItemTap(int index) async {
    if (index < dirAllInfoList.length) {
      Application.router.navigateTo(context,
          '${Routes.imgurFileExplorer}?userProfile=${Uri.encodeComponent(jsonEncode(widget.userProfile))}&albumInfo=${Uri.encodeComponent(jsonEncode(allInfoList[index]))}&allImages=${Uri.encodeComponent(jsonEncode(widget.allImages))}',
          transition: TransitionType.cupertino);
    } else {
      String urlList = '';
      //预览图片
      if (Global.imgExt.contains(allInfoList[index]['link'].split('.').last.toLowerCase())) {
        int newImageIndex = index - dirAllInfoList.length;
        for (int i = dirAllInfoList.length; i < allInfoList.length; i++) {
          urlList += '${allInfoList[i]['link']},';
        }
        urlList = urlList.substring(0, urlList.length - 1);
        Application.router.navigateTo(
            context, '${Routes.albumImagePreview}?index=$newImageIndex&images=${Uri.encodeComponent(urlList)}',
            transition: TransitionType.none);
      }
    }
  }

  @override
  Future<void> deleteFiles(List<int> toDelete) async {
    toDelete.sort((a, b) => b.compareTo(a));
    for (int index in toDelete) {
      var result = index < dirAllInfoList.length
          ? await manageAPI.deleteAlbum(
              widget.userProfile['accesstoken'],
              allInfoList[index]['id'].toString(),
              widget.userProfile['proxy'],
            )
          : await manageAPI.deleteImage(
              widget.userProfile['accesstoken'],
              allInfoList[index]['id'],
              widget.userProfile['proxy'],
            );
      if (result[0] != 'success') {
        throw Exception(result[0]);
      }
      setState(() {
        allInfoList.removeAt(index);
        if (index < dirAllInfoList.length) {
          dirAllInfoList.removeAt(index);
        } else {
          fileAllInfoList.removeAt(index - dirAllInfoList.length);
        }
        selectedFilesBool.removeAt(index);
      });
    }
    if (allInfoList.isEmpty) {
      setState(() {
        state = loading_state.LoadState.empty;
      });
    }
  }

  @override
  List<Widget> getExtraAppBarActions() {
    return [
      IconButton(
        onPressed: () async {
          await Application.router
              .navigateTo(context, Routes.imgurTokenManagePage, transition: TransitionType.cupertino);
        },
        icon: const Icon(Icons.perm_identity, color: Colors.white),
        iconSize: 30,
      ),
    ];
  }

  @override
  String getPageTitle() => widget.albumInfo.isEmpty ? '文件' : widget.albumInfo['title'];

  @override
  DateTime getFormatedFileDate(dynamic item) {
    return DateTime.fromMillisecondsSinceEpoch(item['datetime'] * 1000);
  }

  @override
  int getFormatedSize(dynamic item) {
    return int.parse((item['size'] ?? 0).toString().split('.')[0]);
  }

  @override
  String getFormatedFileName(dynamic item) => item['id'] ?? '';

  @override
  String getFormatedExtension(dynamic item) {
    String fileName = item['link'] ?? '';
    return fileName.split('.').last;
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
                    showToast('未选择图片');
                  } else {
                    List<File> files = [];
                    for (var i = 0; i < pickedImage.length; i++) {
                      File? fileImage = await pickedImage[i].originFile;
                      if (fileImage != null) {
                        files.add(fileImage);
                      }
                    }
                    Map configMap = widget.userProfile;
                    configMap['albumhash'] = widget.albumInfo['id'] ?? 'None';
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
                      Global.imgurUploadList.add(jsonEncode(uploadList));
                    }
                    Global.imgurUploadList = removeDuplicates(Global.imgurUploadList);
                    Global.setImgurUploadList(Global.imgurUploadList);
                    String downloadPath =
                        await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_DOWNLOAD);
                    if (mounted) {
                      String albumName = widget.albumInfo.isEmpty ? '其它' : widget.albumInfo['title'];
                      Application.router
                          .navigateTo(context,
                              '/baseUpDownloadManagePage?albumName=${Uri.encodeComponent(albumName)}&downloadPath=${Uri.encodeComponent(downloadPath)}&tabIndex=0&currentListIndex=5',
                              transition: TransitionType.inFromRight)
                          .then((value) {
                        _getFileList();
                      });
                    }
                  }
                },
              ),
              ListTile(
                minLeadingWidth: 0,
                leading: const Icon(Icons.link, color: Colors.blue),
                title: const Text('上传剪贴板链接'),
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
                                  widget.userProfile['accesstoken'],
                                  widget.albumInfo['id'] ?? 'None',
                                  widget.userProfile['proxy']),
                            );
                          });
                    }
                    _getFileList();
                    setState(() {});
                  } catch (e) {
                    flogErr(
                      e,
                      {
                        'url': url.text,
                      },
                      'ImgurFileExplorerState',
                      'uploadNetworkFileEntry',
                    );
                    if (mounted) {
                      showToastWithContext(context, '错误');
                    }
                    return;
                  }
                },
              ),
              ListTile(
                minLeadingWidth: 0,
                leading: const Icon(
                  Icons.folder_open_outlined,
                  color: Colors.blue,
                ),
                title: const Text('新建相册'),
                onTap: () async {
                  Navigator.pop(context);
                  showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (context) {
                        return NewFolderDialog(
                          contentWidget: NewFolderDialogContent(
                            title: "输入相册名",
                            onConfirm: () async {
                              String newName = newFolder.text;
                              if (newName.isEmpty) {
                                showToastWithContext(context, "相册名不能为空");
                                return;
                              }
                              var copyResult = await manageAPI.createAlbum(
                                  widget.userProfile['accesstoken'], newName, widget.userProfile['proxy']);
                              if (copyResult[0] == 'success') {
                                showToast('创建成功');
                                _getFileList();
                              } else {
                                showToast('创建失败');
                              }
                            },
                            folderNameController: newFolder,
                            onCancel: () {},
                          ),
                        );
                      });
                },
              ),
            ],
          ));
        });
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
      Global.imgurDownloadList.add('${downloadList[i]['link']}');
    }
    Global.imgurDownloadList = removeDuplicates(Global.imgurDownloadList);
    Global.setImgurDownloadList(Global.imgurDownloadList);
    String downloadPath = await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_DOWNLOAD);
    String albumName = '';
    if (widget.albumInfo.isEmpty) {
      albumName = '其它';
    } else {
      albumName = widget.albumInfo['title'];
    }
    if (mounted) {
      Application.router.navigateTo(context,
          '/baseUpDownloadManagePage?albumName=${Uri.encodeComponent(albumName)}&downloadPath=${Uri.encodeComponent(downloadPath)}&tabIndex=1&currentListIndex=5',
          transition: TransitionType.inFromRight);
    }
  }

  @override
  void navigateToDownloadManagement() async {
    String downloadPath = await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_DOWNLOAD);
    int index = Global.imgurDownloadList.isEmpty ? 0 : 1;
    String albumName = widget.albumInfo.isEmpty ? '其它' : widget.albumInfo['title'];
    if (mounted) {
      Application.router.navigateTo(context,
          '/baseUpDownloadManagePage?albumName=${Uri.encodeComponent(albumName)}&downloadPath=${Uri.encodeComponent(downloadPath)}&tabIndex=$index&currentListIndex=5',
          transition: TransitionType.inFromRight);
    }
  }

  @override
  void onFileInfoTap(int index) {
    Map fileMap = allInfoList[index];
    Application.router.navigateTo(
        context, '${Routes.imgurFileInformation}?fileMap=${Uri.encodeComponent(jsonEncode(fileMap))}',
        transition: TransitionType.cupertino);
  }
}
