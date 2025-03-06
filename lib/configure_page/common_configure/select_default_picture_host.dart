import 'dart:convert';
import 'dart:io';

import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fluro/fluro.dart';
import 'package:f_logs/f_logs.dart';
import 'package:horopic/picture_host_manage/manage_api/alist_manage_api.dart';
import 'package:horopic/picture_host_manage/manage_api/aliyun_manage_api.dart';
import 'package:horopic/picture_host_manage/manage_api/aws_manage_api.dart';
import 'package:horopic/picture_host_manage/manage_api/github_manage_api.dart';
import 'package:horopic/picture_host_manage/manage_api/imgur_manage_api.dart';
import 'package:horopic/picture_host_manage/manage_api/lskypro_manage_api.dart';
import 'package:horopic/picture_host_manage/manage_api/qiniu_manage_api.dart';
import 'package:horopic/picture_host_manage/manage_api/smms_manage_api.dart';
import 'package:horopic/picture_host_manage/manage_api/tencent_manage_api.dart';
import 'package:horopic/picture_host_manage/manage_api/upyun_manage_api.dart';
import 'package:path_provider/path_provider.dart';

import 'package:horopic/utils/global.dart';
import 'package:horopic/utils/common_functions.dart';

import 'package:horopic/picture_host_configure/configure_page/configure_export.dart';

import 'package:horopic/pages/loading.dart';

import 'package:horopic/router/application.dart';
import 'package:horopic/router/routers.dart';

//a configure page for user to show configure entry
class AllPShost extends StatefulWidget {
  const AllPShost({super.key});

  @override
  AllPShostState createState() => AllPShostState();
}

