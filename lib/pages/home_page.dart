import 'dart:io' as io;
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import 'package:external_path/external_path.dart';

import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:flutter/services.dart' as flutter_services;
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:fluro/fluro.dart';
import 'package:http/http.dart' as my_http;
import 'package:path_provider/path_provider.dart';

import 'package:horopic/album/album_sql.dart';
import 'package:horopic/utils/event_bus_utils.dart';
import 'package:horopic/pages/loading.dart';
import 'package:horopic/picture_host_configure/default_picture_host_select.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/utils/global.dart';
import 'package:horopic/utils/uploader.dart';

import 'package:horopic/router/application.dart';
import 'package:horopic/router/routers.dart';
import 'package:horopic/pages/upload_pages/upload_task.dart';
import 'package:horopic/pages/upload_pages/upload_utils.dart';
import 'package:horopic/pages/upload_pages/upload_status.dart';

Map uploadStatus = {
  'UploadStatus.uploading': "上传中",
  'UploadStatus.canceled': "取消",
  'UploadStatus.failed': "失败",
  'UploadStatus.completed': "完成",
  'UploadStatus.queued': "排队中",
  'UploadStatus.paused': "暂停",
};

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin<HomePage> {
  final ImagePicker _picker = ImagePicker();
  List clipboardList = [];
  List<String> uploadList = [];
  var uploadManager = UploadManager();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    uploadManager = UploadManager();
  }

  clearAllList() {
    setState(() {
      uploadList.clear();
      Global.imagesList.clear();
      Global.imageFile = null;
    });
  }

  @override
  void dispose() {
    super.dispose();
    clipboardList.clear();
  }

  _createUploadListItem() {
    List<Widget> list = [];
    for (var i = 0; i < uploadList.length; i++) {
      list.add(ListItem(
          onUploadPlayPausedPressed: (path) async {
            var task = uploadManager.getUpload(uploadList[i]);
            if (task != null && !task.status.value.isCompleted) {
              switch (task.status.value) {
                case UploadStatus.uploading:
                  await uploadManager.pauseUpload(path);
                  break;
                case UploadStatus.paused:
                  await uploadManager.resumeUpload(path);
                  break;
              }
              setState(() {});
            } else {
              await uploadManager.addUpload(path);
              setState(() {});
            }
          },
          onDelete: (path) async {
            await uploadManager.removeUpload(path);
            setState(() {});
          },
          path: uploadList[i],
          uploadTask: uploadManager.getUpload(uploadList[i])));
    }
    List<Widget> list2 = [
      const Divider(
        height: 5,
        color: Colors.transparent,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(
              onPressed: () async {
                await uploadManager.addBatchUploads(uploadList);
                setState(() {});
              },
              child: const Text(
                "全部开始",
                style: TextStyle(
                    color: Colors.blue,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              )),
          TextButton(
              onPressed: () async {
                await uploadManager.cancelBatchUploads(uploadList);
              },
              child: const Text(
                "全部取消",
                style: TextStyle(
                    color: Colors.blue,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              )),
          TextButton(
              onPressed: () async {
                await clearAllList();
                setState(() {});
              },
              child: const Text(
                "全部清空",
                style: TextStyle(
                    color: Colors.blue,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              )),
        ],
      ),
      ValueListenableBuilder(
          valueListenable: uploadManager.getBatchUploadProgress(uploadList),
          builder: (context, value, child) {
            return Container(
              color: const Color.fromARGB(255, 219, 239, 255),
              height: 10,
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: LinearProgressIndicator(
                value: value,
              ),
            );
          }),
    ];
    list2.addAll(list);

    return list2;
  }

  _imageFromCamera() async {
    final XFile? pickedImage =
        await _picker.pickImage(source: ImageSource.camera, imageQuality: 100);
    if (pickedImage == null) {
      showToast('未拍摄图片');
      return;
    }
    final io.File fileImage = io.File(pickedImage.path);
    Global.imagesList.clear();
    if (imageConstraint(context: context, image: fileImage)) {
      //图片重命名
      if (Global.iscustomRename == true) {
        Global.imageFile = await renamePictureWithCustomFormat(fileImage);
      } else if (Global.isTimeStamp == true) {
        Global.imageFile = await renamePictureWithTimestamp(fileImage);
      } else if (Global.isRandomName == true) {
        Global.imageFile = await renamePictureWithRandomString(fileImage);
      } else {
        Global.imageFile = fileImage;
      }
      Global.imagesList.add(Global.imageFile!);
    }
  }

  _imageFromNetwork() async {
    var url = await flutter_services.Clipboard.getData('text/plain');
    if (url == null) {
      showToast('剪贴板为空');
      return;
    }
    try {
      String urlStr = url.text!;
      List urlList;
      urlList = urlStr.split("\n");
      int successCount = 0;
      int failCount = 0;
      Global.imagesList.clear();

      for (var i = 0; i < urlList.length; i++) {
        if (urlList[i].isEmpty) {
          continue;
        }
        try {
          var response = await my_http.get(Uri.parse(urlList[i]));
          String tempPath =
              await getTemporaryDirectory().then((value) => value.path);
          String timeStamp = DateTime.now().millisecondsSinceEpoch.toString();
          String randomString = randomStringGenerator(5);
          io.File file = io.File('$tempPath/Web$timeStamp$randomString.jpg');
          await file.writeAsBytes(response.bodyBytes);
          Global.imageFile = file;
          if (imageConstraint(context: context, image: file)) {
            //图片重命名
            if (Global.iscustomRename == true) {
              Global.imageFile = await renamePictureWithCustomFormat(file);
            } else if (Global.isTimeStamp == true) {
              Global.imageFile = await renamePictureWithTimestamp(file);
            } else if (Global.isRandomName == true) {
              Global.imageFile = await renamePictureWithRandomString(file);
            } else {
              Global.imageFile = file;
            }
            Global.imagesList.add(Global.imageFile!);
          }
          successCount++;
        } catch (e) {
          failCount++;
          continue;
        }
      }
      if (successCount > 0) {
        showToast('获取成功$successCount张,失败$failCount张');
      } else {
        showToast('剪贴板内无链接');
      }
    } catch (e) {
      showToast('获取图片失败');
    }
  }

  _cameraAndBack() async {
    XFile? pickedImage =
        await _picker.pickImage(source: ImageSource.camera, imageQuality: 100);
    if (pickedImage == null) {
      if (Global.isCopyLink == true) {
        await flutter_services.Clipboard.setData(
            flutter_services.ClipboardData(text: clipboardList.toString()));
        clipboardList.clear();
      }
      return Fluttertoast.showToast(
          msg: "未选择图片",
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 2,
          fontSize: 16.0);
    }

    io.File fileImage = io.File(pickedImage.path);

    if (Global.iscustomRename == true) {
      Global.imageFile = await renamePictureWithCustomFormat(fileImage);
    } else if (Global.isTimeStamp == true) {
      Global.imageFile = await renamePictureWithTimestamp(fileImage);
    } else if (Global.isRandomName == true) {
      Global.imageFile = await renamePictureWithRandomString(fileImage);
    } else {
      Global.imageFile = fileImage;
    }
    await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return NetLoadingDialog(
            outsideDismiss: false,
            loading: true,
            loadingText: "上传中...",
            requestCallBack: _uploadAndBackToCamera(),
          );
        });

    if (Global.multiUpload == 'fail') {
      if (Global.isCopyLink == true) {
        if (clipboardList.length == 1) {
          await flutter_services.Clipboard.setData(
              flutter_services.ClipboardData(text: clipboardList[0]));
        } else {
          await flutter_services.Clipboard.setData(
              flutter_services.ClipboardData(
                  text: clipboardList
                      .toString()
                      .substring(1, clipboardList.toString().length - 1)
                      .replaceAll(',', '\n')));
        }
        clipboardList.clear();
      }
      return true;
    } else {
      _cameraAndBack();
    }
  }

  _uploadAndBackToCamera() async {
    String path = Global.imageFile!.path;
    String name = path.substring(path.lastIndexOf("/") + 1, path.length);
    Global.imageFile = null;

    var uploadResult = await uploaderentry(path: path, name: name);
    if (uploadResult[0] == "Error") {
      Global.multiUpload = 'fail';
      return showCupertinoAlertDialog(
          context: context, title: "上传失败!", content: "请先配置上传参数.");
    } else if (uploadResult[0] == "success") {
      eventBus.fire(AlbumRefreshEvent(albumKeepAlive: false));
      Map<String, dynamic> maps = {};
      //
      if (Global.defaultPShost == 'sm.ms') {
        //["success", formatedURL, returnUrl, pictureKey]
        maps = {
          'path': path,
          'name': name,
          'url': uploadResult[2], //返回地址可以直接访问
          'PBhost': Global.defaultPShost,
          'pictureKey': uploadResult[3],
          'hostSpecificArgA': 'test',
          'hostSpecificArgB': 'test',
          'hostSpecificArgC': 'test',
          'hostSpecificArgD': 'test',
          'hostSpecificArgE': 'test',
        };
      } else if (Global.defaultPShost == 'lsky.pro') {
        //["success", formatedURL, returnUrl, pictureKey, displayUrl]
        maps = {
          'path': path,
          'name': name,
          'url': uploadResult[2], //原图地址
          'PBhost': Global.defaultPShost,
          'pictureKey': uploadResult[3],
          'hostSpecificArgA': uploadResult[4], //实际展示的是缩略图
          'hostSpecificArgB': 'test',
          'hostSpecificArgC': 'test',
          'hostSpecificArgD': 'test',
          'hostSpecificArgE': 'test',
        };
      } else if (Global.defaultPShost == 'github') {
        //["success", formatedURL, returnUrl, pictureKey, downloadUrl]
        maps = {
          'path': path,
          'name': name,
          'url': uploadResult[2], //github文件原始地址
          'PBhost': Global.defaultPShost,
          'pictureKey': uploadResult[3],
          'hostSpecificArgA':
              uploadResult[4], //实际展示的是github download url或者自定义域名+路径
          'hostSpecificArgB': 'test',
          'hostSpecificArgC': 'test',
          'hostSpecificArgD': 'test',
          'hostSpecificArgE': 'test',
        };
      } else if (Global.defaultPShost == 'imgur') {
        // ["success", formatedURL, returnUrl, pictureKey,cdnUrl]
        maps = {
          'path': path,
          'name': name,
          'url': uploadResult[2], //imgur文件原始地址
          'PBhost': Global.defaultPShost,
          'pictureKey': uploadResult[3],
          'hostSpecificArgA': uploadResult[4], //实际展示的是imgur cdn url
          'hostSpecificArgB': 'test',
          'hostSpecificArgC': 'test',
          'hostSpecificArgD': 'test',
          'hostSpecificArgE': 'test',
        };
      } else if (Global.defaultPShost == 'qiniu') {
        // ["success", formatedURL, returnUrl, pictureKey,displayUrl]
        maps = {
          'path': path,
          'name': name,
          'url': uploadResult[2], //qiniu文件原始地址
          'PBhost': Global.defaultPShost,
          'pictureKey': uploadResult[3],
          'hostSpecificArgA': uploadResult[4], //实际展示的是displayUrl
          'hostSpecificArgB': 'test',
          'hostSpecificArgC': 'test',
          'hostSpecificArgD': 'test',
          'hostSpecificArgE': 'test',
        };
      } else if (Global.defaultPShost == 'tencent') {
        // ["success", formatedURL, returnUrl, pictureKey,displayUrl]
        maps = {
          'path': path,
          'name': name,
          'url': uploadResult[2], //tencent文件原始地址
          'PBhost': Global.defaultPShost,
          'pictureKey': uploadResult[3],
          'hostSpecificArgA': uploadResult[4], //实际展示的是displayUrl
          'hostSpecificArgB': 'test',
          'hostSpecificArgC': 'test',
          'hostSpecificArgD': 'test',
          'hostSpecificArgE': 'test',
        };
      } else if (Global.defaultPShost == 'aliyun') {
        // ["success", formatedURL, returnUrl, pictureKey,displayUrl]
        maps = {
          'path': path,
          'name': name,
          'url': uploadResult[2], //aliyun文件原始地址
          'PBhost': Global.defaultPShost,
          'pictureKey': uploadResult[3],
          'hostSpecificArgA': uploadResult[4], //实际展示的是displayUrl
          'hostSpecificArgB': 'test',
          'hostSpecificArgC': 'test',
          'hostSpecificArgD': 'test',
          'hostSpecificArgE': 'test',
        };
      } else if (Global.defaultPShost == 'upyun') {
        // ["success", formatedURL, returnUrl, pictureKey,displayUrl]
        maps = {
          'path': path,
          'name': name,
          'url': uploadResult[2], //upyun文件原始地址
          'PBhost': Global.defaultPShost,
          'pictureKey': uploadResult[3],
          'hostSpecificArgA': uploadResult[4], //实际展示的是displayUrl
          'hostSpecificArgB': 'test',
          'hostSpecificArgC': 'test',
          'hostSpecificArgD': 'test',
          'hostSpecificArgE': 'test',
        };
      }

      await AlbumSQL.insertData(
          Global.imageDB!, pBhostToTableName[Global.defaultPShost]!, maps);

      clipboardList.add(uploadResult[1]); //这里是formatedURL,应该是可以直接访问的地址
      Global.multiUpload = 'success';
      return true;
    } else if (uploadResult[0] == "failed") {
      Global.multiUpload = 'fail';
      return showCupertinoAlertDialog(
          context: context, title: "上传失败!", content: "上传参数有误.");
    } else {
      Global.multiUpload = 'fail';
      return showCupertinoAlertDialog(
          context: context, title: "上传失败!", content: uploadResult);
    }
  }

  _multiImagePickerFromGallery() async {
    AssetPickerConfig config = const AssetPickerConfig(
      maxAssets: 100,
      selectedAssets: [],
    );
    final List<AssetEntity>? pickedImage =
        await AssetPicker.pickAssets(context, pickerConfig: config);

    if (pickedImage == null) {
      showToast("未选择图片");
      return;
    }

    for (var i = 0; i < pickedImage.length; i++) {
      io.File? fileImage = await pickedImage[i].originFile;

      if (imageConstraint(context: context, image: fileImage!)) {
        if (Global.iscustomRename == true) {
          Global.imageFile = await renamePictureWithCustomFormat(fileImage);
        } else if (Global.isTimeStamp == true) {
          Global.imageFile = await renamePictureWithTimestamp(fileImage);
        } else if (Global.isRandomName == true) {
          Global.imageFile = await renamePictureWithRandomString(fileImage);
        } else {
          Global.imageFile = fileImage;
        }
        Global.imagesList.add(Global.imageFile!);
      }
    }
  }

  _upLoadImage() async {
    clipboardList.clear();
    int successCount = 0;
    int failCount = 0;

    List<String> failList = [];
    List<String> successList = [];
    failList.clear();
    successList.clear();

    for (io.File imageToTread in Global.imagesList) {
      String path = imageToTread.path;
      var name = path.substring(path.lastIndexOf("/") + 1, path.length);

      var uploadResult = await uploaderentry(path: path, name: name);
      if (uploadResult[0] == "Error") {
        return showCupertinoAlertDialog(
            context: context, title: "上传失败!", content: "请先配置上传参数.");
      } else if (uploadResult[0] == "success") {
        successCount++;
        successList.add(name);
        Map<String, dynamic> maps = {};
        if (Global.defaultPShost == 'sm.ms') {
          maps = {
            'path': path,
            'name': name,
            'url': uploadResult[2],
            'PBhost': Global.defaultPShost,
            'pictureKey': uploadResult[3],
            'hostSpecificArgA': 'test',
            'hostSpecificArgB': 'test',
            'hostSpecificArgC': 'test',
            'hostSpecificArgD': 'test',
            'hostSpecificArgE': 'test',
          };
        } else if (Global.defaultPShost == 'lsky.pro') {
          //["success", formatedURL, returnUrl, pictureKey, displayUrl]
          maps = {
            'path': path,
            'name': name,
            'url': uploadResult[2], //原图地址
            'PBhost': Global.defaultPShost,
            'pictureKey': uploadResult[3],
            'hostSpecificArgA': uploadResult[4], //实际展示的是缩略图
            'hostSpecificArgB': 'test',
            'hostSpecificArgC': 'test',
            'hostSpecificArgD': 'test',
            'hostSpecificArgE': 'test',
          };
        } else if (Global.defaultPShost == 'github') {
          maps = {
            'path': path,
            'name': name,
            'url': uploadResult[2],
            'PBhost': Global.defaultPShost,
            'pictureKey': uploadResult[3],
            'hostSpecificArgA': uploadResult[4], //github download url或者自定义域名+路径
            'hostSpecificArgB': 'test',
            'hostSpecificArgC': 'test',
            'hostSpecificArgD': 'test',
            'hostSpecificArgE': 'test',
          };
        } else if (Global.defaultPShost == 'imgur') {
          // ["success", formatedURL, returnUrl, pictureKey,cdnUrl]
          maps = {
            'path': path,
            'name': name,
            'url': uploadResult[2], //imgur文件原始地址
            'PBhost': Global.defaultPShost,
            'pictureKey': uploadResult[3],
            'hostSpecificArgA': uploadResult[4], //实际展示的是imgur cdn url
            'hostSpecificArgB': 'test',
            'hostSpecificArgC': 'test',
            'hostSpecificArgD': 'test',
            'hostSpecificArgE': 'test',
          };
        } else if (Global.defaultPShost == 'qiniu') {
          // ["success", formatedURL, returnUrl, pictureKey,displayUrl]
          maps = {
            'path': path,
            'name': name,
            'url': uploadResult[2], //qiniu文件原始地址
            'PBhost': Global.defaultPShost,
            'pictureKey': uploadResult[3],
            'hostSpecificArgA': uploadResult[4], //实际展示的是displayUrl
            'hostSpecificArgB': 'test',
            'hostSpecificArgC': 'test',
            'hostSpecificArgD': 'test',
            'hostSpecificArgE': 'test',
          };
        } else if (Global.defaultPShost == 'tencent') {
          // ["success", formatedURL, returnUrl, pictureKey,displayUrl]
          maps = {
            'path': path,
            'name': name,
            'url': uploadResult[2], //tencent文件原始地址
            'PBhost': Global.defaultPShost,
            'pictureKey': uploadResult[3],
            'hostSpecificArgA': uploadResult[4], //实际展示的是displayUrl
            'hostSpecificArgB': 'test',
            'hostSpecificArgC': 'test',
            'hostSpecificArgD': 'test',
            'hostSpecificArgE': 'test',
          };
        } else if (Global.defaultPShost == 'aliyun') {
          // ["success", formatedURL, returnUrl, pictureKey,displayUrl]
          maps = {
            'path': path,
            'name': name,
            'url': uploadResult[2], //aliyun文件原始地址
            'PBhost': Global.defaultPShost,
            'pictureKey': uploadResult[3],
            'hostSpecificArgA': uploadResult[4], //实际展示的是displayUrl
            'hostSpecificArgB': 'test',
            'hostSpecificArgC': 'test',
            'hostSpecificArgD': 'test',
            'hostSpecificArgE': 'test',
          };
        } else if (Global.defaultPShost == 'upyun') {
          // ["success", formatedURL, returnUrl, pictureKey,displayUrl]
          maps = {
            'path': path,
            'name': name,
            'url': uploadResult[2], //upyun文件原始地址
            'PBhost': Global.defaultPShost,
            'pictureKey': uploadResult[3],
            'hostSpecificArgA': uploadResult[4], //实际展示的是displayUrl
            'hostSpecificArgB': 'test',
            'hostSpecificArgC': 'test',
            'hostSpecificArgD': 'test',
            'hostSpecificArgE': 'test',
          };
        }

        await AlbumSQL.insertData(
            Global.imageDB!, pBhostToTableName[Global.defaultPShost]!, maps);

        clipboardList.add(uploadResult[1]);
      } else if (uploadResult[0] == "failed") {
        failCount++;
        failList.add(name);
      } else {
        failCount++;
        failList.add(name);
      }
    }

    setState(() {
      uploadList.clear();
      Global.imagesList.clear();
      Global.imageFile = null;
    });

    if (successCount == 0) {
      String content = "哭唧唧，全部上传失败了=_=\n\n上传失败的图片列表:\n\n";
      for (String failImage in failList) {
        content += "$failImage\n";
      }
      return showCupertinoAlertDialog(
          barrierDismissible: true,
          context: context,
          title: "上传失败!",
          content: content);
    } else if (failCount == 0) {
      eventBus.fire(AlbumRefreshEvent(albumKeepAlive: false));
      if (Global.isCopyLink == true) {
        await flutter_services.Clipboard.setData(flutter_services.ClipboardData(
            text: clipboardList
                .toString()
                .substring(1, clipboardList.toString().length - 1)));
        clipboardList.clear();
      }
      String content = "哇塞，全部上传成功了！\n上传成功的图片列表:\n";
      for (String successImage in successList) {
        content += "$successImage\n";
      }
      if (successList.length == 1) {
        return Fluttertoast.showToast(msg: '上传成功');
      } else {
        return showCupertinoAlertDialog(
            barrierDismissible: true,
            context: context,
            title: "上传成功!",
            content: content);
      }
    } else {
      eventBus.fire(AlbumRefreshEvent(albumKeepAlive: false));
      if (Global.isCopyLink == true) {
        await flutter_services.Clipboard.setData(flutter_services.ClipboardData(
            text: clipboardList
                .toString()
                .substring(1, clipboardList.toString().length - 1)
                .replaceAll(',', '\n')));
        clipboardList.clear();
      }

      String content = "部分上传成功~\n\n上传成功的图片列表:\n\n";
      for (String successImage in successList) {
        content += "$successImage\n";
      }
      content += "上传失败的图片列表:\n\n";
      for (String failImage in failList) {
        content += "$failImage\n";
      }
      return showCupertinoAlertDialog(
          barrierDismissible: true,
          context: context,
          title: "上传完成!",
          content: content);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
          ),
          shadowColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(
                Icons.cleaning_services_sharp,
                color: Colors.white,
                size: 30,
              ),
              onPressed: () {
                uploadList.clear();
                setState(() {
                  Global.imagesList.clear();
                  Global.imageFile = null;
                });
              },
            ),
          ],
          title: const Text('PicHoro',
              style: TextStyle(
                fontSize: 22.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              )),
        ),
        body: uploadList.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/empty.png',
                      width: 150,
                      height: 150,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Text('空空如也哦 点击下方按钮上传',
                        style: TextStyle(
                            fontSize: 20,
                            color: Color.fromARGB(136, 121, 118, 118)))
                  ],
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  children: _createUploadListItem(),
                ),
              ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton:
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          SizedBox(
              height: 40,
              width: 40,
              child: FloatingActionButton(
                heroTag: 'camera',
                backgroundColor: const Color.fromARGB(255, 180, 236, 182),
                onPressed: () async {
                  await _imageFromCamera();
                  for (int i = 0; i < Global.imagesList.length; i++) {
                    uploadList.add(Global.imagesList[i].path);
                  }
                  if (uploadList.isNotEmpty) {
                    showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) {
                          return NetLoadingDialog(
                            outsideDismiss: false,
                            loading: true,
                            loadingText: "上传中...",
                            requestCallBack: _upLoadImage(),
                          );
                        });
                  }
                },
                child: const Icon(
                  Icons.camera_alt_outlined,
                  size: 30,
                ),
              )),
          const SizedBox(width: 10),
          SizedBox(
              height: 40,
              width: 40,
              child: FloatingActionButton(
                heroTag: 'picture',
                backgroundColor: const Color.fromARGB(255, 112, 215, 247),
                onPressed: () async {
                  await _multiImagePickerFromGallery();
                  if (Global.imagesList.isNotEmpty) {
                    for (int i = 0; i < Global.imagesList.length; i++) {
                      uploadList.add(Global.imagesList[i].path);
                    }
                  }
                  setState(() {
                    Global.imagesList.clear();
                    Global.imageFile = null;
                  });
                },
                child: const Icon(
                  Icons.image_outlined,
                  size: 30,
                ),
              )),
          const SizedBox(width: 10),
          SizedBox(
              height: 40,
              width: 40,
              child: FloatingActionButton(
                heroTag: 'multi',
                backgroundColor: const Color.fromARGB(255, 237, 201, 241),
                onPressed: () {
                  _cameraAndBack();
                },
                child: const Icon(
                  Icons.camera,
                  size: 30,
                ),
              )),
          const SizedBox(width: 10),
          SizedBox(
              height: 40,
              width: 40,
              child: FloatingActionButton(
                heroTag: 'network',
                backgroundColor: const Color.fromARGB(255, 248, 231, 136),
                onPressed: () async {
                  await _imageFromNetwork();
                  if (Global.imagesList.isNotEmpty) {
                    for (int i = 0; i < Global.imagesList.length; i++) {
                      uploadList.add(Global.imagesList[i].path);
                    }
                  }
                  setState(() {
                    Global.imagesList.clear();
                    Global.imageFile = null;
                  });
                },
                child: const Icon(
                  Icons.wifi,
                  size: 30,
                ),
              )),
          const SizedBox(width: 10),
          SpeedDial(
            renderOverlay: true,
            overlayOpacity: 0.5,
            buttonSize: const Size(41, 41),
            childrenButtonSize: const Size(40, 40),
            animatedIcon: AnimatedIcons.menu_close,
            animatedIconTheme: const IconThemeData(size: 33.0),
            backgroundColor: Colors.blue,
            visible: true,
            curve: Curves.bounceIn,
            children: [
              SpeedDialChild(
                shape: const CircleBorder(),
                child: const Icon(
                  IconData(0x004C),
                  color: Colors.white,
                ),
                backgroundColor: Global.defaultPShost == 'lsky.pro'
                    ? Colors.amber
                    : const Color.fromARGB(255, 97, 180, 248),
                label: '兰空',
                labelStyle: const TextStyle(fontSize: 12.0),
                onTap: () async {
                  await setdefaultPShostRemoteAndLocal('lsky.pro');
                  eventBus.fire(AlbumRefreshEvent(albumKeepAlive: false));
                  setState(() {});
                },
              ),
              SpeedDialChild(
                shape: const CircleBorder(),
                child: const Icon(
                  IconData(0x0053),
                  color: Colors.white,
                ),
                backgroundColor: Global.defaultPShost == 'sm.ms'
                    ? Colors.amber
                    : const Color.fromARGB(255, 97, 180, 248),
                label: 'SM.MS',
                labelStyle: const TextStyle(fontSize: 12.0),
                onTap: () async {
                  await setdefaultPShostRemoteAndLocal('sm.ms');
                  eventBus.fire(AlbumRefreshEvent(albumKeepAlive: false));
                  setState(() {});
                },
              ),
              SpeedDialChild(
                shape: const CircleBorder(),
                child: const Icon(
                  IconData(0x0047),
                  color: Colors.white,
                ),
                backgroundColor: Global.defaultPShost == 'github'
                    ? Colors.amber
                    : const Color.fromARGB(255, 97, 180, 248),
                label: 'Github',
                labelStyle: const TextStyle(fontSize: 12.0),
                onTap: () async {
                  await setdefaultPShostRemoteAndLocal('github');
                  eventBus.fire(AlbumRefreshEvent(albumKeepAlive: false));
                  setState(() {});
                },
              ),
              SpeedDialChild(
                shape: const CircleBorder(),
                child: const Icon(
                  IconData(0x0049),
                  color: Colors.white,
                ),
                backgroundColor: Global.defaultPShost == 'imgur'
                    ? Colors.amber
                    : const Color.fromARGB(255, 97, 180, 248),
                label: 'Imgur',
                labelStyle: const TextStyle(fontSize: 12.0),
                onTap: () async {
                  await setdefaultPShostRemoteAndLocal('imgur');
                  eventBus.fire(AlbumRefreshEvent(albumKeepAlive: false));
                  setState(() {});
                },
              ),
              SpeedDialChild(
                shape: const CircleBorder(),
                child: const Icon(
                  IconData(0x0051),
                  color: Colors.white,
                ),
                backgroundColor: Global.defaultPShost == 'qiniu'
                    ? Colors.amber
                    : const Color.fromARGB(255, 97, 180, 248),
                label: '七牛',
                labelStyle: const TextStyle(fontSize: 12.0),
                onTap: () async {
                  await setdefaultPShostRemoteAndLocal('qiniu');
                  eventBus.fire(AlbumRefreshEvent(albumKeepAlive: false));
                  setState(() {});
                },
              ),
              SpeedDialChild(
                shape: const CircleBorder(),
                child: const Icon(
                  IconData(0x0054),
                  color: Colors.white,
                ),
                backgroundColor: Global.defaultPShost == 'tencent'
                    ? Colors.amber
                    : const Color.fromARGB(255, 97, 180, 248),
                label: '腾讯',
                labelStyle: const TextStyle(fontSize: 12.0),
                onTap: () async {
                  await setdefaultPShostRemoteAndLocal('tencent');
                  eventBus.fire(AlbumRefreshEvent(albumKeepAlive: false));
                  setState(() {});
                },
              ),
              SpeedDialChild(
                shape: const CircleBorder(),
                child: const Icon(
                  IconData(0x0041),
                  color: Colors.white,
                ),
                backgroundColor: Global.defaultPShost == 'aliyun'
                    ? Colors.amber
                    : const Color.fromARGB(255, 97, 180, 248),
                label: '阿里',
                labelStyle: const TextStyle(fontSize: 12.0),
                onTap: () async {
                  await setdefaultPShostRemoteAndLocal('aliyun');
                  eventBus.fire(AlbumRefreshEvent(albumKeepAlive: false));
                  setState(() {});
                },
              ),
              SpeedDialChild(
                shape: const CircleBorder(),
                child: const Icon(
                  IconData(0x0055),
                  color: Colors.white,
                ),
                backgroundColor: Global.defaultPShost == 'upyun'
                    ? Colors.amber
                    : const Color.fromARGB(255, 97, 180, 248),
                label: '又拍',
                labelStyle: const TextStyle(fontSize: 12.0),
                onTap: () async {
                  await setdefaultPShostRemoteAndLocal('upyun');
                  eventBus.fire(AlbumRefreshEvent(albumKeepAlive: false));
                  setState(() {});
                },
              ),
            ],
          ),
        ]));
  }
}

