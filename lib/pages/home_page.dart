import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:image_picker/image_picker.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:flutter/services.dart' as flutter_services;
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:f_logs/f_logs.dart';
import 'package:http/http.dart' as my_http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as my_path;

import 'package:horopic/album/album_sql.dart';
import 'package:horopic/utils/event_bus_utils.dart';
import 'package:horopic/pages/loading.dart';
import 'package:horopic/picture_host_configure/default_picture_host_select.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/utils/global.dart';
import 'package:horopic/utils/uploader.dart';
import 'package:receive_intent/receive_intent.dart' as ic_intent;
import 'package:uri_to_file/uri_to_file.dart';

import 'package:horopic/pages/upload_pages/upload_task.dart';
import 'package:horopic/pages/upload_pages/upload_utils.dart';
import 'package:horopic/pages/upload_pages/upload_status.dart';

import 'package:horopic/utils/image_compress.dart';

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

class HomePageState extends State<HomePage> with AutomaticKeepAliveClientMixin<HomePage> {
  final ImagePicker _picker = ImagePicker();

  /// 剪贴板图片链接
  List clipboardList = [];

  /// 上传列表
  List uploadList = [];
  List<String> uploadPathList = [];
  List<String> uploadFileNameList = [];
  var uploadManager = UploadManager(maxConcurrentTasks: 1);
  ic_intent.Intent? _initialIntent;

  bool homepageKeepAlive = true;
  dynamic actionEventBus;

  @override
  bool get wantKeepAlive => homepageKeepAlive;

  @override
  void initState() {
    actionEventBus = eventBus.on<HomePhotoRefreshEvent>().listen(
      (event) {
        homepageKeepAlive = false;
        updateKeepAlive();
      },
    );
    super.initState();
    _initIntent();
    uploadManager = UploadManager(maxConcurrentTasks: 1);
  }

  Future<void> _initIntent() async {
    final receivedIntent = await ic_intent.ReceiveIntent.getInitialIntent();
    if (!mounted) return;

    setState(() {
      _initialIntent = receivedIntent;
    });
    try {
      if (_initialIntent!.extra!['android.intent.extra.STREAM'] == null) {
        return;
      }
      List imageList = [];
      if (_initialIntent!.extra!['android.intent.extra.STREAM'] is List) {
        imageList = _initialIntent!.extra!['android.intent.extra.STREAM'];
      } else {
        imageList.add(_initialIntent!.extra!['android.intent.extra.STREAM']);
      }

      for (int i = 0; i < imageList.length; i++) {
        File imageFile = await toFile(imageList[i]);
        String imagePath = imageFile.path;
        if (imagePath.isNotEmpty) {
          if (Global.isCustomRename == true) {
            Global.imageFile = await renamePictureWithCustomFormat(imageFile);
          } else if (Global.isTimeStamp == true) {
            Global.imageFile = await renamePictureWithTimestamp(imageFile);
          } else if (Global.isRandomName == true) {
            Global.imageFile = await renamePictureWithRandomString(imageFile);
          } else {
            Global.imageFile = my_path.basename(imageFile.path);
          }

          File compressedFile;
          if (Global.isCompress == true) {
            ImageCompress imageCompress = ImageCompress();
            compressedFile = await imageCompress.compressAndGetFile(
                imageFile.path, my_path.basename(Global.imageFile!), Global.defaultCompressFormat,
                minHeight: Global.minHeight, minWidth: Global.minWidth, quality: Global.quality);
          } else {
            compressedFile = imageFile;
          }
          Global.imagesList.add(Global.imageFile!);
          Global.imagesFileList.add(compressedFile);
        }
      }
      if (Global.imagesList.isNotEmpty) {
        for (int i = 0; i < Global.imagesList.length; i++) {
          uploadList.add([Global.imagesFileList[i].path, Global.imagesList[i]]);
          uploadPathList.add(Global.imagesFileList[i].path);
          uploadFileNameList.add(Global.imagesList[i]);
        }
      }
      setState(() {
        Global.imagesList.clear();
        Global.imagesFileList.clear();
        Global.imageFile = null;
        Global.imageOriginalFile = null;
      });
    } catch (e) {
      FLog.error(
          className: 'HomePage',
          methodName: '_initIntent',
          text: formatErrorMessage({
            'intent': _initialIntent,
          }, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
    }
  }

  clearAllList() {
    setState(() {
      uploadList.clear();
      uploadPathList.clear();
      uploadFileNameList.clear();
      Global.imagesList.clear();
      Global.imagesFileList.clear();
      Global.imageFile = null;
      Global.imageOriginalFile = null;
    });
  }

  @override
  void dispose() {
    actionEventBus.cancel();

    clipboardList.clear();
    super.dispose();
  }

  _createUploadListItem() {
    List<Widget> list = [];
    for (var i = uploadList.length - 1; i >= 0; i--) {
      list.add(ListItem(
          onUploadPlayPausedPressed: (path, fileName) async {
            var task = uploadManager.getUpload(uploadList[i][1]);
            if (task != null && !task.status.value.isCompleted) {
              switch (task.status.value) {
                case UploadStatus.uploading:
                  await uploadManager.pauseUpload(path, fileName);
                case UploadStatus.paused:
                  await uploadManager.resumeUpload(path, fileName);
                default:
                  break;
              }
              setState(() {});
            } else {
              await uploadManager.addUpload(path, fileName);
              setState(() {});
            }
          },
          onDelete: (path, fileName) async {
            await uploadManager.removeUpload(path, fileName);
            setState(() {});
          },
          path: uploadList[i][0],
          fileName: uploadList[i][1],
          uploadTask: uploadManager.getUpload(uploadList[i][1])));
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
                await uploadManager.addBatchUploads(uploadPathList, uploadFileNameList);
                setState(() {});
              },
              child: const Text(
                "全部开始",
                style: TextStyle(color: Colors.blue, fontSize: 16, fontWeight: FontWeight.bold),
              )),
          TextButton(
              onPressed: () async {
                await uploadManager.cancelBatchUploads(uploadPathList, uploadFileNameList);
              },
              child: const Text(
                "全部取消",
                style: TextStyle(color: Colors.blue, fontSize: 16, fontWeight: FontWeight.bold),
              )),
          TextButton(
              onPressed: () async {
                await clearAllList();
                setState(() {});
              },
              child: const Text(
                "全部清空",
                style: TextStyle(color: Colors.blue, fontSize: 16, fontWeight: FontWeight.bold),
              )),
        ],
      ),
      ValueListenableBuilder(
          valueListenable: uploadManager.getBatchUploadProgress(uploadPathList, uploadFileNameList),
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
    final XFile? pickedImage = await _picker.pickImage(source: ImageSource.camera, imageQuality: 100);

    if (pickedImage == null) {
      showToast('未拍摄图片');
      return;
    }
    final File fileImage = File(pickedImage.path);

    Global.imagesList.clear();
    Global.imagesFileList.clear();

    //图片重命名
    if (Global.isCustomRename == true) {
      Global.imageFile = await renamePictureWithCustomFormat(fileImage);
    } else if (Global.isTimeStamp == true) {
      Global.imageFile = renamePictureWithTimestamp(fileImage);
    } else if (Global.isRandomName == true) {
      Global.imageFile = renamePictureWithRandomString(fileImage);
    } else {
      Global.imageFile = my_path.basename(fileImage.path);
    }
    File compressedFile;
    if (Global.isCompress == true) {
      ImageCompress imageCompress = ImageCompress();
      compressedFile = await imageCompress.compressAndGetFile(
          pickedImage.path, my_path.basename(Global.imageFile!), Global.defaultCompressFormat,
          minHeight: Global.minHeight, minWidth: Global.minWidth, quality: Global.quality);
    } else {
      compressedFile = fileImage;
    }
    Global.imagesList.add(Global.imageFile!);
    Global.imagesFileList.add(compressedFile);
  }

