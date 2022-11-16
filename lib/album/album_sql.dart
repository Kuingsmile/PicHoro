import 'package:horopic/utils/global.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'package:external_path/external_path.dart';

//所有的数据库的图床表名
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

//扩展数据库的图床表名
List<String> allPBhostExtend = [
  'PBhostExtend1', //扩展图床1
  'PBhostExtend2', //扩展图床2
  'PBhostExtend3', //扩展图床3
  'PBhostExtend4', //扩展图床4
  'PBhostExtend5', //扩展图床5
  'PBhostExtend6', //扩展图床6
  'PBhostExtend7', //扩展图床7
  'PBhostExtend8', //扩展图床8
  'PBhostExtend9', //扩展图床9
  'PBhostExtend10', //扩展图床10
  'PBhostExtend11', //扩展图床11
  'PBhostExtend12', //扩展图床12
  'PBhostExtend13', //扩展图床13
  'PBhostExtend14', //扩展图床14
  'PBhostExtend15', //扩展图床15
  'PBhostExtend16', //扩展图床16
  'PBhostExtend17', //扩展图床17
  'PBhostExtend18', //扩展图床18
  'PBhostExtend19', //扩展图床19
  'PBhostExtend20', //扩展图床20
  'PBhostExtend21', //扩展图床21
  'PBhostExtend22', //扩展图床22
  'PBhostExtend23', //扩展图床23
  'PBhostExtend24', //扩展图床24
  'PBhostExtend25', //扩展图床25
  'PBhostExtend26', //扩展图床26
  'PBhostExtend27', //扩展图床27
  'PBhostExtend28', //扩展图床28
  'PBhostExtend29', //扩展图床29
  'PBhostExtend30', //扩展图床30
  'PBhostExtend31', //扩展图床31
  'PBhostExtend32', //扩展图床32
  'PBhostExtend33', //扩展图床33
  'PBhostExtend34', //扩展图床34
  'PBhostExtend35', //扩展图床35
  'PBhostExtend36', //扩展图床36
  'PBhostExtend37', //扩展图床37
  'PBhostExtend38', //扩展图床38
  'PBhostExtend39', //扩展图床39
  'PBhostExtend40', //扩展图床40
  'PBhostExtend41', //扩展图床41
  'PBhostExtend42', //扩展图床42
  'PBhostExtend43', //扩展图床43
  'PBhostExtend44', //扩展图床44
  'PBhostExtend45', //扩展图床45
  'PBhostExtend46', //扩展图床46
  'PBhostExtend47', //扩展图床47
  'PBhostExtend48', //扩展图床48
  'PBhostExtend49', //扩展图床49
  'PBhostExtend50', //扩展图床50
];

// XXX 重要，默认上传图床名和数据库表名对应关系
Map<String, String> pBhostToTableName = {
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
  'ftp': 'PBhostExtend1',
};

List<String> tableKeysList = [
  'path',
  'name',
  'url',
  'PBhost',
  'pictureKey',
  'hostSpecificArgA',
  'hostSpecificArgB',
  'hostSpecificArgC',
  'hostSpecificArgD',
  'hostSpecificArgE',
  'hostSpecificArgF',
  'hostSpecificArgG',
  'hostSpecificArgH',
  'hostSpecificArgI',
  'hostSpecificArgJ',
  'hostSpecificArgK',
  'hostSpecificArgL',
  'hostSpecificArgM',
  'hostSpecificArgN',
  'hostSpecificArgO',
  'hostSpecificArgP',
  'hostSpecificArgQ',
  'hostSpecificArgR',
  'hostSpecificArgS',
  'hostSpecificArgT',
  'hostSpecificArgU',
  'hostSpecificArgV',
  'hostSpecificArgW',
  'hostSpecificArgX',
  'hostSpecificArgY',
  'hostSpecificArgZ',
];

class AlbumSQL {
  static getDatabase() async {
    String currentUserName = await Global.getUser();
    Database db = await initDB(currentUserName);
    return db;
  }

  static initDB(String username) async {
    var externalDirectoryPath =
        await ExternalPath.getExternalStoragePublicDirectory(
            ExternalPath.DIRECTORY_DOWNLOADS);
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

  static getExtendDatabase() async {
    String currentUserName = await Global.getUser();
    Database db = await initExtendDB(currentUserName);
    return db;
  }

  static initExtendDB(String username) async {
    var externalDirectoryPath =
        await ExternalPath.getExternalStoragePublicDirectory(
            ExternalPath.DIRECTORY_DOWNLOADS);
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
    var res = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='$tableName'");
    return res.isNotEmpty;
  }

  static createTable(Database db, String tableName) async {
    await db.execute(
        "CREATE TABLE $tableName (id INTEGER PRIMARY KEY AUTOINCREMENT,path TEXT,name TEXT,url TEXT,PBhost TEXT,pictureKey TEXT,hostSpecificArgA TEXT,hostSpecificArgB TEXT,hostSpecificArgC TEXT,hostSpecificArgD TEXT,hostSpecificArgE TEXT)");
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
