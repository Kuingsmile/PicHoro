part of 'select_default_picture_host.dart';

// Helper methods for configuration
Future<void> _configureSmms(Map<String, dynamic> jsonResult) async {
  try {
    final smmsToken = jsonResult['smms']['token'] ?? '';
    final smmsConfig = SmmsConfigModel(smmsToken);
    await _saveConfig(SmmsManageAPI.localFile, smmsConfig);
    showToast("sm.ms配置成功");
  } catch (e) {
    _logError('_configureSmms', {}, e);
    showToast("sm.ms配置错误");
  }
}

Future<void> _configureAws(Map<String, dynamic> jsonResult) async {
  try {
    String awsKeyName = jsonResult['aws-s3'] == null ? 'aws-s3-plist' : 'aws-s3';
    Map<String, dynamic> awsData = jsonResult[awsKeyName];

    // Extract and normalize AWS data
    String accessKeyId = (awsData['accessKeyID'] ?? '').trim();
    String secretKey = (awsData['secretAccessKey'] ?? '').trim();
    String bucket = (awsData['bucketName'] ?? '').trim();
    String endpoint = (awsData['endpoint'] ?? '').trim();
    String region = (awsData['region'] ?? '').trim();
    String uploadPath = _normalizePath(awsData['uploadPath'] ?? '');
    String customUrl = _normalizeUrl(awsData['urlPrefix'] ?? '');
    var usePathStyle = awsData['pathStyleAccess'] ?? false;

    // Process endpoint and detect SSL
    bool isEnableSSL = endpoint.startsWith('https');
    if (endpoint.startsWith('http')) {
      endpoint = endpoint.substring(endpoint.indexOf('://') + 3);
    }

    // Convert usePathStyle to boolean
    if (usePathStyle is String) {
      usePathStyle = usePathStyle.toLowerCase() == 'true';
    }
    if (usePathStyle is! bool) {
      usePathStyle = false;
    }

    final awsConfig = AwsConfigModel(accessKeyId, secretKey, bucket, endpoint, region.isEmpty ? 'None' : region,
        uploadPath, customUrl, usePathStyle, isEnableSSL);

    await _saveConfig(AwsManageAPI.localFile, awsConfig);
    showToast("AWS S3配置成功");
  } catch (e) {
    _logError('_configureAws', {}, e);
    showToast("AWS S3配置错误");
  }
}

// Similar helper methods for other services
Future<void> _configureAlist(Map<String, dynamic> jsonResult) async {
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
          final alistConfig = AlistConfigModel(
              alistUrl, 'None', alistUsername, alistPassword, res[1], alistUploadPath, alistWebPath, alistCustomUrl);
          final alistConfigJson = jsonEncode(alistConfig);
          final alistConfigFile = await AlistManageAPI.localFile;
          await alistConfigFile.writeAsString(alistConfigJson);
          showToast("Alist配置成功");
        }
      }
    }
  } catch (e) {
    _logError('_configureAlist', {}, e);
    showToast("Alist配置错误");
  }
}

Future<void> _configureGithub(Map<String, dynamic> jsonResult) async {
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
    _logError('_configureGithub', {}, e);
    showToast("Github配置错误");
  }
}

Future<void> _configureLankong(Map<String, dynamic> jsonResult) async {
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
    _logError('_configureLankong', {}, e);
    showToast("兰空配置错误");
  }
}

Future<void> _configureImgur(Map<String, dynamic> jsonResult) async {
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
    _logError('_configureImgur', {}, e);
    showToast("Imgur配置错误");
  }
}

Future<void> _configureQiniu(Map<String, dynamic> jsonResult) async {
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
    }

    final qiniuConfig =
        QiniuConfigModel(qiniuAccessKey, qiniuSecretKey, qiniuBucket, qiniuUrl, qiniuArea, qiniuOptions, qiniuPath);
    final qiniuConfigJson = jsonEncode(qiniuConfig);
    final qiniuConfigFile = await QiniuManageAPI.localFile;
    await qiniuConfigFile.writeAsString(qiniuConfigJson);
    showToast("七牛配置成功");
  } catch (e) {
    _logError('_configureQiniu', {}, e);
    showToast("七牛配置错误");
  }
}

Future<void> _configureTencent(Map<String, dynamic> jsonResult) async {
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
    _logError('_configureTencent', {}, e);
    showToast("腾讯云配置错误");
  }
}

Future<void> _configureAliyun(Map<String, dynamic> jsonResult) async {
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
    _logError('_configureAliyun', {}, e);
    showToast("阿里云配置错误");
  }
}

Future<void> _configureUpyun(Map<String, dynamic> jsonResult) async {
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
    _logError('_configureUpyun', {}, e);
    showToast("又拍云配置错误");
  }
}

// Common helper methods
Future<void> _saveConfig(Future<File> fileGetter, dynamic config) async {
  final file = await fileGetter;
  await file.writeAsString(jsonEncode(config));
}

void _logError(String methodName, Map<String, dynamic> params, dynamic error) {
  flogErr(error, params, 'AllPShostState', methodName);
}

String _normalizePath(String path) {
  if (path.isEmpty || path == '/') return 'None';

  if (path.startsWith('/')) {
    path = path.substring(1);
  }
  if (!path.endsWith('/')) {
    path = '$path/';
  }
  return path;
}

String _normalizeUrl(String url) {
  if (url.isEmpty) return 'None';

  if (!url.startsWith('http') && !url.startsWith('https')) {
    url = 'http://$url';
  }
  if (url.endsWith('/')) {
    url = url.substring(0, url.length - 1);
  }
  return url;
}
