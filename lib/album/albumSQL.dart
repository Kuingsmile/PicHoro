import 'package:flutter/material.dart';
import 'package:horopic/utils/global.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
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

Map<String, String> PBhostToTableName = {
  "lsky.pro": "lskypro",
  "sm.ms": "smms",
};

List<String> tableKeysList = [
  'path',
  'name',
  'url',
  'PBhost',
  'pictureKey',
  'hostSpecificArgA',
  'hostSpecificArgB'
];

class AlbumSQL {
  static getDatabase() async {
    String currentUserName = await Global.getUser();
    Database db = await initDB(currentUserName);
    return db;
  }

  static initDB(String username) async {
    var externalDirectoryPath = await getExternalStorageDirectory();
    var persistPath = '${externalDirectoryPath!.path}/horoDB';
    if (!await Directory(persistPath).exists()) {
      await Directory(persistPath).create(recursive: true);
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
              hostSpecificArgB TEXT
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
    return res != null && res.isNotEmpty;
  }

  static createTable(Database db, String tableName) async {
    await db.execute(
        "CREATE TABLE $tableName (id INTEGER PRIMARY KEY AUTOINCREMENT,path TEXT,name TEXT,url TEXT,PBhost TEXT,pictureKey TEXT,hostSpecificArgA TEXT,hostSpecificArgB TEXT)");
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

  static EmptyAllTable(Database db) async {
    for (var i = 0; i < allPBhost.length; i++) {
      await db.delete(allPBhost[i]);
    }
  }

  static DeleteTable(Database db, String tableName) async {
    await db.delete(tableName);
  }

  static close(Database db) async {
    await db.close();
  }
}
