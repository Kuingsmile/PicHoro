import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' as flutter_services;

import 'package:external_path/external_path.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluro/fluro.dart';

import 'package:intl/intl.dart';
import 'package:path/path.dart' as my_path;
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import 'package:horopic/picture_host_manage/common/base_file_explorer_page.dart';
import 'package:horopic/picture_host_manage/common/build_bottom_widget.dart';
import 'package:horopic/router/application.dart';
import 'package:horopic/router/routers.dart';
import 'package:horopic/picture_host_manage/manage_api/alist_manage_api.dart';
import 'package:horopic/picture_host_manage/common/loading_state.dart' as loading_state;
import 'package:horopic/utils/global.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/widgets/net_loading_dialog.dart';
import 'package:horopic/utils/image_compressor.dart';
import 'package:horopic/picture_host_manage/common/new_folder_widgets.dart';
import 'package:horopic/picture_host_manage/common/rename_dialog_widgets.dart';

class AlistFileExplorer extends BaseFileExplorer {
  /// alist图床设置
  final Map configMap;

  /// 当前图床信息
  final Map currentStorageInfoMap;
  final String bucketPrefix;
  final String refresh;

  const AlistFileExplorer(
      {super.key,
      required this.currentStorageInfoMap,
      required this.bucketPrefix,
      required this.refresh,
      required this.configMap});

  @override
  AlistFileExplorerState createState() => AlistFileExplorerState();
}

class AlistFileExplorerState extends BaseFileExplorerState<AlistFileExplorer> {
  List fileAllInfoList = [];
  TextEditingController vc = TextEditingController();
  TextEditingController newFolder = TextEditingController();
  TextEditingController fileLink = TextEditingController();

  AlistManageAPI manageAPI = AlistManageAPI();

  @override
  Future<void> initializeData() async {
    await _getBucketList();
  }

  @override
  Future<void> refreshData() async {
    await _getBucketList();
  }

