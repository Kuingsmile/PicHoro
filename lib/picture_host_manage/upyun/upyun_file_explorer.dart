import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' as flutter_services;
import 'package:external_path/external_path.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluro/fluro.dart';
import 'package:path/path.dart' as my_path;
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import 'package:horopic/router/application.dart';
import 'package:horopic/router/routers.dart';
import 'package:horopic/picture_host_manage/manage_api/upyun_manage_api.dart';
import 'package:horopic/picture_host_manage/common/loading_state.dart' as loading_state;
import 'package:horopic/utils/global.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/widgets/net_loading_dialog.dart';
import 'package:horopic/utils/image_compressor.dart';
import 'package:horopic/picture_host_manage/common/base_file_explorer_page.dart';
import 'package:horopic/picture_host_manage/common/build_bottom_widget.dart';
import 'package:horopic/picture_host_manage/common/new_folder_widgets.dart';
import 'package:horopic/picture_host_manage/common/rename_dialog_widgets.dart';

class UpyunFileExplorer extends BaseFileExplorer {
  final Map element;
  final String bucketPrefix;

  const UpyunFileExplorer({super.key, required this.element, required this.bucketPrefix});

  @override
  UpyunFileExplorerState createState() => UpyunFileExplorerState();
}

class UpyunFileExplorerState extends BaseFileExplorerState<UpyunFileExplorer> {
  TextEditingController vc = TextEditingController();
  TextEditingController newFolder = TextEditingController();
  TextEditingController fileLink = TextEditingController();

  UpyunManageAPI manageAPI = UpyunManageAPI();

  @override
  Future<void> initializeData() async {
    await _getBucketList();
  }

  @override
  Future<void> refreshData() async {
    await _getBucketList();
  }

