import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:horopic/utils/global.dart';
import 'package:horopic/pages/homePage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/services.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:horopic/utils/common_func.dart';
import 'package:horopic/album/albumSQL.dart';
import 'dart:io';
import 'dart:convert';
import 'package:horopic/configurePage/configurePage.dart';
import 'package:horopic/album/albumPreview.dart';
import 'package:horopic/album/LoadStateChanged.dart';
import 'package:msh_checkbox/msh_checkbox.dart';
import 'package:horopic/utils/deleter.dart';
import 'package:horopic/router/application.dart';
import 'package:horopic/router/routes.dart';
import 'package:fluro/fluro.dart';
//一小部分代码参考了开源项目flutter-picgo 项目地址https://github.com/PicGo/flutter-picgo

//show uploaded images
class UploadedImages extends StatefulWidget {
  const UploadedImages({super.key});

  @override
  _UploadedImagesState createState() => _UploadedImagesState();
}

class _UploadedImagesState extends State<UploadedImages> {
  List showedImages = []; //全部图片
  List showedImageUrl = []; //showedImages的url
  List showedImagePaths = []; //showedImages的路径
  List showedImageName = []; //showedImages的name
  List showedImageId = []; //showedImages的id
  List showedImagePictureKey = []; //showedImages的pictureKey
  List showedImageDisplayAddressUrl = []; //showedImages的用来显示到相册里的url

  final int _perPageItemSize = 12;
  List currentShowedImagesUrl = []; //当前显示的图片url,用来复制
  List currentShowedImagesDisplayAddressUrl = []; //当前显示的图片用来显示到相册里的url

  int _currentPage = 0;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  List selectedImages = [];
  List<bool> selectedImagesBool = List.filled(12, false);
  Map<String, String> nameToPara = {
    'lskypro': '兰空',
    'smms': 'SM.MS',
    'github': 'GitHub',
    'imgur': 'Imgur',
    'qiniu': '七牛云',
    'tencent': '腾讯云',
    'aliyun': '阿里云',
    'upyun': '又拍云',
  };

