import 'dart:convert';

// ignore: depend_on_referenced_packages
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:dart_des/dart_des.dart';
import 'package:mysql1/mysql1.dart';

import 'package:horopic/utils/global.dart';
import 'package:horopic/utils/common_functions.dart';

class MySqlUtils {
  static String currentClassName = 'MySqlUtils';

  static List<int> iv = "保密占位符";
  static List<int> encrypted = [];
  static List<int> decrypted = [];

  static encryptSelf(String data) async {
    //加密保存用户数据
    String passwordUser = await Global.getPassword();
    String encryptKey = passwordUser * 3;
    String to_encrypt = data + "保密占位符";
    DES3 des3CBC = DES3(key: encryptKey.codeUnits, mode: DESMode.CBC, iv: iv);
    encrypted = des3CBC.encrypt(utf8.encode(to_encrypt));
    String encryptedString = hex.encode(encrypted);
    return encryptedString;
  }

  static decryptSelf(String encryptedString) async {
    //用户本地解密
    String passwordUser = await Global.getPassword();
    String encryptKey = passwordUser * 3;
    List<int> encrypted = hex.decode(encryptedString);
    DES3 des3CBC = DES3(key: encryptKey.codeUnits, mode: DESMode.CBC, iv: iv);
    decrypted = des3CBC.decrypt(encrypted);
    String decryptedStr = utf8.decode(decrypted);
    String to_remove = "保密占位符";
    String decryptedString =
        decryptedStr.substring(0, decryptedStr.length - to_remove.length);
    if (decryptedString.isEmpty) {
      return ' ';
    } else {
      return decryptedString;
    }
  }

  static var settings = ConnectionSettings(
      //连接个人数据库，这里保密了
      host: "保密占位符",
      port: 3306,
      user: "保密占位符",
      password: "保密占位符",
      db: "保密占位符");

  static getCurrentVersion() async {
    var conn = await MySqlConnection.connect(settings);
    var results =
        await conn.query('select * from version where stable=?', ['current']);
    for (var row in results) {
      return row[1].toString();
    }
  }

  static queryUser({required String username}) async {
    var conn = await MySqlConnection.connect(settings);
    try {
      var results = await conn
          .query('select * from users where username = ?', [username]);
      if (results.isEmpty) {
        return "Empty";
      }
      Map<String, dynamic> resultsMap = {};
      resultsMap.clear();
      for (var row in results) {
        String username = row[1].toString();
        String password = await decryptSelf(row[2].toString());
        String defaultPShost = row[3].toString();
        resultsMap['username'] = username;
        resultsMap['password'] = password;
        resultsMap['defaultPShost'] = defaultPShost;
      }
      return resultsMap;
    } catch (e) {
      flogErr(
        e,
        {'username': username},
        currentClassName,
        "queryUser",
      );
      return "Error";
    } finally {
      await conn.close();
    }
  }

  static insertUser({required List content}) async {
    var conn = await MySqlConnection.connect(settings);
    try {
      String valuename = content[0].toString();
      String valuepassword = content[1].toString();
      String valuedefaultPShost = content[2].toString();
      String encryptedPassword = await encryptSelf(valuepassword);

      await conn.query(
          "insert into users (username,password,defaultPShost) values (?,?,?)",
          [valuename, encryptedPassword, valuedefaultPShost]);
      return 'Success';
    } catch (e) {
      flogErr(
        e,
        {},
        currentClassName,
        "insertUser",
      );
      return "Error";
    } finally {
      await conn.close();
    }
  }

  static updateUser({required List content}) async {
    var conn = await MySqlConnection.connect(settings);
    try {
      String valuename = content[0].toString();
      String valuepassword = content[1].toString();
      String valuedefaultPShost = content[2].toString();
      String encryptedPassword = await encryptSelf(valuepassword);

      await conn.query(
          "update users set password = ?,defaultPShost = ? where username = ?",
          [encryptedPassword, valuedefaultPShost, valuename]);
      return 'Success';
    } catch (e) {
      flogErr(
        e,
        {},
        currentClassName,
        "updateUser",
      );
      return "Error";
    } finally {
      await conn.close();
    }
  }

