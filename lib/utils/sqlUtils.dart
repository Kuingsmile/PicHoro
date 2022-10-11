import 'package:horopic/utils/global.dart';
import 'package:mysql1/mysql1.dart';
import 'package:dart_des/dart_des.dart';
import 'package:convert/convert.dart';

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
        String strategy_id = await decryptSelf(row[2].toString());
        String token = await decryptSelf(row[3].toString());
        resultsMap['host'] = host;
        resultsMap['strategy_id'] = strategy_id;
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

  static insertUser({required List content}) async {
    var conn = await MySqlConnection.connect(settings);
    try {
      String valuename = content[0].toString();
      String valuepassword = content[1].toString();
      String valuedefaultPShost = content[2].toString();
      String encryptedPassword = await encryptSelf(valuepassword);
      var results = await conn.query(
          "insert into users (username,password,defaultPShost) values (?,?,?)",
          [valuename, encryptedPassword, valuedefaultPShost]);
      return 'Success';
    } catch (e) {
      return "Error";
    } finally {
      await conn.close();
    }
  }

  static insertLankong({required List content}) async {
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
          "insert into lankong (hosts,strategy_id,token,username) values (?,?,?,?)",
          [encryptedHost, encryptedStrategy_id, encryptedToken, username]);
      return 'Success';
    } catch (e) {
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
          "update smms set ,token = ? where username = ?",
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
}
