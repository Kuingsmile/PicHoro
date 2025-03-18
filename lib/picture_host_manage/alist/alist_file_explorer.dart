import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' as flutter_services;

import 'package:external_path/external_path.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluro/fluro.dart';
import 'package:horopic/widgets/common_widgets.dart';

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
  List dirAllInfoList = [];
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

    var files = [];
    var dir = [];
    files.clear();
    dir.clear();
    for (var i = 0; i < fetchedFolderData[1].length; i++) {
      if (fetchedFolderData[1][i]['is_dir'] == false) {
        files.add(fetchedFolderData[1][i]);
      } else {
        dir.add(fetchedFolderData[1][i]);
      }
    }

    if (files.isNotEmpty) {
      fileAllInfoList.clear();
      for (var element in files) {
        fileAllInfoList.add(element);
      }
      for (var i = 0; i < fileAllInfoList.length; i++) {
        fileAllInfoList[i]['modified'] = DateTime.parse(
          fileAllInfoList[i]['modified'],
        );
      }
      fileAllInfoList.sort((a, b) {
        return b['modified'].compareTo(a['modified']);
      });
    } else {
      fileAllInfoList.clear();
    }

    if (dir.isNotEmpty) {
      dirAllInfoList.clear();
      for (var element in dir) {
        dirAllInfoList.add(element);
      }
    } else {
      dirAllInfoList.clear();
    }

    allInfoList.clear();
    allInfoList.addAll(dirAllInfoList);
    allInfoList.addAll(fileAllInfoList);
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
  }

  @override
  String getShareUrl(int index) {
    String shareUrl = '';
    if (index < dirAllInfoList.length) {
      shareUrl = '${widget.configMap['host']}${widget.bucketPrefix}${dirAllInfoList[index]['name']}';
    } else {
      shareUrl = '${widget.configMap['host']}/d${widget.bucketPrefix}${allInfoList[index]['name']}';
      if (allInfoList[index]['sign'] != null && allInfoList[index]['sign'].isNotEmpty) {
        shareUrl += '?sign=${allInfoList[index]['sign']}';
      }
    }
    return shareUrl;
  }

  @override
  String getFileName(int index) => allInfoList[index]['name'];

  @override
  String getFileDate(int index) {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(allInfoList[index]['modified'].toString() != 'null'
        ? DateTime.parse(allInfoList[index]['modified'].toString())
        : DateTime.now());
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
  Future<void> onFileItemTap(int index) async {
    if (index < dirAllInfoList.length) {
      String prefix = allInfoList[index]['name'];
      prefix = '${widget.bucketPrefix}$prefix/';
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

  PopupMenuItem _buildSortMenuItem(String title, Function(dynamic, dynamic, bool) compareFunc) {
    return PopupMenuItem(
      child: Center(
          child: Text(
        title,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 15,
        ),
      )),
      onTap: () {
        setState(() {
          bool ascending = !sorted;

          if (dirAllInfoList.isEmpty) {
            allInfoList.sort((a, b) => compareFunc(a, b, ascending));
          } else {
            List temp = allInfoList.sublist(dirAllInfoList.length, allInfoList.length);
            temp.sort((a, b) => compareFunc(a, b, ascending));
            allInfoList.clear();
            allInfoList.addAll(dirAllInfoList);
            allInfoList.addAll(temp);
          }

          sorted = ascending;
        });
      },
    );
  }

  Future<void> _processUploadFiles(List<File> files, bool isSkipImageCheck) async {
    Map configMap = await manageAPI.getConfigMap();
    configMap['uploadPath'] = widget.bucketPrefix == "/" ? "None" : widget.bucketPrefix;

    for (int i = 0; i < files.length; i++) {
      File compressedFile;
      if (isSkipImageCheck || Global.imgExt.contains(my_path.extension(files[i].path).toLowerCase().substring(1))) {
        if (Global.isCompress == true) {
          ImageCompressor imageCompress = ImageCompressor();
          compressedFile = await imageCompress.compressAndGetFile(
              files[i].path, my_path.basename(files[i].path), Global.defaultCompressFormat,
              minHeight: Global.minHeight, minWidth: Global.minWidth, quality: Global.quality);
          files[i] = compressedFile;
        } else {
          compressedFile = files[i];
        }
      }
      List uploadList = [files[i].path, my_path.basename(files[i].path), configMap];
      String uploadListStr = jsonEncode(uploadList);
      Global.alistUploadList.add(uploadListStr);
    }

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
  AppBar buildAppBar() {
    return AppBar(
      elevation: 0,
      flexibleSpace: getFlexibleSpace(context),
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios,
          size: 20,
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      titleSpacing: 0,
      title: titleText(
        widget.bucketPrefix == '/'
            ? '根目录'
            : widget.bucketPrefix.substring(0, widget.bucketPrefix.length - 1).split('/').last,
      ),
      actions: [
        PopupMenuButton(
          icon: const Icon(
            Icons.sort,
            color: Colors.white,
            size: 25,
          ),
          position: PopupMenuPosition.under,
          itemBuilder: (BuildContext context) {
            return [
              _buildSortMenuItem(
                  '修改时间排序',
                  (a, b, ascending) =>
                      ascending ? a['modified'].compareTo(b['modified']) : b['modified'].compareTo(a['modified'])),
              _buildSortMenuItem('文件名称排序',
                  (a, b, ascending) => ascending ? a['name'].compareTo(b['name']) : b['name'].compareTo(a['name'])),
              _buildSortMenuItem('文件大小排序',
                  (a, b, ascending) => ascending ? a['size'].compareTo(b['size']) : b['size'].compareTo(a['size'])),
              _buildSortMenuItem('文件类型排序', (a, b, ascending) {
                String typeA = a['name'].split('.').last;
                String typeB = b['name'].split('.').last;
                if (typeA.isEmpty && typeB.isEmpty) return 0;
                if (typeA.isEmpty) return ascending ? 1 : -1;
                if (typeB.isEmpty) return ascending ? -1 : 1;
                return ascending ? typeA.compareTo(typeB) : typeB.compareTo(typeA);
              }),
            ];
          },
        ),
        IconButton(
            onPressed: () {
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
            },
            icon: const Icon(
              Icons.add,
              color: Colors.white,
              size: 30,
            )),
        IconButton(
            onPressed: () async {
              String downloadPath =
                  await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_DOWNLOAD);
              int index = 1;
              if (Global.alistDownloadList.isEmpty) {
                index = 0;
              }
              if (mounted) {
                Application.router
                    .navigateTo(context,
                        '/baseUpDownloadManagePage?bucketName=${Uri.encodeComponent('Alist_${widget.currentStorageInfoMap['mount_path'].split('/').last}')}&downloadPath=${Uri.encodeComponent(downloadPath)}&tabIndex=$index&currentListIndex=0',
                        transition: TransitionType.inFromRight)
                    .then((value) {
                  _getBucketList();
                });
              }
            },
            icon: const Icon(
              Icons.import_export,
              color: Colors.white,
              size: 25,
            )),
        IconButton(
          icon: selectedFilesBool.contains(true)
              ? const Icon(Icons.delete, color: Color.fromARGB(255, 236, 127, 120), size: 30.0)
              : const Icon(Icons.delete_outline, color: Colors.white, size: 30.0),
          onPressed: () async {
            if (!selectedFilesBool.contains(true) || selectedFilesBool.isEmpty) {
              showToastWithContext(context, '没有选择文件');
              return;
            }
            return showCupertinoAlertDialogWithConfirmFunc(
              title: '删除全部文件',
              content: '是否删除全部选择的文件？\n请谨慎选择!',
              context: context,
              onConfirm: () async {
                try {
                  List<int> toDelete = [];
                  for (int i = 0; i < allInfoList.length; i++) {
                    if (selectedFilesBool[i]) {
                      toDelete.add(i);
                    }
                  }
                  await deleteFiles(toDelete);
                  showToast('删除完成');
                } catch (e) {
                  flogErr(e, {}, 'AlistManagePage', 'deleteFiles');
                  showToast('删除失败');
                }
              },
            );
          },
        ),
      ],
    );
  }

  @override
  Future<void> onDownloadButtonPressed() async {
    if (!selectedFilesBool.contains(true) || selectedFilesBool.isEmpty) {
      showToastWithContext(context, '没有选择文件');
      return;
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
    Global.setAlistDownloadList(Global.alistDownloadList);
    String downloadPath = await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_DOWNLOAD);
    final bucketName = 'Alist_${widget.currentStorageInfoMap['mount_path'].split('/').last}';

    Application.router.navigateTo(context,
        '/baseUpDownloadManagePage?bucketName=${Uri.encodeComponent(bucketName)}&downloadPath=${Uri.encodeComponent(downloadPath)}&tabIndex=1&currentListIndex=0',
        transition: TransitionType.inFromRight);
  }

  @override
  void onCopyButtonPressed() async {
    if (!selectedFilesBool.contains(true)) {
      showToastWithContext(context, '请先选择文件');
      return;
    }
    Map configMap = await manageAPI.getConfigMap();
    List multiUrls = [];
    for (int i = 0; i < allInfoList.length; i++) {
      if (!selectedFilesBool[i]) continue;

      String rawurl = '';
      String fileName = allInfoList[i]['name'];
      if (i < dirAllInfoList.length) {
        rawurl = '${configMap['host']}${widget.bucketPrefix}${dirAllInfoList[i]['name']}';
      } else {
        rawurl = '${configMap['host']}/d${widget.bucketPrefix}${allInfoList[i]['name']}';
        if (allInfoList[i]['sign'] != null && allInfoList[i]['sign'].isNotEmpty) {
          rawurl = '$rawurl?sign=${allInfoList[i]['sign']}';
        }
      }

      multiUrls.add(getFormatedUrl(rawurl, fileName));
    }
    if (multiUrls.isNotEmpty) {
      await flutter_services.Clipboard.setData(flutter_services.ClipboardData(text: multiUrls.join('\n')));
    }
    if (mounted) {
      showToastWithContext(context, '已复制全部链接');
    }
  }

  @override
  Future<void> deleteFiles(List<int> toDelete) async {
    try {
      toDelete.sort((a, b) => b.compareTo(a));
      for (int index in toDelete) {
        String fileName = allInfoList[index]['name'];
        await manageAPI.remove(widget.bucketPrefix, [fileName]);
        setState(() {
          bool isDirectory = index < dirAllInfoList.length;
          allInfoList.removeAt(index);
          selectedFilesBool.removeAt(index);
          if (isDirectory) {
            dirAllInfoList.removeAt(index);
          } else {
            fileAllInfoList.removeAt(index - dirAllInfoList.length);
          }
        });
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
          'AlistManagePage',
          'deleteAll');
      rethrow;
    }
  }

  @override
  Widget buildBottomSheetWidget(BuildContext context, int index) {
    return FileBottomSheetWidget(
      thumbnailWidget: getThumbnailWidget(index),
      fileName: getFileName(index),
      fileDate: getFileDate(index),
      actions: index < dirAllInfoList.length
          ? [
              BottomSheetAction(
                icon: Icons.delete_outline,
                iconColor: Color.fromARGB(255, 97, 141, 236),
                title: '设为图床默认目录',
                onTap: () async {
                  String path = widget.bucketPrefix + allInfoList[index]['name'];
                  var result = await manageAPI.setDefaultBucket(path);
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
              BottomSheetAction(
                icon: Icons.delete_outline,
                iconColor: const Color.fromARGB(255, 240, 85, 131),
                title: '删除',
                onTap: () async {
                  Navigator.pop(context);
                  showCupertinoAlertDialogWithConfirmFunc(
                    context: context,
                    title: '通知',
                    content: '确定要删除${allInfoList[index]['name']}吗？',
                    onConfirm: () async {
                      var result = await manageAPI.remove(widget.bucketPrefix, [allInfoList[index]['name']]);
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
                    },
                  );
                },
              ),
            ]
          : [
              BottomSheetAction(
                icon: Icons.info_outline_rounded,
                iconColor: const Color.fromARGB(255, 97, 141, 236),
                title: '文件详情',
                onTap: () async {
                  Navigator.pop(context);
                  Map<String, dynamic> fileMap = allInfoList[index];
                  fileMap['fullPath'] = widget.bucketPrefix + fileMap['name'];
                  fileMap['modified'] = fileMap['modified'].toString().replaceAll('T', ' ').replaceAll('Z', '');

                  Application.router.navigateTo(
                      context, '${Routes.alistFileInformation}?fileMap=${Uri.encodeComponent(jsonEncode(fileMap))}',
                      transition: TransitionType.cupertino);
                },
              ),
              BottomSheetAction(
                icon: Icons.link_rounded,
                iconColor: const Color.fromARGB(255, 97, 141, 236),
                title: '复制链接(设置中的默认格式)',
                onTap: () async {
                  String shareUrl = '${widget.configMap['host']}/d${widget.bucketPrefix}${allInfoList[index]['name']}';
                  if (allInfoList[index]['sign'] != null && allInfoList[index]['sign'].isNotEmpty) {
                    shareUrl += '?sign=${allInfoList[index]['sign']}';
                  }

                  String filename = my_path.basename(allInfoList[index]['name']);
                  String formatedLink = getFormatedUrl(shareUrl, filename);
                  await flutter_services.Clipboard.setData(flutter_services.ClipboardData(text: formatedLink));
                  if (mounted) {
                    Navigator.pop(context);
                  }
                  showToast('复制完毕');
                },
              ),
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
              ),
              BottomSheetAction(
                icon: Icons.delete_outline,
                iconColor: const Color.fromARGB(255, 240, 85, 131),
                title: '删除文件',
                onTap: () async {
                  Navigator.pop(context);
                  showCupertinoAlertDialogWithConfirmFunc(
                    context: context,
                    title: '通知',
                    content: '确定要删除${allInfoList[index]['name']}吗？',
                    onConfirm: () async {
                      var result = await manageAPI.remove(widget.bucketPrefix, [allInfoList[index]['name']]);
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
              ),
            ],
    );
  }
}
