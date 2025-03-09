import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluro/fluro.dart';
import 'package:f_logs/f_logs.dart';

import 'package:horopic/picture_host_configure/configure_store/configure_store_file.dart';
import 'package:horopic/picture_host_configure/configure_page/configure_export.dart';
import 'package:horopic/picture_host_configure/configure_store/configure_template.dart';
import 'package:horopic/picture_host_manage/manage_api/alist_manage_api.dart';
import 'package:horopic/picture_host_manage/manage_api/aliyun_manage_api.dart';
import 'package:horopic/picture_host_manage/manage_api/aws_manage_api.dart';
import 'package:horopic/picture_host_manage/manage_api/ftp_manage_api.dart';
import 'package:horopic/picture_host_manage/manage_api/github_manage_api.dart';
import 'package:horopic/picture_host_manage/manage_api/imgur_manage_api.dart';
import 'package:horopic/picture_host_manage/manage_api/lskypro_manage_api.dart';
import 'package:horopic/picture_host_manage/manage_api/qiniu_manage_api.dart';
import 'package:horopic/picture_host_manage/manage_api/smms_manage_api.dart';
import 'package:horopic/picture_host_manage/manage_api/tencent_manage_api.dart';
import 'package:horopic/picture_host_manage/manage_api/upyun_manage_api.dart';
import 'package:horopic/picture_host_manage/manage_api/webdav_manage_api.dart';

import 'package:horopic/router/application.dart';
import 'package:horopic/utils/common_functions.dart';

