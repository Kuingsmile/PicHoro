import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' as flutter_services;
import 'package:external_path/external_path.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluro/fluro.dart';
import 'package:horopic/picture_host_manage/common/base_file_explorer_page.dart';
import 'package:horopic/picture_host_manage/common/build_bottom_widget.dart';
import 'package:horopic/picture_host_manage/common/new_folder_widgets.dart';
import 'package:horopic/picture_host_manage/common/rename_dialog_widgets.dart';
import 'package:path/path.dart' as my_path;
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import 'package:horopic/router/application.dart';
import 'package:horopic/router/routers.dart';
import 'package:horopic/picture_host_manage/manage_api/qiniu_manage_api.dart';
import 'package:horopic/picture_host_manage/common/loading_state.dart' as loading_state;
import 'package:horopic/utils/global.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/utils/image_compressor.dart';

class QiniuFileExplorer extends BaseFileExplorer {
  final Map element;
  final String bucketPrefix;
  const QiniuFileExplorer({super.key, required this.element, required this.bucketPrefix});

  @override
  QiniuFileExplorerState createState() => QiniuFileExplorerState();
}

class QiniuFileExplorerState extends BaseFileExplorerState<QiniuFileExplorer> {
  TextEditingController vc = TextEditingController();
  TextEditingController newFolder = TextEditingController();
  TextEditingController fileLink = TextEditingController();

  QiniuManageAPI manageAPI = QiniuManageAPI();

  @override
  Future<void> initializeData() async {
    await _getBucketList();
  }

  @override
  Future<void> refreshData() async {
    await _getBucketList();
  }

  _getBucketList() async {
    var bucketFilesResponse = await manageAPI.queryBucketFiles(widget.element, {
      if (widget.bucketPrefix != '') 'prefix': widget.bucketPrefix,
      'bucket': widget.element['name'],
      'limit': 1000,
      'delimiter': '/',
    });
    if (bucketFilesResponse[0] != 'success') {
      if (mounted) {
        setState(() {
          state = loading_state.LoadState.error;
        });
      }
      return;
    }
    if (widget.bucketPrefix != '') {
      bucketFilesResponse[1]['items'].removeWhere((element) => element['key'] == widget.bucketPrefix);
    }

    var files = bucketFilesResponse[1]['items'] ?? [];
    var dir = bucketFilesResponse[1]['commonPrefixes'] ?? [];

    fileAllInfoList = files is List ? files : [files];
    for (var i = 0; i < fileAllInfoList.length; i++) {
      fileAllInfoList[i]['putTime'] = fileAllInfoList[i]['putTime'] / 10000;
    }
    fileAllInfoList.sort((a, b) {
      return b['putTime'].compareTo(a['putTime']);
    });

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
    String domain = widget.element['domain'];
    if (!domain.startsWith('http') && !domain.startsWith('https')) {
      domain = 'http://$domain';
    }
    if (domain.endsWith('/')) {
      domain = domain.substring(0, domain.length - 1);
    }
    String filepath = index < dirAllInfoList.length ? allInfoList[index] : allInfoList[index]['key'];
    return '$domain/$filepath';
  }

  @override
  String getFileName(int index) {
    String fileName = index < dirAllInfoList.length ? allInfoList[index] : allInfoList[index]['key'];
    return fileName.replaceAll(RegExp(r'\/+$'), '').split('/').last;
  }

  @override
  String getFileDate(int index) {
    if (index < dirAllInfoList.length) {
      return '';
    }
    return allInfoList[index]['putTime'] == null
        ? ''
        : DateTime.fromMillisecondsSinceEpoch(int.parse((allInfoList[index]['putTime']).toString().split('.')[0]))
            .toString()
            .split('.')[0];
  }

  @override
  String? getFileSizeForList(int index) {
    if (index < dirAllInfoList.length) {
      return null;
    } else {
      return getFileSize(allInfoList[index]['fsize']);
    }
  }

