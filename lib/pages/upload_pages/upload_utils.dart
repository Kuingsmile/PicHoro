import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:f_logs/f_logs.dart';
import 'package:horopic/api/api.dart';
import 'package:ftpconnect/ftpconnect.dart';
import 'package:dartssh2/dartssh2.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:minio/minio.dart';

import 'package:horopic/pages/upload_pages/upload_request.dart';
import 'package:horopic/pages/upload_pages/upload_status.dart';
import 'package:horopic/pages/upload_pages/upload_task.dart';
import 'package:horopic/utils/event_bus_utils.dart';
import 'package:horopic/utils/uploader.dart';
import 'package:horopic/utils/global.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/album/album_sql.dart';

class UploadManager {
  final Map<String, UploadTask> _cache = <String, UploadTask>{};
  final Queue<UploadRequest> _queue = Queue();
  Dio dio = Dio();

  int maxConcurrentTasks = 2;
  int runningTasks = 0;

  static final UploadManager _instance = UploadManager._internal();

  UploadManager._internal();

  factory UploadManager({int? maxConcurrentTasks}) {
    if (maxConcurrentTasks != null) {
      _instance.maxConcurrentTasks = maxConcurrentTasks;
    }
    return _instance;
  }

  void Function(int, int) createCallback(String path, String name) {
    return (int sent, int total) {
      getUpload(name)?.progress.value = sent / total;
    };
  }

