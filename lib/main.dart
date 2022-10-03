import 'dart:io';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:horopic/AlertDialog.dart';
import 'package:horopic/bottompicker_sheet.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:horopic/hostconfig.dart';
import 'package:path_provider/path_provider.dart';
//import 'package:permission_handler/permission_handler.dart';
import 'package:horopic/utils/permission.dart';

/*
@Author: Horo
@e-mail: ma_shiqing@163.com
@Date: 2022-10-02
@Description:HoroPic, a picture upload tool 
@version: 1.0.0
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
      theme: ThemeData(primarySwatch: Colors.cyan),
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
  bool uploadStatus = false;

  _imageFromCamera() async {
    final XFile? pickedImage =
        await _picker.pickImage(source: ImageSource.camera, imageQuality: 100);
    if (pickedImage == null) {
      showAlertDialog(context: context, title: "上传失败!", content: "请重新选择图片.");
      return;
    }
    final File fileImage = File(pickedImage.path);

    if (imageConstraint(fileImage)) {
      setState(() {
        _image = fileImage;
      });
    }
  }

  _cameraAndBack() async {
    final XFile? pickedImage =
        await _picker.pickImage(source: ImageSource.camera, imageQuality: 100);
    if (pickedImage == null) {
      showAlertDialog(context: context, title: "上传失败!", content: "请重新选择图片.");
      return;
    }
    final File fileImage = File(pickedImage.path);
    if (imageConstraint(fileImage)) {
      setState(() {
        _image = fileImage;
        _uploadAndBackToCamera();
      });
    }
  }

  _uploadAndBackToCamera() async {
    if (_image == null) {
      showAlertDialog(context: context, title: "上传失败!", content: "请先选择图片.");
      return;
    }
    String path = _image!.path;
    var name = path.substring(path.lastIndexOf("/") + 1, path.length);
    var configData = await readHostConfig();
    if (configData == "Error") {
      showAlertDialog(context: context, title: "上传失败!", content: "请先配置上传参数.");
      return;
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
    var respone = await dio.post<String>(uploadUrl, data: formdata);
    _cameraAndBack();
  }

  _imageFromGallery() async {
    final XFile? pickedImage =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 100);
    if (pickedImage == null) {
      showAlertDialog(context: context, title: "上传失败!", content: "请重新选择图片.");
      return;
    }
    final File fileImage = File(pickedImage.path);
    if (imageConstraint(fileImage)) {
      setState(() {
        _image = fileImage;
      });
    }
  }

  bool imageConstraint(File image) {
    if (!['bmp', 'jpg', 'jpeg', 'png', 'gif', 'webp']
        .contains(image.path.split('.').last.toString())) {
      showAlertDialog(
          context: context,
          title: "上传失败!",
          content: "图片格式因该为bmp,jpg,jpeg,png,gif,webp.");
      return false;
    }
    return true;
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
    if (_image == null) {
      showAlertDialog(context: context, title: "上传失败!", content: "请先选择图片.");
      return;
    }
    String path = _image!.path;
    var name = path.substring(path.lastIndexOf("/") + 1, path.length);
    var configData = await readHostConfig();
    if (configData == "Error") {
      showAlertDialog(context: context, title: "上传失败!", content: "请先配置上传参数.");
      return;
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
    var response = await dio.post(uploadUrl, data: formdata);
    if (response.statusCode == 200 && response.data!['status'] == true) {
      _image = null;
      Fluttertoast.showToast(
          msg: "图片上传成功", gravity: ToastGravity.CENTER, textColor: Colors.grey);
    } else {
      if (response.data['status'] == false) {
        showAlertDialog(
            context: context, title: '错误', content: response.data['message']);
        return;
      } else if (response.statusCode == 403) {
        showAlertDialog(context: context, title: '错误', content: '管理员关闭了接口功能');
        return;
      } else if (response.statusCode == 401) {
        showAlertDialog(context: context, title: '错误', content: '授权失败');
        return;
      } else if (response.statusCode == 500) {
        showAlertDialog(context: context, title: '错误', content: '服务器异常');
        return;
      } else if (response.statusCode == 404) {
        showAlertDialog(context: context, title: '错误', content: '接口不存在');
        return;
      }
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
              // Display Progress Indicator if uploadStatus is true
              child: uploadStatus
                  ? Container(
                      height: 100,
                      width: 100,
                      child: const CircularProgressIndicator(
                        strokeWidth: 7,
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              bottomPickerSheet(
                                  context, _imageFromCamera, _imageFromGallery);
                            },
                            child: CircleAvatar(
                              radius: MediaQuery.of(context).size.width / 6,
                              backgroundColor: Colors.grey,
                              backgroundImage: _image != null
                                  ? FileImage(_image!)
                                  : const Image(
                                          image:
                                              AssetImage('assets/favicon.jpg'))
                                      .image,
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          ElevatedButton(
                            onPressed: _upLoadImage, // Upload Image
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
                                  '单次拍照',
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
                          onPressed: _imageFromGallery,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.photo_library),
                                Text(
                                  '相册上传',
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
                            backgroundColor: Colors.yellow[300],
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
            label: '上传界面',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: '配置',
          ),
        ],
        currentIndex: 0,
        selectedItemColor: Colors.cyan[600],
        onTap: (int index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HostConfig()),
            );
          }
        },
      ),

      //,
    );
  }
}
