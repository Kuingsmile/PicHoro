import 'package:horopic/utils/global.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'package:external_path/external_path.dart';

/// 所有的数据库的图床表名
List<String> allPBhost = [
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

/// 扩展数据库的图床表名
List<String> allPBhostExtend = [for (int i = 1; i <= 50; i++) 'PBhostExtend$i'];

/// 重要，默认上传图床名和数据库表名对应关系
Map<String, String> hostToTableNameMap = {
  "lsky.pro": "lskypro",
  "sm.ms": "smms",
  'github': 'github',
  'imgur': 'imgur',
  'upyun': 'upyun',
  'qiniu': 'qiniu',
  'aliyun': 'aliyun',
  'tencent': 'tencent',
  'ftp': 'PBhostExtend1',
  'aws': 'PBhostExtend2',
  'alist': 'PBhostExtend3',
  'webdav': 'PBhostExtend4',
};

List<String> tableKeysList = [
  'path',
  'name',
  'url',
  'PBhost',
  'pictureKey',
  for (int i = 0; i < 26; i++) 'hostSpecificArg${String.fromCharCode(65 + i)}',
];

class AlbumSQL {
  static Future<Database> getDatabase() async {
    String currentUserName = await Global.getUser();
    return await initDB(currentUserName);
  }

  static initDB(String username) async {
    var externalDirectoryPath = await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_DOWNLOADS);
    var persistPath = '$externalDirectoryPath/PicHoro/Database';
    if (!await Directory(persistPath).exists()) {
      await Directory(persistPath).create(recursive: true);
    }
    if (username == '' || username == ' ') {
      username = 'null';
    }
    var dbPath = join(persistPath, '${username}_album.db');
    Database newdb = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (Database db, int version) async {
        for (var i = 0; i < allPBhost.length; i++) {
          await db.execute('''
            CREATE TABLE ${allPBhost[i]} (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              path TEXT,
              name TEXT,
              url TEXT,
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

  static Future<Database> getExtendDatabase() async {
    String currentUserName = await Global.getUser();
    return await initExtendDB(currentUserName);
  }

  static initExtendDB(String username) async {
    var externalDirectoryPath = await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_DOWNLOADS);
    var persistPath = '$externalDirectoryPath/PicHoro/Database';
    if (!await Directory(persistPath).exists()) {
      await Directory(persistPath).create(recursive: true);
    }
    if (username == '' || username == ' ') {
      username = 'null';
    }
    var dbPath = join(persistPath, '${username}_album_extend.db');
    Database newdb = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (Database db, int version) async {
        for (var i = 0; i < allPBhostExtend.length; i++) {
          await db.execute('''
            CREATE TABLE ${allPBhostExtend[i]} (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              path TEXT,
              name TEXT,
              url TEXT,
              PBhost TEXT,
              pictureKey TEXT,
              hostSpecificArgA TEXT,
              hostSpecificArgB TEXT,
              hostSpecificArgC TEXT,
              hostSpecificArgD TEXT,
              hostSpecificArgE TEXT,
              hostSpecificArgF TEXT,
              hostSpecificArgG TEXT,
              hostSpecificArgH TEXT,
              hostSpecificArgI TEXT,
              hostSpecificArgJ TEXT,
              hostSpecificArgK TEXT,
              hostSpecificArgL TEXT,
              hostSpecificArgM TEXT,
              hostSpecificArgN TEXT,
              hostSpecificArgO TEXT,
              hostSpecificArgP TEXT,
              hostSpecificArgQ TEXT,
              hostSpecificArgR TEXT,
              hostSpecificArgS TEXT,
              hostSpecificArgT TEXT,
              hostSpecificArgU TEXT,
              hostSpecificArgV TEXT,
              hostSpecificArgW TEXT,
              hostSpecificArgX TEXT,
              hostSpecificArgY TEXT,
              hostSpecificArgZ TEXT
            )
            ''');
        }
      },
    );
    return newdb;
  }

  static isTableExist(Database db, String tableName) async {
    var res = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table' AND name='$tableName'");
    return res.isNotEmpty;
  }

  static createTable(Database db, String tableName) async {
    await db.execute(
        "CREATE TABLE $tableName (id INTEGER PRIMARY KEY AUTOINCREMENT,path TEXT,name TEXT,url TEXT,PBhost TEXT,pictureKey TEXT,hostSpecificArgA TEXT,hostSpecificArgB TEXT,hostSpecificArgC TEXT,hostSpecificArgD TEXT,hostSpecificArgE TEXT)");
  }

  static insertData(Database db, String tableName, Map<String, dynamic> data) async {
    return await db.insert(tableName, data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static deleteData(Database db, String tableName, int id) async {
    return await db.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }

  static Future<List<Map<String, dynamic>>> queryData(Database db, String tableName, int id) async {
    return await db.query(tableName, where: 'id = ?', whereArgs: [id]);
  }

  static Future<List<Map<String, dynamic>>> queryTableData(Database db, String tableName) async {
    return await db.query(tableName);
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
    List<Map<String, dynamic>> maps =
        await db.query(tableName, where: where, whereArgs: whereargs, orderBy: orderBy, limit: limit, offset: offset);
    return maps;
  }

  static getAllTableData(Database db, String key) async {
    Map<String, dynamic> allTableData = {};

    for (var i = 0; i < allPBhost.length; i++) {
      List<Map<String, dynamic>> maps = await db.query(allPBhost[i]);
      List keyData = [];
      for (var j = 0; j < maps.length; j++) {
        keyData.add(maps[j][key]);
      }
      allTableData[allPBhost[i]] = keyData;
    }

    return allTableData;
  }

  static getAllTableDataExtend(Database db, String key) async {
    Map<String, dynamic> allTableData = {};

    for (var i = 0; i < allPBhostExtend.length; i++) {
      List<Map<String, dynamic>> maps = await db.query(allPBhostExtend[i]);
      List keyData = [];
      for (var j = 0; j < maps.length; j++) {
        keyData.add(maps[j][key]);
      }
      allTableData[allPBhostExtend[i]] = keyData;
    }

    return allTableData;
  }

  static emptyAllTable(Database db) async {
    for (var i = 0; i < allPBhost.length; i++) {
      await db.delete(allPBhost[i]);
    }
  }

  static emptyAllTableExtend(Database db) async {
    for (var i = 0; i < allPBhostExtend.length; i++) {
      await db.delete(allPBhostExtend[i]);
    }
  }

  static deleteTable(Database db, String tableName) async {
    await db.delete(tableName);
  }

  static close(Database db) async {
    await db.close();
  }
}
