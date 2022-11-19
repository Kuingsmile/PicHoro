import 'dart:io';
import 'dart:convert';

import 'package:path_provider/path_provider.dart';

import 'package:horopic/album/album_sql.dart';
import 'package:horopic/utils/global.dart';
import 'package:horopic/picture_host_configure/configure_store/configure_template.dart';

class ConfigureStoreFile {
  static final ConfigureStoreFile _instance = ConfigureStoreFile._internal();
  factory ConfigureStoreFile() => _instance;
  ConfigureStoreFile._internal();
  String alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

  Map initConigureStoreMap(String psHost) {
    Map<String, Map<String, String>> configureStoreMap = {};
    Map<String, String> template =
        ConfigureTemplate.psHostNameToTemplate[psHost]!;
    for (int i = 0; i < alphabet.length; i++) {
      configureStoreMap[alphabet[i]] = template;
    }
    return configureStoreMap;
  }

  Future<String> localConfigureFilePath(String psHost) async {
    String defaultUser = await Global.getUser();
    String configureFileName = '${defaultUser}_${psHost}_configure_store.json';
    String appDocDir = (await getApplicationDocumentsDirectory()).path;
    String configureFilePath = '$appDocDir/$configureFileName';
    return configureFilePath;
  }

  Future<void> generateConfigureFile() async {
    List allPBhost = pBhostToTableName.keys.toList();
    for (var i = 0; i < allPBhost.length; i++) {
      String configureFilePath = await localConfigureFilePath(allPBhost[i]);
      if (!File(configureFilePath).existsSync()) {
        Map configureStoreMap = initConigureStoreMap(allPBhost[i]);
        String configureStoreMapJson = json.encode(configureStoreMap);
        File(configureFilePath).writeAsStringSync(configureStoreMapJson);
      }
    }
  }

  readConfigureFile(String psHost) async {
    String configureFilePath = await localConfigureFilePath(psHost);
    String configureStoreMapJson = File(configureFilePath).readAsStringSync();
    Map configureStoreMap = json.decode(configureStoreMapJson);
    return configureStoreMap;
  }

  Future<void> resetConfigureFile(String psHost) async {
    String configureFilePath = await localConfigureFilePath(psHost);
    Map configureStoreMap = initConigureStoreMap(psHost);
    String configureStoreMapJson = json.encode(configureStoreMap);
    File(configureFilePath).writeAsStringSync(configureStoreMapJson);
  }

  Future<void> resetConfigureFileKey(String psHost, String key) async {
    String configureFilePath = await localConfigureFilePath(psHost);
    String configureStoreMapJson = File(configureFilePath).readAsStringSync();
    Map configureStoreMap = json.decode(configureStoreMapJson);
    Map<String, String> template =
        ConfigureTemplate.psHostNameToTemplate[psHost]!;
    configureStoreMap[key] = template;
    configureStoreMapJson = json.encode(configureStoreMap);
    File(configureFilePath).writeAsStringSync(configureStoreMapJson);
  }

  Future<void> updateConfigureFile(String psHost, Map configureStoreMap) async {
    String configureFilePath = await localConfigureFilePath(psHost);
    String configureStoreMapJson = json.encode(configureStoreMap);
    File(configureFilePath).writeAsStringSync(configureStoreMapJson);
  }

  Future<void> updateConfigureFileKey(
      String psHost, String key, Map value) async {
    String configureFilePath = await localConfigureFilePath(psHost);
    String configureStoreMapJson = File(configureFilePath).readAsStringSync();
    Map configureStoreMap = json.decode(configureStoreMapJson);
    configureStoreMap[key] = value;
    configureStoreMapJson = json.encode(configureStoreMap);
    File(configureFilePath).writeAsStringSync(configureStoreMapJson);
  }

  Future<bool> checkIfAllUndetermined(String psHost) async {
    Map configureStoreMap = await readConfigureFile(psHost);
    List keyList = configureStoreMap[alphabet[0]]!.keys.toList();
    for (var i = 0; i < alphabet.length; i++) {
      for (var j = 0; j < keyList.length; j++) {
        if (configureStoreMap[alphabet[i]]![keyList[j]] !=
            ConfigureTemplate.placeholder) {
          return false;
        }
      }
    }
    return true;
  }

  bool checkIfOneUndetermined(Map configureStoreMapOne) {
    List keyList = configureStoreMapOne.keys.toList();
    for (var i = 0; i < keyList.length; i++) {
      if (configureStoreMapOne[keyList[i]] != ConfigureTemplate.placeholder) {
        return false;
      }
    }
    return true;
  }

  Future<String> exportConfigureToJson(String psHost) async {
    Map configureStoreMap = await readConfigureFile(psHost);
    List keyList = configureStoreMap[alphabet[0]]!.keys.toList();
    Map configureStoreMapExport = {};
    for (var i = 0; i < alphabet.length; i++) {
      Map configureStoreMapOne = {};
      for (var j = 0; j < keyList.length; j++) {
        if (configureStoreMap[alphabet[i]]![keyList[j]] !=
            ConfigureTemplate.placeholder) {
          configureStoreMapOne[keyList[j]] =
              configureStoreMap[alphabet[i]]![keyList[j]];
        }
      }
      if (!checkIfOneUndetermined(configureStoreMapOne)) {
        configureStoreMapExport[alphabet[i]] = configureStoreMapOne;
      }
    }
    String configureStoreMapExportJson = json.encode(configureStoreMapExport);
    return configureStoreMapExportJson;
  }

  Future<String> exportConfigureKeyToJson(String psHost, String key) async {
    Map configureStoreMap = await readConfigureFile(psHost);
    Map configureStoreMapOne = configureStoreMap[key]!;
    List keyList = configureStoreMapOne.keys.toList();
    for (var i = 0; i < keyList.length; i++) {
      if (configureStoreMapOne[keyList[i]] == ConfigureTemplate.placeholder) {
        configureStoreMapOne.remove(keyList[i]);
      }
    }
    Map result = {
      key: configureStoreMapOne,
    };
    String configureStoreMapExportJson = json.encode(result);
    return configureStoreMapExportJson;
  }

  Future<void> importConfigureFromJson(
      String psHost, String configureStoreMapImportJson) async {
    Map configureStoreMap = await readConfigureFile(psHost);
    Map configureStoreMapImport = json.decode(configureStoreMapImportJson);
    List keyList = configureStoreMap[alphabet[0]]!.keys.toList();
    for (var i = 0; i < alphabet.length; i++) {
      if (configureStoreMapImport[alphabet[i]] != null) {
        for (var j = 0; j < keyList.length; j++) {
          if (configureStoreMapImport[alphabet[i]]![keyList[j]] != null) {
            configureStoreMap[alphabet[i]]![keyList[j]] =
                configureStoreMapImport[alphabet[i]]![keyList[j]];
          } else {
            configureStoreMap[alphabet[i]]![keyList[j]] =
                ConfigureTemplate.placeholder;
          }
        }
      }
    }
    await updateConfigureFile(psHost, configureStoreMap);
  }
}