  static queryBase({
    required String username,
    required String tablename,
    required List paramNames,
    required bool isID,
  }) async {
    var conn = await MySqlConnection.connect(settings);
    try {
      var results = await conn
          .query('select * from $tablename where username = ?', [username]);
      if (results.isEmpty) {
        return "Empty";
      }
      Map<String, dynamic> resultsMap = {};
      resultsMap.clear();
      for (var row in results) {
        if (isID) {
          resultsMap['id'] = row[0];
        }
        for (int i = 0; i < paramNames.length; i++) {
          String paramName = paramNames[i];
          String paramValue = await decryptSelf(row[i + 1].toString());
          resultsMap[paramName] = paramValue;
        }
      }
      return resultsMap;
    } catch (e) {
      flogErr(
        e,
        {'username': username},
        currentClassName,
        'query$tablename',
      );
      return "Error";
    } finally {
      await conn.close();
    }
  }

  static insertBase({
    required List content,
    required String tablename,
    required List paramNames,
  }) async {
    var conn = await MySqlConnection.connect(settings);
    try {
      int paraNum = paramNames.length;
      List paraToInsert = [];
      for (int i = 0; i < paraNum; i++) {
        var _ = await encryptSelf(content[i].toString());
        paraToInsert.add(_);
      }
      paraToInsert.add(content[paraNum].toString());
      String paraNamesString = '${paramNames.join(",")},username';
      String questionMark = '${'?,' * paraNum}?';

      String insertCommand =
          "insert into $tablename ($paraNamesString) values ($questionMark)";
      await conn.query(insertCommand, paraToInsert);
      return 'Success';
    } catch (e) {
      flogErr(
        e,
        {},
        currentClassName,
        'insert$tablename',
      );
      return "Error";
    } finally {
      await conn.close();
    }
  }

  static updateBase({
    required List content,
    required String tablename,
    required List paramNames,
  }) async {
    var conn = await MySqlConnection.connect(settings);
    try {
      int paraNum = paramNames.length;
      List paraToInsert = [];
      String paramNamesString = '';
      for (int i = 0; i < paraNum; i++) {
        var _ = await encryptSelf(content[i].toString());
        paraToInsert.add(_);
        paramNamesString += '${paramNames[i]} = ?,';
      }
      paraToInsert.add(content[paraNum].toString());
      paramNamesString =
          paramNamesString.substring(0, paramNamesString.length - 1);

      String updateCommand =
          "update $tablename set $paramNamesString where username = ?";
      await conn.query(updateCommand, paraToInsert);
      return 'Success';
    } catch (e) {
      flogErr(
        e,
        {},
        currentClassName,
        'update$tablename',
      );
      return "Error";
    } finally {
      await conn.close();
    }
  }

  static queryLankong({required String username}) async {
    var result = await queryBase(
      username: username,
      tablename: 'lankong',
      paramNames: ['host', 'strategy_id', 'album_id', 'token'],
      isID: false,
    );
    return result;
  }

  static insertLankong({required List content}) async {
    var result = await insertBase(
        content: content,
        tablename: 'lankong',
        paramNames: ['hosts', 'strategy_id', 'album_id', 'token']);
    return result;
  }

  static updateLankong({required List content}) async {
    var result = await updateBase(
        content: content,
        tablename: 'lankong',
        paramNames: ['hosts', 'strategy_id', 'album_id', 'token']);
    return result;
  }

  static querySmms({required String username}) async {
    var result = await queryBase(
      username: username,
      tablename: 'smms',
      paramNames: ['token'],
      isID: false,
    );
    return result;
  }

  static insertSmms({required List content}) async {
    var result = await insertBase(
        content: content, tablename: 'smms', paramNames: ['token']);
    return result;
  }