  Future<void> _getBucketList() async {
    var fetchedFolderData = await manageAPI.listFolder(
      widget.bucketPrefix,
      widget.refresh,
    );

    if (fetchedFolderData[0] != 'success') {
      if (mounted) {
        setState(() {
          state = loading_state.LoadState.error;
        });
      }
      return;
    }

    var files = <Map>[];
    var dir = <Map>[];
    for (var item in fetchedFolderData[1]) {
      (item['is_dir'] ? dir : files).add(item);
    }
    fileAllInfoList = files.isEmpty
        ? []
        : files.map((element) {
            var file = Map.from(element);
            file['modified'] = DateTime.parse(file['modified']);
            return file;
          }).toList()
      ..sort((a, b) => b['modified'].compareTo(a['modified']));

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
  String getShareUrl(int index) {
    final isDirectory = index < dirAllInfoList.length;
    final fileName = isDirectory ? dirAllInfoList[index]['name'] : allInfoList[index]['name'];
    final baseUrl = widget.configMap['host'];
    final path = isDirectory ? '$baseUrl${widget.bucketPrefix}$fileName' : '$baseUrl/d${widget.bucketPrefix}$fileName';
    if (!isDirectory && allInfoList[index]['sign'] != null && allInfoList[index]['sign'].isNotEmpty) {
      return '$path?sign=${allInfoList[index]['sign']}';
    }

    return path;
  }

  @override
  String getFileDate(int index) {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(allInfoList[index]['modified'].toString() != 'null'
        ? DateTime.parse(allInfoList[index]['modified'].toString())
        : DateTime.now());
  }

  @override
  Future<void> onFileItemTap(int index) async {
    if (index < dirAllInfoList.length) {
      String prefix = '${widget.bucketPrefix}${allInfoList[index]['name']}/';
      Application.router.navigateTo(context,
          '${Routes.alistFileExplorer}?currentStorageInfoMap=${Uri.encodeComponent(jsonEncode(widget.currentStorageInfoMap))}&bucketPrefix=${Uri.encodeComponent(prefix)}&refresh=${Uri.encodeComponent(widget.refresh)}&configMap=${Uri.encodeComponent(jsonEncode(widget.configMap))}',
          transition: TransitionType.cupertino);
    } else {
      String urlList = '';
      //判断是否为支持的格式
      String fileExt = allInfoList[index]['name'].split('.').last.toLowerCase();
      if (!supportedExtensions(fileExt)) {
        showToast('只支持图片文本和pdf格式');
        return;
      }
      //预览图片
      if (Global.imgExt.contains(fileExt)) {
        String shareUrl = '';
        int newImageIndex = index - dirAllInfoList.length;
        for (int i = dirAllInfoList.length; i < allInfoList.length; i++) {
          if (Global.imgExt.contains(allInfoList[i]['name'].split('.').last.toLowerCase())) {
            shareUrl = getShareUrl(i);
            urlList += '$shareUrl,';
          } else if (i < index) {
            newImageIndex--;
          }
        }
        urlList = urlList.substring(0, urlList.length - 1);
        if (context.mounted) {
          Application.router.navigateTo(
              context, '${Routes.albumImagePreview}?index=$newImageIndex&images=${Uri.encodeComponent(urlList)}',
              transition: TransitionType.none);
        }
      } else if (fileExt == 'pdf') {
        if (context.mounted) {
          Application.router.navigateTo(context,
              '${Routes.pdfViewer}?url=${Uri.encodeComponent(getShareUrl(index))}&fileName=${Uri.encodeComponent(allInfoList[index]['name'])}&headers=${Uri.encodeComponent(jsonEncode({}))}',
              transition: TransitionType.none);
        }
      } else if (Global.textExt.contains(fileExt)) {
        String shareUrl = getShareUrl(index);
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

  Future<void> _processUploadFiles(List<File> files, bool isSkipImageCheck) async {
    Map configMap = await manageAPI.getConfigMap();
    configMap['uploadPath'] = widget.bucketPrefix == "/" ? "None" : widget.bucketPrefix;

    for (int i = 0; i < files.length; i++) {
      if (isSkipImageCheck || Global.imgExt.contains(my_path.extension(files[i].path).toLowerCase().substring(1))) {
        if (Global.isCompress == true) {
          files[i] = await compressAndGetFile(
              files[i].path, my_path.basename(files[i].path), Global.defaultCompressFormat,
              minHeight: Global.minHeight, minWidth: Global.minWidth, quality: Global.quality);
        }
      }
      List uploadList = [files[i].path, my_path.basename(files[i].path), configMap];
      Global.alistUploadList.add(jsonEncode(uploadList));
    }
    Global.alistUploadList = removeDuplicates(Global.alistUploadList);
    Global.setAlistUploadList(Global.alistUploadList);
    String downloadPath = await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_DOWNLOAD);

    if (mounted) {
      Application.router
          .navigateTo(context,
              '/baseUpDownloadManagePage?bucketName=${Uri.encodeComponent('Alist_${widget.currentStorageInfoMap['mount_path'].split('/').last}')}&downloadPath=${Uri.encodeComponent(downloadPath)}&tabIndex=0&currentListIndex=0',
              transition: TransitionType.inFromRight)
          .then((value) {
        _getBucketList();
      });
    }
  }

  @override
  String getPageTitle() => widget.bucketPrefix == '/'
      ? '根目录'
      : widget.bucketPrefix.substring(0, widget.bucketPrefix.length - 1).split('/').last;

  @override
  DateTime getFormatedFileDate(dynamic item) {
    return DateTime.parse(item['modified'].toString());
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
                title: const Text('上传照片'),
                onTap: () async {
                  Navigator.pop(context);
                  final List<AssetEntity>? pickedImage = await AssetPicker.pickAssets(context,
                      pickerConfig: const AssetPickerConfig(
                        maxAssets: 100,
                        selectedAssets: [],
                      ));

                  if (pickedImage == null) {
                    return showToast('未选择照片');
                  }
                  List<File> files = [];
                  for (var i = 0; i < pickedImage.length; i++) {
                    File? fileImage = await pickedImage[i].originFile;
                    if (fileImage != null) {
                      files.add(fileImage);
                    }
                  }
                  await _processUploadFiles(files, true);
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
                              requestCallBack: manageAPI.uploadNetworkFileEntry(
                                  fileLinkList, widget.bucketPrefix == "/" ? "None" : widget.bucketPrefix),
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
                        'AlistManagePage',
                        'uploadNetworkFileEntry');
                    if (mounted) {
                      showToastWithContext(context, "错误");
                    }
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
                            title: "新文件夹名",
                            onConfirm: () async {
                              String newName = newFolder.text;
                              if (newName.isEmpty) {
                                return showToastWithContext(context, "文件夹名不能为空");
                              }
                              if (newName.startsWith('/')) {
                                newName = newName.substring(1);
                              }
                              if (newName.endsWith('/')) {
                                newName = newName.substring(0, newName.length - 1);
                              }
                              var copyResult = await manageAPI.mkDir(widget.bucketPrefix + newName);
                              if (copyResult[0] == 'success') {
                                showToast('创建成功');
                                _getBucketList();
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
  void navigateToDownloadManagement() async {
    String downloadPath = await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_DOWNLOAD);
    final int index = Global.alistDownloadList.isEmpty ? 0 : 1;
    if (mounted) {
      Application.router
          .navigateTo(context,
              '/baseUpDownloadManagePage?bucketName=${Uri.encodeComponent('Alist_${widget.currentStorageInfoMap['mount_path'].split('/').last}')}&downloadPath=${Uri.encodeComponent(downloadPath)}&tabIndex=$index&currentListIndex=0',
              transition: TransitionType.inFromRight)
          .then((value) {
        _getBucketList();
      });
    }
  }

  @override
  Future<void> onDownloadButtonPressed() async {
    if (!selectedFilesBool.contains(true)) {
      return showToastWithContext(context, '没有选择文件');
    }

    final downloadList = <Map>[];
    for (int i = 0; i < allInfoList.length; i++) {
      if (selectedFilesBool[i] && i >= dirAllInfoList.length) {
        downloadList.add(allInfoList[i]);
      }
    }
    if (downloadList.isEmpty) {
      return showToast('没有选择文件');
    }
    showToast('开始解析下载地址');
    Map configMap = await manageAPI.getConfigMap();
    final urlList = <String>[];

    for (final fileInfo in downloadList) {
      final fileName = fileInfo['name'];
      String shareUrl;
      var res = await manageAPI.getFileInfo(
        widget.bucketPrefix + fileName,
      );
      if (res[0] == 'success') {
        if (res[1]['raw_url'] != "" && res[1]['raw_url'] != null) {
          shareUrl = res[1]['raw_url'];
        } else {
          shareUrl = '${configMap['host']}/d${widget.bucketPrefix}$fileName';
          if (res[1]['sign'] != null && res[1]['sign'].isNotEmpty) {
            shareUrl += '?sign=${res[1]['sign']}';
          }
        }
      } else {
        shareUrl = '${configMap['host']}/d${widget.bucketPrefix}$fileName';
        if (fileInfo['sign'] != null && fileInfo['sign'].isNotEmpty) {
          shareUrl += '?sign=${fileInfo['sign']}';
        }
      }

      Map downloadMap = Map.from(widget.currentStorageInfoMap);

      urlList.add(jsonEncode([
        shareUrl,
        fileName,
        downloadMap,
      ]));
    }

    Global.alistDownloadList.addAll(urlList);
    Global.alistDownloadList = removeDuplicates(Global.alistDownloadList);
    Global.setAlistDownloadList(Global.alistDownloadList);
    String downloadPath = await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_DOWNLOAD);
    final bucketName = 'Alist_${widget.currentStorageInfoMap['mount_path'].split('/').last}';

    Application.router.navigateTo(context,
        '/baseUpDownloadManagePage?bucketName=${Uri.encodeComponent(bucketName)}&downloadPath=${Uri.encodeComponent(downloadPath)}&tabIndex=1&currentListIndex=0',
        transition: TransitionType.inFromRight);
  }

  @override
  Future<void> deleteFiles(List<int> toDelete) async {
    toDelete.sort((a, b) => b.compareTo(a));
    for (int index in toDelete) {
      String fileName = allInfoList[index]['name'];
      var result = await manageAPI.remove(widget.bucketPrefix, [fileName]);
      if (result[0] != 'success') {
        throw Exception(result[0]);
      }
      setState(() {
        allInfoList.removeAt(index);
        selectedFilesBool.removeAt(index);
        if (index < dirAllInfoList.length) {
          dirAllInfoList.removeAt(index);
        }
      });
    }
    if (allInfoList.isEmpty) {
      setState(() {
        state = loading_state.LoadState.empty;
      });
    }
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
            String path = widget.bucketPrefix + allInfoList[index]['name'];
            var result = await manageAPI.setDefaultBucket(path);
            if (result[0] != 'success') {
              showToast('设置失败');
              return;
            }
            showToast('设置成功');
            if (mounted) {
              Navigator.pop(context);
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
                barrierDismissible: false,
                context: context,
                builder: (context) {
                  return RenameDialog(
                    contentWidget: RenameDialogContent(
                      title: "新文件名",
                      onConfirm: (bool isCoverFile) async {
                        var renameResult =
                            await manageAPI.rename(widget.bucketPrefix + allInfoList[index]['name'], vc.text);
                        if (renameResult[0] == 'success') {
                          showToast('重命名成功');
                          _getBucketList();
                        } else {
                          showToast('重命名失败');
                        }
                      },
                      renameTextController: vc,
                      onCancel: () {},
                    ),
                  );
                });
          },
        )
    ];
  }

  @override
  void onFileInfoTap(int index) {
    Map fileMap = allInfoList[index];
    fileMap['fullPath'] = widget.bucketPrefix + fileMap['name'];
    fileMap['modified'] = fileMap['modified'].toString().replaceAll('T', ' ').replaceAll('Z', '');

    Application.router.navigateTo(
        context, '${Routes.alistFileInformation}?fileMap=${Uri.encodeComponent(jsonEncode(fileMap))}',
        transition: TransitionType.cupertino);
  }
}