  @override
  Future<void> onFileItemTap(int index) async {
    if (index < dirAllInfoList.length) {
      String prefix = allInfoList[index];
      Application.router.navigateTo(context,
          '${Routes.qiniuFileExplorer}?element=${Uri.encodeComponent(jsonEncode(widget.element))}&bucketPrefix=${Uri.encodeComponent(prefix)}',
          transition: TransitionType.cupertino);
    } else {
      String urlList = '';
      if (!supportedExtensions(allInfoList[index]['key'].split('.').last.toLowerCase())) {
        showToast('只支持图片文本和视频');
        return;
      }
      String domain = widget.element['domain'];
      if (!domain.startsWith('http') && !domain.startsWith('https')) {
        domain = 'http://$domain';
      }
      if (domain.endsWith('/')) {
        domain = domain.substring(0, domain.length - 1);
      }
      //预览图片
      if (Global.imgExt.contains(allInfoList[index]['key'].split('.').last.toLowerCase())) {
        int newImageIndex = index - dirAllInfoList.length;
        for (int i = dirAllInfoList.length; i < allInfoList.length; i++) {
          if (Global.imgExt.contains(allInfoList[i]['key'].split('.').last.toLowerCase())) {
            String shareUrl = '$domain/${allInfoList[i]['key']}';
            urlList += '$shareUrl,';
          } else if (i < index) {
            newImageIndex--;
          }
        }
        urlList = urlList.substring(0, urlList.length - 1);
        Application.router.navigateTo(
            context, '${Routes.albumImagePreview}?index=$newImageIndex&images=${Uri.encodeComponent(urlList)}',
            transition: TransitionType.none);
      } else if (allInfoList[index]['key'].split('.').last.toLowerCase() == 'pdf') {
        String shareUrl = '$domain/${allInfoList[index]['key']}';
        Map<String, dynamic> headers = {};
        Application.router.navigateTo(context,
            '${Routes.pdfViewer}?url=${Uri.encodeComponent(shareUrl)}&fileName=${Uri.encodeComponent(allInfoList[index]['key'])}&headers=${Uri.encodeComponent(jsonEncode(headers))}',
            transition: TransitionType.none);
      } else if (Global.textExt.contains(allInfoList[index]['key'].split('.').last.toLowerCase())) {
        String shareUrl = '$domain/${allInfoList[index]['key']}';

        showToast('开始获取文件');
        String filePath = await downloadTxtFile(shareUrl, allInfoList[index]['key'], null);
        String fileName = allInfoList[index]['key'];
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
          ? await manageAPI.deleteFolder(widget.element, allInfoList[index])
          : await manageAPI.deleteFile(widget.element, allInfoList[index]['key']);
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
    return DateTime.fromMillisecondsSinceEpoch(int.parse((item['putTime']).toString().split('.')[0]));
  }

  @override
  int getFormatedSize(dynamic item) {
    return int.parse((item['fsize'] ?? 0).toString());
  }

  @override
  String getFormatedFileName(dynamic item) => item['key'].toString();

  Future<void> _processUploadFiles(List<File> files, bool isSkipImageCheck) async {
    Map tempConfigMap = await manageAPI.getConfigMap();
    Map configMap = {
      'accessKey': tempConfigMap['accessKey'],
      'secretKey': tempConfigMap['secretKey'],
      'bucket': widget.element['name'],
      'area': widget.element['area'],
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
      Global.qiniuUploadList.add(jsonEncode(uploadList));
    }
    (Global.qiniuUploadList = removeDuplicates(Global.qiniuUploadList));
    Global.setQiniuUploadList(Global.qiniuUploadList);
    String downloadPath = await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_DOWNLOAD);
    if (mounted) {
      Application.router
          .navigateTo(context,
              '/baseUpDownloadManagePage?bucketName=${widget.element['name']}&downloadPath=${Uri.encodeComponent(downloadPath)}&tabIndex=0&currentListIndex=7',
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

                  String urlStr = url.text!;
                  List fileLinkList = urlStr.split("\n");
                  int successCount = 0;
                  int failCount = 0;
                  for (int i = 0; i < fileLinkList.length; i++) {
                    var result = await manageAPI.sisyphusFetch(
                      widget.element,
                      widget.bucketPrefix,
                      fileLinkList[i],
                    );
                    if (result[0] == 'success') {
                      successCount++;
                    } else {
                      failCount++;
                    }
                  }
                  if (failCount == 0) {
                    showToast('成功提交$successCount个文件,稍后刷新查看');
                  } else if (successCount == 0) {
                    showToast('提交失败');
                  } else {
                    showToast('成功提交$successCount个文件,失败$failCount个文件');
                  }
                  _getBucketList();
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
                                return showToastWithContext(context, "文件夹名不能为空");
                              }
                              if (newName.startsWith("/")) {
                                newName = newName.substring(1);
                              }
                              if (!newName.endsWith("/")) {
                                newName = "$newName/";
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
    String hostPrefix = widget.element['domain'];
    if (!hostPrefix.startsWith('http://') && !hostPrefix.startsWith('https://')) {
      hostPrefix = 'http://$hostPrefix';
    }
    if (!hostPrefix.endsWith('/')) {
      hostPrefix = '$hostPrefix/';
    }
    List<String> urlList = [];
    for (int i = 0; i < downloadList.length; i++) {
      urlList.add(hostPrefix + downloadList[i]['key']);
    }
    Global.qiniuDownloadList.addAll(urlList);
    Global.qiniuDownloadList = removeDuplicates(Global.qiniuDownloadList);
    Global.setQiniuDownloadList(Global.qiniuDownloadList);
    String downloadPath = await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_DOWNLOAD);
    Application.router.navigateTo(context,
        '/baseUpDownloadManagePage?bucketName=${widget.element['name']}&downloadPath=${Uri.encodeComponent(downloadPath)}&tabIndex=1&currentListIndex=7',
        transition: TransitionType.inFromRight);
  }

  @override
  void navigateToDownloadManagement() async {
    String downloadPath = await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_DOWNLOAD);
    int index = Global.qiniuDownloadList.isEmpty ? 0 : 1;
    if (mounted) {
      Application.router
          .navigateTo(context,
              '/baseUpDownloadManagePage?bucketName=${widget.element['name']}&downloadPath=${Uri.encodeComponent(downloadPath)}&tabIndex=$index&currentListIndex=7',
              transition: TransitionType.inFromRight)
          .then((value) {
        _getBucketList();
      });
    }
  }

  @override
  void onFileInfoTap(int index) {
    Application.router.navigateTo(
        context, '${Routes.qiniuFileInformation}?fileMap=${Uri.encodeComponent(jsonEncode(allInfoList[index]))}',
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
            Map<String, dynamic> textMap = {
              'domain': widget.element['domain'],
              'area': widget.element['area'],
            };
            var result = await manageAPI.setDefaultBucketFromListPage(widget.element, textMap, allInfoList[index]);
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
                          var copyResult = await manageAPI.copyFile(
                              'move', widget.element, allInfoList[index]['key'], newName, true);
                          if (copyResult[0] == 'success') {
                            showToast('重命名成功');
                            _getBucketList();
                          } else {
                            showToast('重命名失败');
                          }
                        } else {
                          var copyResult = await manageAPI.copyFile(
                              'move', widget.element, allInfoList[index]['key'], newName, false);
                          if (copyResult[0] == 'success') {
                            showToast('重命名成功');
                            _getBucketList();
                          } else if (copyResult[0] == 'existed') {
                            showToast('重命名失败，文件已存在');
                          } else {
                            showToast('重命名失败');
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
