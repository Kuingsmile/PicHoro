import 'dart:io';
import 'dart:convert';

import 'package:f_logs/f_logs.dart';
import 'package:path_provider/path_provider.dart';

import 'package:horopic/api/aliyun_api.dart';
import 'package:horopic/api/lskypro_api.dart';
import 'package:horopic/api/smms_api.dart';
import 'package:horopic/api/github_api.dart';
import 'package:horopic/api/imgur_api.dart';
import 'package:horopic/api/qiniu_api.dart';
import 'package:horopic/api/tencent_api.dart';
import 'package:horopic/api/upyun_api.dart';
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
  //获取用户设置的默认图床
  String defaultConfig = await Global.getShowedPBhost();
  //调用对应图床的删除接口
  try {
    var result = await deleteFunc[defaultConfig]!(
        deleteMap: deleteConfig, configMap: configMap);

    return result;
  } catch (e) {
    FLog.error(
        className: "Deleter",
        methodName: "deleterentry",
        text: formatErrorMessage({
          'deleteConfig': deleteConfig,
        }, e.toString()),
        dataLogType: DataLogType.ERRORS.toString());
    return ["Error"];
  }
}
