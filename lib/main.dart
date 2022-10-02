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
      showAlertDialog(
          context: context,
          title: "Error Uploading!",
          content: "No Image was selected.");
      return;
    }
    final File fileImage = File(pickedImage.path);

    if (imageConstraint(fileImage)) {
      setState(() {
        _image = fileImage;
      });
    }
  }

  _imageFromGallery() async {
    final XFile? pickedImage =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 100);
    if (pickedImage == null) {
      showAlertDialog(
          context: context,
          title: "Error Uploading!",
          content: "No Image was selected.");
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
    if (!['bmp', 'jpg', 'jpeg']
        .contains(image.path.split('.').last.toString())) {
      showAlertDialog(
          context: context,
          title: "Error Uploading!",
          content: "Image format should be jpg/jpeg/bmp.");
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
      showAlertDialog(
          context: context,
          title: "Error Uploading!",
          content: "No Image was selected.");
      return;
    }
    String path = _image!.path;
    var name = path.substring(path.lastIndexOf("/") + 1, path.length);
    var config_data = await readHostConfig();
    if (config_data == "Error") {
      showAlertDialog(
          context: context,
          title: "Error Uploading!",
          content: "No host_config.txt found.");
      return;
    }

    Map configMap = jsonDecode(config_data);

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
    var respone = await dio.post<String>(
        uploadUrl,
        data: formdata);
    if (respone.statusCode == 200) {
      Fluttertoast.showToast(
          msg: "图片上传成功", gravity: ToastGravity.CENTER, textColor: Colors.grey);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('赫萝图片上传工具'),
      ),
      body: Center(
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
                              : const Image(image: AssetImage('assets/favicon.jpg'))
                                  .image,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      ElevatedButton(
                        onPressed: _upLoadImage, // Upload Image
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
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
                      Expanded(
                        child: Container(
                          alignment: FractionalOffset.center,
                          margin: const EdgeInsets.only(left: 20, right: 20),
                      child: ElevatedButton(
                        onPressed: _imageFromCamera,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.camera_alt),
                              Text(
                                '拍照',
                              ),
                            ],
                          ),
                        ),
                      ),
                        ),
                      ),
                      Expanded(
                        child: Container(  
                          alignment: FractionalOffset.center,
                         margin: const EdgeInsets.only(left: 20, right: 20,bottom: 50),
                          child: ElevatedButton(
                            onPressed: _imageFromGallery,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.photo_library),
                                  Text(
                                    '相册',
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ), 
                      ),
                    ],
                  ),
                ),
        ),
      ),
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
        selectedItemColor: Colors.amber[800],
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
