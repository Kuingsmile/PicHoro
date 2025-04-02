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
import 'package:horopic/picture_host_manage/manage_api/webdav_manage_api.dart';
import 'package:horopic/picture_host_manage/common/loading_state.dart' as loading_state;
import 'package:horopic/utils/global.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/widgets/net_loading_dialog.dart';
import 'package:horopic/utils/image_compressor.dart';
import 'package:horopic/picture_host_manage/common/base_file_explorer_page.dart';
import 'package:horopic/picture_host_manage/common/build_bottom_widget.dart';
import 'package:horopic/picture_host_manage/common/new_folder_widgets.dart';
import 'package:horopic/picture_host_manage/common/rename_dialog_widgets.dart';

class WebdavFileExplorer extends BaseFileExplorer {
  final Map element;
  final String bucketPrefix;
  const WebdavFileExplorer({super.key, required this.element, required this.bucketPrefix});

  @override
  WebdavFileExplorerState createState() => WebdavFileExplorerState();
}

class WebdavFileExplorerState extends BaseFileExplorerState<WebdavFileExplorer> {
  TextEditingController vc = TextEditingController();
  TextEditingController newFolder = TextEditingController();
  TextEditingController fileLink = TextEditingController();

  @override
  Future<void> initializeData() async {
    await _getBucketList();
  }

  @override
  Future<void> refreshData() async {
    await _getBucketList();
  }