  static updateSmms({required List content}) async {
    var result = await updateBase(
        content: content, tablename: 'smms', paramNames: ['token']);
    return result;
  }

  static queryGithub({required String username}) async {
    var result = await queryBase(
      username: username,
      tablename: 'github',
      paramNames: [
        'githubusername',
        'repo',
        'token',
        'storePath',
        'branch',
        'customDomain'
      ],
      isID: false,
    );
    return result;
  }

  static insertGithub({required List content}) async {
    var result = await insertBase(
        content: content,
        tablename: 'github',
        paramNames: [
          'githubusername',
          'repo',
          'token',
          'storePath',
          'branch',
          'customDomain'
        ]);
    return result;
  }

  static updateGithub({required List content}) async {
    var result = await updateBase(
        content: content,
        tablename: 'github',
        paramNames: [
          'githubusername',
          'repo',
          'token',
          'storePath',
          'branch',
          'customDomain'
        ]);
    return result;
  }

  static queryImgur({required String username}) async {
    var result = await queryBase(
      username: username,
      tablename: 'imgur',
      paramNames: ['clientId', 'proxy'],
      isID: false,
    );
    return result;
  }

  static insertImgur({required List content}) async {
    var result =
        await insertBase(content: content, tablename: 'imgur', paramNames: [
      'clientId',
      'proxy',
    ]);
    return result;
  }

  static updateImgur({required List content}) async {
    var result =
        await updateBase(content: content, tablename: 'imgur', paramNames: [
      'clientId',
      'proxy',
    ]);
    return result;
  }

  static queryQiniu({required String username}) async {
    var result = await queryBase(
      username: username,
      tablename: 'qiniu',
      paramNames: [
        'accessKey',
        'secretKey',
        'bucket',
        'url',
        'area',
        'options',
        'path'
      ],
      isID: false,
    );
    return result;
  }

  static insertQiniu({required List content}) async {
    var result = await insertBase(
        content: content,
        tablename: 'qiniu',
        paramNames: [
          'accessKey',
          'secretKey',
          'bucket',
          'url',
          'area',
          'options',
          'path'
        ]);
    return result;
  }

  static updateQiniu({required List content}) async {
    var result = await updateBase(
        content: content,
        tablename: 'qiniu',
        paramNames: [
          'accessKey',
          'secretKey',
          'bucket',
          'url',
          'area',
          'options',
          'path'
        ]);
    return result;
  }

  static queryTencent({required String username}) async {
    var result = await queryBase(
      username: username,
      tablename: 'tencent',
      paramNames: [
        'secretId',
        'secretKey',
        'bucket',
        'appId',
        'area',
        'path',
        'customUrl',
        'options'
      ],
      isID: false,
    );
    return result;
  }

  static insertTencent({required List content}) async {
    var result =
        await insertBase(content: content, tablename: 'tencent', paramNames: [
      'secretId',
      'secretKey',
      'bucket',
      'appId',
      'area',
      'path',
      'customUrl',
      'options',
    ]);
    return result;
  }

  static updateTencent({required List content}) async {
    var result =
        await updateBase(content: content, tablename: 'tencent', paramNames: [
      'secretId',
      'secretKey',
      'bucket',
      'appId',
      'area',
      'path',
      'customUrl',
      'options',
    ]);
    return result;
  }

  static queryAliyun({required String username}) async {
    var result = await queryBase(
      username: username,
      tablename: 'aliyun',
      paramNames: [
        'keyId',
        'keySecret',
        'bucket',
        'area',
        'path',
        'customUrl',
        'options'
      ],
      isID: false,
    );
    return result;
  }

  static insertAliyun({required List content}) async {
    var result = await insertBase(
        content: content,
        tablename: 'aliyun',
        paramNames: [
          'keyId',
          'keySecret',
          'bucket',
          'area',
          'path',
          'customUrl',
          'options'
        ]);
    return result;
  }

  static updateAliyun({required List content}) async {
    var result = await updateBase(
        content: content,
        tablename: 'aliyun',
        paramNames: [
          'keyId',
          'keySecret',
          'bucket',
          'area',
          'path',
          'customUrl',
          'options'
        ]);
    return result;
  }

