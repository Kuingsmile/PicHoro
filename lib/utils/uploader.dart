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
  return File('${directory.path}/${pd_config[Global.defaultPShost]}.txt');
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
    return "Error";
  }
  Map configMap = jsonDecode(configData);
  if (Global.defaultPShost == 'lsky.pro') {
    var result = await LskyproImageUploadUtils()
        .uploadApi(path: path, name: name, configMap: configMap);
    return result;
  }
}
