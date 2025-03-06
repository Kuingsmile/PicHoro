/* 
Copyright 2020 Mr.Yang All Rights Reserved
Modified under MIT license
See file LICENSE of original project at https://github.com/PicGo/flutter-picgo
*/

import 'package:universal_io/io.dart';
import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:extended_image/extended_image.dart';
import 'package:fluro/fluro.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:f_logs/f_logs.dart';
import 'package:flutter/services.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:msh_checkbox/msh_checkbox.dart';

import 'package:horopic/album/load_state_change.dart';
import 'package:horopic/album/album_sql.dart';
import 'package:horopic/utils/event_bus_utils.dart';

import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/utils/global.dart';
import 'package:horopic/utils/deleter.dart';
import 'package:horopic/router/application.dart';
import 'package:horopic/router/routers.dart';

class UploadedImages extends StatefulWidget {
  const UploadedImages({super.key});

  @override
  UploadedImagesState createState() => UploadedImagesState();
}

class UploadedImagesState extends State<UploadedImages> with AutomaticKeepAliveClientMixin<UploadedImages> {
  /// 全部图片的url列表
  List imageUrlList = [];

  /// 全部图片的本地路径列表
  List imageLocalPathList = [];

  /// 全部图片的文件名列表
  List imageFileNameList = [];

  /// 全部图片的id列表
  List imageIdList = [];

  /// 全部图片的pictureKey列表,用于删除
  List imagePictureKeyList = [];

  /// 全部图片的显示地址列表
  List imageDisplayedUrlList = []; //showedImages的用来显示到相册里的url

  int pageIndex = 0;
  final int paginationSize = 12;

  /// 当前显示的图片url列表
  List currentVisibleImageUrlList = [];

  /// 当前显示的图片的显示地址列表
  List currentVisibleImageDisplayedUrlList = [];

  RefreshController refreshController = RefreshController(initialRefresh: false);
  List selectedImagesList = [];
  List<bool> selectedImagesBoolList = List.filled(12, false);

  Map<String, String> nameToPara = {
    'lskypro': '兰空',
    'smms': 'SM.MS',
    'github': 'GitHub',
    'imgur': 'Imgur',
    'qiniu': '七牛云',
    'tencent': '腾讯云',
    'aliyun': '阿里云',
    'upyun': '又拍云',
    'PBhostExtend1': 'FTP',
    'PBhostExtend2': 'S3',
    'PBhostExtend3': 'Alist',
    'PBhostExtend4': 'WebDAV',
  };

  List<Map<String, String>> switchPBOptions = [
    {'text': 'Alist V3', 'host': 'PBhostExtend3'},
    {'text': '阿里云', 'host': 'aliyun'},
    {'text': 'FTP-SSH/SFTP', 'host': 'PBhostExtend1'},
    {'text': 'Github', 'host': 'github'},
    {'text': 'Imgur', 'host': 'imgur'},
    {'text': '兰空图床', 'host': 'lskypro'},
    {'text': '七牛云', 'host': 'qiniu'},
    {'text': 'S3兼容平台', 'host': 'PBhostExtend2'},
    {'text': 'SM.MS', 'host': 'smms'},
    {'text': '腾讯云', 'host': 'tencent'},
    {'text': '又拍云', 'host': 'upyun'},
    {'text': 'WebDAV', 'host': 'PBhostExtend4'},
  ];

  List<String> pasteFormatsList = [
    'rawurl',
    'html',
    'bbcode',
    'markdown',
    'markdown_with_link',
    'custom',
  ];

  List<String> pasteFormatNamesList = [
    'URL格式',
    'HTML格式',
    'BBcode格式',
    'markdown格式',
    'markdown格式(带链接)',
    '自定义格式',
  ];

  bool albumKeepAlive = true;
  // ignore: prefer_typing_uninitialized_variables
  var actionEventBus;

  @override
  bool get wantKeepAlive => albumKeepAlive;

  @override
  void initState() {
    actionEventBus = eventBus.on<AlbumRefreshEvent>().listen(
      (event) {
        albumKeepAlive = false;
        updateKeepAlive();
      },
    );
    super.initState();
    _onRefresh();
  }

  @override
  void dispose() {
    actionEventBus.cancel();
    super.dispose();
  }

  getUrlAndAuth(String rawurl) {
    RegExp regExp = RegExp(r'Basic (.*)');
    String url = rawurl.replaceAll(regExp, '');
    var match = regExp.firstMatch(rawurl);
    return [url, match![1]];
  }

