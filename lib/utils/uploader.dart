import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

import 'package:horopic/api/api.dart';
import 'package:horopic/utils/global.dart';
import 'package:horopic/utils/common_functions.dart';

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

  return ensureFileExists(File('${directory.path}/${defaultUser}_${getpdconfig(defaultConfig)}.txt'));
}

//读取图床配置文件
Future<String> readPictureHostConfig() async {
  return (await _localFile).readAsString();
}

uploaderentry({required String path, required String name}) async {
  try {
    String configData = await readPictureHostConfig();
    if (configData == '') return ["failed"];
    Map configMap = jsonDecode(configData);
    String defaultConfig = await Global.getPShost();
    return await uploadFunc[defaultConfig]!(path: path, name: name, configMap: configMap);
  } catch (e) {
    return ["failed"];
  }
}
