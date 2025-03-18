import 'dart:convert';
import 'dart:io';

import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/utils/global.dart';
import 'package:path_provider/path_provider.dart';

class BaseManageApi {
  /// override this
  String configFileName() => 'alist_config.txt';

  Future<File> localFile() async {
    final path = await _localPath();
    String defaultUser = Global.getUser();
    return ensureFileExists(File('$path/${defaultUser}_${configFileName()}'));
  }

  Future<String> _localPath() async {
    return (await getApplicationDocumentsDirectory()).path;
  }

  Future<String> readCurrentConfig() async {
    try {
      final file = await localFile();
      return await file.readAsString();
    } catch (e) {
      return "Error";
    }
  }

  Future<Map> getConfigMap() async {
    String configStr = await readCurrentConfig();
    if (configStr == '') {
      return {};
    }
    Map<String, dynamic> configMap = json.decode(configStr);
    return configMap;
  }
}
