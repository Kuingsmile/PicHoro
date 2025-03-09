import 'package:horopic/album/action_button.dart';
import 'package:universal_io/io.dart';
import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:extended_image/extended_image.dart';
import 'package:fluro/fluro.dart';
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

  // 新增：当前已加载的图片数量
  int _loadedImagesCount = 0;

  // 每次加载的图片数量
  final int _loadBatchSize = 12;

  // 是否正在加载更多图片
  bool _isLoading = false;

  // 是否已加载所有图片
  bool _hasLoadedAll = false;

  // 用于选择的列表 - Change to growable list
  List<bool> selectedImagesBoolList = [];

  // 滚动控制器
  final ScrollController _scrollController = ScrollController();

  RefreshController refreshController = RefreshController(initialRefresh: false);

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
    _initScrollListener();
    setState(() {
      _isLoading = true;
    });
    _onRefresh();
  }

  void _initScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels > _scrollController.position.maxScrollExtent - 800 &&
          !_isLoading &&
          !_hasLoadedAll) {
        _loadMoreImages();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
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
          Global.setLKformat(format);
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
          title: Column(
            children: [
              titleText(
                '${nameToPara[Global.defaultShowedPBhost]}相册',
              ),
              if (selectedImagesBoolList.contains(true))
                Text(
                  '已选择 ${selectedImagesBoolList.where((selected) => selected).length} 项',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white70),
                ),
            ],
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
                                  Global.setCustomLinkFormat(value);
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
                      height: 56.0,
                      padding: EdgeInsets.zero,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.cloud_off_outlined,
                                  size: 20,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  '同步删除云端',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onSurface,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            Tooltip(
                              message: '删除本地图片的同时也从云端删除',
                              child: Switch(
                                activeColor: Theme.of(context).colorScheme.primary,
                                value: Global.isDeleteCloud,
                                onChanged: (value) async {
                                  Global.setIsDeleteCloud(value);
                                  setState(() {});
                                  if (context.mounted) {
                                    showToastWithContext(context, value ? '已开启云端删除' : '已关闭云端删除');
                                    Navigator.pop(context);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const PopupMenuItem(
                      value: 1,
                      child: Row(
                        children: [
                          Icon(Icons.link, size: 20),
                          SizedBox(width: 12),
                          Text('选择默认链接格式'),
                        ],
                      ),
                    ),
                  ];
                }),
            IconButton(
              icon: selectedImagesBoolList.contains(true)
                  ? const Icon(Icons.delete, color: Color.fromARGB(255, 236, 127, 120), size: 40.0)
                  : const Icon(Icons.delete_outline, color: Colors.white, size: 40.0),
              onPressed: () async {
                if (!selectedImagesBoolList.contains(true) || imageUrlList.isEmpty) {
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
                      for (int i = 0; i < _loadedImagesCount; i++) {
                        if (selectedImagesBoolList[i]) {
                          toDelete.add(i);
                        }
                      }
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
      body: Column(
        children: [
          Expanded(
            child: SmartRefresher(
                enablePullDown: true,
                enablePullUp: !_hasLoadedAll,
                header: const ClassicHeader(
                  refreshStyle: RefreshStyle.Follow,
                  idleText: '下拉刷新',
                  refreshingText: '正在刷新',
                  completeText: '刷新完成',
                  failedText: '刷新失败',
                  releaseText: '释放刷新',
                ),
                footer: CustomFooter(
                  builder: (BuildContext context, LoadStatus? mode) {
                    Widget body;
                    if (mode == LoadStatus.idle) {
                      body = const Text("上拉加载更多");
                    } else if (mode == LoadStatus.loading) {
                      body = const CircularProgressIndicator(strokeWidth: 2.0);
                    } else if (mode == LoadStatus.failed) {
                      body = const Text("加载失败，请重试");
                    } else if (mode == LoadStatus.canLoading) {
                      body = const Text("释放加载更多");
                    } else {
                      body = const Text("没有更多图片了");
                    }
                    return SizedBox(
                      height: 55.0,
                      child: Center(child: body),
                    );
                  },
                ),
                controller: refreshController,
                onRefresh: _onRefresh,
                onLoading: _loadMoreImages,
                child: _isLoading && imageUrlList.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : imageUrlList.isEmpty
                        ? const Center(child: Text('暂无图片'))
                        : GridView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.only(left: 2, right: 2, top: 2, bottom: 60),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              childAspectRatio: 1,
                              mainAxisSpacing: 2,
                              crossAxisSpacing: 2,
                            ),
                            itemCount: _loadedImagesCount,
                            cacheExtent: 1000,
                            addRepaintBoundaries: true,
                            addAutomaticKeepAlives: true,
                            itemBuilder: (context, index) {
                              // 确保布尔值列表长度足够
                              if (index >= selectedImagesBoolList.length) {
                                selectedImagesBoolList.add(false);
                              }

                              return GestureDetector(
                                onTap: () => _handleImageTap(index),
                                onDoubleTap: () => copyFormatedLink(index, Global.defaultLKformat),
                                onLongPressStart: (LongPressStartDetails details) {
                                  handleOnLongPress(
                                      context, details.globalPosition.dx, details.globalPosition.dy - 20, index);
                                },
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    SizedBox(
                                      height: 150,
                                      child: Card(
                                        clipBehavior: Clip.antiAlias,
                                        shape:
                                            RoundedRectangleBorder(borderRadius: BorderRadiusDirectional.circular(8)),
                                        child: _buildImageWidget(index),
                                      ),
                                    ),
                                    Positioned(
                                      right: 4,
                                      top: 4,
                                      child: Container(
                                        decoration: const BoxDecoration(
                                            borderRadius: BorderRadius.all(Radius.circular(35)),
                                            color: Color.fromARGB(255, 199, 208, 216)),
                                        padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                                        child: MSHCheckbox(
                                          colorConfig: MSHColorConfig.fromCheckedUncheckedDisabled(
                                              checkedColor: Colors.blue,
                                              uncheckedColor: Colors.blue,
                                              disabledColor: Colors.grey),
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
                                    ),
                                  ],
                                ),
                              );
                            },
                          )),
          ),
          Container(
              padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 16.0),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4.0,
                    offset: const Offset(0, -1),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ActionButton(
                      icon: Icons.switch_left_outlined,
                      label: nameToPara[Global.defaultShowedPBhost] ?? '选择图床',
                      color: const Color.fromARGB(255, 180, 236, 182),
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
                                    _onRefresh();
                                  },
                                );
                              }).toList(),
                            );
                          },
                        );
                      },
                    ),
                    ActionButton(
                      icon: Icons.home_outlined,
                      label: '主页',
                      color: Colors.blue,
                      onPressed: () async {
                        setState(() {
                          _loadedImagesCount = 0;
                          imageUrlList.clear();
                          imageDisplayedUrlList.clear();
                          selectedImagesBoolList = List.filled(
                            _loadBatchSize,
                            false,
                          );
                          refreshController.resetNoData();
                        });
                        _initLoadImages();
                      },
                    ),
                    ActionButton(
                      icon: Icons.copy,
                      label: '复制',
                      color: selectedImagesBoolList.contains(true)
                          ? const Color.fromARGB(255, 232, 177, 241)
                          : Colors.grey,
                      onPressed: () async {
                        if (!selectedImagesBoolList.contains(true)) {
                          showToastWithContext(context, "请先选择图片");
                          return;
                        }

                        List<String> multiUrls = [];
                        for (int i = 0; i < _loadedImagesCount; i++) {
                          if (selectedImagesBoolList[i]) {
                            String finalFormatedurl =
                                linkGeneratorMap[Global.defaultLKformat]!(imageUrlList[i], imageFileNameList[i]);
                            multiUrls.add(finalFormatedurl);
                          }
                        }
                        await Clipboard.setData(ClipboardData(text: multiUrls.join('\n')));
                        showToast('已复制全部链接');
                      },
                    ),
                    ActionButton(
                      icon: selectedImagesBoolList.contains(true) ? Icons.deselect : Icons.select_all,
                      label: selectedImagesBoolList.contains(true) ? '取消' : '全选',
                      color: const Color.fromARGB(255, 248, 196, 237),
                      onPressed: () {
                        if (imageUrlList.isEmpty) {
                          showToastWithContext(context, '相册为空');
                          return;
                        }

                        setState(() {
                          final newValue = !selectedImagesBoolList.contains(true);
                          // Ensure we're setting the value for all images, not just displayed ones
                          for (int i = 0; i < selectedImagesBoolList.length; i++) {
                            selectedImagesBoolList[i] = newValue;
                          }
                        });
                      },
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  copyFormatedLink(int index, String format) async {
    await Clipboard.setData(
        ClipboardData(text: linkGeneratorMap[format]!(imageUrlList[index], imageFileNameList[index])));
    showToast('链接已复制');
  }

  handleOnLongPress(BuildContext context, double dx, double dy, int index) {
    final menuItems = [
      {'label': 'Url', 'value': 1, 'format': 'rawurl'},
      {'label': 'Html', 'value': 2, 'format': 'html'},
      {'label': 'Markdown', 'value': 3, 'format': 'markdown'},
      {'label': 'BBcode', 'value': 4, 'format': 'bbcode'},
      {'label': 'MD&Link', 'value': 5, 'format': 'markdown_with_link'},
      {'label': '自定义格式', 'value': 6, 'format': 'custom'},
      {'label': '删除', 'value': 7, 'format': ''},
    ];

    List<PopupMenuEntry<int>> popupItems = [];

    for (int i = 0; i < menuItems.length; i++) {
      popupItems.add(
        PopupMenuItem(
          height: 20,
          value: menuItems[i]['value'] as int,
          child: Center(
            child: Text(menuItems[i]['label'] as String, textAlign: TextAlign.center),
          ),
        ),
      );

      if (i < menuItems.length - 1) {
        popupItems.add(
          const PopupMenuItem(
            height: 1,
            value: 10,
            child: Divider(
              height: 1,
              color: Colors.grey,
              thickness: 1,
            ),
          ),
        );
      }
    }

    showMenu(context: context, position: RelativeRect.fromLTRB(dx, dy, dx + 50, dy - 50), items: popupItems)
        .then((value) async {
      if (value == null || value == 10) return;

      if (value == 7) {
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
      } else {
        final selectedItem = menuItems.firstWhere((item) => item['value'] == value);
        copyFormatedLink(index, selectedItem['format'] as String);
      }
    });
  }

  removeAllImages(List imagesIndex) async {
    bool isDeleteLocal = Global.getIsDeleteLocal();
    bool isDeleteCloud = Global.getIsDeleteCloud();
    List<int> sortedIndices = List<int>.from(imagesIndex)..sort((a, b) => b.compareTo(a));
    for (int index in sortedIndices) {
      try {
        Map deleteConfig = {
          'pictureKey': imagePictureKeyList[index],
          "name": imageFileNameList[index],
        };

        if (isDeleteCloud) {
          var result = await deleterentry(deleteConfig);
          if (result[0] != 'success') {
            showToast('云端删除失败');
            return;
          }
        }
        if (Global.defaultShowedPBhost == 'PBhostExtend1') {
          await AlbumSQL.deleteData(Global.imageDBExtend!, Global.defaultShowedPBhost, imageIdList[index]);
          try {
            await File(imageDisplayedUrlList[index]).delete();
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
          await AlbumSQL.deleteData(Global.imageDBExtend!, Global.defaultShowedPBhost, imageIdList[index]);
        } else {
          await AlbumSQL.deleteData(Global.imageDB!, Global.defaultShowedPBhost, imageIdList[index]);
        }

        if (isDeleteLocal) {
          try {
            await File(imageLocalPathList[index]).delete();
          } catch (e) {
            FLog.error(
                className: 'ImagePage',
                methodName: 'deleteImageAll',
                text: formatErrorMessage({}, e.toString()),
                dataLogType: DataLogType.ERRORS.toString());
          }
        }
        imageIdList.removeAt(index);
        imageUrlList.removeAt(index);
        imageDisplayedUrlList.removeAt(index);
        imageLocalPathList.removeAt(index);
        imageFileNameList.removeAt(index);
        imagePictureKeyList.removeAt(index);
        setState(() {
          _loadedImagesCount = imageUrlList.length;
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

    // After removing all selected images, update the selectedImagesBoolList for remaining images
    setState(() {
      selectedImagesBoolList = List.filled(imageUrlList.length, false, growable: true);
      _loadedImagesCount = imageUrlList.length < _loadedImagesCount ? imageUrlList.length : _loadedImagesCount;
    });

    return true;
  }

  deleteImage(int index) async {
    try {
      bool isDeleteLocal = Global.getIsDeleteLocal();
      bool isDeleteCloud = Global.getIsDeleteCloud();

      Map deleteConfig = {
        'pictureKey': imagePictureKeyList[index],
        "name": imageFileNameList[index],
      };

      if (isDeleteCloud) {
        var result = await deleterentry(deleteConfig);
        if (result[0] != 'success') {
          showToast('云端删除失败');
          return;
        }
      }

      if (Global.defaultShowedPBhost == 'PBhostExtend1') {
        await AlbumSQL.deleteData(Global.imageDBExtend!, Global.defaultShowedPBhost, imageIdList[index]);
        try {
          await File(imageDisplayedUrlList[index]).delete();
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
        await AlbumSQL.deleteData(Global.imageDBExtend!, Global.defaultShowedPBhost, imageIdList[index]);
      } else {
        await AlbumSQL.deleteData(Global.imageDB!, Global.defaultShowedPBhost, imageIdList[index]);
      }
      if (isDeleteLocal) {
        try {
          await File(imageLocalPathList[index]).delete();
        } catch (e) {
          FLog.error(
              className: 'ImagePage',
              methodName: 'deleteImage',
              text: formatErrorMessage({}, e.toString()),
              dataLogType: DataLogType.ERRORS.toString());
        }
      }

      setState(() {
        imageIdList.removeAt(index);
        imageUrlList.removeAt(index);
        imageDisplayedUrlList.removeAt(index);
        imagePictureKeyList.removeAt(index);
        imageFileNameList.removeAt(index);
        imageLocalPathList.removeAt(index);
        selectedImagesBoolList.removeAt(index);
        _loadedImagesCount = _loadedImagesCount > 0 ? _loadedImagesCount - 1 : 0;
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

  // 刷新操作
  _onRefresh() async {
    setState(() {
      _isLoading = true;
      _loadedImagesCount = 0;
      imageUrlList.clear();
      imageDisplayedUrlList.clear();
      imageIdList.clear();
      imageFileNameList.clear();
      imageLocalPathList.clear();
      imagePictureKeyList.clear();
      selectedImagesBoolList.clear(); // Now it's a growable list
      _hasLoadedAll = false;
    });
    await _initLoadImages();
    refreshController.refreshCompleted();
  }

  // 加载更多图片
  Future<void> _loadMoreImages() async {
    if (_isLoading || _hasLoadedAll) return;

    _isLoading = true;

    final nextBatchEnd = _loadedImagesCount + _loadBatchSize;
    final actualEnd = nextBatchEnd > imageUrlList.length ? imageUrlList.length : nextBatchEnd;

    if (_loadedImagesCount >= imageUrlList.length) {
      _hasLoadedAll = true;
      _isLoading = false;
      refreshController.loadNoData();
      return;
    }

    // Ensure selectedImagesBoolList is big enough
    if (selectedImagesBoolList.length < actualEnd) {
      int elementsToAdd = actualEnd - selectedImagesBoolList.length;
      selectedImagesBoolList.addAll(List.filled(elementsToAdd, false));
    }

    setState(() {
      _loadedImagesCount = actualEnd;
    });

    _isLoading = false;
    refreshController.loadComplete();
  }

  Future<void> _initLoadImages() async {
    setState(() {
      _isLoading = true;
    });
    Map<String, dynamic> dbIdList = await AlbumSQL.getAllTableData(Global.imageDB!, 'id');
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

    // 初始加载一批图片
    final initialLoadCount = _loadBatchSize > imageUrlList.length ? imageUrlList.length : _loadBatchSize;

    // Initialize selectedImagesBoolList with the right size
    selectedImagesBoolList = List.filled(imageUrlList.length, false, growable: true);

    setState(() {
      _loadedImagesCount = initialLoadCount;
      _hasLoadedAll = imageUrlList.length <= initialLoadCount;
      _isLoading = false;
    });

    if (_hasLoadedAll) {
      refreshController.loadNoData();
    } else {
      refreshController.loadComplete();
    }
  }

  // 优化：处理图片点击事件
  void _handleImageTap(int index) {
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
        String urlList = imageUrlList.sublist(0, _loadedImagesCount).join(',');
        Application.router.navigateTo(
            context, '${Routes.albumImagePreview}?index=$index&images=${Uri.encodeComponent(urlList)}',
            transition: TransitionType.none);
      case 'github':
        String urlList = '';
        for (int i = 0; i < _loadedImagesCount; i++) {
          urlList += imageUrlList[i] + ',';
        }
        Application.router.navigateTo(
            context, '${Routes.albumImagePreview}?index=$index&images=${Uri.encodeComponent(urlList)}',
            transition: TransitionType.none);
      case 'PBhostExtend1':
        String urlList = imageDisplayedUrlList.sublist(0, _loadedImagesCount).join(',');
        Application.router.navigateTo(
            context, '${Routes.localImagePreview}?index=$index&images=${Uri.encodeComponent(urlList)}',
            transition: TransitionType.none);
      case 'PBhostExtend4':
        List trueUrlList = [];
        List headersList = [];
        RegExp reg = RegExp(r'Basic (.*)');
        for (int i = 0; i < _loadedImagesCount; i++) {
          String trueUrl = imageDisplayedUrlList[i].replaceAll(reg, '');
          headersList.add({
            'Authorization': reg.firstMatch(imageDisplayedUrlList[i])![0],
          });
          trueUrlList.add(trueUrl);
        }
        String urlList = trueUrlList.join(',');
        Application.router.navigateTo(context,
            '${Routes.webdavImagePreview}?index=$index&images=${Uri.encodeComponent(urlList)}&headersList=${Uri.encodeComponent(jsonEncode(headersList))}',
            transition: TransitionType.none);
    }
  }

  // 优化：构建图片Widget
  Widget _buildImageWidget(int index) {
    if (Global.defaultShowedPBhost == 'github' ||
        Global.defaultShowedPBhost == 'imgur' ||
        Global.defaultShowedPBhost == 'upyun' ||
        Global.defaultShowedPBhost == 'aliyun' ||
        Global.defaultShowedPBhost == 'qiniu' ||
        Global.defaultShowedPBhost == 'tencent' ||
        Global.defaultShowedPBhost == 'smms' ||
        Global.defaultShowedPBhost == 'lskypro' ||
        Global.defaultShowedPBhost == 'PBhostExtend2' ||
        Global.defaultShowedPBhost == 'PBhostExtend3') {
      String imageUrl = imageDisplayedUrlList[index];

      return ExtendedImage.network(
        imageUrl,
        clearMemoryCacheIfFailed: true,
        retries: 5,
        height: 150,
        fit: BoxFit.cover,
        cache: true,
        cacheMaxAge: const Duration(days: 7),
        border: Border.all(color: selectedImagesBoolList[index] ? Colors.red : Colors.transparent, width: 2),
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        loadStateChanged: (state) => defaultLoadStateChanged(state, iconSize: 30),
      );
    } else if (Global.defaultShowedPBhost == 'PBhostExtend1') {
      return File(imageDisplayedUrlList[index]).existsSync()
          ? ExtendedImage.file(
              File(imageDisplayedUrlList[index]),
              fit: BoxFit.cover,
              clearMemoryCacheIfFailed: true,
              height: 150,
              border: Border.all(color: selectedImagesBoolList[index] ? Colors.red : Colors.transparent, width: 2),
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              loadStateChanged: (state) => defaultLoadStateChanged(state, iconSize: 30),
            )
          : const Icon(Icons.error, size: 30, color: Colors.red);
    } else if (Global.defaultShowedPBhost == 'PBhostExtend4') {
      if (imageDisplayedUrlList[index].contains('Basic')) {
        return ExtendedImage.network(
          imageDisplayedUrlList[index].replaceAll(RegExp(r'Basic (.*)'), ''),
          clearMemoryCacheIfFailed: true,
          retries: 5,
          height: 150,
          fit: BoxFit.cover,
          headers: {'Authorization': RegExp(r'Basic (.*)').firstMatch(imageDisplayedUrlList[index])![0]!},
          cache: true,
          border: Border.all(color: selectedImagesBoolList[index] ? Colors.red : Colors.transparent, width: 2),
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          loadStateChanged: (state) => defaultLoadStateChanged(state, iconSize: 30),
        );
      } else {
        return ExtendedImage.network(
          imageDisplayedUrlList[index],
          clearMemoryCacheIfFailed: true,
          retries: 5,
          height: 150,
          fit: BoxFit.cover,
          cache: true,
          border: Border.all(color: selectedImagesBoolList[index] ? Colors.red : Colors.transparent, width: 2),
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          loadStateChanged: (state) => defaultLoadStateChanged(state, iconSize: 30),
        );
      }
    }
    return const Icon(Icons.error, size: 30, color: Colors.red);
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
}