  Future<void> upload(String path, String fileName, canceltoken) async {
    try {
      var task = getUpload(fileName);

      if (task == null || task.status.value == UploadStatus.canceled) {
        return;
      }
      setStatus(task, UploadStatus.uploading);

      String configData = await readPictureHostConfig();
      Map configMap = jsonDecode(configData);
      String defaultPH = await Global.getPShost();
      if (defaultPH == 'tencent') {
        var tencentUploadResult = await TencentImageUploadUtils.uploadApi(
            path: path,
            name: fileName,
            configMap: configMap,
            onSendProgress: createCallback(path, fileName),
            cancelToken: canceltoken);

        if (tencentUploadResult[0] == 'success') {
          eventBus.fire(AlbumRefreshEvent(albumKeepAlive: false));
          Map<String, dynamic> maps = {};
          String formatedURL = tencentUploadResult[1];
          String returnUrl = tencentUploadResult[2];
          String pictureKey = tencentUploadResult[3];
          String displayUrl = tencentUploadResult[4];

          if (Global.isCopyLink == true) {
            formatedURL = linkGenerateDict[Global.defaultLKformat]!(returnUrl, fileName);
          } else {
            formatedURL = returnUrl;
          }
          await Clipboard.setData(ClipboardData(text: formatedURL));

          maps = {
            'path': path,
            'name': fileName,
            'url': returnUrl, //tencent文件原始地址
            'PBhost': Global.defaultPShost,
            'pictureKey': pictureKey,
            'hostSpecificArgA': displayUrl, //实际展示的是displayUrl
            'hostSpecificArgB': 'test',
            'hostSpecificArgC': 'test',
            'hostSpecificArgD': 'test',
            'hostSpecificArgE': 'test',
          };
          await AlbumSQL.insertData(Global.imageDB!, pBhostToTableName[Global.defaultPShost]!, maps);
          setStatus(task, UploadStatus.completed);
        } else {
          throw Exception('上传失败');
        }
      } else if (defaultPH == 'aliyun') {
        var aliUploadResult = await AliyunImageUploadUtils.uploadApi(
            path: path,
            name: fileName,
            configMap: configMap,
            onSendProgress: createCallback(path, fileName),
            cancelToken: canceltoken);
        if (aliUploadResult[0] == 'success') {
          eventBus.fire(AlbumRefreshEvent(albumKeepAlive: false));
          Map<String, dynamic> maps = {};
          String formatedURL = aliUploadResult[1];
          String returnUrl = aliUploadResult[2];
          String pictureKey = aliUploadResult[3];
          String displayUrl = aliUploadResult[4];

          await Clipboard.setData(ClipboardData(text: formatedURL));

          maps = {
            'path': path,
            'name': fileName,
            'url': returnUrl, //aliyun文件原始地址
            'PBhost': Global.defaultPShost,
            'pictureKey': pictureKey,
            'hostSpecificArgA': displayUrl, //实际展示的是displayUrl
            'hostSpecificArgB': 'test',
            'hostSpecificArgC': 'test',
            'hostSpecificArgD': 'test',
            'hostSpecificArgE': 'test',
          };
          await AlbumSQL.insertData(Global.imageDB!, pBhostToTableName[Global.defaultPShost]!, maps);
          setStatus(task, UploadStatus.completed);
        } else {
          throw Exception('上传失败');
        }
      } else if (defaultPH == 'qiniu') {
        var qiniuUploadResult = await QiniuImageUploadUtils.uploadApi(
            path: path,
            name: fileName,
            configMap: configMap,
            onSendProgress: createCallback(path, fileName),
            cancelToken: canceltoken);

        if (qiniuUploadResult[0] == 'success') {
          eventBus.fire(AlbumRefreshEvent(albumKeepAlive: false));
          Map<String, dynamic> maps = {};
          String formatedURL = qiniuUploadResult[1];
          String returnUrl = qiniuUploadResult[2];
          String pictureKey = qiniuUploadResult[3];
          String displayUrl = qiniuUploadResult[4];

          await Clipboard.setData(ClipboardData(text: formatedURL));

          maps = {
            'path': path,
            'name': fileName,
            'url': returnUrl, //qiniu文件原始地址
            'PBhost': Global.defaultPShost,
            'pictureKey': pictureKey,
            'hostSpecificArgA': displayUrl, //实际展示的是displayUrl
            'hostSpecificArgB': 'test',
            'hostSpecificArgC': 'test',
            'hostSpecificArgD': 'test',
            'hostSpecificArgE': 'test',
          };
          await AlbumSQL.insertData(Global.imageDB!, pBhostToTableName[Global.defaultPShost]!, maps);
          setStatus(task, UploadStatus.completed);
        } else {
          throw Exception('上传失败');
        }
      } else if (defaultPH == 'upyun') {
        var upyunUploadResult = await UpyunImageUploadUtils.uploadApi(
            path: path,
            name: fileName,
            configMap: configMap,
            onSendProgress: createCallback(path, fileName),
            cancelToken: canceltoken);

        if (upyunUploadResult[0] == 'success') {
          eventBus.fire(AlbumRefreshEvent(albumKeepAlive: false));
          Map<String, dynamic> maps = {};
          String formatedURL = upyunUploadResult[1];
          String returnUrl = upyunUploadResult[2];
          String pictureKey = upyunUploadResult[3];
          String displayUrl = upyunUploadResult[4];

          await Clipboard.setData(ClipboardData(text: formatedURL));
          maps = {
            'path': path,
            'name': fileName,
            'url': returnUrl, //upyun文件原始地址
            'PBhost': Global.defaultPShost,
            'pictureKey': pictureKey,
            'hostSpecificArgA': displayUrl, //实际展示的是displayUrl
            'hostSpecificArgB': 'test',
            'hostSpecificArgC': 'test',
            'hostSpecificArgD': 'test',
            'hostSpecificArgE': 'test',
          };
          await AlbumSQL.insertData(Global.imageDB!, pBhostToTableName[Global.defaultPShost]!, maps);
          setStatus(task, UploadStatus.completed);
        } else {
          throw Exception('上传失败');
        }
      } else if (defaultPH == 'lsky.pro') {
        var lskyproUploadResult = await LskyproImageUploadUtils.uploadApi(
            path: path,
            name: fileName,
            configMap: configMap,
            onSendProgress: createCallback(path, fileName),
            cancelToken: canceltoken);

        if (lskyproUploadResult[0] == 'success') {
          eventBus.fire(AlbumRefreshEvent(albumKeepAlive: false));
          Map<String, dynamic> maps = {};
          String formatedURL = lskyproUploadResult[1];
          String returnUrl = lskyproUploadResult[2];
          String pictureKey = lskyproUploadResult[3];
          String displayUrl = lskyproUploadResult[4];

          await Clipboard.setData(ClipboardData(text: formatedURL));

          maps = {
            'path': path,
            'name': fileName,
            'url': returnUrl, //原图地址
            'PBhost': Global.defaultPShost,
            'pictureKey': pictureKey,
            'hostSpecificArgA': displayUrl, //实际展示的是缩略图
            'hostSpecificArgB': 'test',
            'hostSpecificArgC': 'test',
            'hostSpecificArgD': 'test',
            'hostSpecificArgE': 'test',
          };
          await AlbumSQL.insertData(Global.imageDB!, pBhostToTableName[Global.defaultPShost]!, maps);
          setStatus(task, UploadStatus.completed);
        } else {
          throw Exception('上传失败');
        }
      } else if (defaultPH == 'sm.ms') {
        var smmsUploadResult = await SmmsImageUploadUtils.uploadApi(
            path: path,
            name: fileName,
            configMap: configMap,
            onSendProgress: createCallback(path, fileName),
            cancelToken: canceltoken);

        if (smmsUploadResult[0] == 'success') {
          eventBus.fire(AlbumRefreshEvent(albumKeepAlive: false));
          Map<String, dynamic> maps = {};
          String formatedURL = smmsUploadResult[1];
          String returnUrl = smmsUploadResult[2];
          String pictureKey = smmsUploadResult[3];

          await Clipboard.setData(ClipboardData(text: formatedURL));
          maps = {
            'path': path,
            'name': fileName,
            'url': returnUrl,
            'PBhost': Global.defaultPShost,
            'pictureKey': pictureKey,
            'hostSpecificArgA': 'test',
            'hostSpecificArgB': 'test',
            'hostSpecificArgC': 'test',
            'hostSpecificArgD': 'test',
            'hostSpecificArgE': 'test',
          };
          await AlbumSQL.insertData(Global.imageDB!, pBhostToTableName[Global.defaultPShost]!, maps);
          setStatus(task, UploadStatus.completed);
        } else {
          throw Exception('上传失败');
        }
      } else if (defaultPH == 'github') {
        maxConcurrentTasks = 1;
        var githubUploadResult = await GithubImageUploadUtils.uploadApi(
          path: path,
          name: fileName,
          configMap: configMap,
          onSendProgress: createCallback(path, fileName),
        );
        if (githubUploadResult[0] == 'success') {
          eventBus.fire(AlbumRefreshEvent(albumKeepAlive: false));
          Map<String, dynamic> maps = {};
          String formatedURL = githubUploadResult[1];
          String returnUrl = githubUploadResult[2];
          String pictureKey = githubUploadResult[3];
          String downloadUrl = githubUploadResult[4];

          await Clipboard.setData(ClipboardData(text: formatedURL));
          maps = {
            'path': path,
            'name': fileName,
            'url': returnUrl,
            'PBhost': Global.defaultPShost,
            'pictureKey': pictureKey,
            'hostSpecificArgA': downloadUrl, //github download url或者自定义域名+路径
            'hostSpecificArgB': 'test',
            'hostSpecificArgC': 'test',
            'hostSpecificArgD': 'test',
            'hostSpecificArgE': 'test',
          };
          await AlbumSQL.insertData(Global.imageDB!, pBhostToTableName[Global.defaultPShost]!, maps);
          setStatus(task, UploadStatus.completed);
        } else {
          throw Exception('上传失败');
        }
      } else if (defaultPH == 'imgur') {
        var imgurUploadResult = await ImgurImageUploadUtils.uploadApi(
            path: path,
            name: fileName,
            configMap: configMap,
            onSendProgress: createCallback(path, fileName),
            cancelToken: canceltoken);

        if (imgurUploadResult[0] == 'success') {
          eventBus.fire(AlbumRefreshEvent(albumKeepAlive: false));
          Map<String, dynamic> maps = {};
          String formatedURL = imgurUploadResult[1];
          String returnUrl = imgurUploadResult[2];
          String pictureKey = imgurUploadResult[3];
          String cdnUrl = imgurUploadResult[4];
          await Clipboard.setData(ClipboardData(text: formatedURL));
          maps = {
            'path': path,
            'name': fileName,
            'url': returnUrl, //imgur文件原始地址
            'PBhost': Global.defaultPShost,
            'pictureKey': pictureKey,
            'hostSpecificArgA': cdnUrl, //实际展示的是imgur cdn url
            'hostSpecificArgB': 'test',
            'hostSpecificArgC': 'test',
            'hostSpecificArgD': 'test',
            'hostSpecificArgE': 'test',
          };
          await AlbumSQL.insertData(Global.imageDB!, pBhostToTableName[Global.defaultPShost]!, maps);
          setStatus(task, UploadStatus.completed);
        } else {
          throw Exception('上传失败');
        }
      } else if (defaultPH == 'ftp') {
        String ftpHost = configMap["ftpHost"];
        String ftpPort = configMap["ftpPort"];
        String ftpUser = configMap["ftpUser"];
        String ftpPassword = configMap["ftpPassword"];
        String ftpType = configMap["ftpType"];
        String isAnonymous = configMap["isAnonymous"].toString();
        String uploadPath = configMap["uploadPath"];
        String? ftpCustomUrl = configMap["ftpCustomUrl"];
        String? ftpWebPath = configMap["ftpWebPath"];

        if (ftpType == 'SFTP') {
          final socket = await SSHSocket.connect(ftpHost, int.parse(ftpPort.toString()));
          final client = SSHClient(
            socket,
            username: ftpUser,
            onPasswordRequest: () {
              return ftpPassword;
            },
          );
          final sftp = await client.sftp();
          if (uploadPath == 'None') {
            uploadPath = '/';
          }
          if (!uploadPath.startsWith('/')) {
            uploadPath = '/$uploadPath';
          }
          if (!uploadPath.endsWith('/')) {
            uploadPath = '$uploadPath/';
          }
          String urlPath = uploadPath + fileName;
          var file = await sftp.open(urlPath, mode: SftpFileOpenMode.create | SftpFileOpenMode.write);
          int fileSize = File(path).lengthSync();
          bool operateDone = false;
          file.write(File(path).openRead().cast(), onProgress: (int sent) {
            getUpload(fileName)?.progress.value = sent / fileSize;
            if (sent == fileSize) {
              operateDone = true;
            }
          });
          while (!operateDone) {
            await Future.delayed(const Duration(milliseconds: 100));
          }
          client.close();
          String returnUrl = '';
          String displayUrl = '';
          if (ftpCustomUrl != null && ftpCustomUrl != 'None') {
            ftpCustomUrl = ftpCustomUrl.replaceAll(RegExp(r'/$'), '');
            if (ftpWebPath != null && ftpWebPath != 'None') {
              ftpWebPath = ftpWebPath.replaceAll(RegExp(r'^/*'), '').replaceAll(RegExp(r'/*$'), '');
              returnUrl = '$ftpCustomUrl/$ftpWebPath/$fileName';
            } else {
              urlPath = urlPath.replaceAll(RegExp(r'^/*'), '');
              returnUrl = '$ftpCustomUrl/$urlPath';
            }
            displayUrl = returnUrl;
          } else {
            returnUrl = 'ftp://$ftpUser:$ftpPassword@$ftpHost:$ftpPort$urlPath';
            displayUrl = returnUrl;
          }
          String pictureKey = jsonEncode(configMap);

          eventBus.fire(AlbumRefreshEvent(albumKeepAlive: false));
          Map<String, dynamic> maps = {};
          String formatedURL = '';
          if (Global.isCopyLink == true) {
            formatedURL = linkGenerateDict[Global.defaultLKformat]!(returnUrl, fileName);
          } else {
            formatedURL = returnUrl;
          }
          var externalCacheDir = await getExternalCacheDirectories();
          String cachePath = externalCacheDir![0].path;
          String ftpCachePath = '$cachePath/ftp';
          if (!await Directory(ftpCachePath).exists()) {
            await Directory(ftpCachePath).create(recursive: true);
          }
          String randomString = randomStringGenerator(5);
          String thumbnailFileName = 'FTP_${randomString}_$fileName';
          var result = await FlutterImageCompress.compressAndGetFile(
            path,
            '$ftpCachePath/$thumbnailFileName',
            quality: 50,
            minWidth: 500,
            minHeight: 500,
          );
          if (result == null) {
            //copy raw file
            await File(path).copy('$ftpCachePath/$thumbnailFileName');
          }
          await Clipboard.setData(ClipboardData(text: formatedURL));
          maps = {
            'path': path,
            'name': fileName,
            'url': returnUrl, //ftp文件原始地址
            'PBhost': Global.defaultPShost,
            'pictureKey': pictureKey,
            'hostSpecificArgA': displayUrl, //实际展示的是displayUrl
            'hostSpecificArgB': ftpHost, //ftp自定义域名
            'hostSpecificArgC': ftpPort, //ftp端口
            'hostSpecificArgD': ftpUser, //ftp用户名
            'hostSpecificArgE': ftpPassword, //ftp密码
            'hostSpecificArgF': ftpType, //ftp类型
            'hostSpecificArgG': isAnonymous, //ftp是否匿名
            'hostSpecificArgH': uploadPath, //ftp路径
            'hostSpecificArgI': '$ftpCachePath/$thumbnailFileName', //缩略图路径
          };
          List letter = 'JKLMNOPQRSTUVWXYZ'.split('');
          for (int i = 0; i < letter.length; i++) {
            maps['hostSpecificArg${letter[i]}'] = 'test';
          }
          await AlbumSQL.insertData(Global.imageDBExtend!, pBhostToTableName[Global.defaultPShost]!, maps);
          setStatus(task, UploadStatus.completed);
        } else if (ftpType == 'FTP') {
          FTPConnect ftpConnect;
          if (isAnonymous == 'true') {
            ftpConnect = FTPConnect(ftpHost, port: int.parse(ftpPort), securityType: SecurityType.FTP);
          } else {
            ftpConnect = FTPConnect(ftpHost,
                port: int.parse(ftpPort), user: ftpUser, pass: ftpPassword, securityType: SecurityType.FTP);
          }
          var connectResult = await ftpConnect.connect();
          if (connectResult == true) {
            if (uploadPath == 'None') {
              uploadPath = '/';
            }
            if (!uploadPath.startsWith('/')) {
              uploadPath = '/$uploadPath';
            }
            if (!uploadPath.endsWith('/')) {
              uploadPath = '$uploadPath/';
            }
            String urlPath = uploadPath + fileName;
            File fileToUpload = File(path);
            await ftpConnect.sendCustomCommand('TYPE I');
            await ftpConnect.changeDirectory(uploadPath);
            bool res = await ftpConnect.uploadFile(
              fileToUpload,
              sRemoteName: fileName,
            );
            if (res == true) {
              String returnUrl = '';
              String displayUrl = '';
              if (ftpCustomUrl != null && ftpCustomUrl != 'None') {
                ftpCustomUrl = ftpCustomUrl.replaceAll(RegExp(r'/$'), '');
                if (ftpWebPath != null && ftpWebPath != 'None') {
                  ftpWebPath = ftpWebPath.replaceAll(RegExp(r'^/*'), '').replaceAll(RegExp(r'/*$'), '');
                  returnUrl = '$ftpCustomUrl/$ftpWebPath/$fileName';
                } else {
                  urlPath = urlPath.replaceAll(RegExp(r'^/*'), '');
                  returnUrl = '$ftpCustomUrl/$urlPath';
                }
                displayUrl = returnUrl;
              } else {
                if (isAnonymous == 'true') {
                  returnUrl = 'ftp://$ftpHost:$ftpPort$urlPath';
                } else if (ftpPassword == 'None') {
                  returnUrl = 'ftp://$ftpUser@$ftpHost:$ftpPort$urlPath';
                } else {
                  returnUrl = 'ftp://$ftpUser:$ftpPassword@$ftpHost:$ftpPort$urlPath';
                }
                displayUrl = returnUrl;
              }
              String pictureKey = jsonEncode(configMap);
              eventBus.fire(AlbumRefreshEvent(albumKeepAlive: false));
              Map<String, dynamic> maps = {};
              String formatedURL = '';
              if (Global.isCopyLink == true) {
                formatedURL = linkGenerateDict[Global.defaultLKformat]!(returnUrl, fileName);
              } else {
                formatedURL = returnUrl;
              }
              ftpConnect.disconnect();
              var externalCacheDir = await getExternalCacheDirectories();
              String cachePath = externalCacheDir![0].path;
              String ftpCachePath = '$cachePath/ftp';
              if (!await Directory(ftpCachePath).exists()) {
                await Directory(ftpCachePath).create(recursive: true);
              }
              String randomString = randomStringGenerator(5);
              String thumbnailFileName = 'FTP_${randomString}_$fileName';
              var result = await FlutterImageCompress.compressAndGetFile(
                path,
                '$ftpCachePath/$thumbnailFileName',
                quality: 50,
                minWidth: 500,
                minHeight: 500,
              );
              if (result == null) {
                await File(path).copy('$ftpCachePath/$thumbnailFileName');
              }
              await Clipboard.setData(ClipboardData(text: formatedURL));
              maps = {
                'path': path,
                'name': fileName,
                'url': returnUrl, //ftp文件原始地址
                'PBhost': Global.defaultPShost,
                'pictureKey': pictureKey,
                'hostSpecificArgA': displayUrl, //实际展示的是displayUrl
                'hostSpecificArgB': ftpHost, //ftp自定义域名
                'hostSpecificArgC': ftpPort, //ftp端口
                'hostSpecificArgD': ftpUser, //ftp用户名
                'hostSpecificArgE': ftpPassword, //ftp密码
                'hostSpecificArgF': ftpType, //ftp类型
                'hostSpecificArgG': isAnonymous, //ftp是否匿名
                'hostSpecificArgH': uploadPath, //ftp路径
                'hostSpecificArgI': '$ftpCachePath/$thumbnailFileName', //缩略图路径
              };

              List letter = 'JKLMNOPQRSTUVWXYZ'.split('');
              for (int i = 0; i < letter.length; i++) {
                maps['hostSpecificArg${letter[i]}'] = 'test';
              }
              await AlbumSQL.insertData(Global.imageDBExtend!, pBhostToTableName[Global.defaultPShost]!, maps);
              setStatus(task, UploadStatus.completed);
            }
          }
        }
      } else if (defaultPH == 'aws') {
        String accessKeyId = configMap['accessKeyId'];
        String secretAccessKey = configMap['secretAccessKey'];
        String bucket = configMap['bucket'];
        String endpoint = configMap['endpoint'];
        String region = configMap['region'];
        String uploadPath = configMap['uploadPath'];
        String customUrl = configMap['customUrl'];
        if (customUrl != "None") {
          if (!customUrl.startsWith('http') && !customUrl.startsWith('https')) {
            customUrl = 'http://$customUrl';
          }
        }

        if (uploadPath != 'None') {
          if (uploadPath.startsWith('/')) {
            uploadPath = uploadPath.substring(1);
          }
          if (!uploadPath.endsWith('/')) {
            uploadPath = '$uploadPath/';
          }
        }
        //云存储的路径
        String urlpath = '';
        if (uploadPath != 'None') {
          urlpath = '$uploadPath$fileName';
        } else {
          urlpath = fileName;
        }

        Minio minio;
        if (region == 'None') {
          minio = Minio(
            endPoint: endpoint,
            accessKey: accessKeyId,
            secretKey: secretAccessKey,
          );
        } else {
          minio = Minio(
            endPoint: endpoint,
            accessKey: accessKeyId,
            secretKey: secretAccessKey,
            region: region,
          );
        }
        int fileSize = File(path).lengthSync();
        Stream<Uint8List> stream = File(path).openRead().cast();

        await minio.putObject(bucket, urlpath, stream, onProgress: (int sent) {
          getUpload(fileName)?.progress.value = sent / fileSize;
        });

        eventBus.fire(AlbumRefreshEvent(albumKeepAlive: false));
        Map<String, dynamic> maps = {};
        String returnUrl = '';
        String displayUrl = '';

        if (customUrl != 'None') {
          if (!customUrl.endsWith('/')) {
            returnUrl = '$customUrl/$urlpath';
            displayUrl = '$customUrl/$urlpath';
          } else {
            returnUrl = '$customUrl$urlpath';
            displayUrl = '$customUrl$urlpath';
          }
        } else {
          if (endpoint.contains('amazonaws.com')) {
            returnUrl = 'https://$bucket.s3.$region.amazonaws.com/$urlpath';
            displayUrl = 'https://$bucket.s3.$region.amazonaws.com/$urlpath';
          } else {
            returnUrl = 'https://$bucket.$endpoint/$urlpath';
            displayUrl = 'https://$bucket.$endpoint/$urlpath';
          }
        }

        String formatedURL = '';
        if (Global.isCopyLink == true) {
          formatedURL = linkGenerateDict[Global.defaultLKformat]!(returnUrl, fileName);
        } else {
          formatedURL = returnUrl;
        }
        await Clipboard.setData(ClipboardData(text: formatedURL));

        Map pictureKeyMap = Map.from(configMap);
        String pictureKey = jsonEncode(pictureKeyMap);
        maps = {
          'path': path,
          'name': fileName,
          'url': returnUrl,
          'PBhost': Global.defaultPShost,
          'pictureKey': pictureKey,
          'hostSpecificArgA': displayUrl,
        };
        List letter = 'BCDEFGHIJKLMNOPQRSTUVWXYZ'.split('');
        for (int i = 0; i < letter.length; i++) {
          maps['hostSpecificArg${letter[i]}'] = 'test';
        }
        await AlbumSQL.insertData(Global.imageDBExtend!, pBhostToTableName[Global.defaultPShost]!, maps);
        setStatus(task, UploadStatus.completed);
      } else if (defaultPH == 'alist') {
        var alistUploadResult = await AlistImageUploadUtils.uploadApi(
          path: path,
          name: fileName,
          configMap: configMap,
          onSendProgress: createCallback(path, fileName),
        );

        if (alistUploadResult[0] == 'success') {
          eventBus.fire(AlbumRefreshEvent(albumKeepAlive: false));
          Map<String, dynamic> maps = {};
          String formatedURL = alistUploadResult[1];
          String returnUrl = alistUploadResult[2];
          String pictureKey = alistUploadResult[3];
          //返回缩略图地址用来在相册显示
          String displayUrl = alistUploadResult[4];
          String hostPicUrl = alistUploadResult[5];

          await Clipboard.setData(ClipboardData(text: formatedURL));

          maps = {
            'path': path,
            'name': fileName,
            'url': returnUrl,
            'PBhost': Global.defaultPShost,
            'pictureKey': pictureKey,
            'hostSpecificArgA': displayUrl,
            'hostSpecificArgB': hostPicUrl,
          };
          List letter = 'CDEFGHIJKLMNOPQRSTUVWXYZ'.split('');
          for (int i = 0; i < letter.length; i++) {
            maps['hostSpecificArg${letter[i]}'] = 'test';
          }
          await AlbumSQL.insertData(Global.imageDBExtend!, pBhostToTableName[Global.defaultPShost]!, maps);
          setStatus(task, UploadStatus.completed);
        } else {
          throw Exception('上传失败');
        }
      } else if (defaultPH == 'webdav') {
        var webdavUploadResult =
            await WebdavImageUploadUtils.uploadApi(path: path, name: fileName, configMap: configMap);
        if (webdavUploadResult[0] == 'success') {
          String formatedURL = webdavUploadResult[1];
          String returnUrl = webdavUploadResult[2];
          String pictureKey = webdavUploadResult[3];
          String displayUrl = webdavUploadResult[4];

          eventBus.fire(AlbumRefreshEvent(albumKeepAlive: false));
          Map<String, dynamic> maps = {};

          await Clipboard.setData(ClipboardData(text: formatedURL));

          maps = {
            'path': path,
            'name': fileName,
            'url': returnUrl,
            'PBhost': Global.defaultPShost,
            'pictureKey': pictureKey,
            'hostSpecificArgA': displayUrl,
          };
          List letter = 'BCDEFGHIJKLMNOPQRSTUVWXYZ'.split('');
          for (int i = 0; i < letter.length; i++) {
            maps['hostSpecificArg${letter[i]}'] = 'test';
          }
          await AlbumSQL.insertData(Global.imageDBExtend!, pBhostToTableName[Global.defaultPShost]!, maps);
          setStatus(task, UploadStatus.completed);
        } else {
          throw 'webdavUploadError';
        }
      }
    } catch (e) {
      FLog.error(
          className: 'UploadTask',
          methodName: 'start',
          text: formatErrorMessage({
            'path': path,
            'fileName': fileName,
          }, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      var task = getUpload(fileName)!;
      if (task.status.value != UploadStatus.canceled && task.status.value != UploadStatus.completed) {
        setStatus(task, UploadStatus.failed);
      }
    }
    runningTasks--;
    if (_queue.isNotEmpty) {
      _startExecution();
    }
  }

  void _startExecution() async {
    if (runningTasks == maxConcurrentTasks || _queue.isEmpty) {
      return;
    }

    while (_queue.isNotEmpty && runningTasks < maxConcurrentTasks) {
      runningTasks++;
      var currentRequest = _queue.removeFirst();
      if (_cache[currentRequest.name]!.status.value.isCompleted) {
        runningTasks--;
        continue;
      }
      upload(currentRequest.path, currentRequest.name, currentRequest.cancelToken);
      await Future.delayed(const Duration(milliseconds: 500), null);
    }
  }

  UploadTask? getUpload(String fileName) {
    return _cache[fileName];
  }

  void setStatus(UploadTask? task, UploadStatus status) {
    if (task != null) {
      task.status.value = status;
    }
  }

  Future<UploadTask?> addUpload(String path, String fileName) async {
    if (path.isNotEmpty && fileName.isNotEmpty) {
      return await _addUploadRequest(UploadRequest(path, fileName));
    }
    return null;
  }

  Future<UploadTask> _addUploadRequest(UploadRequest uploadRequest) async {
    if (_cache[uploadRequest.name] != null) {
      if ((_cache[uploadRequest.name]!.status.value == UploadStatus.completed ||
              _cache[uploadRequest.name]!.status.value == UploadStatus.uploading) &&
          _cache[uploadRequest.name]!.request == uploadRequest) {
        return _cache[uploadRequest.name]!;
      } else {
        _queue.remove(_cache[uploadRequest.name]);
      }
    }
    _queue.add(UploadRequest(uploadRequest.path, uploadRequest.name));
    var task = UploadTask(_queue.last);
    _cache[uploadRequest.name] = task;
    _startExecution();
    return task;
  }

  Future<void> pauseUpload(String path, String fileName) async {
    var task = getUpload(fileName);
    if (task != null) {
      setStatus(task, UploadStatus.paused);
      _queue.remove(task.request);
      task.request.cancelToken.cancel();
    }
  }

  Future<void> cancelUpload(String path, String fileName) async {
    var task = getUpload(fileName);
    if (task != null) {
      setStatus(task, UploadStatus.canceled);
      _queue.remove(task.request);
      task.request.cancelToken.cancel();
    }
  }

  Future<void> resumeUpload(String path, String fileName) async {
    var task = getUpload(fileName);
    if (task != null) {
      setStatus(task, UploadStatus.uploading);
      task.request.cancelToken = CancelToken();
      _queue.add(task.request);
    }
    _startExecution();
  }

  Future<void> removeUpload(String path, String fileName) async {
    await cancelUpload(path, fileName);
    _cache.remove(path);
  }

  Future<UploadStatus> whenUploadComplete(String path, String fileName,
      {Duration timeout = const Duration(hours: 2)}) async {
    UploadTask? task = getUpload(fileName);

    if (task != null) {
      return task.whenUploadComplete(timeout: timeout);
    } else {
      return Future.error("Upload not found");
    }
  }

  List<UploadTask> getALlUpload() {
    return _cache.values as List<UploadTask>;
  }

  Future<void> addBatchUploads(List<String> paths, List<String> names) async {
    for (var i = 0; i < paths.length; i++) {
      await addUpload(paths[i], names[i]);
    }
  }

  List<UploadTask?> getBatchUploads(List<String> paths, List<String> names) {
    return names.map((e) => _cache[e]).toList();
  }

  Future<void> pauseBatchUploads(List<String> paths, List<String> names) async {
    for (var i = 0; i < paths.length; i++) {
      await pauseUpload(paths[i], names[i]);
    }
  }

  Future<void> cancelBatchUploads(List<String> paths, List<String> names) async {
    for (var i = 0; i < paths.length; i++) {
      await cancelUpload(paths[i], names[i]);
    }
  }

  Future<void> resumeBatchUploads(List<String> paths, List<String> names) async {
    for (var i = 0; i < paths.length; i++) {
      await resumeUpload(paths[i], names[i]);
    }
  }

  ValueNotifier<double> getBatchUploadProgress(List<String> paths, List<String> names) {
    ValueNotifier<double> progress = ValueNotifier(0);
    var total = paths.length;

    if (total == 0) {
      return progress;
    }

    if (total == 1) {
      return getUpload(names.first)?.progress ?? progress;
    }

    var progressMap = <String, double>{};

    for (var i = 0; i < paths.length; i++) {
      UploadTask? task = getUpload(names[i]);
      if (task != null) {
        progressMap[paths[i]] = 0.0;
        if (task.status.value.isCompleted) {
          progressMap[paths[i]] = 1.0;
          progress.value = progressMap.values.sum / total;
        }

        Null Function() progressListener;
        progressListener = () {
          progressMap[paths[i]] = task.progress.value;
          progress.value = progressMap.values.sum / total;
        };

        task.progress.addListener(progressListener);
        dynamic listener;
        listener = () {
          if (task.status.value.isCompleted) {
            progressMap[paths[i]] = 1.0;
            progress.value = progressMap.values.sum / total;
            task.progress.removeListener(progressListener);
            task.status.removeListener(listener);
          }
        };
        task.status.addListener(listener);
      } else {
        total--;
      }
    }
    return progress;
  }

  Future<List<UploadTask?>?> whenBatchUploadsComplete(List<String> paths, List<String> names,
      {Duration timeout = const Duration(hours: 2)}) async {
    var completer = Completer<List<UploadTask?>?>();
    var completed = 0;
    var total = paths.length;
    for (var i = 0; i < paths.length; i++) {
      UploadTask? task = getUpload(names[i]);

      if (task != null) {
        if (task.status.value.isCompleted) {
          completed++;

          if (completed == total) {
            completer.complete(getBatchUploads(paths, names));
          }
        }

        dynamic listener;
        listener = () {
          if (task.status.value.isCompleted) {
            completed++;

            if (completed == total) {
              completer.complete(getBatchUploads(paths, names));
              task.status.removeListener(listener);
            }
          }
        };

        task.status.addListener(listener);
      } else {
        total--;

        if (total == 0) {
          completer.complete(null);
        }
      }
    }

    return completer.future.timeout(timeout);
  }
}