class ConfigureStorePage extends StatefulWidget {
  final String psHost;
  const ConfigureStorePage({super.key, required this.psHost});

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
    'alist': 'Alist V3',
    'webdav': 'WebDAV',
  };

  Map psNameToRouter = {
    'alist': '/alistConfigureStoreEditPage',
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
    'webdav': '/webdavConfigureStoreEditPage',
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

    bool isConfigured = !ConfigureStoreFile().checkIfOneUndetermined(pictureHostInfo);

    psInfoListTile.add(
      Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: isConfigured ? const Color.fromARGB(255, 88, 171, 240) : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundColor: isConfigured ? const Color.fromARGB(255, 88, 171, 240) : Colors.grey.shade300,
                child: Text(
                  storeName,
                  style: TextStyle(
                    color: isConfigured ? Colors.white : Colors.grey.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                remarkName == ConfigureTemplate.placeholder ? '配置$storeName' : '配置$storeName->$remarkName',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: isConfigured
                  ? const Text('已配置', style: TextStyle(color: Colors.green))
                  : const Text('未配置', style: TextStyle(color: Colors.grey)),
              trailing: IconButton(
                icon: const Icon(Icons.more_horiz_outlined, color: Colors.amber),
                onPressed: () {
                  showModalBottomSheet(
                      isScrollControlled: true,
                      context: context,
                      builder: (context) {
                        return buildBottomSheetWidget(context, storeName, pictureHostInfo);
                      });
                },
              ),
            ),
            if (!isConfigured)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    '尚未配置',
                    style: TextStyle(
                      color: Color.fromARGB(255, 88, 171, 240),
                      fontSize: 16,
                    ),
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: List.generate(keys.length, (i) {
                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 16.0),
                              child: SelectableText(
                                keys[i],
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: SelectableText(
                              values[i] == ConfigureTemplate.placeholder ? '未配置' : values[i].toString(),
                              style: TextStyle(
                                color: values[i] == ConfigureTemplate.placeholder ? Colors.grey : Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
          ],
        ),
      ),
    );

    return psInfoListTile;
  }

  buildAllPsInfoListTile(Map configMap) {
    List<Widget> allPsInfoListTile = [];
    String alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    for (var element in alphabet.split('')) {
      allPsInfoListTile.addAll(buildPsInfoListTile(element, configMap[element]!));
    }
    return allPsInfoListTile;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: titleText(psNameTranslate[widget.psHost]!),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColor.withAlpha(204)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.delete_forever,
              size: 30,
              color: Colors.redAccent,
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
                  padding: const EdgeInsets.symmetric(vertical: 10),
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
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            backgroundColor: const Color.fromARGB(255, 198, 135, 235),
            heroTag: 'exportConfig',
            onPressed: () async {
              var result = await ConfigureStoreFile().exportConfigureToJson(widget.psHost);
              await Clipboard.setData(ClipboardData(text: result));
              showToast('已导出到剪贴板');
            },
            child: const Icon(Icons.outbox_outlined, color: Colors.white),
          ),
          const SizedBox(width: 16),
          FloatingActionButton(
            backgroundColor: const Color.fromARGB(255, 127, 165, 37),
            heroTag: 'importConfig',
            onPressed: () async {
              var clipboardData = await Clipboard.getData('text/plain');
              if (clipboardData == null) {
                showToast('剪贴板为空');
                return;
              }
              try {
                await ConfigureStoreFile().importConfigureFromJson(widget.psHost, clipboardData.text!);
                setState(() {
                  showToast('导入成功');
                });
              } catch (e) {
                showToast('导入失败');
                return;
              }
            },
            child: const Icon(Icons.inbox_outlined, color: Colors.white),
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

  String checkPlaceholder(String? value) {
    if (value == null || value == ConfigureTemplate.placeholder) {
      return 'None';
    }
    return value;
  }

  Future<bool> applyConfigAsDefault(String hostType, Map psInfo) async {
    try {
      switch (hostType) {
        case 'aliyun':
          return await _applyAliyunConfig(psInfo);
        case 'aws':
          return await _applyAwsConfig(psInfo);
        case 'ftp':
          return await _applyFtpConfig(psInfo);
        case 'github':
          return await _applyGithubConfig(psInfo);
        case 'imgur':
          return await _applyImgurConfig(psInfo);
        case 'lsky.pro':
          return await _applyLskyConfig(psInfo);
        case 'qiniu':
          return await _applyQiniuConfig(psInfo);
        case 'sm.ms':
          return await _applySmmsConfig(psInfo);
        case 'tencent':
          return await _applyTencentConfig(psInfo);
        case 'upyun':
          return await _applyUpyunConfig(psInfo);
        case 'alist':
          return await _applyAlistConfig(psInfo);
        case 'webdav':
          return await _applyWebdavConfig(psInfo);
        default:
          showToast('未知图床类型');
          return false;
      }
    } catch (e) {
      FLog.error(
          className: 'ConfigureStorePage',
          methodName: 'applyConfigAsDefault',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      return false;
    }
  }

  Future<bool> _applyAliyunConfig(Map psInfo) async {
    String keyId = psInfo['keyId']!;
    String keySecret = psInfo['keySecret']!;
    String bucket = psInfo['bucket']!;
    String area = psInfo['area']!;

    if (!validateUndetermined([keyId, keySecret, bucket, area])) {
      showToast('请先去设置参数');
      return false;
    }

    String path = checkPlaceholder(psInfo['path']);
    String customUrl = checkPlaceholder(psInfo['customUrl']);
    String options = checkPlaceholder(psInfo['options']);

    final config = AliyunConfigModel(keyId, keySecret, bucket, area, path, customUrl, options);
    final configFile = await AliyunManageAPI.localFile;
    await configFile.writeAsString(jsonEncode(config));
    showToast('设置成功');
    return true;
  }

  Future<bool> _applyAwsConfig(Map psInfo) async {
    String accessKeyId = psInfo['accessKeyId']!;
    String secretAccessKey = psInfo['secretAccessKey']!;
    String bucket = psInfo['bucket']!;
    String endpoint = psInfo['endpoint']!;

    if (!validateUndetermined([accessKeyId, secretAccessKey, bucket, endpoint])) {
      showToast('请先去设置参数');
      return false;
    }

    String region = checkPlaceholder(psInfo['region']);
    String uploadPath = checkPlaceholder(psInfo['uploadPath']);
    String customUrl = checkPlaceholder(psInfo['customUrl']);
    bool isS3PathStyle = psInfo['isS3PathStyle'] ?? false;
    bool isEnableSSL = psInfo['isEnableSSL'] ?? true;

    final config = AwsConfigModel(
        accessKeyId, secretAccessKey, bucket, endpoint, region, uploadPath, customUrl, isS3PathStyle, isEnableSSL);
    final configFile = await AwsManageAPI.localFile;
    await configFile.writeAsString(jsonEncode(config));
    showToast('设置成功');
    return true;
  }

  Future<bool> _applyFtpConfig(Map psInfo) async {
    String ftpHost = psInfo['ftpHost']!;
    String ftpPort = psInfo['ftpPort']!;
    String ftpType = psInfo['ftpType']!;
    String isAnonymous = psInfo['isAnonymous']!.toString();

    if (!validateUndetermined([ftpHost, ftpPort, ftpType, isAnonymous])) {
      showToast('请先去设置参数');
      return false;
    }

    String ftpUser = checkPlaceholder(psInfo['ftpUser']);
    String ftpPassword = checkPlaceholder(psInfo['ftpPassword']);
    String uploadPath = checkPlaceholder(psInfo['uploadPath']);
    String ftpHomeDir = checkPlaceholder(psInfo['ftpHomeDir']);
    String ftpCustomUrl = checkPlaceholder(psInfo['ftpCustomUrl']);
    String ftpWebPath = checkPlaceholder(psInfo['ftpWebPath']);

    final config = FTPConfigModel(
        ftpHost, ftpPort, ftpUser, ftpPassword, ftpType, isAnonymous, uploadPath, ftpHomeDir, ftpCustomUrl, ftpWebPath);
    final configFile = await FTPManageAPI.localFile;
    await configFile.writeAsString(jsonEncode(config));
    showToast('设置成功');
    return true;
  }

  Future<bool> _applyGithubConfig(Map psInfo) async {
    String githubusername = psInfo['githubusername']!;
    String repo = psInfo['repo']!;
    String token = psInfo['token']!;
    String storePath = psInfo['storePath']!;
    String branch = psInfo['branch']!;
    String customDomain = psInfo['customDomain']!;

    if (!validateUndetermined([githubusername, repo, token, branch])) {
      showToast('请先去设置参数');
      return false;
    }

    storePath = checkPlaceholder(storePath);
    customDomain = checkPlaceholder(customDomain);

    final config = GithubConfigModel(githubusername, repo, token, storePath, branch, customDomain);
    final configFile = await GithubManageAPI.localFile;
    await configFile.writeAsString(jsonEncode(config));
    showToast('设置成功');
    return true;
  }

  Future<bool> _applyImgurConfig(Map psInfo) async {
    String clientId = psInfo['clientId']!;
    String proxy = psInfo['proxy']!;

    if (!validateUndetermined([clientId])) {
      showToast('请先去设置参数');
      return false;
    }

    proxy = checkPlaceholder(proxy);

    final config = ImgurConfigModel(clientId, proxy);
    final configFile = await ImgurManageAPI.localFile;
    await configFile.writeAsString(jsonEncode(config));
    showToast('设置成功');
    return true;
  }

  Future<bool> _applyLskyConfig(Map psInfo) async {
    String host = psInfo['host']!;
    String token = psInfo['token']!;
    String strategyId = psInfo['strategy_id']!.toString();
    String albumId = psInfo['album_id']!.toString();

    if (!validateUndetermined([host, token, strategyId])) {
      showToast('请先去设置参数');
      return false;
    }

    albumId = checkPlaceholder(albumId);

    final config = HostConfigModel(host, token, strategyId, albumId);
    final configFile = await LskyproManageAPI.localFile;
    await configFile.writeAsString(jsonEncode(config));
    showToast('设置成功');
    return true;
  }

  Future<bool> _applyQiniuConfig(Map psInfo) async {
    String accessKey = psInfo['accessKey']!;
    String secretKey = psInfo['secretKey']!;
    String bucket = psInfo['bucket']!;
    String url = psInfo['url']!;
    String area = psInfo['area']!;

    if (!validateUndetermined([accessKey, secretKey, bucket, url, area])) {
      showToast('请先去设置参数');
      return false;
    }

    String options = checkPlaceholder(psInfo['options']);
    String path = checkPlaceholder(psInfo['path']);

    final config = QiniuConfigModel(accessKey, secretKey, bucket, url, area, options, path);
    final configFile = await QiniuManageAPI.localFile;
    await configFile.writeAsString(jsonEncode(config));
    showToast('设置成功');
    return true;
  }

  Future<bool> _applySmmsConfig(Map psInfo) async {
    String token = psInfo['token']!;

    if (!validateUndetermined([token])) {
      showToast('请先去设置参数');
      return false;
    }

    final config = SmmsConfigModel(token);
    final configFile = await SmmsManageAPI.localFile;
    await configFile.writeAsString(jsonEncode(config));
    showToast('设置成功');
    return true;
  }

  Future<bool> _applyTencentConfig(Map psInfo) async {
    String secretId = psInfo['secretId']!;
    String secretKey = psInfo['secretKey']!;
    String bucket = psInfo['bucket']!;
    String appId = psInfo['appId']!;
    String area = psInfo['area']!;

    if (!validateUndetermined([secretId, secretKey, bucket, appId, area])) {
      showToast('请先去设置参数');
      return false;
    }

    String path = checkPlaceholder(psInfo['path']);
    String customUrl = checkPlaceholder(psInfo['customUrl']);
    String options = checkPlaceholder(psInfo['options']);

    final config = TencentConfigModel(secretId, secretKey, bucket, appId, area, path, customUrl, options);
    final configFile = await TencentManageAPI.localFile;
    await configFile.writeAsString(jsonEncode(config));
    showToast('设置成功');
    return true;
  }

  Future<bool> _applyUpyunConfig(Map psInfo) async {
    String bucket = psInfo['bucket']!;
    String operator = psInfo['operator']!;
    String password = psInfo['password']!;
    String url = psInfo['url']!;

    if (!validateUndetermined([bucket, operator, password, url])) {
      showToast('请先去设置参数');
      return false;
    }

    String options = checkPlaceholder(psInfo['options']);
    String path = checkPlaceholder(psInfo['path']);
    String antiLeechToken = checkPlaceholder(psInfo['antiLeechToken']);
    String antiLeechType = checkPlaceholder(psInfo['antiLeechType']);

    final config = UpyunConfigModel(bucket, operator, password, url, options, path, antiLeechToken, antiLeechType);
    final configFile = await UpyunManageAPI.localFile;
    await configFile.writeAsString(jsonEncode(config));
    showToast('设置成功');
    return true;
  }

  Future<bool> _applyAlistConfig(Map psInfo) async {
    String host = psInfo['host'];

    if (!validateUndetermined([host])) {
      showToast('请先去设置参数');
      return false;
    }

    String adminToken = checkPlaceholder(psInfo['adminToken']);
    String alistusername = checkPlaceholder(psInfo['alistusername']);
    String password = checkPlaceholder(psInfo['password']);
    String token = checkPlaceholder(psInfo['token']);
    String uploadPath = checkPlaceholder(psInfo['uploadPath']);
    String webPath = checkPlaceholder(psInfo['webPath']);
    String customUrl = checkPlaceholder(psInfo['customUrl']);

    final config = AlistConfigModel(host, adminToken, alistusername, password, token, uploadPath, webPath, customUrl);
    final configFile = await AlistManageAPI.localFile;
    await configFile.writeAsString(jsonEncode(config));
    showToast('设置成功');
    return true;
  }

  Future<bool> _applyWebdavConfig(Map psInfo) async {
    String host = psInfo['host']!;
    String webdavusername = psInfo['webdavusername']!;
    String password = psInfo['password']!;

    if (!validateUndetermined([host, webdavusername, password])) {
      showToast('请先去设置参数');
      return false;
    }

    String uploadPath = checkPlaceholder(psInfo['uploadPath']);
    String customUrl = checkPlaceholder(psInfo['customUrl']);
    String webPath = checkPlaceholder(psInfo['webPath']);

    final config = WebdavConfigModel(host, webdavusername, password, uploadPath, customUrl, webPath);
    final configFile = await WebdavManageAPI.localFile;
    await configFile.writeAsString(jsonEncode(config));
    showToast('设置成功');
    return true;
  }

  Widget buildBottomSheetWidget(BuildContext context, String storeName, Map psInfo) {
    String remarkName = psInfo['remarkName']!;
    bool isConfigured = !ConfigureStoreFile().checkIfOneUndetermined(psInfo);

    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 6,
              width: 40,
              margin: const EdgeInsets.only(top: 8, bottom: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            ListTile(
              dense: true,
              leading: CircleAvatar(
                backgroundColor: isConfigured ? const Color.fromARGB(255, 88, 171, 240) : Colors.grey.shade300,
                child: Text(
                  storeName,
                  style: TextStyle(
                    color: isConfigured ? Colors.white : Colors.grey.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                remarkName == ConfigureTemplate.placeholder ? '配置$storeName' : '配置$storeName-$remarkName',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              subtitle: isConfigured
                  ? const Text('已配置', style: TextStyle(color: Colors.green))
                  : const Text('未配置', style: TextStyle(color: Colors.grey)),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(
                Icons.edit,
                color: Color.fromARGB(255, 97, 141, 236),
              ),
              minLeadingWidth: 0,
              title: const Text('修改配置'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
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
              title: const Text('导出'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () async {
                Navigator.pop(context);
                var result = await ConfigureStoreFile().exportConfigureKeyToJson(widget.psHost, storeName);
                await Clipboard.setData(ClipboardData(text: result));
                showToast('已复制到剪贴板');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(
                Icons.check_box_outlined,
                color: Color.fromARGB(255, 97, 141, 236),
              ),
              minLeadingWidth: 0,
              title: const Text('替代图床默认配置'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () async {
                bool success = await applyConfigAsDefault(widget.psHost, psInfo);
                if (!success) {
                  showToast('保存失败');
                }
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(
                Icons.refresh,
                color: Color.fromARGB(255, 240, 85, 131),
              ),
              minLeadingWidth: 0,
              title: const Text('重置配置'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
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
            // Add padding at the bottom to ensure better visibility with system navigation
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
