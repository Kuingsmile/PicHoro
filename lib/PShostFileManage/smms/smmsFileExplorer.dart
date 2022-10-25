import 'dart:io';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:horopic/PShostFileManage/manageAPI/smmsManage.dart';
import 'package:horopic/utils/global.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:fluro/fluro.dart';
import 'package:horopic/router/application.dart';
import 'package:horopic/router/routes.dart';
import 'package:horopic/PShostFileManage/commonPage/loadingState.dart'
    as loadingState;
import 'package:horopic/utils/common_func.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart' as flutterServices;
import 'package:path/path.dart' as myPath;
import 'package:horopic/pages/loading.dart';
import 'package:external_path/external_path.dart';
import 'package:msh_checkbox/msh_checkbox.dart';
import 'package:file_picker/file_picker.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:extended_image/extended_image.dart';

class SmmsFileExplorer extends StatefulWidget {
  SmmsFileExplorer({
    Key? key,
  }) : super(key: key);

  @override
  _SmmsFileExplorerState createState() => _SmmsFileExplorerState();
}

class _SmmsFileExplorerState
    extends loadingState.BaseLoadingPageState<SmmsFileExplorer> {
  List _allInfoList = [];
  List selectedFilesBool = [];
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  bool sorted = true;

  @override
  void initState() {
    super.initState();
    _allInfoList.clear();
    _getFileList();
  }

  _getFileList() async {
    try {
      var fileList = await SmmsManageAPI.getFileList(page: 1);
      if (fileList[0] == 'success') {
        Map firstPageMap = fileList[1];
        if (firstPageMap['Count'] == 0) {
          state = loadingState.LoadState.EMPTY;
        } else {
          int totalPage = firstPageMap['TotalPages'];
          _allInfoList.clear();
          _allInfoList.addAll(firstPageMap['data']);
          if (totalPage > 1) {
            for (int i = 2; i <= totalPage; i++) {
              var fileList = await SmmsManageAPI.getFileList(page: i);
              if (fileList[0] == 'success') {
                Map pageMap = fileList[1];
                _allInfoList.addAll(pageMap['data']);
              }
            }
          }
          selectedFilesBool.clear();
          for (int i = 0; i < _allInfoList.length; i++) {
            selectedFilesBool.add(false);
          }
          state = loadingState.LoadState.SUCCESS;
          if (mounted) {
            setState(() {});
          }
        }
      } else {
        state = loadingState.LoadState.ERROR;
      }
    } catch (e) {
      state = loadingState.LoadState.ERROR;
    }
    if (mounted) {
      setState(() {});
    }
  }

  _onrefresh() async {
    _getFileList();
    _refreshController.refreshCompleted();
  }

  @override
  void dispose() {
    _allInfoList.clear();
    super.dispose();
  }

  @override
  AppBar get appBar => AppBar(
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
        title: const Text('SM.MS文件浏览',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            )),
        actions: [
          PopupMenuButton(
              icon: const Icon(
                Icons.sort,
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
                        _allInfoList.sort((a, b) {
                          int timestampA = DateTime.parse(a['created_at'])
                              .millisecondsSinceEpoch;
                          int timestampB = DateTime.parse(b['created_at'])
                              .millisecondsSinceEpoch;
                          return timestampB.compareTo(timestampA);
                        });
                        sorted = false;
                      } else {
                        _allInfoList.sort((a, b) {
                          int timestampA = DateTime.parse(a['created_at'])
                              .millisecondsSinceEpoch;
                          int timestampB = DateTime.parse(b['created_at'])
                              .millisecondsSinceEpoch;
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
                        _allInfoList.sort((a, b) {
                          return a['filename'].compareTo(b['filename']);
                        });
                        sorted = false;
                      } else {
                        _allInfoList.sort((a, b) {
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
                        _allInfoList.sort((a, b) {
                          return a['size'].compareTo(b['size']);
                        });
                        sorted = false;
                      } else {
                        _allInfoList.sort((a, b) {
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
                        _allInfoList.sort((a, b) {
                          String aExtension = myPath.extension(a['filename']);
                          String bExtension = myPath.extension(b['filename']);
                          return aExtension.compareTo(bExtension);
                        });
                        sorted = false;
                      } else {
                        _allInfoList.sort((a, b) {
                          String aExtension = myPath.extension(a['filename']);
                          String bExtension = myPath.extension(b['filename']);
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
                          leading: const Icon(Icons.image_outlined,
                              color: Colors.blue),
                          title: const Text('上传照片(可多选)'),
                          onTap: () async {
                            Navigator.pop(context);
                            AssetPickerConfig config = const AssetPickerConfig(
                              maxAssets: 100,
                              selectedAssets: [],
                            );
                            final List<AssetEntity>? pickedImage =
                                await AssetPicker.pickAssets(context,
                                    pickerConfig: config);
                            if (pickedImage == null) {
                              Fluttertoast.showToast(
                                  msg: '未选择照片',
                                  toastLength: Toast.LENGTH_SHORT,
                                  timeInSecForIosWeb: 2,
                                  fontSize: 16.0);
                            } else {
                              List<File> files = [];
                              for (var i = 0; i < pickedImage.length; i++) {
                                File? fileImage =
                                    await pickedImage[i].originFile;
                                if (fileImage != null) {
                                  files.add(fileImage);
                                }
                              }
                              await showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context) {
                                    return NetLoadingDialog(
                                      outsideDismiss: false,
                                      loading: true,
                                      loadingText: "上传中...",
                                      requestCallBack:
                                          SmmsManageAPI.upLoadFileEntry(
                                        files,
                                      ),
                                    );
                                  });
                              _getFileList();
                            }
                          },
                        ),
                        ListTile(
                          minLeadingWidth: 0,
                          leading: const Icon(Icons.link, color: Colors.blue),
                          title: const Text('上传剪贴板内链接(换行分隔多个)'),
                          onTap: () async {
                            Navigator.pop(context);
                            var url = await flutterServices.Clipboard.getData(
                                'text/plain');
                            if (url == null ||
                                url.text == null ||
                                url.text!.isEmpty) {
                              Fluttertoast.showToast(
                                  msg: "剪贴板为空",
                                  toastLength: Toast.LENGTH_SHORT,
                                  timeInSecForIosWeb: 2,
                                  backgroundColor:
                                      Theme.of(context).brightness ==
                                              Brightness.light
                                          ? Colors.black
                                          : Colors.white,
                                  textColor: Theme.of(context).brightness ==
                                          Brightness.light
                                      ? Colors.white
                                      : Colors.black,
                                  fontSize: 16.0);
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
                                      requestCallBack:
                                          SmmsManageAPI.uploadNetworkFileEntry(
                                        fileLinkList,
                                      ),
                                    );
                                  });
                               _getFileList();
                              setState(() {});
                            } catch (e) {
                              Fluttertoast.showToast(
                                  msg: "错误",
                                  toastLength: Toast.LENGTH_SHORT,
                                  timeInSecForIosWeb: 2,
                                  backgroundColor:
                                      Theme.of(context).brightness ==
                                              Brightness.light
                                          ? Colors.black
                                          : Colors.white,
                                  textColor: Theme.of(context).brightness ==
                                          Brightness.light
                                      ? Colors.white
                                      : Colors.black,
                                  fontSize: 16.0);
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
              size: 30,
            ),
          ),
           IconButton(
              onPressed: () async {
                List downloadList = [];
                List savedFileNameList= [];
                String downloadPath =
                    await ExternalPath.getExternalStoragePublicDirectory(
                        ExternalPath.DIRECTORY_DOWNLOADS);
                
                Application.router.navigateTo(context,
                    '/smmsUpDownloadManagePage?savedFileNameList=${Uri.encodeComponent(jsonEncode(savedFileNameList))}&downloadList=${Uri.encodeComponent(jsonEncode(downloadList))}&downloadPath=${Uri.encodeComponent(downloadPath)}',
                    transition: TransitionType.inFromRight);
              },
              icon: const Icon(
                Icons.system_update_tv_outlined,
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
                Fluttertoast.showToast(
                    backgroundColor:
                        Theme.of(context).brightness == Brightness.light
                            ? Colors.black
                            : Colors.white,
                    textColor: Theme.of(context).brightness == Brightness.light
                        ? Colors.white
                        : Colors.black,
                    msg: '没有选择文件');
                return;
              }
              return showDialog(
                barrierDismissible: false,
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text(
                      '删除全部文件',
                      textAlign: TextAlign.center,
                    ),
                    content: const Text(
                      '是否删除全部选择的文件？\n请谨慎选择!',
                      textAlign: TextAlign.center,
                    ),
                    actions: [
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextButton(
                              child: const Text(
                                '确定',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              onPressed: () async {
                                try {
                                  List<int> toDelete = [];
                                  for (int i = 0;
                                      i < _allInfoList.length;
                                      i++) {
                                    if (selectedFilesBool[i]) {
                                      toDelete.add(i);
                                    }
                                  }
                                  Navigator.pop(context);
                                  await deleteAll(toDelete);
                                  Fluttertoast.showToast(msg: '删除完成');
                                  return;
                                } catch (e) {
                                  Fluttertoast.showToast(msg: '删除失败');
                                }
                              },
                            ),
                            TextButton(
                              style: TextButton.styleFrom(
                                alignment: Alignment.center,
                              ),
                              child: const Text(
                                '取消',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        ),
                      )
                    ],
                  );
                },
              );
            },
          ),
        ],
      );

  deleteAll(List toDelete) async {
    try {
      for (int i = 0; i < toDelete.length; i++) {
        await SmmsManageAPI.deleteFile(_allInfoList[toDelete[i] - i]['hash']);
        setState(() {
          _allInfoList.removeAt(toDelete[i] - i);
          selectedFilesBool.removeAt(toDelete[i] - i);
        });
        if (_allInfoList.isEmpty) {
          setState(() {
            state = loadingState.LoadState.EMPTY;
          });
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: buildStateWidget,
      floatingActionButtonLocation: state == loadingState.LoadState.ERROR ||
              state == loadingState.LoadState.EMPTY ||
              state == loadingState.LoadState.LOADING
          ? null
          : FloatingActionButtonLocation.centerFloat,
      floatingActionButton: state == loadingState.LoadState.ERROR ||
              state == loadingState.LoadState.EMPTY ||
              state == loadingState.LoadState.LOADING
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
                    Fluttertoast.showToast(
                        backgroundColor:
                            Theme.of(context).brightness == Brightness.light
                                ? Colors.black
                                : Colors.white,
                        textColor:
                            Theme.of(context).brightness == Brightness.light
                                ? Colors.white
                                : Colors.black,
                        msg: '没有选择文件');
                    return;
                  }

                  List downloadList = [];
                  for (int i = 0; i < _allInfoList.length; i++) {
                    if (selectedFilesBool[i]) {
                      downloadList.add(_allInfoList[i]);
                    }
                  }

                  List urlList = [];
                  for (int i = 0; i < downloadList.length; i++) {
                    urlList.add(downloadList[i]['url']);
                  }

                  List savedFileNameList = [];
                  for (int i = 0; i < downloadList.length; i++) {
                    savedFileNameList.add(downloadList[i]['filename']);
                  }

                  String downloadPath =
                      await ExternalPath.getExternalStoragePublicDirectory(
                          ExternalPath.DIRECTORY_DOWNLOADS);
                  Application.router.navigateTo(context,
                    '/smmsUpDownloadManagePage?savedFileNameList=${Uri.encodeComponent(jsonEncode(savedFileNameList))}&downloadList=${Uri.encodeComponent(jsonEncode(urlList))}&downloadPath=${Uri.encodeComponent(downloadPath)}',
                   transition: TransitionType.inFromRight);
                },
                child: const Icon(
                  Icons.download,
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
                    Fluttertoast.showToast(
                        msg: "请先选择文件",
                        toastLength: Toast.LENGTH_SHORT,
                        timeInSecForIosWeb: 2,
                        backgroundColor:
                            Theme.of(context).brightness == Brightness.light
                                ? Colors.black
                                : Colors.white,
                        textColor:
                            Theme.of(context).brightness == Brightness.light
                                ? Colors.white
                                : Colors.black,
                        fontSize: 16.0);
                    return;
                  } else {
                    List multiUrls = [];
                    for (int i = 0; i < _allInfoList.length; i++) {
                      if (selectedFilesBool[i]) {
                        String finalFormatedurl = ' ';
                        String rawurl = '';
                        String fileName = '';
                        rawurl = _allInfoList[i]['url'];
                        fileName = _allInfoList[i]['filename'];
                        finalFormatedurl =
                            linkGenerateDict[Global.defaultLKformat]!(
                                rawurl, fileName);
                        multiUrls.add(finalFormatedurl);
                      }
                    }
                    await flutterServices.Clipboard.setData(
                        flutterServices.ClipboardData(
                            text: multiUrls
                                .toString()
                                .substring(1, multiUrls.toString().length - 1)
                                .replaceAll(',', '\n')));
                    Fluttertoast.showToast(
                        msg: "已复制全部链接",
                        toastLength: Toast.LENGTH_SHORT,
                        timeInSecForIosWeb: 2,
                        backgroundColor:
                            Theme.of(context).brightness == Brightness.light
                                ? Colors.black
                                : Colors.white,
                        textColor:
                            Theme.of(context).brightness == Brightness.light
                                ? Colors.white
                                : Colors.black,
                        fontSize: 16.0);
                    return;
                  }
                },
                child: const Icon(
                  Icons.copy,
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
                  if (_allInfoList.isEmpty) {
                    Fluttertoast.showToast(
                        msg: "目录为空",
                        toastLength: Toast.LENGTH_SHORT,
                        timeInSecForIosWeb: 2,
                        backgroundColor:
                            Theme.of(context).brightness == Brightness.light
                                ? Colors.black
                                : Colors.white,
                        textColor:
                            Theme.of(context).brightness == Brightness.light
                                ? Colors.white
                                : Colors.black,
                        fontSize: 16.0);
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
                  size: 25,
                ),
              )),
        ],
      );

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
                state = loadingState.LoadState.LOADING;
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
    return SmartRefresher(
      controller: _refreshController,
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
        itemCount: _allInfoList.length,
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
                            String shareUrl = _allInfoList[index]['url'];
                            Share.share(shareUrl);
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
                            showCupertinoDialog(
                                barrierDismissible: true,
                                context: context,
                                builder: (BuildContext context) {
                                  return CupertinoAlertDialog(
                                    title: const Text('通知'),
                                    content: Text(
                                        '确定要删除${_allInfoList[index]['filename']}吗？'),
                                    actions: <Widget>[
                                      CupertinoDialogAction(
                                        child: const Text('取消',
                                            style:
                                                TextStyle(color: Colors.blue)),
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                      ),
                                      CupertinoDialogAction(
                                        child: const Text('确定',
                                            style:
                                                TextStyle(color: Colors.blue)),
                                        onPressed: () async {
                                          Navigator.pop(context);
                                          var result =
                                              await SmmsManageAPI.deleteFile(
                                                  _allInfoList[index]['hash']);
                                          if (result[0] == 'success') {
                                            Fluttertoast.showToast(
                                                msg: '删除成功',
                                                toastLength: Toast.LENGTH_SHORT,
                                                timeInSecForIosWeb: 2,
                                                fontSize: 16.0);
                                            setState(() {
                                              _allInfoList.removeAt(index);
                                              selectedFilesBool.removeAt(index);
                                            });
                                          } else {
                                            Fluttertoast.showToast(
                                                msg: '删除失败',
                                                toastLength: Toast.LENGTH_SHORT,
                                                timeInSecForIosWeb: 2,
                                                fontSize: 16.0);
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
                        color: selectedFilesBool[index]
                            ? const Color(0x311192F3)
                            : Colors.transparent,
                        child: ListTile(
                          minLeadingWidth: 0,
                          minVerticalPadding: 0,
                          //dense: true,
                          leading: SizedBox(
                            width: 50,
                            height: 50,
                            child: iconImageLoad(index),
                          ),
                          title: Text(
                              _allInfoList[index]['filename'].length > 20
                                  ? _allInfoList[index]['filename']
                                          .substring(0, 10) +
                                      '...' +
                                      _allInfoList[index]['filename'].substring(
                                          _allInfoList[index]['filename']
                                                  .length -
                                              10)
                                  : _allInfoList[index]['filename'],
                              style: const TextStyle(fontSize: 14)),
                          subtitle: Text(
                            _allInfoList[index]['created_at'] +
                                '   ' +
                                getFileSize(_allInfoList[index]['size']),
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
                            for (var i = 0; i < _allInfoList.length; i++) {
                              urlList += _allInfoList[i]['url'] + ',';
                            }
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
                              borderRadius:
                                  BorderRadius.all(Radius.circular(55)),
                              color: Color.fromARGB(255, 235, 242, 248)),
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                          child: MSHCheckbox(
                            uncheckedColor: Colors.blue,
                            size: 16,
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

  iconImageLoad(int index) {
    try {
      return ExtendedImage.network(
        _allInfoList[index]['url'],
        clearMemoryCacheIfFailed: true,
        retries: 5,
        height: 30,
        fit: BoxFit.cover,
        cache: true,
        border: Border.all(color: Colors.transparent, width: 2),
        borderRadius: const BorderRadius.all(Radius.circular(8)),
      );
    } catch (e) {
      String fileExtension = _allInfoList[index]['url'].split('.').last;
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
            //  dense: true,
            leading: iconImageLoad(index),
            visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
            minLeadingWidth: 0,
            title: Text(
                _allInfoList[index]['filename'].length > 20
                    ? _allInfoList[index]['filename'].substring(0, 10) +
                        '...' +
                        _allInfoList[index]['filename'].substring(
                            _allInfoList[index]['filename'].length - 10)
                    : _allInfoList[index]['filename'],
                style: const TextStyle(fontSize: 14)),
            subtitle: Text(
              _allInfoList[index]['created_at'] +
                  '   ' +
                  getFileSize(_allInfoList[index]['size']),
              style: const TextStyle(fontSize: 12),
            ),
          ),
          const Divider(
            height: 0.1,
            color: Color.fromARGB(255, 230, 230, 230),
          ),
          ListTile(
            //dense: true,
            leading: const Icon(
              Icons.link_rounded,
              color: Color.fromARGB(255, 97, 141, 236),
            ),
            // visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
            minLeadingWidth: 0,
            title: const Text('复制链接(设置中的默认格式)'),
            onTap: () async {
              String format = await Global.getLKformat();
              String shareUrl = _allInfoList[index]['url'];
              String filename =
                  myPath.basename(_allInfoList[index]['filename']);
              String formatedLink =
                  linkGenerateDict[format]!(shareUrl, filename);
              await flutterServices.Clipboard.setData(
                  flutterServices.ClipboardData(text: formatedLink));
              Navigator.pop(context);
              Fluttertoast.showToast(
                  msg: '复制完毕',
                  toastLength: Toast.LENGTH_SHORT,
                  timeInSecForIosWeb: 2,
                  fontSize: 16.0);
            },
          ),
          const Divider(
            height: 0.1,
            color: Color.fromARGB(255, 230, 230, 230),
          ),
          ListTile(
            // dense: true,
            leading: const Icon(
              Icons.delete_outline,
              color: Color.fromARGB(255, 240, 85, 131),
            ),
            // visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
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
                    content: Text('确定要删除${_allInfoList[index]['filename']}吗？'),
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
                          var result = await SmmsManageAPI.deleteFile(
                              _allInfoList[index]['hash']);
                          if (result[0] == 'success') {
                            Fluttertoast.showToast(
                                msg: '删除成功',
                                toastLength: Toast.LENGTH_SHORT,
                                timeInSecForIosWeb: 2,
                                fontSize: 16.0);
                            setState(() {
                              _allInfoList.removeAt(index);
                              selectedFilesBool.removeAt(index);
                            });
                          } else {
                            Fluttertoast.showToast(
                                msg: '删除失败',
                                toastLength: Toast.LENGTH_SHORT,
                                timeInSecForIosWeb: 2,
                                fontSize: 16.0);
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