class AllPShostState extends State<AllPShost> {
  _scan() async {
    try {
      final result = await BarcodeScanner.scan(
          options: const ScanOptions(
        strings: {
          "cancel": "取消",
          "flash_on": "打开闪光灯",
          "flash_off": "关闭闪光灯",
        },
        restrictFormat: [BarcodeFormat.qr],
        android: AndroidOptions(
          aspectTolerance: 0.00,
          useAutoFocus: true,
        ),
        autoEnableFlash: false,
      ));
      setState(() {
        Global.qrScanResult = result.rawContent.toString();
      });
    } catch (e) {
      FLog.error(
          className: 'AllPShostState',
          methodName: '_scan',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      setState(() {
        Global.qrScanResult = ScanResult(
          type: ResultType.Error,
          format: BarcodeFormat.unknown,
          rawContent: e.toString(),
        ).rawContent;
      });
    }
  }

  static Future<String> get localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  exportConfiguration(String pshost) async {
    try {
      String configPath = await localPath;
      String defaultUser = await Global.getUser();
      Map<String, dynamic> configFilePath = {
        "smms": "$configPath/${defaultUser}_smms_config.txt",
        "lankong": "$configPath/${defaultUser}_host_config.txt",
        "github": "$configPath/${defaultUser}_github_config.txt",
        "imgur": "$configPath/${defaultUser}_imgur_config.txt",
        "qiniu": "$configPath/${defaultUser}_qiniu_config.txt",
        "tcyun": "$configPath/${defaultUser}_tencent_config.txt",
        "aliyun": "$configPath/${defaultUser}_aliyun_config.txt",
        "upyun": "$configPath/${defaultUser}_upyun_config.txt",
        "ftp": "$configPath/${defaultUser}_ftp_config.txt",
        "aws": "$configPath/${defaultUser}_aws_config.txt",
        "alist": "$configPath/${defaultUser}_alist_config.txt",
        "webdav": "$configPath/${defaultUser}_webdav_config.txt",
      };
      String config = await File(configFilePath[pshost]!).readAsString();
      if (config == '') {
        return Fluttertoast.showToast(
            msg: "该图床未配置", toastLength: Toast.LENGTH_SHORT, timeInSecForIosWeb: 2, fontSize: 16.0);
      }
      Map<String, dynamic> configMap = jsonDecode(config);
      Map configMapWithPshost = {pshost: configMap};
      String configJson = jsonEncode(configMapWithPshost);
      configJson = configJson.replaceAll('None', '');
      await Clipboard.setData(ClipboardData(text: configJson));
      showToast("$pshost配置已复制到剪贴板");
    } catch (e) {
      FLog.error(
          className: 'AllPShostState',
          methodName: 'exportConfiguration',
          text: formatErrorMessage({
            "pshost": pshost,
          }, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      showToast("导出失败");
    }
  }

  exportAllConfiguration() async {
    try {
      String configPath = await localPath;
      String defaultUser = await Global.getUser();
      Map<String, dynamic> configFilePath = {
        "smms": "$configPath/${defaultUser}_smms_config.txt",
        "lankong": "$configPath/${defaultUser}_host_config.txt",
        "github": "$configPath/${defaultUser}_github_config.txt",
        "imgur": "$configPath/${defaultUser}_imgur_config.txt",
        "qiniu": "$configPath/${defaultUser}_qiniu_config.txt",
        "tcyun": "$configPath/${defaultUser}_tencent_config.txt",
        "aliyun": "$configPath/${defaultUser}_aliyun_config.txt",
        "upyun": "$configPath/${defaultUser}_upyun_config.txt",
        "ftp": "$configPath/${defaultUser}_ftp_config.txt",
        "aws": "$configPath/${defaultUser}_aws_config.txt",
        "alist": "$configPath/${defaultUser}_alist_config.txt",
        "webdav": "$configPath/${defaultUser}_webdav_config.txt",
      };
      Map<String, dynamic> configMap = {};
      for (var key in configFilePath.keys) {
        if (!File(configFilePath[key]!).existsSync()) {
          continue;
        }
        String config = await File(configFilePath[key]!).readAsString();
        if (config == '') {
          continue;
        }
        Map<String, dynamic> configMap2 = jsonDecode(config);
        configMap[key] = configMap2;
      }
      String configJson = jsonEncode(configMap);
      configJson = configJson.replaceAll('None', '');
      await Clipboard.setData(ClipboardData(text: configJson));
      showToast("配置已复制到剪贴板");
    } catch (e) {
      FLog.error(
          className: 'AllPShostState',
          methodName: 'exportAllConfiguration',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      showToast("导出失败");
    }
  }

  processingQRCodeResult() async {
    try {
      String result = Global.qrScanResult;
      Global.qrScanResult = "";
      Map<String, dynamic> jsonResult = jsonDecode(result);
      if (jsonResult['smms'] == null &&
          jsonResult['alist'] == null &&
          jsonResult['alistplist'] == null &&
          jsonResult['aws-s3-plist'] == null &&
          jsonResult['aws-s3'] == null &&
          jsonResult['github'] == null &&
          jsonResult['lankong'] == null &&
          jsonResult['lskyplist'] == null &&
          jsonResult['imgur'] == null &&
          jsonResult['qiniu'] == null &&
          jsonResult['tcyun'] == null &&
          jsonResult['aliyun'] == null &&
          jsonResult['upyun'] == null) {
        return Fluttertoast.showToast(
            msg: "不包含支持的图床配置信息", toastLength: Toast.LENGTH_SHORT, timeInSecForIosWeb: 2, fontSize: 16.0);
      }

      if (jsonResult['smms'] != null) {
        final smmsToken = jsonResult['smms']['token'] ?? '';
        try {
          final smmsConfig = SmmsConfigModel(smmsToken);
          final smmsConfigJson = jsonEncode(smmsConfig);
          final smmsConfigFile = await SmmsManageAPI.localFile;
          await smmsConfigFile.writeAsString(smmsConfigJson);
          showToast("sm.ms配置成功");
        } catch (e) {
          FLog.error(
              className: 'AllPShostState',
              methodName: 'processingQRCodeResult_smms_2',
              text: formatErrorMessage({}, e.toString()),
              dataLogType: DataLogType.ERRORS.toString());
          showToast("sm.ms配置错误");
        }
      }

      if (jsonResult['aws-s3-plist'] != null || jsonResult['aws-s3'] != null) {
        try {
          String awsKeyName = jsonResult['aws-s3'] == null ? 'aws-s3-plist' : 'aws-s3';
          String awsAccessKeyId = (jsonResult[awsKeyName]['accessKeyID'] ?? '').trim();
          String awsSecretAccessKey = (jsonResult[awsKeyName]['secretAccessKey'] ?? '').trim();
          String awsBucket = (jsonResult[awsKeyName]['bucketName'] ?? '').trim();
          String awsEndpoint = (jsonResult[awsKeyName]['endpoint'] ?? '').trim();
          String awsRegion = (jsonResult[awsKeyName]['region'] ?? '').trim();
          String awsUploadPath = (jsonResult[awsKeyName]['uploadPath'] ?? '').trim();
          String awsCustomUrl = (jsonResult[awsKeyName]['urlPrefix'] ?? '').trim();
          var awsUsePathStyle = jsonResult[awsKeyName]['pathStyleAccess'] ?? false;
          if (awsUploadPath.isEmpty || awsUploadPath == '/') {
            awsUploadPath = 'None';
          } else {
            if (!awsUploadPath.endsWith('/')) {
              awsUploadPath = '$awsUploadPath/';
            }
            if (awsUploadPath.startsWith('/')) {
              awsUploadPath = awsUploadPath.substring(1);
            }
          }
          if (awsCustomUrl.isEmpty) {
            awsCustomUrl = 'None';
          } else {
            if (!awsCustomUrl.startsWith('http') && !awsCustomUrl.startsWith('https')) {
              awsCustomUrl = 'http://$awsCustomUrl';
            }
            if (awsCustomUrl.endsWith('/')) {
              awsCustomUrl = awsCustomUrl.substring(0, awsCustomUrl.length - 1);
            }
          }
          bool isEnableSSL = awsEndpoint.startsWith('https');
          if (awsEndpoint.startsWith('http')) {
            awsEndpoint = awsEndpoint.substring(awsEndpoint.indexOf('://') + 3);
          } else if (awsEndpoint.startsWith('https')) {
            awsEndpoint = awsEndpoint.substring(awsEndpoint.indexOf('s://') + 3);
          }
          if (awsRegion.isEmpty) {
            awsRegion = 'None';
          }
          if (awsUsePathStyle is String) {
            awsUsePathStyle = awsUsePathStyle.toLowerCase() == 'true';
          }
          if (awsUsePathStyle is! bool) {
            awsUsePathStyle = false;
          }
          final awsConfig = AwsConfigModel(awsAccessKeyId, awsSecretAccessKey, awsBucket, awsEndpoint, awsRegion,
              awsUploadPath, awsCustomUrl, awsUsePathStyle, isEnableSSL);
          final awsConfigJson = jsonEncode(awsConfig);
          final awsConfigFile = await AwsManageAPI.localFile;
          await awsConfigFile.writeAsString(awsConfigJson);
          showToast("AWS S3配置成功");
        } catch (e) {
          FLog.error(
              className: 'AllPShostState',
              methodName: 'processingQRCodeResult_aws_2',
              text: formatErrorMessage({}, e.toString()),
              dataLogType: DataLogType.ERRORS.toString());
          showToast("AWS S3配置错误");
        }
      }

      if (jsonResult['alist'] != null || jsonResult['alistplist'] != null) {
        try {
          String alistKeyName = jsonResult['alist'] == null ? 'alistplist' : 'alist';
          String alistVersion = jsonResult['alist']?['version'] ?? '';
          if (alistVersion == '2') {
            showToast("不支持Alist V2");
          } else {
            String alistUrl = (jsonResult[alistKeyName]['url'] ?? '').trim();
            String alistToken = (jsonResult[alistKeyName]['token'] ?? '').trim();
            String alistUsername = (jsonResult[alistKeyName]['username'] ?? '').trim();
            String alistPassword = (jsonResult[alistKeyName]['password'] ?? '').trim();
            String alistUploadPath = (jsonResult[alistKeyName]['uploadPath'] ?? '').trim();
            String alistWebPath =
                (jsonResult[alistKeyName]['webPath'] ?? jsonResult[alistKeyName]['accessPath'] ?? '').trim();
            String alistCustomUrl = (jsonResult[alistKeyName]['customUrl'] ?? '').trim();
            alistUrl = alistUrl.replaceAll(RegExp(r'/+$'), '');
            if (!alistUrl.startsWith('http') && !alistUrl.startsWith('https')) {
              alistUrl = 'http://$alistUrl';
            }
            if (alistToken.isEmpty) {
              alistToken = 'None';
            }
            if (alistUploadPath.isEmpty || alistUploadPath == '/') {
              alistUploadPath = 'None';
            }
            if (alistWebPath.isEmpty) {
              alistWebPath = 'None';
            } else {
              if (!alistWebPath.endsWith('/')) {
                alistWebPath = '$alistWebPath/';
              }
            }
            if (alistCustomUrl.isEmpty) {
              alistCustomUrl = 'None';
            } else {
              if (!alistCustomUrl.endsWith('/')) {
                alistCustomUrl = alistCustomUrl.replaceAll(RegExp(r'/+$'), '');
              }
            }
            if (alistToken != 'None') {
              final alistConfig = AlistConfigModel(alistUrl, alistToken, alistUsername, alistPassword, alistToken,
                  alistUploadPath, alistWebPath, alistCustomUrl);
              final alistConfigJson = jsonEncode(alistConfig);
              final alistConfigFile = await AlistManageAPI.localFile;
              await alistConfigFile.writeAsString(alistConfigJson);
              showToast("Alist配置成功");
            } else {
              if (alistUsername.isNotEmpty && alistPassword.isNotEmpty) {
                var res = await AlistManageAPI.getToken(alistUrl, alistUsername, alistPassword);
                if (res[0] != 'success') {
                  throw Exception('获取Token失败');
                }
                final alistConfig = AlistConfigModel(alistUrl, 'None', alistUsername, alistPassword, res[1],
                    alistUploadPath, alistWebPath, alistCustomUrl);
                final alistConfigJson = jsonEncode(alistConfig);
                final alistConfigFile = await AlistManageAPI.localFile;
                await alistConfigFile.writeAsString(alistConfigJson);
                showToast("Alist配置成功");
              }
            }
          }
        } catch (e) {
          FLog.error(
              className: 'AllPShostState',
              methodName: 'processingQRCodeResult_alist_2',
              text: formatErrorMessage({}, e.toString()),
              dataLogType: DataLogType.ERRORS.toString());
          showToast("Alist配置错误");
        }
      }

      if (jsonResult['github'] != null) {
        try {
          String token = jsonResult['github']['token'] ?? '';
          String usernameRepo = jsonResult['github']['repo'] ?? '';
          String githubusername = usernameRepo.substring(0, usernameRepo.indexOf('/'));
          String repo = usernameRepo.substring(usernameRepo.indexOf('/') + 1);
          String storePath = jsonResult['github']['path'] ?? '';
          String branch = jsonResult['github']['branch'] ?? '';
          String customDomain = jsonResult['github']['customUrl'] ?? '';
          if (storePath.isEmpty || storePath == '/') {
            storePath = 'None';
          } else if (!storePath.endsWith('/')) {
            storePath = '$storePath/';
          }

          if (branch.isEmpty) {
            branch = 'main';
          }

          if (customDomain.isEmpty) {
            customDomain = 'None';
          }
          if (customDomain != 'None') {
            if (!customDomain.startsWith('http') && !customDomain.startsWith('https')) {
              customDomain = 'http://$customDomain';
            }
            if (customDomain.endsWith('/')) {
              customDomain = customDomain.substring(0, customDomain.length - 1);
            }
          }
          token = token.startsWith('Bearer ') ? token : 'Bearer $token';

          final githubConfig = GithubConfigModel(githubusername, repo, token, storePath, branch, customDomain);
          final githubConfigJson = jsonEncode(githubConfig);
          final githubConfigFile = await GithubManageAPI.localFile;
          await githubConfigFile.writeAsString(githubConfigJson);
          showToast("Github配置成功");
        } catch (e) {
          FLog.error(
              className: 'AllPShostState',
              methodName: 'processingQRCodeResult_github',
              text: formatErrorMessage({}, e.toString()),
              dataLogType: DataLogType.ERRORS.toString());
          showToast("Github配置错误");
        }
      }

      if (jsonResult['lankong'] != null || jsonResult['lskyplist'] != null) {
        try {
          String lankongKeyName = jsonResult['lankong'] == null ? 'lskyplist' : 'lankong';
          String lankongVersion = jsonResult['lankong']?['lskyProVersion'] ?? jsonResult['lskyplist']['version'] ?? '';
          if (lankongVersion == 'V1') {
            showToast("不支持兰空V1");
          } else {
            String lankongHost = jsonResult[lankongKeyName]['server'] ?? jsonResult[lankongKeyName]['host'] ?? '';
            if (lankongHost.endsWith('/')) {
              lankongHost = lankongHost.substring(0, lankongHost.length - 1);
            }
            String lankongToken = jsonResult[lankongKeyName]['token'];
            if (!lankongToken.startsWith('Bearer ')) {
              lankongToken = 'Bearer $lankongToken';
            }
            String lanKongstrategyId = jsonResult[lankongKeyName]['strategyId'];
            if (lanKongstrategyId.isEmpty) {
              lanKongstrategyId = 'None';
            }
            String lanKongalbumId = jsonResult['lankong']['albumId'];
            if (lanKongalbumId.isEmpty) {
              lanKongalbumId = 'None';
            }

            HostConfigModel hostConfig = HostConfigModel(lankongHost, lankongToken, lanKongstrategyId, lanKongalbumId);
            final hostConfigJson = jsonEncode(hostConfig);
            final hostConfigFile = await LskyproManageAPI.localFile;
            hostConfigFile.writeAsString(hostConfigJson);
            showToast("兰空配置成功");
          }
        } catch (e) {
          FLog.error(
              className: 'AllPShostState',
              methodName: 'processingQRCodeResult_lankong_3',
              text: formatErrorMessage({}, e.toString()),
              dataLogType: DataLogType.ERRORS.toString());
          showToast("兰空配置错误");
        }
      }

      if (jsonResult['imgur'] != null) {
        try {
          final imgurclientId = jsonResult['imgur']['clientId'] ?? '';
          String imgurProxy = jsonResult['imgur']['proxy'] ?? '';
          if (imgurProxy.isEmpty) {
            imgurProxy = 'None';
          }
          final imgurConfig = ImgurConfigModel(imgurclientId, imgurProxy);
          final imgurConfigJson = jsonEncode(imgurConfig);
          final imgurConfigFile = await ImgurManageAPI.localFile;
          await imgurConfigFile.writeAsString(imgurConfigJson);
          showToast("Imgur配置成功");
        } catch (e) {
          FLog.error(
              className: 'AllPShostState',
              methodName: 'processingQRCodeResult_imgur_2',
              text: formatErrorMessage({}, e.toString()),
              dataLogType: DataLogType.ERRORS.toString());
          showToast("Imgur配置错误");
        }
      }

      if (jsonResult['qiniu'] != null) {
        try {
          String qiniuAccessKey = jsonResult['qiniu']['accessKey'] ?? '';
          String qiniuSecretKey = jsonResult['qiniu']['secretKey'] ?? '';
          String qiniuBucket = jsonResult['qiniu']['bucket'] ?? '';
          String qiniuUrl = jsonResult['qiniu']['url'] ?? '';
          String qiniuArea = jsonResult['qiniu']['area'] ?? '';
          String qiniuOptions = jsonResult['qiniu']['options'] ?? '';
          String qiniuPath = jsonResult['qiniu']['path'] ?? '';

          if (!qiniuUrl.startsWith('http') && !qiniuUrl.startsWith('https')) {
            qiniuUrl = 'http://$qiniuUrl';
          }
          if (qiniuUrl.endsWith('/')) {
            qiniuUrl = qiniuUrl.substring(0, qiniuUrl.length - 1);
          }

          if (qiniuPath.isEmpty) {
            qiniuPath = 'None';
          } else {
            if (qiniuPath.startsWith('/')) {
              qiniuPath = qiniuPath.substring(1);
            }
            if (!qiniuPath.endsWith('/')) {
              qiniuPath = '$qiniuPath/';
            }
          }

          if (qiniuOptions.isEmpty) {
            qiniuOptions = 'None';
          } else if (!qiniuOptions.startsWith('?')) {
            qiniuOptions = '?$qiniuOptions';
          }

          final qiniuConfig = QiniuConfigModel(
              qiniuAccessKey, qiniuSecretKey, qiniuBucket, qiniuUrl, qiniuArea, qiniuOptions, qiniuPath);
          final qiniuConfigJson = jsonEncode(qiniuConfig);
          final qiniuConfigFile = await QiniuManageAPI.localFile;
          await qiniuConfigFile.writeAsString(qiniuConfigJson);
          showToast("七牛配置成功");
        } catch (e) {
          FLog.error(
              className: 'AllPShostState',
              methodName: 'processingQRCodeResult_qiniu_2',
              text: formatErrorMessage({}, e.toString()),
              dataLogType: DataLogType.ERRORS.toString());
          showToast("七牛配置错误");
        }
      }

      if (jsonResult['tcyun'] != null) {
        try {
          String tencentVersion = jsonResult['tcyun']['version'];
          if (tencentVersion != 'v5') {
            showToast("不支持腾讯V4");
          } else {
            String tencentSecretId = jsonResult['tcyun']['secretId'] ?? '';
            String tencentSecretKey = jsonResult['tcyun']['secretKey'] ?? '';
            String tencentBucket = jsonResult['tcyun']['bucket'] ?? '';
            String tencentAppId = jsonResult['tcyun']['appId'] ?? '';
            String tencentArea = jsonResult['tcyun']['area'] ?? '';
            String tencentPath = jsonResult['tcyun']['path'] ?? '';
            String tencentCustomUrl = jsonResult['tcyun']['customUrl'] ?? '';
            String tencentOptions = jsonResult['tcyun']['options'] ?? '';

            if (tencentCustomUrl.isNotEmpty) {
              if (!tencentCustomUrl.startsWith('http') && !tencentCustomUrl.startsWith('https')) {
                tencentCustomUrl = 'http://$tencentCustomUrl';
              }
              if (tencentCustomUrl.endsWith('/')) {
                tencentCustomUrl = tencentCustomUrl.substring(0, tencentCustomUrl.length - 1);
              }
            } else {
              tencentCustomUrl = 'None';
            }

            if (tencentPath.isEmpty || tencentPath == '/') {
              tencentPath = 'None';
            } else {
              if (tencentPath.startsWith('/')) {
                tencentPath = tencentPath.substring(1);
              }
              if (!tencentPath.endsWith('/')) {
                tencentPath = '$tencentPath/';
              }
            }

            if (tencentOptions.isEmpty) {
              tencentOptions = 'None';
            } else if (!tencentOptions.startsWith('?')) {
              tencentOptions = '?$tencentOptions';
            }

            final tencentConfig = TencentConfigModel(
              tencentSecretId,
              tencentSecretKey,
              tencentBucket,
              tencentAppId,
              tencentArea,
              tencentPath,
              tencentCustomUrl,
              tencentOptions,
            );
            final tencentConfigJson = jsonEncode(tencentConfig);
            final tencentConfigFile = await TencentManageAPI.localFile;
            await tencentConfigFile.writeAsString(tencentConfigJson);
            showToast("腾讯云配置成功");
          }
        } catch (e) {
          FLog.error(
              className: 'TencentConfigPage',
              methodName: 'saveTencentConfig',
              text: formatErrorMessage({}, e.toString()),
              dataLogType: DataLogType.ERRORS.toString());
          showToast("腾讯云配置错误");
        }
      }

      if (jsonResult['aliyun'] != null) {
        try {
          String aliyunKeyId = jsonResult['aliyun']['accessKeyId'] ?? '';
          String aliyunKeySecret = jsonResult['aliyun']['accessKeySecret'] ?? '';
          String aliyunBucket = jsonResult['aliyun']['bucket'] ?? '';
          String aliyunArea = jsonResult['aliyun']['area'] ?? '';
          String aliyunPath = jsonResult['aliyun']['path'] ?? '';
          String aliyunCustomUrl = jsonResult['aliyun']['customUrl'] ?? '';
          String aliyunOptions = jsonResult['aliyun']['options'] ?? '';

          if (aliyunCustomUrl.isNotEmpty) {
            if (!aliyunCustomUrl.startsWith('http') && !aliyunCustomUrl.startsWith('https')) {
              aliyunCustomUrl = 'http://$aliyunCustomUrl';
            }
            if (aliyunCustomUrl.endsWith('/')) {
              aliyunCustomUrl = aliyunCustomUrl.substring(0, aliyunCustomUrl.length - 1);
            }
          } else {
            aliyunCustomUrl = 'None';
          }

          if (aliyunPath.isEmpty || aliyunPath == '/') {
            aliyunPath = 'None';
          } else {
            if (aliyunPath.startsWith('/')) {
              aliyunPath = aliyunPath.substring(1);
            }
            if (!aliyunPath.endsWith('/')) {
              aliyunPath = '$aliyunPath/';
            }
          }

          if (aliyunOptions.isEmpty) {
            aliyunOptions = 'None';
          } else if (!aliyunOptions.startsWith('?')) {
            aliyunOptions = '?$aliyunOptions';
          }

          final aliyunConfig = AliyunConfigModel(
            aliyunKeyId,
            aliyunKeySecret,
            aliyunBucket,
            aliyunArea,
            aliyunPath,
            aliyunCustomUrl,
            aliyunOptions,
          );
          final aliyunConfigJson = jsonEncode(aliyunConfig);
          final aliyunConfigFile = await AliyunManageAPI.localFile;
          await aliyunConfigFile.writeAsString(aliyunConfigJson);
          showToast("阿里云配置成功");
        } catch (e) {
          FLog.error(
              className: 'AliyunConfigPage',
              methodName: 'saveAliyunConfig',
              text: formatErrorMessage({}, e.toString()),
              dataLogType: DataLogType.ERRORS.toString());
          showToast("阿里云配置错误");
        }
      }

      if (jsonResult['upyun'] != null) {
        try {
          String upyunBucket = jsonResult['upyun']['bucket'] ?? '';
          String upyunOperator = jsonResult['upyun']['operator'] ?? '';
          String upyunPassword = jsonResult['upyun']['password'] ?? '';
          String upyunUrl = jsonResult['upyun']['url'] ?? '';
          String upyunOptions = jsonResult['upyun']['options'] ?? '';
          String upyunPath = jsonResult['upyun']['path'] ?? '';
          String upyunAntiLeechToken = jsonResult['upyun']['antiLeechToken'] ?? '';
          String upyunAntiLeechExpiration = jsonResult['upyun']['antiLeechExpiration'] ?? '';

          if (!upyunUrl.startsWith('http') && !upyunUrl.startsWith('https')) {
            upyunUrl = 'http://$upyunUrl';
          }

          if (upyunUrl.endsWith('/')) {
            upyunUrl = upyunUrl.substring(0, upyunUrl.length - 1);
          }

          if (upyunPath.isEmpty || upyunPath == '/') {
            upyunPath = 'None';
          } else {
            if (upyunPath.startsWith('/')) {
              upyunPath = upyunPath.substring(1);
            }

            if (!upyunPath.endsWith('/')) {
              upyunPath = '$upyunPath/';
            }
          }

          final upyunConfig = UpyunConfigModel(
            upyunBucket,
            upyunOperator,
            upyunPassword,
            upyunUrl,
            upyunOptions,
            upyunPath,
            upyunAntiLeechToken,
            upyunAntiLeechExpiration,
          );
          final upyunConfigJson = jsonEncode(upyunConfig);
          final upyunConfigFile = await UpyunManageAPI.localFile;
          await upyunConfigFile.writeAsString(upyunConfigJson);
          showToast("又拍云配置成功");
        } catch (e) {
          FLog.error(
              className: 'UpyunConfigPage',
              methodName: 'upyunConfig',
              text: formatErrorMessage({}, e.toString()),
              dataLogType: DataLogType.ERRORS.toString());
          showToast("又拍云配置错误");
        }
      }
      return true;
    } catch (e) {
      FLog.error(
          className: 'AllPShostState',
          methodName: 'processingQRCodeResult',
          text: formatErrorMessage({}, e.toString()),
          dataLogType: DataLogType.ERRORS.toString());
      showToast("导入失败");
    }
  }

  SimpleDialogOption _buildSimpleDialogOption(BuildContext context, String text, String value) {
    return SimpleDialogOption(
      child: Text(text, textAlign: TextAlign.center),
      onPressed: () {
        exportConfiguration(value);
        Navigator.pop(context);
      },
    );
  }

  List<SimpleDialogOption> _buildSimpleDialogOptions(BuildContext context) {
    List<SimpleDialogOption> options = [
      SimpleDialogOption(
        child: const Text('全部导出', textAlign: TextAlign.center),
        onPressed: () {
          exportAllConfiguration();
          Navigator.pop(context);
        },
      ),
    ];
    Map temp = {
      "AList V3": 'alist',
      '阿里云': 'aliyun',
      'FTP-SSH/SFTP': 'ftp',
      'Github': 'github',
      'Imgur': 'imgur',
      '兰空图床': 'lankong',
      '七牛云': 'qiniu',
      'S3兼容平台': 'aws',
      'SM.MS': 'smms',
      '腾讯云': 'tcyun',
      '又拍云': 'upyun',
      'WebDAV': 'webdav',
    };
    temp.forEach((key, value) {
      options.add(_buildSimpleDialogOption(context, key, value));
    });
    return options;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: titleText(
          '图床设置',
        ),
      ),
      body: ListView(children: [
        ListTile(
          leading: const Icon(
            Icons.camera_alt_outlined,
          ),
          minLeadingWidth: 0,
          title: const Text('二维码扫描导入PicGo配置'),
          onTap: () async {
            await _scan();
            if (context.mounted) {
              showDialog(
                  context: this.context,
                  barrierDismissible: false,
                  builder: (context) {
                    return NetLoadingDialog(
                      outsideDismiss: false,
                      loading: true,
                      loadingText: "配置中...",
                      requestCallBack: processingQRCodeResult(),
                    );
                  });
            }
          },
          trailing: const Icon(Icons.arrow_forward_ios),
        ),
        const Divider(
          height: 1,
          color: Colors.grey,
        ),
        ListTile(
          title: const Text('默认图床选择'),
          onTap: () {
            Application.router.navigateTo(context, Routes.defaultPShostSelect, transition: TransitionType.cupertino);
          },
          trailing: const Icon(Icons.arrow_forward_ios),
        ),
        ListTile(
          title: const Text('AList V3'),
          onTap: () {
            Application.router.navigateTo(context, Routes.alistPShostSelect, transition: TransitionType.cupertino);
          },
          trailing: const Icon(Icons.arrow_forward_ios),
        ),
        ListTile(
          title: const Text('阿里云OSS'),
          onTap: () {
            Application.router.navigateTo(context, Routes.aliyunPShostSelect, transition: TransitionType.cupertino);
          },
          trailing: const Icon(Icons.arrow_forward_ios),
        ),
        ListTile(
          title: const Text('FTP-SSH/SFTP'),
          onTap: () {
            Application.router.navigateTo(context, Routes.ftpPShostSelect, transition: TransitionType.cupertino);
          },
          trailing: const Icon(Icons.arrow_forward_ios),
        ),
        ListTile(
          title: const Text('Github图床'),
          onTap: () {
            Application.router.navigateTo(context, Routes.githubPShostSelect, transition: TransitionType.cupertino);
          },
          trailing: const Icon(Icons.arrow_forward_ios),
        ),
        ListTile(
          title: const Text('Imgur图床'),
          onTap: () {
            Application.router.navigateTo(context, Routes.imgurPShostSelect, transition: TransitionType.cupertino);
          },
          trailing: const Icon(Icons.arrow_forward_ios),
        ),
        ListTile(
          title: const Text('兰空图床V2'),
          onTap: () {
            Application.router.navigateTo(context, Routes.lskyproPShostSelect, transition: TransitionType.cupertino);
          },
          trailing: const Icon(Icons.arrow_forward_ios),
        ),
        ListTile(
          title: const Text('七牛云存储'),
          onTap: () {
            Application.router.navigateTo(context, Routes.qiniuPShostSelect, transition: TransitionType.cupertino);
          },
          trailing: const Icon(Icons.arrow_forward_ios),
        ),
        ListTile(
          title: const Text('S3兼容平台'),
          onTap: () {
            Application.router.navigateTo(context, Routes.awsPShostSelect, transition: TransitionType.cupertino);
          },
          trailing: const Icon(Icons.arrow_forward_ios),
        ),
        ListTile(
          title: const Text('SM.MS图床'),
          onTap: () {
            Application.router.navigateTo(context, Routes.smmsPShostSelect, transition: TransitionType.cupertino);
          },
          trailing: const Icon(Icons.arrow_forward_ios),
        ),
        ListTile(
          title: const Text('腾讯云COS V5'),
          onTap: () {
            Application.router.navigateTo(context, Routes.tencentPShostSelect, transition: TransitionType.cupertino);
          },
          trailing: const Icon(Icons.arrow_forward_ios),
        ),
        ListTile(
          title: const Text('又拍云存储'),
          onTap: () {
            Application.router.navigateTo(context, Routes.upyunPShostSelect, transition: TransitionType.cupertino);
          },
          trailing: const Icon(Icons.arrow_forward_ios),
        ),
        ListTile(
          title: const Text('WebDAV'),
          onTap: () {
            Application.router.navigateTo(context, Routes.webdavPShostSelect, transition: TransitionType.cupertino);
          },
          trailing: const Icon(Icons.arrow_forward_ios),
        ),
      ]),
      floatingActionButton: SizedBox(
          height: 40,
          width: 40,
          child: FloatingActionButton(
            heroTag: 'copyConfig',
            backgroundColor: const Color.fromARGB(255, 198, 135, 235),
            onPressed: () async {
              await showDialog(
                barrierDismissible: true,
                context: context,
                builder: (context) {
                  return SimpleDialog(
                    title: const Text(
                      '选择要复制配置的图床',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    children: _buildSimpleDialogOptions(context),
                  );
                },
              );
            },
            child: const Icon(
              Icons.outbox_outlined,
              color: Colors.white,
              size: 30,
            ),
          )),
    );
  }
}
