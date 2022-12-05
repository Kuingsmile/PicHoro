import 'dart:io';
import 'dart:convert';
import 'package:f_logs/f_logs.dart';
import 'package:path_provider/path_provider.dart';

import 'package:horopic/api/api.dart';
import 'package:horopic/utils/global.dart';
import 'package:horopic/utils/common_functions.dart';

//默认图床参数和配置文件名对应关系
Map<String, String> pdconfig = {
  'lsky.pro': 'host_config',
  'sm.ms': 'smms_config',
  'imgur': 'imgur_config',
  'upyun': 'upyun_config',
  'qiniu': 'qiniu_config',
  'aliyun': 'aliyun_config',
  'tencent': 'tencent_config',
  'github': 'github_config',
  'ftp': 'ftp_config',
  'aws': 'aws_config',
  'alist': 'alist_config',
  'webdav': 'webdav_config',
};

Map<String, Function> uploadFunc = {
  'lsky.pro': LskyproImageUploadUtils.uploadApi,
  'sm.ms': SmmsImageUploadUtils.uploadApi,
  'github': GithubImageUploadUtils.uploadApi,
  'imgur': ImgurImageUploadUtils.uploadApi,
  'qiniu': QiniuImageUploadUtils.uploadApi,
  'tencent': TencentImageUploadUtils.uploadApi,
  'aliyun': AliyunImageUploadUtils.uploadApi,
  'upyun': UpyunImageUploadUtils.uploadApi,
  'ftp': FTPImageUploadUtils.uploadApi,
  'aws': AwsImageUploadUtils.uploadApi,
  'alist': AlistImageUploadUtils.uploadApi,
  'webdav': WebdavImageUploadUtils.uploadApi,
};

//获取图床配置文件
Future<File> get _localFile async {
  final directory = await getApplicationDocumentsDirectory();
  String defaultConfig = await Global.getPShost();
  String defaultUser = await Global.getUser();

  return File(
      '${directory.path}/${defaultUser}_${pdconfig[defaultConfig]}.txt');
}

//读取图床配置文件
Future<String> readPictureHostConfig() async {
  try {
    final file = await _localFile;
    String contents = await file.readAsString();
    return contents;
  } catch (e) {
    FLog.error(
        className: 'Uploader',
        methodName: 'readPictureHostConfig',
        text: formatErrorMessage({}, e.toString()),
        dataLogType: DataLogType.ERRORS.toString());
    return "Error";
  }
}

uploaderentry({required String path, required String name}) async {
  String configData = await readPictureHostConfig();
  if (configData == 'Error') {
    return ["Error"];
  }
  Map configMap = jsonDecode(configData);
  String defaultConfig = await Global.getPShost();
  try {
    var result = await uploadFunc[defaultConfig]!(
        path: path, name: name, configMap: configMap);
    return result;
  } catch (e) {
    FLog.error(
        className: 'Uploader',
        methodName: 'uploaderentry',
        text: formatErrorMessage({'path': path, 'name': name}, e.toString()),
        dataLogType: DataLogType.ERRORS.toString());
    return ["Error"];
  }
}
