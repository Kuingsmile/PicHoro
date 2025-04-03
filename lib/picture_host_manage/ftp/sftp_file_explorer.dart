import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' as flutter_services;

import 'package:external_path/external_path.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluro/fluro.dart';
import 'package:path/path.dart' as my_path;
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:dartssh2/dartssh2.dart';
import 'package:path_provider/path_provider.dart';

import 'package:horopic/picture_host_manage/common/base_file_explorer_page.dart';
import 'package:horopic/picture_host_manage/common/build_bottom_widget.dart';
import 'package:horopic/router/application.dart';
import 'package:horopic/router/routers.dart';
import 'package:horopic/picture_host_manage/manage_api/ftp_manage_api.dart';
import 'package:horopic/picture_host_manage/common/loading_state.dart' as loading_state;
import 'package:horopic/utils/global.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/widgets/net_loading_dialog.dart';
import 'package:horopic/utils/image_compressor.dart';
import 'package:horopic/picture_host_manage/common/new_folder_widgets.dart';
import 'package:horopic/picture_host_manage/common/rename_dialog_widgets.dart';

class SFTPFileExplorer extends BaseFileExplorer {
  final Map element;
  final String bucketPrefix;
  const SFTPFileExplorer({super.key, required this.element, required this.bucketPrefix});

  @override
  SFTPFileExplorerState createState() => SFTPFileExplorerState();
}

class SFTPFileExplorerState extends BaseFileExplorerState<SFTPFileExplorer> {
  TextEditingController vc = TextEditingController();
  TextEditingController newFolder = TextEditingController();
  TextEditingController fileLink = TextEditingController();

  FTPManageAPI manageAPI = FTPManageAPI();

  @override
  Future<void> initializeData() async {
    await _getBucketList();
  }

  @override
  Future<void> refreshData() async {
    await _getBucketList();
  }

