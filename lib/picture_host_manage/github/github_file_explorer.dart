import 'dart:io';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' as flutter_services;

import 'package:external_path/external_path.dart';
import 'package:file_picker/file_picker.dart';
import 'package:f_logs/f_logs.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path/path.dart' as my_path;
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:msh_checkbox/msh_checkbox.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'package:horopic/router/application.dart';
import 'package:horopic/router/routers.dart';
import 'package:horopic/picture_host_manage/manage_api/github_manage_api.dart';
import 'package:horopic/picture_host_manage/common_page/loading_state.dart'
    as loading_state;
import 'package:horopic/utils/global.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/pages/loading.dart';

class GithubFileExplorer extends StatefulWidget {
  final Map element;
  final String bucketPrefix;
  const GithubFileExplorer(
      {Key? key, required this.element, required this.bucketPrefix})
      : super(key: key);

  @override
  GithubFileExplorerState createState() => GithubFileExplorerState();
}

class GithubFileExplorerState
    extends loading_state.BaseLoadingPageState<GithubFileExplorer> {
  Map config = {};
  List fileAllInfoList = [];
  List dirAllInfoList = [];
  List allInfoList = [];
  String adminUserName = '';
  String suffixToken = 'None';

  List selectedFilesBool = [];
  RefreshController refreshController =
      RefreshController(initialRefresh: false);
  TextEditingController vc = TextEditingController();
  TextEditingController newFolder = TextEditingController();
  TextEditingController fileLink = TextEditingController();
  bool sorted = true;

  @override
  void initState() {
    super.initState();
    fileAllInfoList.clear();
    dirAllInfoList.clear();
    _getBucketList();
  }

  _getBucketList() async {
    var configMap = await GithubManageAPI.getConfigMap();
    adminUserName = configMap['githubusername'];
    if (widget.bucketPrefix == '') {
      var rootdir = await GithubManageAPI.getRootDirSha(
          widget.element['showedUsername'],
          widget.element['name'],
          widget.element['default_branch']);
      if (rootdir[0] != 'success') {
        if (mounted) {
          setState(() {
            state = loading_state.LoadState.ERROR;
          });
        }
        return;
      }
      var res = await GithubManageAPI.getRepoDirList(
          widget.element['showedUsername'], widget.element['name'], rootdir[1]);
      if (res[0] != 'success') {
        if (mounted) {
          setState(() {
            state = loading_state.LoadState.ERROR;
          });
        }
        return;
      }

      List files = [];
      List dirs = [];
      files.clear();
      dirs.clear();
      for (var i = 0; i < res[1].length; i++) {
        if (res[1][i]['type'] == 'blob') {
          files.add(res[1][i]);
        } else if (res[1][i]['type'] == 'tree') {
          dirs.add(res[1][i]);
        }
      }
      files.sort((a, b) => a['path'].compareTo(b['path']));
      dirs.sort((a, b) => a['path'].compareTo(b['path']));
      if (files.isEmpty) {
        fileAllInfoList.clear();
      } else {
        fileAllInfoList.clear();
        fileAllInfoList.addAll(files);
      }
      if (dirs.isEmpty) {
        dirAllInfoList.clear();
      } else {
        dirAllInfoList.clear();
        dirAllInfoList.addAll(dirs);
      }
      allInfoList.clear();
      allInfoList.addAll(dirAllInfoList);
      allInfoList.addAll(fileAllInfoList);
      if (allInfoList.isEmpty) {
        if (mounted) {
          setState(() {
            state = loading_state.LoadState.EMPTY;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            selectedFilesBool.clear();
            for (var i = 0; i < allInfoList.length; i++) {
              selectedFilesBool.add(false);
            }
            state = loading_state.LoadState.SUCCESS;
          });
        }
      }
      return;
    } else {
      var res = await GithubManageAPI.getRepoDirList(
          widget.element['showedUsername'],
          widget.element['name'],
          widget.element['bucketSha']);
      if (res[0] != 'success') {
        if (mounted) {
          setState(() {
            state = loading_state.LoadState.ERROR;
          });
        }
        return;
      }

      List files = [];
      List dirs = [];
      files.clear();
      dirs.clear();
      for (var i = 0; i < res[1].length; i++) {
        if (res[1][i]['type'] == 'blob') {
          files.add(res[1][i]);
        } else if (res[1][i]['type'] == 'tree') {
          dirs.add(res[1][i]);
        }
      }
      files.sort((a, b) => a['path'].compareTo(b['path']));
      dirs.sort((a, b) => a['path'].compareTo(b['path']));
      if (files.isEmpty) {
        fileAllInfoList.clear();
      } else {
        fileAllInfoList.clear();
        fileAllInfoList.addAll(files);
      }
      if (dirs.isEmpty) {
        dirAllInfoList.clear();
      } else {
        dirAllInfoList.clear();
        dirAllInfoList.addAll(dirs);
      }
      allInfoList.clear();
      allInfoList.addAll(dirAllInfoList);
      allInfoList.addAll(fileAllInfoList);
      if (allInfoList.isEmpty) {
        if (mounted) {
          setState(() {
            state = loading_state.LoadState.EMPTY;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            selectedFilesBool.clear();
            for (var i = 0; i < allInfoList.length; i++) {
              selectedFilesBool.add(false);
            }
            state = loading_state.LoadState.SUCCESS;
          });
        }
      }
      return;
    }
  }

  _onrefresh() async {
    _getBucketList();
    refreshController.refreshCompleted();
  }

  @override
  void dispose() {
    refreshController.dispose();
    super.dispose();
  }

  downloadFile(String urlpath, String fileName) async {
    try {
      BaseOptions baseOptions = BaseOptions(
        sendTimeout: 30000,
        receiveTimeout: 30000,
        connectTimeout: 30000,
      );
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
      } else {
        return 'error';
      }
    } catch (e) {
      FLog.error(
          className: "githubFileExplorerState",
          methodName: "downloadFile",
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
    }
    return 'error';
  }

  @override
  AppBar get appBar => AppBar(
        elevation: 0,
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
        title: Text(
            widget.bucketPrefix == ''
                ? widget.element['name']
                : widget.bucketPrefix
                    .substring(0, widget.bucketPrefix.length - 1)
                    .split('/')
                    .last,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            )),
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
                PopupMenuItem(
                  child: const Center(
                      child: Text(
                    '文件名称排序',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                    ),
                  )),
                  onTap: () {
                    if (sorted == true) {
                      if (dirAllInfoList.isEmpty) {
                        allInfoList.sort((a, b) {
                          return a['path'].compareTo(b['path']);
                        });
                      } else {
                        List temp = allInfoList.sublist(
                            dirAllInfoList.length, allInfoList.length);
                        temp.sort((a, b) {
                          return a['path'].compareTo(b['path']);
                        });
                        allInfoList.clear();
                        allInfoList.addAll(dirAllInfoList);
                        allInfoList.addAll(temp);
                      }
                      setState(() {
                        sorted = false;
                      });
                    } else {
                      if (dirAllInfoList.isEmpty) {
                        allInfoList.sort((a, b) {
                          return b['path'].compareTo(a['path']);
                        });
                      } else {
                        List temp = allInfoList.sublist(
                            dirAllInfoList.length, allInfoList.length);
                        temp.sort((a, b) {
                          return b['path'].compareTo(a['path']);
                        });
                        allInfoList.clear();
                        allInfoList.addAll(dirAllInfoList);
                        allInfoList.addAll(temp);
                      }
                      setState(() {
                        sorted = true;
                      });
                    }
                  },
                ),
                PopupMenuItem(
                  child: const Center(
                      child: Text(
                    '文件大小排序',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                    ),
                  )),
                  onTap: () {
                    if (sorted == true) {
                      if (dirAllInfoList.isEmpty) {
                        allInfoList.sort((a, b) {
                          return a['size'].compareTo(b['size']);
                        });
                      } else {
                        List temp = allInfoList.sublist(
                            dirAllInfoList.length, allInfoList.length);
                        temp.sort((a, b) {
                          return a['size'].compareTo(b['size']);
                        });
                        allInfoList.clear();
                        allInfoList.addAll(dirAllInfoList);
                        allInfoList.addAll(temp);
                      }
                      setState(() {
                        sorted = false;
                      });
                    } else {
                      if (dirAllInfoList.isEmpty) {
                        allInfoList.sort((a, b) {
                          return b['size'].compareTo(a['size']);
                        });
                      } else {
                        List temp = allInfoList.sublist(
                            dirAllInfoList.length, allInfoList.length);
                        temp.sort((a, b) {
                          return b['size'].compareTo(a['size']);
                        });
                        allInfoList.clear();
                        allInfoList.addAll(dirAllInfoList);
                        allInfoList.addAll(temp);
                      }
                      setState(() {
                        sorted = true;
                      });
                    }
                  },
                ),
                PopupMenuItem(
                  child: const Center(
                      child: Text(
                    '文件类型排序',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                    ),
                  )),
                  onTap: () {
                    if (sorted == true) {
                      if (dirAllInfoList.isEmpty) {
                        allInfoList.sort((a, b) {
                          String type = a['path'].split('.').last;
                          String type2 = b['path'].split('.').last;
                          if (type.isEmpty) {
                            return 1;
                          } else if (type2.isEmpty) {
                            return -1;
                          } else {
                            return type.compareTo(type2);
                          }
                        });
                      } else {
                        List temp = allInfoList.sublist(
                            dirAllInfoList.length, allInfoList.length);
                        temp.sort((a, b) {
                          String type = a['path'].split('.').last;
                          String type2 = b['path'].split('.').last;
                          if (type.isEmpty) {
                            return 1;
                          } else if (type2.isEmpty) {
                            return -1;
                          } else {
                            return type.compareTo(type2);
                          }
                        });
                        allInfoList.clear();
                        allInfoList.addAll(dirAllInfoList);
                        allInfoList.addAll(temp);
                      }
                      setState(() {
                        sorted = false;
                      });
                    } else {
                      if (dirAllInfoList.isEmpty) {
                        allInfoList.sort((a, b) {
                          String type = a['path'].split('.').last;
                          String type2 = b['path'].split('.').last;
                          if (type.isEmpty) {
                            return -1;
                          } else if (type2.isEmpty) {
                            return 1;
                          } else {
                            return type2.compareTo(type);
                          }
                        });
                      } else {
                        List temp = allInfoList.sublist(
                            dirAllInfoList.length, allInfoList.length);
                        temp.sort((a, b) {
                          String type = a['path'].split('.').last;
                          String type2 = b['path'].split('.').last;
                          if (type.isEmpty) {
                            return -1;
                          } else if (type2.isEmpty) {
                            return 1;
                          } else {
                            return type2.compareTo(type);
                          }
                        });
                        allInfoList.clear();
                        allInfoList.addAll(dirAllInfoList);
                        allInfoList.addAll(temp);
                      }
                      setState(() {
                        sorted = true;
                      });
                    }
                  },
                ),
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
                            leading: const Icon(Icons.file_present_outlined,
                                color: Colors.blue),
                            title: const Text('上传文件(可多选)'),
                            onTap: () async {
                              if (widget.element['showedUsername'] !=
                                  adminUserName) {
                                showToast('您没有权限上传文件');
                                return;
                              }
                              Navigator.pop(context);
                              FilePickerResult? pickresult =
                                  await FilePicker.platform.pickFiles(
                                allowMultiple: true,
                              );
                              if (pickresult == null) {
                                showToast('未选择文件');
                              } else {
                                List<File> files = pickresult.paths
                                    .map((path) => File(path!))
                                    .toList();
                                Map configMapTemp =
                                    await GithubManageAPI.getConfigMap();
                                Map configMap = {};
                                configMap['githubusername'] =
                                    configMapTemp['githubusername'];
                                configMap['token'] = configMapTemp['token'];
                                configMap['default_branch'] =
                                    widget.element['default_branch'];
                                configMap['savePath'] = widget.bucketPrefix;
                                configMap['repo'] = widget.element['name'];
                                for (int i = 0; i < files.length; i++) {
                                  List uploadList = [
                                    files[i].path,
                                    my_path.basename(files[i].path),
                                    configMap
                                  ];
                                  String uploadListStr = jsonEncode(uploadList);
                                  Global.githubUploadList.add(uploadListStr);
                                }
                                await Global.setGithubUploadList(
                                    Global.githubUploadList);
                                String downloadPath = await ExternalPath
                                    .getExternalStoragePublicDirectory(
                                        ExternalPath.DIRECTORY_DOWNLOADS);
                                if (mounted) {
                                  Application.router
                                      .navigateTo(context,
                                          '/githubUpDownloadManagePage?userName=${Uri.encodeComponent(widget.element['showedUsername'])}&repoName=${Uri.encodeComponent(widget.element['name'])}&downloadPath=${Uri.encodeComponent(downloadPath)}&tabIndex=0',
                                          transition:
                                              TransitionType.inFromRight)
                                      .then((value) {
                                    _getBucketList();
                                  });
                                }
                              }
                            },
                          ),
                          ListTile(
                            minLeadingWidth: 0,
                            leading: const Icon(Icons.image_outlined,
                                color: Colors.blue),
                            title: const Text('上传照片(可多选)'),
                            onTap: () async {
                              if (widget.element['showedUsername'] !=
                                  adminUserName) {
                                showToast('您没有权限上传照片');
                                return;
                              }
                              Navigator.pop(context);
                              AssetPickerConfig config =
                                  const AssetPickerConfig(
                                maxAssets: 100,
                                selectedAssets: [],
                              );
                              final List<AssetEntity>? pickedImage =
                                  await AssetPicker.pickAssets(context,
                                      pickerConfig: config);
                              if (pickedImage == null) {
                                showToast('未选择照片');
                              } else {
                                List<File> files = [];
                                for (var i = 0; i < pickedImage.length; i++) {
                                  File? fileImage =
                                      await pickedImage[i].originFile;
                                  if (fileImage != null) {
                                    files.add(fileImage);
                                  }
                                }
                                Map configMapTemp =
                                    await GithubManageAPI.getConfigMap();
                                Map configMap = {};
                                configMap['githubusername'] =
                                    configMapTemp['githubusername'];
                                configMap['token'] = configMapTemp['token'];
                                configMap['default_branch'] =
                                    widget.element['default_branch'];
                                configMap['savePath'] = widget.bucketPrefix;
                                configMap['repo'] = widget.element['name'];
                                for (int i = 0; i < files.length; i++) {
                                  List uploadList = [
                                    files[i].path,
                                    my_path.basename(files[i].path),
                                    configMap
                                  ];
                                  String uploadListStr = jsonEncode(uploadList);
                                  Global.githubUploadList.add(uploadListStr);
                                }
                                await Global.setGithubUploadList(
                                    Global.githubUploadList);
                                String downloadPath = await ExternalPath
                                    .getExternalStoragePublicDirectory(
                                        ExternalPath.DIRECTORY_DOWNLOADS);
                                if (mounted) {
                                  Application.router
                                      .navigateTo(context,
                                          '/githubUpDownloadManagePage?userName=${Uri.encodeComponent(widget.element['showedUsername'])}&repoName=${Uri.encodeComponent(widget.element['name'])}&downloadPath=${Uri.encodeComponent(downloadPath)}&tabIndex=0',
                                          transition:
                                              TransitionType.inFromRight)
                                      .then((value) {
                                    _getBucketList();
                                  });
                                }
                              }
                            },
                          ),
                          ListTile(
                            minLeadingWidth: 0,
                            leading: const Icon(Icons.link, color: Colors.blue),
                            title: const Text('上传剪贴板内链接(换行分隔多个)'),
                            onTap: () async {
                              if (widget.element['showedUsername'] !=
                                  adminUserName) {
                                showToast('您没有权限上传链接');
                                return;
                              }
                              Navigator.pop(context);
                              var url =
                                  await flutter_services.Clipboard.getData(
                                      'text/plain');
                              if (url == null ||
                                  url.text == null ||
                                  url.text!.isEmpty) {
                                if (mounted) {
                                  showToastWithContext(context, "剪贴板为空");
                                }
                                return;
                              }
                              try {
                                String urlStr = url.text!;
                                List fileLinkList = urlStr.split("\n");
                                await showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (context) {
                                      return NetLoadingDialog(
                                        outsideDismiss: false,
                                        loading: true,
                                        loadingText: "上传中...",
                                        requestCallBack: GithubManageAPI
                                            .uploadNetworkFileEntry(
                                                fileLinkList,
                                                widget.element,
                                                widget.bucketPrefix),
                                      );
                                    });
                                _getBucketList();
                              } catch (e) {
                                FLog.error(
                                    className: "GithubManagePage",
                                    methodName: "uploadNetworkFileEntry",
                                    text: formatErrorMessage({
                                      'url': url.text,
                                    }, e.toString()),
                                    dataLogType: DataLogType.ERRORS.toString());
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
                              if (widget.element['showedUsername'] !=
                                  adminUserName) {
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
                                        title: "  请输入新文件夹名\n / 分隔创建嵌套文件夹",
                                        okBtnTap: () async {
                                          String newName = newFolder.text;
                                          if (newName.isEmpty) {
                                            showToastWithContext(
                                                context, "文件夹名不能为空");
                                            return;
                                          }
                                          if (newName.startsWith("/")) {
                                            newName = newName.substring(1);
                                          }
                                          var copyResult = await GithubManageAPI
                                              .createFolder(
                                                  widget.element,
                                                  widget.bucketPrefix +
                                                      newName);
                                          if (copyResult[0] == 'success') {
                                            showToast('创建成功');
                                            setState(() {
                                              _getBucketList();
                                            });
                                          } else {
                                            showToast('创建失败');
                                          }
                                        },
                                        vc: newFolder,
                                        cancelBtnTap: () {},
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
                    await ExternalPath.getExternalStoragePublicDirectory(
                        ExternalPath.DIRECTORY_DOWNLOADS);
                // ignore: use_build_context_synchronously
                int index = 1;
                if (Global.githubDownloadList.isEmpty) {
                  index = 0;
                }
                if (mounted) {
                  Application.router
                      .navigateTo(context,
                          '/githubUpDownloadManagePage?userName=${Uri.encodeComponent(widget.element['showedUsername'])}&repoName=${Uri.encodeComponent(widget.element['name'])}&downloadPath=${Uri.encodeComponent(downloadPath)}&tabIndex=$index',
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
                ? const Icon(Icons.delete,
                    color: Color.fromARGB(255, 236, 127, 120), size: 30.0)
                : const Icon(Icons.delete_outline,
                    color: Colors.white, size: 30.0),
            onPressed: () async {
              if (!selectedFilesBool.contains(true) ||
                  selectedFilesBool.isEmpty) {
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
                    Navigator.pop(context);
                    await deleteAll(toDelete);
                    showToast('删除完成');
                    return;
                  } catch (e) {
                    FLog.error(
                        className: 'GithubBucketPage',
                        methodName: 'deleteAll',
                        text: formatErrorMessage({}, e.toString()),
                        dataLogType: DataLogType.ERRORS.toString());
                    showToast('删除失败');
                  }
                },
              );
            },
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: buildStateWidget,
      floatingActionButtonLocation: state == loading_state.LoadState.ERROR ||
              state == loading_state.LoadState.EMPTY ||
              state == loading_state.LoadState.LOADING
          ? null
          : FloatingActionButtonLocation.centerFloat,
      floatingActionButton: state == loading_state.LoadState.ERROR ||
              state == loading_state.LoadState.EMPTY ||
              state == loading_state.LoadState.LOADING
          ? null
          : floatingActionButton,
    );
  }

  Widget get floatingActionButton => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
              height: 40,
              width: 40,
              child: FloatingActionButton(
                heroTag: 'download',
                backgroundColor: selectedFilesBool.contains(true)
                    ? const Color.fromARGB(255, 180, 236, 182)
                    : Colors.transparent,
                onPressed: () async {
                  if (!selectedFilesBool.contains(true) ||
                      selectedFilesBool.isEmpty) {
                    showToastWithContext(context, '没有选择文件');
                    return;
                  }
                  if (widget.element['showedUsername'] != adminUserName ||
                      widget.element['private'] == false) {
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
                    String hostPrefix =
                        'https://gh.api.99988866.xyz/https://raw.githubusercontent.com/${widget.element['showedUsername']}/${widget.element['name']}/${widget.element['default_branch']}/${widget.bucketPrefix}';
                    List<String> urlList = [];
                    for (int i = 0; i < downloadList.length; i++) {
                      urlList.add(hostPrefix + downloadList[i]['path']);
                    }
                    Global.githubDownloadList.addAll(urlList);
                    await Global.setGithubDownloadList(
                        Global.githubDownloadList);
                    String downloadPath =
                        await ExternalPath.getExternalStoragePublicDirectory(
                            ExternalPath.DIRECTORY_DOWNLOADS);
                    // ignore: use_build_context_synchronously
                    Application.router.navigateTo(context,
                        '/githubUpDownloadManagePage?userName=${Uri.encodeComponent(widget.element['showedUsername'])}&repoName=${Uri.encodeComponent(widget.element['name'])}&downloadPath=${Uri.encodeComponent(downloadPath)}&tabIndex=1',
                        transition: TransitionType.inFromRight);
                  } else {
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
                    showToast('私有仓库获取链接时间长，请耐心等待');
                    List<String> urlList = [];
                    for (int i = 0; i < downloadList.length; i++) {
                      var result = await GithubManageAPI.getRepoFileContent(
                        widget.element['showedUsername'],
                        widget.element['name'],
                        widget.bucketPrefix + downloadList[i]['path'],
                      );
                      if (result[0] == 'success') {
                        urlList.add(
                            'https://gh.api.99988866.xyz/${result[1]['download_url']}');
                      }
                    }
                    Global.githubDownloadList.addAll(urlList);
                    await Global.setGithubDownloadList(
                        Global.githubDownloadList);
                    String downloadPath =
                        await ExternalPath.getExternalStoragePublicDirectory(
                            ExternalPath.DIRECTORY_DOWNLOADS);
                    // ignore: use_build_context_synchronously
                    Application.router.navigateTo(context,
                        '/githubUpDownloadManagePage?userName=${Uri.encodeComponent(widget.element['showedUsername'])}&repoName=${Uri.encodeComponent(widget.element['name'])}&downloadPath=${Uri.encodeComponent(downloadPath)}&tabIndex=1',
                        transition: TransitionType.inFromRight);
                  }
                },
                child: const Icon(
                  Icons.download,
                  color: Colors.white,
                  size: 25,
                ),
              )),
          const SizedBox(width: 20),
          SizedBox(
              height: 40,
              width: 40,
              child: FloatingActionButton(
                heroTag: 'copy',
                backgroundColor: selectedFilesBool.contains(true)
                    ? const Color.fromARGB(255, 232, 177, 241)
                    : Colors.transparent,
                elevation: 5,
                onPressed: () async {
                  if (!selectedFilesBool.contains(true)) {
                    showToastWithContext(context, '请先选择文件');
                    return;
                  } else {
                    if (widget.element['showedUsername'] != adminUserName ||
                        widget.element['private'] == false) {
                      List multiUrls = [];
                      for (int i = 0; i < allInfoList.length; i++) {
                        if (selectedFilesBool[i]) {
                          String finalFormatedurl = ' ';
                          String rawurl = '';
                          String fileName = '';
                          rawurl =
                              'https://raw.githubusercontent.com/${widget.element['showedUsername']}/${widget.element['name']}/${widget.element['default_branch']}/${widget.bucketPrefix}${allInfoList[i]['path']}';
                          fileName = allInfoList[i]['path'];
                          finalFormatedurl =
                              linkGenerateDict[Global.defaultLKformat]!(
                                  rawurl, fileName);

                          multiUrls.add(finalFormatedurl);
                        }
                      }
                      await flutter_services.Clipboard.setData(
                          flutter_services.ClipboardData(
                              text: multiUrls
                                  .toString()
                                  .substring(1, multiUrls.toString().length - 1)
                                  .replaceAll(', ', '\n')
                                  .replaceAll(',', '\n')));
                      if (mounted) {
                        showToastWithContext(context, '已复制全部链接');
                      }
                    } else {
                      showToastWithContext(context, '私有仓库获取链接时间较长，请耐心等待');
                      List multiUrls = [];
                      int successCount = 0;
                      int failCount = 0;
                      for (int i = 0; i < allInfoList.length; i++) {
                        if (selectedFilesBool[i]) {
                          String finalFormatedurl = ' ';
                          String rawurl = '';
                          String fileName = '';
                          var res = await GithubManageAPI.getRepoFileContent(
                            widget.element['showedUsername'],
                            widget.element['name'],
                            widget.bucketPrefix + allInfoList[i]['path'],
                          );
                          if (res[0] == 'success') {
                            successCount++;
                            rawurl = Uri.decodeFull(res[1]['download_url']);
                          } else {
                            failCount++;
                          }
                          fileName = allInfoList[i]['path'];
                          finalFormatedurl =
                              linkGenerateDict[Global.defaultLKformat]!(
                                  rawurl, fileName);
                          multiUrls.add(finalFormatedurl);
                        }
                      }
                      await flutter_services.Clipboard.setData(
                          flutter_services.ClipboardData(
                              text: multiUrls
                                  .toString()
                                  .substring(1, multiUrls.toString().length - 1)
                                  .replaceAll(', ', '\n')
                                  .replaceAll(',', '\n')));
                      if (successCount == 0) {
                        showToast('获取链接失败');
                      } else if (failCount == 0) {
                        showToast('获取链接成功');
                      } else {
                        showToast('获取链接成功$successCount个');
                      }
                    }
                  }
                },
                child: const Icon(
                  Icons.copy,
                  color: Colors.white,
                  size: 20,
                ),
              )),
          const SizedBox(width: 20),
          SizedBox(
              height: 40,
              width: 40,
              child: FloatingActionButton(
                heroTag: 'select',
                backgroundColor: const Color.fromARGB(255, 248, 196, 237),
                elevation: 50,
                onPressed: () async {
                  if (allInfoList.isEmpty) {
                    showToastWithContext(context, '目录为空');
                    return;
                  } else if (selectedFilesBool.contains(true)) {
                    setState(() {
                      for (int i = 0; i < selectedFilesBool.length; i++) {
                        selectedFilesBool[i] = false;
                      }
                    });
                  } else {
                    setState(() {
                      for (int i = 0; i < selectedFilesBool.length; i++) {
                        selectedFilesBool[i] = true;
                      }
                    });
                  }
                },
                child: const Icon(
                  Icons.check_circle_outline,
                  color: Colors.white,
                  size: 25,
                ),
              )),
        ],
      );

  deleteAll(List toDelete) async {
    try {
      for (int i = 0; i < toDelete.length; i++) {
        if ((toDelete[i] - i) < dirAllInfoList.length) {
          await GithubManageAPI.deleteFolder(
            widget.element['showedUsername'],
            widget.element['name'],
            '${widget.bucketPrefix + dirAllInfoList[toDelete[i] - i]['path']}/',
            widget.element['default_branch'],
            allInfoList[toDelete[i] - i]['sha'],
          );
          setState(() {
            allInfoList.removeAt(toDelete[i] - i);
            dirAllInfoList.removeAt(toDelete[i] - i);
            selectedFilesBool.removeAt(toDelete[i] - i);
          });
        } else {
          await GithubManageAPI.deleteRepoFile(
            widget.element['showedUsername'],
            widget.element['name'],
            widget.bucketPrefix + allInfoList[toDelete[i] - i]['path'],
            allInfoList[toDelete[i] - i]['sha'],
            widget.element['default_branch'],
          );
          setState(() {
            allInfoList.removeAt(toDelete[i] - i);
            fileAllInfoList.removeAt(toDelete[i] - i - dirAllInfoList.length);
            selectedFilesBool.removeAt(toDelete[i] - i);
          });
        }
      }
      if (allInfoList.isEmpty) {
        setState(() {
          state = loading_state.LoadState.EMPTY;
        });
      }
    } catch (e) {
      FLog.error(
          className: "GithubFilePage",
          methodName: "deleteAll",
          text: formatErrorMessage({
            'toDelete': toDelete,
          }, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      rethrow;
    }
  }

  @override
  Widget buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/empty.png',
            width: 100,
            height: 100,
          ),
          const Text('没有文件哦，点击右上角添加吧',
              style: TextStyle(
                  fontSize: 20, color: Color.fromARGB(136, 121, 118, 118)))
        ],
      ),
    );
  }

  @override
  Widget buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('加载失败,请先登录或者检查网络',
              style: TextStyle(
                  fontSize: 20, color: Color.fromARGB(136, 121, 118, 118))),
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.blue),
            ),
            onPressed: () {
              setState(() {
                state = loading_state.LoadState.LOADING;
              });
              _getBucketList();
            },
            child: const Text('重新加载'),
          )
        ],
      ),
    );
  }

  @override
  Widget buildLoading() {
    return const Center(
      child: SizedBox(
        width: 30,
        height: 30,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          backgroundColor: Colors.transparent,
          valueColor: AlwaysStoppedAnimation(Colors.blue),
        ),
      ),
    );
  }

  @override
  Widget buildSuccess() {
    if (allInfoList.isEmpty) {
      return buildEmpty();
    } else {
      return SmartRefresher(
        controller: refreshController,
        enablePullDown: true,
        enablePullUp: false,
        header: const ClassicHeader(
          refreshStyle: RefreshStyle.Follow,
          idleText: '下拉刷新',
          refreshingText: '正在刷新',
          completeText: '刷新完成',
          failedText: '刷新失败',
          releaseText: '释放刷新',
        ),
        footer: const ClassicFooter(
          loadStyle: LoadStyle.ShowWhenLoading,
          idleText: '上拉加载',
          loadingText: '正在加载',
          noDataText: '没有更多啦',
          failedText: '没有更多啦',
          canLoadingText: '释放加载',
        ),
        onRefresh: _onrefresh,
        child: ListView.builder(
          itemCount: allInfoList.length,
          itemBuilder: (context, index) {
            if (index < dirAllInfoList.length) {
              return Container(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: Column(
                  children: [
                    Slidable(
                      direction: Axis.horizontal,
                      endActionPane: ActionPane(
                        motion: const ScrollMotion(),
                        children: [
                          SlidableAction(
                            onPressed: (BuildContext context) async {
                              if (widget.element['showedUsername'] ==
                                  adminUserName) {
                                showCupertinoDialog(
                                    barrierDismissible: true,
                                    context: context,
                                    builder: (BuildContext context) {
                                      return CupertinoAlertDialog(
                                        title: const Text('通知'),
                                        content: Text(
                                            '确定要删除${allInfoList[index]['path']}吗？'),
                                        actions: <Widget>[
                                          CupertinoDialogAction(
                                            child: const Text('取消',
                                                style: TextStyle(
                                                    color: Colors.blue)),
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                          ),
                                          CupertinoDialogAction(
                                            child: const Text('确定',
                                                style: TextStyle(
                                                    color: Colors.blue)),
                                            onPressed: () async {
                                              Navigator.pop(context);
                                              await showDialog(
                                                  context: context,
                                                  barrierDismissible: false,
                                                  builder: (context) {
                                                    return NetLoadingDialog(
                                                      outsideDismiss: false,
                                                      loading: true,
                                                      loadingText: "删除中...",
                                                      requestCallBack: GithubManageAPI
                                                          .deleteFolder(
                                                              widget.element[
                                                                  'showedUsername'],
                                                              widget.element[
                                                                  'name'],
                                                              '${widget.bucketPrefix + allInfoList[index]['path']}/',
                                                              widget.element[
                                                                  'default_branch'],
                                                              allInfoList[index]
                                                                  ['sha']),
                                                    );
                                                  });
                                              setState(() {
                                                showToast('操作完毕');
                                                _onrefresh();
                                              });
                                            },
                                          ),
                                        ],
                                      );
                                    });
                              } else {
                                showToast('您没有权限删除');
                              }
                            },
                            backgroundColor: const Color(0xFFFE4A49),
                            foregroundColor: Colors.white,
                            spacing: 0,
                            icon: Icons.delete,
                            label: '删除',
                          ),
                        ],
                      ),
                      child: Stack(
                        fit: StackFit.loose,
                        children: [
                          Container(
                            color: selectedFilesBool[index]
                                ? const Color(0x311192F3)
                                : Colors.transparent,
                            child: ListTile(
                              minLeadingWidth: 0,
                              minVerticalPadding: 0,
                              leading: Image.asset(
                                'assets/icons/folder.png',
                                width: 30,
                                height: 32,
                              ),
                              title: Text(allInfoList[index]['path'],
                                  style: const TextStyle(fontSize: 16)),
                              trailing: IconButton(
                                icon: const Icon(Icons.more_horiz),
                                onPressed: () {
                                  if (widget.element['showedUsername'] ==
                                      adminUserName) {
                                    String iconPath = 'assets/icons/folder.png';
                                    showModalBottomSheet(
                                        isScrollControlled: true,
                                        context: context,
                                        builder: (context) {
                                          return buildFolderBottomSheetWidget(
                                              context, index, iconPath);
                                        });
                                  } else {
                                    showToast('您没有权限');
                                  }
                                },
                              ),
                              onTap: () {
                                Map newElement = Map.from(widget.element);
                                String prefix =
                                    '${widget.bucketPrefix + allInfoList[index]['path']}/';
                                newElement['bucketSha'] =
                                    allInfoList[index]['sha'];
                                Application.router.navigateTo(context,
                                    '${Routes.githubFileExplorer}?element=${Uri.encodeComponent(jsonEncode(newElement))}&bucketPrefix=${Uri.encodeComponent(prefix)}',
                                    transition: TransitionType.cupertino);
                              },
                            ),
                          ),
                          Positioned(
                            // ignore: sort_child_properties_last
                            child: Container(
                              decoration: const BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(55)),
                                  color: Color.fromARGB(255, 235, 242, 248)),
                              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                              child: MSHCheckbox(
                                uncheckedColor: Colors.blue,
                                size: 17,
                                checkedColor: Colors.blue,
                                value: selectedFilesBool[index],
                                style: MSHCheckboxStyle.fillScaleCheck,
                                onChanged: (selected) {
                                  setState(() {
                                    if (selected) {
                                      selectedFilesBool[index] = true;
                                    } else {
                                      selectedFilesBool[index] = false;
                                    }
                                  });
                                },
                              ),
                            ),
                            left: -0.5,
                            top: 20,
                          )
                        ],
                      ),
                    ),
                    const Divider(
                      height: 1,
                    )
                  ],
                ),
              );
            } else {
              String fileExtension = allInfoList[index]['path'].split('.').last;
              fileExtension = fileExtension.toLowerCase();
              String iconPath = 'assets/icons/';
              if (fileExtension == '') {
                iconPath += '_blank.png';
              } else if (Global.iconList.contains(fileExtension)) {
                iconPath += '$fileExtension.png';
              } else {
                iconPath += 'unknown.png';
              }
              return Container(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: Column(
                  children: [
                    Slidable(
                        key: Key(allInfoList[index]['path']),
                        direction: Axis.horizontal,
                        endActionPane: ActionPane(
                          motion: const ScrollMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (BuildContext context) async {
                                if (widget.element['showedUsername'] !=
                                        adminUserName ||
                                    widget.element['private'] == false) {
                                  String shareUrl =
                                      'https://raw.githubusercontent.com/${widget.element['showedUsername']}/${widget.element['name']}/${widget.element['default_branch']}/${widget.bucketPrefix}${allInfoList[index]['path']}';
                                  Share.share(shareUrl);
                                } else {
                                  showToast('开始获取私有仓库分享链接');
                                  var result =
                                      await GithubManageAPI.getRepoFileContent(
                                          widget.element['showedUsername'],
                                          widget.element['name'],
                                          widget.bucketPrefix +
                                              allInfoList[index]['path']);
                                  if (result[0] == 'success') {
                                    String shareUrl = result[1]['download_url'];
                                    Share.share(shareUrl);
                                  } else {
                                    showToast('获取失败');
                                  }
                                }
                              },
                              autoClose: true,
                              padding: EdgeInsets.zero,
                              backgroundColor:
                                  const Color.fromARGB(255, 109, 196, 116),
                              foregroundColor: Colors.white,
                              icon: Icons.share,
                              label: '分享',
                            ),
                            SlidableAction(
                              onPressed: (BuildContext context) async {
                                if (widget.element['showedUsername'] ==
                                    adminUserName) {
                                  showCupertinoDialog(
                                    barrierDismissible: true,
                                    context: context,
                                    builder: (BuildContext context) {
                                      return CupertinoAlertDialog(
                                        title: const Text('通知'),
                                        content: Text(
                                            '确定要删除${allInfoList[index]['path']}吗？'),
                                        actions: <Widget>[
                                          CupertinoDialogAction(
                                            child: const Text('取消',
                                                style: TextStyle(
                                                    color: Colors.blue)),
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                          ),
                                          CupertinoDialogAction(
                                            child: const Text('确定',
                                                style: TextStyle(
                                                    color: Colors.blue)),
                                            onPressed: () async {
                                              Navigator.pop(context);
                                              String path = widget
                                                      .bucketPrefix +
                                                  allInfoList[index]['path'];
                                              var result = await GithubManageAPI
                                                  .deleteRepoFile(
                                                      widget.element[
                                                          'showedUsername'],
                                                      widget.element['name'],
                                                      path,
                                                      allInfoList[index]['sha'],
                                                      widget.element[
                                                          'default_branch']);
                                              if (result[0] == 'success') {
                                                showToast('删除成功');
                                                setState(() {
                                                  allInfoList.removeAt(index);
                                                  selectedFilesBool
                                                      .removeAt(index);
                                                });
                                              } else {
                                                showToast('删除失败');
                                              }
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                } else {
                                  showToast('只有管理员才能删除文件');
                                }
                              },
                              backgroundColor: const Color(0xFFFE4A49),
                              foregroundColor: Colors.white,
                              icon: Icons.delete,
                              label: '删除',
                            ),
                          ],
                        ),
                        child: Stack(fit: StackFit.loose, children: [
                          Container(
                            color: selectedFilesBool[index]
                                ? const Color(0x311192F3)
                                : Colors.transparent,
                            child: ListTile(
                              minLeadingWidth: 0,
                              minVerticalPadding: 0,
                              leading: Image.asset(
                                iconPath,
                                width: 30,
                                height: 30,
                              ),
                              title: Text(
                                  allInfoList[index]['path'].length > 20
                                      ? allInfoList[index]['path']
                                              .substring(0, 10) +
                                          '...' +
                                          allInfoList[index]['path'].substring(
                                              allInfoList[index]['path']
                                                      .length -
                                                  10)
                                      : allInfoList[index]['path'],
                                  style: const TextStyle(fontSize: 14)),
                              subtitle: Text(
                                  getFileSize(allInfoList[index]['size']),
                                  style: const TextStyle(fontSize: 12)),
                              trailing: IconButton(
                                icon: const Icon(Icons.more_horiz),
                                onPressed: () {
                                  showModalBottomSheet(
                                      isScrollControlled: true,
                                      context: context,
                                      builder: (context) {
                                        return buildBottomSheetWidget(
                                            context, index, iconPath);
                                      });
                                },
                              ),
                              onTap: () async {
                                String urlList = '';
                                //判断是否为图片文本
                                if (!Global.imgExt.contains(allInfoList[index]
                                            ['path']
                                        .split('.')
                                        .last
                                        .toLowerCase()) &&
                                    !Global.textExt.contains(allInfoList[index]
                                            ['path']
                                        .split('.')
                                        .last
                                        .toLowerCase())) {
                                  showToast('不支持的格式');
                                  return;
                                }
                                if (Global.imgExt.contains(allInfoList[index]
                                        ['path']
                                    .split('.')
                                    .last
                                    .toLowerCase())) {
                                  //预览图片
                                  if (widget.element['showedUsername'] !=
                                          adminUserName ||
                                      widget.element['private'] == false) {
                                    int newImageIndex =
                                        index - dirAllInfoList.length;
                                    for (int i = dirAllInfoList.length;
                                        i < allInfoList.length;
                                        i++) {
                                      if (Global.imgExt.contains(allInfoList[i]
                                              ['path']
                                          .split('.')
                                          .last
                                          .toLowerCase())) {
                                        if (widget.element['showedUsername'] !=
                                                adminUserName ||
                                            widget.element['private'] ==
                                                false) {
                                          urlList +=
                                              'https://gh.api.99988866.xyz/https://raw.githubusercontent.com/${widget.element['showedUsername']}/${widget.element['name']}/${widget.element['default_branch']}/${widget.bucketPrefix}${allInfoList[i]['path']},';
                                        } else {
                                          var result = await GithubManageAPI
                                              .getRepoFileContent(
                                            widget.element['showedUsername'],
                                            widget.element['name'],
                                            widget.bucketPrefix +
                                                allInfoList[i]['path'],
                                          );
                                          if (result[0] == 'success') {
                                            urlList +=
                                                'https://gh.api.99988866.xyz/${result[1]['download_url']},';
                                          }
                                        }
                                      } else if (i < index) {
                                        newImageIndex--;
                                      }
                                    }
                                    urlList = urlList.substring(
                                        0, urlList.length - 1);
                                    Application.router.navigateTo(this.context,
                                        '${Routes.albumImagePreview}?index=$newImageIndex&images=${Uri.encodeComponent(urlList)}',
                                        transition: TransitionType.none);
                                  } else {
                                    int newImageIndex = 0;
                                    showToast('请稍候，正在获取图片地址');
                                    var result = await GithubManageAPI
                                        .getRepoFileContent(
                                      widget.element['showedUsername'],
                                      widget.element['name'],
                                      widget.bucketPrefix +
                                          allInfoList[index]['path'],
                                    );
                                    if (result[0] == 'success') {
                                      urlList +=
                                          'https://gh.api.99988866.xyz/${result[1]['download_url']}';
                                    } else {
                                      showToast('获取图片地址失败');
                                      return;
                                    }
                                    Application.router.navigateTo(this.context,
                                        '${Routes.albumImagePreview}?index=$newImageIndex&images=${Uri.encodeComponent(urlList)}',
                                        transition: TransitionType.none);
                                  }
                                } else if (Global.textExt.contains(
                                    allInfoList[index]['path']
                                        .split('.')
                                        .last
                                        .toLowerCase())) {
                                  if (widget.element['showedUsername'] !=
                                          adminUserName ||
                                      widget.element['private'] == false) {
                                    String urlPath =
                                        'https://gh.api.99988866.xyz/https://raw.githubusercontent.com/${widget.element['showedUsername']}/${widget.element['name']}/${widget.element['default_branch']}/${widget.bucketPrefix}${allInfoList[index]['path']}';
                                    showToast('开始获取文件');
                                    String filePath = await downloadFile(
                                        urlPath, allInfoList[index]['path']);
                                    String fileName =
                                        allInfoList[index]['path'];
                                    if (filePath == 'error') {
                                      showToast('获取失败');
                                      return;
                                    }
                                    Application.router.navigateTo(this.context,
                                        '${Routes.mdPreview}?filePath=${Uri.encodeComponent(filePath)}&fileName=${Uri.encodeComponent(fileName)}',
                                        transition: TransitionType.none);
                                  } else {
                                    showToast('请稍候，正在获取文件地址');
                                    var result = await GithubManageAPI
                                        .getRepoFileContent(
                                      widget.element['showedUsername'],
                                      widget.element['name'],
                                      widget.bucketPrefix +
                                          allInfoList[index]['path'],
                                    );
                                    if (result[0] == 'success') {
                                      urlList +=
                                          'https://gh.api.99988866.xyz/${result[1]['download_url']}';
                                    } else {
                                      showToast('获取文件地址失败');
                                      return;
                                    }
                                    String filePath = await downloadFile(
                                        urlList, allInfoList[index]['path']);
                                    String fileName =
                                        allInfoList[index]['path'];
                                    if (filePath == 'error') {
                                      showToast('获取文件失败');
                                      return;
                                    }
                                    Application.router.navigateTo(this.context,
                                        '${Routes.mdPreview}?filePath=${Uri.encodeComponent(filePath)}&fileName=${Uri.encodeComponent(fileName)}',
                                        transition: TransitionType.none);
                                  }
                                }
                              },
                            ),
                          ),
                          Positioned(
                            // ignore: sort_child_properties_last
                            child: Container(
                              decoration: const BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(55)),
                                  color: Color.fromARGB(255, 235, 242, 248)),
                              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                              child: MSHCheckbox(
                                uncheckedColor: Colors.blue,
                                size: 17,
                                checkedColor: Colors.blue,
                                value: selectedFilesBool[index],
                                style: MSHCheckboxStyle.fillScaleCheck,
                                onChanged: (selected) {
                                  setState(() {
                                    if (selected) {
                                      selectedFilesBool[index] = true;
                                    } else {
                                      selectedFilesBool[index] = false;
                                    }
                                  });
                                },
                              ),
                            ),
                            left: 0,
                            top: 22,
                          ),
                        ])),
                    const Divider(
                      height: 1,
                    )
                  ],
                ),
              );
            }
          },
        ),
      );
    }
  }

  Widget buildBottomSheetWidget(
      BuildContext context, int index, String iconPath) {
    return SingleChildScrollView(
      child: Column(
        children: [
          ListTile(
            leading: Image.asset(
              iconPath,
              width: 30,
              height: 30,
            ),
            visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
            minLeadingWidth: 0,
            title: Text(
                allInfoList[index]['path'].length > 20
                    ? allInfoList[index]['path'].substring(0, 10) +
                        '...' +
                        allInfoList[index]['path']
                            .substring(allInfoList[index]['path'].length - 10)
                    : allInfoList[index]['path'],
                style: const TextStyle(fontSize: 14)),
            subtitle: Text(getFileSize(allInfoList[index]['size']),
                style: const TextStyle(fontSize: 12)),
          ),
          const Divider(
            height: 0.1,
            color: Color.fromARGB(255, 230, 230, 230),
          ),
          ListTile(
              leading: const Icon(
                Icons.info_outline_rounded,
                color: Color.fromARGB(255, 97, 141, 236),
              ),
              minLeadingWidth: 0,
              title: const Text('文件详情'),
              onTap: () async {
                Navigator.pop(context);
                Map<String, dynamic> fileMap = allInfoList[index];
                fileMap['downloadurl'] =
                    'https://raw.githubusercontent.com/${widget.element['showedUsername']}/${widget.element['name']}/${widget.element['default_branch']}/${widget.bucketPrefix}${fileMap['path']}';
                fileMap['private'] = widget.element['private'];
                fileMap['path'] = widget.bucketPrefix + fileMap['path'];
                fileMap['showedUsername'] = widget.element['showedUsername'];
                fileMap['name'] = widget.element['name'];
                fileMap['default_branch'] = widget.element['default_branch'];
                fileMap['dir'] = widget.bucketPrefix;
                Application.router.navigateTo(context,
                    '${Routes.githubFileInformation}?fileMap=${Uri.encodeComponent(jsonEncode(fileMap))}',
                    transition: TransitionType.cupertino);
              }),
          const Divider(
            height: 0.1,
            color: Color.fromARGB(255, 230, 230, 230),
          ),
          ListTile(
            leading: const Icon(
              Icons.link_rounded,
              color: Color.fromARGB(255, 97, 141, 236),
            ),
            minLeadingWidth: 0,
            title: const Text('复制链接(设置中的默认格式)'),
            onTap: () async {
              if (widget.element['showedUsername'] != adminUserName ||
                  widget.element['private'] == false) {
                String format = await Global.getLKformat();
                String shareUrl =
                    'https://raw.githubusercontent.com/${widget.element['showedUsername']}/${widget.element['name']}/${widget.element['default_branch']}/${widget.bucketPrefix}${allInfoList[index]['path']}';
                String filename = my_path.basename(allInfoList[index]['path']);
                String formatedLink =
                    linkGenerateDict[format]!(shareUrl, filename);
                await flutter_services.Clipboard.setData(
                    flutter_services.ClipboardData(text: formatedLink));
                if (mounted) {
                  Navigator.pop(context);
                }
                showToast('复制完毕');
              } else {
                showToast('开始获取私有仓库链接');
                var result = await GithubManageAPI.getRepoFileContent(
                  widget.element['showedUsername'],
                  widget.element['name'],
                  widget.bucketPrefix + allInfoList[index]['path'],
                );
                if (result[0] == 'success') {
                  String format = await Global.getLKformat();
                  String shareUrl = result[1]['download_url'];
                  String filename =
                      my_path.basename(allInfoList[index]['path']);
                  String formatedLink =
                      linkGenerateDict[format]!(shareUrl, filename);
                  await flutter_services.Clipboard.setData(
                      flutter_services.ClipboardData(text: formatedLink));
                  if (mounted) {
                    Navigator.pop(context);
                  }
                  showToast('复制完毕');
                } else {
                  showToast('获取失败');
                }
              }
            },
          ),
          const Divider(
            height: 0.1,
            color: Color.fromARGB(255, 230, 230, 230),
          ),
          ListTile(
            leading: const Icon(
              Icons.delete_outline,
              color: Color.fromARGB(255, 240, 85, 131),
            ),
            minLeadingWidth: 0,
            title: const Text('删除'),
            onTap: () async {
              if (widget.element['showedUsername'] == adminUserName) {
                Navigator.pop(context);
                showCupertinoDialog(
                  barrierDismissible: true,
                  context: context,
                  builder: (BuildContext context) {
                    return CupertinoAlertDialog(
                      title: const Text('通知'),
                      content: Text('确定要删除${allInfoList[index]['path']}吗？'),
                      actions: <Widget>[
                        CupertinoDialogAction(
                          child: const Text('取消',
                              style: TextStyle(color: Colors.blue)),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        CupertinoDialogAction(
                          child: const Text('确定',
                              style: TextStyle(color: Colors.blue)),
                          onPressed: () async {
                            Navigator.pop(context);
                            String path = widget.bucketPrefix +
                                allInfoList[index]['path'];
                            var result = await GithubManageAPI.deleteRepoFile(
                                widget.element['showedUsername'],
                                widget.element['name'],
                                path,
                                allInfoList[index]['sha'],
                                widget.element['default_branch']);
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
                        ),
                      ],
                    );
                  },
                );
              } else {
                showToast('只有管理员才能删除文件');
              }
            },
          ),
        ],
      ),
    );
  }

  Widget buildFolderBottomSheetWidget(
      BuildContext context, int index, String iconPath) {
    return SingleChildScrollView(
      child: Column(
        children: [
          ListTile(
            leading: Image.asset(
              iconPath,
              width: 30,
              height: 30,
            ),
            minLeadingWidth: 0,
            title: Text(allInfoList[index]['path'],
                style: const TextStyle(fontSize: 15)),
          ),
          const Divider(
            height: 0.1,
            color: Color.fromARGB(255, 230, 230, 230),
          ),
          ListTile(
            leading: const Icon(
              Icons.beenhere_outlined,
              color: Color.fromARGB(255, 97, 141, 236),
            ),
            minLeadingWidth: 0,
            title: const Text('设为图床默认目录'),
            onTap: () async {
              var result = await GithubManageAPI.setDefaultRepo(
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
          const Divider(
            height: 0.1,
            color: Color.fromARGB(255, 230, 230, 230),
          ),
          ListTile(
              leading: const Icon(
                Icons.delete_outline,
                color: Color.fromARGB(255, 240, 85, 131),
              ),
              minLeadingWidth: 0,
              title: const Text('删除'),
              onTap: () async {
                Navigator.pop(context);
                showCupertinoDialog(
                  barrierDismissible: true,
                  context: context,
                  builder: (BuildContext context) {
                    return CupertinoAlertDialog(
                      title: const Text('通知'),
                      content: Text('确定要删除目录${allInfoList[index]['path']}吗？'),
                      actions: <Widget>[
                        CupertinoDialogAction(
                          child: const Text('取消',
                              style: TextStyle(color: Colors.blue)),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        CupertinoDialogAction(
                          child: const Text('确定',
                              style: TextStyle(color: Colors.blue)),
                          onPressed: () async {
                            Navigator.pop(context);
                            await showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) {
                                  return NetLoadingDialog(
                                    outsideDismiss: false,
                                    loading: true,
                                    loadingText: "删除中...",
                                    requestCallBack: GithubManageAPI.deleteFolder(
                                        widget.element['showedUsername'],
                                        widget.element['name'],
                                        '${widget.bucketPrefix + allInfoList[index]['path']}/',
                                        widget.element['default_branch'],
                                        allInfoList[index]['sha']),
                                  );
                                });
                            setState(() {
                              showToast('操作完毕');
                              _onrefresh();
                            });
                          },
                        ),
                      ],
                    );
                  },
                );
              }),
        ],
      ),
    );
  }
}

class RenameDialog extends AlertDialog {
  RenameDialog({super.key, required Widget contentWidget})
      : super(
          content: contentWidget,
          contentPadding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        );
}

//弹出框 修改自https://www.jianshu.com/p/4144837a789b
double btnHeight = 60;
double borderWidth = 2;

class NewFolderDialog extends AlertDialog {
  NewFolderDialog({super.key, required Widget contentWidget})
      : super(
          content: contentWidget,
          contentPadding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        );
}

class NewFolderDialogContent extends StatefulWidget {
  String title;
  String cancelBtnTitle;
  String okBtnTitle;
  VoidCallback cancelBtnTap;
  VoidCallback okBtnTap;
  TextEditingController vc;
  NewFolderDialogContent({
    super.key,
    required this.title,
    this.cancelBtnTitle = "取消",
    this.okBtnTitle = "确定",
    required this.cancelBtnTap,
    required this.okBtnTap,
    required this.vc,
  });

  @override
  NewFolderDialogContentState createState() => NewFolderDialogContentState();
}

class NewFolderDialogContentState extends State<NewFolderDialogContent> {
  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.only(top: 20),
        height: 190,
        width: 10000,
        alignment: Alignment.bottomCenter,
        child: Column(
          children: [
            Container(
                alignment: Alignment.center,
                child: Text(
                  widget.title,
                  style: const TextStyle(
                      color: Color.fromARGB(255, 0, 0, 0), fontSize: 20),
                )),
            Padding(
              padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
              child: TextFormField(
                cursorHeight: 20,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black87),
                controller: widget.vc,
                validator: (value) {
                  if (value!.isEmpty) {
                    return '不能为空';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                    enabledBorder: UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: Color.fromARGB(255, 14, 103, 192)),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    )),
              ),
            ),
            const Spacer(),
            //A check box with a label
            Container(
              // color: Colors.red,
              height: btnHeight,
              margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    color: const Color.fromARGB(255, 234, 236, 238),
                    height: borderWidth,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () {
                          widget.vc.text = "";
                          widget.cancelBtnTap();
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          widget.cancelBtnTitle,
                          style:
                              const TextStyle(fontSize: 22, color: Colors.blue),
                        ),
                      ),
                      Container(
                        width: borderWidth,
                        color: const Color.fromARGB(255, 234, 236, 238),
                        height: btnHeight - borderWidth - borderWidth,
                      ),
                      TextButton(
                          onPressed: () {
                            widget.okBtnTap();
                            Navigator.of(context).pop();
                            widget.vc.text = "";
                          },
                          child: Text(
                            widget.okBtnTitle,
                            style: const TextStyle(
                                fontSize: 22, color: Colors.blue),
                          )),
                    ],
                  ),
                ],
              ),
            )
          ],
        ));
  }
}