  _imageFromNetwork() async {
    var url = await flutter_services.Clipboard.getData('text/plain');
    if (url == null) {
      showToast('剪贴板为空');
      return true;
    }
    try {
      String urlStr = url.text!;
      List urlList;
      urlList = urlStr.split("\n");
      int successCount = 0;
      int failCount = 0;
      Global.imagesList.clear();
      Global.imagesFileList.clear();

      for (var i = 0; i < urlList.length; i++) {
        if (urlList[i].isEmpty) {
          continue;
        }
        try {
          var response = await my_http.get(Uri.parse(urlList[i]));
          String tempPath = await getTemporaryDirectory().then((value) => value.path);
          String timeStamp = DateTime.now().millisecondsSinceEpoch.toString();
          String randomString = randomStringGenerator(5);
          File file = File('$tempPath/Web$timeStamp$randomString.jpg');
          await file.writeAsBytes(response.bodyBytes);
          Global.imageFile = file.path;

          //图片重命名
          if (Global.isCustomRename == true) {
            Global.imageFile = await renamePictureWithCustomFormat(file);
          } else if (Global.isTimeStamp == true) {
            Global.imageFile = await renamePictureWithTimestamp(file);
          } else if (Global.isRandomName == true) {
            Global.imageFile = await renamePictureWithRandomString(file);
          } else {
            Global.imageFile = my_path.basename(file.path);
          }
          File compressedFile;
          if (Global.isCompress == true) {
            ImageCompress imageCompress = ImageCompress();
            compressedFile = await imageCompress.compressAndGetFile(
                file.path, my_path.basename(Global.imageFile!), Global.defaultCompressFormat,
                minHeight: Global.minHeight, minWidth: Global.minWidth, quality: Global.quality);
          } else {
            compressedFile = file;
          }
          Global.imagesList.add(Global.imageFile!);
          Global.imagesFileList.add(compressedFile);
          successCount++;
        } catch (e) {
          FLog.error(
              className: 'ImagePage',
              methodName: '_imageFromNetwork',
              text: formatErrorMessage({
                'url': urlList[i],
              }, e.toString()),
              dataLogType: DataLogType.ERRORS.toString());
          failCount++;
          continue;
        }
      }
      if (successCount > 0) {
        return showToast('获取成功$successCount张,失败$failCount张');
      } else {
        return showToast('剪贴板内无链接');
      }
    } catch (e) {
      FLog.error(
          className: 'ImagePage',
          methodName: '_imageFromNetwork',
          text: formatErrorMessage({
            'url': url,
          }, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      return showToast('获取图片失败');
    }
  }

  _captureAndGoBack() async {
    XFile? pickedImage = await _picker.pickImage(source: ImageSource.camera, imageQuality: 100);
    if (pickedImage == null) {
      if (Global.isCopyLink == true) {
        if (clipboardList.isEmpty) {
          return showToast('未拍摄图片');
        }
        if (clipboardList.length == 1) {
          await flutter_services.Clipboard.setData(flutter_services.ClipboardData(text: clipboardList[0]));
        } else {
          await flutter_services.Clipboard.setData(flutter_services.ClipboardData(
              text: clipboardList
                  .toString()
                  .substring(1, clipboardList.toString().length - 1)
                  .replaceAll(', ', '\n')
                  .replaceAll(',', '\n')));
        }
        clipboardList.clear();
      }
      return showToast('上传完成');
    }

    File fileImage = File(pickedImage.path);

    if (Global.isCustomRename == true) {
      Global.imageFile = await renamePictureWithCustomFormat(fileImage);
    } else if (Global.isTimeStamp == true) {
      Global.imageFile = await renamePictureWithTimestamp(fileImage);
    } else if (Global.isRandomName == true) {
      Global.imageFile = await renamePictureWithRandomString(fileImage);
    } else {
      Global.imageFile = my_path.basename(fileImage.path);
    }
    Global.imageOriginalFile = fileImage;

    _processUploadAndReturnToCamera();
    if (Global.multiUpload == 'fail') {
      if (Global.isCopyLink == true) {
        if (clipboardList.length == 1) {
          await flutter_services.Clipboard.setData(flutter_services.ClipboardData(text: clipboardList[0]));
        } else {
          await flutter_services.Clipboard.setData(flutter_services.ClipboardData(
              text: clipboardList
                  .toString()
                  .substring(1, clipboardList.toString().length - 1)
                  .replaceAll(', ', '\n')
                  .replaceAll(',', '\n')));
        }
        clipboardList.clear();
      }
      return true;
    }
    _captureAndGoBack();
  }

  Map<String, dynamic> getUploadResultMap(String path, String fullName, List uploadResult) {
    Map<String, dynamic> maps = {};
    switch (Global.defaultPShost) {
      case 'sm.ms':
        //["success", formatedURL, returnUrl, pictureKey]
        maps = {
          'path': path,
          'name': fullName,
          'url': uploadResult[2], //返回地址可以直接访问
          'PBhost': Global.defaultPShost,
          'pictureKey': uploadResult[3],
          'hostSpecificArgA': 'test',
          'hostSpecificArgB': 'test',
          'hostSpecificArgC': 'test',
          'hostSpecificArgD': 'test',
          'hostSpecificArgE': 'test',
        };
      case 'lsky.pro':
      case 'github':
      case 'imgur':
      case 'qiniu':
      case 'tencent':
      case 'aliyun':
      case 'upyun':
        // ["success", formatedURL, returnUrl, pictureKey,displayUrl]
        maps = {
          'path': path,
          'name': fullName,
          'url': uploadResult[2], //tencent文件原始地址
          'PBhost': Global.defaultPShost,
          'pictureKey': uploadResult[3],
          'hostSpecificArgA': uploadResult[4], //实际展示的是displayUrl
          'hostSpecificArgB': 'test',
          'hostSpecificArgC': 'test',
          'hostSpecificArgD': 'test',
          'hostSpecificArgE': 'test',
        };
      case 'ftp':
        // ["success", formatedURL, returnUrl, pictureKey,displayUrl]
        maps = {
          'path': path,
          'name': fullName,
          'url': uploadResult[2], //ftp文件原始地址
          'PBhost': Global.defaultPShost,
          'pictureKey': uploadResult[3],
          'hostSpecificArgA': uploadResult[4], //实际展示的是displayUrl
          'hostSpecificArgB': uploadResult[5], //ftp自定义域名
          'hostSpecificArgC': uploadResult[6], //ftp端口
          'hostSpecificArgD': uploadResult[7], //ftp用户名
          'hostSpecificArgE': uploadResult[8], //ftp密码
          'hostSpecificArgF': uploadResult[9], //ftp类型
          'hostSpecificArgG': uploadResult[10], //ftp是否匿名
          'hostSpecificArgH': uploadResult[11], //ftp路径
          'hostSpecificArgI': uploadResult[12], //缩略图路径
        };
        List letter = 'JKLMNOPQRSTUVWXYZ'.split('');
        for (int i = 0; i < letter.length; i++) {
          maps['hostSpecificArg${letter[i]}'] = 'test';
        }
      case 'aws':
      case 'webdav':
        // ["success", formatedURL, returnUrl, pictureKey,displayUrl]
        maps = {
          'path': path,
          'name': fullName,
          'url': uploadResult[2], //aws文件原始地址
          'PBhost': Global.defaultPShost,
          'pictureKey': uploadResult[3],
          'hostSpecificArgA': uploadResult[4], //实际展示的是displayUrl
        };
        List letter = 'BCDEFGHIJKLMNOPQRSTUVWXYZ'.split('');
        for (int i = 0; i < letter.length; i++) {
          maps['hostSpecificArg${letter[i]}'] = 'test';
        }
      case 'alist':
        // ["success", formatedURL, returnUrl, pictureKey, displayUrl,hostPicUrl]
        maps = {
          'path': path,
          'name': fullName,
          'url': uploadResult[2], //alist文件原始地址
          'PBhost': Global.defaultPShost,
          'pictureKey': uploadResult[3],
          'hostSpecificArgA': uploadResult[4], //实际展示的是displayUrl
          'hostSpecificArgB': uploadResult[5], //源站地址，访问后会302跳转到returnUrl
        };
        List letter = 'CDEFGHIJKLMNOPQRSTUVWXYZ'.split('');
        for (int i = 0; i < letter.length; i++) {
          maps['hostSpecificArg${letter[i]}'] = 'test';
        }
    }
    return maps;
  }

  _processUploadAndReturnToCamera() async {
    File compressedFile;
    if (Global.isCompress == true) {
      ImageCompress imageCompress = ImageCompress();
      compressedFile = await imageCompress.compressAndGetFile(
          Global.imageOriginalFile!.path, my_path.basename(Global.imageFile!), Global.defaultCompressFormat,
          minHeight: Global.minHeight, minWidth: Global.minWidth, quality: Global.quality);
    } else {
      compressedFile = Global.imageOriginalFile!;
    }
    String path = compressedFile.path;
    String fullName = Global.imageFile!;
    Global.imageFile = null;
    Global.imageOriginalFile = null;

    var uploadResult = await uploaderentry(path: path, name: fullName);

    if (uploadResult[0] == "success") {
      eventBus.fire(AlbumRefreshEvent(albumKeepAlive: false));
      Map<String, dynamic> maps = getUploadResultMap(path, fullName, uploadResult);
      if (Global.defaultPShost == 'ftp' ||
          Global.defaultPShost == 'aws' ||
          Global.defaultPShost == 'alist' ||
          Global.defaultPShost == 'webdav') {
        await AlbumSQL.insertData(Global.imageDBExtend!, hostToTableNameMap[Global.defaultPShost]!, maps);
      } else {
        await AlbumSQL.insertData(Global.imageDB!, hostToTableNameMap[Global.defaultPShost]!, maps);
      }

      clipboardList.add(uploadResult[1]); //这里是formatedURL, 用来复制到剪贴板
      Global.multiUpload = 'success';
      return;
    } else {
      Global.multiUpload = 'fail';
      if (context.mounted) {
        return showCupertinoAlertDialog(context: context, title: "上传失败!", content: "上传参数有误.");
      }
      return;
    }
  }

  _multiImagePickerFromGallery() async {
    AssetPickerConfig config = const AssetPickerConfig(
      maxAssets: 100,
      selectedAssets: [],
    );
    final List<AssetEntity>? pickedImage = await AssetPicker.pickAssets(context, pickerConfig: config);

    if (pickedImage == null) {
      showToast("未选择图片");
      return;
    }

    for (var i = 0; i < pickedImage.length; i++) {
      File? fileImage = await pickedImage[i].originFile;

      if (Global.isCustomRename == true) {
        Global.imageFile = await renamePictureWithCustomFormat(fileImage!);
      } else if (Global.isTimeStamp == true) {
        Global.imageFile = await renamePictureWithTimestamp(fileImage!);
      } else if (Global.isRandomName == true) {
        Global.imageFile = await renamePictureWithRandomString(fileImage!);
      } else {
        Global.imageFile = my_path.basename(fileImage!.path);
      }

      File compressedFile;
      if (Global.isCompress == true) {
        ImageCompress imageCompress = ImageCompress();
        compressedFile = await imageCompress.compressAndGetFile(
            fileImage.path, my_path.basename(Global.imageFile!), Global.defaultCompressFormat,
            minHeight: Global.minHeight, minWidth: Global.minWidth, quality: Global.quality);
      } else {
        compressedFile = fileImage;
      }
      Global.imagesList.add(Global.imageFile!);
      Global.imagesFileList.add(compressedFile);
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

    for (var i = 0; i < Global.imagesFileList.length; i++) {
      String path = Global.imagesFileList[i].path;

      var uploadResult = await uploaderentry(path: path, name: Global.imagesList[i]);
      if (uploadResult[0] == "success") {
        successCount++;
        successList.add(Global.imagesList[i]);
        Map<String, dynamic> maps = getUploadResultMap(path, Global.imagesList[i], uploadResult);
        if (Global.defaultPShost == 'ftp' ||
            Global.defaultPShost == 'aws' ||
            Global.defaultPShost == 'alist' ||
            Global.defaultPShost == 'webdav') {
          await AlbumSQL.insertData(Global.imageDBExtend!, hostToTableNameMap[Global.defaultPShost]!, maps);
        } else {
          await AlbumSQL.insertData(Global.imageDB!, hostToTableNameMap[Global.defaultPShost]!, maps);
        }

        clipboardList.add(uploadResult[1]);
      } else {
        failCount++;
        failList.add(Global.imagesList[i]);
      }
    }

    setState(() {
      uploadList.clear();
      uploadPathList.clear();
      uploadFileNameList.clear();
      Global.imagesList.clear();
      Global.imagesFileList.clear();
      Global.imageFile = null;
      Global.imageOriginalFile = null;
    });

    if (successCount == 0) {
      String content = "全部上传失败\n\n失败的图片列表:\n\n";
      for (String failImage in failList) {
        content += "$failImage\n";
      }
      if (context.mounted) {
        return showCupertinoAlertDialog(barrierDismissible: true, context: context, title: "上传失败!", content: content);
      }
      return;
    } else if (failCount == 0) {
      eventBus.fire(AlbumRefreshEvent(albumKeepAlive: false));
      if (Global.isCopyLink == true) {
        await flutter_services.Clipboard.setData(flutter_services.ClipboardData(
            text: clipboardList.toString().substring(1, clipboardList.toString().length - 1)));
        clipboardList.clear();
      }
      String content = "图片列表:\n";
      for (String successImage in successList) {
        content += "$successImage\n";
      }
      if (successList.length == 1) {
        return showToast('上传成功');
      } else {
        if (context.mounted) {
          return showCupertinoAlertDialog(barrierDismissible: true, context: context, title: "上传成功!", content: content);
        }
        return;
      }
    } else {
      eventBus.fire(AlbumRefreshEvent(albumKeepAlive: false));
      if (Global.isCopyLink == true) {
        await flutter_services.Clipboard.setData(flutter_services.ClipboardData(
            text: clipboardList
                .toString()
                .substring(1, clipboardList.toString().length - 1)
                .replaceAll(', ', '\n')
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
      if (context.mounted) {
        return showCupertinoAlertDialog(barrierDismissible: true, context: context, title: "上传完成!", content: content);
      }
      return;
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
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColor.withValues(alpha: 0.8)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          actions: [
            PopupMenuButton(
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
                            SimpleDialogOption(
                              child: Text(
                                Global.defaultLKformat == 'rawurl' ? 'URL格式 \u2713' : 'URL格式',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Global.defaultLKformat == 'rawurl' ? Colors.blue : Colors.black,
                                  fontWeight: Global.defaultLKformat == 'rawurl' ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                              onPressed: () async {
                                await Global.setLKformat('rawurl');
                                if (context.mounted) {
                                  showToastWithContext(context, '已设置为URL格式');
                                  Navigator.pop(context);
                                }
                              },
                            ),
                            SimpleDialogOption(
                              child: Text(
                                Global.defaultLKformat == 'html' ? 'HTML格式 \u2713' : 'HTML格式',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Global.defaultLKformat == 'html' ? Colors.blue : Colors.black,
                                  fontWeight: Global.defaultLKformat == 'html' ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                              onPressed: () async {
                                await Global.setLKformat('html');
                                if (mounted) {
                                  showToastWithContext(context, '已设置为HTML格式');
                                  Navigator.pop(context);
                                }
                              },
                            ),
                            SimpleDialogOption(
                              child: Text(
                                Global.defaultLKformat == 'bbcode' ? 'BBcode格式 \u2713' : 'BBcode格式',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Global.defaultLKformat == 'bbcode' ? Colors.blue : Colors.black,
                                  fontWeight: Global.defaultLKformat == 'bbcode' ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                              onPressed: () async {
                                await Global.setLKformat('bbcode');
                                if (mounted) {
                                  showToastWithContext(context, '已设置为BBcode格式');
                                  Navigator.pop(context);
                                }
                              },
                            ),
                            SimpleDialogOption(
                              child: Text(
                                Global.defaultLKformat == 'markdown' ? 'markdown格式 \u2713' : 'markdown格式',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Global.defaultLKformat == 'markdown' ? Colors.blue : Colors.black,
                                  fontWeight:
                                      Global.defaultLKformat == 'markdown' ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                              onPressed: () async {
                                await Global.setLKformat('markdown');
                                if (mounted) {
                                  showToastWithContext(context, '已设置为markdown格式');
                                  Navigator.pop(context);
                                }
                              },
                            ),
                            SimpleDialogOption(
                              child: Text(
                                Global.defaultLKformat == 'markdown_with_link'
                                    ? 'markdown格式(带链接) \u2713'
                                    : 'markdown格式(带链接)',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Global.defaultLKformat == 'markdown_with_link' ? Colors.blue : Colors.black,
                                  fontWeight: Global.defaultLKformat == 'markdown_with_link'
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                              onPressed: () async {
                                await Global.setLKformat('markdown_with_link');
                                if (context.mounted) {
                                  showToastWithContext(context, '已设置为md_link格式');
                                  Navigator.pop(context);
                                }
                              },
                            ),
                            SimpleDialogOption(
                              child: Text(
                                Global.defaultLKformat == 'custom' ? '自定义格式 \u2713' : '自定义格式',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Global.defaultLKformat == 'custom' ? Colors.blue : Colors.black,
                                  fontWeight: Global.defaultLKformat == 'custom' ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                              onPressed: () async {
                                await Global.setLKformat('custom');
                                if (context.mounted) {
                                  showToastWithContext(context, '已设置为自定义格式');
                                  Navigator.pop(context);
                                }
                              },
                            ),
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
                  } else if (value == 2) {
                    showDialog(
                      barrierDismissible: true,
                      context: context,
                      builder: (context) {
                        return SimpleDialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          title: const Text(
                            '选择重命名方式',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          children: [
                            SimpleDialogOption(
                              child: ListTile(
                                title: const Text('开启时间戳重命名'),
                                subtitle: const Text('优先级按照自定义>时间戳>随机字符串'),
                                trailing: Switch(
                                  value: Global.isTimeStamp,
                                  onChanged: (value) async {
                                    await Global.setIsTimeStamp(value);
                                    if (context.mounted) {
                                      if (value) {
                                        showToastWithContext(context, '已开启时间戳重命名');
                                      } else {
                                        showToastWithContext(context, '已关闭时间戳重命名');
                                      }
                                      Navigator.pop(context);
                                    }
                                  },
                                ),
                              ),
                            ),
                            SimpleDialogOption(
                              child: ListTile(
                                title: const Text('开启随机字符串重命名'),
                                subtitle: const Text('字符串长度固定为30'),
                                trailing: Switch(
                                  value: Global.isRandomName,
                                  onChanged: (value) async {
                                    await Global.setIsRandomName(value);
                                    if (context.mounted) {
                                      if (value) {
                                        showToastWithContext(context, '已开启随机字符串重命名');
                                      } else {
                                        showToastWithContext(context, '已关闭随机字符串重命名');
                                      }
                                      Navigator.pop(context);
                                    }
                                  },
                                ),
                              ),
                            ),
                            SimpleDialogOption(
                              child: ListTile(
                                title: const Text('使用自定义重命名'),
                                trailing: Switch(
                                  value: Global.isCustomRename,
                                  onChanged: (value) async {
                                    await Global.setIsCustomeRename(value);
                                    if (context.mounted) {
                                      if (value) {
                                        showToastWithContext(context, '已开启自定义重命名');
                                      } else {
                                        showToastWithContext(context, '已关闭自定义重命名');
                                      }
                                      Navigator.pop(context);
                                    }
                                  },
                                ),
                              ),
                            ),
                            SimpleDialogOption(
                              child: TextFormField(
                                textAlign: TextAlign.center,
                                initialValue: Global.customRenameFormat,
                                decoration: const InputDecoration(
                                  label: Center(child: Text('自定义重命名格式')),
                                  hintText: r'规则参考表格，可随意组合其它字符',
                                ),
                                onChanged: (String value) async {
                                  await Global.setCustomeRenameFormat(value);
                                },
                              ),
                            ),
                            SimpleDialogOption(
                              child: Container(
                                  margin: const EdgeInsets.only(left: 20, right: 20),
                                  child: Table(
                                    border: TableBorder.all(
                                      color: Colors.black,
                                      width: 1,
                                      style: BorderStyle.solid,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    children: [
                                      const TableRow(
                                        decoration: ShapeDecoration(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(5),
                                              topRight: Radius.circular(5),
                                            ),
                                          ),
                                          color: Colors.grey,
                                        ),
                                        children: [
                                          TableCell(child: Center(child: Text("占位符"))),
                                          TableCell(child: Center(child: Text("说明"))),
                                        ],
                                      ),
                                      generateTableRow("{Y}", "年份(2022)"),
                                      generateTableRow("{y}", "两位数年份(22)"),
                                      generateTableRow("{m}", "月份(01-12)"),
                                      generateTableRow("{d}", "日期(01-31)"),
                                      generateTableRow("{h}", "小时(00-23)"),
                                      generateTableRow("{i}", "分钟(00-59)"),
                                      generateTableRow("{s}", "秒(00-59)"),
                                      generateTableRow("{ms}", "毫秒(000-999)"),
                                      generateTableRow("{timestamp}", "时间戳(毫秒)"),
                                      generateTableRow("{uuid}", "唯一字符串"),
                                      generateTableRow("{md5}", "随机md5"),
                                      generateTableRow("{md5-16}", "随机md5前16位"),
                                      generateTableRow("{str-number}", "number位随机字符串"),
                                      generateTableRow("{filename}", "原始文件名"),
                                    ],
                                  )),
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
                icon: const Icon(
                  Icons.settings,
                  color: Colors.white,
                  size: 30,
                ),
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
                          const Text('自动复制链接'),
                          Switch(
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            value: Global.isCopyLink,
                            onChanged: (value) async {
                              if (value == true) {
                                showToastWithContext(context, '开启链接复制');
                              } else {
                                showToastWithContext(context, '关闭链接复制');
                              }
                              await Global.setIsCopyLink(value);
                              setState(() {});
                              if (context.mounted) {
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
                    const PopupMenuItem(
                      value: 2,
                      child: Text('文件重命名方式'),
                    ),
                  ];
                }),
            IconButton(
              icon: const Icon(
                Icons.cleaning_services_sharp,
                color: Colors.white,
                size: 30,
              ),
              onPressed: () {
                uploadList.clear();
                uploadPathList.clear();
                uploadFileNameList.clear();
                setState(() {
                  Global.imagesList.clear();
                  Global.imagesFileList.clear();
                  Global.imageFile = null;
                  Global.imageOriginalFile = null;
                  showToastWithContext(context, "清除成功");
                });
              },
            ),
          ],
          title: titleText(
            '${psNameTranslate[Global.defaultPShost]}',
          ),
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
                    const Text('',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 20, color: Color.fromARGB(136, 121, 118, 118))),
                  ],
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  children: _createUploadListItem(),
                ),
              ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          SizedBox(
              height: 40,
              width: 40,
              child: FloatingActionButton(
                heroTag: 'camera',
                backgroundColor: const Color.fromARGB(255, 180, 236, 182),
                onPressed: () async {
                  await _imageFromCamera();
                  for (int i = 0; i < Global.imagesList.length; i++) {
                    uploadList.add([Global.imagesFileList[i].path, Global.imagesList[i]]);
                    uploadPathList.add(Global.imagesFileList[i].path);
                    uploadFileNameList.add(Global.imagesList[i]);
                  }
                  if (uploadList.isNotEmpty) {
                    if (context.mounted) {
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
                    return;
                  }
                },
                child: const Icon(
                  Icons.camera_alt_outlined,
                  color: Colors.white,
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
                      uploadList.add([Global.imagesFileList[i].path, Global.imagesList[i]]);
                      uploadPathList.add(Global.imagesFileList[i].path);
                      uploadFileNameList.add(Global.imagesList[i]);
                    }
                  }
                  setState(() {
                    Global.imagesList.clear();
                    Global.imagesFileList.clear();
                    Global.imageFile = null;
                    Global.imageOriginalFile = null;
                  });
                },
                child: const Icon(
                  Icons.image_outlined,
                  color: Colors.white,
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
                  _captureAndGoBack();
                },
                child: const Icon(
                  Icons.camera,
                  color: Colors.white,
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
                  await showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) {
                        return NetLoadingDialog(
                          outsideDismiss: false,
                          loading: true,
                          loadingText: "获取中...",
                          requestCallBack: _imageFromNetwork(),
                        );
                      });
                  if (Global.imagesList.isNotEmpty) {
                    for (int i = 0; i < Global.imagesList.length; i++) {
                      uploadList.add([Global.imagesFileList[i].path, Global.imagesList[i]]);
                      uploadPathList.add(Global.imagesFileList[i].path);
                      uploadFileNameList.add(Global.imagesList[i]);
                    }
                  }
                  setState(() {
                    Global.imagesList.clear();
                    Global.imagesFileList.clear();
                    Global.imageFile = null;
                    Global.imageOriginalFile = null;
                  });
                },
                child: const Icon(
                  Icons.wifi,
                  color: Colors.white,
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
            animatedIconTheme: const IconThemeData(color: Colors.white, size: 33.0),
            backgroundColor: Colors.blue,
            visible: true,
            curve: Curves.bounceIn,
            children: [
              SpeedDialChild(
                shape: const CircleBorder(),
                child: const Icon(
                  IconData(0x0055),
                  color: Colors.white,
                ),
                backgroundColor:
                    Global.defaultPShost == 'upyun' ? Colors.amber : const Color.fromARGB(255, 97, 180, 248),
                label: '又拍',
                labelStyle: const TextStyle(fontSize: 12.0),
                onTap: () async {
                  await setdefaultPShostRemoteAndLocal('upyun');
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
                backgroundColor:
                    Global.defaultPShost == 'tencent' ? Colors.amber : const Color.fromARGB(255, 97, 180, 248),
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
                  IconData(0x0053),
                  color: Colors.white,
                ),
                backgroundColor:
                    Global.defaultPShost == 'sm.ms' ? Colors.amber : const Color.fromARGB(255, 97, 180, 248),
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
                  IconData(0x0051),
                  color: Colors.white,
                ),
                backgroundColor:
                    Global.defaultPShost == 'qiniu' ? Colors.amber : const Color.fromARGB(255, 97, 180, 248),
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
                  IconData(0x004C),
                  color: Colors.white,
                ),
                backgroundColor:
                    Global.defaultPShost == 'lsky.pro' ? Colors.amber : const Color.fromARGB(255, 97, 180, 248),
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
                  IconData(0x0049),
                  color: Colors.white,
                ),
                backgroundColor:
                    Global.defaultPShost == 'imgur' ? Colors.amber : const Color.fromARGB(255, 97, 180, 248),
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
                  IconData(0x0047),
                  color: Colors.white,
                ),
                backgroundColor:
                    Global.defaultPShost == 'github' ? Colors.amber : const Color.fromARGB(255, 97, 180, 248),
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
                  IconData(0x0046),
                  color: Colors.white,
                ),
                backgroundColor: Global.defaultPShost == 'ftp' ? Colors.amber : const Color.fromARGB(255, 97, 180, 248),
                label: 'FTP',
                labelStyle: const TextStyle(fontSize: 12.0),
                onTap: () async {
                  await setdefaultPShostRemoteAndLocal('ftp');
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
                backgroundColor:
                    Global.defaultPShost == 'aliyun' ? Colors.amber : const Color.fromARGB(255, 97, 180, 248),
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
                  Icons.more_horiz_rounded,
                  color: Colors.white,
                ),
                backgroundColor: !['aliyun', 'ftp', 'github', 'imgur', 'lsky.pro', 'qiniu', 'sm.ms', 'tencent', 'upyun']
                        .contains(Global.defaultPShost)
                    ? Colors.amber
                    : const Color.fromARGB(255, 97, 180, 248),
                label: '更多',
                labelStyle: const TextStyle(fontSize: 12.0),
                onTap: () async {
                  await showDialog(
                    barrierDismissible: true,
                    context: context,
                    builder: (context) {
                      return SimpleDialog(
                        title: const Text(
                          '选择要为默认的图床',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        children: [
                          SimpleDialogOption(
                              child: ListTile(
                            dense: true,
                            visualDensity: VisualDensity.compact,
                            title: Text('Alist V3',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Global.defaultPShost == 'alist'
                                        ? Colors.amber
                                        : const Color.fromARGB(255, 97, 180, 248))),
                            onTap: () async {
                              Navigator.pop(context);
                              await setdefaultPShostRemoteAndLocal('alist');
                              eventBus.fire(AlbumRefreshEvent(albumKeepAlive: false));
                              setState(() {});
                            },
                          )),
                          SimpleDialogOption(
                              child: ListTile(
                            dense: true,
                            visualDensity: VisualDensity.compact,
                            title: Text('S3兼容平台',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Global.defaultPShost == 'aws'
                                        ? Colors.amber
                                        : const Color.fromARGB(255, 97, 180, 248))),
                            onTap: () async {
                              Navigator.pop(context);
                              await setdefaultPShostRemoteAndLocal('aws');
                              eventBus.fire(AlbumRefreshEvent(albumKeepAlive: false));
                              setState(() {});
                            },
                          )),
                          SimpleDialogOption(
                              child: ListTile(
                            dense: true,
                            visualDensity: VisualDensity.compact,
                            title: Text('WebDAV',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Global.defaultPShost == 'webdav'
                                        ? Colors.amber
                                        : const Color.fromARGB(255, 97, 180, 248))),
                            onTap: () async {
                              Navigator.pop(context);
                              await setdefaultPShostRemoteAndLocal('webdav');
                              eventBus.fire(AlbumRefreshEvent(albumKeepAlive: false));
                              setState(() {});
                            },
                          )),
                        ],
                      );
                    },
                  );
                  setState(() {});
                },
              ),
            ],
          ),
        ]));
  }
}

class ListItem extends StatefulWidget {
  final Function(String, String) onUploadPlayPausedPressed;
  final Function(String, String) onDelete;
  final UploadTask? uploadTask;
  final String path;
  final String fileName;
  const ListItem(
      {super.key,
      required this.onUploadPlayPausedPressed,
      required this.onDelete,
      required this.path,
      required this.fileName,
      this.uploadTask});

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
                getImageIcon(widget.path),
                Expanded(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '文件名:${widget.fileName}',
                    ),
                    if (widget.uploadTask != null)
                      ValueListenableBuilder(
                          valueListenable: widget.uploadTask!.status,
                          builder: (context, value, child) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child:
                                  Text("状态: ${uploadStatus[value.toString()]}", style: const TextStyle(fontSize: 14)),
                            );
                          }),
                  ],
                )),
                widget.uploadTask != null
                    ? ValueListenableBuilder(
                        valueListenable: widget.uploadTask!.status,
                        builder: (context, value, child) {
                          switch (widget.uploadTask!.status.value) {
                            case UploadStatus.completed:
                              return IconButton(
                                  onPressed: () {
                                    widget.onDelete(widget.path, widget.fileName);
                                  },
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ));
                            case UploadStatus.failed:
                            case UploadStatus.canceled:
                              return IconButton(
                                  onPressed: () async {
                                    await widget.onUploadPlayPausedPressed(widget.path, widget.fileName);
                                  },
                                  icon: const Icon(
                                    Icons.cloud_upload_outlined,
                                    color: Colors.blue,
                                  ));
                            default:
                              return widget.uploadTask == null || widget.uploadTask!.status.value == UploadStatus.queued
                                  ? const Icon(
                                      Icons.query_builder_rounded,
                                      color: Colors.blue,
                                    )
                                  : ValueListenableBuilder(
                                      valueListenable: widget.uploadTask!.progress,
                                      builder: (context, value, child) {
                                        return Container(
                                          height: 20,
                                          width: 20,
                                          margin: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                                          child: CircularProgressIndicator(
                                            value: value,
                                            strokeWidth: 4,
                                            color: widget.uploadTask!.status.value == UploadStatus.paused
                                                ? Colors.grey
                                                : Colors.blue,
                                          ),
                                        );
                                      });
                          }
                        })
                    : IconButton(
                        onPressed: () async {
                          await widget.onUploadPlayPausedPressed(widget.path, widget.fileName);
                        },
                        icon: const Icon(
                          Icons.cloud_upload_outlined,
                          color: Colors.green,
                        ))
              ],
            ),
          ],
        ),
      ),
    );
  }
}

TableRow generateTableRow(String placeholder, String description) {
  return TableRow(
    children: [
      TableCell(child: Center(child: Text(placeholder))),
      TableCell(child: Center(child: Text(description))),
    ],
  );
}
