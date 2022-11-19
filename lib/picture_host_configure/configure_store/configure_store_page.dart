import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluro/fluro.dart';
import 'package:f_logs/f_logs.dart';

import 'package:horopic/picture_host_configure/configure_store/configure_store_file.dart';
import 'package:horopic/picture_host_configure/configure_page/configure_export.dart';
import 'package:horopic/picture_host_configure/configure_store/configure_template.dart';

import 'package:horopic/router/application.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:horopic/utils/sql_utils.dart';
import 'package:horopic/utils/global.dart';

class ConfigureStorePage extends StatefulWidget {
  final String psHost;
  const ConfigureStorePage({Key? key, required this.psHost}) : super(key: key);

  @override
  ConfigureStorePageState createState() => ConfigureStorePageState();
}

class ConfigureStorePageState extends State<ConfigureStorePage> {
  Map<String, String> psNameTranslate = {
    'aliyun': '阿里云',
    'qiniu': '七牛云',
    'tencent': '腾讯云',
    'upyun': '又拍云',
    'aws': 'S3兼容平台',
    'ftp': 'FTP',
    'github': 'GitHub',
    'sm.ms': 'SM.MS',
    'imgur': 'Imgur',
    'lsky.pro': '兰空图床',
  };

  Map psNameToRouter = {
    'aliyun': '/aliyunConfigureStoreEditPage',
    'aws': '/awsConfigureStoreEditPage',
    'ftp': '/ftpConfigureStoreEditPage',
    'github': '/githubConfigureStoreEditPage',
    'imgur': '/imgurConfigureStoreEditPage',
    'lsky.pro': '/lskyConfigureStoreEditPage',
    'qiniu': '/qiniuConfigureStoreEditPage',
    'sm.ms': '/smmsConfigureStoreEditPage',
    'tencent': '/tencentConfigureStoreEditPage',
    'upyun': '/upyunConfigureStoreEditPage',
  };

  @override
  void initState() {
    super.initState();
  }

  initConfigMap() async {
    Map configMap = await ConfigureStoreFile().readConfigureFile(widget.psHost);
    return configMap;
  }

