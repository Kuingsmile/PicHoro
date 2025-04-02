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
import 'package:horopic/picture_host_manage/manage_api/aliyun_manage_api.dart';
import 'package:horopic/picture_host_manage/common/loading_state.dart' as loading_state;
import 'package:horopic/utils/global.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/widgets/net_loading_dialog.dart';
import 'package:horopic/utils/image_compressor.dart';
import 'package:horopic/picture_host_manage/common/base_file_explorer_page.dart';
import 'package:horopic/picture_host_manage/common/build_bottom_widget.dart';
import 'package:horopic/picture_host_manage/common/new_folder_widgets.dart';
import 'package:horopic/picture_host_manage/common/rename_dialog_widgets.dart';

class AliyunFileExplorer extends BaseFileExplorer {
  final Map element;
  final String bucketPrefix;

  const AliyunFileExplorer({super.key, required this.element, required this.bucketPrefix});

  @override
  AliyunFileExplorerState createState() => AliyunFileExplorerState();
}

class AliyunFileExplorerState extends BaseFileExplorerState<AliyunFileExplorer> {
  TextEditingController vc = TextEditingController();
  TextEditingController newFolder = TextEditingController();
  TextEditingController fileLink = TextEditingController();

  AliyunManageAPI manageAPI = AliyunManageAPI();

  @override
  Future<void> initializeData() async {
    await _getBucketList();
  }

  @override
  Future<void> refreshData() async {
    await _getBucketList();
  }

  _getBucketList() async {
    var bucketFilesResponse = await manageAPI.queryBucketFiles(
      widget.element,
      {'prefix': widget.bucketPrefix, 'delimiter': '/'},
    );

    if (bucketFilesResponse[0] != 'success') {
      if (mounted) {
        setState(() {
          state = loading_state.LoadState.error;
        });
      }
      return;
    }
    if (bucketFilesResponse[1]['ListBucketResult']['Prefix'] != null) {
      if (bucketFilesResponse[1]['ListBucketResult']['Contents'] != null) {
        if (bucketFilesResponse[1]['ListBucketResult']['Contents'] is! List) {
          bucketFilesResponse[1]['ListBucketResult']
              ['Contents'] = [bucketFilesResponse[1]['ListBucketResult']['Contents']];
        }
        bucketFilesResponse[1]['ListBucketResult']['Contents']
            .removeWhere((element) => element['Key'] == bucketFilesResponse[1]['ListBucketResult']['Prefix']);
      }
    }

    var files = bucketFilesResponse[1]['ListBucketResult']['Contents'] ?? [];
    var dir = bucketFilesResponse[1]['ListBucketResult']['CommonPrefixes'] ?? [];

    fileAllInfoList = files is List ? files : [files];
    for (var file in fileAllInfoList) {
      file['LastModified'] = DateTime.parse(file['LastModified']);
    }
    fileAllInfoList.sort((a, b) => b['LastModified'].compareTo(a['LastModified']));

    dirAllInfoList = dir is List ? dir : [dir];

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
    String customUrl = widget.element['customUrl'] ?? '';
    if (customUrl.isNotEmpty) {
      customUrl = '$customUrl/'.replaceAll(RegExp(r'\/+$'), '/');
    }
    String filePath = index < dirAllInfoList.length ? allInfoList[index]['Prefix'] : allInfoList[index]['Key'];
    return customUrl.isNotEmpty
        ? '$customUrl$filePath'
        : 'https://${widget.element['name']}.${widget.element['location']}.aliyuncs.com/$filePath';
  }

  @override
  String getFileName(int index) => index < dirAllInfoList.length
      ? allInfoList[index]['Prefix'].replaceAll(RegExp(r'\/+$'), '').split('/').last
      : allInfoList[index]['Key'].split('/').last;

  @override
  String getFileDate(int index) =>
      allInfoList[index]['LastModified'] == null ? '' : allInfoList[index]['LastModified'].toString().substring(0, 19);

  @override
  String? getFileSizeForList(int index) {
    int size = int.parse((allInfoList[index]['Size'] ?? 0).toString());
    return size > 0 ? getFileSize(size) : null;
  }