  @override
  void initState() {
    super.initState();
    _onRefresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
              '${nameToPara[Global.defaultShowedPBhost]}相册 - 第${_currentPage + 1}页'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: selectedImagesBool.contains(true)
                  ? const Icon(Icons.delete,
                      color: Color.fromARGB(255, 236, 127, 120), size: 40.0)
                  : const Icon(Icons.delete_outline,
                      color: Colors.white, size: 40.0),
              onPressed: () async {
                if (!selectedImagesBool.contains(true) ||
                    currentShowedImagesUrl.isEmpty) {
                  Fluttertoast.showToast(
                      backgroundColor:
                          Theme.of(context).brightness == Brightness.light
                              ? Colors.black
                              : Colors.white,
                      textColor:
                          Theme.of(context).brightness == Brightness.light
                              ? Colors.white
                              : Colors.black,
                      msg: '没有选择图片');
                  return;
                }
                return showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text(
                        '删除全部图片',
                        textAlign: TextAlign.center,
                      ),
                      content: const Text(
                        '是否删除全部选择的图片？\n请注意检查删除本地和删除云端两项设置!',
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
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                                onPressed: () async {
                                  try {
                                    List<int> toDelete = [];
                                    for (int i = 0;
                                        i < currentShowedImagesUrl.length;
                                        i++) {
                                      if (selectedImagesBool[i]) {
                                        toDelete.add(i);
                                      }
                                    }
                                    selectedImagesBool =
                                        List.filled(_perPageItemSize, false);
                                    Navigator.pop(context);
                                    await deleteImageAll(toDelete);
                                    Fluttertoast.showToast(
                                        backgroundColor:
                                            Theme.of(this.context).brightness ==
                                                    Brightness.light
                                                ? Colors.black
                                                : Colors.white,
                                        textColor:
                                            Theme.of(this.context).brightness ==
                                                    Brightness.light
                                                ? Colors.white
                                                : Colors.black,
                                        msg: '删除完成');
                                    return;
                                  } catch (e) {
                                    //跳转一下
                                    //Navigator.push(
                                    //  context,
                                    //   MaterialPageRoute(
                                    //       builder: (context) =>
                                    //            UploadedImages()));
                                    Application.router.navigateTo(
                                        context, Routes.albumUploadedImages,
                                        transition: TransitionType.none);
                                    showAlertDialog(
                                        barrierDismissible: true,
                                        context: context,
                                        title: '错误',
                                        content: e.toString());
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
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
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
          ]),
      body: SmartRefresher(
          enablePullDown: true,
          enablePullUp: showedImageUrl.length > _perPageItemSize,
          header: ClassicHeader(
            refreshStyle: RefreshStyle.Follow,
            idleText: '下拉刷新',
            refreshingText: '正在刷新',
            completeText: '刷新完成',
            failedText: '刷新失败',
            releaseText: '释放刷新',
          ),
          footer: ClassicFooter(
            loadStyle: LoadStyle.ShowWhenLoading,
            idleText: '上拉加载',
            loadingText: '正在加载',
            noDataText: '没有更多图片啦',
            failedText: '没有更多图片啦',
            canLoadingText: '释放加载',
          ),
          controller: _refreshController,
          onRefresh: _onRefresh,
          onLoading: _onLoading,
          child: GridView.builder(
            padding: EdgeInsets.all(2),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                //mainAxisSpacing: 10,
                // crossAxisSpacing: 10,
                childAspectRatio: 1),
            itemCount: currentShowedImagesUrl.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  if (Global.defaultShowedPBhost == 'lskypro' ||
                      Global.defaultShowedPBhost == 'github' ||
                      Global.defaultShowedPBhost == 'smms') {
                    String urlList = currentShowedImagesUrl.join(',');
                    Application.router.navigateTo(context,
                        '${Routes.albumImagePreview}?index=$index&images=${Uri.encodeComponent(urlList)}',
                        transition: TransitionType.none);
                  } else if (Global.defaultShowedPBhost == 'imgur') {
                    String urlList =
                        currentShowedImagesDisplayAddressUrl.join(',');
                    Application.router.navigateTo(context,
                        '${Routes.albumImagePreview}?index=$index&images=${Uri.encodeComponent(urlList)}',
                        transition: TransitionType.none);
                  } else if (Global.defaultShowedPBhost == 'qiniu') {
                    String urlList = currentShowedImagesUrl.join(',');
                    Application.router.navigateTo(context,
                        '${Routes.albumImagePreview}?index=$index&images=${Uri.encodeComponent(urlList)}',
                        transition: TransitionType.none);
                  } else if (Global.defaultShowedPBhost == 'tencent') {
                    String urlList = currentShowedImagesUrl.join(',');
                    Application.router.navigateTo(context,
                        '${Routes.albumImagePreview}?index=$index&images=${Uri.encodeComponent(urlList)}',
                        transition: TransitionType.none);
                  } else if (Global.defaultShowedPBhost == 'aliyun') {
                    String urlList = currentShowedImagesUrl.join(',');
                    Application.router.navigateTo(context,
                        '${Routes.albumImagePreview}?index=$index&images=${Uri.encodeComponent(urlList)}',
                        transition: TransitionType.none);
                  } else if (Global.defaultShowedPBhost == 'upyun') {
                    String urlList = currentShowedImagesUrl.join(',');
                    Application.router.navigateTo(context,
                        '${Routes.albumImagePreview}?index=$index&images=${Uri.encodeComponent(urlList)}',
                        transition: TransitionType.none);
                  }
                },
                onDoubleTap: () =>
                    copyFormatedLink(index, Global.defaultLKformat),
                onLongPressStart: (LongPressStartDetails details) {
                  double dx = details.globalPosition.dx;
                  double dy = details.globalPosition.dy - 20;
                  handleOnLongPress(context, dx, dy, index);
                },
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      height: 150,
                      child: Card(
                        clipBehavior: Clip.antiAlias,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadiusDirectional.circular(8)),
                        //这玩意只识别http或者https开头的链接
                        child: ExtendedImage.network(
                          currentShowedImagesDisplayAddressUrl[index],
                          clearMemoryCacheIfFailed: true,
                          retries: 5,
                          height: 150,
                          fit: BoxFit.cover,
                          cache: true,
                          border: Border.all(
                              color: selectedImagesBool[index]
                                  ? Colors.red
                                  : Colors.transparent,
                              width: 2),
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          loadStateChanged: (state) =>
                              defaultLoadStateChanged(state, iconSize: 30),
                        ),
                      ),
                    ),
                    Positioned(
                      // ignore: sort_child_properties_last
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(35)),
                            color: Color.fromARGB(255, 199, 208, 216)),
                        padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                        child: MSHCheckbox(
                          uncheckedColor: Colors.blue,
                          size: 20,
                          checkedColor: Colors.blue,
                          value: selectedImagesBool[index],
                          style: MSHCheckboxStyle.fillScaleCheck,
                          onChanged: (selected) {
                            setState(() {
                              if (selected) {
                                selectedImagesBool[index] = true;
                              } else {
                                selectedImagesBool[index] = false;
                              }
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
          Container(
              height: 40,
              width: 40,
              child: FloatingActionButton(
                heroTag: 'switch',
                backgroundColor: const Color.fromARGB(255, 180, 236, 182),
                //select host menu
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
                        children: [
                          SimpleDialogOption(
                            child:
                                const Text('兰空图床', textAlign: TextAlign.center),
                            onPressed: () {
                              Global.setShowedPBhost('lskypro');
                              Navigator.pop(context);
                              _currentPage = 0;
                              _onRefresh();
                            },
                          ),
                          SimpleDialogOption(
                            child: const Text('SM.MS',
                                textAlign: TextAlign.center),
                            onPressed: () {
                              Global.setShowedPBhost('smms');
                              Navigator.pop(context);
                              _currentPage = 0;
                              _onRefresh();
                            },
                          ),
                          SimpleDialogOption(
                            child: const Text('Github',
                                textAlign: TextAlign.center),
                            onPressed: () {
                              Global.defaultShowedPBhost = 'github';
                              Navigator.pop(context);
                              _currentPage = 0;
                              _onRefresh();
                            },
                          ),
                          SimpleDialogOption(
                            child: const Text('Imgur',
                                textAlign: TextAlign.center),
                            onPressed: () {
                              Global.defaultShowedPBhost = 'imgur';
                              Navigator.pop(context);
                              _currentPage = 0;
                              _onRefresh();
                            },
                          ),
                          SimpleDialogOption(
                            child:
                                const Text('七牛云', textAlign: TextAlign.center),
                            onPressed: () {
                              Global.defaultShowedPBhost = 'qiniu';
                              Navigator.pop(context);
                              _currentPage = 0;
                              _onRefresh();
                            },
                          ),
                          SimpleDialogOption(
                            child:
                                const Text('腾讯云', textAlign: TextAlign.center),
                            onPressed: () {
                              Global.defaultShowedPBhost = 'tencent';
                              Navigator.pop(context);
                              _currentPage = 0;
                              _onRefresh();
                            },
                          ),
                          SimpleDialogOption(
                            child:
                                const Text('阿里云', textAlign: TextAlign.center),
                            onPressed: () {
                              Global.defaultShowedPBhost = 'aliyun';
                              Navigator.pop(context);
                              _currentPage = 0;
                              _onRefresh();
                            },
                          ),
                          SimpleDialogOption(
                            child:
                                const Text('又拍云', textAlign: TextAlign.center),
                            onPressed: () {
                              Global.defaultShowedPBhost = 'upyun';
                              Navigator.pop(context);
                              _currentPage = 0;
                              _onRefresh();
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
                child: const Icon(
                  Icons.switch_left_outlined,
                  size: 30,
                ),
              )),
          const SizedBox(width: 10),
          Container(
              height: 40,
              width: 40,
              child: FloatingActionButton(
                heroTag: 'Home',
                backgroundColor: Colors.blue,
                //select host menu
                onPressed: () async {
                  setState(() {
                    _currentPage = 0;
                    currentShowedImagesUrl.clear();
                    currentShowedImagesDisplayAddressUrl.clear();
                    selectedImagesBool = List.filled(
                      _perPageItemSize,
                      false,
                    );
                    _refreshController.resetNoData();
                  });
                  initLoadUploadedImages();
                },
                child: const Icon(
                  Icons.home_outlined,
                  size: 30,
                ),
              )),
          const SizedBox(width: 10),
          Container(
              height: 40,
              width: 40,
              child: FloatingActionButton(
                heroTag: 'copy',
                backgroundColor: selectedImagesBool.contains(true)
                    ? const Color.fromARGB(255, 232, 177, 241)
                    : Colors.transparent,
                elevation: 5,
                //select host menu
                onPressed: () async {
                  if (!selectedImagesBool.contains(true)) {
                    Fluttertoast.showToast(
                        msg: "请先选择图片",
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

                    for (int i = 0; i < currentShowedImagesUrl.length; i++) {
                      if (selectedImagesBool[i]) {
                        String finalFormatedurl = ' ';
                        finalFormatedurl =
                            linkGenerateDict[Global.defaultLKformat]!(
                                currentShowedImagesUrl[i],
                                showedImageName[
                                    i + _perPageItemSize * _currentPage]);

                        multiUrls.add(finalFormatedurl);
                      }
                    }
                    await Clipboard.setData(ClipboardData(
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
                child: const Icon(Icons.copy),
              )),
          const SizedBox(width: 10),
          Container(
              height: 40,
              width: 40,
              child: FloatingActionButton(
                heroTag: 'select',
                backgroundColor: Color.fromARGB(255, 248, 196, 237),
                elevation: 5,
                //select host menu
                onPressed: () async {
                  if (currentShowedImagesUrl.isEmpty) {
                    Fluttertoast.showToast(
                        msg: "相册为空",
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
                  } else if (selectedImagesBool.contains(true)) {
                    setState(() {
                      selectedImagesBool = List.filled(
                          selectedImagesBool.length, false,
                          growable: false);
                    });
                  } else {
                    setState(() {
                      selectedImagesBool = List.filled(
                          selectedImagesBool.length, true,
                          growable: false);
                    });
                  }
                },
                child: const Icon(Icons.check_circle_outline),
              )),
        ],
      ),
    );
  }

  copyFormatedLink(int index, String format) async {
    String link = currentShowedImagesUrl[index];
    String filename = showedImageName[index + _currentPage * _perPageItemSize];
    String formatedLink = '';
    formatedLink = linkGenerateDict[format]!(link, filename);
    Clipboard.setData(ClipboardData(text: formatedLink));
    Fluttertoast.showToast(
        msg: "$format已复制",
        toastLength: Toast.LENGTH_SHORT,
        timeInSecForIosWeb: 2,
        fontSize: 16.0);
  }

  handleOnLongPress(BuildContext context, double dx, double dy, int index) {
    showMenu(
        context: context,
        position: RelativeRect.fromLTRB(dx, dy, dx + 50, dy - 50),
        items: [
          const PopupMenuItem(
            height: 20,
            value: 1,
            child: Center(
              child: Text('Url', textAlign: TextAlign.center),
            ),
          ),
          //divider
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
          break;
        case 2:
          copyFormatedLink(index, 'html');
          break;
        case 3:
          copyFormatedLink(index, 'markdown');
          break;
        case 4:
          copyFormatedLink(index, 'bbcode');
          break;
        case 5:
          copyFormatedLink(index, 'markdown_with_link');
          break;
        case 6:
          copyFormatedLink(index, 'custom');
          break;
        case 7:
          try {
            await deleteImage(index);
            break;
          } catch (e) {
            Fluttertoast.showToast(
                msg: "删除失败",
                toastLength: Toast.LENGTH_SHORT,
                timeInSecForIosWeb: 2,
                backgroundColor:
                    Theme.of(context).brightness == Brightness.light
                        ? Colors.black
                        : Colors.white,
                textColor: Theme.of(context).brightness == Brightness.light
                    ? Colors.white
                    : Colors.black,
                fontSize: 16.0);
          }
      }
    });
  }

  deleteImageAll(List imagesIndex) async {
    bool deleteLocal = await Global.getDeleteLocal();
    bool deleteCloud = await Global.getDeleteCloud();
    for (int i = 0; i < imagesIndex.length; i++) {
      try {
        Map deleteConfig = {
          'pictureKey': showedImagePictureKey[
              imagesIndex[i] + (_currentPage * _perPageItemSize) - i],
          "name": showedImageName[
              imagesIndex[i] + (_currentPage * _perPageItemSize) - i],
        };
        if (deleteCloud) {
          await deleterentry(deleteConfig);
        }
        await AlbumSQL.deleteData(
            Global.imageDB!,
            Global.defaultShowedPBhost,
            showedImageId[
                imagesIndex[i] + (_currentPage * _perPageItemSize) - i]);
        if (deleteLocal) {
          try {
            await File(showedImagePaths[
                    imagesIndex[i] + (_currentPage * _perPageItemSize) - i])
                .delete();
          } catch (e) {}
        }
        showedImageId
            .removeAt(imagesIndex[i] + (_currentPage * _perPageItemSize) - i);
        showedImageUrl
            .removeAt(imagesIndex[i] + (_currentPage * _perPageItemSize) - i);
        showedImageDisplayAddressUrl
            .removeAt(imagesIndex[i] + (_currentPage * _perPageItemSize) - i);
        showedImagePaths
            .removeAt(imagesIndex[i] + (_currentPage * _perPageItemSize) - i);
        showedImageName
            .removeAt(imagesIndex[i] + (_currentPage * _perPageItemSize) - i);
        showedImagePictureKey
            .removeAt(imagesIndex[i] + (_currentPage * _perPageItemSize) - i);
        setState(() {
          currentShowedImagesUrl = showedImageUrl.sublist(
              _currentPage * _perPageItemSize,
              (_currentPage + 1) * _perPageItemSize > showedImageUrl.length
                  ? showedImageUrl.length
                  : (_currentPage + 1) * _perPageItemSize);
          currentShowedImagesDisplayAddressUrl =
              showedImageDisplayAddressUrl.sublist(
                  _currentPage * _perPageItemSize,
                  (_currentPage + 1) * _perPageItemSize >
                          showedImageDisplayAddressUrl.length
                      ? showedImageDisplayAddressUrl.length
                      : (_currentPage + 1) * _perPageItemSize);
        });
      } catch (e) {
        rethrow;
      }
    }
    return true;
  }

  deleteImage(int index) async {
    bool deleteLocal = await Global.getDeleteLocal();
    bool deleteCloud = await Global.getDeleteCloud();
    try {
      Map deleteConfig = {
        'pictureKey':
            showedImagePictureKey[index + (_currentPage * _perPageItemSize)],
        "name": showedImageName[index + (_currentPage * _perPageItemSize)],
      };
      if (deleteCloud) {
        await deleterentry(deleteConfig);
      }

      await AlbumSQL.deleteData(Global.imageDB!, Global.defaultShowedPBhost,
          showedImageId[index + (_currentPage * _perPageItemSize)]);

      if (deleteLocal) {
        try {
          await File(showedImagePaths[index + _currentPage * _perPageItemSize])
              .delete();
        } catch (e) {}
      }
      setState(() {
        showedImageId.removeAt(index + _perPageItemSize * _currentPage);
        showedImageUrl.removeAt(index + _perPageItemSize * _currentPage);
        showedImageDisplayAddressUrl
            .removeAt(index + _perPageItemSize * _currentPage);
        showedImagePictureKey.removeAt(index + _perPageItemSize * _currentPage);
        showedImageName.removeAt(index + _perPageItemSize * _currentPage);
        showedImagePaths.removeAt(index + _perPageItemSize * _currentPage);
        currentShowedImagesUrl.removeAt(index);
        currentShowedImagesDisplayAddressUrl.removeAt(index);
        selectedImagesBool = List.filled(_perPageItemSize, false);
        if (currentShowedImagesUrl.isEmpty && _currentPage == 0) {
          currentShowedImagesUrl = [];
          currentShowedImagesDisplayAddressUrl = [];
        } else if (currentShowedImagesUrl.isEmpty && _currentPage > 0) {
          _currentPage--;
          currentShowedImagesUrl = showedImageUrl.sublist(
              _currentPage * _perPageItemSize,
              (_currentPage + 1) * _perPageItemSize);
          currentShowedImagesDisplayAddressUrl =
              showedImageDisplayAddressUrl.sublist(
                  _currentPage * _perPageItemSize,
                  (_currentPage + 1) * _perPageItemSize);
        } else if (showedImageUrl.length >=
            (_currentPage + 1) * _perPageItemSize) {
          currentShowedImagesUrl = showedImageUrl.sublist(
              _currentPage * _perPageItemSize,
              (_currentPage + 1) * _perPageItemSize);
          currentShowedImagesDisplayAddressUrl =
              showedImageDisplayAddressUrl.sublist(
                  _currentPage * _perPageItemSize,
                  (_currentPage + 1) * _perPageItemSize);
        } else if (showedImageUrl.length <
            (_currentPage + 1) * _perPageItemSize) {
          currentShowedImagesUrl = showedImageUrl.sublist(
              _currentPage * _perPageItemSize, showedImageUrl.length);
          currentShowedImagesDisplayAddressUrl =
              showedImageDisplayAddressUrl.sublist(
                  _currentPage * _perPageItemSize,
                  showedImageDisplayAddressUrl.length);
        }
      });
    } catch (e) {
      rethrow;
    }
  }

  /// 刷新或返回上一页
  _onRefresh() async {
    if (_currentPage == 0 || _currentPage == 1) {
      setState(() {
        _currentPage = 0;
        currentShowedImagesUrl.clear();
        currentShowedImagesDisplayAddressUrl.clear();
        selectedImagesBool = List.filled(
          _perPageItemSize,
          false,
        );
        _refreshController.resetNoData();
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

  void initLoadUploadedImages() async {
    String defaultUser = await Global.getUser();
    //所有的图床的图片ID
    Map<String, dynamic> imageList =
        await AlbumSQL.getAllTableData(Global.imageDB!, 'id');
    //默认图床的图片ID
    showedImageId = imageList[Global.defaultShowedPBhost]!;
    showedImageId = showedImageId.reversed.toList();
    showedImageUrl.clear();
    showedImageDisplayAddressUrl.clear();
    showedImagePictureKey.clear();
    showedImageName.clear();
    showedImagePaths.clear();
    for (int i = 0; i < showedImageId.length; i++) {
      List<Map<String, dynamic>> maps = await AlbumSQL.queryData(
          Global.imageDB!, Global.defaultShowedPBhost, showedImageId[i]);
      if (Global.defaultShowedPBhost == 'smms') {
        showedImageUrl.add(maps[0]['url']); //smms的returnUrl就是用来复制和相册展示的url
        showedImageDisplayAddressUrl.add(maps[0]['url']);
        showedImageName.add(maps[0]['name']);
        showedImagePictureKey.add(maps[0]['pictureKey']);
        showedImagePaths.add(maps[0]['path']);
      } else if (Global.defaultShowedPBhost == 'lskypro') {
        showedImageUrl.add(maps[0]['url']); //用来复制的url
        showedImageDisplayAddressUrl
            .add(maps[0]['hostSpecificArgA']); //用来相册展示的url
        showedImageName.add(maps[0]['name']);
        showedImagePictureKey.add(maps[0]['pictureKey']);
        showedImagePaths.add(maps[0]['path']);
      } else if (Global.defaultShowedPBhost == 'github') {
        if (!maps[0]['url'].toString().startsWith('https://') &&
            !maps[0]['url'].toString().startsWith('http://')) {
          showedImageUrl.add('http://' + maps[0]['url']);
        } else {
          showedImageUrl.add(maps[0]['url']);
        }
        // showedImageUrl.add(maps[0]['hostSpecificArgA']); //用来复制的url
        if (!maps[0]['hostSpecificArgA'].toString().startsWith('https://') &&
            !maps[0]['hostSpecificArgA'].toString().startsWith('http://')) {
          showedImageDisplayAddressUrl
              .add('http://' + maps[0]['hostSpecificArgA']);
        } else {
          showedImageDisplayAddressUrl.add(maps[0]['hostSpecificArgA']);
        }
        // showedImageDisplayAddressUrl
        //  .add(maps[0]['hostSpecificArgA']); //用来相册展示的url
        showedImageName.add(maps[0]['name']);
        showedImagePictureKey.add(maps[0]['pictureKey']);
        showedImagePaths.add(maps[0]['path']);
      } else if (Global.defaultShowedPBhost == 'imgur') {
        showedImageUrl.add(maps[0]['url']); //用来复制的url
        showedImageDisplayAddressUrl
            .add(maps[0]['hostSpecificArgA']); //用来显示的url
        showedImageName.add(maps[0]['name']);
        showedImagePictureKey.add(maps[0]['pictureKey']);
        showedImagePaths.add(maps[0]['path']);
      } else if (Global.defaultShowedPBhost == 'qiniu') {
        if (!maps[0]['url'].toString().startsWith('https://') &&
            !maps[0]['url'].toString().startsWith('http://')) {
          showedImageUrl.add('http://' + maps[0]['url']);
        } else {
          showedImageUrl.add(maps[0]['url']);
        }
        if (!maps[0]['hostSpecificArgA'].toString().startsWith('https://') &&
            !maps[0]['hostSpecificArgA'].toString().startsWith('http://')) {
          showedImageDisplayAddressUrl
              .add('http://' + maps[0]['hostSpecificArgA']);
        } else {
          showedImageDisplayAddressUrl.add(maps[0]['hostSpecificArgA']);
        }
        showedImageName.add(maps[0]['name']);
        showedImagePictureKey.add(maps[0]['pictureKey']);
        showedImagePaths.add(maps[0]['path']);
      } else if (Global.defaultShowedPBhost == 'tencent') {
        if (!maps[0]['url'].toString().startsWith('https://') &&
            !maps[0]['url'].toString().startsWith('http://')) {
          showedImageUrl.add('http://' + maps[0]['url']);
        } else {
          showedImageUrl.add(maps[0]['url']);
        }
        if (!maps[0]['hostSpecificArgA'].toString().startsWith('https://') &&
            !maps[0]['hostSpecificArgA'].toString().startsWith('http://')) {
          showedImageDisplayAddressUrl
              .add('http://' + maps[0]['hostSpecificArgA']);
        } else {
          showedImageDisplayAddressUrl.add(maps[0]['hostSpecificArgA']);
        }
        showedImageName.add(maps[0]['name']);
        showedImagePictureKey.add(maps[0]['pictureKey']);
        showedImagePaths.add(maps[0]['path']);
      } else if (Global.defaultShowedPBhost == 'aliyun') {
        if (!maps[0]['url'].toString().startsWith('https://') &&
            !maps[0]['url'].toString().startsWith('http://')) {
          showedImageUrl.add('http://' + maps[0]['url']);
        } else {
          showedImageUrl.add(maps[0]['url']);
        }
        if (!maps[0]['hostSpecificArgA'].toString().startsWith('https://') &&
            !maps[0]['hostSpecificArgA'].toString().startsWith('http://')) {
          showedImageDisplayAddressUrl
              .add('http://' + maps[0]['hostSpecificArgA']);
        } else {
          showedImageDisplayAddressUrl.add(maps[0]['hostSpecificArgA']);
        }
        showedImageName.add(maps[0]['name']);
        showedImagePictureKey.add(maps[0]['pictureKey']);
        showedImagePaths.add(maps[0]['path']);
      } else if (Global.defaultShowedPBhost == 'upyun') {
        if (!maps[0]['url'].toString().startsWith('https://') &&
            !maps[0]['url'].toString().startsWith('http://')) {
          showedImageUrl.add('http://' + maps[0]['url']);
        } else {
          showedImageUrl.add(maps[0]['url']);
        }
        if (!maps[0]['hostSpecificArgA'].toString().startsWith('https://') &&
            !maps[0]['hostSpecificArgA'].toString().startsWith('http://')) {
          showedImageDisplayAddressUrl
              .add('http://' + maps[0]['hostSpecificArgA']);
        } else {
          showedImageDisplayAddressUrl.add(maps[0]['hostSpecificArgA']);
        }
        showedImageName.add(maps[0]['name']);
        showedImagePictureKey.add(maps[0]['pictureKey']);
        showedImagePaths.add(maps[0]['path']);
      }
    }

    currentShowedImagesUrl = showedImageUrl.sublist(
        0,
        _perPageItemSize > showedImageUrl.length
            ? showedImageUrl.length
            : _perPageItemSize);
    currentShowedImagesDisplayAddressUrl = showedImageDisplayAddressUrl.sublist(
        0,
        _perPageItemSize > showedImageDisplayAddressUrl.length
            ? showedImageDisplayAddressUrl.length
            : _perPageItemSize);

    setState(() {
      _refreshController.refreshCompleted();
    });
  }

  void doLoadUploadedImages() async {
    if (showedImageUrl.length < _perPageItemSize * (_currentPage + 1)) {
    } else {
      _currentPage = _currentPage + 1;
      currentShowedImagesUrl.clear();
      currentShowedImagesUrl = showedImageUrl.sublist(
          (_currentPage) * _perPageItemSize,
          showedImageUrl.length > _perPageItemSize * (_currentPage + 1)
              ? _perPageItemSize * (_currentPage + 1)
              : showedImageUrl.length);
      currentShowedImagesDisplayAddressUrl.clear();
      currentShowedImagesDisplayAddressUrl =
          showedImageDisplayAddressUrl.sublist(
              (_currentPage) * _perPageItemSize,
              showedImageDisplayAddressUrl.length >
                      _perPageItemSize * (_currentPage + 1)
                  ? _perPageItemSize * (_currentPage + 1)
                  : showedImageDisplayAddressUrl.length);
      selectedImagesBool = List.filled(_perPageItemSize, false);
    }
    LoadUploadedImages();
  }

  void LoadUploadedImages() async {
    setState(() {
      if (currentShowedImagesUrl.isEmpty || showedImageUrl.isEmpty) {
        _refreshController.loadNoData();
      } else if (_currentPage == 0) {
        _refreshController.refreshCompleted();
      } else if (showedImageUrl.length <
          _perPageItemSize * (_currentPage + 1)) {
        _refreshController.loadNoData();
      } else {
        _refreshController.loadComplete();
      }
    });
  }

  void doBackUploadedImages() async {
    _currentPage = _currentPage - 1;
    currentShowedImagesUrl.clear();
    currentShowedImagesDisplayAddressUrl.clear();
    currentShowedImagesUrl = showedImageUrl.sublist(
        (_currentPage) * _perPageItemSize,
        _perPageItemSize * (_currentPage + 1));
    currentShowedImagesDisplayAddressUrl = showedImageDisplayAddressUrl.sublist(
        (_currentPage) * _perPageItemSize,
        _perPageItemSize * (_currentPage + 1));
    selectedImagesBool = List.filled(_perPageItemSize, false);
    BackUploadedImages();
  }

  void BackUploadedImages() async {
    setState(() {
      _refreshController.refreshCompleted();
    });
  }
}
