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
  'gitee': 'gitee_config',
  'weibo': 'weibo_config',
  'ftp': 'ftp_config',
  'aws': 'aws_config',
};

Map<String, Function> deleteFunc = {
  'lskypro': LskyproImageUploadUtils.deleteApi,
  'smms': SmmsImageUploadUtils.deleteApi,
  'github': GithubImageUploadUtils.deleteApi,
  'imgur': ImgurImageUploadUtils.deleteApi,
  'qiniu': QiniuImageUploadUtils.deleteApi,
  'tencent': TencentImageUploadUtils.deleteApi,
  'aliyun': AliyunImageUploadUtils.deleteApi,
  'upyun': UpyunImageUploadUtils.deleteApi,
  'PBhostExtend1': FTPImageUploadUtils.deleteApi,//FTP
  'PBhostExtend2': AwsImageUploadUtils.deleteApi,//AWS
};

//获取图床配置文件
Future<File> get _localFile async {
  final directory = await getApplicationDocumentsDirectory();
  String defaultConfig = await Global.getShowedPBhost();
  String defaultUser = await Global.getUser();
  if (defaultConfig == 'lskypro') {
    defaultConfig = 'lsky.pro';
  } else if (defaultConfig == 'smms') {
    defaultConfig = 'sm.ms';
  } else if (defaultConfig == 'PBhostExtend1') {
    defaultConfig = 'ftp';
  } else if (defaultConfig == 'PBhostExtend2') {
    defaultConfig = 'aws';
  }
  return File(
      '${directory.path}/${defaultUser}_${pdconfig[defaultConfig]}.txt');
}

//读取图床配置文件
Future<String> readHostConfig() async {
  try {
    final file = await _localFile;
    String contents = await file.readAsString();
    return contents;
  } catch (e) {
    FLog.error(
        className: "Deleter",
        methodName: "readHostConfig",
        text: formatErrorMessage({}, e.toString()),
        dataLogType: DataLogType.ERRORS.toString());
    return "Error";
  }
}

deleterentry(Map deleteConfig) async {
  String configData = await readHostConfig();
  if (configData == 'Error') {
    return ["Error"];
  }
  Map configMap = jsonDecode(configData);

  String defaultConfig = await Global.getShowedPBhost();
  try {
    var result = await deleteFunc[defaultConfig]!(
        deleteMap: deleteConfig, configMap: configMap);
    return result;
  } catch (e) {
    FLog.error(
        className: "Deleter",
        methodName: "deleterentry",
        text: formatErrorMessage({
        }, e.toString()),
        dataLogType: DataLogType.ERRORS.toString());
    return ["Error"];
  }
}