  _getBucketList() async {
    var bucketFilesResponse = await manageAPI.queryBucketFiles(widget.element, widget.bucketPrefix);

    if (bucketFilesResponse[0] != 'success') {
      if (mounted) {
        setState(() {
          state = loading_state.LoadState.error;
        });
      }
      return;
    }
    List files = [];
    List dir = [];
    for (var item in bucketFilesResponse[1]) {
      (item['type'] == 'folder' ? dir : files).add(item);
    }
    fileAllInfoList = files.isEmpty ? [] : files.toList()
      ..sort((a, b) => b['last_modified'].compareTo(a['last_modified']));

    dirAllInfoList = dir.isEmpty ? [] : List.from(dir);
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
  Future<String> getShareUrl(int index) async =>
      '${widget.element['url']}/${widget.bucketPrefix}${allInfoList[index]['name']}';

  @override
  String getFileDate(int index) =>
      DateTime.fromMillisecondsSinceEpoch(allInfoList[index]['last_modified'] * 1000).toString().substring(0, 19);

  @override
  String? getFileSizeForList(int index) {
    int size = allInfoList[index]['length'] ?? 0;
    return size > 0 ? getFileSize(size) : null;
  }

  @override
  Future<void> onFileItemTap(int index) async {
    if (index < dirAllInfoList.length) {
      String prefix = '${widget.bucketPrefix}${allInfoList[index]['name']}/';
      Application.router.navigateTo(context,
          '${Routes.upyunFileExplorer}?element=${Uri.encodeComponent(jsonEncode(widget.element))}&bucketPrefix=${Uri.encodeComponent(prefix)}',
          transition: TransitionType.cupertino);
    } else {
      String urlList = '';

      //判断是否为图片
      if (!supportedExtensions(allInfoList[index]['name'].split('.').last)) {
        showToast('只支持图片文本和视频');
        return;
      }
      //预览图片
      if (Global.imgExt.contains(allInfoList[index]['name'].split('.').last.toLowerCase())) {
        int newImageIndex = index - dirAllInfoList.length;
        for (int i = dirAllInfoList.length; i < allInfoList.length; i++) {
          if (Global.imgExt.contains(allInfoList[i]['name'].split('.').last.toLowerCase())) {
            urlList += widget.element['url'] + widget.bucketPrefix + allInfoList[i]['name'] + ',';
          } else if (i < index) {
            newImageIndex--;
          }
        }
        urlList = urlList.substring(0, urlList.length - 1);

        Application.router.navigateTo(
            context, '${Routes.albumImagePreview}?index=$newImageIndex&images=${Uri.encodeComponent(urlList)}',
            transition: TransitionType.none);
      } else if (allInfoList[index]['name'].split('.').last.toLowerCase() == 'pdf') {
        //预览pdf
        String shareUrl = widget.element['url'] + widget.bucketPrefix + allInfoList[index]['name'];
        Map<String, dynamic> headers = {};
        Application.router.navigateTo(context,
            '${Routes.pdfViewer}?url=${Uri.encodeComponent(shareUrl)}&fileName=${Uri.encodeComponent(allInfoList[index]['name'])}&headers=${Uri.encodeComponent(jsonEncode(headers))}',
            transition: TransitionType.none);
      } else if (Global.textExt.contains(allInfoList[index]['name'].split('.').last.toLowerCase())) {
        String shareUrl = widget.element['url'] + widget.bucketPrefix + allInfoList[index]['name'];
        showToast('开始获取文件');
        String filePath = await downloadTxtFile(shareUrl, allInfoList[index]['name'], null);
        String fileName = allInfoList[index]['name'];
        if (filePath == 'error') {
          showToast('获取失败');
          return;
        }
        if (context.mounted) {
          Application.router.navigateTo(context,
              '${Routes.mdPreview}?filePath=${Uri.encodeComponent(filePath)}&fileName=${Uri.encodeComponent(fileName)}',
              transition: TransitionType.none);
        }
      }
    }
  }

  @override
  String getPageTitle() => widget.bucketPrefix == '/' ? '根目录' : widget.bucketPrefix;

  @override
  DateTime getFormatedFileDate(dynamic item) {
    return DateTime.parse(item['last_modified'].toString());
  }

  @override
  int getFormatedSize(dynamic item) {
    return item['length'] ?? 0;
  }

  Future<void> _processUploadFiles(List<File> files, bool isSkipImageCheck) async {
    Map configMap = {
      'bucket': widget.element['bucket'],
      'operator': widget.element['operator'],
      'password': widget.element['password'],
      'url': widget.element['url'],
      'path': widget.bucketPrefix,
    };
    for (int i = 0; i < files.length; i++) {
      if (isSkipImageCheck || Global.imgExt.contains(my_path.extension(files[i].path).toLowerCase().substring(1))) {
        if (Global.isCompress == true) {
          files[i] = await compressAndGetFile(
              files[i].path, my_path.basename(files[i].path), Global.defaultCompressFormat,
              minHeight: Global.minHeight, minWidth: Global.minWidth, quality: Global.quality);
        }
      }
      List uploadList = [files[i].path, my_path.basename(files[i].path), configMap];
      String uploadListStr = jsonEncode(uploadList);
      Global.upyunUploadList.add(uploadListStr);
    }
    Global.upyunUploadList = removeDuplicates(Global.upyunUploadList);
    Global.setUpyunUploadList(Global.upyunUploadList);
    String downloadPath = await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_DOWNLOAD);
    if (mounted) {
      Application.router
          .navigateTo(context,
              '/baseUpDownloadManagePage?bucketName=${widget.element['bucket']}&downloadPath=${Uri.encodeComponent(downloadPath)}&tabIndex=0&currentListIndex=10',
              transition: TransitionType.inFromRight)
          .then((value) {
        _getBucketList();
      });
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
                leading: const Icon(Icons.file_present_outlined, color: Colors.blue),
                title: const Text('上传文件'),
                onTap: () async {
                  Navigator.pop(context);
                  FilePickerResult? pickresult = await FilePicker.platform.pickFiles(
                    allowMultiple: true,
                  );
                  if (pickresult == null) {
                    return showToast('未选择文件');
                  }
                  List<File> files = pickresult.paths.map((path) => File(path!)).toList();
                  await _processUploadFiles(files, false);
                },
              ),
              ListTile(
                minLeadingWidth: 0,
                leading: const Icon(Icons.image_outlined, color: Colors.blue),
                title: const Text('上传照片(可多选)'),
                onTap: () async {
                  Navigator.pop(context);
                  AssetPickerConfig config = const AssetPickerConfig(
                    maxAssets: 100,
                    selectedAssets: [],
                  );
                  final List<AssetEntity>? pickedImage = await AssetPicker.pickAssets(context, pickerConfig: config);
                  if (pickedImage == null) {
                    showToast('未选择照片');
                  } else {
                    List<File> files = [];
                    for (var i = 0; i < pickedImage.length; i++) {
                      File? fileImage = await pickedImage[i].originFile;
                      if (fileImage != null) {
                        files.add(fileImage);
                      }
                    }
                    await _processUploadFiles(files, true);
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
                      showToastWithContext(context, "剪贴板为空");
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
                              requestCallBack:
                                  manageAPI.uploadNetworkFileEntry(fileLinkList, widget.element, widget.bucketPrefix),
                            );
                          });
                    }
                    _getBucketList();
                  } catch (e) {
                    flogErr(
                      e,
                      {
                        'url': url.text,
                      },
                      'UpyunFileExplorerState',
                      'uploadNetworkFileEntry',
                    );
                    if (mounted) {
                      showToastWithContext(context, "错误");
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
                title: const Text('新建文件夹'),
                onTap: () async {
                  Navigator.pop(context);
                  showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (context) {
                        return NewFolderDialog(
                          contentWidget: NewFolderDialogContent(
                            title: "文件夹名 / 分隔",
                            onConfirm: () async {
                              String newName = newFolder.text;
                              if (newName.isEmpty) {
                                return showToastWithContext(context, "文件夹名不能为空");
                              }
                              var copyResult =
                                  await manageAPI.createFolder(widget.element, widget.bucketPrefix, newName);
                              if (copyResult[0] == 'success') {
                                showToast('创建成功');
                                _getBucketList();
                              } else {
                                showToast('创建失败');
                              }
                              setState(() {});
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
    String hostPrefix = widget.element['url'];
    String bucketPrefix = widget.bucketPrefix;

    List<String> urlList = [];
    for (int i = 0; i < downloadList.length; i++) {
      urlList.add(hostPrefix + bucketPrefix + downloadList[i]['name']);
    }
    Global.upyunDownloadList.addAll(urlList);
    Global.upyunDownloadList = removeDuplicates(Global.upyunDownloadList);
    Global.setUpyunDownloadList(Global.upyunDownloadList);
    String downloadPath = await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_DOWNLOAD);
    Application.router.navigateTo(context,
        '/baseUpDownloadManagePage?bucketName=${widget.element['bucket']}&downloadPath=${Uri.encodeComponent(downloadPath)}&tabIndex=1&currentListIndex=10',
        transition: TransitionType.inFromRight);
  }

  @override
  void navigateToDownloadManagement() async {
    String downloadPath = await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_DOWNLOAD);
    int index = Global.upyunDownloadList.isEmpty ? 0 : 1;
    if (mounted) {
      Application.router
          .navigateTo(context,
              '/baseUpDownloadManagePage?bucketName=${widget.element['bucket']}&downloadPath=${Uri.encodeComponent(downloadPath)}&tabIndex=$index&currentListIndex=10',
              transition: TransitionType.inFromRight)
          .then((value) {
        _getBucketList();
      });
    }
  }

  @override
  Future<void> deleteFiles(List<int> toDelete) async {
    toDelete.sort((a, b) => b.compareTo(a));
    for (int index in toDelete) {
      var result = index < dirAllInfoList.length
          ? await manageAPI.deleteFolder(widget.element, '${widget.bucketPrefix}${allInfoList[index]['name']}')
          : await manageAPI.deleteFile(widget.element, widget.bucketPrefix, allInfoList[index]['name']);
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
  void onFileInfoTap(int index) {
    Application.router.navigateTo(
        context, '${Routes.upyunFileInformationPage}?fileMap=${Uri.encodeComponent(jsonEncode(allInfoList[index]))}',
        transition: TransitionType.cupertino);
  }

  @override
  List<BottomSheetAction> getExtraActions(int index) {
    return [
      if (index < dirAllInfoList.length)
        BottomSheetAction(
          icon: Icons.delete_outline,
          iconColor: Color.fromARGB(255, 97, 141, 236),
          title: '设为图床默认目录',
          onTap: () async {
            String fullPath = widget.bucketPrefix != '/' ? widget.bucketPrefix + allInfoList[index]['name'] : '';
            var result = await manageAPI.setDefaultBucket(widget.element, fullPath);
            if (result[0] == 'success') {
              showToast('设置成功');
              if (mounted) {
                Navigator.pop(context);
              }
            } else {
              showToast('设置失败');
            }
          },
        ),
      if (index >= dirAllInfoList.length)
        BottomSheetAction(
          icon: Icons.edit_note_rounded,
          iconColor: const Color.fromARGB(255, 76, 175, 80),
          title: '重命名',
          onTap: () {
            Navigator.pop(context);
            showDialog(
                barrierDismissible: true,
                context: context,
                builder: (context) {
                  return RenameDialog(
                    contentWidget: RenameDialogContent(
                      title: "新文件名",
                      onConfirm: (bool isCoverFile) async {
                        String newName = vc.text;
                        if (isCoverFile) {
                          var copyResult = await manageAPI.renameFile(
                              widget.element, widget.bucketPrefix, allInfoList[index]['name'], newName);
                          if (copyResult[0] == 'success') {
                            showToast('重命名成功');
                            _getBucketList();
                          } else {
                            showToast('重命名失败');
                          }
                          return;
                        }
                        var checkDuplicate =
                            await manageAPI.queryDuplicateName(widget.element, widget.bucketPrefix, vc.text);
                        if (checkDuplicate[0] == 'duplicate' || checkDuplicate[0] == 'error') {
                          return showToast('文件名重复');
                        }
                        var copyResult = await manageAPI.renameFile(
                            widget.element, widget.bucketPrefix, allInfoList[index]['name'], newName);
                        if (copyResult[0] == 'success') {
                          showToast('重命名成功');
                          _getBucketList();
                        } else {
                          showToast('重命名失败');
                        }
                      },
                      renameTextController: vc,
                      onCancel: () {},
                      isShowCoverFileWidget: true,
                    ),
                  );
                });
          },
        ),
    ];
  }
}
