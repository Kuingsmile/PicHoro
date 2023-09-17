import 'dart:convert';
import 'package:crypto/crypto.dart';

String getUpyunUploadPolicy(
    {required String bucket, required String saveKey, required String contentMd5, required String date}) {
  Map<String, dynamic> uploadPolicy = {
    'bucket': bucket,
    'save-key': saveKey,
    'expiration': DateTime.now().millisecondsSinceEpoch + 1800000,
    'date': date,
    'content-md5': contentMd5,
  };
  return base64.encode(utf8.encode(json.encode(uploadPolicy)));
}

String getUpyunUploadAuthHeader(
    {required String bucket,
    required String saveKey,
    required String contentMd5,
    required String operator,
    required String password,
    required String base64Policy,
    required String date}) {
  String stringToSign = 'POST&/$bucket&$date&$base64Policy&$contentMd5';
  String passwordMd5 = md5.convert(utf8.encode(password)).toString();
  String signature = base64.encode(Hmac(sha1, utf8.encode(passwordMd5)).convert(utf8.encode(stringToSign)).bytes);
  return 'UPYUN $operator:$signature';
}

String getUpyunAntiLeechParam(
    {required String saveKey, required String antiLeechToken, required String antiLeechExpiration}) {
  String key = '';
  if (saveKey.startsWith('/')) {
    key = saveKey;
  } else {
    key = '/$saveKey';
  }
  if (antiLeechToken == '') {
    return '';
  }
  int dateNowInSecond = (DateTime.now().millisecondsSinceEpoch / 1000).floor();
  int expire = antiLeechExpiration == '' ? dateNowInSecond + 3600 : dateNowInSecond + int.parse(antiLeechExpiration);
  String sign = md5.convert(utf8.encode('$antiLeechToken&$expire&$key')).toString();
  String upt = '_upt=${sign.substring(12, 20)}$expire';
  return upt;
}
