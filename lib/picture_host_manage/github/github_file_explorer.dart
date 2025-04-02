import 'dart:io';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' as flutter_services;
import 'package:external_path/external_path.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluro/fluro.dart';
import 'package:path/path.dart' as my_path;
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'package:horopic/router/application.dart';
import 'package:horopic/router/routers.dart';
import 'package:horopic/picture_host_manage/manage_api/github_manage_api.dart';
import 'package:horopic/picture_host_manage/common/loading_state.dart' as loading_state;
import 'package:horopic/utils/global.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/widgets/net_loading_dialog.dart';
import 'package:horopic/utils/image_compressor.dart';
import 'package:horopic/picture_host_manage/common/new_folder_widgets.dart';
import 'package:horopic/picture_host_manage/common/base_file_explorer_page.dart';
import 'package:horopic/picture_host_manage/common/build_bottom_widget.dart';

class GithubFileExplorer extends BaseFileExplorer {
  final Map element;
  final String bucketPrefix;
  const GithubFileExplorer({super.key, required this.element, required this.bucketPrefix});

  @override
  GithubFileExplorerState createState() => GithubFileExplorerState();
}

class GithubFileExplorerState extends BaseFileExplorerState<GithubFileExplorer> {
  Map config = {};
  String adminUserName = '';
  String suffixToken = 'None';

  TextEditingController vc = TextEditingController();
  TextEditingController newFolder = TextEditingController();
  TextEditingController fileLink = TextEditingController();

  GithubManageAPI manageAPI = GithubManageAPI();

  @override
  Future<void> initializeData() async {
    await _getBucketList();
  }

  @override
  Future<void> refreshData() async {
    await _getBucketList();
  }

