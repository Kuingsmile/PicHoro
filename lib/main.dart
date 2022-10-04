import 'dart:io';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:horopic/AlertDialog.dart';
import 'package:horopic/bottompicker_sheet.dart';
import 'package:fluttertoast/fluttertoast.dart';
//import 'package:horopic/hostconfig.dart';
import 'package:path_provider/path_provider.dart';
//import 'package:permission_handler/permission_handler.dart';
import 'package:horopic/utils/permission.dart';
import 'package:horopic/utils/common_func.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
//import 'package:camera/camera.dart';
import 'package:horopic/configurePage.dart';
import 'package:horopic/pages/themeSet.dart';
import 'package:horopic/pages/loading.dart';
/*
@Author: Horo
@e-mail: ma_shiqing@163.com
@Date: 2022-10-04
@Description:HoroPic, a picture upload tool 
@version: 1.2.1
*/

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '赫萝图床上传工具',
      debugShowCheckedModeBanner: false,
      theme: lightThemeData,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ImagePicker _picker = ImagePicker();
  File? _image;
  List<File> _imagesList = [];

  _imageFromCamera() async {
    final XFile? pickedImage =
        await _picker.pickImage(source: ImageSource.camera, imageQuality: 100);
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
    final File fileImage = File(pickedImage.path);
    _imagesList.clear();
    if (imageConstraint(context: context, image: fileImage)) {
      setState(() {
        _image = fileImage;
        _imagesList.add(_image!);
      });
    }
  }

  _cameraAndBack() async {
    final XFile? pickedImage =
        await _picker.pickImage(source: ImageSource.camera, imageQuality: 100);
    if (pickedImage == null) {
      Fluttertoast.showToast(
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
      return;
    }
    final File fileImage = File(pickedImage.path);
    if (imageConstraint(context: context, image: fileImage)) {
      _image = fileImage;
      //setState(//() {
      //_uploadAndBackToCamera();
      if (_image == null) {
        Fluttertoast.showToast(
            backgroundColor: Theme.of(context).brightness == Brightness.light
                ? Colors.black
                : Colors.white,
            textColor: Theme.of(context).brightness == Brightness.light
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
                requestCallBack: _uploadAndBackToCamera(),
              );
            });
      }
    }
    _cameraAndBack();
  }

  _uploadAndBackToCamera() async {
    if (_image == null) {
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
    String path = _image!.path;
    var name = path.substring(path.lastIndexOf("/") + 1, path.length);
    var configData = await readHostConfig();
    if (configData == "Error") {
      return showAlertDialog(
          context: context, 
          title: "上传失败!",
           content: "请先配置上传参数.");
    }

    Map configMap = jsonDecode(configData);
    FormData formdata = FormData.fromMap({
      "file": await MultipartFile.fromFile(path, filename: name),
      "strategy_id": configMap["strategy_id"],
    });

    BaseOptions options = BaseOptions();
    options.headers = {
      "Authorization": configMap["token"],
      "Accept": "application/json",
      "Content-Type": "multipart/form-data",
    };
    Dio dio = Dio(options);
    String uploadUrl = configMap["host"] + "/api/v1/upload";
    var response = await dio.post<String>(uploadUrl, data: formdata);
    return true;
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
      final File? fileImage = await pickedImage[i].originFile;
      if (imageConstraint(context: context, image: fileImage!)) {
        setState(() {
          _imagesList.add(fileImage);
          if (i == 0) {
            _image = fileImage;
          }
        });
      }
    }
  }

//read from host_config.txt to get token,host,strategy_id
  Future<File> get _localFile async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/host_config.txt');
  }

  Future<String> readHostConfig() async {
    try {
      final file = await _localFile;
      String contents = await file.readAsString();
      return contents;
    } catch (e) {
      return "Error";
    }
  }

  _upLoadImage() async {
    var configData = await readHostConfig();
    if (configData == "Error") {
      return showAlertDialog(
          context: context, title: "上传失败!", content: "请先配置上传参数.");
    }
    Map configMap = jsonDecode(configData);
    BaseOptions options = BaseOptions();
    options.headers = {
      "Authorization": configMap["token"],
      "Accept": "application/json",
      "Content-Type": "multipart/form-data",
    };
    String uploadUrl = configMap["host"] + "/api/v1/upload";
    int successCount = 0;
    int failCount = 0;

    List<String> failList = [];
    List<String> successList = [];
    failList.clear();
    successList.clear();

    for (File imageToTread in _imagesList) {
      String path = imageToTread.path;
      var name = path.substring(path.lastIndexOf("/") + 1, path.length);
      FormData formdata = FormData.fromMap({
        "file": await MultipartFile.fromFile(path, filename: name),
        "strategy_id": configMap["strategy_id"],
      });

      Dio dio = Dio(options);
      var response = await dio.post(uploadUrl, data: formdata);
      if (response.statusCode == 200 && response.data!['status'] == true) {
        successCount += 1;
        successList.add(name);
      } else {
        failCount += 1;
        failList.add(name);
      }
    }
    _imagesList.clear();
    _image = null;

    if (successCount == 0) {
      String content = "哭唧唧，全部上传失败了=_=\n上传失败的图片列表:\n";
      for (String failImage in failList) {
        content += failImage + "\n";
      }
      return showAlertDialog(
          context: context, title: "上传失败!", content: content);
    } else if (failCount == 0) {
      String content = "哇塞，全部上传成功了！\n上传成功的图片列表:\n";
      for (String successImage in successList) {
        content += successImage + "\n";
      }
      return showAlertDialog(
          context: context, title: "上传成功!", content: content);
    } else {
      String content = "部分上传成功~\n上传成功的图片列表:\n";
      for (String successImage in successList) {
        content += successImage + "\n";
      }
      content += "上传失败的图片列表:\n";
      for (String failImage in failList) {
        content += failImage + "\n";
      }
      return showAlertDialog(
          context: context, title: "上传完成!", content: content);
    }
  }

  @override
  Widget build(BuildContext context) {
    Permissionutils.askPermission();
    Permissionutils.askPermissionCamera();
    Permissionutils.askPermissionGallery();
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('赫萝图片上传工具'),
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
                        backgroundImage: _image != null
                            ? FileImage(_image!)
                            : const Image(
                                    image: AssetImage('assets/favicon.jpg'))
                                .image,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (_imagesList.isEmpty) {
                          Fluttertoast.showToast(
                              backgroundColor: Theme.of(context).brightness ==
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
              MaterialPageRoute(builder: (context) => ConfigurePage()),
            );
          }
        },
      ),

      //,
    );
  }
}
