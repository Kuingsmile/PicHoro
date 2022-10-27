import 'package:horopic/utils/global.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'package:external_path/external_path.dart';

//所有的数据库的图床表名
List<String> allPBhostUpDown = [
  'lskypro', //兰空图床
  'smms', //sm.ms图床
  'imgur', //imgur图床
  'upyun', //又拍云图床
  'qiniu', //七牛图床
  'aliyun', //阿里云图床
  'tencent', //腾讯云图床
  'github', //github图床
  'gitee', //gitee图床
  'weibo', //微博图床
  'PBhost1', //自定义图床1
  'PBhost2', //自定义图床2
  'PBhost3', //自定义图床3
];
// XXX 重要，默认上传图床名和数据库表名对应关系
Map<String, String> PBhostToTableNameUpDown = {
  "lsky.pro": "lskypro",
  "sm.ms": "smms",
  'github': 'github',
  'gitee': 'gitee',
  'weibo': 'weibo',
  'imgur': 'imgur',
  'upyun': 'upyun',
  'qiniu': 'qiniu',
  'aliyun': 'aliyun',
  'tencent': 'tencent',
  'PBhost1': 'PBhost1',
  'PBhost2': 'PBhost2',
  'PBhost3': 'PBhost3',
};

List<String> tableKeysListUpDown = [
  'path',
  'name',
  'url',
  'saveTime',
  'PBhost',
  'pictureKey',
  'hostSpecificArgA',
  'hostSpecificArgB',
  'hostSpecificArgC',
  'hostSpecificArgD',
  'hostSpecificArgE',
];

class PSHostSQL {
  static getUploadDatabase() async {
    String currentUserName = await Global.getUser();
    Database db = await initUpDownDB(currentUserName, 'upload');
    return db;
  }

  static getDownloadDatabase() async {
    String currentUserName = await Global.getUser();
    Database db = await initUpDownDB(currentUserName, 'download');
    return db;
  }

  static initUpDownDB(String username,String type) async {
    var externalDirectoryPath =
        await ExternalPath.getExternalStoragePublicDirectory(
            ExternalPath.DIRECTORY_DOWNLOADS);
    var persistPath = '$externalDirectoryPath/PicHoro/Database';
    if (!await Directory(persistPath).exists()) {
      await Directory(persistPath).create(recursive: true);
    }
    var dbPath = join(persistPath, '${username}_$type.db');
    Database newdb = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (Database db, int version) async {
        for (var i = 0; i < allPBhostUpDown.length; i++) {
          await db.execute('''
            CREATE TABLE ${allPBhostUpDown[i]} (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              path TEXT,
              name TEXT,
              url TEXT,
              saveTime TEXT,
              PBhost TEXT,
              pictureKey TEXT,
              hostSpecificArgA TEXT,
              hostSpecificArgB TEXT,
              hostSpecificArgC TEXT,
              hostSpecificArgD TEXT,
              hostSpecificArgE TEXT
            )
            ''');
        }
      },
    );
    return newdb;
  }

  static isTableExist(Database db, String tableName) async {
    var res = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='$tableName'");
    return res.isNotEmpty;
  }

  static createTable(Database db, String tableName) async {
    await db.execute(
        "CREATE TABLE $tableName (id INTEGER PRIMARY KEY AUTOINCREMENT,path TEXT,name TEXT,url TEXT,saveTime TEXT,PBhost TEXT,pictureKey TEXT,hostSpecificArgA TEXT,hostSpecificArgB TEXT,hostSpecificArgC TEXT,hostSpecificArgD TEXT,hostSpecificArgE TEXT)");
  }

  static insertData(
      Database db, String tableName, Map<String, dynamic> data) async {
    int id = await db.insert(tableName, data,
        conflictAlgorithm: ConflictAlgorithm.replace);
    return id;
  }

  static deleteData(Database db, String tableName, int id) async {
    int count = await db.delete(tableName, where: 'id = ?', whereArgs: [id]);
    return count;
  }

  static queryData(Database db, String tableName, int id) async {
    List<Map<String, dynamic>> maps =
        await db.query(tableName, where: 'id = ?', whereArgs: [id]);
    return maps;
  }

  static queryTableData(Database db, String tableName) async {
    List<Map<String, dynamic>> maps = await db.query(tableName);
    return maps;
  }

  static queryDataByLimit(
    Database db,
    String tableName,
    String? where,
    List<dynamic>? whereargs, {
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    List<Map<String, dynamic>> maps = await db.query(tableName,
        where: where,
        whereArgs: whereargs,
        orderBy: orderBy,
        limit: limit,
        offset: offset);
    return maps;
  }

  static getAllTableData(Database db, String key) async {
    Map<String, dynamic> allTableData = {};

    for (var i = 0; i < allPBhostUpDown.length; i++) {
      List<Map<String, dynamic>> maps = await db.query(allPBhostUpDown[i]);
      List keyData = [];
      for (var j = 0; j < maps.length; j++) {
        keyData.add(maps[j][key]);
      }
      allTableData[allPBhostUpDown[i]] = keyData;
    }

    return allTableData;
  }

  static emptyAllTable(Database db) async {
    for (var i = 0; i < allPBhostUpDown.length; i++) {
      await db.delete(allPBhostUpDown[i]);
    }
  }

  static deleteTable(Database db, String tableName) async {
    await db.delete(tableName);
  }

  static close(Database db) async {
    await db.close();
  }
}