  _getBucketList() async {
    var configMap = await manageAPI.getConfigMap();
    adminUserName = configMap['githubusername'];
    List files = [];
    List dirs = [];
    files.clear();
    dirs.clear();
    var rootDirSha = '';
    if (widget.bucketPrefix == '') {
      var rootdir = await manageAPI.getRootDirSha(
          widget.element['showedUsername'], widget.element['name'], widget.element['default_branch']);
      if (rootdir[0] != 'success') {
        if (mounted) {
          setState(() {
            state = loading_state.LoadState.error;
          });
        }
        return;
      }
      rootDirSha = rootdir[1];
    }
    var res = await manageAPI.getRepoDirList(widget.element['showedUsername'], widget.element['name'],
        widget.bucketPrefix == '' ? rootDirSha : widget.element['bucketSha']);
    if (res[0] != 'success') {
      if (mounted) {
        setState(() {
          state = loading_state.LoadState.error;
        });
      }
      return;
    }

    for (var i = 0; i < res[1].length; i++) {
      if (res[1][i]['type'] == 'blob') {
        files.add(res[1][i]);
      } else if (res[1][i]['type'] == 'tree') {
        dirs.add(res[1][i]);
      }
    }
    files.sort((a, b) => a['path'].compareTo(b['path']));
    dirs.sort((a, b) => a['path'].compareTo(b['path']));
    fileAllInfoList = files.isEmpty ? [] : List.from(files);
    dirAllInfoList = dirs.isEmpty ? [] : List.from(dirs);
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
  bool isShowSortByDate() => false;

  downloadFile(String urlpath, String fileName) async {
    try {
      BaseOptions baseOptions = setBaseOptions();
      Dio dio = Dio(baseOptions);
      String tempDir = (await getTemporaryDirectory()).path;
      var tempfile = File('$tempDir/$fileName');
      var response = await dio.download(
        urlpath,
        tempfile.path,
        deleteOnError: false,
        options: Options(
          headers: {},
        ),
      );
      if (response.statusCode == 200) {
        return tempfile.path;
      }
      return 'error';
    } catch (e) {
      flogErr(e, {}, 'githubFileExplorerState', 'downloadFile');
    }
    return 'error';
  }

  bool isPublicFile() {
    if (widget.element['showedUsername'].toString().toLowerCase() != adminUserName.toLowerCase() ||
        widget.element['private'] == false) {
      return true;
    }
    return false;
  }

  @override
  Future<String> getShareUrl(int index) async {
    String defaultUrl =
        'https://raw.githubusercontent.com/${widget.element['showedUsername']}/${widget.element['name']}/${widget.element['default_branch']}/${widget.bucketPrefix}${allInfoList[index]['path']}';
    if (isPublicFile()) {
      return defaultUrl;
    }
    var res = await manageAPI.getRepoFileContent(
      widget.element['showedUsername'],
      widget.element['name'],
      widget.bucketPrefix + allInfoList[index]['path'],
    );
    if (res[0] != 'success') {
      return defaultUrl;
    }
    return Uri.decodeFull(res[1]['download_url']);
  }

  @override
  String getFileName(int index) => allInfoList[index]['path'];

  @override
  String getFileDate(int index) {
    return '';
  }

  @override
  String? getFileSizeForList(int index) {
    int size = int.parse((allInfoList[index]['size'] ?? 0).toString().split('.')[0]);
    return size > 0 ? getFileSize(size) : null;
  }

  @override
  Future<void> onFileItemTap(int index) async {
    if (index < dirAllInfoList.length) {
      Map newElement = Map.from(widget.element);
      String prefix = '${widget.bucketPrefix + allInfoList[index]['path']}/';
      newElement['bucketSha'] = allInfoList[index]['sha'];
      Application.router.navigateTo(context,
          '${Routes.githubFileExplorer}?element=${Uri.encodeComponent(jsonEncode(newElement))}&bucketPrefix=${Uri.encodeComponent(prefix)}',
          transition: TransitionType.cupertino);
    } else {
      String urlList = '';
      //判断是否为图片文本
      if (!Global.imgExt.contains(allInfoList[index]['path'].split('.').last.toLowerCase()) &&
          !Global.textExt.contains(allInfoList[index]['path'].split('.').last.toLowerCase())) {
        showToast('不支持的格式');
        return;
      }
      if (Global.imgExt.contains(allInfoList[index]['path'].split('.').last.toLowerCase())) {
        //预览图片
        if (isPublicFile()) {
          int newImageIndex = index - dirAllInfoList.length;
          for (int i = dirAllInfoList.length; i < allInfoList.length; i++) {
            if (Global.imgExt.contains(allInfoList[i]['path'].split('.').last.toLowerCase())) {
              urlList +=
                  'https://raw.githubusercontent.com/${widget.element['showedUsername']}/${widget.element['name']}/${widget.element['default_branch']}/${widget.bucketPrefix}${allInfoList[i]['path']},';
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
        } else {
          int newImageIndex = 0;
          showToast('请稍候，正在获取图片地址');
          var result = await manageAPI.getRepoFileContent(
            widget.element['showedUsername'],
            widget.element['name'],
            widget.bucketPrefix + allInfoList[index]['path'],
          );
          if (result[0] == 'success') {
            urlList += '${result[1]['download_url']}';
          } else {
            showToast('获取图片地址失败');
            return;
          }
          if (context.mounted) {
            Application.router.navigateTo(
                context, '${Routes.albumImagePreview}?index=$newImageIndex&images=${Uri.encodeComponent(urlList)}',
                transition: TransitionType.none);
          }
        }
      } else if (Global.textExt.contains(allInfoList[index]['path'].split('.').last.toLowerCase())) {
        if (isPublicFile()) {
          String urlPath =
              'https://raw.githubusercontent.com/${widget.element['showedUsername']}/${widget.element['name']}/${widget.element['default_branch']}/${widget.bucketPrefix}${allInfoList[index]['path']}';
          showToast('开始获取文件');
          String filePath = await downloadFile(urlPath, allInfoList[index]['path']);
          String fileName = allInfoList[index]['path'];
          if (filePath == 'error') {
            showToast('获取失败');
            return;
          }
          if (context.mounted) {
            Application.router.navigateTo(context,
                '${Routes.mdPreview}?filePath=${Uri.encodeComponent(filePath)}&fileName=${Uri.encodeComponent(fileName)}',
                transition: TransitionType.none);
          }
        } else {
          showToast('请稍候');
          var result = await manageAPI.getRepoFileContent(
            widget.element['showedUsername'],
            widget.element['name'],
            widget.bucketPrefix + allInfoList[index]['path'],
          );
          if (result[0] == 'success') {
            urlList += '${result[1]['download_url']}';
          } else {
            showToast('获取失败');
            return;
          }
          String filePath = await downloadFile(urlList, allInfoList[index]['path']);
          String fileName = allInfoList[index]['path'];
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
  }

  @override
  Future<void> deleteFiles(List<int> toDelete) async {
    toDelete.sort((a, b) => b.compareTo(a));
    for (int index in toDelete) {
      var result = index < dirAllInfoList.length
          ? await manageAPI.deleteFolder(
              widget.element['showedUsername'],
              widget.element['name'],
              '${widget.bucketPrefix + dirAllInfoList[index]['path']}/',
              widget.element['default_branch'],
              dirAllInfoList[index]['sha'],
            )
          : await manageAPI.deleteRepoFile(
              widget.element['showedUsername'],
              widget.element['name'],
              widget.bucketPrefix + allInfoList[index]['path'],
              allInfoList[index]['sha'],
              widget.element['default_branch'],
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
  String getPageTitle() => widget.bucketPrefix == ''
      ? widget.element['name']
      : widget.bucketPrefix.substring(0, widget.bucketPrefix.length - 1).split('/').last;

  @override
  DateTime getFormatedFileDate(dynamic item) {
    return DateTime.now();
  }

  @override
  String getFormatedFileName(dynamic item) {
    return item['path'];
  }

  Future<void> _processUploadFiles(List<File> files, bool isSkipImageCheck) async {
    Map configMapTemp = await manageAPI.getConfigMap();
    Map configMap = {
      'githubusername': configMapTemp['githubusername'],
      'token': configMapTemp['token'],
      'default_branch': widget.element['default_branch'],
      'savePath': widget.bucketPrefix,
      'repo': widget.element['name'],
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
      Global.githubUploadList.add(uploadListStr);
    }
    Global.githubUploadList = removeDuplicates(Global.githubUploadList);
    Global.setGithubUploadList(Global.githubUploadList);
    String downloadPath = await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_DOWNLOAD);
    if (mounted) {
      Application.router
          .navigateTo(context,
              '/baseUpDownloadManagePage?userName=${Uri.encodeComponent(widget.element['showedUsername'])}&repoName=${Uri.encodeComponent(widget.element['name'])}&downloadPath=${Uri.encodeComponent(downloadPath)}&tabIndex=0&currentListIndex=4',
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
                  if (widget.element['showedUsername'].toString().toLowerCase() != adminUserName.toLowerCase()) {
                    showToast('您没有权限上传');
                    return;
                  }
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
                  if (widget.element['showedUsername'].toString().toLowerCase() != adminUserName.toLowerCase()) {
                    showToast('您没有权限上传');
                    return;
                  }
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
                title: const Text('上传剪贴板内链接'),
                onTap: () async {
                  if (widget.element['showedUsername'].toString().toLowerCase() != adminUserName.toLowerCase()) {
                    showToast('您没有权限上传');
                    return;
                  }
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
                        'GithubManagePage',
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
                  if (widget.element['showedUsername'].toString().toLowerCase() != adminUserName.toLowerCase()) {
                    showToastWithContext(context, "只有管理员才能新建文件夹");
                    return;
                  }
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
                              var copyResult =
                                  await manageAPI.createFolder(widget.element, widget.bucketPrefix + newName);
                              if (copyResult[0] == 'success') {
                                showToast('创建成功');
                                setState(() {
                                  _getBucketList();
                                });
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
    List<String> urlList = [];
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
    if (isPublicFile()) {
      String hostPrefix =
          'https://raw.githubusercontent.com/${widget.element['showedUsername']}/${widget.element['name']}/${widget.element['default_branch']}/${widget.bucketPrefix}';
      for (int i = 0; i < downloadList.length; i++) {
        urlList.add(hostPrefix + downloadList[i]['path']);
      }
    } else {
      for (int i = 0; i < downloadList.length; i++) {
        var result = await manageAPI.getRepoFileContent(
          widget.element['showedUsername'],
          widget.element['name'],
          widget.bucketPrefix + downloadList[i]['path'],
        );
        if (result[0] == 'success') {
          urlList.add('${result[1]['download_url']}');
        }
      }
    }
    Global.githubDownloadList.addAll(urlList);
    Global.githubDownloadList = removeDuplicates(Global.githubDownloadList);
    Global.setGithubDownloadList(Global.githubDownloadList);
    String downloadPath = await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_DOWNLOAD);
    Application.router.navigateTo(context,
        '/baseUpDownloadManagePage?userName=${Uri.encodeComponent(widget.element['showedUsername'])}&repoName=${Uri.encodeComponent(widget.element['name'])}&downloadPath=${Uri.encodeComponent(downloadPath)}&tabIndex=1&currentListIndex=4',
        transition: TransitionType.inFromRight);
  }

  @override
  void navigateToDownloadManagement() async {
    String downloadPath = await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_DOWNLOAD);
    int index = Global.githubDownloadList.isEmpty ? 0 : 1;
    if (mounted) {
      Application.router
          .navigateTo(context,
              '/baseUpDownloadManagePage?userName=${Uri.encodeComponent(widget.element['showedUsername'])}&repoName=${Uri.encodeComponent(widget.element['name'])}&downloadPath=${Uri.encodeComponent(downloadPath)}&tabIndex=$index&currentListIndex=4',
              transition: TransitionType.inFromRight)
          .then((value) {
        _getBucketList();
      });
    }
  }

  @override
  void onFileInfoTap(int index) {
    Map<String, dynamic> fileMap = Map<String, dynamic>.from(allInfoList[index]);
    fileMap.addAll({
      'downloadurl':
          'https://raw.githubusercontent.com/${widget.element['showedUsername']}/${widget.element['name']}/${widget.element['default_branch']}/${widget.bucketPrefix}${fileMap['path']}',
      'private': widget.element['private'],
      'path': widget.bucketPrefix + fileMap['path'],
      'showedUsername': widget.element['showedUsername'],
      'name': widget.element['name'],
      'default_branch': widget.element['default_branch'],
      'dir': widget.bucketPrefix,
    });
    Application.router.navigateTo(
        context, '${Routes.githubFileInformation}?fileMap=${Uri.encodeComponent(jsonEncode(fileMap))}',
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
            var result = await manageAPI.setDefaultRepo(
              widget.element,
              '${widget.bucketPrefix + allInfoList[index]['path']}/',
            );
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
    ];
  }
}
