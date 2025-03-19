import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:horopic/widgets/common_widgets.dart';

import 'package:image_picker/image_picker.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:flutter/services.dart' as flutter_services;
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:http/http.dart' as my_http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as my_path;
import 'package:receive_intent/receive_intent.dart' as ic_intent;
import 'package:uri_to_file/uri_to_file.dart';

import 'package:horopic/album/album_sql.dart';
import 'package:horopic/utils/event_bus_utils.dart';
import 'package:horopic/widgets/net_loading_dialog.dart';
import 'package:horopic/picture_host_configure/default_picture_host_select.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/utils/global.dart';
import 'package:horopic/utils/uploader.dart';
import 'package:horopic/pages/upload_helper/home_page_uploadlist.dart';
import 'package:horopic/pages/upload_helper/upload_utils.dart';
import 'package:horopic/pages/upload_helper/upload_status.dart';
import 'package:horopic/utils/image_compressor.dart';

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
  Map<String, String> uploadedLinks = {}; // Track links for each file
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
          File compressedFile = await processImageFile(imageFile);
          Global.imagesList.add(Global.imageFile!);
          Global.imagesFileList.add(compressedFile);
        }
      }
      addToUploadList();
    } catch (e) {
      flogErr(
          e,
          {
            'intent': _initialIntent,
          },
          'HomePage',
          '_initIntent');
    }
  }

  void addToUploadList() {
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
  }

  clearAllList() {
    setState(() {
      uploadList.clear();
      uploadPathList.clear();
      uploadFileNameList.clear();
      uploadedLinks.clear(); // Clear the links map too
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
    uploadedLinks.clear(); // Clear links map on dispose
    super.dispose();
  }

  // Refresh links from tasks
  void _updateLinksFromTasks() {
    for (var i = 0; i < uploadList.length; i++) {
      String fileName = uploadList[i][1];
      var task = uploadManager.getUpload(fileName);
      if (task != null && task.status.value == UploadStatus.completed && task.formattedUrl.isNotEmpty) {
        uploadedLinks[fileName] = task.formattedUrl;
      }
    }
  }

  _createUploadListItem() {
    _updateLinksFromTasks(); // Update links from tasks before rendering

    List<Widget> list = [];
    for (var i = uploadList.length - 1; i >= 0; i--) {
      String fileName = uploadList[i][1];
      String? clipboardLink;

      // Check if we have the link in our map
      if (uploadedLinks.containsKey(fileName)) {
        clipboardLink = uploadedLinks[fileName];
      } else {
        // Try to get it from the task if available
        var task = uploadManager.getUpload(fileName);
        if (task != null && task.status.value == UploadStatus.completed && task.formattedUrl.isNotEmpty) {
          clipboardLink = task.formattedUrl;
          uploadedLinks[fileName] = clipboardLink;
        }
      }

      list.add(HomePageUploadItem(
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
              _handleBatchUploadCompletion(uploadPathList, uploadFileNameList);
              setState(() {});
            }
          },
          onDelete: (path, fileName) async {
            await uploadManager.removeUpload(path, fileName);
            setState(() {
              // Also remove from links map when deleted
              uploadedLinks.remove(fileName);
            });
          },
          onCopy: (link) {
            flutter_services.Clipboard.setData(flutter_services.ClipboardData(text: link!));
            showToastWithContext(context, '链接已复制到剪贴板');
          },
          path: uploadList[i][0],
          fileName: uploadList[i][1],
          clipboardLink: clipboardLink,
          uploadTask: uploadManager.getUpload(uploadList[i][1])));
    }
    List<Widget> list2 = [
      const Divider(
        height: 5,
        color: Colors.transparent,
      ),
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.2),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _actionButton(
                      icon: Icons.play_arrow,
                      label: "全部开始",
                      onPressed: () async {
                        await uploadManager.addBatchUploads(uploadPathList, uploadFileNameList);
                        _handleBatchUploadCompletion(uploadPathList, uploadFileNameList);
                        setState(() {});
                      }),
                  _actionButton(
                      icon: Icons.cancel,
                      label: "全部取消",
                      onPressed: () async {
                        await uploadManager.cancelBatchUploads(uploadPathList, uploadFileNameList);
                      }),
                  _actionButton(
                      icon: Icons.delete_sweep,
                      label: "全部清空",
                      onPressed: () async {
                        await clearAllList();
                        setState(() {});
                      }),
                ],
              ),
            ),
          ],
        ),
      ),
    ];
    list2.addAll(list);

    return list2;
  }

  Widget _actionButton({required IconData icon, required String label, required Function() onPressed}) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Theme.of(context).primaryColor, size: 18),
      label: Text(
        label,
        style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
      ),
    );
  }

  _imageFromCamera() async {
    final XFile? pickedImage = await _picker.pickImage(source: ImageSource.camera, imageQuality: 100);

    if (pickedImage == null) {
      showToast('未拍摄图片');
      return;
    }

    Global.imagesList.clear();
    Global.imagesFileList.clear();
    final File fileImage = File(pickedImage.path);
    File compressedFile = await processImageFile(fileImage);
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
          Uri uri = Uri.parse(urlList[i]);
          var response = await my_http.get(uri);
          String fileExt = '.jpg';
          String path = uri.path.toLowerCase();
          if (path.contains('.')) {
            fileExt = path.substring(path.lastIndexOf('.'));
          }
          String tempPath = await getTemporaryDirectory().then((value) => value.path);
          String timeStamp = DateTime.now().millisecondsSinceEpoch.toString();
          String randomString = randomStringGenerator(5);
          File file = File('$tempPath/Web$timeStamp$randomString.$fileExt');
          await file.writeAsBytes(response.bodyBytes);
          Global.imageFile = file.path;
          File compressedFile = await processImageFile(file);
          Global.imagesList.add(Global.imageFile!);
          Global.imagesFileList.add(compressedFile);
          successCount++;
        } catch (e) {
          flogErr(
              e,
              {
                'url': urlList[i],
              },
              'ImagePage',
              '_imageFromNetwork');
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
      flogErr(
          e,
          {
            'url': url,
          },
          'ImagePage',
          '_imageFromNetwork');
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
        if (clipboardList.isNotEmpty) {
          await flutter_services.Clipboard.setData(flutter_services.ClipboardData(text: clipboardList.join('\n')));
        }
      }
      return showToast('上传完成');
    }

    File fileImage = File(pickedImage.path);

    if (Global.isCustomRename) {
      Global.imageFile = await renamePictureWithCustomFormat(fileImage);
    } else if (Global.isTimeStamp) {
      Global.imageFile = await renamePictureWithTimestamp(fileImage);
    } else if (Global.isRandomName) {
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
    Map<String, dynamic> maps = {
      'path': path,
      'name': fullName,
      'url': uploadResult[2],
      'PBhost': Global.defaultPShost,
      'pictureKey': uploadResult[3],
    };
    switch (Global.defaultPShost) {
      case 'sm.ms':
        //["success", formatedURL, returnUrl, pictureKey]
        maps['hostSpecificArgA'] = 'test';
        maps['hostSpecificArgB'] = 'test';
        maps['hostSpecificArgC'] = 'test';
        maps['hostSpecificArgD'] = 'test';
        maps['hostSpecificArgE'] = 'test';
      case 'lsky.pro':
      case 'github':
      case 'imgur':
      case 'qiniu':
      case 'tencent':
      case 'aliyun':
      case 'upyun':
        // ["success", formatedURL, returnUrl, pictureKey,displayUrl]
        maps['hostSpecificArgA'] = uploadResult[4]; // displayUrl
        maps['hostSpecificArgB'] = 'test';
        maps['hostSpecificArgC'] = 'test';
        maps['hostSpecificArgD'] = 'test';
        maps['hostSpecificArgE'] = 'test';
      case 'ftp':
        // ["success", formatedURL, returnUrl, pictureKey,displayUrl]
        // A-I:  displayUrl, ftp自定义域名, ftp端口, ftp用户名, ftp密码, ftp类型, ftp是否匿名, ftp路径, 缩略图路径
        for (int i = 0; i < 8; i++) {
          maps['hostSpecificArg${String.fromCharCode(65 + i)}'] = uploadResult[i + 4];
        }
        maps['hostSpecificArgI'] = uploadResult[12]; // 缩略图路径
        // Add remaining default values
        for (int i = 9; i < 26; i++) {
          maps['hostSpecificArg${String.fromCharCode(65 + i)}'] = 'test';
        }
      case 'aws':
      case 'webdav':
        // ["success", formatedURL, returnUrl, pictureKey,displayUrl]
        maps['hostSpecificArgA'] = uploadResult[4]; // displayUrl
        for (int i = 1; i < 26; i++) {
          maps['hostSpecificArg${String.fromCharCode(65 + i)}'] = 'test';
        }
      case 'alist':
        // ["success", formatedURL, returnUrl, pictureKey, displayUrl,hostPicUrl]
        maps['hostSpecificArgA'] = uploadResult[4]; // displayUrl
        maps['hostSpecificArgB'] = uploadResult[5]; //源站地址，访问后会302跳转到returnUrl
        for (int i = 2; i < 26; i++) {
          maps['hostSpecificArg${String.fromCharCode(65 + i)}'] = 'test';
        }
    }
    return maps;
  }

  _processUploadAndReturnToCamera() async {
    File compressedFile;
    if (Global.isCompress == true) {
      compressedFile = await compressAndGetFile(
          Global.imageOriginalFile!.path, my_path.basename(Global.imageFile!), Global.defaultCompressFormat,
          minHeight: Global.minHeight, minWidth: Global.minWidth, quality: Global.quality);
      Global.imageFile = '${my_path.dirname(Global.imageFile!)}/${my_path.basename(compressedFile.path)}';
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
      setState(() {
        // Add to uploadedLinks map
        uploadedLinks[fullName] = uploadResult[1];
      });
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
      File compressedFile = await processImageFile(fileImage!);
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
        setState(() {
          // Add to uploadedLinks map
          uploadedLinks[Global.imagesList[i]] = uploadResult[1];
        });
      } else {
        failCount++;
        failList.add(Global.imagesList[i]);
      }
    }

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
      if (Global.isCopyLink == true && clipboardList.isNotEmpty) {
        // Save all links to clipboard with new line separator
        await flutter_services.Clipboard.setData(flutter_services.ClipboardData(text: clipboardList.join('\n')));
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
      if (Global.isCopyLink == true && clipboardList.isNotEmpty) {
        // Save all successful links to clipboard with new line separator
        await flutter_services.Clipboard.setData(flutter_services.ClipboardData(text: clipboardList.join('\n')));
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

  Future<void> _handleBatchUploadCompletion(List<String> paths, List<String> fileNames) async {
    // Wait for all uploads to complete
    try {
      await uploadManager.whenBatchUploadsComplete(paths, fileNames);

      // After completion, update all links
      clipboardList.clear();
      for (var i = 0; i < fileNames.length; i++) {
        var task = uploadManager.getUpload(fileNames[i]);
        if (task != null && task.status.value == UploadStatus.completed && task.formattedUrl.isNotEmpty) {
          // Add to clipboard list
          clipboardList.add(task.formattedUrl);
          // Update the links map
          setState(() {
            uploadedLinks[fileNames[i]] = task.formattedUrl;
          });
        }
      }

      // Copy all successful links to clipboard if enabled
      if (Global.isCopyLink && clipboardList.isNotEmpty) {
        await flutter_services.Clipboard.setData(flutter_services.ClipboardData(text: clipboardList.join('\n')));
        if (context.mounted) {
          showToastWithContext(context, '已复制${clipboardList.length}个链接到剪贴板');
        }
      }
    } catch (e) {
      flogErr(
          e,
          {
            'paths': paths,
            'fileNames': fileNames,
          },
          'HomePage',
          '_handleBatchUploadCompletion');
    }
  }

  Future<void> showFormatSelectionDialog() async {
    await showDialog(
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
            _buildFormatOption('rawurl', 'URL格式'),
            _buildFormatOption('html', 'HTML格式'),
            _buildFormatOption('bbcode', 'BBcode格式'),
            _buildFormatOption('markdown', 'markdown格式'),
            _buildFormatOption('markdown_with_link', 'markdown格式(带链接)'),
            _buildFormatOption('custom', '自定义格式'),
            SimpleDialogOption(
              child: TextFormField(
                textAlign: TextAlign.center,
                initialValue: Global.customLinkFormat,
                decoration: const InputDecoration(
                  hintText: r'使用$url和$fileName作为占位符',
                ),
                onChanged: (String value) {
                  Global.setCustomLinkFormat(value);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFormatOption(String format, String label) {
    return SimpleDialogOption(
      child: Text(
        Global.defaultLKformat == format ? '$label \u2713' : label,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Global.defaultLKformat == format ? Colors.blue : Colors.black,
          fontWeight: Global.defaultLKformat == format ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onPressed: () async {
        Global.setLKformat(format);
        if (mounted) {
          showToastWithContext(context, '已设置为$label');
          Navigator.pop(context);
        }
      },
    );
  }

  List<SpeedDialChild> _buildSpeedDialChildren() {
    // Main image hosts
    final List<Map<String, dynamic>> mainHosts = [
      {'id': 'upyun', 'icon': 0x0055, 'label': '又拍'},
      {'id': 'tencent', 'icon': 0x0054, 'label': '腾讯'},
      {'id': 'sm.ms', 'icon': 0x0053, 'label': 'SM.MS'},
      {'id': 'qiniu', 'icon': 0x0051, 'label': '七牛'},
      {'id': 'lsky.pro', 'icon': 0x004C, 'label': '兰空'},
      {'id': 'imgur', 'icon': 0x0049, 'label': 'Imgur'},
      {'id': 'github', 'icon': 0x0047, 'label': 'Github'},
      {'id': 'ftp', 'icon': 0x0046, 'label': 'FTP'},
      {'id': 'aliyun', 'icon': 0x0041, 'label': '阿里'},
    ];

    // More hosts for the dialog
    final List<Map<String, dynamic>> moreHosts = [
      {'id': 'alist', 'label': 'Alist V3'},
      {'id': 'aws', 'label': 'S3兼容平台'},
      {'id': 'webdav', 'label': 'WebDAV'},
    ];

    List<SpeedDialChild> children = mainHosts
        .map((host) => SpeedDialChild(
              shape: const CircleBorder(),
              child: Icon(
                IconData(host['icon']),
                color: Colors.white,
              ),
              backgroundColor:
                  Global.defaultPShost == host['id'] ? Colors.amber : const Color.fromARGB(255, 97, 180, 248),
              label: host['label'],
              labelStyle: const TextStyle(fontSize: 12.0),
              labelBackgroundColor: Colors.white,
              elevation: 3,
              onTap: () async {
                await setdefaultPShostRemoteAndLocal(host['id']);
                eventBus.fire(AlbumRefreshEvent(albumKeepAlive: false));
                setState(() {});
              },
            ))
        .toList();

    // Add "More" button
    children.add(SpeedDialChild(
      shape: const CircleBorder(),
      child: const Icon(
        Icons.more_horiz_rounded,
        color: Colors.white,
      ),
      backgroundColor: !mainHosts.map((host) => host['id']).contains(Global.defaultPShost)
          ? Colors.amber
          : const Color.fromARGB(255, 97, 180, 248),
      label: '更多',
      labelStyle: const TextStyle(fontSize: 12.0),
      labelBackgroundColor: Colors.white,
      elevation: 3,
      onTap: () async {
        await showDialog(
          barrierDismissible: true,
          context: context,
          builder: (context) {
            return SimpleDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
              title: const Text(
                '选择要为默认的图床',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              children: moreHosts
                  .map((host) => SimpleDialogOption(
                        child: ListTile(
                          dense: true,
                          visualDensity: VisualDensity.compact,
                          title: Text(host['label'],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Global.defaultPShost == host['id']
                                      ? Colors.amber
                                      : const Color.fromARGB(255, 97, 180, 248))),
                          onTap: () async {
                            Navigator.pop(context);
                            await setdefaultPShostRemoteAndLocal(host['id']);
                            eventBus.fire(AlbumRefreshEvent(albumKeepAlive: false));
                            setState(() {});
                          },
                        ),
                      ))
                  .toList(),
            );
          },
        );
        setState(() {});
      },
    ));

    return children;
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
          flexibleSpace: getFlexibleSpace(context),
          actions: [
            PopupMenuButton(
                icon: const Icon(
                  Icons.settings,
                  color: Colors.white,
                  size: 26,
                ),
                position: PopupMenuPosition.under,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
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
                            activeColor: Theme.of(context).primaryColor,
                            onChanged: (value) async {
                              if (value == true) {
                                showToastWithContext(context, '开启链接复制');
                              } else {
                                showToastWithContext(context, '关闭链接复制');
                              }
                              Global.setIsCopyLink(value);
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
                },
                onSelected: (value) {
                  if (value == 1) {
                    showFormatSelectionDialog();
                  } else if (value == 2) {
                    showDialog(
                      barrierDismissible: true,
                      context: context,
                      builder: (context) {
                        return SimpleDialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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
                                  activeColor: Theme.of(context).primaryColor,
                                  value: Global.isTimeStamp,
                                  onChanged: (value) async {
                                    Global.setIsTimeStamp(value);
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
                                  activeColor: Theme.of(context).primaryColor,
                                  value: Global.isRandomName,
                                  onChanged: (value) async {
                                    Global.setIsRandomName(value);
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
                                  activeColor: Theme.of(context).primaryColor,
                                  value: Global.isCustomRename,
                                  onChanged: (value) async {
                                    Global.setIsCustomeRename(value);
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
                                onChanged: (String value) {
                                  Global.setCustomeRenameFormat(value);
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
                }),
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
                      width: 180,
                      height: 180,
                    ),
                    const SizedBox(height: 20),
                    Text('点击下方按钮上传图片',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18, color: Theme.of(context).primaryColor.withValues(alpha: 0.7))),
                    const SizedBox(height: 10),
                    Text('当前图床: ${psNameTranslate[Global.defaultPShost]}',
                        textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                  ],
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  children: _createUploadListItem(),
                ),
              ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              _buildActionButton(
                color: const Color.fromARGB(255, 180, 236, 182),
                icon: Icons.camera_alt_outlined,
                tooltip: '拍照上传',
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
              ),
              _buildActionButton(
                color: const Color.fromARGB(255, 112, 215, 247),
                icon: Icons.image_outlined,
                tooltip: '从相册选择',
                onPressed: () async {
                  await _multiImagePickerFromGallery();
                  addToUploadList();
                },
              ),
              _buildActionButton(
                color: const Color.fromARGB(255, 237, 201, 241),
                icon: Icons.camera,
                tooltip: '连续拍照',
                onPressed: () {
                  _captureAndGoBack();
                },
              ),
              _buildActionButton(
                color: const Color.fromARGB(255, 248, 231, 136),
                icon: Icons.wifi,
                tooltip: '从网络获取',
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
                  addToUploadList();
                },
              ),
              SpeedDial(
                activeIcon: Icons.close,
                activeForegroundColor: Colors.white,
                activeBackgroundColor: Colors.redAccent,
                renderOverlay: true,
                overlayOpacity: 0.5,
                buttonSize: const Size(40, 40),
                childrenButtonSize: const Size(40, 40),
                animatedIcon: AnimatedIcons.menu_close,
                animatedIconTheme: const IconThemeData(color: Colors.white, size: 25.0),
                backgroundColor: Colors.blue,
                visible: true,
                curve: Curves.bounceIn,
                tooltip: '选择图床',
                children: _buildSpeedDialChildren(),
              ),
            ])));
  }

  Widget _buildActionButton(
      {required Color color, required IconData icon, required Function() onPressed, required String tooltip}) {
    return SizedBox(
        height: 40,
        width: 40,
        child: FloatingActionButton(
          heroTag: icon.toString(),
          backgroundColor: color,
          tooltip: tooltip,
          onPressed: onPressed,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ));
  }
}

// Clipper for rounded rectangle
class ClipRoundedRectangle extends CustomClipper<RRect> {
  final BorderRadius borderRadius;

  ClipRoundedRectangle({required this.borderRadius});

  @override
  RRect getClip(Size size) {
    return borderRadius.toRRect(Offset.zero & size);
  }

  @override
  bool shouldReclip(CustomClipper<RRect> oldClipper) {
    return true;
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

Future<File> processImageFile(File imageFile) async {
  String fileName;

  if (Global.isCustomRename) {
    fileName = await renamePictureWithCustomFormat(imageFile);
  } else if (Global.isTimeStamp) {
    fileName = await renamePictureWithTimestamp(imageFile);
  } else if (Global.isRandomName) {
    fileName = await renamePictureWithRandomString(imageFile);
  } else {
    fileName = my_path.basename(imageFile.path);
  }
  Global.imageFile = fileName;
  File compressedFile;
  if (Global.isCompress) {
    compressedFile = await compressAndGetFile(
        imageFile.path, my_path.basename(Global.imageFile!), Global.defaultCompressFormat,
        minHeight: Global.minHeight, minWidth: Global.minWidth, quality: Global.quality);
    Global.imageFile = '${my_path.dirname(Global.imageFile!)}/${my_path.basename(compressedFile.path)}';
  } else {
    compressedFile = imageFile;
  }
  return compressedFile;
}