  @override
  Future<void> onFileItemTap(int index) async {
    if (index < dirAllInfoList.length) {
      String prefix = allInfoList[index]['Prefix'];
      Application.router.navigateTo(context,
          '${Routes.aliyunFileExplorer}?element=${Uri.encodeComponent(jsonEncode(widget.element))}&bucketPrefix=${Uri.encodeComponent(prefix)}',
          transition: TransitionType.cupertino);
    } else {
      String urlList = '';
      //判断是否为图片
      if (!supportedExtensions(allInfoList[index]['Key'].split('.').last.toLowerCase())) {
        showToast('只支持图片预览');
        return;
      }
      //判断权限
      var result = await manageAPI.queryACLPolicy(widget.element);
      if (result[0] == 'success') {
        var granteeURI = result[1]['AccessControlPolicy']['AccessControlList']['Grant'];
        String aclState = granteeURI;
        if (aclState != 'public-read' && aclState != 'public-read-write') {
          showToast('请先设置公有读权限');
          return;
        }
      } else {
        showToast('获取权限失败');
        return;
      }
      //预览图片
      if (Global.imgExt.contains(allInfoList[index]['Key'].split('.').last.toLowerCase())) {
        int newImageIndex = index - dirAllInfoList.length;
        for (int i = dirAllInfoList.length; i < allInfoList.length; i++) {
          if (Global.imgExt.contains(allInfoList[i]['Key'].split('.').last.toLowerCase())) {
            urlList +=
                'https://${widget.element['name']}.${widget.element['location']}.aliyuncs.com/${allInfoList[i]['Key']},';
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
      } else if (allInfoList[index]['Key'].split('.').last.toLowerCase() == 'pdf') {
        String shareUrl = '';
        shareUrl =
            'https://${widget.element['name']}.${widget.element['location']}.aliyuncs.com/${allInfoList[index]['Key']}';
        Map<String, dynamic> headers = {};
        if (context.mounted) {
          Application.router.navigateTo(context,
              '${Routes.pdfViewer}?url=${Uri.encodeComponent(shareUrl)}&fileName=${Uri.encodeComponent(allInfoList[index]['Key'])}&headers=${Uri.encodeComponent(jsonEncode(headers))}',
              transition: TransitionType.none);
        }
      } else if (Global.textExt.contains(allInfoList[index]['Key'].split('.').last.toLowerCase())) {
        String shareUrl = '';
        shareUrl =
            'https://${widget.element['name']}.${widget.element['location']}.aliyuncs.com/${allInfoList[index]['Key']}';
        showToast('开始获取文件');
        String filePath = await downloadTxtFile(shareUrl, allInfoList[index]['Key'], null);
        String fileName = allInfoList[index]['Key'];
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
      var result = index < dirAllInfoList.length
          ? await manageAPI.deleteFolder(widget.element, allInfoList[index]['Prefix'])
          : await manageAPI.deleteFile(widget.element, allInfoList[index]['Key']);
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
  String getPageTitle() => widget.bucketPrefix == '' ? widget.element['name'] : widget.bucketPrefix;

  @override
  DateTime getFormatedFileDate(dynamic item) {
    return DateTime.parse(item['LastModified'].toString());
  }

  @override
  int getFormatedSize(dynamic item) {
    return int.parse((item['Size'] ?? 0).toString());
  }

  @override
  String getFormatedFileName(dynamic item) => item['Key'].toString();

  Future<void> _processUploadFiles(List<File> files, bool isSkipImageCheck) async {
    Map configMap = await manageAPI.getConfigMap();
    configMap['bucket'] = widget.element['name'];
    configMap['area'] = widget.element['location'];
    configMap['path'] = widget.bucketPrefix;
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
      Global.aliyunUploadList.add(uploadListStr);
    }
    Global.aliyunUploadList = removeDuplicates(Global.aliyunUploadList);
    Global.setAliyunUploadList(Global.aliyunUploadList);
    String downloadPath = await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_DOWNLOAD);
    if (mounted) {
      Application.router
          .navigateTo(context,
              '/baseUpDownloadManagePage?bucketName=${widget.element['name']}&downloadPath=${Uri.encodeComponent(downloadPath)}&tabIndex=0&currentListIndex=1',
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
                        'AliyunFileExplorer',
                        'uploadNetworkFileEntry');
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
                            title: "新文件夹名 / 分隔",
                            onConfirm: () async {
                              String newName = newFolder.text;
                              if (newName.isEmpty) {
                                showToastWithContext(context, "文件夹名不能为空");
                                return;
                              }
                              if (newName.startsWith('/')) {
                                newName = newName.substring(1);
                              }
                              if (newName.endsWith('/')) {
                                newName = newName.substring(0, newName.length - 1);
                              }
                              var copyResult =
                                  await manageAPI.createFolder(widget.element, widget.bucketPrefix, newName);
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
    String hostPrefix = 'https://${widget.element['name']}.${widget.element['location']}.aliyuncs.com/';
    List<String> urlList = [];
    for (int i = 0; i < downloadList.length; i++) {
      urlList.add(hostPrefix + downloadList[i]['Key']);
    }
    Global.aliyunDownloadList.addAll(urlList);
    Global.aliyunDownloadList = removeDuplicates(Global.aliyunDownloadList);
    Global.setAliyunDownloadList(Global.aliyunDownloadList);
    String downloadPath = await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_DOWNLOAD);
    Application.router.navigateTo(context,
        '/baseUpDownloadManagePage?bucketName=${widget.element['name']}&downloadPath=${Uri.encodeComponent(downloadPath)}&tabIndex=1&currentListIndex=1',
        transition: TransitionType.inFromRight);
  }

  @override
  void navigateToDownloadManagement() async {
    String downloadPath = await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_DOWNLOAD);
    int index = Global.aliyunDownloadList.isEmpty ? 0 : 1;
    if (mounted) {
      Application.router
          .navigateTo(context,
              '/baseUpDownloadManagePage?bucketName=${widget.element['name']}&downloadPath=${Uri.encodeComponent(downloadPath)}&tabIndex=$index&currentListIndex=1',
              transition: TransitionType.inFromRight)
          .then((value) {
        _getBucketList();
      });
    }
  }

  @override
  void onFileInfoTap(int index) {
    Map<String, dynamic> fileMap = allInfoList[index];
    fileMap['LastModified'] = fileMap['LastModified'].toString().replaceAll('T', ' ').replaceAll('Z', '');
    Application.router.navigateTo(
        context, '${Routes.aliyunFileInformation}?fileMap=${Uri.encodeComponent(jsonEncode(fileMap))}',
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
            var result = await manageAPI.setDefaultBucket(widget.element, allInfoList[index]['Prefix']);
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
                        if (isCoverFile) {
                          var copyResult = await manageAPI.copyFile(widget.element, allInfoList[index]['Key'], newName);
                          if (copyResult[0] == 'success') {
                            var deleteResult = await manageAPI.deleteFile(widget.element, allInfoList[index]['Key']);
                            if (deleteResult[0] == 'success') {
                              showToast('重命名成功');
                              _getBucketList();
                            } else {
                              showToast('重命名失败');
                            }
                          } else {
                            showToast('拷贝失败');
                          }
                        } else {
                          var checkDuplicate =
                              await manageAPI.queryDuplicateName(widget.element, widget.bucketPrefix, vc.text);
                          if (checkDuplicate[0] == 'duplicate' || checkDuplicate[0] == 'error') {
                            showToast('文件名重复');
                          } else {
                            var copyResult =
                                await manageAPI.copyFile(widget.element, allInfoList[index]['Key'], newName);
                            if (copyResult[0] == 'success') {
                              var deleteResult = await manageAPI.deleteFile(widget.element, allInfoList[index]['Key']);
                              if (deleteResult[0] == 'success') {
                                showToast('重命名成功');
                                _getBucketList();
                              }
                            } else {
                              showToast('重命名失败');
                            }
                          }
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