  List<Widget> buildFormatOptions(BuildContext context) {
    return pasteFormatsList.asMap().entries.map((entry) {
      int index = entry.key;
      String format = entry.value;
      return SimpleDialogOption(
        child: Text(
          Global.defaultLKformat == format ? '${pasteFormatNamesList[index]} \u2713' : pasteFormatNamesList[index],
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Global.defaultLKformat == format ? Colors.blue : Colors.black,
            fontWeight: Global.defaultLKformat == format ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onPressed: () async {
          await Global.setLKformat(format);
          if (context.mounted) {
            showToastWithContext(context, '已设置为${pasteFormatNamesList[index]}');
            Navigator.pop(context);
          }
        },
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
          title: titleText(
            '${nameToPara[Global.defaultShowedPBhost]}相册 - 第${pageIndex + 1}页',
          ),
          centerTitle: true,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
          ),
          shadowColor: Colors.transparent,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColor.withValues(alpha: 0.8)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          elevation: 0,
          actions: [
            PopupMenuButton(
                icon: const Icon(
                  Icons.settings,
                  color: Colors.white,
                  size: 30,
                ),
                onSelected: (value) {
                  if (value == 1) {
                    showDialog(
                      barrierDismissible: true,
                      context: context,
                      builder: (context) {
                        return SimpleDialog(
                          title: const Text(
                            '选择默认链接格式',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          children: [
                            ...buildFormatOptions(context),
                            SimpleDialogOption(
                              child: TextFormField(
                                textAlign: TextAlign.center,
                                initialValue: Global.customLinkFormat,
                                decoration: const InputDecoration(
                                  hintText: r'使用$url和$fileName作为占位符',
                                ),
                                onChanged: (String value) async {
                                  await Global.setCustomLinkFormat(value);
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
                position: PopupMenuPosition.under,
                itemBuilder: (BuildContext context) {
                  return [
                    PopupMenuItem(
                      padding: EdgeInsets.zero,
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 10,
                          ),
                          const Text('同步删除云端'),
                          Switch(
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            value: Global.isDeleteCloud,
                            onChanged: (value) async {
                              await Global.setIsDeleteCloud(value);
                              setState(() {});
                              if (context.mounted) {
                                if (value == true) {
                                  showToastWithContext(context, '已开启云端删除');
                                } else {
                                  showToastWithContext(context, '已关闭云端删除');
                                }
                                Navigator.pop(context);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 1,
                      child: Text('选择默认链接格式'),
                    ),
                  ];
                }),
            IconButton(
              icon: selectedImagesBoolList.contains(true)
                  ? const Icon(Icons.delete, color: Color.fromARGB(255, 236, 127, 120), size: 40.0)
                  : const Icon(Icons.delete_outline, color: Colors.white, size: 40.0),
              onPressed: () async {
                if (!selectedImagesBoolList.contains(true) || currentVisibleImageUrlList.isEmpty) {
                  showToastWithContext(context, '没有选择图片');
                  return;
                }
                return showCupertinoAlertDialogWithConfirmFunc(
                  context: context,
                  title: '删除全部图片',
                  content: '是否删除全部选择的图片？\n请注意检查删除本地和删除云端两项设置!',
                  onConfirm: () async {
                    try {
                      List<int> toDelete = [];
                      for (int i = 0; i < currentVisibleImageUrlList.length; i++) {
                        if (selectedImagesBoolList[i]) {
                          toDelete.add(i);
                        }
                      }
                      selectedImagesBoolList = List.filled(paginationSize, false);
                      Navigator.pop(context);
                      await removeAllImages(toDelete);
                      showToast('删除完成');
                      return;
                    } catch (e) {
                      FLog.error(
                          className: 'UploadedImagesState',
                          methodName: 'build_delete_button',
                          text: formatErrorMessage({}, e.toString()),
                          dataLogType: DataLogType.ERRORS.toString());
                      if (context.mounted) {
                        Application.router
                            .navigateTo(context, Routes.albumUploadedImages, transition: TransitionType.none);
                        showCupertinoAlertDialog(
                            barrierDismissible: true, context: context, title: '错误', content: e.toString());
                      }
                    }
                  },
                );
              },
            ),
          ]),
      body: SmartRefresher(
          enablePullDown: true,
          enablePullUp: imageUrlList.length > paginationSize,
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
            noDataText: '没有更多图片啦',
            failedText: '没有更多图片啦',
            canLoadingText: '释放加载',
          ),
          controller: refreshController,
          onRefresh: _onRefresh,
          onLoading: _onLoading,
          child: GridView.builder(
            padding: const EdgeInsets.all(2),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 1),
            itemCount: currentVisibleImageUrlList.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  switch (Global.defaultShowedPBhost) {
                    case 'lskypro':
                    case 'smms':
                    case 'imgur':
                    case 'qiniu':
                    case 'tencent':
                    case 'aliyun':
                    case 'upyun':
                    case 'PBhostExtend2':
                    case 'PBhostExtend3':
                      String urlList = currentVisibleImageUrlList.join(',');
                      Application.router.navigateTo(
                          context, '${Routes.albumImagePreview}?index=$index&images=${Uri.encodeComponent(urlList)}',
                          transition: TransitionType.none);
                    case 'github':
                      String urlList = '';
                      for (int i = 0; i < currentVisibleImageDisplayedUrlList.length; i++) {
                        if (currentVisibleImageDisplayedUrlList[i].contains('raw.githubusercontent.com')) {
                          urlList += 'https://ghproxy.com/${currentVisibleImageDisplayedUrlList[i]},';
                        } else {
                          urlList += currentVisibleImageUrlList[i] + ',';
                        }
                      }
                      Application.router.navigateTo(
                          context, '${Routes.albumImagePreview}?index=$index&images=${Uri.encodeComponent(urlList)}',
                          transition: TransitionType.none);
                    case 'PBhostExtend1':
                      String urlList = currentVisibleImageDisplayedUrlList.join(',');
                      Application.router.navigateTo(
                          context, '${Routes.localImagePreview}?index=$index&images=${Uri.encodeComponent(urlList)}',
                          transition: TransitionType.none);
                    case 'PBhostExtend4':
                      List trueUrlList = [];
                      List headersList = [];
                      RegExp reg = RegExp(r'Basic (.*)');
                      for (int i = 0; i < currentVisibleImageDisplayedUrlList.length; i++) {
                        String trueUrl = currentVisibleImageDisplayedUrlList[i].replaceAll(reg, '');
                        headersList.add({
                          'Authorization': reg.firstMatch(currentVisibleImageDisplayedUrlList[i])![0],
                        });
                        trueUrlList.add(trueUrl);
                      }
                      String urlList = trueUrlList.join(',');
                      Application.router.navigateTo(context,
                          '${Routes.webdavImagePreview}?index=$index&images=${Uri.encodeComponent(urlList)}&headersList=${Uri.encodeComponent(jsonEncode(headersList))}',
                          transition: TransitionType.none);
                  }
                },
                onDoubleTap: () => copyFormatedLink(index, Global.defaultLKformat),
                onLongPressStart: (LongPressStartDetails details) {
                  handleOnLongPress(context, details.globalPosition.dx, details.globalPosition.dy - 20, index);
                },
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    SizedBox(
                      height: 150,
                      child: Card(
                        clipBehavior: Clip.antiAlias,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadiusDirectional.circular(8)),
                        child: Global.defaultShowedPBhost == 'github' ||
                                Global.defaultShowedPBhost == 'imgur' ||
                                Global.defaultShowedPBhost == 'upyun' ||
                                Global.defaultShowedPBhost == 'aliyun' ||
                                Global.defaultShowedPBhost == 'qiniu' ||
                                Global.defaultShowedPBhost == 'tencent' ||
                                Global.defaultShowedPBhost == 'smms' ||
                                Global.defaultShowedPBhost == 'lskypro' ||
                                Global.defaultShowedPBhost == 'PBhostExtend2' ||
                                Global.defaultShowedPBhost == 'PBhostExtend3'
                            ? ExtendedImage.network(
                                currentVisibleImageDisplayedUrlList[index].contains('raw.githubusercontent.com')
                                    ?
                                    // ignore: prefer_interpolation_to_compose_strings
                                    'https://ghproxy.com/' + currentVisibleImageDisplayedUrlList[index]
                                    : currentVisibleImageDisplayedUrlList[index],
                                clearMemoryCacheIfFailed: true,
                                retries: 5,
                                height: 150,
                                fit: BoxFit.fill,
                                cache: true,
                                border: Border.all(
                                    color: selectedImagesBoolList[index] ? Colors.red : Colors.transparent, width: 2),
                                borderRadius: const BorderRadius.all(Radius.circular(8)),
                                loadStateChanged: (state) => defaultLoadStateChanged(state, iconSize: 30),
                              )
                            : Global.defaultShowedPBhost == 'PBhostExtend1'
                                ? File(currentVisibleImageDisplayedUrlList[index]).existsSync()
                                    ? ExtendedImage.file(
                                        File(currentVisibleImageDisplayedUrlList[index]),
                                        fit: BoxFit.fill,
                                        clearMemoryCacheIfFailed: true,
                                        height: 150,
                                        border: Border.all(
                                            color: selectedImagesBoolList[index] ? Colors.red : Colors.transparent,
                                            width: 2),
                                        borderRadius: const BorderRadius.all(Radius.circular(8)),
                                        loadStateChanged: (state) => defaultLoadStateChanged(state, iconSize: 30),
                                      )
                                    : const Icon(Icons.error, size: 30, color: Colors.red)
                                : Global.defaultShowedPBhost == 'PBhostExtend4'
                                    ? currentVisibleImageDisplayedUrlList[index].contains('Basic')
                                        ? ExtendedImage.network(
                                            currentVisibleImageDisplayedUrlList[index]
                                                .replaceAll(RegExp(r'Basic (.*)'), ''),
                                            clearMemoryCacheIfFailed: true,
                                            retries: 5,
                                            height: 150,
                                            fit: BoxFit.fill,
                                            headers: {
                                              'Authorization': RegExp(r'Basic (.*)')
                                                  .firstMatch(currentVisibleImageDisplayedUrlList[index])![0]!
                                            },
                                            cache: false,
                                            border: Border.all(
                                                color: selectedImagesBoolList[index] ? Colors.red : Colors.transparent,
                                                width: 2),
                                            borderRadius: const BorderRadius.all(Radius.circular(8)),
                                            loadStateChanged: (state) => defaultLoadStateChanged(state, iconSize: 30),
                                          )
                                        : ExtendedImage.network(
                                            currentVisibleImageDisplayedUrlList[index],
                                            clearMemoryCacheIfFailed: true,
                                            retries: 5,
                                            height: 150,
                                            fit: BoxFit.fill,
                                            cache: true,
                                            border: Border.all(
                                                color: selectedImagesBoolList[index] ? Colors.red : Colors.transparent,
                                                width: 2),
                                            borderRadius: const BorderRadius.all(Radius.circular(8)),
                                            loadStateChanged: (state) => defaultLoadStateChanged(state, iconSize: 30),
                                          )
                                    : const Icon(Icons.error, size: 30, color: Colors.red),
                      ),
                    ),
                    Positioned(
                      // ignore: sort_child_properties_last
                      child: Container(
                        decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(35)),
                            color: Color.fromARGB(255, 199, 208, 216)),
                        padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                        child: MSHCheckbox(
                          colorConfig: MSHColorConfig.fromCheckedUncheckedDisabled(
                              checkedColor: Colors.blue, uncheckedColor: Colors.blue, disabledColor: Colors.grey),
                          size: 20,
                          value: selectedImagesBoolList[index],
                          style: MSHCheckboxStyle.fillScaleCheck,
                          onChanged: (bool selected) {
                            setState(() {
                              selectedImagesBoolList[index] = selected;
                            });
                          },
                        ),
                      ),
                      right: 4,
                      top: 4,
                    )
                  ],
                ),
              );
            },
          )),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
              height: 40,
              width: 40,
              child: FloatingActionButton(
                heroTag: 'switch',
                backgroundColor: const Color.fromARGB(255, 180, 236, 182),
                onPressed: () async {
                  await showDialog(
                    barrierDismissible: true,
                    context: context,
                    builder: (context) {
                      return SimpleDialog(
                        title: const Text(
                          '选择要展示的图床',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        children: switchPBOptions.map((option) {
                          return SimpleDialogOption(
                            child: Text(option['text']!, textAlign: TextAlign.center),
                            onPressed: () {
                              Global.setShowedPBhost(option['host']!);
                              Navigator.pop(context);
                              pageIndex = 0;
                              _onRefresh();
                            },
                          );
                        }).toList(),
                      );
                    },
                  );
                },
                child: const Icon(
                  Icons.switch_left_outlined,
                  color: Colors.white,
                  size: 30,
                ),
              )),
          const SizedBox(width: 10),
          SizedBox(
              height: 40,
              width: 40,
              child: FloatingActionButton(
                heroTag: 'Home',
                backgroundColor: Colors.blue,
                onPressed: () async {
                  setState(() {
                    pageIndex = 0;
                    currentVisibleImageUrlList.clear();
                    currentVisibleImageDisplayedUrlList.clear();
                    selectedImagesBoolList = List.filled(
                      paginationSize,
                      false,
                    );
                    refreshController.resetNoData();
                  });
                  initLoadUploadedImages();
                },
                child: const Icon(
                  Icons.home_outlined,
                  color: Colors.white,
                  size: 30,
                ),
              )),
          const SizedBox(width: 10),
          SizedBox(
              height: 40,
              width: 40,
              child: FloatingActionButton(
                heroTag: 'copy',
                backgroundColor: selectedImagesBoolList.contains(true)
                    ? const Color.fromARGB(255, 232, 177, 241)
                    : Colors.transparent,
                elevation: 5,
                onPressed: () async {
                  if (!selectedImagesBoolList.contains(true)) {
                    Fluttertoast.showToast(
                        msg: "请先选择图片",
                        toastLength: Toast.LENGTH_SHORT,
                        timeInSecForIosWeb: 2,
                        backgroundColor: Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white,
                        textColor: Theme.of(context).brightness == Brightness.light ? Colors.white : Colors.black,
                        fontSize: 16.0);
                    return;
                  } else {
                    List multiUrls = [];

                    for (int i = 0; i < currentVisibleImageUrlList.length; i++) {
                      if (selectedImagesBoolList[i]) {
                        String finalFormatedurl = ' ';
                        finalFormatedurl = linkGeneratorMap[Global.defaultLKformat]!(
                            currentVisibleImageUrlList[i], imageFileNameList[i + paginationSize * pageIndex]);

                        multiUrls.add(finalFormatedurl);
                      }
                    }
                    await Clipboard.setData(ClipboardData(text: multiUrls.join('\n')));
                    showToast('已复制全部链接');
                    return;
                  }
                },
                child: const Icon(
                  Icons.copy,
                  color: Colors.white,
                ),
              )),
          const SizedBox(width: 10),
          SizedBox(
              height: 40,
              width: 40,
              child: FloatingActionButton(
                heroTag: 'select',
                backgroundColor: const Color.fromARGB(255, 248, 196, 237),
                elevation: 5,
                onPressed: () async {
                  if (currentVisibleImageUrlList.isEmpty) {
                    showToastWithContext(context, '相册为空');
                    return;
                  } else if (selectedImagesBoolList.contains(true)) {
                    setState(() {
                      selectedImagesBoolList = List.filled(selectedImagesBoolList.length, false, growable: false);
                    });
                  } else {
                    setState(() {
                      selectedImagesBoolList = List.filled(selectedImagesBoolList.length, true, growable: false);
                    });
                  }
                },
                child: const Icon(
                  Icons.check_circle_outline,
                  color: Colors.white,
                ),
              )),
        ],
      ),
    );
  }

  copyFormatedLink(int index, String format) async {
    String link = currentVisibleImageUrlList[index];
    String filename = imageFileNameList[index + pageIndex * paginationSize];
    String formatedLink = linkGeneratorMap[format]!(link, filename);
    Clipboard.setData(ClipboardData(text: formatedLink));
    showToast('链接已复制');
  }

  handleOnLongPress(BuildContext context, double dx, double dy, int index) {
    showMenu(context: context, position: RelativeRect.fromLTRB(dx, dy, dx + 50, dy - 50), items: [
      const PopupMenuItem(
        height: 20,
        value: 1,
        child: Center(
          child: Text('Url', textAlign: TextAlign.center),
        ),
      ),
      const PopupMenuItem(
        height: 1,
        value: 10,
        child: Divider(
          height: 1,
          color: Colors.grey,
          thickness: 1,
        ),
      ),
      const PopupMenuItem(
        height: 20,
        value: 2,
        child: Center(
          child: Text('Html', textAlign: TextAlign.center),
        ),
      ),
      const PopupMenuItem(
        height: 1,
        value: 10,
        child: Divider(
          height: 1,
          color: Colors.grey,
          thickness: 1,
        ),
      ),
      const PopupMenuItem(
        height: 20,
        value: 3,
        child: Center(
          child: Text('Markdown', textAlign: TextAlign.center),
        ),
      ),
      const PopupMenuItem(
        height: 1,
        value: 10,
        child: Divider(
          height: 1,
          color: Colors.grey,
          thickness: 1,
        ),
      ),
      const PopupMenuItem(
        height: 20,
        value: 4,
        child: Center(
          child: Text('BBcode', textAlign: TextAlign.center),
        ),
      ),
      const PopupMenuItem(
        height: 1,
        value: 10,
        child: Divider(
          height: 1,
          color: Colors.grey,
          thickness: 1,
        ),
      ),
      const PopupMenuItem(
        height: 20,
        value: 5,
        child: Center(
          child: Text('MD&Link', textAlign: TextAlign.center),
        ),
      ),
      const PopupMenuItem(
        height: 1,
        value: 10,
        child: Divider(
          height: 1,
          color: Colors.grey,
          thickness: 1,
        ),
      ),
      const PopupMenuItem(
        height: 20,
        value: 6,
        child: Center(
          child: Text('自定义格式', textAlign: TextAlign.center),
        ),
      ),
      const PopupMenuItem(
        height: 1,
        value: 10,
        child: Divider(
          height: 1,
          color: Colors.grey,
          thickness: 1,
        ),
      ),
      const PopupMenuItem(
        height: 20,
        value: 7,
        child: Center(
          child: Text('删除', textAlign: TextAlign.center),
        ),
      ),
    ]).then((value) async {
      switch (value) {
        case 1:
          copyFormatedLink(index, 'rawurl');
        case 2:
          copyFormatedLink(index, 'html');
        case 3:
          copyFormatedLink(index, 'markdown');
        case 4:
          copyFormatedLink(index, 'bbcode');
        case 5:
          copyFormatedLink(index, 'markdown_with_link');
        case 6:
          copyFormatedLink(index, 'custom');
        case 7:
          try {
            await deleteImage(index);
          } catch (e) {
            FLog.error(
                className: 'ImagePage',
                methodName: 'handleOnLongPress_delete',
                text: formatErrorMessage({}, e.toString()),
                dataLogType: DataLogType.ERRORS.toString());
            if (context.mounted) {
              showToastWithContext(context, '删除失败');
            }
          }
        default:
          return;
      }
    });
  }

  removeAllImages(List imagesIndex) async {
    bool isDeleteLocal = await Global.getIsDeleteLocal();
    bool isDeleteCloud = await Global.getIsDeleteCloud();
    for (int i = 0; i < imagesIndex.length; i++) {
      try {
        Map deleteConfig = {
          'pictureKey': imagePictureKeyList[imagesIndex[i] + (pageIndex * paginationSize) - i],
          "name": imageFileNameList[imagesIndex[i] + (pageIndex * paginationSize) - i],
        };

        if (isDeleteCloud) {
          var result = await deleterentry(deleteConfig);
          if (result[0] != 'success') {
            showToast('云端删除失败');
            return;
          }
        }
        if (Global.defaultShowedPBhost == 'PBhostExtend1') {
          await AlbumSQL.deleteData(Global.imageDBExtend!, Global.defaultShowedPBhost,
              imageIdList[imagesIndex[i] + (pageIndex * paginationSize) - i]);
          try {
            await File(imageDisplayedUrlList[imagesIndex[i] + pageIndex * paginationSize - i]).delete();
          } catch (e) {
            FLog.error(
                className: 'ImagePage',
                methodName: 'deleteALLFTPThumbnail',
                text: formatErrorMessage({}, e.toString()),
                dataLogType: DataLogType.ERRORS.toString());
          }
        } else if (Global.defaultShowedPBhost == 'PBhostExtend2' ||
            Global.defaultShowedPBhost == 'PBhostExtend3' ||
            Global.defaultShowedPBhost == 'PBhostExtend4') {
          await AlbumSQL.deleteData(Global.imageDBExtend!, Global.defaultShowedPBhost,
              imageIdList[imagesIndex[i] + (pageIndex * paginationSize) - i]);
        } else {
          await AlbumSQL.deleteData(Global.imageDB!, Global.defaultShowedPBhost,
              imageIdList[imagesIndex[i] + (pageIndex * paginationSize) - i]);
        }

        if (isDeleteLocal) {
          try {
            await File(imageLocalPathList[imagesIndex[i] + (pageIndex * paginationSize) - i]).delete();
          } catch (e) {
            FLog.error(
                className: 'ImagePage',
                methodName: 'deleteImageAll',
                text: formatErrorMessage({}, e.toString()),
                dataLogType: DataLogType.ERRORS.toString());
          }
        }
        imageIdList.removeAt(imagesIndex[i] + (pageIndex * paginationSize) - i);
        imageUrlList.removeAt(imagesIndex[i] + (pageIndex * paginationSize) - i);
        imageDisplayedUrlList.removeAt(imagesIndex[i] + (pageIndex * paginationSize) - i);
        imageLocalPathList.removeAt(imagesIndex[i] + (pageIndex * paginationSize) - i);
        imageFileNameList.removeAt(imagesIndex[i] + (pageIndex * paginationSize) - i);
        imagePictureKeyList.removeAt(imagesIndex[i] + (pageIndex * paginationSize) - i);
        setState(() {
          currentVisibleImageUrlList = imageUrlList.sublist(
              pageIndex * paginationSize,
              (pageIndex + 1) * paginationSize > imageUrlList.length
                  ? imageUrlList.length
                  : (pageIndex + 1) * paginationSize);
          currentVisibleImageDisplayedUrlList = imageDisplayedUrlList.sublist(
              pageIndex * paginationSize,
              (pageIndex + 1) * paginationSize > imageDisplayedUrlList.length
                  ? imageDisplayedUrlList.length
                  : (pageIndex + 1) * paginationSize);
        });
      } catch (e) {
        FLog.error(
            className: 'ImagePage',
            methodName: 'deleteImageAll',
            text: formatErrorMessage({}, e.toString()),
            dataLogType: DataLogType.ERRORS.toString());
        rethrow;
      }
    }
    return true;
  }

  deleteImage(int index) async {
    try {
      bool isDeleteLocal = await Global.getIsDeleteLocal();
      bool isDeleteCloud = await Global.getIsDeleteCloud();

      Map deleteConfig = {
        'pictureKey': imagePictureKeyList[index + (pageIndex * paginationSize)],
        "name": imageFileNameList[index + (pageIndex * paginationSize)],
      };
      if (isDeleteCloud) {
        var result = await deleterentry(deleteConfig);
        if (result[0] != 'success') {
          showToast('云端删除失败');
          return;
        }
      }
      if (Global.defaultShowedPBhost == 'PBhostExtend1') {
        await AlbumSQL.deleteData(
            Global.imageDBExtend!, Global.defaultShowedPBhost, imageIdList[index + (pageIndex * paginationSize)]);
        try {
          await File(imageDisplayedUrlList[index + pageIndex * paginationSize]).delete();
        } catch (e) {
          FLog.error(
              className: 'ImagePage',
              methodName: 'deleteFTPThumbnail',
              text: formatErrorMessage({}, e.toString()),
              dataLogType: DataLogType.ERRORS.toString());
        }
      } else if (Global.defaultShowedPBhost == 'PBhostExtend2' ||
          Global.defaultShowedPBhost == 'PBhostExtend3' ||
          Global.defaultShowedPBhost == 'PBhostExtend4') {
        await AlbumSQL.deleteData(
            Global.imageDBExtend!, Global.defaultShowedPBhost, imageIdList[index + (pageIndex * paginationSize)]);
      } else {
        await AlbumSQL.deleteData(
            Global.imageDB!, Global.defaultShowedPBhost, imageIdList[index + (pageIndex * paginationSize)]);
      }

      if (isDeleteLocal) {
        try {
          await File(imageLocalPathList[index + pageIndex * paginationSize]).delete();
        } catch (e) {
          FLog.error(
              className: 'ImagePage',
              methodName: 'deleteImage',
              text: formatErrorMessage({}, e.toString()),
              dataLogType: DataLogType.ERRORS.toString());
        }
      }
      setState(() {
        imageIdList.removeAt(index + paginationSize * pageIndex);
        imageUrlList.removeAt(index + paginationSize * pageIndex);
        imageDisplayedUrlList.removeAt(index + paginationSize * pageIndex);
        imagePictureKeyList.removeAt(index + paginationSize * pageIndex);
        imageFileNameList.removeAt(index + paginationSize * pageIndex);
        imageLocalPathList.removeAt(index + paginationSize * pageIndex);
        currentVisibleImageUrlList.removeAt(index);
        currentVisibleImageDisplayedUrlList.removeAt(index);
        selectedImagesBoolList = List.filled(paginationSize, false);
        if (currentVisibleImageUrlList.isEmpty && pageIndex == 0) {
          currentVisibleImageUrlList = [];
          currentVisibleImageDisplayedUrlList = [];
        } else if (currentVisibleImageUrlList.isEmpty && pageIndex > 0) {
          pageIndex--;
          currentVisibleImageUrlList =
              imageUrlList.sublist(pageIndex * paginationSize, (pageIndex + 1) * paginationSize);
          currentVisibleImageDisplayedUrlList =
              imageDisplayedUrlList.sublist(pageIndex * paginationSize, (pageIndex + 1) * paginationSize);
        } else if (imageUrlList.length >= (pageIndex + 1) * paginationSize) {
          currentVisibleImageUrlList =
              imageUrlList.sublist(pageIndex * paginationSize, (pageIndex + 1) * paginationSize);
          currentVisibleImageDisplayedUrlList =
              imageDisplayedUrlList.sublist(pageIndex * paginationSize, (pageIndex + 1) * paginationSize);
        } else if (imageUrlList.length < (pageIndex + 1) * paginationSize) {
          currentVisibleImageUrlList = imageUrlList.sublist(pageIndex * paginationSize, imageUrlList.length);
          currentVisibleImageDisplayedUrlList =
              imageDisplayedUrlList.sublist(pageIndex * paginationSize, imageDisplayedUrlList.length);
        }
      });
    } catch (e) {
      FLog.error(
          className: 'ImagePage',
          methodName: 'deleteImage',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      rethrow;
    }
  }

  /// 刷新或返回上一页
  _onRefresh() async {
    if (pageIndex == 0 || pageIndex == 1) {
      setState(() {
        pageIndex = 0;
        currentVisibleImageUrlList.clear();
        currentVisibleImageDisplayedUrlList.clear();
        selectedImagesBoolList = List.filled(
          paginationSize,
          false,
        );
        refreshController.resetNoData();
      });
      initLoadUploadedImages();
    } else {
      doBackUploadedImages();
    }
  }

  /// 上拉加载
  _onLoading() async {
    doLoadUploadedImages();
  }

  void addImageDetails(
      Map<String, dynamic> map, String urlKey, String displayedUrlKey, bool isFormatUrl, bool isFormatDisplayedUrl) {
    String url = map[urlKey].toString();
    String displayedUrl = map[displayedUrlKey].toString();

    if (isFormatUrl && !url.startsWith('https://') && !url.startsWith('http://')) {
      url = 'http://$url';
    }
    if (isFormatDisplayedUrl && !displayedUrl.startsWith('https://') && !displayedUrl.startsWith('http://')) {
      displayedUrl = 'http://$displayedUrl';
    }

    imageUrlList.add(url);
    imageDisplayedUrlList.add(displayedUrl);
    imageFileNameList.add(map['name']);
    imagePictureKeyList.add(map['pictureKey']);
    imageLocalPathList.add(map['path']);
  }

  void initLoadUploadedImages() async {
    //所有的图床的图片ID
    Map<String, dynamic> dbIdList = await AlbumSQL.getAllTableData(Global.imageDB!, 'id');
    //扩展图床的图片ID
    Map<String, dynamic> extendDbIdListExtend = await AlbumSQL.getAllTableDataExtend(
      Global.imageDBExtend!,
      'id',
    );
    if (Global.defaultShowedPBhost == 'PBhostExtend1' ||
        Global.defaultShowedPBhost == 'PBhostExtend2' ||
        Global.defaultShowedPBhost == 'PBhostExtend3' ||
        Global.defaultShowedPBhost == 'PBhostExtend4') {
      imageIdList = extendDbIdListExtend[Global.defaultShowedPBhost]!;
    } else {
      imageIdList = dbIdList[Global.defaultShowedPBhost]!;
    }

    imageIdList = imageIdList.reversed.toList();
    imageUrlList.clear();
    imageDisplayedUrlList.clear();
    imagePictureKeyList.clear();
    imageFileNameList.clear();
    imageLocalPathList.clear();

    for (int i = 0; i < imageIdList.length; i++) {
      List<Map<String, dynamic>> maps;
      if (Global.defaultShowedPBhost == 'PBhostExtend1' ||
          Global.defaultShowedPBhost == 'PBhostExtend2' ||
          Global.defaultShowedPBhost == 'PBhostExtend3' ||
          Global.defaultShowedPBhost == 'PBhostExtend4') {
        maps = await AlbumSQL.queryData(Global.imageDBExtend!, Global.defaultShowedPBhost, imageIdList[i]);
      } else {
        maps = await AlbumSQL.queryData(Global.imageDB!, Global.defaultShowedPBhost, imageIdList[i]);
      }

      Map<String, dynamic> map = maps[0];
      switch (Global.defaultShowedPBhost) {
        case 'smms':
          addImageDetails(map, 'url', 'url', false, false);
        case 'lskypro':
        case 'imgur':
          addImageDetails(map, 'url', 'hostSpecificArgA', false, false);
        case 'github':
          addImageDetails(map, 'hostSpecificArgA', 'hostSpecificArgA', true, true);
        case 'qiniu':
        case 'tencent':
        case 'aliyun':
        case 'upyun':
        case 'PBhostExtend2':
        case 'PBhostExtend4':
          addImageDetails(map, 'url', 'hostSpecificArgA', true, true);
        case 'PBhostExtend1':
          addImageDetails(map, 'url', 'hostSpecificArgI', false, false);
        case 'PBhostExtend3':
          addImageDetails(map, 'hostSpecificArgB', 'hostSpecificArgA', true, true);
        default:
          break;
      }
    }

    currentVisibleImageUrlList =
        imageUrlList.sublist(0, paginationSize > imageUrlList.length ? imageUrlList.length : paginationSize);

    currentVisibleImageDisplayedUrlList = imageDisplayedUrlList.sublist(
        0, paginationSize > imageDisplayedUrlList.length ? imageDisplayedUrlList.length : paginationSize);

    setState(() {
      refreshController.refreshCompleted();
    });
  }

  void doLoadUploadedImages() async {
    if (imageUrlList.length < paginationSize * (pageIndex + 1)) {
    } else {
      pageIndex = pageIndex + 1;
      currentVisibleImageUrlList.clear();
      currentVisibleImageUrlList = imageUrlList.sublist(
          (pageIndex) * paginationSize,
          imageUrlList.length > paginationSize * (pageIndex + 1)
              ? paginationSize * (pageIndex + 1)
              : imageUrlList.length);
      currentVisibleImageDisplayedUrlList.clear();
      currentVisibleImageDisplayedUrlList = imageDisplayedUrlList.sublist(
          (pageIndex) * paginationSize,
          imageDisplayedUrlList.length > paginationSize * (pageIndex + 1)
              ? paginationSize * (pageIndex + 1)
              : imageDisplayedUrlList.length);
      selectedImagesBoolList = List.filled(paginationSize, false);
    }
    loadUploadedImages();
  }

  void loadUploadedImages() async {
    setState(() {
      if (currentVisibleImageUrlList.isEmpty || imageUrlList.isEmpty) {
        refreshController.loadNoData();
      } else if (pageIndex == 0) {
        refreshController.refreshCompleted();
      } else if (imageUrlList.length < paginationSize * (pageIndex + 1)) {
        refreshController.loadNoData();
      } else {
        refreshController.loadComplete();
      }
    });
  }

  void doBackUploadedImages() async {
    pageIndex = pageIndex - 1;
    currentVisibleImageUrlList.clear();
    currentVisibleImageDisplayedUrlList.clear();
    currentVisibleImageUrlList = imageUrlList.sublist((pageIndex) * paginationSize, paginationSize * (pageIndex + 1));
    currentVisibleImageDisplayedUrlList =
        imageDisplayedUrlList.sublist((pageIndex) * paginationSize, paginationSize * (pageIndex + 1));
    selectedImagesBoolList = List.filled(paginationSize, false);
    backUploadedImages();
  }

  void backUploadedImages() async {
    setState(() {
      refreshController.refreshCompleted();
    });
  }
}
