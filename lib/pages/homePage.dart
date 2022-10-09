import 'dart:io' as io;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:horopic/utils/common_func.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:horopic/pages/configurePage.dart';
import 'package:horopic/pages/loading.dart';
import 'package:horopic/utils/global.dart';
import 'package:horopic/utils/uploader.dart';
import 'package:flutter/services.dart' as flutterServices;
import 'package:horopic/album/albumSQL.dart';
import 'package:horopic/album/albumPage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ImagePicker _picker = ImagePicker();
  List clipbordList = [];

  _imageFromCamera() async {
    final XFile? pickedImage =
        await _picker.pickImage(source: ImageSource.camera, imageQuality: 100);
    //Database imageDB = await AlbumSQL.getDatabase();
    //await AlbumSQL.EmptyAllTable(imageDB);
    if (pickedImage == null) {
      Fluttertoast.showToast(
          msg: "未拍摄图片",
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 2,
          backgroundColor: Theme.of(context).brightness == Brightness.light
              ? Colors.black
              : Colors.white,
          textColor: Theme.of(context).brightness == Brightness.light
              ? Colors.white
              : Colors.black,
          fontSize: 16.0);
      return;
    }
    final io.File fileImage = io.File(pickedImage.path);
    Global.imagesList.clear();
    if (imageConstraint(context: context, image: fileImage)) {
      //图片重命名
      if (Global.isTimeStamp == true) {
        Global.imageFile = await renamePictureWithTimestamp(fileImage);
      } else if (Global.isRandomName == true) {
        Global.imageFile = await renamePictureWithRandomString(fileImage);
      } else {
        Global.imageFile = fileImage;
      }
      setState(() {
        //Global.imageFile = fileImage;
        Global.imagesList.add(Global.imageFile!);
      });
    }
  }

  _cameraAndBack() async {
    XFile? pickedImage =
        await _picker.pickImage(source: ImageSource.camera, imageQuality: 100);
    if (pickedImage == null) {
      if (Global.isCopyLink == true) {
        await flutterServices.Clipboard.setData(
            flutterServices.ClipboardData(text: clipbordList.toString()));
        clipbordList.clear();
      }
      return Fluttertoast.showToast(
          msg: "未选择图片",
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 2,
          backgroundColor: Theme.of(context).brightness == Brightness.light
              ? Colors.black
              : Colors.white,
          textColor: Theme.of(context).brightness == Brightness.light
              ? Colors.white
              : Colors.black,
          fontSize: 16.0);
    }

    io.File fileImage = io.File(pickedImage.path);

    if (Global.isTimeStamp == true) {
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
        await flutterServices.Clipboard.setData(
            flutterServices.ClipboardData(text: clipbordList.toString()));
        clipbordList.clear();
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
      return showAlertDialog(
          context: context, title: "上传失败!", content: "请先配置上传参数.");
    } else if (uploadResult[0] == "success") {
      Map<String, dynamic> maps = {
        'path': path,
        'name': name,
        'url': uploadResult[2],
        'PBhost': Global.defaultPShost,
        'pictureKey': uploadResult[3],
        'hostSpecificArgA': 'test',
        'hostSpecificArgB': 'test',
      };
      int id = await AlbumSQL.insertData(
          Global.imageDB!, PBhostToTableName[Global.defaultPShost]!, maps);
      clipbordList.add(uploadResult[1]);
      Global.multiUpload = 'success';
      return true;
    } else if (uploadResult[0] == "failed") {
      Global.multiUpload = 'fail';
      return showAlertDialog(
          context: context, title: "上传失败!", content: "上传参数有误.");
    } else {
      Global.multiUpload = 'fail';
      return showAlertDialog(
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
      Fluttertoast.showToast(
          msg: "未选择任何图片",
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 2,
          backgroundColor: Theme.of(context).brightness == Brightness.light
              ? Colors.black
              : Colors.white,
          textColor: Theme.of(context).brightness == Brightness.light
              ? Colors.white
              : Colors.black,
          fontSize: 16.0);
      return;
    }

    for (var i = 0; i < pickedImage.length; i++) {
      io.File? fileImage = await pickedImage[i].originFile;

      if (imageConstraint(context: context, image: fileImage!)) {
        if (Global.isTimeStamp == true) {
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
    clipbordList.clear();
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
        return showAlertDialog(
            context: context, title: "上传失败!", content: "请先配置上传参数.");
      } else if (uploadResult[0] == "success") {
        successCount++;
        successList.add(name);

        Map<String, dynamic> maps = {
          'path': path,
          'name': name,
          'url': uploadResult[2],
          'PBhost': Global.defaultPShost,
          'pictureKey': uploadResult[3],
          'hostSpecificArgA': 'test',
          'hostSpecificArgB': 'test',
        };
        int id = await AlbumSQL.insertData(
            Global.imageDB!, PBhostToTableName[Global.defaultPShost]!, maps);

        clipbordList.add(uploadResult[1]);
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
      return showAlertDialog(
          barrierDismissible: true,
          context: context,
          title: "上传失败!",
          content: content);
    } else if (failCount == 0) {
      if (Global.isCopyLink == true) {
        await flutterServices.Clipboard.setData(
            flutterServices.ClipboardData(text: clipbordList.toString()));
        clipbordList.clear();
      }
      String content = "哇塞，全部上传成功了！\n\n上传成功的图片列表:\n\n";
      for (String successImage in successList) {
        content += "$successImage\n";
      }
      if (successList.length == 1) {
        return Fluttertoast.showToast(
            backgroundColor: Theme.of(context).brightness == Brightness.light
                ? Colors.black
                : Colors.white,
            textColor: Theme.of(context).brightness == Brightness.light
                ? Colors.white
                : Colors.black,
            msg: '上传成功');
      } else {
        return showAlertDialog(
            barrierDismissible: true,
            context: context,
            title: "上传成功!",
            content: content);
      }
    } else {
      if (Global.isCopyLink == true) {
        await flutterServices.Clipboard.setData(flutterServices.ClipboardData(
            text: clipbordList
                .toString()
                .substring(1, clipbordList.toString().length - 1)
                .replaceAll(',', '\n')));
        clipbordList.clear();
      }

      String content = "部分上传成功~\n\n上传成功的图片列表:\n\n";
      for (String successImage in successList) {
        content += "$successImage\n";
      }
      content += "上传失败的图片列表:\n\n";
      for (String failImage in failList) {
        content += "$failImage\n";
      }
      return showAlertDialog(
          barrierDismissible: true,
          context: context,
          title: "上传完成!",
          content: content);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/background.png"), //丑，有好看的背景了再改
                fit: BoxFit.cover)),
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            //backgroundColor: Colors.transparent,
            //elevation: 0,
            centerTitle: true,
            title: const Text('PicHoro',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25.0,
                  fontWeight: FontWeight.bold,
                )),
          ),
          //
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
                                        image:
                                            AssetImage('assets/app_icon.png'))
                                    .image,
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            if (Global.imagesList.isEmpty) {
                              Fluttertoast.showToast(
                                  backgroundColor:
                                      Theme.of(context).brightness ==
                                              Brightness.light
                                          ? Colors.black
                                          : Colors.white,
                                  textColor: Theme.of(context).brightness ==
                                          Brightness.light
                                      ? Colors.white
                                      : Colors.black,
                                  msg: '请先选择图片');
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
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        const SizedBox(
                          height: 20,
                        ),
                        Container(
                          child: Container(
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
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        Container(
                          child: Container(
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
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        const SizedBox(
                          height: 20,
                        ),
                        Container(
                          child: Container(
                            alignment: FractionalOffset.center,
                            margin: const EdgeInsets.only(
                              left: 20,
                              right: 20,
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                //backgroundColor: Colors.yellow[300],
                                minimumSize: const Size(20, 100),
                              ),
                              onPressed: _cameraAndBack,
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Icon(Icons.backup),
                                    Text(
                                      '  连续上传',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          // This trailing comma makes auto-formatting nicer for build methods.
          //switch wthin upload and hostconfig
          bottomNavigationBar: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.file_upload),
                label: '上传',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.photo_outlined),
                label: '相册',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: '设置',
              ),
            ],
            currentIndex: 0,
            //selectedItemColor: Colors.cyan[600],
            onTap: (int index) {
              if (index == 1) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UploadedImages()),
                );
              } else if (index == 2) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ConfigurePage()),
                );
              }
            },
          ),

          //,
        ));
  }
}
