import 'dart:io' as io;

import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:flutter/services.dart' as flutter_services;
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:http/http.dart' as my_http;
import 'package:path_provider/path_provider.dart';

import 'package:horopic/album/album_sql.dart';
import 'package:horopic/pages/loading.dart';
import 'package:horopic/picture_host_configure/default_picture_host_select.dart';

import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/utils/global.dart';
import 'package:horopic/utils/uploader.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin<HomePage> {
  final ImagePicker _picker = ImagePicker();
  List clipboardList = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    super.dispose();
    clipboardList.clear();
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
      setState(() {
        Global.imagesList.add(Global.imageFile!);
      });
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
          setState(() {});
        } catch (e) {
          failCount++;
          continue;
        }
      }
      if (successCount > 0) {
        showToast('成功$successCount张,失败$failCount张');
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
        setState(() {
          Global.imagesList.add(Global.imageFile!);
        });
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
        elevation: 0,
        title: const Text('PicHoro',
            style: TextStyle(
              fontSize: 25.0,
              fontWeight: FontWeight.bold,
            )),
      ),
      body: Column(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        bottomPickerSheet(context, _imageFromCamera,
                            _multiImagePickerFromGallery);
                      },
                      child: CircleAvatar(
                        radius: MediaQuery.of(context).size.width / 6,
                        backgroundColor: Colors.grey,
                        backgroundImage: Global.imageFile != null
                            ? FileImage(Global.imageFile!)
                            : const Image(
                                    image: AssetImage('assets/app_icon.png'))
                                .image,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (Global.imagesList.isEmpty) {
                          showToastWithContext(context, '请先选择图片');
                          return;
                        } else {
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
                      }, // Upload Image
                      child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.file_upload),
                            Text(
                              '上传图片',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    alignment: FractionalOffset.center,
                    margin: const EdgeInsets.only(left: 20, right: 20),
                    child: ElevatedButton(
                      onPressed: _imageFromCamera,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.camera_alt),
                            Text(
                              '单张拍照',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    alignment: FractionalOffset.center,
                    margin: const EdgeInsets.only(
                      left: 20,
                      right: 20,
                    ),
                    child: ElevatedButton(
                      onPressed: _multiImagePickerFromGallery,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.photo_library),
                            Text(
                              '相册多选',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    alignment: FractionalOffset.center,
                    margin: const EdgeInsets.only(left: 20, right: 20),
                    child: ElevatedButton(
                      onPressed: _cameraAndBack,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.backup),
                            Text(
                              '连续上传',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    alignment: FractionalOffset.center,
                    margin: const EdgeInsets.only(left: 20, right: 20),
                    child: ElevatedButton(
                      onPressed: _imageFromNetwork,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.wifi),
                            Text(
                              '网络多选',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: SpeedDial(
        renderOverlay: true,
        overlayOpacity: 0.5,
        buttonSize: const Size(45, 45),
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
              setState(() {});
            },
          ),
        ],
      ),
    );
  }
}
