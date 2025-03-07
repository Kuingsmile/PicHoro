import 'dart:io';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:extended_image/extended_image.dart';
import 'package:external_path/external_path.dart';
import 'package:fluro/fluro.dart';
import 'package:f_logs/f_logs.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart' as flutter_services;
import 'package:path/path.dart' as my_path;
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'package:msh_checkbox/msh_checkbox.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import 'package:horopic/album/load_state_change.dart';
import 'package:horopic/picture_host_manage/manage_api/smms_manage_api.dart';
import 'package:horopic/pages/loading.dart';
import 'package:horopic/utils/global.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/router/application.dart';
import 'package:horopic/router/routers.dart';
import 'package:horopic/picture_host_manage/common_page/loading_state.dart' as loading_state;

import 'package:horopic/utils/image_compress.dart';

class SmmsFileExplorer extends StatefulWidget {
  const SmmsFileExplorer({
    super.key,
  });

  @override
  SmmsFileExplorerState createState() => SmmsFileExplorerState();
}

class SmmsFileExplorerState extends loading_state.BaseLoadingPageState<SmmsFileExplorer> {
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
      var fileList = await SmmsManageAPI.getFileList(page: 1);
      if (fileList[0] == 'success') {
        Map firstPageMap = fileList[1];
        if (firstPageMap['Count'] == 0) {
          state = loading_state.LoadState.EMPTY;
        } else {
          int totalPage = firstPageMap['TotalPages'];
          allInfoList.clear();
          allInfoList.addAll(firstPageMap['data']);
          if (totalPage > 1) {
            for (int i = 2; i <= totalPage; i++) {
              var fileList = await SmmsManageAPI.getFileList(page: i);
              if (fileList[0] == 'success') {
                Map pageMap = fileList[1];
                allInfoList.addAll(pageMap['data']);
              }
            }
          }
          selectedFilesBool.clear();
          for (int i = 0; i < allInfoList.length; i++) {
            selectedFilesBool.add(false);
          }
          state = loading_state.LoadState.SUCCESS;
          if (mounted) {
            setState(() {});
          }
        }
      } else {
        state = loading_state.LoadState.ERROR;
      }
    } catch (e) {
      FLog.error(
          className: 'SmmsFileExplorer',
          methodName: '_getFileList',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
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
        title: titleText(
          'SM.MS文件浏览',
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
                        allInfoList.sort((a, b) {
                          int timestampA = DateTime.parse(a['created_at']).millisecondsSinceEpoch;
                          int timestampB = DateTime.parse(b['created_at']).millisecondsSinceEpoch;
                          return timestampB.compareTo(timestampA);
                        });
                        sorted = false;
                      } else {
                        allInfoList.sort((a, b) {
                          int timestampA = DateTime.parse(a['created_at']).millisecondsSinceEpoch;
                          int timestampB = DateTime.parse(b['created_at']).millisecondsSinceEpoch;
                          return timestampA.compareTo(timestampB);
                        });
                        sorted = true;
                      }
                      setState(() {});
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
                        allInfoList.sort((a, b) {
                          return a['filename'].compareTo(b['filename']);
                        });
                        sorted = false;
                      } else {
                        allInfoList.sort((a, b) {
                          return b['filename'].compareTo(a['filename']);
                        });
                        sorted = true;
                      }
                      setState(() {});
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
                        allInfoList.sort((a, b) {
                          return a['size'].compareTo(b['size']);
                        });
                        sorted = false;
                      } else {
                        allInfoList.sort((a, b) {
                          return b['size'].compareTo(a['size']);
                        });
                        sorted = true;
                      }
                      setState(() {});
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
                        allInfoList.sort((a, b) {
                          String aExtension = my_path.extension(a['filename']);
                          String bExtension = my_path.extension(b['filename']);
                          return aExtension.compareTo(bExtension);
                        });
                        sorted = false;
                      } else {
                        allInfoList.sort((a, b) {
                          String aExtension = my_path.extension(a['filename']);
                          String bExtension = my_path.extension(b['filename']);
                          return bExtension.compareTo(aExtension);
                        });
                        sorted = true;
                      }
                      setState(() {});
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
                              Map configMap = await SmmsManageAPI.getConfigMap();
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
                                List uploadList = [files[i].path, my_path.basename(files[i].path), configMap];
                                String uploadListStr = jsonEncode(uploadList);
                                Global.smmsUploadList.add(uploadListStr);
                              }
                              Global.setSmmsUploadList(Global.smmsUploadList);
                              String downloadPath =
                                  await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_DOWNLOAD);
                              if (mounted) {
                                Application.router
                                    .navigateTo(context,
                                        '/smmsUpDownloadManagePage?downloadPath=${Uri.encodeComponent(downloadPath)}&tabIndex=0',
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
                                        requestCallBack: SmmsManageAPI.uploadNetworkFileEntry(
                                          fileLinkList,
                                        ),
                                      );
                                    });
                              }
                              _getFileList();
                              setState(() {});
                            } catch (e) {
                              FLog.error(
                                  className: 'SmmsManagePage',
                                  methodName: 'uploadNetworkFileEntry',
                                  text: formatErrorMessage({
                                    'url': url,
                                  }, e.toString()),
                                  dataLogType: DataLogType.ERRORS.toString());
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
                    await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_DOWNLOAD);
                int index = 1;
                if (Global.smmsDownloadList.isEmpty) {
                  index = 0;
                }
                if (mounted) {
                  Application.router.navigateTo(context,
                      '/smmsUpDownloadManagePage?downloadPath=${Uri.encodeComponent(downloadPath)}&tabIndex=$index',
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
                    FLog.error(
                        className: 'SmmsManagePage',
                        methodName: 'deleteAll_button',
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

  deleteAll(List toDelete) async {
    try {
      for (int i = 0; i < toDelete.length; i++) {
        await SmmsManageAPI.deleteFile(allInfoList[toDelete[i] - i]['hash']);
        setState(() {
          allInfoList.removeAt(toDelete[i] - i);
          selectedFilesBool.removeAt(toDelete[i] - i);
        });
        if (allInfoList.isEmpty) {
          setState(() {
            state = loading_state.LoadState.EMPTY;
          });
        }
      }
    } catch (e) {
      FLog.error(
          className: 'SmmsManagePage',
          methodName: 'deleteAll',
          text: formatErrorMessage({'toDelete': toDelete}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
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
                    if (selectedFilesBool[i]) {
                      downloadList.add(allInfoList[i]);
                    }
                  }
                  if (downloadList.isEmpty) {
                    showToast('没有选择文件');
                    return;
                  }
                  for (int i = 0; i < downloadList.length; i++) {
                    Global.smmsDownloadList.add(downloadList[i]['url']);
                  }

                  for (int i = 0; i < downloadList.length; i++) {
                    Global.smmsSavedNameList.add(downloadList[i]['filename']);
                  }
                  String downloadPath =
                      await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_DOWNLOAD);
                  if (mounted) {
                    Application.router.navigateTo(context,
                        '/smmsUpDownloadManagePage?downloadPath=${Uri.encodeComponent(downloadPath)}&tabIndex=1',
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
                      if (selectedFilesBool[i]) {
                        String finalFormatedurl = ' ';
                        String rawurl = '';
                        String fileName = '';
                        rawurl = allInfoList[i]['url'];
                        fileName = allInfoList[i]['filename'];
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
                  child: Text('没有文件哦，点击右上角添加吧\n刚上传的文件\n可能需要一段时间才能显示',
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
              backgroundColor: WidgetStateProperty.all(Colors.blue),
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
                              String shareUrl = allInfoList[index]['url'];
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
                                      content: Text('确定要删除${allInfoList[index]['filename']}吗？'),
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
                                            var result = await SmmsManageAPI.deleteFile(allInfoList[index]['hash']);
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
                              width: 50,
                              height: 50,
                              child: iconImageLoad(index),
                            ),
                            title: Text(
                                allInfoList[index]['filename'].length > 20
                                    ? allInfoList[index]['filename'].substring(0, 10) +
                                        '...${allInfoList[index]['filename'].substring(allInfoList[index]['filename'].length - 10)}'
                                    : allInfoList[index]['filename'],
                                style: const TextStyle(fontSize: 14)),
                            subtitle: Text(
                              '${allInfoList[index]['created_at']}   ${getFileSize(allInfoList[index]['size'])}',
                              style: const TextStyle(fontSize: 12),
                            ),
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
                              for (var i = 0; i < allInfoList.length; i++) {
                                urlList += allInfoList[i]['url'] + ',';
                              }
                              urlList = urlList.substring(0, urlList.length - 1);

                              Application.router.navigateTo(this.context,
                                  '${Routes.albumImagePreview}?index=$index&images=${Uri.encodeComponent(urlList)}',
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
                              size: 16,
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
                          top: 25,
                        ),
                      ])),
                  const Divider(
                    height: 1,
                  )
                ],
              ),
            );
          },
        ),
      );
    }
  }

  iconImageLoad(int index) {
    try {
      return ExtendedImage.network(
        allInfoList[index]['url'],
        clearMemoryCacheIfFailed: true,
        retries: 5,
        height: 30,
        fit: BoxFit.fill,
        cache: true,
        border: Border.all(color: Colors.transparent, width: 2),
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        loadStateChanged: (state) => defaultLoadStateChanged(state, iconSize: 30),
      );
    } catch (e) {
      FLog.error(
          className: 'SmmsFileExplorer',
          methodName: 'iconImageLoad',
          text: formatErrorMessage({'index': index}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      String fileExtension = allInfoList[index]['url'].split('.').last;
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
                allInfoList[index]['filename'].length > 20
                    ? allInfoList[index]['filename'].substring(0, 10) +
                        '...${allInfoList[index]['filename'].substring(allInfoList[index]['filename'].length - 10)}'
                    : allInfoList[index]['filename'],
                style: const TextStyle(fontSize: 14)),
            subtitle: Text(
              '${allInfoList[index]['created_at']}   ${getFileSize(allInfoList[index]['size'])}',
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
                Application.router.navigateTo(context,
                    '${Routes.smmsFileInformation}?fileMap=${Uri.encodeComponent(jsonEncode(allInfoList[index]))}',
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
              String format = Global.getLKformat();
              String shareUrl = allInfoList[index]['url'];
              String filename = my_path.basename(allInfoList[index]['filename']);
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
                    content: Text('确定要删除${allInfoList[index]['filename']}吗？'),
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
                          var result = await SmmsManageAPI.deleteFile(allInfoList[index]['hash']);
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