  static queryUpyun({required String username}) async {
    var result = await queryBase(
      username: username,
      tablename: 'upyun',
      paramNames: ['bucket', 'operator', 'password', 'url', 'options', 'path'],
      isID: false,
    );
    return result;
  }

  static insertUpyun({required List content}) async {
    var result = await insertBase(
        content: content,
        tablename: 'upyun',
        paramNames: [
          'bucket',
          'operator',
          'password',
          'url',
          'options',
          'path'
        ]);
    return result;
  }

  static updateUpyun({required List content}) async {
    var result = await updateBase(
        content: content,
        tablename: 'upyun',
        paramNames: [
          'bucket',
          'operator',
          'password',
          'url',
          'options',
          'path'
        ]);
    return result;
  }

  static queryUpyunManage({required String username}) async {
    var result = await queryBase(
      username: username,
      tablename: 'upyunmanage',
      paramNames: ['email', 'password', 'token', 'tokenname'],
      isID: false,
    );
    return result;
  }

  static insertUpyunManage({required List content}) async {
    var result = await insertBase(
        content: content,
        tablename: 'upyunmanage',
        paramNames: ['email', 'password', 'token', 'tokenname']);
    return result;
  }

  static updateUpyunManage({required List content}) async {
    var result = await updateBase(
        content: content,
        tablename: 'upyunmanage',
        paramNames: ['email', 'password', 'token', 'tokenname']);
    return result;
  }

  static queryUpyunOperator({required String username}) async {
    var result = await queryBase(
      username: username,
      tablename: 'upyunoperator',
      paramNames: ['bucket', 'email', 'operator', 'password'],
      isID: true,
    );
    return result;
  }

  static insertUpyunOperator({required List content}) async {
    var result = await insertBase(
        content: content,
        tablename: 'upyunoperator',
        paramNames: ['bucket', 'email', 'operator', 'password']);
    return result;
  }

  static updateUpyunOperator({required List content}) async {
    var result = await updateBase(
        content: content,
        tablename: 'upyunoperator',
        paramNames: ['bucket', 'email', 'operator', 'password']);
    return result;
  }

  static deleteUpyunOperator({required int id}) async {
    var conn = await MySqlConnection.connect(settings);
    try {
      await conn.query('delete from upyunoperator where id = ?', [id]);
      return 'Success';
    } catch (e) {
      flogErr(
        e,
        {'id': id},
        currentClassName,
        'deleteUpyunOperator',
      );
      return "Error";
    } finally {
      await conn.close();
    }
  }

  static queryQiniuManage({required String username}) async {
    var result = await queryBase(
      username: username,
      tablename: 'qiniumanage',
      paramNames: ['bucket', 'domain', 'area'],
      isID: true,
    );
    return result;
  }

  static insertQiniuManage({required List content}) async {
    var result = await insertBase(
        content: content,
        tablename: 'qiniumanage',
        paramNames: ['bucket', 'domain', 'area']);
    return result;
  }

  static updateQiniuManage({required List content}) async {
    var result = await updateBase(
        content: content,
        tablename: 'qiniumanage',
        paramNames: ['bucket', 'domain', 'area']);
    return result;
  }

  static insertUserCount({required List content}) async {
    var conn = await MySqlConnection.connect(settings);
    try {
      String opentime = content[0].toString();
      String version = content[1].toString();
      String username = content[2].toString();

      await conn.query(
          "insert into usercount (opentime,version,username) values (?,?,?)",
          [opentime, version, username]);
      return 'Success';
    } catch (e) {
      return "Error";
    } finally {
      await conn.close();
    }
  }

  static queryFTP({required String username}) async {
    var result = await queryBase(
        username: username,
        tablename: 'ftp',
        paramNames: [
          'ftpHost',
          'ftpPort',
          'ftpUser',
          'ftpPassword',
          'ftpType',
          'isAnonymous',
          'uploadPath',
          'ftpHomeDir',
        ],
        isID: false);
    return result;
  }

