import 'package:horopic/picture_host_configure/configure_page/configure_export.dart';

class ConfigureTemplate {
  static String placeholder = 'undetermined';
  static Map<String, Map<String, String>> psHostNameToTemplate = {
    'lsky.pro': lskyproConfigureTemplate,
    'aliyun': aliyunConfigureTemplate,
    'qiniu': qiniuConfigureTemplate,
    'tencent': tencentConfigureTemplate,
    'upyun': upyunConfigureTemplate,
    'aws': awsConfigureTemplate,
    'ftp': ftpConfigureTemplate,
    'github': githubConfigureTemplate,
    'sm.ms': smmsConfigureTemplate,
    'imgur': imgurConfigureTemplate,
    'alist': alistConfigureTemplate,
    'webdav': webdavConfigureTemplate,
  };

  static List alistConfigureTemplateKeys = AlistConfigModel.keysList;
  static List aliyunConfigureTemplateKeys = AliyunConfigModel.keysList;
  static List awsConfigureTemplateKeys = AwsConfigModel.keysList;
  static List ftpConfigureTemplateKeys = FTPConfigModel.keysList;
  static List githubConfigureTemplateKeys = GithubConfigModel.keysList;
  static List imgurConfigureTemplateKeys = ImgurConfigModel.keysList;
  static List lskyproConfigureTemplateKeys = HostConfigModel.keysList;
  static List qiniuConfigureTemplateKeys = QiniuConfigModel.keysList;
  static List smmsConfigureTemplateKeys = SmmsConfigModel.keysList;
  static List tencentConfigureTemplateKeys = TencentConfigModel.keysList;
  static List upyunConfigureTemplateKeys = UpyunConfigModel.keysList;
  static List webdavConfigureTemplateKeys = WebdavConfigModel.keysList;

  static final Map<String, String> alistConfigureTemplate = {
    for (var k in alistConfigureTemplateKeys) k: placeholder
  };

  static final Map<String, String> aliyunConfigureTemplate = {
    for (var k in aliyunConfigureTemplateKeys) k: placeholder
  };

  static final Map<String, String> awsConfigureTemplate = {
    for (var k in awsConfigureTemplateKeys) k: placeholder
  };

  static final Map<String, String> ftpConfigureTemplate = {
    for (var k in ftpConfigureTemplateKeys) k: placeholder
  };

  static final Map<String, String> githubConfigureTemplate = {
    for (var k in githubConfigureTemplateKeys) k: placeholder
  };

  static final Map<String, String> imgurConfigureTemplate = {
    for (var k in imgurConfigureTemplateKeys) k: placeholder
  };

  static final Map<String, String> lskyproConfigureTemplate = {
    for (var k in lskyproConfigureTemplateKeys) k: placeholder
  };

  static final Map<String, String> qiniuConfigureTemplate = {
    for (var k in qiniuConfigureTemplateKeys) k: placeholder
  };

  static final Map<String, String> smmsConfigureTemplate = {
    for (var k in smmsConfigureTemplateKeys) k: placeholder
  };

  static final Map<String, String> tencentConfigureTemplate = {
    for (var k in tencentConfigureTemplateKeys) k: placeholder
  };

  static final Map<String, String> upyunConfigureTemplate = {
    for (var k in upyunConfigureTemplateKeys) k: placeholder
  };

  static final Map<String, String> webdavConfigureTemplate = {
    for (var k in webdavConfigureTemplateKeys) k: placeholder
  };
}
