import 'dart:io';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:extended_image/extended_image.dart';
import 'package:external_path/external_path.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart' as flutter_services;
import 'package:path/path.dart' as my_path;
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'package:msh_checkbox/msh_checkbox.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import 'package:horopic/album/load_state_change.dart';
import 'package:horopic/picture_host_manage/manage_api/lskypro_manage_api.dart';
import 'package:horopic/pages/loading.dart';
import 'package:horopic/utils/global.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/router/application.dart';
import 'package:horopic/router/routers.dart';
import 'package:horopic/picture_host_manage/common_page/loading_state.dart' as loading_state;
import 'package:horopic/utils/image_compress.dart';

class LskyproFileExplorer extends StatefulWidget {
  final Map userProfile;
  final Map albumInfo;
  const LskyproFileExplorer({
    Key? key,
    required this.userProfile,
    required this.albumInfo,
  }) : super(key: key);

  @override
  LskyproFileExplorerState createState() => LskyproFileExplorerState();
}

class LskyproFileExplorerState extends loading_state.BaseLoadingPageState<LskyproFileExplorer> {
  List fileAllInfoList = [];
  List dirAllInfoList = [];
  List allInfoList = [];
  List selectedFilesBool = [];
  bool sorted = true;

  RefreshController refreshController = RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    allInfoList.clear();
    _getFileList();
  }

  _getFileList() async {
    try {
      if (widget.userProfile['image_num'] == 0) {
        setState(() {
          state = loading_state.LoadState.EMPTY;
        });
        return;
      }
      //主页模式
      if (widget.albumInfo.isEmpty) {
        //查询相册
        var albumResult = await LskyproManageAPI.getAlbums();
        if (albumResult[0] == 'success') {
          if (albumResult[1].length >= 1) {
            dirAllInfoList.clear();
            dirAllInfoList.addAll(albumResult[1]);
          } else {
            dirAllInfoList.clear();
          }
        } else {
          setState(() {
            state = loading_state.LoadState.ERROR;
          });
          return;
        }
        //查询文件
        var fileResult = await LskyproManageAPI.getPhoto(null);
        if (fileResult[0] == 'success') {
          if (fileResult[1].length >= 1) {
            fileAllInfoList.clear();
            fileAllInfoList.addAll(fileResult[1]);
          } else {
            fileAllInfoList.clear();
          }
        } else {
          setState(() {
            state = loading_state.LoadState.ERROR;
          });
          return;
        }
        //合并
        for (var i = 0; i < fileAllInfoList.length; i++) {
          fileAllInfoList[i]['date'] = DateTime.parse(
            fileAllInfoList[i]['date'],
          );
        }
        fileAllInfoList.sort((a, b) => b['date'].compareTo(a['date']));
        allInfoList.clear();
        allInfoList.addAll(dirAllInfoList);
        allInfoList.addAll(fileAllInfoList);
      } else {
        //相册内容模式
        dirAllInfoList.clear();
        var fileResult = await LskyproManageAPI.getPhoto(widget.albumInfo['id']);
        if (fileResult[0] == 'success') {
          if (fileResult[1].length >= 1) {
            fileAllInfoList.clear();
            fileAllInfoList.addAll(fileResult[1]);
          } else {
            fileAllInfoList.clear();
          }
        } else {
          setState(() {
            state = loading_state.LoadState.ERROR;
          });
          return;
        }
        //合并
        for (var i = 0; i < fileAllInfoList.length; i++) {
          fileAllInfoList[i]['date'] = DateTime.parse(
            fileAllInfoList[i]['date'],
          );
        }
        fileAllInfoList.sort((a, b) => b['date'].compareTo(a['date']));
        allInfoList.clear();
        allInfoList.addAll(fileAllInfoList);
      }
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
    } catch (e) {
      flogErr(e, {}, 'LskyproFileExplorerState', '_getFileList');
      state = loading_state.LoadState.ERROR;
    }
    if (mounted) {
      setState(() {});
    }
  }

  _onrefresh() async {
    _getFileList();
    refreshController.refreshCompleted();
  }

  @override
  void dispose() {
    refreshController.dispose();
    super.dispose();
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
        title: Text(widget.albumInfo.isEmpty ? '文件管理' : widget.albumInfo['name'],
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
                      '修改时间排序',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                      ),
                    )),
                    onTap: () {
                      if (sorted == true) {
                        if (dirAllInfoList.isEmpty) {
                          allInfoList.sort((a, b) {
                            return b['date'].compareTo(a['date']);
                          });
                        } else {
                          List temp = allInfoList.sublist(dirAllInfoList.length, allInfoList.length);
                          temp.sort((a, b) {
                            return b['date'].compareTo(a['date']);
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
                            return a['date'].compareTo(b['date']);
                          });
                        } else {
                          List temp = allInfoList.sublist(dirAllInfoList.length, allInfoList.length);
                          temp.sort((a, b) {
                            return a['date'].compareTo(b['date']);
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
                            return a['name'].compareTo(b['name']);
                          });
                        } else {
                          List temp = allInfoList.sublist(dirAllInfoList.length, allInfoList.length);
                          temp.sort((a, b) {
                            return a['name'].compareTo(b['name']);
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
                            return b['name'].compareTo(a['name']);
                          });
                        } else {
                          List temp = allInfoList.sublist(dirAllInfoList.length, allInfoList.length);
                          temp.sort((a, b) {
                            return b['name'].compareTo(a['name']);
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
                            return double.parse(a['size'].toString()).compareTo(double.parse(b['size'].toString()));
                          });
                        } else {
                          List temp = allInfoList.sublist(dirAllInfoList.length, allInfoList.length);
                          temp.sort((a, b) {
                            return double.parse(a['size'].toString()).compareTo(double.parse(b['size'].toString()));
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
                            return double.parse(b['size'].toString()).compareTo(double.parse(a['size'].toString()));
                          });
                        } else {
                          List temp = allInfoList.sublist(dirAllInfoList.length, allInfoList.length);
                          temp.sort((a, b) {
                            return double.parse(b['size'].toString()).compareTo(double.parse(a['size'].toString()));
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
                            String type = a['name'].split('.').last;
                            String type2 = b['name'].split('.').last;
                            if (type.isEmpty) {
                              return 1;
                            } else if (type2.isEmpty) {
                              return -1;
                            } else {
                              return type.compareTo(type2);
                            }
                          });
                        } else {
                          List temp = allInfoList.sublist(dirAllInfoList.length, allInfoList.length);
                          temp.sort((a, b) {
                            String type = a['name'].split('.').last;
                            String type2 = b['name'].split('.').last;
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
                            String type = a['name'].split('.').last;
                            String type2 = b['name'].split('.').last;
                            if (type.isEmpty) {
                              return -1;
                            } else if (type2.isEmpty) {
                              return 1;
                            } else {
                              return type2.compareTo(type);
                            }
                          });
                        } else {
                          List temp = allInfoList.sublist(dirAllInfoList.length, allInfoList.length);
                          temp.sort((a, b) {
                            String type = a['name'].split('.').last;
                            String type2 = b['name'].split('.').last;
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
              }),
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
                          leading: const Icon(Icons.image_outlined, color: Colors.blue),
                          title: const Text('上传照片(可多选)'),
                          onTap: () async {
                            Navigator.pop(context);
                            AssetPickerConfig config = const AssetPickerConfig(
                              maxAssets: 100,
                              selectedAssets: [],
                            );
                            final List<AssetEntity>? pickedImage =
                                await AssetPicker.pickAssets(context, pickerConfig: config);
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
                              Map configMap = await LskyproManageAPI.getConfigMap();
                              configMap['album_id'] = widget.albumInfo['id'] ?? 'None';
                              for (int i = 0; i < files.length; i++) {
                                File compressedFile;
                                if (Global.isCompress == true) {
                                  ImageCompress imageCompress = ImageCompress();
                                  compressedFile = await imageCompress.compressAndGetFile(
                                      files[i].path, my_path.basename(files[i].path), Global.defaultCompressFormat,
                                      minHeight: Global.minHeight, minWidth: Global.minWidth, quality: Global.quality);
                                  files[i] = compressedFile;
                                } else {
                                  compressedFile = files[i];
                                }
                                List uploadList = [
                                  files[i].path,
                                  my_path.basename(files[i].path),
                                  configMap,
                                ];
                                String uploadListStr = jsonEncode(uploadList);
                                Global.lskyproUploadList.add(uploadListStr);
                              }
                              await Global.setLskyproUploadList(Global.lskyproUploadList);
                              String downloadPath = await ExternalPath.getExternalStoragePublicDirectory(
                                  ExternalPath.DIRECTORY_DOWNLOADS);
                              if (mounted) {
                                String albumName = '';
                                if (widget.albumInfo.isEmpty) {
                                  albumName = '其它';
                                } else {
                                  albumName = widget.albumInfo['name'];
                                }
                                Application.router
                                    .navigateTo(context,
                                        '/baseUpDownloadManagePage?albumName=${Uri.encodeComponent(albumName)}&downloadPath=${Uri.encodeComponent(downloadPath)}&tabIndex=0&currentListIndex=6',
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
                          title: const Text('上传剪贴板内链接(换行分隔多个)'),
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
                                        requestCallBack: LskyproManageAPI.uploadNetworkFileEntry(
                                          fileLinkList,
                                        ),
                                      );
                                    });
                              }
                              _getFileList();
                              setState(() {});
                            } catch (e) {
                              flogErr(
                                  e,
                                  {
                                    'url': url,
                                  },
                                  'lskyproManagePage',
                                  'uploadNetworkFileEntry');
                              if (mounted) {
                                showToastWithContext(context, '错误');
                              }
                              return;
                            }
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
            ),
          ),
          IconButton(
              onPressed: () async {
                String downloadPath =
                    await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_DOWNLOADS);
                int index = 1;
                if (Global.lskyproDownloadList.isEmpty) {
                  index = 0;
                }
                String albumName = '';
                if (widget.albumInfo.isEmpty) {
                  albumName = '其它';
                } else {
                  albumName = widget.albumInfo['name'];
                }
                if (mounted) {
                  Application.router.navigateTo(context,
                      '/baseUpDownloadManagePage?albumName=${Uri.encodeComponent(albumName)}&downloadPath=${Uri.encodeComponent(downloadPath)}&tabIndex=$index&currentListIndex=6',
                      transition: TransitionType.inFromRight);
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
                    Navigator.pop(context);
                    await deleteAll(toDelete);
                    showToast('删除完成');
                    return;
                  } catch (e) {
                    flogErr(e, {}, 'LskyproManagePage', 'deleteAll_button');
                    showToast('删除失败');
                  }
                },
              );
            },
          ),
        ],
      );

  deleteAll(List toDelete) async {
    try {
      for (int i = 0; i < toDelete.length; i++) {
        if ((toDelete[i] - i) < dirAllInfoList.length) {
          await LskyproManageAPI.deleteAlbum(allInfoList[toDelete[i] - i]['id'].toString());
          setState(() {
            allInfoList.removeAt(toDelete[i] - i);
            dirAllInfoList.removeAt(toDelete[i] - i);
            selectedFilesBool.removeAt(toDelete[i] - i);
          });
        } else {
          await LskyproManageAPI.deleteFile(allInfoList[toDelete[i] - i]['key']);
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
      flogErr(
          e,
          {
            'toDelete': toDelete,
          },
          'LskyproManagePage',
          'deleteAll');
      rethrow;
    }
  }

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
                backgroundColor:
                    selectedFilesBool.contains(true) ? const Color.fromARGB(255, 180, 236, 182) : Colors.transparent,
                onPressed: () async {
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
                    Global.lskyproDownloadList.add(downloadList[i]['links']['url']);
                  }
                  String downloadPath =
                      await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_DOWNLOADS);
                  String albumName = '';
                  if (widget.albumInfo.isEmpty) {
                    albumName = '其它';
                  } else {
                    albumName = widget.albumInfo['name'];
                  }
                  if (mounted) {
                    Application.router.navigateTo(context,
                        '/baseUpDownloadManagePage?albumName=${Uri.encodeComponent(albumName)}&downloadPath=${Uri.encodeComponent(downloadPath)}&tabIndex=1&currentListIndex=6',
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
                backgroundColor:
                    selectedFilesBool.contains(true) ? const Color.fromARGB(255, 232, 177, 241) : Colors.transparent,
                elevation: 5,
                onPressed: () async {
                  if (!selectedFilesBool.contains(true)) {
                    showToastWithContext(context, '请先选择文件');
                    return;
                  } else {
                    List multiUrls = [];
                    for (int i = 0; i < allInfoList.length; i++) {
                      if (selectedFilesBool[i] && allInfoList[i]['links'] != null) {
                        String finalFormatedurl = ' ';
                        String rawurl = '';
                        String fileName = '';
                        rawurl = allInfoList[i]['links']['url'];
                        fileName = allInfoList[i]['name'];
                        finalFormatedurl = linkGeneratorMap[Global.defaultLKformat]!(rawurl, fileName);
                        multiUrls.add(finalFormatedurl);
                      }
                    }
                    await flutter_services.Clipboard.setData(flutter_services.ClipboardData(
                        text: multiUrls
                            .toString()
                            .substring(1, multiUrls.toString().length - 1)
                            .replaceAll(', ', '\n')
                            .replaceAll(',', '\n')));
                    if (mounted) {
                      showToastWithContext(context, '已复制全部链接');
                    }
                    return;
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

  @override
  Widget buildEmpty() {
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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/empty.png',
                width: 100,
                height: 100,
              ),
              const Center(
                  child: Text('没有文件哦，点击右上角添加吧',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20, color: Color.fromARGB(136, 121, 118, 118))))
            ],
          ),
        ));
  }

  @override
  Widget buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('加载失败,请检查网络', style: TextStyle(fontSize: 20, color: Color.fromARGB(136, 121, 118, 118))),
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.blue),
            ),
            onPressed: () {
              setState(() {
                state = loading_state.LoadState.LOADING;
              });
              _getFileList();
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
                              showCupertinoDialog(
                                  barrierDismissible: true,
                                  context: context,
                                  builder: (BuildContext context) {
                                    return CupertinoAlertDialog(
                                      title: const Text('通知'),
                                      content: Text('确定要删除${allInfoList[index]['name']}吗？'),
                                      actions: <Widget>[
                                        CupertinoDialogAction(
                                          child: const Text('取消', style: TextStyle(color: Colors.blue)),
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                        ),
                                        CupertinoDialogAction(
                                          child: const Text('确定', style: TextStyle(color: Colors.blue)),
                                          onPressed: () async {
                                            Navigator.pop(context);
                                            var result =
                                                await LskyproManageAPI.deleteAlbum(allInfoList[index]['id'].toString());
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
                                        ),
                                      ],
                                    );
                                  });
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
                            color: selectedFilesBool[index] ? const Color(0x311192F3) : Colors.transparent,
                            child: ListTile(
                              minLeadingWidth: 0,
                              minVerticalPadding: 0,
                              leading: Image.asset(
                                'assets/icons/folder.png',
                                width: 30,
                                height: 32,
                              ),
                              title: Text(allInfoList[index]['name'], style: const TextStyle(fontSize: 16)),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                Application.router.navigateTo(context,
                                    '${Routes.lskyproFileExplorer}?userProfile=${Uri.encodeComponent(jsonEncode(widget.userProfile))}&albumInfo=${Uri.encodeComponent(jsonEncode(allInfoList[index]))}',
                                    transition: TransitionType.cupertino);
                              },
                            ),
                          ),
                          Positioned(
                            // ignore: sort_child_properties_last
                            child: Container(
                              decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.all(Radius.circular(55)),
                                  color: Color.fromARGB(255, 235, 242, 248)),
                              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                              child: MSHCheckbox(
                                colorConfig: MSHColorConfig.fromCheckedUncheckedDisabled(
                                    checkedColor: Colors.blue, uncheckedColor: Colors.blue, disabledColor: Colors.blue),
                                size: 17,
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
                              onPressed: (BuildContext context) {
                                String shareUrl = allInfoList[index]['links']['url'];
                                Share.share(shareUrl);
                              },
                              autoClose: true,
                              padding: EdgeInsets.zero,
                              backgroundColor: const Color.fromARGB(255, 109, 196, 116),
                              foregroundColor: Colors.white,
                              icon: Icons.share,
                              label: '分享',
                            ),
                            SlidableAction(
                              onPressed: (BuildContext context) async {
                                showCupertinoDialog(
                                    barrierDismissible: true,
                                    context: context,
                                    builder: (BuildContext context) {
                                      return CupertinoAlertDialog(
                                        title: const Text('通知'),
                                        content: Text('确定要删除${allInfoList[index]['name']}吗？'),
                                        actions: <Widget>[
                                          CupertinoDialogAction(
                                            child: const Text('取消', style: TextStyle(color: Colors.blue)),
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                          ),
                                          CupertinoDialogAction(
                                            child: const Text('确定', style: TextStyle(color: Colors.blue)),
                                            onPressed: () async {
                                              Navigator.pop(context);
                                              var result = await LskyproManageAPI.deleteFile(allInfoList[index]['key']);
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
                                    });
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
                            color: selectedFilesBool[index] ? const Color(0x311192F3) : Colors.transparent,
                            child: ListTile(
                              minLeadingWidth: 0,
                              minVerticalPadding: 0,
                              leading: SizedBox(
                                width: 30,
                                height: 32,
                                child: iconImageLoad(index),
                              ),
                              title: Text(
                                  allInfoList[index]['name'].split('/').last.length > 20
                                      ? allInfoList[index]['name'].split('/').last.substring(0, 10) +
                                          '...' +
                                          allInfoList[index]['name']
                                              .split('/')
                                              .last
                                              .substring(allInfoList[index]['name'].split('/').last.length - 10)
                                      : allInfoList[index]['name'].split('/').last,
                                  style: const TextStyle(fontSize: 14)),
                              subtitle: Text(
                                  '${allInfoList[index]['date'].toString().replaceAll('T', ' ').replaceAll('Z', '').substring(0, 19)} ${getFileSize(int.parse(allInfoList[index]['size'].toString().split('.')[0]) * 1024)}',
                                  style: const TextStyle(fontSize: 12)),
                              trailing: IconButton(
                                icon: const Icon(Icons.more_horiz),
                                onPressed: () {
                                  showModalBottomSheet(
                                      isScrollControlled: true,
                                      context: context,
                                      builder: (context) {
                                        return buildBottomSheetWidget(
                                          context,
                                          index,
                                        );
                                      });
                                },
                              ),
                              onTap: () async {
                                String urlList = '';
                                //预览图片
                                int newImageIndex = index - dirAllInfoList.length;
                                for (int i = dirAllInfoList.length; i < allInfoList.length; i++) {
                                  urlList += '${allInfoList[i]['links']['url']},';
                                }
                                urlList = urlList.substring(0, urlList.length - 1);
                                Application.router.navigateTo(this.context,
                                    '${Routes.albumImagePreview}?index=$newImageIndex&images=${Uri.encodeComponent(urlList)}',
                                    transition: TransitionType.none);
                              },
                            ),
                          ),
                          Positioned(
                            // ignore: sort_child_properties_last
                            child: Container(
                              decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.all(Radius.circular(55)),
                                  color: Color.fromARGB(255, 235, 242, 248)),
                              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                              child: MSHCheckbox(
                                colorConfig: MSHColorConfig.fromCheckedUncheckedDisabled(
                                    checkedColor: Colors.blue, uncheckedColor: Colors.blue, disabledColor: Colors.blue),
                                size: 17,
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

  iconImageLoad(int index) {
    try {
      return ExtendedImage.network(
        allInfoList[index]['links']['thumbnail_url'],
        clearMemoryCacheIfFailed: true,
        retries: 5,
        height: 30,
        width: 30,
        fit: BoxFit.fill,
        cache: true,
        border: Border.all(color: Colors.transparent, width: 2),
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        loadStateChanged: (state) => defaultLoadStateChanged(state, iconSize: 30),
      );
    } catch (e) {
      flogErr(e, {'index': index}, 'LskyproFileExplorer', 'iconImageLoad');
      String fileExtension = allInfoList[index]['links']['url'].split('.').last;
      fileExtension = fileExtension.toLowerCase();
      String iconPath = 'assets/icons/';
      if (fileExtension == '') {
        iconPath += '_blank.png';
      } else if (Global.iconList.contains(fileExtension)) {
        iconPath += '$fileExtension.png';
      } else {
        iconPath += 'unknown.png';
      }
      return Image.asset(
        iconPath,
        width: 30,
        height: 30,
      );
    }
  }

  Widget buildBottomSheetWidget(
    BuildContext context,
    int index,
  ) {
    return SingleChildScrollView(
      child: Column(
        children: [
          ListTile(
            leading: iconImageLoad(index),
            visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
            minLeadingWidth: 0,
            title: Text(
                allInfoList[index]['name'].length > 20
                    ? allInfoList[index]['name'].substring(0, 10) +
                        '...' +
                        allInfoList[index]['name'].substring(allInfoList[index]['name'].length - 10)
                    : allInfoList[index]['name'],
                style: const TextStyle(fontSize: 14)),
            subtitle: Text(
              '${allInfoList[index]['date']}  ${getFileSize(int.parse(allInfoList[index]['size'].toString().split('.')[0]) * 1024)}',
              style: const TextStyle(fontSize: 12),
            ),
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
                Map fileMap = allInfoList[index];
                fileMap['date'] = fileMap['date'].toString().replaceAll('T', ' ').replaceAll('Z', '').substring(0, 19);
                Application.router.navigateTo(
                    context, '${Routes.lskyproFileInformation}?fileMap=${Uri.encodeComponent(jsonEncode(fileMap))}',
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
              String format = await Global.getLKformat();
              String shareUrl = allInfoList[index]['links']['url'];
              String filename = my_path.basename(allInfoList[index]['name']);
              String formatedLink = linkGeneratorMap[format]!(shareUrl, filename);
              await flutter_services.Clipboard.setData(flutter_services.ClipboardData(text: formatedLink));
              if (mounted) {
                Navigator.pop(context);
              }
              showToast('复制完毕');
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
                    content: Text('确定要删除${allInfoList[index]['name']}吗？'),
                    actions: <Widget>[
                      CupertinoDialogAction(
                        child: const Text('取消', style: TextStyle(color: Colors.blue)),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      CupertinoDialogAction(
                        child: const Text('确定', style: TextStyle(color: Colors.blue)),
                        onPressed: () async {
                          Navigator.pop(context);
                          var result = await LskyproManageAPI.deleteFile(allInfoList[index]['key']);
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
            },
          ),
        ],
      ),
    );
  }
}