  _getBucketList() async {
    var directoryContent = await manageAPI.getDirectoryContentSFTP(widget.bucketPrefix);

    if (directoryContent[0] != 'success') {
      if (mounted) {
        setState(() {
          state = loading_state.LoadState.error;
        });
      }
      return;
    }

    var files = [];
    var dir = [];
    for (var i = 0; i < directoryContent[1].length; i++) {
      if (directoryContent[1][i]['type'] == 'file') {
        files.add(directoryContent[1][i]);
      } else {
        dir.add(directoryContent[1][i]);
      }
    }

    fileAllInfoList = files.isNotEmpty ? List.from(files) : [];
    fileAllInfoList.sort((a, b) {
      return b['mtime'].compareTo(a['mtime']);
    });
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

  downloadFile(Map configMap, String filePath, String fileName) async {
    try {
      final socket = await SSHSocket.connect(configMap['ftpHost'], int.parse(configMap['ftpPort']));
      final client = SSHClient(
        socket,
        username: configMap['ftpUser'],
        onPasswordRequest: () => configMap['ftpPassword'],
      );
      final sftp = await client.sftp();
      String tempDir = (await getTemporaryDirectory()).path;
      var file = File('$tempDir/$fileName');
      if (file.existsSync()) {
        file.deleteSync();
      }
      var remoteFile = await sftp.open(filePath, mode: SftpFileOpenMode.read);
      file.writeAsBytesSync(await remoteFile.readBytes());
      return file.path;
    } catch (e) {
      flogErr(e, {}, 'SFTPFileExplorerState', 'downloadFile');
    }
    return 'error';
  }

  @override
  Future<String> getShareUrl(int index) async {
    String customUrl = widget.element['ftpCustomUrl'] == null || widget.element['ftpCustomUrl'] == ''
        ? 'None'
        : widget.element['ftpCustomUrl'];
    if (customUrl != 'None') {
      return '$customUrl${widget.bucketPrefix}${allInfoList[index]['name']}';
    } else {
      return 'ftp://${widget.element['ftpUser']}@${widget.element['ftpPassword']}@${widget.element['ftpHost']}:${widget.element['ftpPort']}${widget.bucketPrefix}${allInfoList[index]['name']}';
    }
  }

  @override
  String getFileDate(int index) {
    return allInfoList[index]['mtime'] == null
        ? ''
        : DateTime.fromMillisecondsSinceEpoch(allInfoList[index]['mtime'] * 1000).toString().substring(0, 19);
  }

  @override
  String? getFileSizeForList(int index) {
    int size = int.parse((allInfoList[index]['size'] ?? 0).toString().split('.')[0]);
    return size > 0 ? getFileSize(size) : null;
  }

  @override
  Future<void> onFileItemTap(int index) async {
    if (index < dirAllInfoList.length) {
      String prefix = '${widget.bucketPrefix}${allInfoList[index]['name']}/';
      Application.router.navigateTo(context,
          '${Routes.sftpFileExplorer}?element=${Uri.encodeComponent(jsonEncode(widget.element))}&bucketPrefix=${Uri.encodeComponent(prefix)}',
          transition: TransitionType.cupertino);
    } else {
      if (!Global.imgExt.contains(allInfoList[index]['name'].split('.').last.toLowerCase()) &&
          !Global.textExt.contains(allInfoList[index]['name'].split('.').last.toLowerCase())) {
        showToast('不支持的文件类型');
        return;
      }
      if (Global.imgExt.contains(allInfoList[index]['name'].split('.').last.toLowerCase())) {
        //预览图片
        Map configMapTemp = await manageAPI.getConfigMap();
        configMapTemp['name'] = allInfoList[index]['name'];
        String imagePath = widget.bucketPrefix + allInfoList[index]['name'];
        if (context.mounted) {
          Application.router.navigateTo(context,
              '${Routes.sftpLocalImagePreview}?configMap=${Uri.encodeComponent(jsonEncode(configMapTemp))}&image=${Uri.encodeComponent(imagePath)}',
              transition: TransitionType.none);
        }
      } else if (Global.textExt.contains(allInfoList[index]['name'].split('.').last.toLowerCase())) {
        showToast('开始加载，请稍候');
        Map configMapTemp = await manageAPI.getConfigMap();
        String fileName = allInfoList[index]['name'];
        String path = widget.bucketPrefix + fileName;
        String filePath = await downloadFile(configMapTemp, path, fileName);
        if (filePath == 'error') {
          showToast('获取文件失败');
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
      String filepath = widget.bucketPrefix + allInfoList[index]['name'];
      if (filepath.contains('*') || filepath.contains('?')) {
        showToast('文件名中不能包含特殊字符');
        return;
      }
      var result = index < dirAllInfoList.length
          ? await manageAPI.removeSFTPDirectory(filepath)
          : await manageAPI.deleteSFTPFile(filepath);
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
    return DateTime.fromMillisecondsSinceEpoch(item['mtime'] * 1000);
  }

  Future<void> _processUploadFiles(List<File> files, bool isSkipImageCheck) async {
    Map configMap = await manageAPI.getConfigMap();
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
      Global.ftpUploadList.add(uploadListStr);
    }
    Global.ftpUploadList = removeDuplicates(Global.ftpUploadList);
    Global.setFtpUploadList(Global.ftpUploadList);
    String downloadPath = await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_DOWNLOAD);
    if (mounted) {
      Application.router
          .navigateTo(context,
              '/baseUpDownloadManagePage?ftpHost=${widget.element['ftpHost']}&downloadPath=${Uri.encodeComponent(downloadPath)}&tabIndex=0&currentListIndex=3',
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
                              requestCallBack: manageAPI.uploadNetworkFileEntrySFTP(fileLinkList, widget.bucketPrefix),
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
                        'SFTPManagePage',
                        'uploadNetworkFileEntrySFTP');
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
                            title: "新文件夹名",
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
                              var createResult = await manageAPI.createFolderSFTP(widget.bucketPrefix + newName);
                              if (createResult[0] == 'success') {
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

    List<String> urlList = [];
    for (int i = 0; i < downloadList.length; i++) {
      urlList.add(widget.bucketPrefix + downloadList[i]['name']);
    }
    Global.ftpDownloadList.addAll(urlList);
    Global.ftpDownloadList = removeDuplicates(Global.ftpDownloadList);
    Global.setFtpDownloadList(Global.ftpDownloadList);
    String downloadPath = await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_DOWNLOAD);
    Application.router.navigateTo(context,
        '/baseUpDownloadManagePage?ftpHost=${widget.element['ftpHost']}&downloadPath=${Uri.encodeComponent(downloadPath)}&tabIndex=1&currentListIndex=3',
        transition: TransitionType.inFromRight);
  }

  @override
  void navigateToDownloadManagement() async {
    String downloadPath = await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_DOWNLOAD);
    int index = Global.ftpDownloadList.isEmpty ? 0 : 1;
    if (mounted) {
      Application.router
          .navigateTo(context,
              '/baseUpDownloadManagePage?ftpHost=${widget.element['ftpHost']}&downloadPath=${Uri.encodeComponent(downloadPath)}&tabIndex=$index&currentListIndex=3',
              transition: TransitionType.inFromRight)
          .then((value) {
        _getBucketList();
      });
    }
  }

  @override
  void onFileInfoTap(int index) {
    Map<dynamic, dynamic> fileMap = allInfoList[index];
    Application.router.navigateTo(
        context, '${Routes.sftpFileInformation}?fileMap=${Uri.encodeComponent(jsonEncode(fileMap))}',
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
            var result = await manageAPI.setDefaultBucketSFTP('${widget.bucketPrefix + allInfoList[index]['name']}/');
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
                      title: "新文件名 不含当前目录",
                      onConfirm: (bool isCoverFile) async {
                        String newName = vc.text;
                        if (newName == '') {
                          showToast('文件名不能为空');
                          return;
                        }
                        if (newName.startsWith('/')) {
                          newName = newName.substring(1);
                        }
                        if (newName.endsWith('/')) {
                          newName = newName.substring(0, newName.length - 1);
                        }
                        var renameResult = await manageAPI.renameFileSFTP(
                            widget.bucketPrefix + allInfoList[index]['name'], widget.bucketPrefix + newName);
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
