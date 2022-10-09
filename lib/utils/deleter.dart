import 'package:horopic/utils/global.dart';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:horopic/api/lskypro.dart';
import 'package:horopic/api/smms.dart';

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
  'lsky.pro': LskyproImageUploadUtils.deleteApi,
  'sm.ms': SmmsImageUploadUtils.deleteApi,
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
Future<String> readHostConfig() async {
  try {
    final file = await _localFile;
    String contents = await file.readAsString();
    return contents;
  } catch (e) {
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
  String defaultConfig = await Global.getPShost();

  //调用对应图床的上传接口
  try {
    var result = await deleteFunc[defaultConfig]!(
        deleteMap: deleteConfig, configMap: configMap);
    return result;
  } catch (e) {
    return ["Error"];
  }
}