  _getBucketList() async {
    var fileListResponse = await WebdavManageAPI().getFileList(widget.bucketPrefix);
    if (fileListResponse[0] != 'success') {
      if (mounted) {
        setState(() {
          state = loading_state.LoadState.error;
        });
      }
      return;
    }

    List files = [];
    List dir = [];

    for (var i = 0; i < fileListResponse[1].length; i++) {
      if (fileListResponse[1][i]['isDir'] == true) {
        dir.add(fileListResponse[1][i]);
      } else {
        files.add(fileListResponse[1][i]);
      }
    }

    if (files.isNotEmpty) {
      fileAllInfoList = List.from(files);
      fileAllInfoList.sort((a, b) => b['name'].compareTo(a['name']));
    } else {
      fileAllInfoList.clear();
    }

    dirAllInfoList = dir.isNotEmpty ? List.from(dir) : [];
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
  Future<String> getShareUrl(int index) async {
    String host = widget.element['host'];
    if (host.endsWith('/')) {
      host = host.substring(0, host.length - 1);
    }
    String customUrl =
        widget.element['customUrl'] == null || widget.element['customUrl'] == '' ? 'None' : widget.element['customUrl'];
    String rawurl = customUrl == 'None' ? host + allInfoList[index]['path'] : customUrl + allInfoList[index]['path'];
    return rawurl;
  }

  @override
  String getFileDate(int index) {
    return allInfoList[index]['mTime'] == null
        ? ''
        : allInfoList[index]['mTime'].toString().replaceAll('T', ' ').replaceAll('Z', '').substring(0, 19);
  }

  @override
  String? getFileSizeForList(int index) {
    int size = int.parse((allInfoList[index]['size'] ?? 0).toString().split('.')[0]);
    return size > 0 ? getFileSize(size) : null;
  }

  @override
  Map<String, String> getHeaders(int index) {
    return {'Authorization': generateBasicAuth(widget.element['webdavusername'], widget.element['password'])};
  }

  @override
  Future<void> onFileItemTap(int index) async {
    if (index < dirAllInfoList.length) {
      String prefix = allInfoList[index]['path'];
      Application.router.navigateTo(context,
          '${Routes.webdavFileExplorer}?element=${Uri.encodeComponent(jsonEncode(widget.element))}&bucketPrefix=${Uri.encodeComponent(prefix)}',
          transition: TransitionType.cupertino);
    } else {
      String urlList = '';
      if (!supportedExtensions(allInfoList[index]['name'].split('.').last)) {
        showToast('只支持图片文本PDF文件预览');
        return;
      }
      String host = widget.element['host'];
      if (host.endsWith('/')) {
        host = host.substring(0, host.length - 1);
      }
      //预览图片
      if (Global.imgExt.contains(allInfoList[index]['name'].split('.').last.toLowerCase())) {
        showToast('正在加载');
        int newImageIndex = index - dirAllInfoList.length;
        for (int i = dirAllInfoList.length; i < allInfoList.length; i++) {
          if (Global.imgExt.contains(allInfoList[i]['name'].split('.').last.toLowerCase())) {
            urlList += '${host + allInfoList[i]['path']},';
          } else if (i < index) {
            newImageIndex--;
          }
        }
        urlList = urlList.substring(0, urlList.length - 1);
        Map<String, String> headers = {
          'Authorization': generateBasicAuth(widget.element['webdavusername'], widget.element['password'])
        };
        List<Map<String, dynamic>> headersList = [];
        for (int i = 0; i < urlList.split(',').length; i++) {
          headersList.add(headers);
        }
        Application.router.navigateTo(context,
            '${Routes.webdavImagePreview}?index=$newImageIndex&images=${Uri.encodeComponent(urlList)}&headersList=${Uri.encodeComponent(jsonEncode(headersList))}',
            transition: TransitionType.none);
      } else if (allInfoList[index]['name'].split('.').last.toLowerCase() == 'pdf') {
        String shareUrl = '';
        shareUrl = host + allInfoList[index]['path'];
        Map<String, String> headers = {
          'Authorization': generateBasicAuth(widget.element['webdavusername'], widget.element['password'])
        };
        Application.router.navigateTo(context,
            '${Routes.pdfViewer}?url=${Uri.encodeComponent(shareUrl)}&fileName=${Uri.encodeComponent(allInfoList[index]['name'])}&headers=${Uri.encodeComponent(jsonEncode(headers))}',
            transition: TransitionType.none);
      } else if (Global.textExt.contains(allInfoList[index]['name'].split('.').last.toLowerCase())) {
        String shareUrl = '';
        shareUrl = host + allInfoList[index]['path'];
        Map<String, dynamic>? headers = {
          'Authorization': generateBasicAuth(widget.element['webdavusername'], widget.element['password'])
        };
        showToast('开始获取文件');
        String filePath = await downloadTxtFile(shareUrl, allInfoList[index]['name'], headers);
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
  Future<void> deleteFiles(List<int> toDelete) async {
    toDelete.sort((a, b) => b.compareTo(a));
    for (int index in toDelete) {
      var result = await WebdavManageAPI().deleteFile(allInfoList[index]['path']);
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
  String getPageTitle() => widget.bucketPrefix == '/'
      ? '根目录'
      : widget.bucketPrefix.substring(0, widget.bucketPrefix.length - 1).split('/').last;

  @override
  DateTime getFormatedFileDate(dynamic item) {
    return DateTime.parse(item['mTime'].toString());
  }

  Future<void> _processUploadFiles(List<File> files, bool isSkipImageCheck) async {
    Map configMap = await WebdavManageAPI().getConfigMap();
    configMap['uploadPath'] = widget.bucketPrefix;
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
      Global.webdavUploadList.add(uploadListStr);
    }
    Global.webdavUploadList = removeDuplicates(Global.webdavUploadList);
    Global.setWebdavUploadList(Global.webdavUploadList);
    String downloadPath = await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_DOWNLOAD);
    String bucketName = widget.bucketPrefix == '/'
        ? '根目录'
        : widget.bucketPrefix.endsWith('/')
            ? widget.bucketPrefix.substring(0, widget.bucketPrefix.length - 1)
            : widget.bucketPrefix;
    if (mounted) {
      Application.router
          .navigateTo(context,
              '/baseUpDownloadManagePage?bucketName=${Uri.encodeComponent(bucketName)}&downloadPath=${Uri.encodeComponent(downloadPath)}&tabIndex=0&currentListIndex=11',
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
                title: const Text('上传照片'),
                onTap: () async {
                  Navigator.pop(context);
                  AssetPickerConfig config = const AssetPickerConfig(
                    maxAssets: 100,
                    selectedAssets: [],
                  );
                  final List<AssetEntity>? pickedImage = await AssetPicker.pickAssets(context, pickerConfig: config);
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
                              requestCallBack:
                                  WebdavManageAPI().uploadNetworkFileEntry(fileLinkList, widget.bucketPrefix),
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
                      "WebdavManagePage",
                      "uploadNetworkFileEntry",
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
                            title: "输入新文件夹名 / 分隔",
                            onConfirm: () async {
                              String newName = newFolder.text;
                              if (newName.isEmpty) {
                                showToastWithContext(context, "文件夹名不能为空");
                                return;
                              }
                              if (newName.startsWith("/")) {
                                newName = newName.substring(1);
                              }
                              if (newName.endsWith("/")) {
                                newName = newName.substring(0, newName.length - 1);
                              }
                              newName = "${widget.bucketPrefix}$newName/";
                              var copyResult = await WebdavManageAPI().createDir(newName);
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
    String host = widget.element['host'];
    if (host.endsWith('/')) {
      host = host.substring(0, host.length - 1);
    }
    List<String> urlList = [];
    for (int i = 0; i < downloadList.length; i++) {
      urlList.add(host + downloadList[i]['path']);
    }
    Global.webdavDownloadList.addAll(urlList);
    Global.webdavDownloadList = removeDuplicates(Global.webdavDownloadList);
    Global.setWebdavDownloadList(Global.webdavDownloadList);
    String downloadPath = await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_DOWNLOAD);
    String bucketName = widget.bucketPrefix == '/'
        ? '根目录'
        : widget.bucketPrefix.endsWith('/')
            ? widget.bucketPrefix.substring(0, widget.bucketPrefix.length - 1)
            : widget.bucketPrefix;
    Application.router.navigateTo(context,
        '/baseUpDownloadManagePage?bucketName=${Uri.encodeComponent(bucketName)}&downloadPath=${Uri.encodeComponent(downloadPath)}&tabIndex=0&currentListIndex=11',
        transition: TransitionType.inFromRight);
  }

  @override
  void navigateToDownloadManagement() async {
    String downloadPath = await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_DOWNLOAD);
    int index = Global.webdavDownloadList.isEmpty ? 0 : 1;
    String bucketName = widget.bucketPrefix == '/'
        ? '根目录'
        : widget.bucketPrefix.endsWith('/')
            ? widget.bucketPrefix.substring(0, widget.bucketPrefix.length - 1)
            : widget.bucketPrefix;
    if (mounted) {
      Application.router
          .navigateTo(context,
              '/baseUpDownloadManagePage?bucketName=${Uri.encodeComponent(bucketName)}&downloadPath=${Uri.encodeComponent(downloadPath)}&tabIndex=$index&currentListIndex=11',
              transition: TransitionType.inFromRight)
          .then((value) {
        _getBucketList();
      });
    }
  }

  @override
  void onFileInfoTap(int index) {
    Map<String, dynamic> fileMap = allInfoList[index];
    String host = widget.element['host'];
    if (host.endsWith('/')) {
      host = host.substring(0, host.length - 1);
    }
    fileMap['rawUrl'] = '$host${fileMap['path']}';
    fileMap['mTime'] = fileMap['mTime'].toString();

    Application.router.navigateTo(
        context, '${Routes.webdavFileInformation}?fileMap=${Uri.encodeComponent(jsonEncode(fileMap))}',
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
            var result = await WebdavManageAPI().setDefaultBucket(allInfoList[index]['path']);
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
                barrierDismissible: false,
                context: context,
                builder: (context) {
                  return RenameDialog(
                    contentWidget: RenameDialogContent(
                      title: "新文件名 '/'分割文件夹",
                      onConfirm: (bool isCoverFile) async {
                        String newName = vc.text;
                        newName =
                            allInfoList[index]['path'].substring(0, allInfoList[index]['path'].lastIndexOf('/') + 1) +
                                newName;
                        var renameResult = await WebdavManageAPI().renameFile(
                          allInfoList[index]['path'],
                          newName,
                        );
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
    ];
  }
}