  static insertFTP({required List content}) async {
    var result =
        await insertBase(content: content, tablename: 'ftp', paramNames: [
      'ftpHost',
      'ftpPort',
      'ftpUser',
      'ftpPassword',
      'ftpType',
      'isAnonymous',
      'uploadPath',
      'ftpHomeDir'
    ]);
    return result;
  }

  static updateFTP({required List content}) async {
    var result =
        await updateBase(content: content, tablename: 'ftp', paramNames: [
      'ftpHost',
      'ftpPort',
      'ftpUser',
      'ftpPassword',
      'ftpType',
      'isAnonymous',
      'uploadPath',
      'ftpHomeDir'
    ]);
    return result;
  }

  static queryImgurManage({required String username}) async {
    var result = await queryBase(
        username: username,
        tablename: 'imgurmanage',
        paramNames: [
          'imguruser',
          'clientid',
          'clientsecret',
          'accesstoken',
          'proxy'
        ],
        isID: false);
    return result;
  }

  static insertImgurManage({required List content}) async {
    var result = await insertBase(
        content: content,
        tablename: 'imgurmanage',
        paramNames: [
          'imguruser',
          'clientid',
          'clientsecret',
          'accesstoken',
          'proxy'
        ]);
    return result;
  }

  static updateImgurManage({required List content}) async {
    var result = await updateBase(
        content: content,
        tablename: 'imgurmanage',
        paramNames: [
          'imguruser',
          'clientid',
          'clientsecret',
          'accesstoken',
          'proxy'
        ]);
    return result;
  }

  static queryAws({required String username}) async {
    var result = await queryBase(
        username: username,
        tablename: 'aws',
        paramNames: [
          'accessKeyId',
          'secretAccessKey',
          'bucket',
          'endpoint',
          'region',
          'uploadPath',
          'customUrl'
        ],
        isID: false);
    return result;
  }

  static insertAws({required List content}) async {
    var result =
        await insertBase(content: content, tablename: 'aws', paramNames: [
      'accessKeyID',
      'secretAccessKey',
      'bucket',
      'endpoint',
      'region',
      'uploadPath',
      'customUrl'
    ]);
    return result;
  }

  static updateAws({required List content}) async {
    var result =
        await updateBase(content: content, tablename: 'aws', paramNames: [
      'accessKeyID',
      'secretAccessKey',
      'bucket',
      'endpoint',
      'region',
      'uploadPath',
      'customUrl'
    ]);
    return result;
  }

  static queryAlist({required String username}) async {
    var result = await queryBase(
        username: username,
        tablename: 'alist',
        paramNames: [
          'host',
          'alistusername',
          'password',
          'token',
          'uploadPath',
        ],
        isID: false);
    return result;
  }

  static insertAlist({required List content}) async {
    var result =
        await insertBase(content: content, tablename: 'alist', paramNames: [
      'host',
      'alistusername',
      'password',
      'token',
      'uploadPath',
    ]);
    return result;
  }

  static updateAlist({required List content}) async {
    var result =
        await updateBase(content: content, tablename: 'alist', paramNames: [
      'host',
      'alistusername',
      'password',
      'token',
      'uploadPath',
    ]);
    return result;
  }

  static queryWebdav({required String username}) async {
    var result = await queryBase(
        username: username,
        tablename: 'webdav',
        paramNames: ['host', 'webdavusername', 'password', 'uploadPath'],
        isID: false);
    return result;
  }

  static insertWebdav({required List content}) async {
    var result = await insertBase(
        content: content,
        tablename: 'webdav',
        paramNames: ['host', 'webdavusername', 'password', 'uploadPath']);
    return result;
  }

  static updateWebdav({required List content}) async {
    var result = await updateBase(
        content: content,
        tablename: 'webdav',
        paramNames: ['host', 'webdavusername', 'password', 'uploadPath']);
    return result;
  }
}
