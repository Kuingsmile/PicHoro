import 'package:horopic/utils/global.dart';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:horopic/api/lskypro.dart';

//默认图床参数和配置文件名对应关系
Map<String, String> pd_config = {
  'lsky.pro': 'host_config',
};

//获取图床配置文件
Future<File> get _localFile async {
  final directory = await getApplicationDocumentsDirectory();
  String defaultConfig = await Global.getPShost();
  String defaultUser = await Global.getUser();

  //从本地读取
  return File(
      '${directory.path}/${defaultUser}_${pd_config[defaultConfig]}.txt');
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

uploader_entry({required String path, required String name}) async {
  String configData = await readHostConfig();
  if (configData == 'Error') {
    return ["Error"];
  }
  Map configMap = jsonDecode(configData);
  //获取用户设置的默认图床
  String defaultConfig = await Global.getPShost();
  //调用对应图床的上传接口

  //lsky.pro
  if (defaultConfig == 'lsky.pro') {
    try {
      var result = await LskyproImageUploadUtils()
          .uploadApi(path: path, name: name, configMap: configMap);
      return result;
    } catch (e) {
      return [e.toString()];
    }
  }
}
