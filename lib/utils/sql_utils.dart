import 'dart:convert';

// ignore: depend_on_referenced_packages
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:dart_des/dart_des.dart';
import 'package:f_logs/f_logs.dart';
import 'package:mysql1/mysql1.dart';

import 'package:horopic/utils/global.dart';
import 'package:horopic/utils/common_functions.dart';

class MySqlUtils {
  static List<int> iv = "保密占位符";
  static List<int> encrypted = [];
  static List<int> decrypted = [];

  static encryptSelf(String data) async {
    //加密保存用户数据
    String passwordUser = await Global.getPassword();
    String encryptKey = passwordUser * 3;
    String to_encrypt = data + "保密占位符";
    DES3 des3CBC = DES3(key: encryptKey.codeUnits, mode: DESMode.CBC, iv: iv);
    encrypted = des3CBC.encrypt(to_encrypt.codeUnits);
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
    String decryptedStr = String.fromCharCodes(decrypted);
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

  static Map<String, String> tablePShost = {'lsky.pro': 'lankong'};

  static getCurrentVersion() async {
    var conn = await MySqlConnection.connect(settings);
    var results =
        await conn.query('select * from version where stable=?', ['current']);
    for (var row in results) {
      return row[1].toString();
    }
  }

  static query({required String table_name, required String username}) async {
    var conn = await MySqlConnection.connect(settings);
    try {
      var results = await conn
          .query('select * from $table_name where username = ?', [username]);
      return results;
    } catch (e) {
      return "Error";
    } finally {
      await conn.close();
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
      return "Error";
    } finally {
      await conn.close();
    }
  }

  static queryLankong({required String username}) async {
    var conn = await MySqlConnection.connect(settings);
    try {
      var results = await conn
          .query('select * from lankong where username = ?', [username]);
      if (results.isEmpty) {
        return "Empty";
      }
      Map<String, dynamic> resultsMap = {};
      resultsMap.clear();
      for (var row in results) {
        String host = await decryptSelf(row[1].toString());
        String strategyId = await decryptSelf(row[2].toString());
        String albumId = await decryptSelf(row[3].toString());
        String token = await decryptSelf(row[4].toString());
        resultsMap['host'] = host;
        resultsMap['strategy_id'] = strategyId;
        resultsMap['album_id'] = albumId;
        resultsMap['token'] = token;
      }
      return resultsMap;
    } catch (e) {
      FLog.error(
          className: 'MySqlUtils',
          methodName: 'queryLankong',
          text: formatErrorMessage({'username': username}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      return "Error";
    } finally {
      await conn.close();
    }
  }

  static insertLankong({required List content}) async {
    var conn = await MySqlConnection.connect(settings);
    try {
      String hosts = content[0].toString();
      String strategyId = content[1].toString();
      String albumId = content[2].toString();
      String token = content[3].toString();
      String username = content[4].toString();
      String encryptedHost = await encryptSelf(hosts);
      String encryptedStrategyId = await encryptSelf(strategyId);
      String encryptedAlbumId = await encryptSelf(albumId);
      String encryptedToken = await encryptSelf(token);

      await conn.query(
          "insert into lankong (hosts,strategy_id,album_id,token,username) values (?,?,?,?,?)",
          [
            encryptedHost,
            encryptedStrategyId,
            encryptedAlbumId,
            encryptedToken,
            username
          ]);
      return 'Success';
    } catch (e) {
      FLog.error(
          className: 'MySqlUtils',
          methodName: 'insertLankong',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      return "Error";
    } finally {
      await conn.close();
    }
  }

  static updateLankong({required List content}) async {
    var conn = await MySqlConnection.connect(settings);

    try {
      String hosts = content[0].toString();
      String strategyId = content[1].toString();
      String albumId = content[2].toString();
      String token = content[3].toString();
      String username = content[4].toString();
      String encryptedHost = await encryptSelf(hosts);
      String encryptedStrategyId = await encryptSelf(strategyId);
      String encryptedAlbumId = await encryptSelf(albumId);
      String encryptedToken = await encryptSelf(token);

      await conn.query(
          "update lankong set hosts = ?,strategy_id = ?,album_id = ?,token = ? where username = ?",
          [
            encryptedHost,
            encryptedStrategyId,
            encryptedAlbumId,
            encryptedToken,
            username
          ]);
      return 'Success';
    } catch (e) {
      FLog.error(
          className: 'MySqlUtils',
          methodName: 'updateLankong',
          text: formatErrorMessage({'content': content}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      return "Error";
    } finally {
      await conn.close();
    }
  }

  static updateLankong({required List content}) async {
    var conn = await MySqlConnection.connect(settings);

    try {
      String hosts = content[0].toString();
      String strategy_id = content[1].toString();
      String token = content[2].toString();
      String username = content[3].toString();
      String encryptedHost = await encryptSelf(hosts);
      String encryptedStrategy_id = await encryptSelf(strategy_id);
      String encryptedToken = await encryptSelf(token);

      var results = await conn.query(
          "update lankong set hosts = ?,strategy_id = ?,token = ? where username = ?",
          [encryptedHost, encryptedStrategy_id, encryptedToken, username]);
      return 'Success';
    } catch (e) {
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

      var results = await conn.query(
          "update users set password = ?,defaultPShost = ? where username = ?",
          [encryptedPassword, valuedefaultPShost, valuename]);
      return 'Success';
    } catch (e) {
      return "Error";
    } finally {
      await conn.close();
    }
  }

  static querySmms({required String username}) async {
    var conn = await MySqlConnection.connect(settings);
    try {
      var results =
          await conn.query('select * from smms where username = ?', [username]);
      if (results.isEmpty) {
        return "Empty";
      }
      Map<String, dynamic> resultsMap = {};
      resultsMap.clear();
      for (var row in results) {
        String token = await decryptSelf(row[1].toString());
        resultsMap['token'] = token;
      }
      return resultsMap;
    } catch (e) {
      //print(e);
      return "Error";
    } finally {
      await conn.close();
    }
  }

  static insertSmms({required List content}) async {
    var conn = await MySqlConnection.connect(settings);
    try {
      String token = content[0].toString();
      String username = content[1].toString();

      String encryptedToken = await encryptSelf(token);

      var results = await conn.query(
          "insert into smms (token,username) values (?,?)",
          [encryptedToken, username]);
      return 'Success';
    } catch (e) {
      return "Error";
    } finally {
      await conn.close();
    }
  }

  static updateSmms({required List content}) async {
    var conn = await MySqlConnection.connect(settings);

    try {
      String token = content[0].toString();
      String username = content[1].toString();

      String encryptedToken = await encryptSelf(token);

      var results = await conn.query(
          "update smms set token = ? where username = ?",
          [encryptedToken, username]);
      return 'Success';
    } catch (e) {
      return "Error";
    } finally {
      await conn.close();
    }
  }

  static queryGithub({required String username}) async {
    var conn = await MySqlConnection.connect(settings);
    try {
      var results = await conn
          .query('select * from github where username = ?', [username]);
      if (results.isEmpty) {
        return "Empty";
      }
      Map<String, dynamic> resultsMap = {};
      resultsMap.clear();
      for (var row in results) {
        String githubusername = await decryptSelf(row[1].toString());
        String repo = await decryptSelf(row[2].toString());
        String token = await decryptSelf(row[3].toString());
        String storePath = await decryptSelf(row[4].toString());
        String branch = await decryptSelf(row[5].toString());
        String customDomain = await decryptSelf(row[6].toString());

        resultsMap['githubusername'] = githubusername;
        resultsMap['repo'] = repo;
        resultsMap['token'] = token;
        resultsMap['storePath'] = storePath;
        resultsMap['branch'] = branch;
        resultsMap['customDomain'] = customDomain;
      }
      return resultsMap;
    } catch (e) {
      return "Error";
    } finally {
      await conn.close();
    }
  }

  static insertGithub({required List content}) async {
    var conn = await MySqlConnection.connect(settings);
    try {
      String githubusername = content[0].toString();
      String repo = content[1].toString();
      String token = content[2].toString();
      String storePath = content[3].toString();
      String branch = content[4].toString();
      String customDomain = content[5].toString();
      String username = content[6].toString();

      String encryptedGithubusername = await encryptSelf(githubusername);
      String encryptedRepo = await encryptSelf(repo);
      String encryptedToken = await encryptSelf(token);
      String encryptedStorePath = await encryptSelf(storePath);
      String encryptedBranch = await encryptSelf(branch);
      String encryptedCustomDomain = await encryptSelf(customDomain);

      var results = await conn.query(
          "insert into github (githubusername,repo,token,storePath,branch,customDomain,username) values (?,?,?,?,?,?,?)",
          [
            encryptedGithubusername,
            encryptedRepo,
            encryptedToken,
            encryptedStorePath,
            encryptedBranch,
            encryptedCustomDomain,
            username
          ]);
      return 'Success';
    } catch (e) {
      return "Error";
    } finally {
      await conn.close();
    }
  }

  static updateGithub({required List content}) async {
    var conn = await MySqlConnection.connect(settings);

    try {
      String githubusername = content[0].toString();
      String repo = content[1].toString();
      String token = content[2].toString();
      String storePath = content[3].toString();
      String branch = content[4].toString();
      String customDomain = content[5].toString();
      String username = content[6].toString();

      String encryptedGithubusername = await encryptSelf(githubusername);
      String encryptedRepo = await encryptSelf(repo);
      String encryptedToken = await encryptSelf(token);
      String encryptedStorePath = await encryptSelf(storePath);
      String encryptedBranch = await encryptSelf(branch);
      String encryptedCustomDomain = await encryptSelf(customDomain);

      var results = await conn.query(
          "update github set githubusername = ?,repo = ?,token = ?,storePath = ?,branch = ?,customDomain = ? where username = ?",
          [
            encryptedGithubusername,
            encryptedRepo,
            encryptedToken,
            encryptedStorePath,
            encryptedBranch,
            encryptedCustomDomain,
            username
          ]);
      return 'Success';
    } catch (e) {
      return "Error";
    } finally {
      await conn.close();
    }
  }

  static queryImgur({required String username}) async {
    var conn = await MySqlConnection.connect(settings);
    try {
      var results = await conn
          .query('select * from imgur where username = ?', [username]);

      if (results.isEmpty) {
        return "Empty";
      }
      Map<String, dynamic> resultsMap = {};
      resultsMap.clear();
      for (var row in results) {
        //第一列是id
        String clientId = await decryptSelf(row[1].toString());
        String proxy = await decryptSelf(row[2].toString());

        resultsMap['clientId'] = clientId;
        resultsMap['proxy'] = proxy;
      }
      return resultsMap;
    } catch (e) {
      return "Error";
    } finally {
      await conn.close();
    }
  }

  static insertImgur({required List content}) async {
    var conn = await MySqlConnection.connect(settings);
    try {
      String clientId = content[0].toString();
      String proxy = content[1].toString();
      String username = content[2].toString();

      String encryptedClientId = await encryptSelf(clientId);
      String encryptedProxy = await encryptSelf(proxy);

      var results = await conn.query(
          "insert into imgur (clientId,proxy,username) values (?,?,?)",
          [encryptedClientId, encryptedProxy, username]);
      return 'Success';
    } catch (e) {
      return "Error";
    } finally {
      await conn.close();
    }
  }

  static updateImgur({required List content}) async {
    var conn = await MySqlConnection.connect(settings);

    try {
      String clientId = content[0].toString();
      String proxy = content[1].toString();
      String username = content[2].toString();
      String encryptedClientId = await encryptSelf(clientId);
      String encryptedProxy = await encryptSelf(proxy);
      var results = await conn.query(
          "update imgur set clientId = ?,proxy = ? where username = ?",
          [encryptedClientId, encryptedProxy, username]);
      return 'Success';
    } catch (e) {
      return "Error";
    } finally {
      await conn.close();
    }
  }

  static queryQiniu({required String username}) async {
    var conn = await MySqlConnection.connect(settings);
    try {
      var results = await conn
          .query('select * from qiniu where username = ?', [username]);

      if (results.isEmpty) {
        return "Empty";
      }
      Map<String, dynamic> resultsMap = {};
      resultsMap.clear();
      for (var row in results) {
        //第一列是id
        String accessKey = await decryptSelf(row[1].toString());
        String secretKey = await decryptSelf(row[2].toString());
        String bucket = await decryptSelf(row[3].toString());
        String url = await decryptSelf(row[4].toString());
        String area = await decryptSelf(row[5].toString());
        String options = await decryptSelf(row[6].toString());
        String path = await decryptSelf(row[7].toString());

        resultsMap['accessKey'] = accessKey;
        resultsMap['secretKey'] = secretKey;
        resultsMap['bucket'] = bucket;
        resultsMap['url'] = url;
        resultsMap['area'] = area;
        resultsMap['options'] = options;
        resultsMap['path'] = path;
      }
      return resultsMap;
    } catch (e) {
      return "Error";
    } finally {
      await conn.close();
    }
  }

  static insertQiniu({required List content}) async {
    var conn = await MySqlConnection.connect(settings);
    try {
      String accessKey = content[0].toString();
      String secretKey = content[1].toString();
      String bucket = content[2].toString();
      String url = content[3].toString();
      String area = content[4].toString();
      String options = content[5].toString();
      String path = content[6].toString();
      String username = content[7].toString();

      String encryptedAccessKey = await encryptSelf(accessKey);
      String encryptedSecretKey = await encryptSelf(secretKey);
      String encryptedBucket = await encryptSelf(bucket);
      String encryptedUrl = await encryptSelf(url);
      String encryptedArea = await encryptSelf(area);
      String encryptedOptions = await encryptSelf(options);
      String encryptedPath = await encryptSelf(path);

      var results = await conn.query(
          "insert into qiniu (accessKey,secretKey,bucket,url,area,options,path,username) values (?,?,?,?,?,?,?,?)",
          [
            encryptedAccessKey,
            encryptedSecretKey,
            encryptedBucket,
            encryptedUrl,
            encryptedArea,
            encryptedOptions,
            encryptedPath,
            username
          ]);
      return 'Success';
    } catch (e) {
      return "Error";
    } finally {
      await conn.close();
    }
  }

  static updateQiniu({required List content}) async {
    var conn = await MySqlConnection.connect(settings);

    try {
      String accessKey = content[0].toString();
      String secretKey = content[1].toString();
      String bucket = content[2].toString();
      String url = content[3].toString();
      String area = content[4].toString();
      String options = content[5].toString();
      String path = content[6].toString();
      String username = content[7].toString();

      String encryptedAccessKey = await encryptSelf(accessKey);
      String encryptedSecretKey = await encryptSelf(secretKey);
      String encryptedBucket = await encryptSelf(bucket);
      String encryptedUrl = await encryptSelf(url);
      String encryptedArea = await encryptSelf(area);
      String encryptedOptions = await encryptSelf(options);
      String encryptedPath = await encryptSelf(path);

      var results = await conn.query(
          "update qiniu set accessKey = ?,secretKey = ?,bucket = ?,url = ?,area = ?,options = ?,path = ? where username = ?",
          [
            encryptedAccessKey,
            encryptedSecretKey,
            encryptedBucket,
            encryptedUrl,
            encryptedArea,
            encryptedOptions,
            encryptedPath,
            username
          ]);
      return 'Success';
    } catch (e) {
      return "Error";
    } finally {
      await conn.close();
    }
  }

  static queryTencent({required String username}) async {
    var conn = await MySqlConnection.connect(settings);
    try {
      var results = await conn
          .query('select * from tencent where username = ?', [username]);

      if (results.isEmpty) {
        return "Empty";
      }
      Map<String, dynamic> resultsMap = {};
      resultsMap.clear();
      for (var row in results) {
        //第一列是id
        String secretId = await decryptSelf(row[1].toString());
        String secretKey = await decryptSelf(row[2].toString());
        String bucket = await decryptSelf(row[3].toString());
        String appId = await decryptSelf(row[4].toString());
        String area = await decryptSelf(row[5].toString());
        String path = await decryptSelf(row[6].toString());
        String customUrl = await decryptSelf(row[7].toString());
        String options = await decryptSelf(row[8].toString());

        resultsMap['secretId'] = secretId;
        resultsMap['secretKey'] = secretKey;
        resultsMap['bucket'] = bucket;
        resultsMap['appId'] = appId;
        resultsMap['area'] = area;
        resultsMap['path'] = path;
        resultsMap['customUrl'] = customUrl;
        resultsMap['options'] = options;
      }
      return resultsMap;
    } catch (e) {
      return "Error";
    } finally {
      await conn.close();
    }
  }

  static insertTencent({required List content}) async {
    var conn = await MySqlConnection.connect(settings);
    try {
      String secretId = content[0].toString();
      String secretKey = content[1].toString();
      String bucket = content[2].toString();
      String appId = content[3].toString();
      String area = content[4].toString();
      String path = content[5].toString();
      String customUrl = content[6].toString();
      String options = content[7].toString();
      String username = content[8].toString();

      String encryptedSecretId = await encryptSelf(secretId);
      String encryptedSecretKey = await encryptSelf(secretKey);
      String encryptedBucket = await encryptSelf(bucket);
      String encryptedAppId = await encryptSelf(appId);
      String encryptedArea = await encryptSelf(area);
      String encryptedPath = await encryptSelf(path);
      String encryptedCustomUrl = await encryptSelf(customUrl);
      String encryptedOptions = await encryptSelf(options);

      var results = await conn.query(
          "insert into tencent (secretId,secretKey,bucket,appId,area,path,customUrl,options,username) values (?,?,?,?,?,?,?,?,?)",
          [
            encryptedSecretId,
            encryptedSecretKey,
            encryptedBucket,
            encryptedAppId,
            encryptedArea,
            encryptedPath,
            encryptedCustomUrl,
            encryptedOptions,
            username
          ]);
      return 'Success';
    } catch (e) {
      return "Error";
    } finally {
      await conn.close();
    }
  }

  static updateTencent({required List content}) async {
    var conn = await MySqlConnection.connect(settings);

    try {
      String secretId = content[0].toString();
      String secretKey = content[1].toString();
      String bucket = content[2].toString();
      String appId = content[3].toString();
      String area = content[4].toString();
      String path = content[5].toString();
      String customUrl = content[6].toString();
      String options = content[7].toString();
      String username = content[8].toString();

      String encryptedSecretId = await encryptSelf(secretId);
      String encryptedSecretKey = await encryptSelf(secretKey);
      String encryptedBucket = await encryptSelf(bucket);
      String encryptedAppId = await encryptSelf(appId);
      String encryptedArea = await encryptSelf(area);
      String encryptedPath = await encryptSelf(path);
      String encryptedCustomUrl = await encryptSelf(customUrl);
      String encryptedOptions = await encryptSelf(options);

      var results = await conn.query(
          "update tencent set secretId = ?,secretKey = ?,bucket = ?,appId = ?,area = ?,path = ?,customUrl = ?,options = ? where username = ?",
          [
            encryptedSecretId,
            encryptedSecretKey,
            encryptedBucket,
            encryptedAppId,
            encryptedArea,
            encryptedPath,
            encryptedCustomUrl,
            encryptedOptions,
            username
          ]);
      return 'Success';
    } catch (e) {
      return "Error";
    } finally {
      await conn.close();
    }
  }

  static queryAliyun({required String username}) async {
    var conn = await MySqlConnection.connect(settings);
    try {
      var results = await conn
          .query('select * from aliyun where username = ?', [username]);

      if (results.isEmpty) {
        return "Empty";
      }
      Map<String, dynamic> resultsMap = {};
      resultsMap.clear();
      for (var row in results) {
        //第一列是id
        String keyId = await decryptSelf(row[1].toString());
        String keySecret = await decryptSelf(row[2].toString());
        String bucket = await decryptSelf(row[3].toString());
        String area = await decryptSelf(row[4].toString());
        String path = await decryptSelf(row[5].toString());
        String customUrl = await decryptSelf(row[6].toString());
        String options = await decryptSelf(row[7].toString());

        resultsMap['keyId'] = keyId;
        resultsMap['keySecret'] = keySecret;
        resultsMap['bucket'] = bucket;
        resultsMap['area'] = area;
        resultsMap['path'] = path;
        resultsMap['customUrl'] = customUrl;
        resultsMap['options'] = options;
      }
      return resultsMap;
    } catch (e) {
      return "Error";
    } finally {
      await conn.close();
    }
  }

  static insertAliyun({required List content}) async {
    var conn = await MySqlConnection.connect(settings);
    try {
      String keyId = content[0].toString();
      String keySecret = content[1].toString();
      String bucket = content[2].toString();
      String area = content[3].toString();
      String path = content[4].toString();
      String customUrl = content[5].toString();
      String options = content[6].toString();
      String username = content[7].toString();

      String encryptedKeyId = await encryptSelf(keyId);
      String encryptedKeySecret = await encryptSelf(keySecret);
      String encryptedBucket = await encryptSelf(bucket);
      String encryptedArea = await encryptSelf(area);
      String encryptedPath = await encryptSelf(path);
      String encryptedCustomUrl = await encryptSelf(customUrl);
      String encryptedOptions = await encryptSelf(options);

      var results = await conn.query(
          "insert into aliyun (keyId,keySecret,bucket,area,path,customUrl,options,username) values (?,?,?,?,?,?,?,?)",
          [
            encryptedKeyId,
            encryptedKeySecret,
            encryptedBucket,
            encryptedArea,
            encryptedPath,
            encryptedCustomUrl,
            encryptedOptions,
            username
          ]);
      return 'Success';
    } catch (e) {
      return "Error";
    } finally {
      await conn.close();
    }
  }

  static updateAliyun({required List content}) async {
    var conn = await MySqlConnection.connect(settings);

    try {
      String keyId = content[0].toString();
      String keySecret = content[1].toString();
      String bucket = content[2].toString();
      String area = content[3].toString();
      String path = content[4].toString();
      String customUrl = content[5].toString();
      String options = content[6].toString();
      String username = content[7].toString();

      String encryptedKeyId = await encryptSelf(keyId);
      String encryptedKeySecret = await encryptSelf(keySecret);
      String encryptedBucket = await encryptSelf(bucket);
      String encryptedArea = await encryptSelf(area);
      String encryptedPath = await encryptSelf(path);
      String encryptedCustomUrl = await encryptSelf(customUrl);
      String encryptedOptions = await encryptSelf(options);

      var results = await conn.query(
          "update aliyun set keyId = ?,keySecret = ?,bucket = ?,area = ?,path = ?,customUrl = ?,options = ? where username = ?",
          [
            encryptedKeyId,
            encryptedKeySecret,
            encryptedBucket,
            encryptedArea,
            encryptedPath,
            encryptedCustomUrl,
            encryptedOptions,
            username
          ]);
      return 'Success';
    } catch (e) {
      return "Error";
    } finally {
      await conn.close();
    }
  }

  static queryUpyun({required String username}) async {
    var conn = await MySqlConnection.connect(settings);
    try {
      var results = await conn
          .query('select * from upyun where username = ?', [username]);

      if (results.isEmpty) {
        return "Empty";
      }
      Map<String, dynamic> resultsMap = {};
      resultsMap.clear();
      for (var row in results) {
        //第一列是id
        String bucket = await decryptSelf(row[1].toString());
        String upyunOperator = await decryptSelf(row[2].toString());
        String password = await decryptSelf(row[3].toString());
        String url = await decryptSelf(row[4].toString());
        String opptions = await decryptSelf(row[5].toString());
        String path = await decryptSelf(row[6].toString());

        resultsMap['bucket'] = bucket;
        resultsMap['operator'] = upyunOperator;
        resultsMap['password'] = password;
        resultsMap['url'] = url;
        resultsMap['options'] = opptions;
        resultsMap['path'] = path;
      }
      return resultsMap;
    } catch (e) {
      return "Error";
    } finally {
      await conn.close();
    }
  }

  static insertUpyun({required List content}) async {
    var conn = await MySqlConnection.connect(settings);
    try {
      String bucket = content[0].toString();
      String upyunOperator = content[1].toString();
      String password = content[2].toString();
      String url = content[3].toString();
      String opptions = content[4].toString();
      String path = content[5].toString();
      String username = content[6].toString();

      String encryptedBucket = await encryptSelf(bucket);
      String encryptedOperator = await encryptSelf(upyunOperator);
      String encryptedPassword = await encryptSelf(password);
      String encryptedUrl = await encryptSelf(url);
      String encryptedOptions = await encryptSelf(opptions);
      String encryptedPath = await encryptSelf(path);

      var results = await conn.query(
          "insert into upyun (bucket,operator,password,url,options,path,username) values (?,?,?,?,?,?,?)",
          [
            encryptedBucket,
            encryptedOperator,
            encryptedPassword,
            encryptedUrl,
            encryptedOptions,
            encryptedPath,
            username
          ]);
      return 'Success';
    } catch (e) {
      return "Error";
    } finally {
      await conn.close();
    }
  }

  static updateUpyun({required List content}) async {
    var conn = await MySqlConnection.connect(settings);

    try {
      String bucket = content[0].toString();
      String upyunOperator = content[1].toString();
      String password = content[2].toString();
      String url = content[3].toString();
      String opptions = content[4].toString();
      String path = content[5].toString();
      String username = content[6].toString();

      String encryptedBucket = await encryptSelf(bucket);
      String encryptedOperator = await encryptSelf(upyunOperator);
      String encryptedPassword = await encryptSelf(password);
      String encryptedUrl = await encryptSelf(url);
      String encryptedOptions = await encryptSelf(opptions);
      String encryptedPath = await encryptSelf(path);

      var results = await conn.query(
          "update upyun set bucket = ?,operator = ?,password = ?,url = ?,options = ?,path = ? where username = ?",
          [
            encryptedBucket,
            encryptedOperator,
            encryptedPassword,
            encryptedUrl,
            encryptedOptions,
            encryptedPath,
            username
          ]);
      return 'Success';
    } catch (e) {
      return "Error";
    } finally {
      await conn.close();
    }
  }

  static queryUpyunManage({required String username}) async {
    var conn = await MySqlConnection.connect(settings);
    try {
      var results = await conn
          .query('select * from upyunmanage where username = ?', [username]);

      if (results.isEmpty) {
        return "Empty";
      }
      Map<String, dynamic> resultsMap = {};
      resultsMap.clear();
      for (var row in results) {
        //第一列是id
        String email = await decryptSelf(row[1].toString());
        String password = await decryptSelf(row[2].toString());
        String token = await decryptSelf(row[3].toString());
        String tokenname = await decryptSelf(row[4].toString());
        resultsMap['email'] = email;
        resultsMap['password'] = password;
        resultsMap['token'] = token;
        resultsMap['tokenname'] = tokenname;
      }
      return resultsMap;
    } catch (e) {
      FLog.error(
          className: 'MySqlUtils',
          methodName: 'queryUpyunManage',
          text: formatErrorMessage({'username': username}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      return "Error";
    } finally {
      await conn.close();
    }
  }

  static insertUpyunManage({required List content}) async {
    var conn = await MySqlConnection.connect(settings);
    try {
      String email = content[0].toString();
      String password = content[1].toString();
      String token = content[2].toString();
      String tokenName = content[3].toString();
      String username = content[4].toString();

      String encryptedEmail = await encryptSelf(email);
      String encryptedPassword = await encryptSelf(password);
      String encryptedToken = await encryptSelf(token);
      String encryptedTokenName = await encryptSelf(tokenName);

      await conn.query(
          "insert into upyunmanage (email,password,token,tokenname,username) values (?,?,?,?,?)",
          [
            encryptedEmail,
            encryptedPassword,
            encryptedToken,
            encryptedTokenName,
            username
          ]);
      return 'Success';
    } catch (e) {
      FLog.error(
          className: 'MySqlUtils',
          methodName: 'insertUpyunManage',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      return "Error";
    } finally {
      await conn.close();
    }
  }

  static updateUpyunManage({required List content}) async {
    var conn = await MySqlConnection.connect(settings);

    try {
      String email = content[0].toString();
      String password = content[1].toString();
      String token = content[2].toString();
      String tokenName = content[3].toString();
      String username = content[4].toString();

      String encryptedEmail = await encryptSelf(email);
      String encryptedPassword = await encryptSelf(password);
      String encryptedToken = await encryptSelf(token);
      String encryptedTokenName = await encryptSelf(tokenName);

      await conn.query(
          "update upyunmanage set email = ?,password = ?,token = ?,tokenname = ? where username = ?",
          [
            encryptedEmail,
            encryptedPassword,
            encryptedToken,
            encryptedTokenName,
            username
          ]);
      return 'Success';
    } catch (e) {
      FLog.error(
          className: 'MySqlUtils',
          methodName: 'updateUpyunManage',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      return "Error";
    } finally {
      await conn.close();
    }
  }

  static queryUpyunOperator({required String username}) async {
    var conn = await MySqlConnection.connect(settings);
    try {
      var results = await conn
          .query('select * from upyunoperator where username = ?', [username]);

      if (results.isEmpty) {
        return "Empty";
      }
      Map<String, dynamic> resultsMap = {};
      resultsMap.clear();
      for (var row in results) {
        //第一列是id
        int id = row[0];
        String bucket = await decryptSelf(row[1].toString());
        String email = await decryptSelf(row[2].toString());
        String operator = await decryptSelf(row[3].toString());
        String password = await decryptSelf(row[4].toString());
        resultsMap['id'] = id;
        resultsMap['bucket'] = bucket;
        resultsMap['email'] = email;
        resultsMap['operator'] = operator;
        resultsMap['password'] = password;
      }
      return resultsMap;
    } catch (e) {
      FLog.error(
          className: 'MySqlUtils',
          methodName: 'queryUpyunOperator',
          text: formatErrorMessage({'username': username}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      return "Error";
    } finally {
      await conn.close();
    }
  }

  static insertUpyunOperator({required List content}) async {
    var conn = await MySqlConnection.connect(settings);
    try {
      String bucket = content[0].toString();
      String email = content[1].toString();
      String operator = content[2].toString();
      String password = content[3].toString();
      String username = content[4].toString();

      String encryptedBucket = await encryptSelf(bucket);
      String encryptedEmail = await encryptSelf(email);
      String encryptedOperator = await encryptSelf(operator);
      String encryptedPassword = await encryptSelf(password);

      await conn.query(
          "insert into upyunoperator (bucket,email,operator,password,username) values (?,?,?,?,?)",
          [
            encryptedBucket,
            encryptedEmail,
            encryptedOperator,
            encryptedPassword,
            username
          ]);
      return 'Success';
    } catch (e) {
      FLog.error(
          className: 'MySqlUtils',
          methodName: 'insertUpyunOperator',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      return "Error";
    } finally {
      await conn.close();
    }
  }

  static updateUpyunOperator({required List content}) async {
    var conn = await MySqlConnection.connect(settings);

    try {
      String bucket = content[0].toString();
      String email = content[1].toString();
      String operator = content[2].toString();
      String password = content[3].toString();
      String username = content[4].toString();

      String encryptedBucket = await encryptSelf(bucket);
      String encryptedEmail = await encryptSelf(email);
      String encryptedOperator = await encryptSelf(operator);
      String encryptedPassword = await encryptSelf(password);

      await conn.query(
          "update upyunoperator set bucket = ?,email = ?,operator = ?,password = ? where username = ?",
          [
            encryptedBucket,
            encryptedEmail,
            encryptedOperator,
            encryptedPassword,
            username
          ]);
      return 'Success';
    } catch (e) {
      FLog.error(
          className: 'MySqlUtils',
          methodName: 'updateUpyunOperator',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      return "Error";
    } finally {
      await conn.close();
    }
  }

  static deleteUpyunOperator({required int id}) async {
    var conn = await MySqlConnection.connect(settings);
    try {
      await conn.query('delete from upyunoperator where id = ?', [id]);
      return 'Success';
    } catch (e) {
      FLog.error(
          className: 'MySqlUtils',
          methodName: 'deleteUpyunOperator',
          text: formatErrorMessage({'id': id}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      return "Error";
    } finally {
      await conn.close();
    }
  }

  static queryQiniuManage({required String username}) async {
    var conn = await MySqlConnection.connect(settings);
    try {
      var results = await conn
          .query('select * from qiniumanage where username = ?', [username]);

      if (results.isEmpty) {
        return "Empty";
      }
      Map<String, dynamic> resultsMap = {};
      resultsMap.clear();
      for (var row in results) {
        //第一列是id
        int id = row[0];
        String bucket = await decryptSelf(row[1].toString());
        String domain = await decryptSelf(row[2].toString());
        String area = await decryptSelf(row[3].toString());
        resultsMap['id'] = id;
        resultsMap['bucket'] = bucket;
        resultsMap['domain'] = domain;
        resultsMap['area'] = area;
      }
      return resultsMap;
    } catch (e) {
      FLog.error(
          className: 'MySqlUtils',
          methodName: 'queryQiniuManage',
          text: formatErrorMessage({'username': username}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      return "Error";
    } finally {
      await conn.close();
    }
  }

  static insertQiniuManage({required List content}) async {
    var conn = await MySqlConnection.connect(settings);
    try {
      String bucket = content[0].toString();
      String domain = content[1].toString();
      String area = content[2].toString();
      String username = content[3].toString();

      String encryptedBucket = await encryptSelf(bucket);
      String encryptedDomain = await encryptSelf(domain);
      String encryptedArea = await encryptSelf(area);

      await conn.query(
          "insert into qiniumanage (bucket,domain,area,username) values (?,?,?,?)",
          [encryptedBucket, encryptedDomain, encryptedArea, username]);
      return 'Success';
    } catch (e) {
      FLog.error(
          className: 'MySqlUtils',
          methodName: 'insertQiniuManage',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      return "Error";
    } finally {
      await conn.close();
    }
  }

  static updateQiniuManage({required List content}) async {
    var conn = await MySqlConnection.connect(settings);

    try {
      String bucket = content[0].toString();
      String domain = content[1].toString();
      String area = content[2].toString();
      String username = content[3].toString();

      String encryptedBucket = await encryptSelf(bucket);
      String encryptedDomain = await encryptSelf(domain);
      String encryptedArea = await encryptSelf(area);

      await conn.query(
          "update qiniumanage set bucket = ?,domain = ?,area = ? where username = ?",
          [encryptedBucket, encryptedDomain, encryptedArea, username]);
      return 'Success';
    } catch (e) {
      FLog.error(
          className: 'MySqlUtils',
          methodName: 'updateQiniuManage',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      return "Error";
    } finally {
      await conn.close();
    }
  }

  static queryFTP({required String username}) async {
    var conn = await MySqlConnection.connect(settings);
    try {
      var results =
          await conn.query('select * from ftp where username = ?', [username]);

      if (results.isEmpty) {
        return "Empty";
      }
      Map<String, dynamic> resultsMap = {};
      resultsMap.clear();
      for (var row in results) {
        //第一列是id
        String ftpHost = await decryptSelf(row[1].toString());
        String ftpPort = await decryptSelf(row[2].toString());
        String ftpUser = await decryptSelf(row[3].toString());
        String ftpPassword = await decryptSelf(row[4].toString());
        String ftpType = await decryptSelf(row[5].toString());
        String isAnonymous = await decryptSelf(row[6].toString());
        String uploadPath = await decryptSelf(row[7].toString());
        String ftpHomeDir = await decryptSelf(row[8].toString());

        resultsMap['ftpHost'] = ftpHost;
        resultsMap['ftpPort'] = ftpPort;
        resultsMap['ftpUser'] = ftpUser;
        resultsMap['ftpPassword'] = ftpPassword;
        resultsMap['ftpType'] = ftpType;
        resultsMap['isAnonymous'] = isAnonymous;
        resultsMap['uploadPath'] = uploadPath;
        resultsMap['ftpHomeDir'] = ftpHomeDir;
      }
      return resultsMap;
    } catch (e) {
      FLog.error(
          className: 'MySqlUtils',
          methodName: 'queryFTP',
          text: formatErrorMessage({'username': username}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      return "Error";
    } finally {
      await conn.close();
    }
  }

  static insertFTP({required List content}) async {
    var conn = await MySqlConnection.connect(settings);
    try {
      String ftpHost = content[0].toString();
      String ftpPort = content[1].toString();
      String ftpUser = content[2].toString();
      String ftpPassword = content[3].toString();
      String ftpType = content[4].toString();
      String isAnonymous = content[5].toString();
      String uploadPath = content[6].toString();
      String ftpHomeDir = content[7].toString();
      String username = content[8].toString();

      String encryptedFtpHost = await encryptSelf(ftpHost);
      String encryptedFtpPort = await encryptSelf(ftpPort);
      String encryptedFtpUser = await encryptSelf(ftpUser);
      String encryptedFtpPassword = await encryptSelf(ftpPassword);
      String encryptedFtpType = await encryptSelf(ftpType);
      String encryptedIsAnonymous = await encryptSelf(isAnonymous);
      String encryptedUploadPath = await encryptSelf(uploadPath);
      String encryptedFtpHomeDir = await encryptSelf(ftpHomeDir);

      await conn.query(
          "insert into ftp (ftpHost,ftpPort,ftpUser,ftpPassword,ftpType,isAnonymous,uploadPath,ftpHomeDir,username) values (?,?,?,?,?,?,?,?,?)",
          [
            encryptedFtpHost,
            encryptedFtpPort,
            encryptedFtpUser,
            encryptedFtpPassword,
            encryptedFtpType,
            encryptedIsAnonymous,
            encryptedUploadPath,
            encryptedFtpHomeDir,
            username
          ]);
      return 'Success';
    } catch (e) {
      FLog.error(
          className: 'MySqlUtils',
          methodName: 'insertFTP',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      return "Error";
    } finally {
      await conn.close();
    }
  }

  static updateFTP({required List content}) async {
    var conn = await MySqlConnection.connect(settings);

    try {
      String ftpHost = content[0].toString();
      String ftpPort = content[1].toString();
      String ftpUser = content[2].toString();
      String ftpPassword = content[3].toString();
      String ftpType = content[4].toString();
      String isAnonymous = content[5].toString();
      String uploadPath = content[6].toString();
      String ftpHomeDir = content[7].toString();
      String username = content[8].toString();

      String encryptedFtpHost = await encryptSelf(ftpHost);
      String encryptedFtpPort = await encryptSelf(ftpPort);
      String encryptedFtpUser = await encryptSelf(ftpUser);
      String encryptedFtpPassword = await encryptSelf(ftpPassword);
      String encryptedFtpType = await encryptSelf(ftpType);
      String encryptedIsAnonymous = await encryptSelf(isAnonymous);
      String encryptedUploadPath = await encryptSelf(uploadPath);
      String encryptedFtpHomeDir = await encryptSelf(ftpHomeDir);

      await conn.query(
          "update ftp set ftpHost = ?,ftpPort = ?,ftpUser = ?,ftpPassword = ?,ftpType = ?,isAnonymous = ?,uploadPath = ?,ftpHomeDir = ? where username = ?",
          [
            encryptedFtpHost,
            encryptedFtpPort,
            encryptedFtpUser,
            encryptedFtpPassword,
            encryptedFtpType,
            encryptedIsAnonymous,
            encryptedUploadPath,
            encryptedFtpHomeDir,
            username
          ]);
      return 'Success';
    } catch (e) {
      FLog.error(
          className: 'MySqlUtils',
          methodName: 'updateFTP',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      return "Error";
    } finally {
      await conn.close();
    }
  }

  static queryImgurManage({required String username}) async {
    var conn = await MySqlConnection.connect(settings);
    try {
      var results = await conn
          .query('select * from imgurmanage where username = ?', [username]);

      if (results.isEmpty) {
        return "Empty";
      }
      Map<String, dynamic> resultsMap = {};
      resultsMap.clear();
      for (var row in results) {
        //第一列是id
        String imguruser = await decryptSelf(row[1].toString());
        String clientid = await decryptSelf(row[2].toString());
        String clientsecret = await decryptSelf(row[3].toString());
        String accesstoken = await decryptSelf(row[4].toString());
        String proxy = await decryptSelf(row[5].toString());

        resultsMap['imguruser'] = imguruser;
        resultsMap['clientid'] = clientid;
        resultsMap['clientsecret'] = clientsecret;
        resultsMap['accesstoken'] = accesstoken;
        resultsMap['proxy'] = proxy;
      }
      return resultsMap;
    } catch (e) {
      FLog.error(
          className: 'MySqlUtils',
          methodName: 'queryImgurManage',
          text: formatErrorMessage({'username': username}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      return "Error";
    } finally {
      await conn.close();
    }
  }

  static insertImgurManage({required List content}) async {
    var conn = await MySqlConnection.connect(settings);
    try {
      String imguruser = content[0].toString();
      String clientid = content[1].toString();
      String clientsecret = content[2].toString();
      String accesstoken = content[3].toString();
      String proxy = content[4].toString();
      String username = content[5].toString();

      String encryptedImguruser = await encryptSelf(imguruser);
      String encryptedClientid = await encryptSelf(clientid);
      String encryptedClientsecret = await encryptSelf(clientsecret);
      String encryptedAccesstoken = await encryptSelf(accesstoken);
      String encryptedProxy = await encryptSelf(proxy);

      await conn.query(
          "insert into imgurmanage (imguruser,clientid,clientsecret,accesstoken,proxy,username) values (?,?,?,?,?,?)",
          [
            encryptedImguruser,
            encryptedClientid,
            encryptedClientsecret,
            encryptedAccesstoken,
            encryptedProxy,
            username
          ]);
      return 'Success';
    } catch (e) {
      FLog.error(
          className: 'MySqlUtils',
          methodName: 'insertImgurManage',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      return "Error";
    } finally {
      await conn.close();
    }
  }

  static updateImgurManage({required List content}) async {
    var conn = await MySqlConnection.connect(settings);

    try {
      String imguruser = content[0].toString();
      String clientid = content[1].toString();
      String clientsecret = content[2].toString();
      String accesstoken = content[3].toString();
      String proxy = content[4].toString();
      String username = content[5].toString();

      String encryptedImguruser = await encryptSelf(imguruser);
      String encryptedClientid = await encryptSelf(clientid);
      String encryptedClientsecret = await encryptSelf(clientsecret);
      String encryptedAccesstoken = await encryptSelf(accesstoken);
      String encryptedProxy = await encryptSelf(proxy);

      await conn.query(
          "update imgurmanage set imguruser = ?,clientid = ?,clientsecret = ?,accesstoken = ?,proxy = ? where username = ?",
          [
            encryptedImguruser,
            encryptedClientid,
            encryptedClientsecret,
            encryptedAccesstoken,
            encryptedProxy,
            username
          ]);
      return 'Success';
    } catch (e) {
      FLog.error(
          className: 'MySqlUtils',
          methodName: 'updateImgurManage',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      return "Error";
    } finally {
      await conn.close();
    }
  }

      static queryAws({required String username}) async {
    var conn = await MySqlConnection.connect(settings);
    try {
      var results =
          await conn.query('select * from aws where username = ?', [username]);

      if (results.isEmpty) {
        return "Empty";
      }
      Map<String, dynamic> resultsMap = {};
      resultsMap.clear();
      for (var row in results) {
        //第一列是id
        String accessKeyID = await decryptSelf(row[1].toString());
        String secretAccessKey = await decryptSelf(row[2].toString());
        String bucket = await decryptSelf(row[3].toString());
        String endpoint = await decryptSelf(row[4].toString());
        String region = await decryptSelf(row[5].toString());
        String uploadPath = await decryptSelf(row[6].toString());
        String customUrl = await decryptSelf(row[7].toString());

        resultsMap['accessKeyID'] = accessKeyID;
        resultsMap['secretAccessKey'] = secretAccessKey;
        resultsMap['bucket'] = bucket;
        resultsMap['endpoint'] = endpoint;
        resultsMap['region'] = region;
        resultsMap['uploadPath'] = uploadPath;
        resultsMap['customUrl'] = customUrl;
      }
      return resultsMap;
    } catch (e) {
      FLog.error(
          className: 'MySqlUtils',
          methodName: 'queryAws',
          text: formatErrorMessage({'username': username}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      return "Error";
    } finally {
      await conn.close();
    }
  }

  static insertAws({required List content}) async {
    var conn = await MySqlConnection.connect(settings);
    try {
      String accessKeyID = content[0].toString();
      String secretAccessKey = content[1].toString();
      String bucket = content[2].toString();
      String endpoint = content[3].toString();
      String region = content[4].toString();
      String uploadPath = content[5].toString();
      String customUrl = content[6].toString();
      String username = content[7].toString();

      String encryptedAccessKeyID = await encryptSelf(accessKeyID);
      String encryptedSecretAccessKey = await encryptSelf(secretAccessKey);
      String encryptedBucket = await encryptSelf(bucket);
      String encryptedEndpoint = await encryptSelf(endpoint);
      String encryptedRegion = await encryptSelf(region);
      String encryptedUploadPath = await encryptSelf(uploadPath);
      String encryptedCustomUrl = await encryptSelf(customUrl);


      await conn.query(
          "insert into aws (accessKeyID,secretAccessKey,bucket,endpoint,region,uploadPath,customUrl,username) values (?,?,?,?,?,?,?,?)",
          [
            encryptedAccessKeyID,
            encryptedSecretAccessKey,
            encryptedBucket,
            encryptedEndpoint,
            encryptedRegion,
            encryptedUploadPath,
            encryptedCustomUrl,
            username
          ]);
      return 'Success';
    } catch (e) {
      FLog.error(
          className: 'MySqlUtils',
          methodName: 'insertAws',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      return "Error";
    } finally {
      await conn.close();
    }
  }

  static updateAws({required List content}) async {
    var conn = await MySqlConnection.connect(settings);

    try {
      String accessKeyID = content[0].toString();
      String secretAccessKey = content[1].toString();
      String bucket = content[2].toString();
      String endpoint = content[3].toString();
      String region = content[4].toString();
      String uploadPath = content[5].toString();
      String customUrl = content[6].toString();
      String username = content[7].toString();

      String encryptedAccessKeyID = await encryptSelf(accessKeyID);
      String encryptedSecretAccessKey = await encryptSelf(secretAccessKey);
      String encryptedBucket = await encryptSelf(bucket);
      String encryptedEndpoint = await encryptSelf(endpoint);
      String encryptedRegion = await encryptSelf(region);
      String encryptedUploadPath = await encryptSelf(uploadPath);
      String encryptedCustomUrl = await encryptSelf(customUrl);
      
      await conn.query(
          "update aws set accessKeyID = ?,secretAccessKey = ?,bucket = ?,endpoint = ?,region = ?,uploadPath = ?,customUrl = ? where username = ?",
          [
            encryptedAccessKeyID,
            encryptedSecretAccessKey,
            encryptedBucket,
            encryptedEndpoint,
            encryptedRegion,
            encryptedUploadPath,
            encryptedCustomUrl,
            username
          ]);
      return 'Success';
    } catch (e) {
      FLog.error(
          className: 'MySqlUtils',
          methodName: 'updateAws',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      return "Error";
    } finally {
      await conn.close();
    }
  }
}