  List<Widget> buildPsInfoListTile(String storeName, Map pictureHostInfo) {
    String remarkName = pictureHostInfo['remarkName']!;
    List keys = pictureHostInfo.keys.toList();
    List values = pictureHostInfo.values.toList();
    List<Widget> psInfoListTile = [];
    psInfoListTile.add(
      ListTile(
        leading:
            const Icon(Icons.info, color: Color.fromARGB(255, 88, 171, 240)),
        title: Text(remarkName == ConfigureTemplate.placeholder
            ? '配置$storeName'
            : '配置$storeName->$remarkName'),
        trailing: IconButton(
          icon: const Icon(Icons.more_horiz_outlined, color: Colors.amber),
          onPressed: () {
            showModalBottomSheet(
                isScrollControlled: true,
                context: context,
                builder: (context) {
                  return buildBottomSheetWidget(
                      context, storeName, pictureHostInfo);
                });
          },
        ),
      ),
    );
    if (ConfigureStoreFile().checkIfOneUndetermined(pictureHostInfo)) {
      psInfoListTile.add(
        ListTile(
          title: Center(
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                Text('尚未配置',
                    style: TextStyle(
                        color: Color.fromARGB(255, 88, 171, 240),
                        fontSize: 16)),
              ])),
        ),
      );
    } else {
      for (var i = 0; i < keys.length; i++) {
        psInfoListTile.add(Table(
          children: [
            TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: SelectableText(keys[i],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.black,
                      )),
                ),
                SelectableText(
                    values[i] == ConfigureTemplate.placeholder
                        ? '未配置'
                        : values[i],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.black54,
                    )),
              ],
            ),
          ],
        ));
        if (i != keys.length - 1) {
          psInfoListTile.add(const Divider(
            height: 2,
            color: Colors.transparent,
          ));
        }
      }
    }
    psInfoListTile.add(const Divider(
      height: 2,
      color: Colors.black,
    ));
    return psInfoListTile;
  }

  buildAllPsInfoListTile(Map configMap) {
    List<Widget> allPsInfoListTile = [];
    String alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    for (var element in alphabet.split('')) {
      allPsInfoListTile
          .addAll(buildPsInfoListTile(element, configMap[element]!));
    }
    return allPsInfoListTile;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: Text(psNameTranslate[widget.psHost]!),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.delete_forever,
              size: 30,
            ),
            onPressed: () async {
              showCupertinoAlertDialogWithConfirmFunc(
                title: '通知',
                content: '是否重置所有已保存配置?',
                context: context,
                onConfirm: () async {
                  Navigator.pop(context);
                  await ConfigureStoreFile().resetConfigureFile(widget.psHost);
                  setState(() {
                    showToast('重置成功');
                  });
                },
              );
            },
          ),
        ],
      ),
      body: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return FutureBuilder(
            future: initConfigMap(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                return ListView(
                  children: buildAllPsInfoListTile(snapshot.data),
                );
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(
            height: 40,
            width: 40,
            child: FloatingActionButton(
              backgroundColor: const Color.fromARGB(255, 198, 135, 235),
              heroTag: 'exportConfig',
              onPressed: () async {
                var result = await ConfigureStoreFile()
                    .exportConfigureToJson(widget.psHost);
                await Clipboard.setData(ClipboardData(text: result));
                showToast('已导出到剪贴板');
              },
              child: const Icon(Icons.outbox_outlined),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          SizedBox(
            height: 40,
            width: 40,
            child: FloatingActionButton(
              backgroundColor: const Color.fromARGB(255, 127, 165, 37),
              heroTag: 'importConfig',
              onPressed: () async {
                var clipboardData = await Clipboard.getData('text/plain');
                if (clipboardData == null) {
                  showToast('剪贴板为空');
                  return;
                }
                try {
                  await ConfigureStoreFile().importConfigureFromJson(
                      widget.psHost, clipboardData.text!);
                  setState(() {
                    showToast('导入成功');
                  });
                } catch (e) {
                  showToast('导入失败');
                  return;
                }
              },
              child: const Icon(Icons.inbox_outlined),
            ),
          ),
        ],
      ),
    );
  }

  validateUndetermined(List toCheckList) {
    for (var element in toCheckList) {
      if (element == ConfigureTemplate.placeholder) {
        return false;
      }
    }
    return true;
  }

  Widget buildBottomSheetWidget(
      BuildContext context, String storeName, Map psInfo) {
    String remarkName = psInfo['remarkName']!;

    return SingleChildScrollView(
      child: Column(
        children: [
          ListTile(
            dense: true,
            leading: const Icon(Icons.settings),
            minLeadingWidth: 0,
            title: Text(
                remarkName == ConfigureTemplate.placeholder
                    ? '配置$storeName'
                    : '配置$storeName-$remarkName',
                style: const TextStyle(fontSize: 15)),
          ),
          const Divider(
            height: 0.1,
            color: Color.fromARGB(255, 3, 3, 3),
          ),
          ListTile(
            leading: const Icon(
              Icons.edit,
              color: Color.fromARGB(255, 97, 141, 236),
            ),
            minLeadingWidth: 0,
            title: const Text('修改配置'),
            onTap: () async {
              Navigator.pop(context);
              Application.router
                  .navigateTo(
                    context,
                    '${psNameToRouter[widget.psHost]!}?storeKey=${Uri.encodeComponent(storeName)}&psInfo=${Uri.encodeComponent(jsonEncode(psInfo))}',
                    transition: TransitionType.cupertino,
                  )
                  .then((value) => setState(() {}));
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.outbox_outlined,
              color: Color.fromARGB(255, 97, 141, 236),
            ),
            minLeadingWidth: 0,
            title: const Text('导出配置'),
            onTap: () async {
              Navigator.pop(context);
              var result = await ConfigureStoreFile()
                  .exportConfigureKeyToJson(widget.psHost, storeName);
              await Clipboard.setData(ClipboardData(text: result));
              showToast('已复制到剪贴板');
            },
          ),
          const Divider(
            height: 0.1,
            color: Color.fromARGB(255, 230, 230, 230),
          ),
          ListTile(
              leading: const Icon(
                Icons.check_box_outlined,
                color: Color.fromARGB(255, 97, 141, 236),
              ),
              minLeadingWidth: 0,
              title: const Text('替代图床默认配置'),
              onTap: () async {
                Navigator.pop(context);
                if (widget.psHost == 'aliyun') {
                  try {
                    String keyId = psInfo['keyId']!;
                    String keySecret = psInfo['keySecret']!;
                    String bucket = psInfo['bucket']!;
                    String area = psInfo['area']!;
                    String path = psInfo['path']!;
                    String customUrl = psInfo['customUrl']!;
                    String options = psInfo['options']!;
                    bool valid = validateUndetermined([
                      keyId,
                      keySecret,
                      bucket,
                      area,
                    ]);
                    if (!valid) {
                      showToast('请先去设置参数');
                      return;
                    }
                    if (path == ConfigureTemplate.placeholder) {
                      path = 'None';
                    }
                    if (customUrl == ConfigureTemplate.placeholder) {
                      customUrl = 'None';
                    }
                    if (options == ConfigureTemplate.placeholder) {
                      options = 'None';
                    }
                    List sqlconfig = [];
                    sqlconfig.add(keyId);
                    sqlconfig.add(keySecret);
                    sqlconfig.add(bucket);
                    sqlconfig.add(area);
                    sqlconfig.add(path);
                    sqlconfig.add(customUrl);
                    sqlconfig.add(options);
                    String defaultUser = await Global.getUser();
                    sqlconfig.add(defaultUser);
                    var queryAliyun =
                        await MySqlUtils.queryAliyun(username: defaultUser);
                    var queryuser =
                        await MySqlUtils.queryUser(username: defaultUser);

                    if (queryuser == 'Empty') {
                      return showToast('请先登录');
                    }
                    var sqlResult = '';

                    if (queryAliyun == 'Empty') {
                      sqlResult =
                          await MySqlUtils.insertAliyun(content: sqlconfig);
                    } else {
                      sqlResult =
                          await MySqlUtils.updateAliyun(content: sqlconfig);
                    }
                    if (sqlResult == "Success") {
                      final aliyunConfig = AliyunConfigModel(keyId, keySecret,
                          bucket, area, path, customUrl, options);
                      final aliyunConfigJson = jsonEncode(aliyunConfig);
                      final aliyunConfigFile =
                          await AliyunConfigState().localFile;
                      await aliyunConfigFile.writeAsString(aliyunConfigJson);
                      return showToast('设置成功');
                    } else {
                      return showToast('设置失败');
                    }
                  } catch (e) {
                    FLog.error(
                        className: 'AliyunConfigureStorePage',
                        methodName: 'saveAliyunConfig',
                        text: formatErrorMessage({}, e.toString()),
                        dataLogType: DataLogType.ERRORS.toString());
                    return showToast('保存失败');
                  }
                } else if (widget.psHost == 'aws') {
                  try {
                    String accessKeyId = psInfo['accessKeyId']!;
                    String secretAccessKey = psInfo['secretAccessKey']!;
                    String bucket = psInfo['bucket']!;
                    String endpoint = psInfo['endpoint']!;
                    String region = psInfo['region']!;
                    String uploadPath = psInfo['uploadPath']!;
                    String customUrl = psInfo['customUrl']!;
                    bool valid = validateUndetermined([
                      accessKeyId,
                      secretAccessKey,
                      bucket,
                      endpoint,
                    ]);
                    if (!valid) {
                      showToast('请先去设置参数');
                      return;
                    }
                    if (uploadPath == ConfigureTemplate.placeholder) {
                      uploadPath = 'None';
                    }
                    if (customUrl == ConfigureTemplate.placeholder) {
                      customUrl = 'None';
                    }
                    if (region == ConfigureTemplate.placeholder) {
                      region = 'None';
                    }
                    List sqlconfig = [];
                    sqlconfig.add(accessKeyId);
                    sqlconfig.add(secretAccessKey);
                    sqlconfig.add(bucket);
                    sqlconfig.add(endpoint);
                    sqlconfig.add(region);
                    sqlconfig.add(uploadPath);
                    sqlconfig.add(customUrl);
                    String defaultUser = await Global.getUser();
                    sqlconfig.add(defaultUser);
                    var queryAws =
                        await MySqlUtils.queryAws(username: defaultUser);
                    var queryuser =
                        await MySqlUtils.queryUser(username: defaultUser);

                    if (queryuser == 'Empty') {
                      return showToast('请先登录');
                    }
                    var sqlResult = '';

                    if (queryAws == 'Empty') {
                      sqlResult =
                          await MySqlUtils.insertAws(content: sqlconfig);
                    } else {
                      sqlResult =
                          await MySqlUtils.updateAws(content: sqlconfig);
                    }
                    if (sqlResult == "Success") {
                      final awsConfig = AwsConfigModel(
                        accessKeyId,
                        secretAccessKey,
                        bucket,
                        endpoint,
                        region,
                        uploadPath,
                        customUrl,
                      );
                      final awsConfigJson = jsonEncode(awsConfig);
                      final awsConfigFile = await AwsConfigState().localFile;
                      await awsConfigFile.writeAsString(awsConfigJson);
                      return showToast('设置成功');
                    } else {
                      return showToast('设置失败');
                    }
                  } catch (e) {
                    FLog.error(
                        className: 'AwsConfigureStorePage',
                        methodName: 'saveAwsConfig',
                        text: formatErrorMessage({}, e.toString()),
                        dataLogType: DataLogType.ERRORS.toString());
                    return showToast('保存失败');
                  }
                } else if (widget.psHost == 'ftp') {
                  try {
                    String ftpHost = psInfo['ftpHost']!;
                    String ftpPort = psInfo['ftpPort']!;
                    String ftpUser = psInfo['ftpUser']!;
                    String ftpPassword = psInfo['ftpPassword']!;
                    String ftpType = psInfo['ftpType']!;
                    String isAnonymous = psInfo['isAnonymous']!.toString();
                    String uploadPath = psInfo['uploadPath']!;
                    String ftpHomeDir = psInfo['ftpHomeDir']!;
                    bool valid = validateUndetermined([
                      ftpHost,
                      ftpPort,
                      ftpType,
                      isAnonymous,
                    ]);
                    if (!valid) {
                      showToast('请先去设置参数');
                      return;
                    }
                    if (ftpUser == ConfigureTemplate.placeholder) {
                      ftpUser = 'None';
                    }
                    if (ftpPassword == ConfigureTemplate.placeholder) {
                      ftpPassword = 'None';
                    }
                    if (uploadPath == ConfigureTemplate.placeholder) {
                      uploadPath = 'None';
                    }
                    if (ftpHomeDir == ConfigureTemplate.placeholder) {
                      ftpHomeDir = 'None';
                    }
                    List sqlconfig = [];
                    sqlconfig.add(ftpHost);
                    sqlconfig.add(ftpPort);
                    sqlconfig.add(ftpUser);
                    sqlconfig.add(ftpPassword);
                    sqlconfig.add(ftpType);
                    sqlconfig.add(isAnonymous);
                    sqlconfig.add(uploadPath);
                    sqlconfig.add(ftpHomeDir);
                    String defaultUser = await Global.getUser();
                    sqlconfig.add(defaultUser);
                    var queryFtp =
                        await MySqlUtils.queryFTP(username: defaultUser);
                    var queryuser =
                        await MySqlUtils.queryUser(username: defaultUser);

                    if (queryuser == 'Empty') {
                      return showToast('请先登录');
                    }
                    var sqlResult = '';

                    if (queryFtp == 'Empty') {
                      sqlResult =
                          await MySqlUtils.insertFTP(content: sqlconfig);
                    } else {
                      sqlResult =
                          await MySqlUtils.updateFTP(content: sqlconfig);
                    }
                    if (sqlResult == "Success") {
                      final ftpConfig = FTPConfigModel(
                        ftpHost,
                        ftpPort,
                        ftpUser,
                        ftpPassword,
                        ftpType,
                        isAnonymous,
                        uploadPath,
                        ftpHomeDir,
                      );
                      final ftpConfigJson = jsonEncode(ftpConfig);
                      final ftpConfigFile = await FTPConfigState().localFile;
                      await ftpConfigFile.writeAsString(ftpConfigJson);
                      return showToast('设置成功');
                    } else {
                      return showToast('设置失败');
                    }
                  } catch (e) {
                    FLog.error(
                        className: 'FtpConfigureStorePage',
                        methodName: 'saveFtpConfig',
                        text: formatErrorMessage({}, e.toString()),
                        dataLogType: DataLogType.ERRORS.toString());
                    return showToast('保存失败');
                  }
                } else if (widget.psHost == 'github') {
                  try {
                    String githubusername = psInfo['githubusername']!;
                    String repo = psInfo['repo']!;
                    String token = psInfo['token']!;
                    String storePath = psInfo['storePath']!;
                    String branch = psInfo['branch']!;
                    String customDomain = psInfo['customDomain']!;
                    bool valid = validateUndetermined(
                        [githubusername, repo, token, branch]);
                    if (!valid) {
                      showToast('请先去设置参数');
                      return;
                    }
                    if (storePath == ConfigureTemplate.placeholder) {
                      storePath = 'None';
                    }
                    if (customDomain == ConfigureTemplate.placeholder) {
                      customDomain = 'None';
                    }
                    List sqlconfig = [];
                    sqlconfig.add(githubusername);
                    sqlconfig.add(repo);
                    sqlconfig.add(token);
                    sqlconfig.add(storePath);
                    sqlconfig.add(branch);
                    sqlconfig.add(customDomain);
                    String defaultUser = await Global.getUser();
                    sqlconfig.add(defaultUser);
                    var queryGithub =
                        await MySqlUtils.queryGithub(username: defaultUser);
                    var queryuser =
                        await MySqlUtils.queryUser(username: defaultUser);

                    if (queryuser == 'Empty') {
                      return showToast('请先登录');
                    }
                    var sqlResult = '';

                    if (queryGithub == 'Empty') {
                      sqlResult =
                          await MySqlUtils.insertGithub(content: sqlconfig);
                    } else {
                      sqlResult =
                          await MySqlUtils.updateGithub(content: sqlconfig);
                    }
                    if (sqlResult == "Success") {
                      final githubConfig = GithubConfigModel(
                        githubusername,
                        repo,
                        token,
                        storePath,
                        branch,
                        customDomain,
                      );
                      final githubConfigJson = jsonEncode(githubConfig);
                      final githubConfigFile =
                          await GithubConfigState().localFile;
                      await githubConfigFile.writeAsString(githubConfigJson);
                      return showToast('设置成功');
                    } else {
                      return showToast('设置失败');
                    }
                  } catch (e) {
                    FLog.error(
                        className: 'GithubConfigureStorePage',
                        methodName: 'saveGithubConfig',
                        text: formatErrorMessage({}, e.toString()),
                        dataLogType: DataLogType.ERRORS.toString());
                    return showToast('保存失败');
                  }
                } else if (widget.psHost == 'imgur') {
                  try {
                    String clientId = psInfo['clientId']!;
                    String proxy = psInfo['proxy']!;
                    bool valid = validateUndetermined([
                      clientId,
                    ]);
                    if (!valid) {
                      showToast('请先去设置参数');
                      return;
                    }
                    if (proxy == ConfigureTemplate.placeholder) {
                      proxy = 'None';
                    }
                    List sqlconfig = [];
                    sqlconfig.add(clientId);
                    sqlconfig.add(proxy);
                    String defaultUser = await Global.getUser();
                    sqlconfig.add(defaultUser);
                    var queryImgur =
                        await MySqlUtils.queryImgur(username: defaultUser);
                    var queryuser =
                        await MySqlUtils.queryUser(username: defaultUser);

                    if (queryuser == 'Empty') {
                      return showToast('请先登录');
                    }
                    var sqlResult = '';

                    if (queryImgur == 'Empty') {
                      sqlResult =
                          await MySqlUtils.insertImgur(content: sqlconfig);
                    } else {
                      sqlResult =
                          await MySqlUtils.updateImgur(content: sqlconfig);
                    }
                    if (sqlResult == "Success") {
                      final imgurConfig = ImgurConfigModel(
                        clientId,
                        proxy,
                      );
                      final imgurConfigJson = jsonEncode(imgurConfig);
                      final imgurConfigFile =
                          await ImgurConfigState().localFile;
                      await imgurConfigFile.writeAsString(imgurConfigJson);
                      return showToast('设置成功');
                    } else {
                      return showToast('设置失败');
                    }
                  } catch (e) {
                    FLog.error(
                        className: 'ImgurConfigureStorePage',
                        methodName: 'saveImgurConfig',
                        text: formatErrorMessage({}, e.toString()),
                        dataLogType: DataLogType.ERRORS.toString());
                    return showToast('保存失败');
                  }
                } else if (widget.psHost == 'lsky.pro') {
                  try {
                    String host = psInfo['host']!;
                    String token = psInfo['token']!;
                    String strategyId = psInfo['strategy_id']!.toString();
                    String albumId = psInfo['album_id']!.toString();
                    bool valid = validateUndetermined([
                      host,
                      token,
                      strategyId,
                    ]);
                    if (!valid) {
                      showToast('请先去设置参数');
                      return;
                    }
                    if (albumId == ConfigureTemplate.placeholder) {
                      albumId = 'None';
                    }
                    List sqlconfig = [];
                    sqlconfig.add(host);
                    sqlconfig.add(token);
                    sqlconfig.add(strategyId);
                    sqlconfig.add(albumId);
                    String defaultUser = await Global.getUser();
                    sqlconfig.add(defaultUser);
                    var queryLskypro =
                        await MySqlUtils.queryLankong(username: defaultUser);
                    var queryuser =
                        await MySqlUtils.queryUser(username: defaultUser);

                    if (queryuser == 'Empty') {
                      return showToast('请先登录');
                    }
                    var sqlResult = '';

                    if (queryLskypro == 'Empty') {
                      sqlResult =
                          await MySqlUtils.insertLankong(content: sqlconfig);
                    } else {
                      sqlResult =
                          await MySqlUtils.updateLankong(content: sqlconfig);
                    }
                    if (sqlResult == "Success") {
                      final lskyproConfig = HostConfigModel(
                        host,
                        token,
                        strategyId,
                        albumId,
                      );
                      final lskyproConfigJson = jsonEncode(lskyproConfig);
                      final lskyproConfigFile =
                          await HostConfigState().localFile;
                      await lskyproConfigFile.writeAsString(lskyproConfigJson);
                      return showToast('设置成功');
                    } else {
                      return showToast('设置失败');
                    }
                  } catch (e) {
                    FLog.error(
                        className: 'LskyproConfigureStorePage',
                        methodName: 'saveLskyProConfig',
                        text: formatErrorMessage({}, e.toString()),
                        dataLogType: DataLogType.ERRORS.toString());
                    return showToast('保存失败');
                  }
                } else if (widget.psHost == 'qiniu') {
                  try {
                    String accessKey = psInfo['accessKey']!;
                    String secretKey = psInfo['secretKey']!;
                    String bucket = psInfo['bucket']!;
                    String url = psInfo['url']!;
                    String area = psInfo['area']!;
                    String options = psInfo['options']!;
                    String path = psInfo['path']!;
                    bool valid = validateUndetermined([
                      accessKey,
                      secretKey,
                      bucket,
                      url,
                      area,
                    ]);
                    if (!valid) {
                      showToast('请先去设置参数');
                      return;
                    }
                    if (options == ConfigureTemplate.placeholder) {
                      options = 'None';
                    }
                    if (path == ConfigureTemplate.placeholder) {
                      path = 'None';
                    }
                    List sqlconfig = [];
                    sqlconfig.add(accessKey);
                    sqlconfig.add(secretKey);
                    sqlconfig.add(bucket);
                    sqlconfig.add(url);
                    sqlconfig.add(area);
                    sqlconfig.add(options);
                    sqlconfig.add(path);
                    String defaultUser = await Global.getUser();
                    sqlconfig.add(defaultUser);
                    var queryQiniu =
                        await MySqlUtils.queryQiniu(username: defaultUser);
                    var queryuser =
                        await MySqlUtils.queryUser(username: defaultUser);

                    if (queryuser == 'Empty') {
                      return showToast('请先登录');
                    }
                    var sqlResult = '';

                    if (queryQiniu == 'Empty') {
                      sqlResult =
                          await MySqlUtils.insertQiniu(content: sqlconfig);
                    } else {
                      sqlResult =
                          await MySqlUtils.updateQiniu(content: sqlconfig);
                    }
                    if (sqlResult == "Success") {
                      final qiniuConfig = QiniuConfigModel(
                        accessKey,
                        secretKey,
                        bucket,
                        url,
                        area,
                        options,
                        path,
                      );
                      final qiniuConfigJson = jsonEncode(qiniuConfig);
                      final qiniuConfigFile =
                          await QiniuConfigState().localFile;
                      await qiniuConfigFile.writeAsString(qiniuConfigJson);
                      return showToast('设置成功');
                    } else {
                      return showToast('设置失败');
                    }
                  } catch (e) {
                    FLog.error(
                        className: 'QiniuConfigureStorePage',
                        methodName: 'saveQiniuConfig',
                        text: formatErrorMessage({}, e.toString()),
                        dataLogType: DataLogType.ERRORS.toString());
                    return showToast('保存失败');
                  }
                } else if (widget.psHost == 'sm.ms') {
                  try {
                    String token = psInfo['token']!;
                    bool valid = validateUndetermined([
                      token,
                    ]);
                    if (!valid) {
                      showToast('请先去设置参数');
                      return;
                    }

                    List sqlconfig = [];
                    sqlconfig.add(token);

                    String defaultUser = await Global.getUser();
                    sqlconfig.add(defaultUser);
                    var querySmms =
                        await MySqlUtils.querySmms(username: defaultUser);
                    var queryuser =
                        await MySqlUtils.queryUser(username: defaultUser);

                    if (queryuser == 'Empty') {
                      return showToast('请先登录');
                    }
                    var sqlResult = '';

                    if (querySmms == 'Empty') {
                      sqlResult =
                          await MySqlUtils.insertSmms(content: sqlconfig);
                    } else {
                      sqlResult =
                          await MySqlUtils.updateSmms(content: sqlconfig);
                    }
                    if (sqlResult == "Success") {
                      final smmsConfig = SmmsConfigModel(
                        token,
                      );
                      final smmsConfigJson = jsonEncode(smmsConfig);
                      final smmsConfigFile = await SmmsConfigState().localFile;
                      await smmsConfigFile.writeAsString(smmsConfigJson);
                      return showToast('设置成功');
                    } else {
                      return showToast('设置失败');
                    }
                  } catch (e) {
                    FLog.error(
                        className: 'SmmsConfigureStorePage',
                        methodName: 'saveSmmsConfig',
                        text: formatErrorMessage({}, e.toString()),
                        dataLogType: DataLogType.ERRORS.toString());
                    return showToast('保存失败');
                  }
                } else if (widget.psHost == 'tencent') {
                  try {
                    String secretId = psInfo['secretId']!;
                    String secretKey = psInfo['secretKey']!;
                    String bucket = psInfo['bucket']!;
                    String appId = psInfo['appId']!;
                    String area = psInfo['area']!;
                    String path = psInfo['path']!;
                    String customUrl = psInfo['customUrl']!;
                    String options = psInfo['options']!;
                    bool valid = validateUndetermined([
                      secretId,
                      secretKey,
                      bucket,
                      appId,
                      area,
                    ]);
                    if (!valid) {
                      showToast('请先去设置参数');
                      return;
                    }
                    if (path == ConfigureTemplate.placeholder) {
                      path = 'None';
                    }
                    if (customUrl == ConfigureTemplate.placeholder) {
                      customUrl = 'None';
                    }
                    if (options == ConfigureTemplate.placeholder) {
                      options = 'None';
                    }
                    List sqlconfig = [];
                    sqlconfig.add(secretId);
                    sqlconfig.add(secretKey);
                    sqlconfig.add(bucket);
                    sqlconfig.add(appId);
                    sqlconfig.add(area);
                    sqlconfig.add(path);
                    sqlconfig.add(customUrl);
                    sqlconfig.add(options);
                    String defaultUser = await Global.getUser();
                    sqlconfig.add(defaultUser);
                    var queryTencent =
                        await MySqlUtils.queryTencent(username: defaultUser);
                    var queryuser =
                        await MySqlUtils.queryUser(username: defaultUser);

                    if (queryuser == 'Empty') {
                      return showToast('请先登录');
                    }
                    var sqlResult = '';

                    if (queryTencent == 'Empty') {
                      sqlResult =
                          await MySqlUtils.insertTencent(content: sqlconfig);
                    } else {
                      sqlResult =
                          await MySqlUtils.updateTencent(content: sqlconfig);
                    }
                    if (sqlResult == "Success") {
                      final tencentConfig = TencentConfigModel(
                          secretId,
                          secretKey,
                          bucket,
                          appId,
                          area,
                          path,
                          customUrl,
                          options);
                      final tencentConfigJson = jsonEncode(tencentConfig);
                      final tencentConfigFile =
                          await TencentConfigState().localFile;
                      await tencentConfigFile.writeAsString(tencentConfigJson);
                      return showToast('设置成功');
                    } else {
                      return showToast('设置失败');
                    }
                  } catch (e) {
                    FLog.error(
                        className: 'TencentConfigureStorePage',
                        methodName: 'saveTencentConfig',
                        text: formatErrorMessage({}, e.toString()),
                        dataLogType: DataLogType.ERRORS.toString());
                    return showToast('保存失败');
                  }
                } else if (widget.psHost == 'upyun') {
                  try {
                    String bucket = psInfo['bucket']!;
                    String operator = psInfo['operator']!;
                    String password = psInfo['password']!;
                    String url = psInfo['url']!;
                    String options = psInfo['options']!;
                    String path = psInfo['path']!;

                    bool valid = validateUndetermined([
                      bucket,
                      operator,
                      password,
                      url,
                    ]);
                    if (!valid) {
                      showToast('请先去设置参数');
                      return;
                    }
                    if (path == ConfigureTemplate.placeholder) {
                      path = 'None';
                    }

                    List sqlconfig = [];
                    sqlconfig.add(bucket);
                    sqlconfig.add(operator);
                    sqlconfig.add(password);
                    sqlconfig.add(url);
                    sqlconfig.add(options);
                    sqlconfig.add(path);
                    String defaultUser = await Global.getUser();
                    sqlconfig.add(defaultUser);
                    var queryUpyun =
                        await MySqlUtils.queryUpyun(username: defaultUser);
                    var queryuser =
                        await MySqlUtils.queryUser(username: defaultUser);

                    if (queryuser == 'Empty') {
                      return showToast('请先登录');
                    }
                    var sqlResult = '';

                    if (queryUpyun == 'Empty') {
                      sqlResult =
                          await MySqlUtils.insertUpyun(content: sqlconfig);
                    } else {
                      sqlResult =
                          await MySqlUtils.updateUpyun(content: sqlconfig);
                    }
                    if (sqlResult == "Success") {
                      final upyunConfig = UpyunConfigModel(
                          bucket, operator, password, url, options, path);
                      final upyunConfigJson = jsonEncode(upyunConfig);
                      final upyunConfigFile =
                          await UpyunConfigState().localFile;
                      await upyunConfigFile.writeAsString(upyunConfigJson);
                      return showToast('设置成功');
                    } else {
                      return showToast('设置失败');
                    }
                  } catch (e) {
                    FLog.error(
                        className: 'UpyunConfigureStorePage',
                        methodName: 'saveUpyunConfig',
                        text: formatErrorMessage({}, e.toString()),
                        dataLogType: DataLogType.ERRORS.toString());
                    return showToast('保存失败');
                  }
                }
              }),
          const Divider(
            height: 0.1,
            color: Color.fromARGB(255, 230, 230, 230),
          ),
          ListTile(
            leading: const Icon(
              Icons.refresh,
              color: Color.fromARGB(255, 240, 85, 131),
            ),
            minLeadingWidth: 0,
            title: const Text('重置配置'),
            onTap: () async {
              showCupertinoAlertDialogWithConfirmFunc(
                title: '通知',
                content: '是否重置配置$storeName?',
                context: context,
                onConfirm: () async {
                  await ConfigureStoreFile().resetConfigureFileKey(
                    widget.psHost,
                    storeName,
                  );
                  if (mounted) {
                    Navigator.pop(context);
                  }
                  setState(() {
                    showToast('重置成功');
                  });
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