class ListItem extends StatefulWidget {
  Function(String) onUploadPlayPausedPressed;
  Function(String) onDelete;
  UploadTask? uploadTask;
  String path;
  ListItem(
      {Key? key,
      required this.onUploadPlayPausedPressed,
      required this.onDelete,
      required this.path,
      this.uploadTask})
      : super(key: key);

  @override
  ListItemState createState() => ListItemState();
}

class ListItemState extends State<ListItem> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(1.0),
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(
              color: const Color.fromARGB(255, 203, 237, 253),
            ),
            borderRadius: const BorderRadius.all(Radius.circular(20))),
        padding: const EdgeInsets.all(1.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image(
                    image: FileImage(io.File(widget.path)),
                    width: 30,
                    height: 30,
                    fit: BoxFit.cover),
                Expanded(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '文件名:${widget.path.split('/').last}',
                    ),
                    if (widget.uploadTask != null)
                      ValueListenableBuilder(
                          valueListenable: widget.uploadTask!.status,
                          builder: (context, value, child) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                  "状态: ${uploadStatus[value.toString()]}",
                                  style: const TextStyle(fontSize: 14)),
                            );
                          }),
                  ],
                )),
                widget.uploadTask != null
                    ? ValueListenableBuilder(
                        valueListenable: widget.uploadTask!.status,
                        builder: (context, value, child) {
                          switch (widget.uploadTask!.status.value) {
                            case UploadStatus.uploading:
                              return IconButton(
                                  onPressed: () async {
                                    await widget
                                        .onUploadPlayPausedPressed(widget.path);
                                  },
                                  icon: const Icon(
                                    Icons.pause,
                                    color: Colors.blue,
                                  ));
                            case UploadStatus.paused:
                              return IconButton(
                                onPressed: () async {
                                  await widget
                                      .onUploadPlayPausedPressed(widget.path);
                                },
                                icon: const Icon(Icons.play_arrow),
                                color: Colors.blue,
                              );
                            case UploadStatus.completed:
                              return IconButton(
                                  onPressed: () {
                                    widget.onDelete(widget.path);
                                  },
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ));
                            case UploadStatus.failed:
                            case UploadStatus.canceled:
                              return IconButton(
                                  onPressed: () async {
                                    await widget
                                        .onUploadPlayPausedPressed(widget.path);
                                  },
                                  icon: const Icon(
                                    Icons.cloud_upload_outlined,
                                    color: Colors.blue,
                                  ));
                          }
                          return Text("${uploadStatus[value.toString()]}",
                              style: const TextStyle(fontSize: 16));
                        })
                    : IconButton(
                        onPressed: () async {
                          await widget.onUploadPlayPausedPressed(widget.path);
                        },
                        icon: const Icon(
                          Icons.cloud_upload_outlined,
                          color: Colors.green,
                        ))
              ],
            ),
            if (widget.uploadTask != null &&
                !widget.uploadTask!.status.value.isCompleted)
              ValueListenableBuilder(
                  valueListenable: widget.uploadTask!.progress,
                  builder: (context, value, child) {
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: LinearProgressIndicator(
                        value: value,
                        color: widget.uploadTask!.status.value ==
                                UploadStatus.paused
                            ? Colors.grey
                            : Colors.amber,
                      ),
                    );
                  }),
            if (widget.uploadTask != null)
              FutureBuilder<UploadStatus>(
                  future: widget.uploadTask!.whenUploadComplete(),
                  builder: (BuildContext context,
                      AsyncSnapshot<UploadStatus> snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                        return const Text('请等待上传完成');
                      default:
                        if (snapshot.hasError) {
                          return Text('错误: ${snapshot.error}');
                        } else {
                          return Text(
                              '结果: ${uploadStatus[snapshot.data.toString()]}');
                        }
                    }
                  })
          ],
        ),
      ),
    );
  }
}
